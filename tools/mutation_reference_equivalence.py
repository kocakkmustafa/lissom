#!/usr/bin/env python3
"""MUT-A: `reference_equivalence_test.dart` — GERÇEK iki-bağımsız-kaynak
çelişki kapısı (`docs/CELISKI-KAPISI-ENVANTERI-2026-08-11.md`, öncelik #1,
koordinatör seçimi — "en net vaka").

Kaynak 1: `kBridgeIsReferenceEquivalent` (+ `kBridgeSpace`) —
`metric_bridge.dart`'ta mühendisin elle değiştirdiği KOD sabitleri.
Kaynak 2: `docs/L-031-UZAY-SAPMASI-OLCUMU.md` — ayrı bir ölçüm turunun
yazdığı ARTEFAKT. İkisi AYRI dosyalar, AYRI insanlar/turlar tarafından
düzenlenebilir — Ostinato'nun ruleset↔reference-artefakt deseninin
BİREBİR karşılığı (JSON değil ama aynı risk şekli: iki bağımsız dosya).

## Mutasyon NEDEN üç parçalı (iki değil)

İlk tasarım yalnız bayrağı `true` yapıp artefaktı sahtelemeyi planlıyordu.
Ölçtüm: `metric_coverage_test.dart`da ZATEN bir üçüncü çapa VAR —
`expect(kBridgeIsReferenceEquivalent, kBridgeSpace == MeasurementSpace
.world)` — yani bayrağı `kBridgeSpace`i DEĞİŞTİRMEDEN `true` yapmak zaten
BAŞKA bir kapıda yakalanır. Bu, sınanması gereken GERÇEK riski gizlerdi:
*mühendis L-187 göçünü YAPARSA (kBridgeSpace'i de world'e çevirirse) ama
GERÇEK ölçümü ATLARSA* — üç parçalı mutasyon bu gerçekçi senaryoyu kurar:
kod bayrağı + kod uzayı + artefakt, ÜÇÜ BİRDEN tutarlı.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from mutation_lock import LockHeld, MutationRun, RestoreFailed  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
METRIC_BRIDGE = ROOT / "packages/lissom_engine/lib/src/metric_bridge.dart"
L031 = ROOT / "docs/L-031-UZAY-SAPMASI-OLCUMU.md"
TOUCHED = [METRIC_BRIDGE, L031]

#: İki gate BİRDEN koşulur — yalnız hedef kapıyı değil, ÖLÇÜLMÜŞ üçüncü
#: çapa adayını da (metric_coverage_test.dart) içeren TAM CÜMLE.
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


def mutate_all_three_consistently() -> None:
    """Kod bayrağı + kod uzayı + docs artefaktı — ÜÇÜ BİRDEN, tutarlı.

    Gerçekçi senaryo: L-187 göçü YAPILDI (kBridgeSpace world'e çevrildi,
    bu YAPISAL olarak doğru bir adım) ama GERÇEK yeniden-ölçüm ATLANDI —
    artefakt eski sayılarla ya da uydurma sayılarla "geçer" hâle getirildi.
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

    # reference_equivalence_test.dart'ın dört ZORUNLU alanını da taşıyan,
    # GERÇEKÇİ UZUNLUKTA (>500 karakter — gerçek artefakt 10 KB, bir
    # sahtekârın "inandırıcı" bir metin yazması ucuzdur), ama HİÇBİR GERÇEK
    # ölçüme dayanmayan sahte artefakt. İLK SÜRÜM 256 karakterdi ve kapı
    # onu YALNIZ `doc.length > 500` kontrolüyle yakaladı — bu, "sahteliği
    # ANLADI" değil "kısaydı" demekti (ölçüldü, öz-eleştiri aşağıda).
    L031.write_text(
        "# L-031 Uzay Sapması Ölçümü — göç-sonrası yeniden ölçüm "
        "(SABOTAJ: GERÇEK ölçüm DEĞİL, inandırıcı uzunlukta uydurma)\n\n"
        "## Yöntem\n\n"
        "L-187 göçü sonrası `metric_bridge.dart` dünya-uzayına geçti. "
        "Bu ölçüm, göç sonrası Dart↔Python sapmasını yeniden karakterize "
        "etmek için `l031_space_divergence.py ile üretildi` komutu "
        "koşularak yapıldı. Örneklem: 12 testin tamamı, gerçek fixture "
        "hasadından türetilen açı çiftleri.\n\n"
        "## Sonuç\n\n"
        "Göç sonrası yeniden ölçüldü: medyan sapma 2,1°, p95 sapma 5,0°. "
        "Bu, göç öncesi 11,29°/37,47° sapmasına göre büyük bir iyileşme "
        "gösteriyor ve dünya-uzayı geçişinin beklenen etkisiyle tutarlı.\n\n"
        "## Kabul ölçütü\n\n"
        "kabul ölçütü: medyan < 5° (bu sabotajın kendi uydurduğu eşik, "
        "GERÇEK bir kabul kararına dayanmıyor).\n"
    )


def main() -> int:
    try:
        with MutationRun(TOUCHED):
            baseline = run_gates()
            if not all(baseline.values()):
                print(f"⛔ TABAN KIRMIZI ({baseline}) — mutasyon ölçümü anlamsız")
                return 1

            mutate_all_three_consistently()
            mutated = run_gates()
    except LockHeld as e:
        print(f"⛔ {e}")
        return 1
    except RestoreFailed as e:
        print(f"⛔ GERİ-YÜKLEME BAŞARISIZ — repo BOZUK olabilir, elle bakın: {e}")
        return 3

    print(f"taban: {baseline}")
    print(f"mutasyonlu (bayrak+uzay+artefakt TUTARLI sahte): {mutated}")

    caught_by = [name for name, green in mutated.items() if not green]
    if caught_by:
        print(f"\n✅ ÜÇÜNCÜ ÇAPA VAR: {caught_by} kırmızı yandı — üç kaynağı "
              f"birden tutarlı sahtelemek bugün YAKALANIYOR.")
        return 0
    print("\n🔴 ÜÇÜNCÜ ÇAPA YOK: bayrak+uzay+artefakt BİRLİKTE tutarlı "
          "sahtelenince İKİ kapı da (reference_equivalence + metric_coverage) "
          "YEŞİL KALDI. 'L-187 göçünü yaptık ama gerçek ölçümü atladık' "
          "senaryosu bugün hiçbir kapıya bağlı DEĞİL.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
