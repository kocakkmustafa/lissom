/// GİZLİLİK MANİFESTİ ↔ İKİLİ GERÇEKLİK KAPISI (`L-348`, `LIS-P0-002`).
///
/// ## Neden bu dosya var
/// `ios/Runner/PrivacyInfo.xcprivacy`nin kendi yorumu (L-288, 2026-08-12)
/// GERÇEK bir ağ davranışını dürüstçe kaydediyordu: `google_fonts` üretimde
/// kullanılıyor, `allowRuntimeFetching` KAPATILMAMIŞ, `pubspec`te
/// paketlenmiş font YOK — uygulama yazı tiplerini ÇALIŞMA ANINDA
/// indiriyordu. Bu kapı üç ekseni birlikte tutar; biri eksik kalırsa "font
/// bundle edildi" iddiası yarım-doğru olur (kod kapalı ama dosya yok, ya da
/// dosya var ama kod hâlâ açık):
///
/// ① manifest KENDİSİ well-formed XML ve hesap verisi beyanını taşıyor.
/// ② `main.dart` runtime fetch'i GERÇEKTEN kapatıyor (kaynak-metin kapısı —
///    `shipped_claim_test.dart`nin `wellness_lint.py` kaynak-doğrulama
///    desenindeki AYNI teknik: davranışı üreten kodun KENDİSİ okunur).
/// ③ bundle edilmesi gereken 4 font dosyası GERÇEKTEN diskte VE
///    `pubspec.yaml`nin `assets:` girdisiyle eşleşiyor.
///
/// ③ fontlar yoksa test sert hata verir. Runtime indirmeyi kapatıp fontu
/// pakete eklememek simülatörde ilk ekranda hata üretti; yalnız `skip`
/// göstermek yayın derlemesini korumuyordu. Test ve derleme öncesinde
/// `tool/fetch_fonts.sh` dört pinli dosyayı doğrulamalıdır.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _manifestPath = 'ios/Runner/PrivacyInfo.xcprivacy';
const String _mainPath = 'lib/main.dart';
const String _pubspecPath = 'pubspec.yaml';
const String _fontsDir = 'assets/fonts';

/// `tool/fetch_fonts.sh`deki pinle AYNI kaynaktan — TEK yerde elle
/// yazılmış sayı burada, script'te BİREBİR aynı olmalı (kopya risklidir,
/// ama iki dosyanın AYNI pinni bağımsız taşıması burada BİLEREK: biri
/// kaynak-of-truth [script], diğeri REGRESYON ÇAPASI [bu test] — script
/// değişirse bu test de değişmeli, sessizce ayrışmamalı).
const Map<String, int> _expectedFontBytes = <String, int>{
  'Newsreader-Light.ttf': 109452,
  'Newsreader-Regular.ttf': 109516,
  'NunitoSans-Regular.ttf': 106736,
  'NunitoSans-SemiBold.ttf': 106844,
};

void main() {
  group('① manifest yapısal olarak sağlam ve dört zorunlu anahtar var', () {
    // Tam XML ayrıştırma YOK — bu depoda `xml` paketi yok ve tek bir
    // yapısal kapı için yeni bağımlılık EKLEMEK bu turun kapsamı DEĞİL.
    // Metin-tabanlı denetim yeterli: plist basit ve iç içe değil.
    test('plist etiketleri dengeli ve dört zorunlu anahtar var', () {
      final File f = File(_manifestPath);
      expect(f.existsSync(), isTrue, reason: '$_manifestPath bulunamadı');
      final String src = f.readAsStringSync();
      expect(src, startsWith('<?xml'), reason: 'XML bildirimi eksik/kaymış');
      expect(
        '<dict>'.allMatches(src).length,
        equals('</dict>'.allMatches(src).length),
        reason: '<dict> açma/kapama sayısı eşleşmiyor',
      );
      expect(
        '<plist'.allMatches(src).length,
        equals('</plist>'.allMatches(src).length),
        reason: '<plist> açma/kapama sayısı eşleşmiyor',
      );
      for (final String required in <String>[
        'NSPrivacyTracking',
        'NSPrivacyTrackingDomains',
        'NSPrivacyCollectedDataTypes',
        'NSPrivacyAccessedAPITypes',
      ]) {
        expect(
          src,
          contains('<key>$required</key>'),
          reason: '$required manifestten düşmüş',
        );
      }
      for (final String accountData in <String>[
        'NSPrivacyCollectedDataTypeEmailAddress',
        'NSPrivacyCollectedDataTypeName',
        'NSPrivacyCollectedDataTypeUserID',
      ]) {
        expect(
          src,
          contains('<string>$accountData</string>'),
          reason: '$accountData hesap veri beyanından düşmüş',
        );
      }
      expect(src, isNot(contains('NSPrivacyCollectedDataTypePurchaseHistory')),
          reason: 'İlk sürümde satın alma kapalı; işlem geçmişi toplanmıyor.');
    });
  });

  group('② main.dart runtime font fetch\'i GERÇEKTEN kapatıyor', () {
    test(
      'GoogleFonts.config.allowRuntimeFetching = false, runApp\'tan ÖNCE',
      () {
        final String src = File(_mainPath).readAsStringSync();
        expect(
          src,
          contains('GoogleFonts.config.allowRuntimeFetching = false'),
          reason:
              '$_mainPath artık runtime fetch\'i kapatmıyor — '
              'PrivacyInfo.xcprivacy\'nin "font çalışma anında indiriliyor" '
              'beyanı yeniden GERÇEK olur',
        );
        final int fetchOff = src.indexOf('allowRuntimeFetching = false');
        final int runAppCall = src.indexOf('runApp(');
        expect(fetchOff, greaterThan(-1));
        expect(runAppCall, greaterThan(-1));
        expect(
          fetchOff,
          lessThan(runAppCall),
          reason:
              'kapatma runApp\'tan SONRA gelirse ilk frame\'ler yine '
              'ağa çıkabilir — sıra önemli',
        );
      },
    );

    test('SABOTAJ — desen gerçekten ateşliyor mu', () {
      const String sabotaged = 'void main() => runApp(const LissomApp());';
      expect(
        sabotaged.contains('allowRuntimeFetching = false'),
        isFalse,
        reason:
            'BULUCU BOZUK: eski (kaldırılan) main() gövdesini bile '
            'ihlal olarak görmüyor',
      );
    });
  });

  group('③ dört font dosyası bundle edildi', () {
    test('pubspec.yaml assets: altında assets/fonts/ listeli', () {
      final String pubspec = File(_pubspecPath).readAsStringSync();
      expect(
        pubspec,
        contains('assets/fonts/'),
        reason: 'pubspec.yaml artık $_fontsDir/\'i asset olarak taşımıyor',
      );
    });

    // CI dosyaları testten önce indirir. Yerel test veya derleme de aynı
    // hazırlığı yapmalı; eksik font sessizce atlanırsa ilk ekran bozulur.
    for (final MapEntry<String, int> e in _expectedFontBytes.entries) {
      test('${e.key} diskte VE beklenen boyutta', () {
        final File f = File('$_fontsDir/${e.key}');
        expect(
          f.existsSync(),
          isTrue,
          reason: '${e.key} yok; önce `tool/fetch_fonts.sh` çalıştır',
        );
        expect(
          f.lengthSync(),
          equals(e.value),
          reason:
              '${e.key} boyutu pinle uyuşmuyor — yanlış dosya ya da '
              'bozuk indirme, `tool/fetch_fonts.sh` SHA-256 '
              'doğrulamasını yeniden koştur',
        );
      });
    }
  });
}
