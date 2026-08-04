# L-171 eşik türetimi — İSİMLİ KAPANIŞ: **eşik TÜRETİLEMEZ**

**Tarih:** 2026-08-04 · **Hüküm:** M-F-224 formülü uygulanamadı · **Kapı:** fail-closed KALIR · **Damga:** "dayanaksız-provisional" KALKMADI

Yeniden üretim: `tools/vmr_baseline.py` + `docs/32b-TAVAN-OLCUMU.md` (tavan) ·
rig `motion_core a4a1ac2` (izole worktree) · frameBasis **anatomical** (M-F-224 şart 5)

## Dayanak beyanı (M-F-253 madde 2 — İSİMLİ yeniden-temellendirme)

Bu tur, netlik eşiğinin dayanağını **değiştirmeyi denedi**:

> **Eski dayanak:** landmark-kalitesi ölçüleri — tespit oranı · görünürlük
> ortalaması · görünürlük p10 · kadraj-içi oran · jitter. L-171 bunların
> netlikle ilişkisini ölçtü: **r ≈ 0,00–0,21, biri ters işaretli** → dayanak
> yok.
>
> **Denenen yeni dayanak:** **geçerli-ölçüm üretimi (VMR)** — "kaç landmark
> bulundu" değil "kaç GEÇERLİ ÖLÇÜM üretti". Gerekçe (L-201): `E3Eu0F73ROI`
> netlik **8,3** ile reddedilmiş, tespit oranı **%97,1** (kabul aralığının üst
> kısmı!) ama alt-vücut metriklerinde VMR **0,002** — landmark tespit ediliyor,
> alt vücut kullanılabilir DEĞİL. Dört eski ölçü bunu göremiyor çünkü yanlış
> soruyu soruyorlar.

**Sonuç: yeni dayanak da TUTMADI.** Netlik VMR'yi de öngörmüyor.

## Ölçüm

Klip-başına VMR medyanı (batarya 10 geometrik testinin primary metrikleri,
kare-düzeyi geçerlilik oranı):

| klip | grup | netlik | VMRmed | min | max | kare |
|---|---|---|---|---|---|---|
| F8q1kEF2JCA | RET | 4,3 | 0,419 | 0,230 | 0,994 | 4.651 |
| E3Eu0F73ROI | RET | 8,3 | 0,454 | 0,002 | 0,999 | 9.659 |
| o0knCTTMZHM | **RET-SINIR** | **38,7** | **0,515** | 0,312 | 1,000 | 20.885 |
| HhApHbLgxMA | KABUL | 41,9 | 0,918 | 0,568 | 0,993 | 27.671 |
| ZFTY2UndWNI | KABUL | 98,1 | **0,447** | 0,002 | 1,000 | 16.759 |
| GaP20t6ZOfU | KABUL | 153,5 | 0,978 | 0,806 | 1,000 | 3.564 |
| lPOdTeASiyY | KABUL | 200,5 | 1,000 | 0,976 | 1,000 | 4.770 |
| SfxyICleU4I | KABUL | 1268,9 | **0,590** | 0,230 | 1,000 | 58.046 |

### Neden türetilemiyor — üç bağımsız sebep

**1. Netlik VMR'yi öngörmüyor (n=8): Pearson r = +0,001.**

| değişken | Pearson r | Spearman ρ | n |
|---|---|---|---|
| **netlik** | **+0,001** | +0,690 | 8 |
| log-netlik | +0,433 | +0,690 | 8 |
| **fullBodyRatio** | **+0,876** | +0,800 | 4 |
| upperBodyRatio | +0,786 | +0,700 | 5 |
| cutsPerMin | −0,488 | −0,500 | 8 |

Spearman'ın +0,690 olması yanıltıcı: sıralama eğilimi netlik-reddi grubunun
TOPLUCA düşük olmasından geliyor (grup etkisi), sürekli bir ilişkiden değil.
Sürekli ilişkinin ölçüsü Pearson ve o **sıfır**.

**2. Kabul grubu, ret grubundan AYIRT EDİLEMİYOR (örtüşme).**
`ZFTY2UndWNI` (netlik 98,1, KABUL) VMR **0,447** — reddedilen `E3Eu0F73ROI`
(netlik 8,3) VMR 0,454'ten **DAHA KÖTÜ**. `SfxyICleU4I` (netlik **1268,9** —
havuzun en neti) VMR 0,590, sınır klibinin (0,515) yalnız 0,075 üstünde.
Yani RET aralığı [0,419–0,515] ile KABUL aralığı [0,447–1,000] **kesişiyor**.

> ⚠️ **[[L-200]]'ün +0,429 medyan ayrışması bununla ÇELİŞMİYOR, farklı şey
> ölçüyor.** Orada her TEST için ret-medyanı ↔ kabul-medyanı kıyaslandı;
> burada her KLİP için tüm testlerin medyanı. Eşik **klip düzeyinde**
> uygulanıyor (bir klip kabul mü ret mi), dolayısıyla eşik türetimi için doğru
> mercek bu. Ve klip merceğinde kabul grubunun İÇ VARYANSI, ret↔kabul
> ayrımından BÜYÜK — medyan iki düşük-VMR kabul klibini maskeliyordu.
> Metodolojik ders (L-200'ün tersi yönde tekrarı): **doğru merceği ölçüm
> değil KARAR birimi belirler.**

**3. VMR'yi süren değişkenin ZATEN AYRI bir kapısı var.**
Öngörücü olan `fullBodyRatio` (r = +0,876) ve triyaj **zaten** kadraj kapısı
uyguluyor (`fullBodyRatio < 0,6` → RED; havuzda 17 klip böyle reddedilmiş).
Yani VMR'deki asıl sinyal netlik eşiğine değil, yanındaki kadraj kapısına ait.

## M-F-224 formülünün uygulanamama gerekçesi

Formül: **eşik = ölçülmüş-taban × ölçülmüş-ayrışma-k**

- **ölçülmüş-taban** ✅ var: 0,436 (netlik <10, n=2) — [[L-200]]
- **ölçülmüş-ayrışma-k** ❌ **YOK**: ayrışma netliğin bir fonksiyonu olarak
  ölçülemiyor (r = +0,001) ve gruplar örtüşüyor. `k` hesaplanabilir bir sayı
  değil; hesaplanırsa (0,918/0,436 = 2,1) **kabul grubunun iç varyansını
  ayrışma sanmak** olur.

**Bu yüzden yeni eşik YAZILMADI.** "Ölçülmemiş eşik yazılmaz" kuralının
doğrudan uygulanışı.

## Hüküm ve kalan durum

| kalem | durum |
|---|---|
| Netlik kapısı (40) | **KALIR, fail-closed** (M-F-224: ölçümsüz gevşetme = M-F-200 "gevşetme reddi") |
| "dayanaksız-provisional" damgası | **KALKMADI** — hiçbir raporda ölçüm-iddiası olarak alıntılanamaz |
| Yeni eşik | **TÜRETİLEMEDİ** — isimli kapanış |
| VMR-temelli yeniden-temellendirme | **DENENDİ, TUTMADI** (r = +0,001) |
| Kapı-tasarımı | **koordinatöre döner** (M-F-224 hükmü) |

### Koordinatöre giden gözlem (karar değil)

VMR'yi öngören değişken kadraj çıktı (`fullBodyRatio` r=+0,876, n=4). Eğer bir
gün netlik eşiği yeniden ele alınırsa, sorulacak soru *"eşik 40 mı 38 mi"*
değil **"netlik kapısı kadraj kapısının üstüne ne KATIYOR"** olabilir.

⚠️ **Bu gözlem bir öneri DEĞİL ve confound taşıyor:** netlik-reddi alan
klipler triyajda kadraj ölçümüne **hiç ulaşmıyor** (erken çıkış → manifest'te
`fullBodyRatio: nan`), o yüzden kadraj↔VMR ilişkisi yalnız n=4 kabul klibinde
ölçülebildi. İki kapıyı ayrıştırmak, triyajın erken-çıkış sırasını değiştirip
her klipte HER ölçüyü kaydetmeyi gerektirir — o ayrı bir iş ve koordinatörün
kararı.

## Örneklem sınırı (gizlenmiyor)

**n = 3 ret + 5 kabul.** Küçük. Pearson r = +0,001 gibi bir sıfır bu boyutta
bile anlamlıdır (bir ilişki VARSA n=8'de en azından işaret verirdi), ama
`fullBodyRatio` için n=4 ve o sayı **hipotez üretir, hüküm vermez**. Bu turun
hükmü *"eşik türetilemez"*dir — *"kadraj doğru değişkendir"* DEĞİL.
