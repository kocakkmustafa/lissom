# A3 — SESSİZ ORAN: tanım (ölçümden ÖNCE yazıldı)

> **Bu dosya ölçümden ÖNCE commit edilir ve ölçüm AYRI bir commit'te gelir.**
> Sebebi tek cümle: *bir tanım, ölçümden sonra yazıldığında ölçümü övecek
> biçimde yazılabilir; bir ÖNCEKİ commit'te duran tanım yazılamaz.*
> ⇒ Goodhart karşıtı kanıt **git tarihinin kendisidir**, benim beyanım değil.
>
> Kontrol: `git log --oneline -- docs/A3-SESSIZ-ORAN-TANIMI.md` ile
> `git log --oneline -- docs/a3-sessiz-oran.json` — ilki İKİNCİDEN eski olmalı.

---

## 0. Neden bu tur var — paydanın bilinen sınırı

A3 bu hatta bugüne dek **yalnız 6 aile hedefi** üzerinden konuşuldu (batarya
aileleri). Uygulamanın **kullanıcının gerçekten gezdiği yüzeyleri** —
`Home` · `Library` · `Progress` · `Profile` · `LiveCapture` ·
`WhatLissomDoesntDo` — paydaya **hiç girmemişti.** Yani A3'ün sayısı vardı ama
*neyin üstünde* olduğu dardı.

> ***Bir oranın paydası yazılmadıysa, oran bir sayı değil bir izlenimdir.***

Aile kuralı (JabLab `J-232`, iki hat bağımsız):
***ölçülecek sayı BOŞ oranı değil SESSİZ oranıdır.*** JabLab'da boş %33,
sessiz %0 — *ikisinin bu kadar ayrışması kuralın gerekçesidir.*

---

## 1. PAYDA — "aday yer" nedir

**Aday yer (site):** sevk edilen kodda (`lib/`), widget ağacının **veri
varlığına göre dallandığı** ve dallardan **en az birinin kullanıcıya görünür
içerik ÜRETMEYEBİLECEĞİ** her nokta.

Sayılan biçimler:

| biçim | örnek |
|---|---|
| `if (x.isEmpty) / if (x.isNotEmpty)` dalı | `library_screen.dart:287` |
| `else`'i olmayan koşullu spread (`...[]`) | `what_lissom_doesnt_do.dart:114` |
| `switch` üzerinde **veri kaynaklı** `_ =>` varsayılanı | `home_screen.dart:145` |
| `?:` üçlüsünün boş üreten yanı | — |
| `null` / `SizedBox.shrink()` / `Container()` dönen dal | — |
| boş listeyi dolaşan `for` (0 tur ⇒ 0 widget) | — |

⛔ **Payda TÜRETİLMEZ, DENETLENİR.** Aday listesi mekanik olarak çıkarılır
(`tools/a3_silent_ratio.py`), ama her aday **elle sınıflandırılır** ve araç
yalnız *bölmenin tam ve AYRIK* olduğunu doğrular.
🪤 Kendi ölçülmüş kazam (`L-302`): *bir bölmenin toplamı paydayı aşıyorsa
kovalar ayrık değildir* — ve bunu **payda denetimini kendi kurduğum turda**
kaçırmıştım. Araç bu yüzden toplamı **assert eder**.

---

## 2. İKİ DURUM — ölçüm hangisinde yapılır

Her aday yerin iki durumu vardır:

- **`dolu`** — veri var, dal içerik üretiyor.
- **`boş`** — veri yok, dal ne üretiyorsa A3 **onu** ölçer.

> ***`dolu` durumu A3 hakkında HİÇBİR ŞEY söylemez.*** Bir ekranın veriyle
> güzel görünmesi, veri yokken ne dediğinin kanıtı değildir. Ölçüm **yalnız
> `boş` durumu** üzerinden yapılır.

---

## 3. ÜÇ KOVA — `boş` durumda dal ne yapıyor

| kova | tanım | A3 açısından |
|---|---|---|
| **ⓐ SUNAN** | Boş dal **iş sunuyor**: kullanıcının basıp bir yere gidebileceği gerçek bir eylem (düğme/rota) çiziyor | ✅ A3'ün birinci kolu |
| **ⓑ SÖYLEYEN** | Boş dal **neden boş olduğunu söylüyor**: kullanıcı diliyle, adıyla, sayı uydurmadan | ✅ A3'ün ikinci kolu |
| **ⓒ SESSİZ** | Boş dal kullanıcıya **hiçbir şey** vermiyor — ne iş ne gerekçe | 🔴 A3'ün saydığı kusur |

**`sessiz oran` = |ⓒ| ÷ (|ⓐ| + |ⓑ| + |ⓒ|)**

### 3.1 ⓒ'nin İKİ biçimi — ve yalnız biri kusur

Bu ayrım **ölçümden önce** yazılıyor, çünkü sayıları gördükten sonra
yazılsaydı sayıyı kurtarmak için yazılmış olurdu.

- **ⓒ¹ BAŞLIKLI BOŞLUK** — *vaat çiziliyor, içerik çizilmiyor.* Bölümün
  başlığı/eyebrow'u/kartı ekranda duruyor, altı boş.
  → 🔴 **KUSUR.** Kullanıcı bir şey vaat edilmiş görüp karşılığını bulamıyor.
  *Örnek biçim:* `home_screen.dart:145` — `LissomEyebrow(s.title)` her
  hâlükârda çiziliyor, gövde `_ => SizedBox.shrink()` olabiliyor.

- **ⓒ² BÜTÜN-BÖLÜM YOKLUĞU** — *vaat de içerik de birlikte yok.* Bölüm hiç
  görünmüyor; kullanıcı karşılıksız bir başlık görmüyor.
  → ⚪ **KUSUR DEĞİL, ama SORUSU VAR:** o bölümün yok olabilmesi meşru mu?
  Bu soru A3'ün değil **A4'ün (çıkmaz sokak)** alanıdır; A3 bunu **adıyla
  sayar ve devreder**, sessizce affetmez.

> ***BİR BAŞLIK, ALTINDAKİ BOŞLUĞU GÖRÜNÜR KILAR; BAŞLIĞIN KENDİSİ DE
> KAYBOLDUĞUNDA GÖRÜNEN BİR KUSUR YOKTUR — VE İKİSİNİ AYNI SAYIYA
> TOPLAMAK, OLMAYAN BİR KUSURU VAR, OLANI YOK GÖSTERİR.***

---

## 4. BEKLENTİ — ölçümden önce yazılı (bu bölüm ölçümden sonra DEĞİŞTİRİLMEZ)

Ölçmeden önceki tahminim, yanılırsam yanıldığım kayıtta kalsın diye:

1. **`sessiz oran` > 0 çıkacak.** Sıfır beklemiyorum; bu paydaya ilk kez
   bakılıyor.
2. **En az bir ⓒ¹ (başlıklı boşluk) bulacağım**, ve en olası adayım
   `home_screen.dart:145`'in `switch` varsayılanı.
3. **`WhatLissomDoesntDo`'nun iki koşullu bölümü ⓒ² çıkacak** (114 ve 144) —
   yani kusur DEĞİL, ama A4'e devredilecek.
4. **`Library` ve `Home`'un veri-boş dalları ⓑ çıkacak** — `NamedGapCard` ve
   *"can read none of the twelve tests"* cümlesi zaten gerekçe taşıyor.
5. Nihai hedef: **ⓒ¹ = 0.** ⓒ² sayısı sıfır olmak zorunda değil; **adıyla
   yazılmak** zorunda.

⚠️ Eğer ölçüm bu beş maddeden herhangi birini çürütürse, **çürüten madde
DEFTER'e adıyla yazılır** — tahminin sessizce güncellenmesi, tahmin
yapmamakla aynı şeydir.

---

## 5. KAPI KURMA KISITI — bu tur ne kurulur, ne kurulmaz

Bu hattın kısıtı: *bir kapı ancak bir **A kalemini** — yani bir
**kullanıcı-yüzeyi iddiasını** — doğruluyorsa kurulur.*

- ✅ **Kurulur:** ⓒ¹ sayısını 0'da tutan kapı. Doğruladığı iddia:
  *"Lissom'da başlığı olup gövdesi olmayan bir bölüm yoktur."* Bu doğrudan
  A3'ün metni.
- ⛔ **Kurulmaz:** *"tanım dosyası güncel mi"* kapısı. O, kapının kapısını
  denetleyen kapı olurdu (`L-314`'te aynı sebeple kurmadım).
- ⛔ **Kurulmaz:** ⓒ² sayısını çapalayan sayı-kapısı. Bir sayı çapası,
  denetlediği şey büyüdükçe sessizce yanlışlaşır (`kural 4.5`, `L-314`).

---

## 6. ÖZ-TEST ZORUNLU

Ölçüm aracı **sabotajla** kanıtlanır: sevk edilen koda kasten bir başlıklı
boşluk enjekte edilir, kapının **ötmesi** ölçülür, sabotajın **indiği** ayrıca
doğrulanır (`grep -q`), geri alma **satır bazında** yapılır.

> ***ÖTME KANIT DEĞİL, ÖTME SEBEBİ KANITTIR*** — ve sabotaj birden çok kapıyı
> birden kırıyorsa izole değildir, kanıt sayılmaz (`L-314`, ölçülmüş).
