# M-TALEBİ — Dışlanan kaynağın NEDEN'i: bağlam etiketi

**Bağlam:** M-F-47 anlaşma kapısı v0.5.0'da; aykırı `excludedOutlierIds`'ta adla raporlanıyor.
**Talep:** dışlama SEBEBİNİN de taşınması. **Tarih:** 2026-07-29

## 1. Sorun: "dışlandı" bilgi değil, bilgi eksikliği

`deep_squat`'ta aykırı Man Flow Yoga (65° · diğer üçü 37-41°). Bu dışlama tek başına iki tamamen farklı şeyi aynı görünüme sokuyor:

- **Kaynak kötü** — izleme artefaktı, yanlış kişi, kadraj sorunu → kaynağı elemeli.
- **Kaynak doğru ama BAŞKA BİR ŞEYİ ölçüyor** — yoga bağlamında "squat" daha sığ bir çömelme (Utkatasana benzeri); kaynak kendi bağlamında doğru → eleme *bizim tanımımızın* dar olduğunu söylüyor.

İkisi zıt eylem gerektiriyor: birincisinde kaynağı at, ikincisinde ya testin tanımını netleştir ya da o bağlam için ayrı bir referans aç. Yalnız `excludedOutlierIds` gören biri bu ikisini ayırt edemez ve **ölçüm turu tekrarlanmadan** ayırt edemez — yani bilgi her seferinde yeniden üretilir.

## 2. Öneri: `contextTags` — ölçüm değil, PROVENANCE

Kaynak manifestine ve fixture provenance'ına serbest-metin değil **sözlüklü** etiket:

```
contextTags?: [ "yoga" | "clinical-exam" | "rehab" | "strength-training"
              | "gymnastics" | "instructional" | "competition" | ... ]
contextSource: "channel" | "title" | "transcript" | "manual"
```

Kaynak: kanal/başlık/transkript — `romMode` ile aynı desen, çünkü bağlam da landmark'ta **görünmez**. (Bakış açısında bu deseni reddetmiştim çünkü orası ölçülebiliyor — L-116. Ayrım kasıtlı: görünmeyen metadata'dan gelir, görünen ölçülür.)

ReferenceBuilder aykırıyı raporlarken etiketi de taşır:

```
excluded: [{ id: "TuQ4jYbazuw", deviation: 26.3, contextTags: ["yoga"] }]
```

## 3. Neden ölçüm değil de etiket

Bağlam bir ölçüm sonucu değil, kaynağın **niyeti**. 65°'lik bir çömelme ölçüm olarak kusursuz olabilir; onu aykırı yapan şey Lissom'un "deep squat" tanımının strength/mobility bağlamından gelmesi. Bu bir veri kalitesi sorunu değil, **tanım kapsamı** sorunu — ve tanım kapsamı ancak insan kararıyla değişir.

## 4. Beklenen fayda

- **Sistematik aykırılık görünür olur:** aynı etiket birden çok testte aykırı çıkıyorsa, sorun kaynaklarda değil o bağlamın bizim tanımımıza uymamasındadır.
- **Gelecekte bağlam-ayrık referans mümkün olur** (yoga kullanıcısına yoga referansı) — bugün gerekmiyor ama kapıyı kapatmamak bedava.
- **İnsan-uzman turu için hazır soru:** "yoga bağlamındaki daha sığ çömelme ayrı bir norm mu, yoksa aynı normun sığ ucu mu?"

## 5. Kapsam uyarısı

Etiket sözlüğü **aile düzeyinde** tanımlanmalı; her app kendi kelimesini icat ederse çapraz-app analiz yine imkânsızlaşır — `romMode`'un serbest-metin yasağıyla aynı gerekçe (M-J-05.1). Lissom için başlangıç sözlüğü yukarıdaki 7 değer; genişletme koordinatör onayıyla.

**Uygulama durumu:** ÖNERİ. Rig'e eklemeye hazırım, onay bekliyorum — sözlük aile düzeyinde olduğu için tek başıma tanımlamam doğru olmaz.
