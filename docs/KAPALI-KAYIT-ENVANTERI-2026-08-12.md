# KAPALI-KAYIT ENVANTERİ — Lissom (2026-08-12)

> ⛔ **BU BİR ENVANTERDİR — hüküm YOK, yeniden açma YOK.**
> Soru: ***bugün AÇIK sandığımız kaç yolun, deponun kendi kaydında
> ölçülüp KAPATILMIŞ bir cevabı var?*** (M-F-581, Choreia vakası)

## ① "KAPALI" ÖLÇÜTÜ — ölçümden ÖNCE yazıldı

Defterim **iki biçimli** (L-294'te ölçüldü) ve ***kapalılığın kanıtı
biçime göre değişiyor*** — ölçüt bu yüzden üç kaynağa ayrıldı:

| kaynak | ne | nerede |
|---|---|---|
| **(a) YAPISAL** | `Durum` sütunu kapalı **ve** `Kapanış kanıtı` dolu | yalnız **tablo** biçimi (6 sütun) |
| **(b) DIŞ** | kanıt bir dış artefakta işaret ediyor (`docs/` · `.json` · `.md`) | tablo |
| **(c) YALNIZ ANLATI** | durum sütunu **yok**; kapalılık yalnız metinde | **prose** başlıkları |

⛔ Üçü **aynı şey değildir**: (a) makine-okunur, (b) izlenebilir,
**(c) yalnız okuyanın hatırlamasına bağlı.**

## ② PAYDA

| ölçüm | değer |
|---|---|
| toplam kayıt | **305** (tablo 256 · prose 49) |
| `Durum` KAPALI diyen | **178** |
| └─ **kanıt sütunu BOŞ** | **13** ⚠️ kapalı DENİYOR, kanıtı yok |
| `Durum` AÇIK diyen | **62** |
| **(c) yalnız anlatı** (prose, durum sütunu YOK) | **49** (%16) |

## ③ ASIL SINIF: ÖLÇÜLÜP REDDEDİLMİŞ YOLLAR

*Düzeltilmiş bir kusur* ile *ölçülüp reddedilmiş bir yol* **aynı şey
değildir**: birincisi tekrar edilmez, ikincisine ***yeniden girilebilir.***

| küme | sayı |
|---|---|
| kapalı kayıt | 178 |
| ├─ **ölçülüp REDDEDİLMİŞ** (yeniden girilebilir) | **20** |
| │   ├─ bağlı **KAPISI var** | **5** |
| │   ├─ dış artefakta bağlı | 4 |
| │   └─ **kapısı YOK** | **15** ⚠️ |
| └─ yalnız düzeltilmiş | 158 |

> ⚠️ ***Kapısı olmayan 15 kayıt, yalnız okuyanın hatırlamasına bağlı*** —
> ne bir kapı korur, ne bir alan işaretler. Choreia'nın vakası tam bu
> sınıftı.

## ④ KAPISIZ REDDEDİLMİŞ YOLLAR — listelendi (hüküm YOK)

| kayıt | ölçülüp reddedilen |
|---|---|
| `L-239` | TESTLERİM SAYIYI ÇİVİLİYORDU, KURALI DEĞİL (JabLab aktarımı: "fazla geniş bir test, ürün DOĞRU genişlerken kırmızıya döner"). Ölçtüm: k |
| `L-023` | Varyant-başına güven eşiği uygulanmadı (aile kuralı M-018/M-020: visibility varyantlar arası kıyaslanamaz). Lissom assessment'ta heavy, |
| `L-043` | Hasat kuyruğu üretildi + pilot koşuldu. Envanterden (7 kol, oEmbed doğrulamalı) 100 benzersiz video / 31 hareket türetildi → docs/harve |
| `L-062` | Eklediğim eşik CLI'dan ERİŞİLEMİYORDU — harvest.py TriageThresholds()'i hep varsayılanla çağırıyordu, yani min_full_body_ratio hiçbir k |
| `L-080` | Triyaj sondası kadraj şartını SABİT tutuyordu; ölçüm ayak bileğine hiç bakmayan testlerin adaylarını eledi. overhead_reach (bir OMUZ te |
| `L-086` | L-085 kapandı: eşik gevşetilmedi, ÖLÇÜLEN ŞEY değiştirildi. Görünürlük oranı videonun tamamından hesaplanıyordu; oysa fixture bir temiz |
| `L-090` | Üst-gövde oranı da aynı kusuru taşıyordu — ölçüldü, kapatıldı. Üst-gövde gerekçesiyle reddedilen 2 klipte kesintisiz pencere: 74 sn ve  |
| `L-115` | L-112'deki "önden çekim" açıklamam ÖLÇÜMLE ÇÜRÜDÜ. Reddedilen iki hip_hinge kaynağının önden çekildiğini varsaymıştım. shoulder_line_fo |
| `L-143` | Kanonik CLI ÇÖKÜYOR ve çöküşü "kapı reddi" gibi raporluyor. overhead_reach 6 kaynakla: "REDDEDİLDİ (sayı/kaynak kapısı): Invalid value" |
| `L-147` | 0.7.3 ile overhead_reach kanonik CLI koşumu — L-143 doğrulandı düzeldi, YENİ bulgu: gizli 6. dışlama. 6 kaynaktan yalnız 5'i takese gir |
| `L-168` | İLK LİSSOM REFERANSI: DÜRÜST NEGATİF — rapor mühürlendi (docs/ILK-REFERANS-DURUST-NEGATIF.md). Beş tur ölçümle denendi ve beşi de RET:  |
| `L-170` | HASAT SIRASI GELDİ, PAKETİN İKİ ÖNCÜLÜ DE ÇÜRÜDÜ — ve ikisi de benim yaratmadığım engeller. (a) "5 bekleyen kaynak çıkarım ister" YANLI |
| `L-171` | NETLİK EŞİĞİ (40) ÖLÇÜMLE DAYANAKSIZ ÇIKTI — eşik sorusu ölçüm sorusuna çevrildi (M-F-173 hükmü). Sınır klip (lr3_bA48EBM, netlik 37,8) |
| `L-172` | HEDEFLİ ARAMA TURU — ön-eleme HASATTAN ÖNCE koştu (tools/targeted_search.py, Choreia probe deseni). Üç ölçüt: triyaj-uyumluluk (süre ≥9 |
| `L-199` | KARANTİNA ÇEKİMİ GEREKSİZDİ — reddedilen kliplerin videoları ZATEN YEREL DİSKTE. L-180 "şu an ölçülemez: triyaj reddettiğini indirmiyor |

## ⑤ Ölçümün sınırları — adıyla

- ⛔ **`.lower()` KULLANILMADI** — Türkçe iki `i`de kırık
  (`'I'.lower()='i'≠'ı'` · `'İ'.lower()='i̇'≠'i'`); `re.IGNORECASE` muaf.
- **"Reddedilmiş" süzgeci dizgeye dayanıyor** (*çıkmaz · geri alındı ·
  vazgeçildi · reddedildi · bilerek yok* …). ***Süzgeç EKSİK olabilir,
  FAZLA değil***: bu kelimelerle yazılmamış bir ret kaydı sayıma girmez.
- **Prose kayıtlarının (c) kovasına girmesi YAPISAL bir sonuçtur**, o
  kayıtların kapalı OLMADIĞI anlamına gelmez — yalnız *kapalılıklarının
  makine-okunur bir kanıtı yok* demektir.
- **Kapanış kanıtı BOŞ olan 13 tablo satırı** (a) ölçütünü karşılamıyor;
  sayıldı, ayrı raporlandı, **yorumlanmadı.**
