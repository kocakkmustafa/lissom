# Yazılı hatırlama ve geri bildirim — 12 Ekim 2026

Bu ek, mevcut kaynak derslerini okuma/aktif hatırlama ile çalıştırır. Hareket veya ekipman gerekmez. Öğrenen yazılı cevabı kaynaktan ayrı kurup karşılaştırır. Fiziksel uygunluk, tekniğin doğruluğu, demonstrasyon/lisans ve tam müfredat kabulü verilmez.

| Onaylı alan | Mevcut ders/birim | Yeni okuma | Açık kapsam |
|---|---:|---:|---|
| hatha | 60 | 2 | Existing progression and adaptations need individual suitability and physical review; a reading tick or camera battery result cannot validate yoga technique. |
| chair | 12 | 2 | Stable chair suitability, regional movement and interruption recovery require actual setup/learner review; health outcomes are not claimed. |
| vinyasa | 10 | 2 | Standing route entry/exit and F02-F04 mechanism/suitability remain open; an untaught floor branch is not substituted for a taught standing route. |
| yin | 8 | 2 | Supported floor access, prop setup, exits and personal suitability require review; neutral/chair alternatives are not identical Yin skills; duration is not a health dose. |
| ashtanga | 0 | 2 | Complete beginner course is missing: traditional curriculum identity/order, staged teaching, adaptations, demonstration and learner feedback require competent review. Added bridge teaches only distinction/map literacy. |

Kaynak dosyaları ve bölüm referansları `lib/app/study_review_content.dart` içindeki `sourceRefs` alanındadır. Eski ders metinleri, süre/doz, sensör eşikleri, fiziksel kabul ve ders ilerlemesi değiştirilmez.

`study_review.dart` durumları ayrı tutar: denenmedi → örneği yeniden oku; belirsiz → kesin terimi/geçişi adlandır ve uygun eğitmene soru hazırla; tek fark → yalnız aynı yazılı noktayı düzeltip kaynağı gizleyerek yeniden hatırla; durdum → bitir, hareket/ekipman görevini tekrar etmeyi önerme. Notlar geçicidir; kalıcı sağlık/hesap/ilerleme kaydı yoktur.

`test/study_review_test.dart` TR/EN dar ekran/büyük metin, kaynak cevabının gizlenip açılması, dört farklı geri bildirim ve çıkışta not/durum atılmasını sınar. Gerçek cihaz, fiziksel öğretim, sensör ve mağaza testi değildir.
