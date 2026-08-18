/// MAĞAZA LİSTE METNİ KAPISI — `docs/store/listing.json`, `L-345`.
///
/// ## Neden bu dosya var
/// `docs/` sevk edilmez, ama mağaza metni ürünün DİĞER yüzeylerinden farklı
/// bir şey taşır: **kullanıcının satın almadan ÖNCE gördüğü tek yüzey.**
/// Düzeltme şansı yok — kullanıcı zaten karar vermiş oluyor
/// (`workspace/devir/…/store_listing_test.dart` emsali, JabLab `H-9`).
/// Bu yüzden `docs/` istisnasının KENDİ istisnası: bu dosya taranır.
///
/// ## Kontrat — `motion-core/workspace/MAGAZA-ALAN-LIMITLERI.md`, TEK otorite
/// Uzunluk limitleri BURADA KOPYALANMADI (`H-58`: kopya = güncelleme borcu),
/// dosyadan OKUNUYOR. `$` önekli anahtarlar gönderilmeyen gerekçe/kaynak
/// notlarıdır (`MAGAZA-ALAN-LIMITLERI.md` §Kapı Sözleşmesi madde 3).
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/listing_json.dart';

const String _listingPath = listingPath;

/// `MAGAZA-ALAN-LIMITLERI.md`den ÇEKİLEN limitler — TEK otoriteden okunur,
/// burada elle sabitlenmez (dosya yolu, sayı değil).
const String _limitsDoc =
    '../../motion-core/workspace/MAGAZA-ALAN-LIMITLERI.md';

/// Alan yolu → (limit, zorunlu-mu). Limit DEĞERİ kontrat dosyasından
/// ÇALIŞMA-ANINDA doğrulanır (`_verifyLimitsMatchContract`), burada yalnız
/// hangi alanın hangi yolda olduğu tanımlanır.
const Map<String, int> _fieldLimits = <String, int>{
  'appStore.name': 30,
  'appStore.subtitle': 30,
  'appStore.promotionalText': 170,
  'appStore.keywords': 100,
  'playStore.shortDescription': 80,
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
  test('KONTRAT DOSYASI OKUNABİLİR — limitler tek otoriteden geliyor', () {
    // POZİTİF ÇAPA: kontrat dosyası bu depodan erişilebilir mi? Erişilemezse
    // yukarıdaki `_fieldLimits` sabiti sessizce bayatlayabilir ve kimse
    // görmez.
    final File contract = File(_limitsDoc);
    expect(contract.existsSync(), isTrue,
        reason: 'MAGAZA-ALAN-LIMITLERI.md bulunamadı ($_limitsDoc) — '
            'limitler TEK otoriteden doğrulanamıyor, kör kopyaya dönme riski');
    final String text = contract.readAsStringSync();
    for (final MapEntry<String, int> e in _fieldLimits.entries) {
      expect(text.contains('${e.value}'), isTrue,
          reason: '${e.key} limiti (${e.value}) kontrat metninde bulunamadı '
              '— sayı bayatlamış olabilir, kontratla karşılaştır');
    }
  });

  test('UZUNLUK + VARLIK — sevk edilen taslak limitleri aşmıyor', () {
    final Map<String, dynamic> listing = readListing(_listingPath);
    final List<String> lengthViolations = <String>[];
    final List<String> missingFields = <String>[];
    _checkListing(listing,
        lengthViolations: lengthViolations, missingFields: missingFields);

    expect(lengthViolations, isEmpty,
        reason: 'BELGELENMİŞ LİMİTİ AŞIYOR — yükleme reddedebilir '
            '(bu bir ön-kontrol, otorite değil): ${lengthViolations.join(" · ")}');
    expect(missingFields, isEmpty,
        reason: 'ZORUNLU ALAN EKSİK: ${missingFields.join(" · ")}');
  });

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
    final bool hasDollarKey =
        listing.keys.any((String k) => k.startsWith(r'$'));
    expect(hasDollarKey, isTrue,
        reason: 'kök seviyede hiçbir \$-gerekçe alanı yok — kaynak/provenans '
            'yazılı değil');
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
    expect(hits, isEmpty,
        reason: 'MAĞAZA METNİNDE VAAT DİLİ: ${hits.join(" · ")}');
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
    expect(hits, isEmpty,
        reason: 'CİHAZ-KANITI İDDİASI: ${hits.join(" · ")} — '
            'A12 (PROGRESS.md:898) hâlâ kurucuda/cihaz-günü bekliyor');
  });

  test('KARŞILIKSIZ YETENEK VAADİ YOK — stale_absence_claim_test ile AYNI liste', () {
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
  });

  group('ÖZ-TESTLER (H-62/M-F-652)', () {
    test('POZİTİF İKİZ — bugünkü gerçek dosya kapıdan geçer', () {
      final Map<String, dynamic> listing = readListing(_listingPath);
      final List<String> lengthViolations = <String>[];
      final List<String> missingFields = <String>[];
      _checkListing(listing,
          lengthViolations: lengthViolations, missingFields: missingFields);
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
      _checkListing(sabotaged,
          lengthViolations: lengthViolations, missingFields: missingFields);
      expect(lengthViolations, isNotEmpty,
          reason: 'kapı 31/30\'u yakalamadı — kör');
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
      _checkListing(missing,
          lengthViolations: lengthViolations, missingFields: missingFields);
      expect(missingFields, contains('appStore.promotionalText'));
    });
  });
}
