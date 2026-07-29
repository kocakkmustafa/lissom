#!/usr/bin/env python3
"""Faz config'i yapısal denetimi — CI kapısı.

Neden gerekli: faz tanımları çekirdeğe `PhaseDefinition` olarak akacak ve orada
hatalı bir dizi sessizce "kullanıcı hareketsiz" gibi görünür. Çekirdeğin kendi
dokümantasyonu bunu açıkça uyarıyor: *timeout'u olmayan bir faz, çıkış koşulunu
kaçırdığında sonsuza park eder ve geri bildirim üretmeyi sessizce durdurur.*

Denetlenen değişmezler:
  1. Her testin TAM BİR terminal fazı var
  2. Terminal olmayan her fazın `timeoutMs` değeri var (park etme koruması)
  3. Her testte tam bir `measureHere` fazı var (ölçüm nerede alınıyor belli)
  4. Koşullarda geçen her metrik, metrik setinde TANIMLI
  5. Koşul dilbilgisi geçerli (bilinen `kind`, bilinen `op`)
  6. Faz id'leri test içinde benzersiz
  7. Batarya'daki her testin faz tanımı var (kapsam boşluğu yok)
  8. Terminal olmayan her fazın `timeoutCode`'u var — `timeoutMs` yalnız
     sonsuz-parkı önler, kullanıcıya bir SONUÇ ulaştırmaz. `abort`/`abortCode`
     eşleşmesi (madde 9) bunu abort için zaten sağlıyordu; plain timeout aynı
     korumadan yoksundu ve `peak_hold`'a hiç girilmeden `raising`/`bending`
     timeout'u sessizce düşebiliyordu (L-135/L-146, M-F-71 madde 4) — bu artık
     kapı, gözlem değil.
  9. `abort` koşulu olan her fazın `abortCode`'u var

Bağımlılık YOK — saf stdlib.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PHASES = ROOT / "config/phases/lissom-phases.v1.json"
METRICS = ROOT / "config/metrics/lissom-metrics.v1.json"
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"

VALID_KINDS = {"metric", "delta", "timeInPhase", "confidence", "all", "any"}
VALID_OPS = {">", ">=", "<", "<=", "==", "!="}


def _metric_names(doc: dict) -> set[str]:
    """Metrik setindeki tüm id'ler — ayna türevleri dahil."""
    out: set[str] = set()
    for m in doc["metrics"]:
        out.add(m["id"])
        if m.get("mirror"):
            mid = m["id"]
            if mid.endswith("_right"):
                out.add(mid[: -len("_right")] + "_left")
            elif mid.endswith("_left"):
                out.add(mid[: -len("_left")] + "_right")
    return out


def _resolve(name: str, per_side: bool) -> list[str]:
    """`{side}` / `{opposite}` yer tutucularını iki tarafa da açar.

    `{opposite}` karşı tarafı gösterir — ASLR'de kaldırılan bacak `{side}`,
    yerde kalması gereken bacak `{opposite}`. Çözülmediği sürece o guard hiçbir
    metriğe bağlanamıyordu (L-081).
    """
    if "{side}" not in name and "{opposite}" not in name:
        return [name]
    out = []
    for s in ("right", "left"):
        o = "left" if s == "right" else "right"
        out.append(name.replace("{side}", s).replace("{opposite}", o))
    return out


def _walk_conditions(cond: dict, path: str, out: list[tuple[str, dict]]) -> None:
    out.append((path, cond))
    for i, sub in enumerate(cond.get("of", []) or []):
        _walk_conditions(sub, f"{path}.of[{i}]", out)


def check(phases_doc: dict, metrics_doc: dict, battery_doc: dict) -> list[str]:
    """Tüm değişmezleri sınar, sorun cümlelerinin listesini döner (boşsa temiz).

    `main()`'den ayrı: `phase_check_selftest.py` gerçek dosyaları OKUMADAN,
    bozulmuş bir in-memory kopyayla bu fonksiyonu çağırıp denetimin gerçekten
    yakaladığını kanıtlar — `wellness_lint.py`'nin `--path` deseninin
    faz-config eşdeğeri (burada CLI parametre yerine fonksiyon parametresi:
    faz denetimi tek dosya değil üç dosyanın çapraz-tutarlılığını okur).
    """
    problems: list[str] = []
    battery_ids = {t["id"] for t in battery_doc["tests"]}
    metrics = _metric_names(metrics_doc)

    defined: set[str] = set()
    for test in phases_doc["tests"]:
        tid = test["testId"]
        defined.add(tid)
        per_side = bool(test.get("perSide"))
        ph = test["phases"]

        if tid not in battery_ids:
            problems.append(f"{tid}: bataryada böyle bir test yok")

        ids = [p["id"] for p in ph]
        if len(ids) != len(set(ids)):
            problems.append(f"{tid}: faz id'leri benzersiz değil — {ids}")

        terminals = [p["id"] for p in ph if p.get("isTerminal")]
        if len(terminals) != 1:
            problems.append(
                f"{tid}: tam bir terminal faz olmalı, {len(terminals)} var ({terminals})"
            )

        measured = [p["id"] for p in ph if p.get("measureHere")]
        if len(measured) != 1:
            problems.append(
                f"{tid}: tam bir `measureHere` fazı olmalı, {len(measured)} var ({measured})"
            )

        for p in ph:
            if not p.get("isTerminal") and "timeoutMs" not in p:
                problems.append(
                    f"{tid}.{p['id']}: `timeoutMs` YOK — çıkış koşulu kaçarsa faz "
                    "sonsuza park eder ve bu 'kullanıcı hareketsiz' gibi görünür"
                )
            if not p.get("isTerminal") and "timeoutMs" in p and "timeoutCode" not in p:
                problems.append(
                    f"{tid}.{p['id']}: `timeoutMs` var ama `timeoutCode` yok — "
                    "zaman aşımı sessizce düşer, kullanıcıya ulaşan bir sonuç "
                    "kodu üretmez (L-135/L-146, M-F-71 madde 4)"
                )
            conds: list[tuple[str, dict]] = []
            for key in ("enter", "exit", "abort"):
                if key in p and p[key]:
                    _walk_conditions(p[key], f"{tid}.{p['id']}.{key}", conds)
            for cpath, c in conds:
                kind = c.get("kind")
                if kind not in VALID_KINDS:
                    problems.append(f"{cpath}: bilinmeyen kind {kind!r}")
                    continue
                if "op" in c and c["op"] not in VALID_OPS:
                    problems.append(f"{cpath}: bilinmeyen op {c['op']!r}")
                if kind in ("metric", "delta"):
                    for name in _resolve(c.get("metric", ""), per_side):
                        if name not in metrics:
                            problems.append(
                                f"{cpath}: metrik setinde tanımsız — {name!r}"
                            )
            if p.get("abort") and not p.get("abortCode"):
                problems.append(
                    f"{tid}.{p['id']}: `abort` var ama `abortCode` yok — "
                    "kullanıcı neden durduğunu öğrenemez"
                )

    missing = battery_ids - defined
    if missing:
        problems.append(
            f"Bataryada olup faz tanımı OLMAYAN test(ler): {', '.join(sorted(missing))}"
        )

    return problems


def main() -> int:
    phases_doc = json.loads(PHASES.read_text(encoding="utf-8"))
    metrics_doc = json.loads(METRICS.read_text(encoding="utf-8"))
    battery_doc = json.loads(BATTERY.read_text(encoding="utf-8"))
    battery_ids = {t["id"] for t in battery_doc["tests"]}
    defined = {t["testId"] for t in phases_doc["tests"]}

    problems = check(phases_doc, metrics_doc, battery_doc)

    print(f"Faz denetimi — {len(defined & battery_ids)}/{len(battery_ids)} test tanımlı")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ Tüm değişmezler sağlanıyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
