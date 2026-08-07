#!/usr/bin/env python3
"""`two_mode_report.audit_exemptions` öz-testi — muafiyet denetiminin KENDİ kapısı.

**Neden ayrı bir öz-test (L-232):** `two_mode_report.py` fixture kütüphanesi
(`~/motion-harvest/lissom/*.full.json`) ve taze bir rig olmadan HİÇ koşamıyor;
ikisi de her makinede yok. Yani bu makinede aracın *"muafiyetler tutarlı"*
demesi bir ÖLÇÜM değil, bir SESSİZLİKTİ.

Kapının kendisini sınamayan bir kapı, koruma sanılan bir boşluktur — bu
deponun kendi dersi (`lint_selftest` ve `phase_check_selftest` aynı sebeple
var). Bu dosya hükmü fixture'sız koşturur: kırmızı yanabildiğini GÖSTERİR.

Sınanan iki soru BİRBİRİNDEN FARKLI:
  - `stale_exemptions` → *"gerekçe eskidi mi?"*  (zaten vardı)
  - burada             → *"gerekçenin işaret ettiği şey hiç var mıydı?"*

İkincisi JabLab'ın `engineDriven` bulgusunun sınıfı: liste *"motor üretir"*
diyor, üreten kod yolu yok, test yeşil kaldıkça kimse bakmıyor.

Çalıştırma: `python3 tools/two_mode_selftest.py`
"""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from two_mode_report import EXPECTED_INVARIANT, audit_exemptions  # noqa: E402

CASES: list[tuple[str, dict, int, str]] = [
    (
        "temiz: her muafiyet ziyaret edildi ve ölçüldü",
        dict(seen={"a", "b"}, unverified=[], declared={"a": "x", "b": "y"}),
        0,
        "",
    ),
    (
        "YETİM: sözlükte var, metrik tanımlarında YOK",
        dict(seen={"a"}, unverified=[], declared={"a": "x", "silinmis": "y"}),
        1,
        "silinmis",
    ),
    (
        "DOĞRULANAMADI: metrik hiç geçerli ölçüm üretmedi",
        dict(seen={"a"}, unverified=["a@fx.json (geçerli: anat=0 cam=0)"],
             declared={"a": "x"}),
        1,
        "a@fx.json",
    ),
    (
        "İKİSİ BİRDEN: yetim + doğrulanamayan",
        dict(seen={"a"}, unverified=["a@fx.json (geçerli: anat=0 cam=3)"],
             declared={"a": "x", "hayalet": "y"}),
        1,
        "hayalet",
    ),
    (
        "boş sözlük: iddia yoksa ihlal de yok",
        dict(seen=set(), unverified=[], declared={}),
        0,
        "",
    ),
]


def main() -> int:
    print(f"two_mode muafiyet öz-testi — {len(CASES)} vaka")
    failures: list[str] = []

    for name, kw, want_verdict, want_text in CASES:
        lines, verdict = audit_exemptions(**kw)
        blob = "\n".join(lines)
        if verdict != want_verdict:
            failures.append(f"{name}: hüküm {verdict}, beklenen {want_verdict}")
        elif want_text and want_text not in blob:
            failures.append(f"{name}: «{want_text}» raporda geçmiyor")
        else:
            print(f"  ✅ {name}")

    # POZİTİF ÇAPA: gerçek `EXPECTED_INVARIANT` boş olsaydı yukarıdaki
    # vakalar geçer ve araç yine "muafiyet yok" derdi — hiçbir şey
    # kanıtlamadan. Bu depoda muafiyet GERÇEKTEN var; kapının denetlediği
    # şeyin var olduğunu ayrıca ölçüyoruz (L-183 vacuous-geçiş sınıfı).
    if not EXPECTED_INVARIANT:
        failures.append(
            "EXPECTED_INVARIANT BOŞ — öz-test hiçbir gerçek muafiyeti "
            "kapsamıyor, bu bir geçiş değil")
    else:
        print(f"  ✅ pozitif çapa: {len(EXPECTED_INVARIANT)} gerçek muafiyet "
              f"kayıtlı ({', '.join(sorted(EXPECTED_INVARIANT))})")

    if failures:
        print(f"\n❌ {len(failures)} öz-test kusuru:")
        for f in failures:
            print(f"    {f}")
        return 1
    print("\n✅ Muafiyet denetimi kırmızı yanabiliyor ve meşru hâli geçiriyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
