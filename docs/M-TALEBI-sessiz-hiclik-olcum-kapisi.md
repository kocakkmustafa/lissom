# M-TALEBİ — Sessiz-hiçlik: üç testte ölçüm fazına hiç girilmiyor

**Bağlam:** M-F-57(1) aile kuralı ("sayım cömert dış sınır, hata onun içindeki kalite çizgisi") — Gravita'nın bulgusu Lissom'da da doğrulandı. **Tarih:** 2026-07-29
**Kayıtlar:** L-135 (bulgu, AÇIK) · L-136 (öneri, onay bekliyor) · L-146 (destekleyici bulgu — linter bunu neden kaçırdı)

## 1. Sorun: ölçüm fazına giriş kendisi bir eşik

`overhead_reach`, `ankle_dorsiflexion`, `lateral_bend` — üçü de `rom_sweep` desenini kullanıyor (`config/phases/lissom-phases.v1.json`). Ölçümün alındığı `peak_hold` fazına girmek için **iki koşul BİRLİKTE** gerekiyor:

```
"peak_hold": {
  "enter": { "kind": "all", "of": [
    { "kind": "delta",  "metric": "shoulder_flexion_{side}", "op": "<",  "valuePerSecond": 15.0 },
    { "kind": "metric", "metric": "shoulder_flexion_{side}", "op": ">=", "value": 60 }
  ]}
}
```

Hız yavaşlaması (hareketin durduğunu gösterir) **ve** mutlak değer eşiği (`overhead_reach` ≥60° · `ankle_dorsiflexion` ≥15° · `lateral_bend` ≥15°). Kullanıcı hareketini eşiğin altında durdurursa ikinci koşul hiç sağlanmaz, `peak_hold`'a hiç girilmez, `measureHere` hiç ateşlenmez. Önceki faz (`raising`/`bending`) `timeoutMs`'iyle (8000ms) sessizce zaman aşımına uğrar ve kullanıcıya **ne bir ölçüm ne bir sebep** ulaşır.

Sayılar: `overhead_reach` eşiği 60°, en düşük skor bandı 130° ile başlıyor — yani 60-129° arası dürüstçe "düşük ama ölçülmüş" olması gerekirken hiç ölçülmüyor. `ankle_dorsiflexion`/`lateral_bend`'de 15° eşiği en düşük skor bandının (18°) hemen altında, daha da dar bir sessiz-bölge.

**Bunu en çok ihtiyacı olan kullanıcı görüyor:** donmuş omuzla 50°'ye ulaşabilen biri — uygulamanın var olma sebebi — tam olarak hiçbir şey görmez. Test "başarısız" bile olmuz; hiç bitmez.

## 2. Neden linter yakalamadı (L-146)

`tools/phase_check.py` iki şeyi doğruluyor: her terminal-olmayan fazda `timeoutMs` var mı (sonsuz park koruması) ve her `abort` koşulunun bir `abortCode`'u var mı. İkisi de burada SAĞLANIYOR — `raising` fazının `timeoutMs`'i var, `peak_hold`'un `abort`u (`BENT_ELBOW` vb.) kendi `abortCode`'unu taşıyor. Linter'ın **sormadığı** soru: düz bir TIMEOUT'la (abort değil) biten bir fazın ardından kullanıcıya ulaşan bir sonuç kodu var mı? Kapı "yazılı", ama "hedef yolu" — kullanıcıya gerçekten ulaşan bir sonuç — hiç sınanmıyor. L-131'deki "özellik yazıldı ama hedef yoldan geçmiyor" sınıfının denetim katmanındaki hâli.

## 3. Önerilen yön (L-136 — burada resmileştiriliyor)

`deep_squat` (`descend_return` deseni) aynı sınıf sorunu YAŞAMIYOR: `bottom` fazına giriş **yalnız** hız koşuluyla (`delta > -15°/s`) — mutlak derinlik şartı YOK. Kullanıcı ne kadar sığ çömelirse çömelsin, hareket durduğu anda ölçülüyor ve düşük değer dürüstçe raporlanıyor.

**Öneri — iki parça, ikisi de skorlama semantiğini değiştirdiği için kendi başıma uygulamadım:**

1. Üç testin `peak_hold.enter` koşulundan mutlak-değer eşiğini (`metric >= X`) çıkar, yalnız hız koşulu (`delta`) kalsın — `deep_squat.bottom` deseniyle birebir aynı. Mevcut `conditionGrammar`de zaten var olan `delta` türüyle yapılabilir, yeni bir koşul türü gerekmez.
2. Ölçülen tepe değeri en düşük skor bandının altında kalırsa (`overhead_reach` <130° vb.) sonuç sessizce düşmesin — `RESULT_BELOW_RANGE` gibi ayrı bir kodla **söylensin**. Bu, ailenin `abortCode` desenine paralel ama `abort` değil `complete`-sonrası bir durum; şemaya nasıl oturacağı (yeni alan mı, `complete` fazının bir varyantı mı) koordinatör kararı.

## 4. Kapsam uyarısı

Bu üçü Lissom'un kendi `rom_sweep` deseninde; ailenin diğer üyelerinde aynı "mutlak eşik = ölçüm fazına giriş şartı" deseni varsa (M-F-57(1) zaten JabLab/Choreia/Ostinato'ya da denetim talimatı verdi) aynı sınıf orada da olabilir — ben yalnız kendi bataryamı taradım. `deep_squat` deseni bir referans noktası olarak aile dokümanına (`docs/60-...` veya eşdeğeri) taşınmaya değer olabilir.

**Uygulama durumu:** ÖNERİ. Eşik/kapı tasarımı skorlamayı etkilediği için (M-F-57(1) kapsamındaki "sayım/hata ayrımı" aile kararı gibi) onay olmadan Lissom'da etkinleştirmiyorum. Onay gelirse üç test için config değişikliği + A1-A11 yeniden koşum benim tarafımda hazır.
