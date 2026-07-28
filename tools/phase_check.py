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
    """`{side}` yer tutucusunu iki tarafa da açar."""
    if "{side}" not in name:
        return [name]
    return [name.replace("{side}", s) for s in ("right", "left")]


def _walk_conditions(cond: dict, path: str, out: list[tuple[str, dict]]) -> None:
    out.append((path, cond))
    for i, sub in enumerate(cond.get("of", []) or []):
        _walk_conditions(sub, f"{path}.of[{i}]", out)


def main() -> int:
    problems: list[str] = []

    phases_doc = json.loads(PHASES.read_text(encoding="utf-8"))
    metrics = _metric_names(json.loads(METRICS.read_text(encoding="utf-8")))
    battery = json.loads(BATTERY.read_text(encoding="utf-8"))
    battery_ids = {t["id"] for t in battery["tests"]}

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

    print(f"Faz denetimi — {len(defined)}/{len(battery_ids)} test tanımlı")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ Tüm değişmezler sağlanıyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
