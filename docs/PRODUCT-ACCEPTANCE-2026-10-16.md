# Lissom — sınırlı yazılım kabulü, 16 Ekim 2026

Kanonik repo: `ventures/lissom/app`. Başlangıç: `df434ff1d1bcc1a6ad5b0e68a10e324cf712baff` (temiz çalışma ağacı). Bu kayıt, bu dosyayı içeren commit'teki iki küçük uygulama düzeltmesi ve aşağıdaki otomatik kabul kapsamına aittir.

## Kapatılan kusurlar

Library'den Hatha, sandalye/ofis, Vinyasa veya Yin açılırken ilerleme deposunun kurulması/okunması hata verirse önceki kod yakalanmamış async hata üretiyordu. Dört giriş artık aynı yerel düğme bileşeninde görünür TR/EN hata ve yeniden deneme sunuyor. Bekleyen aynı girişe çift dokunma tek rota açıyor; giriş ekranından ayrıldıktan sonra biten yükleme rota açmıyor.

Ders kaydında bir frame çizilmeden iki dokunma iki `markPracticed` çağrısı başlatabiliyordu (gerçek RED: beklenen 1, gözlenen 2). Kaydetme metodu bekleyen yazıyı ve güncel öz denetim onayını yeniden kontrol ediyor; tek yazma ve tek geri dönüş korunuyor.

## Doğrulama

- `flutter test --no-pub`: **667 PASS**, skip yok. Kurs, ön koşul, görünür kaynak sınırları, self-report kayıtları, gezinme, TR/EN dar ekran/büyük yazı, izin reddi, hata/retry ve hesap ömrü regresyonlarını içerir.
- Yeni `course_entry_recovery_test.dart`: **19 widget PASS**. Dört kurs × açma/okuma hatası × TR/EN, 320 × 640 / 2× metin; ayrıca çift giriş, ayrılma sırasında yükleme ve çift kayıt dokunması.
- Yeni `course_progress_persistence_test.dart`: **1 PASS**. Dört kursun toplam **90** dersi aynı gerçek JSONL dosyasına ön koşul sırasıyla yazılır, her kurs sonunda yeni store ile okunur; başka kurs ilerlemesine sızmaz, kilitli son ders önceden kaydedilemez.
- `packages/lissom_engine`: **114 unit PASS**; fiziksel sensör veya yoga doğruluğu sonucu değildir.
- `flutter analyze --no-pub`: **No issues found**. İlk çalıştırmada eski scratch/cache yolları yüzünden 699 çözümleme hatası çıktı. Mevcut engine cache'i `dart pub get --offline --enforce-lockfile` ile çözümlendi; kaynak/lock/pin değişmedi, son analiz temiz. İlk hata logu korundu.
- Kaynak denetimi: dört course asset'indeki TR/EN öğretim alanları, sıralı ön koşullar ve kaynak ID'leri geçerli. Asset byte'ları değişmedi.

Yeni 20 test, toplam 667'nin içindedir; sayılar toplanmaz. Kanıtlar `scratch/2026-10-16-night-lissom-acceptance/` altındaki `entry-red.log`, `save-red.log`, `recovery-green.log`, `app-suite.log`, `engine-suite.log`, `analyze.log`, `course-inventory.json` ve final SHA bağlı `RESULT.json` içindedir. İlk Türkçe geri düğmesi/test kaydırması fixture hataları ayrı loglarda tutulur; ürün kabulü sayılmaz.

## Kurs tamlığı ve açık sınırlar

Kaynakta Hatha 60, sandalye/ofis 12, destekli ayakta Vinyasa 10, destekli Yin 8 ders vardır. **Tam başlangıç Ashtanga kursu eksiktir.** Yalnız `study_review_content.dart` içindeki iki geçici yazılı hazırlık birimi vardır; bunlar kalıcı kurs ilerlemesi veya tam müfredat değildir. Uygulamanın mevcut “bekliyor” açıklaması korunur. Hatha h49 uyarlaması tam geleneksel Ashtanga serisi kabul edilmez.

Ashtanga için ayrı, kaynaklı ve yetkin incelemeli aşamalı müfredat önerisi ile simülatör run card'ı `scratch/2026-10-16-night-lissom-acceptance/ASHTANGA-AND-SIMULATOR.md` içindedir. Büyük yeni müfredat bu küçük onarımın içine eklenmedi; sabah kapsam kararı için ayrıldı. Mevcut şema ve self-report deposu yeni kursu taşıyabilir; Shared Motion değişikliği ihtiyacı saptanmadı.

Yeni native simülatör koşusu **UNRUN**: LifeOS önceliği nedeniyle bu turda simülatör sahiplenilmedi. Yaklaşık 15 dakikalık bir sonraki ayrılmış pencerede ilk açılış → dört kurs girişi → kayıt → geri dönüş → app yeniden açılışı/readback → dar ekran/büyük yazı akışı doğrulanmalı.

Fiziksel poz/sensör doğruluğu, bireysel sağlık güvenliği/uygunluk, demonstrasyon ve medya lisansı, IAP, gerçek cihaz, imza ve mağaza kabulü açık. Shared Motion Core/workspace ve simgeler değiştirilmedi. Mağaza yüklemesi yapılmadı; ilk üç grup tamamlanmadan yapılmayacak.
