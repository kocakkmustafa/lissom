#!/usr/bin/env python3
"""L-031 ölçümü: Dart canlı yol ↔ normatif Python yorumlayıcısı.

L-031 defterde "uzay farkı sistematik sapma ÜRETEBİLİR" diye kayıtlıydı —
bir olasılık olarak. Bu araç onu SAYIYA çevirir: aynı fixture'ın aynı
karelerinde iki hattı yan yana koşturur ve eşleştirilmiş farkı raporlar.

Üç hesap kıyaslanır:
  HAM  Dart, ham anizotropik `lm`            (J-028 düzeltmesi ÖNCESİ davranış)
  İZO  Dart, `toIsotropic` sonrası           (şimdiki kod)
  REF  Python, `world` 3D + config frameRef  (NORMATİF — çekirdek doktrini:
       "when the two disagree, this package is right by definition")

Karşılaştırmanın Python tarafında olması kasıtlı: hakemi taraflardan biri
yapmamak için.

Kullanım (iki adım):
  cd packages/lissom_engine && dart run tool/dump_angles.dart /tmp/dart.json
  python3 tools/l031_space_divergence.py /tmp/dart.json

## Kanıt zinciri (`--claim-equivalence`, M-F-462/474 — koordinatör onayı 2026-08-12)

Varsayılan koşum yalnız RAPOR basar (yukarıdaki gibi) — hiçbir dosya
YAZMAZ. `--claim-equivalence` AÇIKÇA istenirse (üç zorunlu argümanla
birlikte) `docs/L-031-ESDEGERLIK-KANITI.json` yazılır: `test/
reference_equivalence_test.dart`in `kBridgeIsReferenceEquivalent=true`
iddiasını bağladığı kanıt. Bu bayrak, `reference_equivalence_test.dart`ın
KENDİSİNİN de bir gün taşıyabileceği regex-tabanlı sahte-nesir zaafına
(`mutation_reference_equivalence.py`, 2026-08-11, KANITLANDI) karşı: nesir
yerine İÇERİK-HASH bağı + üreticinin git-izlenebilirliği + üreticinin
KENDİ kabul-hükmü (yeniden hesaplanmaz, yalnız OKUNUR — kapı kendi kendini
ölçen taraf olamaz, Choreia `readers_of()` ilkesi).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
PIPE = (REPO / "../../motion-core/lib/tools/fixture_pipeline").resolve()
HARVEST = Path.home() / "motion-harvest/lissom/landmarks"
WITNESS = REPO / "docs/L-031-ESDEGERLIK-KANITI.json"

#: Ölçülen KOD DURUMUNU bağlayan girdiler — `test/reference_equivalence_
#: test.dart`in `_inputPaths`iyle AYNI liste, elle senkron tutulur (iki
#: dilde paylaşılan tek kaynak yok — ayrışırsa harita anahtarları
#: uyuşmaz ve İKİ TARAF da testte YAKALANIR, sessizce kaçmaz).
INPUT_PATHS = [
    "packages/lissom_engine/lib/src/metric_bridge.dart",
    "config/tests/lissom-assessment.v1.json",
    "config/metrics/lissom-metrics.v1.json",
]

if not PIPE.exists():  # pragma: no cover
    sys.exit(f"normatif yorumlayıcı bulunamadı: {PIPE}")
sys.path.insert(0, str(PIPE))

from mocore import geometry as geo  # noqa: E402
from mocore import measures as ms  # noqa: E402


def load_defs() -> dict[str, ms.MetricDef]:
    raw = json.loads((REPO / "config/metrics/lissom-metrics.v1.json").read_text())
    out: dict[str, ms.MetricDef] = {}
    for m in raw["metrics"]:
        d = ms.MetricDef.from_dict(m)
        out[d.id] = d
        if m.get("mirror"):
            mid = (m["id"].replace("_right", "_left")
                   if "_right" in m["id"] else m["id"].replace("_left", "_right"))
            out[mid] = d.mirrored(mid)
    return out


def stat(d: np.ndarray) -> dict | None:
    d = np.asarray(d, dtype=float)
    d = d[np.isfinite(d)]
    if d.size == 0:
        return None
    a = np.abs(d)
    return dict(n=int(d.size), med=float(np.median(a)),
                p95=float(np.percentile(a, 95)), mx=float(a.max()),
                bias=float(np.median(d)))


def fmt(s: dict | None) -> str:
    if s is None:
        return "ölçülemedi (n=0)"
    return (f"med={s['med']:6.2f}° p95={s['p95']:6.2f}° "
            f"max={s['mx']:7.2f}° bias={s['bias']:+6.2f}° n={s['n']}")


def _sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _inputs_sha256() -> dict[str, str]:
    return {p: _sha256_file(REPO / p) for p in INPUT_PATHS}


def _motion_core_pin() -> str | None:
    """`pubspec.lock`taki `motion_core` pin'i — L-031'in ölçtüğü sapmanın
    Dart tarafı bu SHA'nın geometrisine bağlı; sessizce değişmemeli."""
    lock = REPO / "pubspec.lock"
    if not lock.exists():
        return None
    m = re.search(r"motion_core:\n(?:.*\n)*?\s*resolved-ref:\s*(\S+)",
                  lock.read_text())
    return m.group(1) if m else None


def _script_tracked() -> bool:
    """Bu script'in KENDİSİ bu ağaçta git-takipli mi (`rig_version()`'ın
    1. kademesinin dar hâli, M-F-135 — çok-repo kimlik denetimi Lissom
    tek-repo olduğu için gereksiz, yalnız 'elle kopya mı' sorusu kalır)."""
    here = Path(__file__).resolve()
    try:
        out = subprocess.run(
            ["git", "-C", str(here.parent), "ls-files", "--error-unmatch",
             str(here)],
            capture_output=True, text=True, timeout=15)
    except (OSError, subprocess.TimeoutExpired):
        return False
    return out.returncode == 0


def _parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("dart_json", help="dump_angles.dart çıktısı")
    p.add_argument(
        "--claim-equivalence", action="store_true",
        help=f"{WITNESS.relative_to(REPO)} yaz — GERÇEK bir kabul iddiası")
    p.add_argument("--acceptance-statement",
                    help="kabul ölçütünün gerekçesi (ölçenin KENDİ beyanı)")
    p.add_argument("--acceptance-median-bar-deg", type=float,
                    help="kabul edilir medyan |sapma| üst sınırı, derece")
    p.add_argument("--acceptance-p95-bar-deg", type=float,
                    help="kabul edilir p95 |sapma| üst sınırı, derece")
    args = p.parse_args(argv)
    if args.claim_equivalence:
        missing = [name for name, val in (
            ("--acceptance-statement", args.acceptance_statement),
            ("--acceptance-median-bar-deg", args.acceptance_median_bar_deg),
            ("--acceptance-p95-bar-deg", args.acceptance_p95_bar_deg),
        ) if val is None]
        if missing:
            p.error("--claim-equivalence şunları ZORUNLU kılar (eşik burada "
                     "İCAT EDİLMEZ — ölçenin KENDİ beyanı olmalı): "
                     + ", ".join(missing))
    return args


def _write_witness(dart_json_path: Path, rows: list[tuple], args: argparse.Namespace) -> None:
    cells = [
        {"fixture": fid, "metric": m, "medianAbsDeg": mi, "p95AbsDeg": pi}
        for fid, m, _mr, mi, _pr, pi in rows
    ]
    overall_median = float(np.mean([r[3] for r in rows]))
    overall_p95 = float(np.mean([r[5] for r in rows]))
    passes = bool(overall_median <= args.acceptance_median_bar_deg
                  and overall_p95 <= args.acceptance_p95_bar_deg)
    witness = {
        "measuredAt": datetime.now(timezone.utc).isoformat(),
        "producedBy": {
            "script": "tools/l031_space_divergence.py",
            "tracked": _script_tracked(),
        },
        "inputsSha256": _inputs_sha256(),
        "motionCorePin": _motion_core_pin(),
        "dartAnglesSha256": _sha256_file(dart_json_path),
        "measured": {
            "cells": cells,
            "overallMedianAbsDeg": overall_median,
            "overallP95AbsDeg": overall_p95,
        },
        "acceptanceCriterion": {
            "statement": args.acceptance_statement,
            "medianBarDeg": args.acceptance_median_bar_deg,
            "p95BarDeg": args.acceptance_p95_bar_deg,
        },
        "passesOwnCriterion": passes,
    }
    WITNESS.write_text(json.dumps(witness, indent=2, ensure_ascii=False) + "\n")
    print(f"\n{'✅' if passes else '❌'} kanıt yazıldı: "
          f"{WITNESS.relative_to(REPO)} (passesOwnCriterion={passes})")


def main(argv: list[str]) -> int:
    args = _parse_args(argv)
    dart_json_path = Path(args.dart_json)
    dart = json.loads(dart_json_path.read_text())
    skipped: list[str] = []
    defs = load_defs()
    rows: list[tuple] = []

    for fid, block in dart.items():
        path = HARVEST / f"{fid}.full.json"
        if not path.exists():
            print(f"ATLANDI (fixture yok): {fid}")
            skipped.append(fid)
            continue
        recs = [r for r in json.loads(path.read_text())["frames"]
                if r.get("detected")]
        # Eşleştirme geçersizse SESSİZCE kıyaslamak en kötüsü olur.
        n_dart = len(next(iter(block["raw"].values())))
        if len(recs) != n_dart:
            print(f"⚠️ {fid}: kare sayısı uyuşmuyor "
                  f"(Dart {n_dart} / Python {len(recs)}) — ATLANDI")
            skipped.append(fid)
            continue
        frames = [
            geo.Frame(
                xyz=np.array(r["world"], dtype=float),
                visibility=np.array(r["lm"], dtype=float)[:, 3],
                presence=np.array(r["lm"], dtype=float)[:, 4],
                t_ms=float(r["t"]),
            )
            for r in recs
        ]
        print(f"\n=== {fid}  {block['resolution']} "
              f"(aspect {block['aspect']:.3f})  {len(recs)} kare ===")
        for metric in block["raw"]:
            md = defs.get(metric)
            if md is None:
                print(f"  {metric}: config'te TANIMSIZ — atlandı")
                continue
            # ⚠️ `valid` OTORİTE, `isfinite` DEĞİL (L-197, ölçülmüş kusur):
            # rig'in `mask_invalid` varsayılanından ÖNCE geçersiz ölçümler
            # `value` alanında HAM/ÇÖP sayı taşıyordu, yalnız `valid=False`
            # yan-kanal bayrağıyla işaretli. Bu döngü bayrağı okumuyordu, yani
            # REF serisi geçersiz ölçümlerle KİRLENİYORDU ve L-187'nin sapma
            # sayıları o kirlilikle raporlanmıştı. Geçersizi NaN'a çevirmek
            # aşağı akıştaki `isfinite` süzgeciyle onu dürüstçe DIŞLAR.
            ref = np.array(
                [(m.value if m.valid else np.nan)
                 for m in (ms.evaluate(md, fr, anatomical=True)
                           for fr in frames)],
                dtype=float)
            raw = np.array([np.nan if v is None else v
                            for v in block["raw"][metric]], dtype=float)
            iso = np.array([np.nan if v is None else v
                            for v in block["iso"][metric]], dtype=float)
            s_raw, s_iso, s_gain = stat(raw - ref), stat(iso - ref), stat(iso - raw)
            print(f"  {metric}")
            print(f"    HAM↔REF   {fmt(s_raw)}")
            print(f"    İZO↔REF   {fmt(s_iso)}")
            print(f"    İZO−HAM   {fmt(s_gain)}  <- J-028 düzeltmesinin etkisi")
            if s_raw and s_iso:
                rows.append((fid, metric, s_raw["med"], s_iso["med"],
                             s_raw["p95"], s_iso["p95"]))

    if not rows:
        print("\nHİÇ kıyas yapılamadı — rapor üretilmedi.")
        return 1

    print("\n\n=== ÖZET (medyan ve p95 |sapma|, HAM → İZO) ===")
    print(f"{'fixture':14s} {'metrik':26s} {'medHAM':>7s} {'medİZO':>7s} "
          f"{'p95HAM':>7s} {'p95İZO':>7s}")
    for fid, m, mr, mi, pr, pi in rows:
        print(f"{fid:14s} {m:26s} {mr:7.2f} {mi:7.2f} {pr:7.2f} {pi:7.2f}")
    mr, mi = np.mean([r[2] for r in rows]), np.mean([r[3] for r in rows])
    pr, pi = np.mean([r[4] for r in rows]), np.mean([r[5] for r in rows])
    print(f"\n{'ORTALAMA':14s} {'':26s} {mr:7.2f} {mi:7.2f} {pr:7.2f} {pi:7.2f}")
    print(f"\nmedyan: {mr:.2f}° → {mi:.2f}°  ({(mi - mr) / mr * 100:+.1f}%)")
    print(f"p95   : {pr:.2f}° → {pi:.2f}°  ({(pi - pr) / pr * 100:+.1f}%)")
    print(f"\nKALAN sapma (İZO↔REF) L-031'in gerçek kapsamıdır: "
          f"medyan {mi:.2f}°, p95 {pi:.2f}°.")

    if args.claim_equivalence:
        if skipped:
            print(f"\n⛔ KANIT YAZILMADI: {len(skipped)} fixture ATLANDI "
                  f"({', '.join(skipped)}) — eksik kapsamdan 'referans-"
                  f"eşdeğer' iddia edilemez, kanıt EKSİKSİZ koşumu gerektirir.")
            return 1
        _write_witness(dart_json_path, rows, args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
