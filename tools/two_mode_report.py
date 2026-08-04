#!/usr/bin/env python3
"""İki-mod (anatomical ↔ camera) ölçüm raporu + bayrak-canlılık kapısı.

M-F-230 (koordinatör, 2026-08-04) her `MOCORE_ANATOMICAL=1` turu için POZİTİF
KONTROL zorunlu kılıyor: *"modun değiştirdiği bilinen ≥1 GERÇEK-veri metrik
değerini raporda göster. Çıktılar bit-aynıysa bu 'fark yok' DEĞİL 'bayrak
bağlanmamış' demektir."*

Bu araç o kuralı **iki yönlü** uygular, çünkü tek yönü yanlış alarm verir:

  POZİTİF KONTROL   bayrağın DOKUNDUĞU metrikler (`frameRef` ∈ gravityYaw ·
                    proximal · none) gerçekten DEĞİŞİYOR mu?
                    Hepsi bit-aynıysa → bayrak bağlanmamış, koşum GEÇERSİZ.

  NEGATİF KONTROL   bayrağın DOKUNMADIĞI metrikler (`frameRef` = camera)
                    gerçekten SABİT mi?
                    `measures.evaluate` bayrağı yalnız ilk gruba uyguluyor
                    (`measures.py`: `if anatomical and metric.frame_ref in
                    (...)`), yani camera metriklerinde bit-aynılık DOĞRU
                    davranıştır — "fark yok" diye kırmızı yakmak yanlış olur.
                    Değişiyorlarsa bayrak fazla yere bağlanmış, o da kusur.

Yalnız pozitif kontrol "bayrak bağlı" der; ikisi birlikte **"bayrak DOĞRU
yere bağlı"** der.

⚠️ Bayrağın YAPISAL OLARAK dokunmadığı ölçüm katmanları da var ve orada
bit-aynılık beklenir, kusur değil: `tools/landmark_quality.py` (L-171 netlik
eşiğinin girdisi — tespit oranı · görünürlük · jitter · kadraj-içi) `measures`
modülünü hiç import etmiyor, yani `mz.evaluate`'ten geçmiyor. Bir turda o
sayıların iki modda aynı çıkması bayrak sorunu DEĞİLDİR.

Kullanım:
  python3 tools/two_mode_report.py <fixture.full.json> [...]
  python3 tools/two_mode_report.py --all          # kütüphanenin tamamı
"""
from __future__ import annotations


import json
import math
import os
import sys
from pathlib import Path

import numpy as np

REPO = Path(__file__).resolve().parent.parent
HARVEST = Path.home() / "motion-harvest/lissom/landmarks"

#: Rig (kanonik yorumlayıcı) yolu — `MOCORE_RIG` ile DEĞİŞTİRİLEBİLİR.
#:
#: Neden parametrik: varsayılan yol PAYLAŞIMLI ağaç ve o ağacın dalını
#: değiştirmek YASAK (M-F-22) — yani taze bir çekirdek düzeltmesini oradan
#: okumak imkânsız. Rig işi izole worktree'de yapılır (M-F-139/154), ve araç
#: onu okuyabilmeli. Env yoksa paylaşımlı ağaç kullanılır ve HANGİSİ
#: okunduğu rapora BASILIR — hangi rig'e karşı ölçtüğünü bilmeden "temiz"
#: demek, bayat pinle temiz demektir.
_DEFAULT_RIG = (REPO / "../../motion-core/lib/tools/fixture_pipeline").resolve()
MOCORE = Path(os.environ.get("MOCORE_RIG", str(_DEFAULT_RIG))).resolve()

if not MOCORE.exists():  # pragma: no cover
    sys.exit(f"kanonik yorumlayıcı bulunamadı: {MOCORE}\n"
             f"(MOCORE_RIG ile izole worktree'yi gösterebilirsin)")
sys.path.insert(0, str(MOCORE))

from mocore import geometry as geo  # noqa: E402
from mocore import measures as mz  # noqa: E402

#: `measures.evaluate` bayrağı YALNIZ bu çerçevelerde kullanıyor.
FLAG_TOUCHES = ("gravityYaw", "proximal", "none")

#: Bit-aynılığı DOĞRU davranış olan çerçeve.
FLAG_IGNORES = ("camera",)

#: Bayrağın YAPISAL OLARAK değiştiremediği metrikler + GEREKÇE.
#:
#: Bu liste kapının ikinci yönüdür ve iki işi birlikte yapar:
#:   • listede OLMAYAN bir "dokunulan" metrik bit-aynı çıkarsa → bayrak
#:     bağlanmamış, tur GEÇERSİZ (M-F-230).
#:   • listede OLAN bir metrik DEĞİŞİRSE → gerekçe çürümüş, liste bayat;
#:     kapı yine kırmızı yanar. Yani muafiyet sessiz bir istisna değil,
#:     kendi kendini sınayan bir İDDİA.
#:
#: Bu yüzden bir düzeltmenin TAMAMLANDIĞINI da bu liste kanıtlar: çekirdek
#: düzeltmesi indiğinde (a4a1ac2) `height_diff_norm` satırlarının GEREKÇESİ
#: değişti — "axes kullanmıyor" yerine "gravityYaw'da SI = dünya-y, tüketim
#: BİT-AYNI". Gerekçenin güncellenmesi zorunlu; muafiyet aynı kalsa da
#: SEBEBİ artık başka.
#:
#: Muafiyet SINIFLARI (koordinatör zeyli, M-F-233 revizesi) — "bit-aynı"
#: tek bir şey demiyor, ÜÇ ayrı şey diyor ve üçü ayrı ayrı isimlendirilmeli:
#:   camera-negatif : `frameRef: camera` → bayrak dokunmaz, bit-aynılık DOĞRU
#:   yaw-değişmez   : ölçü yaw'dan yapısal olarak bağımsız (gravityYaw'da
#:                    SI = dünya-y olduğu için height_diff ham-y ile BİT-AYNI)
#:   frame-değişmez : ölçünün kendisi çerçeveden bağımsız (düzlemsiz mesafe)
#: Eskiden hepsi "bit-aynı (beklenmiyor)" diye tek torbaya giriyordu ve
#: "bağlanmamış bayrak" ile karışıyordu.
CLASS_CAMERA_NEG = "camera-negatif"
CLASS_YAW_INVARIANT = "yaw-değişmez"
CLASS_FRAME_INVARIANT = "frame-değişmez"

EXPECTED_INVARIANT: dict[str, str] = {
    # L-190 hükmü madde 1 (ÇÖZÜLDÜ, beyan düşürüldü): 3B Euclidean mesafe
    # rotasyon-değişmezi ve `plane: none` olduğu için izdüşüm de yok.
    # `frameRef` artık `none` — bayrak `plane`i `none`a zorluyor, o da zaten
    # `none`; yani bit-değişmezlik DOĞRU davranış.
    "reach_depth": f"[{CLASS_FRAME_INVARIANT}] düzlemsiz distance_norm "
                   f"rotasyon-değişmezi; beyan `none`a düşürüldü ve taze "
                   f"rig'in guard'ı eski `gravityYaw` hâlini REDDEDİYOR "
                   f"(L-190/1 · L-192)",
    # L-190/2 ÇÖZÜLDÜ (çekirdek a4a1ac2): height_diff_norm artık beyan edilen
    # çerçevenin SI'ını tüketiyor. gravityYaw'da SI = dünya-y ([0,-1,0])
    # olduğu için sonuç ham-y yoluyla BİT-AYNI — ölçüldü, iki rig birebir
    # eşleşti. Yani bunlar artık "bağlanmamış bayrak" DEĞİL, kalıcı
    # `yaw-değişmez` sınıfı. Davranış farkı yalnız `proximal` beyanında
    # doğardı ve Lissom'un iki height metriği de gravityYaw.
    "heel_rise_right": f"[{CLASS_YAW_INVARIANT}] height_diff_norm, gravityYaw "
                       f"SI = dünya-y → çerçeve tüketimi BİT-AYNI (L-190/2 "
                       f"çözüldü, a4a1ac2)",
    "knee_height_right": f"[{CLASS_YAW_INVARIANT}] height_diff_norm, "
                         f"gravityYaw SI = dünya-y → BİT-AYNI (L-190/2 "
                         f"çözüldü, a4a1ac2)",
}


def load_defs() -> list[mz.MetricDef]:
    raw = json.loads((REPO / "config/metrics/lissom-metrics.v1.json").read_text())
    out: list[mz.MetricDef] = []
    for m in raw["metrics"]:
        out.append(mz.MetricDef.from_dict(m))
    return out


def frames_of(path: Path) -> list[geo.Frame]:
    data = json.loads(path.read_text())
    out: list[geo.Frame] = []
    for k in data["frames"]:
        if not k.get("detected"):
            continue
        world = k.get("world")
        if not world:
            continue
        lm = k["lm"]
        out.append(
            geo.Frame(
                xyz=np.asarray(world, dtype=float),
                visibility=np.asarray([p[3] for p in lm], dtype=float),
                presence=np.asarray(
                    [p[4] if len(p) > 4 else p[3] for p in lm], dtype=float),
                t_ms=float(k["t"]),
            )
        )
    return out


def measure(md: mz.MetricDef, frames: list[geo.Frame], anatomical: bool) -> dict:
    """Bir metriği bir modda ölç — değer serisi VE geçerlilik oranı.

    Geçerlilik oranı ayrı tutuluyor çünkü VMR'nin tanımı bu (`geçerli_deneme /
    toplam_deneme`) ve `evaluate` geçerliliği `value_range` süzgeciyle de
    belirliyor — yani mod değişimi değeri değiştirmese bile GEÇERLİLİĞİ
    değiştirebilir. İkisini bir sayıya karıştırmak o etkiyi görünmez yapardı.
    """
    # ⚠️ ÖZET İSTATİSTİKLER YALNIZ `valid` ÖLÇÜMLERDEN — ve bu bir üslup
    # tercihi değil, ölçülmüş bir kusurun panzehiri.
    #
    # İlk sürüm `float(r.value)`'yu KOŞULSUZ toplayıp medyanı `isfinite`
    # süzgeciyle alıyordu. Rig `mask_invalid=True` varsayılanını getirmeden
    # ÖNCE (05aacaf) geçersiz ölçümler `value` alanında HAM/ÇÖP sayı
    # taşıyordu — yalnız `valid=False` yan-kanal bayrağıyla işaretli. Yani
    # `isfinite` onları geçiriyordu ve medyanım geçersiz ölçümlerle
    # KİRLENİYORDU. Taze rig (a4a1ac2) onları NaN'a maskeleyince aynı
    # fixture'da medyanlar sıçradı (`heel_rise` 0,01→0,11 · `reach_depth`
    # 1,47→2,23 · `plank_hip_deviation` 0,21→0,05) ve bunu bir an için
    # "çekirdek düzeltmesi bit-aynılık iddiasını ihlal etti" sandım.
    # Etmemişti: kusur bendeydi. `valid` bayrağına göre filtrelemek her iki
    # rig'de DOĞRU sonuç verir — bu yüzden `isfinite` değil `valid` otorite.
    #
    # Ders (L-155/M-F-114'ün tüketici tarafı): yan-kanal geçerlilik bayrağı
    # taşıyan bir API'de "sayıyı al, sonra NaN'ları at" YETMEZ — bayrağı
    # okumayan kod çöpü gerçek ölçüm sanar.
    values_all: list[float] = []   # kare-hizalı seri (bit-aynılık kıyası için)
    values_valid: list[float] = []  # yalnız geçerli (istatistik için)
    for fr in frames:
        r = mz.evaluate(md, fr, anatomical=anatomical)
        values_all.append(float(r.value))
        if r.valid:
            values_valid.append(float(r.value))
    a = np.asarray(values_all, dtype=float)
    v = np.asarray(values_valid, dtype=float)
    v = v[np.isfinite(v)]
    return dict(
        n=len(values_all),
        valid=len(values_valid),
        vmr=len(values_valid) / len(values_all) if values_all else float("nan"),
        med=float(np.median(v)) if v.size else float("nan"),
        p95=float(np.percentile(v, 95)) if v.size else float("nan"),
        values=a,
    )


def main(argv: list[str]) -> int:
    # ⚠️ argparse KULLANILMIYOR (yalnız -h/--help için): hasat kimlikleri
    # YouTube video id'si ve bunlar `-` ile BAŞLAYABİLİYOR (kütüphanede
    # `-wwRNGArTI0` var, 34 kaynağın 1'i). `nargs="*"` böyle bir adı flag
    # sanıp "unrecognized arguments" veriyordu — yani aracın kütüphanenin
    # gerçek bir alt kümesinde HİÇ çalışmadığı, ama `--all` yolunda (glob)
    # sorunsuz göründüğü bir kör nokta. Elle ayrıştırmak bunu kökten
    # kaldırıyor: `--all` ve `-h` dışındaki her şey dosya adıdır.
    rest = argv[1:]
    if "-h" in rest or "--help" in rest:
        print(__doc__)
        return 0
    want_all = "--all" in rest
    names = [a for a in rest if a != "--all"]
    unknown = [a for a in names
               if a.startswith("--") or (a.startswith("-")
                                         and not a.endswith(".json"))]
    if unknown:
        print(f"bilinmeyen seçenek: {unknown} "
              f"(dosya adı vermek istiyorsan .json uzantısıyla ver)",
              file=sys.stderr)
        return 64

    paths = [HARVEST / p if "/" not in p else Path(p) for p in names]
    if want_all:
        paths = sorted(HARVEST.glob("*.full.json"))
    if not paths:
        print("fixture verilmedi (ya da --all)", file=sys.stderr)
        return 64

    print(f"rig (kanonik yorumlayıcı): {MOCORE}")
    print(f"  {'MOCORE_RIG env ile verildi' if os.environ.get('MOCORE_RIG') else 'VARSAYILAN (paylaşımlı ağaç) — taze düzeltme okunmuyor olabilir'}")

    defs = load_defs()
    touched_changed = 0
    touched_total = 0
    ignored_changed: list[str] = []
    stale_exemptions: list[str] = []
    rows: list[tuple] = []

    for path in paths:
        if not path.exists():
            print(f"ATLANDI (yok): {path.name}")
            continue
        frames = frames_of(path)
        if not frames:
            print(f"ATLANDI (tespit edilmiş kare yok): {path.name}")
            continue
        print(f"\n=== {path.name}  ({len(frames)} kare) ===")
        print(f"  {'metrik':32s} {'frameRef':10s} "
              f"{'med(anat)':>10s} {'med(cam)':>10s} {'Δmed':>9s} "
              f"{'VMR(anat)':>9s} {'VMR(cam)':>9s}")
        for md in defs:
            anat = measure(md, frames, anatomical=True)
            cam = measure(md, frames, anatomical=False)
            # "Bit-aynı" = değer serisi TAMAMEN aynı (NaN konumları dahil).
            same = np.array_equal(anat["values"], cam["values"], equal_nan=True)
            dmed = anat["med"] - cam["med"]
            flag = ""
            exempt = EXPECTED_INVARIANT.get(md.id)
            if exempt is not None:
                # Muafiyet bir İDDİADIR ve sınanır: değişirse gerekçe çürük.
                if same:
                    flag = f"  ← bit-aynı ({exempt.split(']')[0].lstrip('[')})"
                else:
                    stale_exemptions.append(f"{md.id}@{path.name}")
                    flag = "  ← DEĞİŞTİ ama MUAF sayılmış (gerekçe çürük)"
            elif md.frame_ref in FLAG_TOUCHES:
                touched_total += 1
                if not same:
                    touched_changed += 1
                else:
                    flag = "  ← bit-aynı (beklenmiyor)"
            elif md.frame_ref in FLAG_IGNORES:
                if not same:
                    ignored_changed.append(f"{md.id}@{path.name}")
                    flag = "  ← DEĞİŞTİ (beklenmiyor)"
                else:
                    flag = f"  ← bit-aynı ({CLASS_CAMERA_NEG})"
            print(f"  {md.id:32s} {md.frame_ref:10s} "
                  f"{anat['med']:10.2f} {cam['med']:10.2f} {dmed:+9.2f} "
                  f"{anat['vmr']:9.3f} {cam['vmr']:9.3f}{flag}")
            rows.append((path.name, md.id, md.frame_ref, same,
                         anat["med"], cam["med"], anat["vmr"], cam["vmr"]))

    # ---- kapı hükmü ------------------------------------------------------
    print("\n\n=== BAYRAK-CANLILIK HÜKMÜ (M-F-230) ===")
    print(f"bayrağın DOKUNDUĞU metrik-fixture çifti : {touched_total}")
    print(f"  bunlardan gerçekten DEĞİŞEN           : {touched_changed}")
    print(f"bayrağın DOKUNMADIĞI (camera) sapan     : {len(ignored_changed)}")

    verdict = 0
    if touched_total == 0:
        print("\n❌ GEÇERSİZ: bayrağın dokunduğu hiç metrik ölçülmedi — "
              "pozitif kontrol KURULAMADI.")
        verdict = 1
    elif touched_changed == 0:
        print("\n❌ GEÇERSİZ: bayrağın dokunması GEREKEN metriklerin hiçbiri "
              "değişmedi → 'fark yok' değil, BAYRAK BAĞLANMAMIŞ (M-F-230). "
              "Tur geçersiz, koordinatöre dön.")
        verdict = 1
    else:
        print(f"\n✅ POZİTİF KONTROL GEÇTİ: {touched_changed}/{touched_total} "
              f"çiftte mod gerçek-veride ölçülebilir fark üretti.")
    if stale_exemptions:
        print(f"\n⚠️ BAYAT MUAFİYET: `EXPECTED_INVARIANT` bu metrikleri "
              f"değişmez sayıyor ama DEĞİŞTİLER — gerekçe çürümüş, listeyi "
              f"güncelle ({len(stale_exemptions)} çift):")
        for x in stale_exemptions[:10]:
            print(f"    {x}")
        verdict = 1
    else:
        print(f"✅ MUAFİYETLER TUTARLI: {len(EXPECTED_INVARIANT)} kayıtlı "
              f"muafiyetin hiçbiri çürümemiş.")
    if ignored_changed:
        print(f"\n⚠️ NEGATİF KONTROL KIRMIZI: `camera` çerçeveli metrikler "
              f"bayraktan etkilenmemeli ama {len(ignored_changed)} çift "
              f"değişti — bayrak FAZLA yere bağlı:")
        for x in ignored_changed[:10]:
            print(f"    {x}")
        verdict = 1
    else:
        print("✅ NEGATİF KONTROL GEÇTİ: `camera` çerçeveli metrikler "
              "bit-aynı kaldı (bayrak doğru yere bağlı).")

    print("\nHATIRLATMA: `tools/landmark_quality.py` (L-171 netlik eşiğinin "
          "girdisi) `measures`'ı hiç import etmiyor — o katmanda iki modun "
          "aynı çıkması YAPISAL, bayrak kusuru DEĞİL.")
    return verdict


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
