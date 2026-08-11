#!/usr/bin/env python3
"""MUT-A: `reference_equivalence_test.dart` — kanıt-zinciri koruması
(L-277, M-F-462/474, koordinatör onayı 2026-08-12).

## Önceki hâl — ölçüldü, YALANLANDI, DEĞİŞTİRİLDİ

Bu dosyanın İLK sürümü (2026-08-11) `docs/L-031-UZAY-SAPMASI-OLCUMU.md`'nin
NESRİNİ regex'le tarayan bir kapıyı sınıyordu. 2. mutasyon turu (500+
karakterlik gerçekçi ama tamamen UYDURMA bir paragraf, hiçbir gerçek ölçüm
olmadan) o kapıyı geçti — regex nesri doğruluyordu, ispatı değil.

Kapı o zaman (`test/reference_equivalence_test.dart`) yeniden yazıldı:
artefaktı `docs/L-031-ESDEGERLIK-KANITI.json` KANIT ZİNCİRİNE bağlıyor —
YALNIZ `tools/l031_space_divergence.py --claim-equivalence` tarafından
yazılabilen bir dosya (içerik-hash haritası + üretici git-izlenebilirliği +
üreticinin KENDİ kabul-hükmü, yeniden hesaplanmadan OKUNUR).

## Bu dosya YENİ kapıyı koordinatörün istediği ÜÇ sahneyle sınar

  1. **asıl delik**   — bayrak+uzay elle değişir, JSON'a DOKUNULMAZ.
  2. **bayatlık**      — JSON yazılır ama `inputsSha256` ESKİ koda ait
                         (ölçüm YAPILMIŞ OLABİLİR ama bugünkü kod durumunu
                         KANITLAMIYOR).
  3. **pozitif çapa**  — GERÇEK bir `--claim-equivalence` koşumu (tek
                         fixture, kasten gevşek bar — bkz. altta).

(3) olmadan bu harness yalnız "her zaman kırmızı" bir kapıyı da
GEÇİRİRDİ — mekanizmanın GERÇEKTEN çalıştığını, yalnız her şeyi
körlemesine reddetmediğini kanıtlamak ÇAPANIN kendisidir (L-183 dersi,
Ostinato'nun taklit-kontrolü ilkesiyle aynı).
"""
from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from mutation_lock import LockHeld, MutationRun, RestoreFailed  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
METRIC_BRIDGE = ROOT / "packages/lissom_engine/lib/src/metric_bridge.dart"
WITNESS = ROOT / "docs/L-031-ESDEGERLIK-KANITI.json"

#: Yalnız `metric_bridge.dart` MutationRun'a EMANET — `docs/L-031-UZAY-
#: SAPMASI-OLCUMU.md` bu turda hiç mutasyona uğramıyor (artık o değil,
#: JSON kanıtı hedef) ve `WITNESS` MutationRun'ın kapsamı DIŞINDA: dosya
#: temiz tabanda hiç YOK, `MutationRun.__enter__` var-olmayan bir dosyayı
#: yedekleyemez. Yaşam döngüsü elle yönetiliyor (`_clear_witness`).
TOUCHED = [METRIC_BRIDGE]

INPUT_PATHS = [
    "packages/lissom_engine/lib/src/metric_bridge.dart",
    "config/tests/lissom-assessment.v1.json",
    "config/metrics/lissom-metrics.v1.json",
]

GATES = {
    "reference_equivalence (app)": [
        "flutter", "test", "test/reference_equivalence_test.dart"],
    "metric_coverage (engine)": [
        "flutter", "test", "test/metric_coverage_test.dart"],
}


def run_gates() -> dict[str, bool]:
    """{kapı adı: yeşil mi}."""
    results: dict[str, bool] = {}
    results["reference_equivalence (app)"] = subprocess.run(
        GATES["reference_equivalence (app)"], cwd=ROOT,
        capture_output=True).returncode == 0
    results["metric_coverage (engine)"] = subprocess.run(
        GATES["metric_coverage (engine)"], cwd=ROOT / "packages/lissom_engine",
        capture_output=True).returncode == 0
    return results


def _clear_witness() -> None:
    WITNESS.unlink(missing_ok=True)


def _flip_flag_and_space() -> None:
    """L-187 göçünün YAPISAL kısmı — bayrak+uzay TUTARLI çevrilir.

    Gerçekçi senaryo hep bu: mühendis göçü yapar (bu adım kendi başına
    DOĞRUDUR, `metric_coverage_test.dart`'ı da yeşil tutar), soru ondan
    SONRA gerçek yeniden-ölçümün yapılıp yapılmadığıdır.
    """
    src = METRIC_BRIDGE.read_text()
    mutated = src.replace(
        "const bool kBridgeIsReferenceEquivalent = false;",
        "const bool kBridgeIsReferenceEquivalent = true;",
    ).replace(
        "const MeasurementSpace kBridgeSpace = MeasurementSpace.isotropic;",
        "const MeasurementSpace kBridgeSpace = MeasurementSpace.world;",
    )
    assert "kBridgeIsReferenceEquivalent = true" in mutated, \
        "bayrak satırı bulunamadı — mutasyon UYGULANAMADI"
    assert "kBridgeSpace = MeasurementSpace.world" in mutated, \
        "uzay satırı bulunamadı — mutasyon UYGULANAMADI"
    METRIC_BRIDGE.write_text(mutated)


def scenario_1_flag_flipped_no_witness() -> dict[str, bool]:
    """ASIL DELİK: elle bayrak+uzay değiştir, JSON'a DOKUNMA.

    L-254'ün ilk hâlinin tam sahtekârlığı — artık kanıt dosyası YOK
    olduğu için ek bir sahte-nesir yazmaya bile gerek kalmıyor.
    """
    _flip_flag_and_space()
    return run_gates()


def scenario_2_witness_present_but_stale() -> dict[str, bool]:
    """BAYATLIK: JSON yazılır, `passesOwnCriterion=true` bile der, ama
    `inputsSha256` mutasyon ÖNCESİ koda ait — yani "ölçüm yapıldıysa BİLE
    bugünkü kod durumunu KANITLAMIYOR" senaryosu.
    """
    stale_sha = {p: hashlib.sha256((ROOT / p).read_bytes()).hexdigest()
                 for p in INPUT_PATHS}
    _flip_flag_and_space()  # ŞİMDİ kod değişti — yukarıdaki hash artık BAYAT.
    WITNESS.write_text(json.dumps({
        "measuredAt": "2026-01-01T00:00:00+00:00",
        "producedBy": {"script": "tools/l031_space_divergence.py",
                        "tracked": True},
        "inputsSha256": stale_sha,
        "motionCorePin": "f13bdc93b2eae2f741bfcdb4c9270a88e5d75e5d",
        "dartAnglesSha256": "0" * 64,
        "measured": {"cells": [], "overallMedianAbsDeg": 1.0,
                     "overallP95AbsDeg": 2.0},
        "acceptanceCriterion": {"statement": "SABOTAJ — bayat kanıt",
                                 "medianBarDeg": 999.0, "p95BarDeg": 999.0},
        "passesOwnCriterion": True,
    }, indent=2, ensure_ascii=False))
    return run_gates()


def scenario_3_real_run() -> dict[str, bool]:
    """POZİTİF ÇAPA: GERÇEK bir `--claim-equivalence` koşumu.

    Tek fixture (`X2u_vGL0qJU`, harvest'te mevcut) — TAM 3-fixture/8-metrik
    L-031 turunu tekrarlamıyor (pahalı, ayrı bir karar), yalnız mekanizmanın
    UÇTAN UCA (gerçek `dump_angles.dart` + gerçek `l031_space_divergence.py`
    + gerçek dosya hash'leri) GEÇİRDİĞİNİ kanıtlıyor. Kabul barı KASTEN
    gevşek (1000°) — bu bir ürün kararı DEĞİL, yalnız "mekanizma her şeyi
    reddetmiyor" çapası. Gerçek bir L-187 kabul kararı, gerçek bir
    movement-science-advisor barıyla ayrıca koşulmalı.
    """
    _flip_flag_and_space()
    try:
        with tempfile.TemporaryDirectory() as td:
            dart_json = Path(td) / "dart_selftest.json"
            dump = subprocess.run(
                ["dart", "run", "tool/dump_angles.dart", str(dart_json),
                 "X2u_vGL0qJU"],
                cwd=ROOT / "packages/lissom_engine",
                capture_output=True, text=True, timeout=300)
            if dump.returncode != 0:
                print(f"⛔ dump_angles.dart BAŞARISIZ (pozitif çapa "
                      f"koşulamadı):\n{dump.stdout[-2000:]}\n{dump.stderr[-2000:]}")
                return {g: False for g in GATES}
            claim = subprocess.run(
                [sys.executable, "tools/l031_space_divergence.py",
                 str(dart_json), "--claim-equivalence",
                 "--acceptance-statement",
                 "MUTASYON ÖZ-TESTİ — GERÇEK bir kabul kararı DEĞİL, "
                 "yalnız mekanizmanın gerçek kanıtı GEÇİRDİĞİNİ doğrulamak "
                 "için kasten gevşek bir bar (tek fixture X2u_vGL0qJU, "
                 "İZO↔REF).",
                 "--acceptance-median-bar-deg", "1000",
                 "--acceptance-p95-bar-deg", "1000"],
                cwd=ROOT, capture_output=True, text=True, timeout=120)
            if claim.returncode != 0:
                print(f"⛔ --claim-equivalence BAŞARISIZ (pozitif çapa "
                      f"koşulamadı):\n{claim.stdout[-2000:]}\n{claim.stderr[-2000:]}")
                return {g: False for g in GATES}
    except (OSError, subprocess.TimeoutExpired) as e:
        print(f"⛔ pozitif çapa koşum HATASI: {e!r}")
        return {g: False for g in GATES}
    return run_gates()


SCENARIOS = [
    ("1_asil_delik", scenario_1_flag_flipped_no_witness,
     {"reference_equivalence (app)": False}),
    ("2_bayatlik", scenario_2_witness_present_but_stale,
     {"reference_equivalence (app)": False}),
    ("3_pozitif_capa", scenario_3_real_run,
     {"reference_equivalence (app)": True, "metric_coverage (engine)": True}),
]


def main() -> int:
    try:
        with MutationRun(TOUCHED) as run:
            _clear_witness()
            baseline = run_gates()
            if not all(baseline.values()):
                print(f"⛔ TABAN KIRMIZI ({baseline}) — mutasyon ölçümü anlamsız")
                return 1
            print(f"taban: {baseline}\n")

            outcomes: dict[str, dict[str, bool]] = {}
            try:
                for name, fn, _expect in SCENARIOS:
                    print(f"--- sahne: {name} ---")
                    outcomes[name] = fn()
                    print(f"  sonuç: {outcomes[name]}\n")
                    run.restore_for_next()
                    _clear_witness()
            finally:
                _clear_witness()
    except LockHeld as e:
        print(f"⛔ {e}")
        return 1
    except RestoreFailed as e:
        print(f"⛔ GERİ-YÜKLEME BAŞARISIZ — repo BOZUK olabilir, elle bakın: {e}")
        return 3

    ok = True
    for name, _fn, expect in SCENARIOS:
        got = outcomes.get(name, {})
        for gate, want_green in expect.items():
            green = got.get(gate, False)
            match = green == want_green
            ok = ok and match
            beklenen = "YEŞİL" if want_green else "KIRMIZI"
            gercek = "yeşil" if green else "kırmızı"
            print(f"{'✅' if match else '❌'} {name} / {gate}: beklenen "
                  f"{beklenen}, gerçek {gercek}")

    if ok:
        print("\n✅ ÜÇ SAHNE DE BEKLENEN: asıl delik kırmızı, bayatlık "
              "kırmızı, pozitif çapa yeşil — kanıt zinciri hem KAÇAK "
              "SIZDIRMIYOR hem GERÇEK ölçümü REDDETMİYOR.")
        return 0
    print("\n🔴 EN AZ BİR SAHNE BEKLENMEDİK — kapı ya kaçak sızdırıyor ya "
          "da gerçek kanıtı da reddediyor.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
