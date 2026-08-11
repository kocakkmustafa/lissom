#!/usr/bin/env python3
"""MUT-A: `metric_coverage_test.dart` — İKİ BAĞIMSIZ KAYNAK tutarlı
sürüklenirse hiç sınanmamış (envanter #2, koordinatör sırası — 2026-08-12).

`docs/CELISKI-KAPISI-ENVANTERI-2026-08-11.md`'nin bulgusu: bu kapının dört
öz-testi de TEK kaynağı bozuyor (yalnız `required`e sahte metrik ekle, ya
da yalnız `declared`e bayat kayıt ekle). Hiçbiri "`kMetricBindings` VE
`kUnbridgedMetrics` BİRLİKTE, TUTARLI biçimde yeniden düzenlenirse" senaryosunu
sınamıyor — oysa BÖLME testi (`missing`/`stray`/`both` hepsi boş) tam bunu
göremeyecek YAPIDA: config (`required`) SABİT kalırken Dart tarafının iki
kayıt defteri arasında bir metriğin YER DEĞİŞTİRMESİ, bölme denklemini asla
bozmaz.

## Üç sahne

  A) **bridged → declared regresyon** — ÇALIŞAN bir binding kaldırılır,
     yerine aynı metrik için "engellendi" beyanı eklenir. Bölme testi
     görebilir mi?
  B) **declared → bridged YANLIŞ-EKLEM terfi** — "çekirdekte imkânsız"
     diye beyan edilmiş bir metrik, YANLIŞ bir `coreJointId`yle "köprülü"
     sayılır. "her köprülü metrik gerçekten OKUNABİLİYOR" testi yalnız
     `returnsNormally` diyor — YANLIŞ eklem de normal döner. Yakalanır mı?
  C) **`measureKind` sahte beyan** — `metric_bridge.dart`'ın KENDİ doc
     yorumu (satır 166) *"[measureKind] config ile kapıda
     karşılaştırılıyor"* diyor. Kod tabanında bu karşılaştırmayı yapan
     TEK satır YOK (ölçüldü: `grep -rn measureKind test/` yalnız TANIM
     sitelerini buluyor, hiçbir `expect`i yok). Yakalanır mı — yoksa
     doc bir iddia mı, bir uygulama mı?

## Bir YAKIN-ISKA — ölçüldü, kayda geçti

(B)'nin hedef metriği önce `tibia_inclination_right` denendi ve KIRMIZI
yandı — ama `metric_coverage_test.dart`'IN KENDİSİ DEĞİL,
`real_replay_test.dart:67-75`'in `tibia_inclination_right`'ı SABİT/HARDCODED
örnek olarak kullanan (`kUnbridgedMetrics`den TÜRETİLMEMİŞ) bir başka testi
yakaladı. `reach_depth`e (aynı sınıf, farklı metrik) değiştirilince AYNI
mutasyon 103/103 testte SESSİZCE geçti. **Yani (B)'nin ilk "yakalandı"
sonucu YANLIŞ GÜVEN olurdu** — koruma yapısal değil, tek bir hardcoded
örneğin TESADÜFEN aynı adı seçmiş olmasıydı. `reach_depth` bu yüzden
seçildi: hiçbir testte isimle geçmiyor (ölçüldü), sonucu YAPISAL koruma
sorusuna cevap veriyor.

Hiçbir sahne için "beklenen" ÖNCEDEN yazılmıyor — bu bir DOĞRULAMA değil bir
KEŞİF turu (`mutation_reference_equivalence.py`'nin fix'ten ÖNCEKİ hâliyle
aynı disiplin): bulgu ne çıkarsa çıksın raporlanır, düzeltme kararı
koordinatöre gider.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from mutation_lock import LockHeld, MutationRun, RestoreFailed  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
ENGINE = ROOT / "packages/lissom_engine"
METRIC_BRIDGE = ENGINE / "lib/src/metric_bridge.dart"
TOUCHED = [METRIC_BRIDGE]

#: TAM CÜMLE — yalnız hedef dosyayı değil, `lissom_engine` paketinin TÜM
#: test takımını koşar. Tek dosyaya daraltmak "gerçekte kimse bunu
#: yakalamıyor" iddiasını zayıflatırdı — başka bir test (`bridge_convention_
#: test.dart`, `real_replay_test.dart`) yakalarsa bu da bir BULGU.
GATE = ["flutter", "test"]


def run_gate() -> tuple[bool, str]:
    """(yeşil mi, kısa özet)."""
    out = subprocess.run(GATE, cwd=ENGINE, capture_output=True, text=True)
    green = out.returncode == 0
    tail = (out.stdout or out.stderr).strip().splitlines()
    summary = tail[-1] if tail else "(çıktı yok)"
    return green, summary


def _apply(old: str, new: str) -> None:
    src = METRIC_BRIDGE.read_text()
    assert old in src, f"MUTASYON UYGULANAMADI — kaynak bulunamadı:\n{old}"
    mutated = src.replace(old, new, 1)
    assert mutated != src, "mutasyon içerik DEĞİŞTİRMEDİ"
    METRIC_BRIDGE.write_text(mutated)


def scenario_a_bridged_to_declared_regression() -> None:
    """ÇALIŞAN `knee_flexion_right` köprüsü KALDIRILIR, aynı metrik
    `kUnbridgedMetrics`e "engellendi" diye eklenir — config değişmez."""
    _apply(
        "  MetricBinding(\n"
        "      lissomMetric: 'knee_flexion_right',\n"
        "      coreJointId: 'right_knee',\n"
        "      invert: false,\n"
        "      configFrameRef: 'none'),\n",
        "",
    )
    _apply(
        "const Map<String, UnbridgedMetric> kUnbridgedMetrics =\n"
        "    <String, UnbridgedMetric>{\n",
        "const Map<String, UnbridgedMetric> kUnbridgedMetrics =\n"
        "    <String, UnbridgedMetric>{\n"
        "  'knee_flexion_right': UnbridgedMetric(\n"
        "      blocker: BridgeBlocker.coreLacksMeasureKind,\n"
        "      subject: 'Knee angle',\n"
        "      measureKind: 'angle3'),\n",
    )


def scenario_b_declared_to_bridged_wrong_joint() -> None:
    """"Çekirdekte imkânsız" diye beyan edilmiş `reach_depth`, YANLIŞ bir
    `coreJointId`yle (`right_elbow` — mesafe DEĞİL, dirsek açısı) "köprülü"
    sayılır. `configFrameRef` config'le KASTEN tutarlı (`none`) — o
    çapraz-kontrolü YANLIŞLIKLA tetiklememek için. (`tibia_inclination_
    right` DEĞİL — bkz. modül başlığı "YAKIN-ISKA": o isim bir başka testte
    hardcoded, yapısal olmayan bir yakalama üretiyordu.)"""
    _apply(
        "  'reach_depth': UnbridgedMetric(\n"
        "      blocker: BridgeBlocker.coreLacksMeasureKind,\n"
        "      subject: 'Reach depth',\n"
        "      measureKind: 'distance_norm'),\n",
        "",
    )
    _apply(
        "  MetricBinding(\n"
        "      lissomMetric: 'elbow_extension_left',\n"
        "      coreJointId: 'left_elbow',\n"
        "      invert: false,\n"
        "      configFrameRef: 'none'),\n"
        "];",
        "  MetricBinding(\n"
        "      lissomMetric: 'elbow_extension_left',\n"
        "      coreJointId: 'left_elbow',\n"
        "      invert: false,\n"
        "      configFrameRef: 'none'),\n"
        "  MetricBinding(\n"
        "      lissomMetric: 'reach_depth',\n"
        "      coreJointId: 'right_elbow',\n"
        "      invert: false,\n"
        "      configFrameRef: 'none'),\n"
        "];",
    )


def scenario_c_measure_kind_lie() -> None:
    """`trunk_lean`in `measureKind` beyanı config'in GERÇEK `kind`inden
    (`angle_vertical`) SAPTIRILIR (`distance_norm`e) — hiçbir binding/bölme
    değişmez, YALNIZ bu tek alan yalan söyler."""
    _apply(
        "  'trunk_lean': UnbridgedMetric(\n"
        "      blocker: BridgeBlocker.corePlaneSeparationMissing,\n"
        "      subject: 'Forward trunk lean',\n"
        "      measureKind: 'angle_vertical'),\n",
        "  'trunk_lean': UnbridgedMetric(\n"
        "      blocker: BridgeBlocker.corePlaneSeparationMissing,\n"
        "      subject: 'Forward trunk lean',\n"
        "      measureKind: 'distance_norm'),\n",
    )


SCENARIOS = [
    ("A_bridged_to_declared_regresyon", scenario_a_bridged_to_declared_regression,
     "ÇALIŞAN köprü kaldırılıp aynı metrik 'engellendi' diye beyan edilirse"),
    ("B_declared_to_bridged_yanlis_eklem", scenario_b_declared_to_bridged_wrong_joint,
     "'imkânsız' denen metrik YANLIŞ eklemle 'köprülü' sayılırsa"),
    ("C_measureKind_yalan", scenario_c_measure_kind_lie,
     "measureKind beyanı config'in GERÇEK kind'inden saptırılırsa"),
]


def main() -> int:
    try:
        with MutationRun(TOUCHED) as run:
            baseline_green, baseline_summary = run_gate()
            if not baseline_green:
                print(f"⛔ TABAN KIRMIZI ({baseline_summary}) — mutasyon "
                      f"ölçümü anlamsız")
                return 1
            print(f"taban: yeşil ({baseline_summary})\n")

            findings: list[tuple[str, str, bool, str]] = []
            for name, fn, question in SCENARIOS:
                print(f"--- sahne {name} ---\n    soru: {question}")
                fn()
                green, summary = run_gate()
                findings.append((name, question, green, summary))
                print(f"    sonuç: {'🔴 YAKALANMADI (yeşil kaldı)' if green else '✅ YAKALANDI (kırmızı)'}"
                      f" — {summary}\n")
                run.restore_for_next()
    except LockHeld as e:
        print(f"⛔ {e}")
        return 1
    except RestoreFailed as e:
        print(f"⛔ GERİ-YÜKLEME BAŞARISIZ — repo BOZUK olabilir, elle bakın: {e}")
        return 3

    print("=== BULGU ÖZETİ ===")
    undefended = [n for n, _q, green, _s in findings if green]
    for name, question, green, _summary in findings:
        mark = "🔴 YAKALANMADI" if green else "✅ YAKALANDI"
        print(f"{mark}  {name} — {question}")

    if undefended:
        print(f"\n🔴 {len(undefended)}/{len(findings)} sahne YAKALANMADI: "
              f"{undefended} — bu bir DÜZELTME kararı değil, bir ÖLÇÜM. "
              f"Koordinatöre raporlanacak, kod burada DEĞİŞTİRİLMEDİ.")
        return 1
    print("\n✅ ÜÇ SAHNE DE YAKALANDI — envanterin şüphesi bu turda "
          "doğrulanmadı, kapı zaten korumalıydı.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
