/// MAĞAZA LİSTE METNİ KAPISI — `docs/store/listing.json`, `L-345`.
///
/// ## Neden bu dosya var
/// `docs/` sevk edilmez, ama mağaza metni ürünün DİĞER yüzeylerinden farklı
/// bir şey taşır: **kullanıcının satın almadan ÖNCE gördüğü tek yüzey.**
/// Düzeltme şansı yok — kullanıcı zaten karar vermiş oluyor
/// (`workspace/devir/…/store_listing_test.dart` emsali, JabLab `H-9`).
/// Bu yüzden `docs/` istisnasının KENDİ istisnası: bu dosya taranır.
///
/// ## Kontrat
/// Sevk edilen alanların uzunluk ve varlık sınırları aşağıda doğrulanır.
/// `$` önekli anahtarlar gönderilmeyen gerekçe/kaynak notlarıdır. Test,
/// GitHub checkout'unda bulunmayan yerel workspace belgelerine dayanmaz.
///
/// ## Üç ölçüm (kontratın kendi şartı)
/// 1. Uzunluk — her alan limitini aşarsa KIRMIZI.
/// 2. Varlık — zorunlu alan eksikse KIRMIZI (`playStore.title` hariç,
///    kontrat onu opsiyonel ilan etti — `M-F-750`).
/// 3. `$` sözleşmesi — kullanıcı-dizesi yürüyüşü `$` anahtarlarını atlar.
///
/// ## Üç öz-test (`H-62`/`M-F-652`: bir kapı kendi körlüğünü kanıtlamalı)
/// Pozitif ikiz · sabotaj (limiti 1 aşan sahte metin) · vakum (dosya/alan
/// tamamen kaybolursa kapı SESSİZCE geçmemeli).
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'support/listing_json.dart';

const String _listingPath = listingPath;
const String _trListingPath = 'docs/store/listing.tr-TR.json';

/// Alan yolu → mağaza taslağı için üst karakter sınırı.
/// Mağaza sınırları değişirse bu değerler sağlayıcıyla yeniden doğrulanır.
const Map<String, int> _fieldLimits = <String, int>{
  'appStore.name': 30,
  'appStore.subtitle': 30,
  'appStore.promotionalText': 170,
  'appStore.keywords': 100,
  'playStore.title': 30,
  'playStore.shortDescription': 80,
  'playStore.fullDescription': 4000,
  'description': 4000,
};

const Set<String> _requiredFields = <String>{
  'appStore.name',
  'appStore.subtitle',
  'appStore.promotionalText',
  'appStore.keywords',
  'playStore.shortDescription',
  'description',
};

String? _dig(Map<String, dynamic> listing, String dotted) {
  Object? cur = listing;
  for (final String part in dotted.split('.')) {
    if (cur is! Map) return null;
    cur = cur[part];
  }
  return cur is String ? cur : null;
}

void _checkListing(
  Map<String, dynamic> listing, {
  required List<String> lengthViolations,
  required List<String> missingFields,
}) {
  for (final MapEntry<String, int> e in _fieldLimits.entries) {
    final String? v = _dig(listing, e.key);
    if (v != null && v.length > e.value) {
      lengthViolations.add('${e.key}: ${v.length}/${e.value}');
    }
  }
  for (final String key in _requiredFields) {
    final String? v = _dig(listing, key);
    if (v == null || v.isEmpty) missingFields.add(key);
  }
}

void main() {
  test('UZUNLUK + VARLIK — sevk edilen taslak limitleri aşmıyor', () {
    final Map<String, dynamic> listing = readListing(_listingPath);
    final List<String> lengthViolations = <String>[];
    final List<String> missingFields = <String>[];
    _checkListing(
      listing,
      lengthViolations: lengthViolations,
      missingFields: missingFields,
    );

    expect(
      lengthViolations,
      isEmpty,
      reason:
          'BELGELENMİŞ LİMİTİ AŞIYOR — yükleme reddedebilir '
          '(bu bir ön-kontrol, otorite değil): ${lengthViolations.join(" · ")}',
    );
    expect(
      missingFields,
      isEmpty,
      reason: 'ZORUNLU ALAN EKSİK: ${missingFields.join(" · ")}',
    );
  });

  test('tr-TR taslağı alan ve mevcut yetenek sınırını koruyor', () {
    final Map<String, dynamic> listing = readListing(_trListingPath);
    final Map<String, dynamic> english = readListing(_listingPath);
    final List<String> lengthViolations = <String>[];
    final List<String> missingFields = <String>[];
    _checkListing(
      listing,
      lengthViolations: lengthViolations,
      missingFields: missingFields,
    );
    expect(lengthViolations, isEmpty);
    expect(missingFields, isEmpty);

    // K-7 (2026-10-27): 'Lissom: Yoga & Mobility'; TR in its own words.
    expect(_dig(english, 'appStore.name'), 'Lissom: Yoga & Mobility');
    expect(_dig(listing, 'appStore.name'), 'Lissom: Yoga ve Mobilite');
    final String description = _dig(listing, 'description')!;
    // 2026-10-30 rewrite: the movement-test catalogue belonged to the closed
    // camera measurement and the old "Hareket Testleri" name; it stays out.
    for (final String name in <String>[
      'Yukarı uzanma',
      'derin çömelme',
      'düz bacak kaldırma',
    ]) {
      expect(description, isNot(contains(name)));
    }
    expect(description, contains('Lissom’u misafir olarak kullanabilirsin'));
    expect(
      description,
      contains('hareketlerini puanlamak, düzeltmek veya saymak için kamerayı'),
    );
    expect(description, isNot(contains('Kamera değerlendirmeleri')));
    expect(description, contains('arayüz ve tüm dersler 14 dilde'));
    expect(description, contains('10 modülde 60 ders'));
    expect(description, contains('120 dersin 47’si'));
    expect(description, contains('60 Hatha dersinin ilk 24’ü'));
    // Sales open (2026-10-23): free first part, membership, 14-day trial.
    expect(description, contains('Her kursun ilk kısmı ücretsizdir'));
    expect(description, contains('14 günlük ücretsiz deneme'));
    expect(
      description,
      contains('Satın alımları uygulamada geri yükleyebilirsin'),
    );
    expect(description, contains('en az 24 saat önce iptal edilmezse'));
    expect(description, isNot(contains('Üç canlı kamera ölçümü')));
    expect(
      RegExp(
        r'\b(12|on iki)\s+(canlı\s+)?kamera\s+(ölçüm\w*|test\w*)\b',
        caseSensitive: false,
      ).hasMatch(userStrings(listing).join(' ')),
      isFalse,
      reason: 'TR taslak 12 kamera ölçümü izlenimi vermemeli',
    );
    expect(listing.keys.any((String key) => key.startsWith(r'$')), isTrue);
    expect(listing['supportUrl'], english['supportUrl']);
    expect(listing['privacyPolicyUrl'], english['privacyPolicyUrl']);
  });

  // Guideline 3.1.2: the App Store description carries working Terms (EULA)
  // and Privacy links; 2.3.10: it names no other store. The Play copy names
  // no Apple store. TR lives at the site root (defaultLocale tr, as-needed).
  for (final (String path, String terms, String privacy)
      in <(String, String, String)>[
        (
          _listingPath,
          'https://yulalab.com/en/terms',
          'https://yulalab.com/en/privacy/motion',
        ),
        (
          _trListingPath,
          'https://yulalab.com/terms',
          'https://yulalab.com/privacy/motion',
        ),
      ]) {
    test('3.1.2 bağlantıları ve mağaza adı ayrımı: $path', () {
      final Map<String, dynamic> listing = readListing(path);
      final String appStore = _dig(listing, 'description')!;
      final String play = _dig(listing, 'playStore.fullDescription')!;
      for (final String text in <String>[appStore, play]) {
        expect(text, contains(terms));
        expect(text, contains(privacy));
        expect(text, contains('EULA'));
      }
      expect(appStore, isNot(contains('Google')));
      expect(play, isNot(contains('Apple')));
      expect(play, isNot(contains('App Store')));
      expect(_dig(listing, 'playStore.title'), _dig(listing, 'appStore.name'));
    });
  }

  test('\$ SÖZLEŞMESİ — gönderilen alan \$ taşımaz, gerekçe \$ taşır', () {
    final Map<String, dynamic> listing = readListing(_listingPath);
    for (final String key in _requiredFields) {
      final String? v = _dig(listing, key);
      expect(v, isNotNull, reason: '$key eksik');
    }
    // Kök seviyede en az bir $ anahtarı olmalı — provenans yazılı olsun,
    // sessiz varsayım olmasın (H-73: boş alan "yok" ile "bakılmadı"yı
    // ayırt ettirmez; burada "hiç gerekçe yazılmadı" ile "gerekçe var ama
    // görünmüyor"u ayırt ediyoruz).
    final bool hasDollarKey = listing.keys.any(
      (String k) => k.startsWith(r'$'),
    );
    expect(
      hasDollarKey,
      isTrue,
      reason:
          'kök seviyede hiçbir \$-gerekçe alanı yok — kaynak/provenans '
          'yazılı değil',
    );
  });

  test('VAAT DİLİ YOK — henüz gelmemiş bir şeyi ima eden kelime yok', () {
    final Map<String, dynamic> listing = readListing(_listingPath);
    final RegExp promise = RegExp(
      r"\b(yet|soon|coming soon|for now|in a future|will be added|"
      r"we'll add|planned for)\b",
      caseSensitive: false,
    );
    final List<String> hits = <String>[
      for (final String s in userStrings(listing))
        if (promise.hasMatch(s)) '"$s"',
    ];
    expect(
      hits,
      isEmpty,
      reason: 'MAĞAZA METNİNDE VAAT DİLİ: ${hits.join(" · ")}',
    );
  });

  test('CİHAZ-KANITI İDDİASI YOK — A12 hâlâ açık', () {
    final Map<String, dynamic> listing = readListing(_listingPath);
    final RegExp deviceProof = RegExp(
      r'\b(tested on (a )?real device|verified on device|proven on device|'
      r'device[- ]tested|device[- ]verified|clinically)\b',
      caseSensitive: false,
    );
    final List<String> hits = <String>[
      for (final String s in userStrings(listing))
        if (deviceProof.hasMatch(s)) '"$s"',
    ];
    expect(
      hits,
      isEmpty,
      reason:
          'CİHAZ-KANITI İDDİASI: ${hits.join(" · ")} — '
          'A12 (PROGRESS.md:898) hâlâ kurucuda/cihaz-günü bekliyor',
    );
  });

  test(
    'KARŞILIKSIZ YETENEK VAADİ YOK — stale_absence_claim_test ile AYNI liste',
    () {
      // Aynı yasak-vaat sözlüğü — iki dosyada TUTMAK yerine burada TEKRAR
      // yazmak yerine kaynağı işaretliyoruz: değişirse ikisi AYRI turlarda
      // bayatlayabilir, bu satır o riski adıyla taşıyor.
      final Map<String, dynamic> listing = readListing(_listingPath);
      // 🪤 İlk yazım "trend line"/"better than"/"worse than"ı da buraya
      // koymuştu ve KENDİ KENDİNİ ısırdı: description'ın dürüst cümlesi tam
      // olarak "does not draw a trend line or say a result is better or
      // worse than a past one" diyor — yoklukları ADIYLA anlatıyor. Alt-dize
      // yasağı bağlamı (olumsuzlama) ayırt edemez ve doğru davranışı
      // cezalandırdı (L-246 emsali: "will not" da aynı sınıfta muaf
      // tutulmuştu). Bu üçü ÇIKARILDI — riski ["#5/#8" `docs/YOKLUK-
      // IDDIALARI-ENVANTERI-2026-08-17.md`] zaten adıyla taşıyor.
      const Map<String, String> unbacked = <String, String>{
        'feeds your daily plan':
            'stale_absence_claim_test.dart _capabilityClaimGate ile AYNI — '
            'home_screen.dart:169 "program_engine — kodda YOK"',
        'we tell you what to change': 'koçluk katmanı bu derlemede yok',
        'adapts to you': 'uyarlama yapan hiçbir kod yok',
      };
      final List<String> hits = <String>[];
      for (final String s in userStrings(listing)) {
        final String low = s.toLowerCase();
        for (final MapEntry<String, String> c in unbacked.entries) {
          if (low.contains(c.key)) {
            hits.add('"$s" → «${c.key}» ÇÜRÜTEN: ${c.value}');
          }
        }
      }
      expect(hits, isEmpty, reason: 'KARŞILIKSIZ VAAT: ${hits.join(" · ")}');
    },
  );

  // K-6 (2026-10-27): the other twelve of the 14 store languages. Same
  // limits as above; keywords are counted in UTF-8 bytes, where ar/ja/hi/zh
  // can pass a character count and still exceed the byte limit.
  group('14 dil — yerel taslaklar alan ve içerik sınırını koruyor', () {
    final Map<String, dynamic> english = readListing(_listingPath);
    int count(String text, String number) =>
        RegExp('(?<![0-9])$number(?![0-9])').allMatches(text).length;
    final RegExp promise = RegExp(
      r"\b(yet|soon|coming soon|for now|in a future|will be added)\b",
      caseSensitive: false,
    );

    for (final String locale in <String>[
      'es-419',
      'pt-BR',
      'de',
      'fr',
      'ja',
      'ar',
      'it',
      'ko',
      'id',
      'pl',
      'hi',
      'zh-Hans',
    ]) {
      test(locale, () {
        final Map<String, dynamic> local = readListing(
          'docs/store/listing.$locale.json',
        );
        final List<String> lengthViolations = <String>[];
        final List<String> missingFields = <String>[];
        _checkListing(
          local,
          lengthViolations: lengthViolations,
          missingFields: missingFields,
        );
        expect(lengthViolations, isEmpty);
        expect(missingFields, isEmpty);
        expect(
          utf8.encode(_dig(local, 'appStore.keywords')!).length,
          lessThanOrEqualTo(100),
          reason: 'keywords bytes',
        );
        expect(_dig(local, 'appStore.name'), startsWith('Lissom'));

        // 120 lessons: Hatha 60/10 modules, Ashtanga 19/5, Yin 12,
        // Vinyasa 14 (+ 14 languages, 14-day trial), chair/office 15;
        // 47 free; renewal 24 hours.
        final String desc = _dig(local, 'description')!;
        for (final String n in <String>['120', '60', '19', '12', '15', '47']) {
          expect(count(desc, n), greaterThanOrEqualTo(1), reason: n);
        }
        expect(count(desc, '14'), greaterThanOrEqualTo(3));
        expect(count(desc, '24'), greaterThanOrEqualTo(1));
        expect(desc, contains('Motion+'));
        expect(
          userStrings(local).where(promise.hasMatch),
          isEmpty,
          reason: 'promise language',
        );
        expect(local['supportUrl'], english['supportUrl']);
        expect(local['privacyPolicyUrl'], english['privacyPolicyUrl']);
      });
    }
  });

  group('ÖZ-TESTLER (H-62/M-F-652)', () {
    test('POZİTİF İKİZ — bugünkü gerçek dosya kapıdan geçer', () {
      final Map<String, dynamic> listing = readListing(_listingPath);
      final List<String> lengthViolations = <String>[];
      final List<String> missingFields = <String>[];
      _checkListing(
        listing,
        lengthViolations: lengthViolations,
        missingFields: missingFields,
      );
      expect(lengthViolations, isEmpty);
      expect(missingFields, isEmpty);
    });

    test('SABOTAJ — limiti 1 karakter aşan metin YAKALANIR', () {
      final Map<String, dynamic> sabotaged = <String, dynamic>{
        'appStore': <String, dynamic>{
          'name': 'A' * 31, // limit 30
          'subtitle': 'ok',
          'promotionalText': 'ok',
          'keywords': 'ok',
        },
        'playStore': <String, dynamic>{'shortDescription': 'ok'},
        'description': 'ok',
      };
      final List<String> lengthViolations = <String>[];
      final List<String> missingFields = <String>[];
      _checkListing(
        sabotaged,
        lengthViolations: lengthViolations,
        missingFields: missingFields,
      );
      expect(
        lengthViolations,
        isNotEmpty,
        reason: 'kapı 31/30\'u yakalamadı — kör',
      );
    });

    test('VAKUM — dosya bulunamazsa kapı SESSİZCE geçmez, patlar', () {
      expect(
        () => readListing('docs/store/YOK-BOYLE-BIR-DOSYA.json'),
        throwsA(anything),
        reason: 'okuma hatası yutulursa "0 ihlal" VAKUM-DOĞRU olur',
      );
    });

    test('VAKUM — zorunlu alan tamamen kaybolursa YAKALANIR', () {
      final Map<String, dynamic> missing = <String, dynamic>{
        'appStore': <String, dynamic>{
          'name': 'Lissom',
          'subtitle': 'ok',
          // promotionalText BİLEREK yok
          'keywords': 'ok',
        },
        'playStore': <String, dynamic>{'shortDescription': 'ok'},
        'description': 'ok',
      };
      final List<String> lengthViolations = <String>[];
      final List<String> missingFields = <String>[];
      _checkListing(
        missing,
        lengthViolations: lengthViolations,
        missingFields: missingFields,
      );
      expect(missingFields, contains('appStore.promotionalText'));
    });
  });
}
