/// RELEASE İMZASI SESSİZ-DÜŞÜŞ KAPISI (`L-286`nın regresyon kilidi,
/// `LIS-P0-002`).
///
/// ## Neden bu dosya var
/// `android/app/build.gradle.kts` zaten L-286'da bir kapı kazandı: gerçek
/// keystore (`key.properties`) yoksa VE `-PallowDebugSigning` açıkça
/// verilmediyse, GERÇEK bir release görevi (`bundleRelease` vb.) Gradle'ı
/// `GradleException` ile durdurur — debug anahtarıyla imzalanmış ve
/// Play'in reddedeceği bir AAB'nin SESSİZCE üretilmesini engeller.
///
/// Bu mantık Gradle Kotlin DSL'de yaşıyor; Dart testinden ÇALIŞTIRILAMAZ
/// (gerçek bir Gradle koşumu gerekir — pahalı, ve CI'da AYRI bir adım
/// olarak zaten var: `flutter build appbundle --release
/// -PallowDebugSigning=true`, bkz. `.github/workflows/checks.yml`). Bu
/// dosya GRADLE'I ÇALIŞTIRMAZ; kaynak metninin kendisinin hâlâ üç kritik
/// parçayı taşıdığını doğrular — `shipped_claim_test.dart`nin
/// `wellness_lint.py` kaynak-doğrulama desenindeki AYNI teknik. Biri
/// sessizce silinirse (ör. bir refactor sırasında) bu kapı KIRMIZI yanar;
/// gerçek koruma yalnız CI'ın gerçek `-release` koşumuyla TAM doğrulanır.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _gradlePath = 'android/app/build.gradle.kts';

void main() {
  test('debug-imza-düşüşü guard\'ının üç parçası da kaynakta duruyor', () {
    final String src = File(_gradlePath).readAsStringSync();
    final Map<String, String> mustContain = <String, String>{
      'gerçek keystore kontrolü':
          'val hasRealSigning = keyProps.getProperty("storeFile") != null',
      'bilinçli debug-imza kapısı': 'project.hasProperty("allowDebugSigning")',
      'sessiz düşüşü durduran hata': 'throw GradleException(',
    };
    final List<String> missing = <String>[
      for (final MapEntry<String, String> e in mustContain.entries)
        if (!src.contains(e.value)) '${e.key}: «${e.value}» bulunamadı',
    ];
    expect(missing, isEmpty,
        reason: 'L-286 GUARD\'I ZAYIFLADI:\n${missing.join("\n")}\n\n'
            'Bu, release AAB\'nin debug anahtarıyla SESSİZCE üretilip '
            'Play\'de reddedilmesi riskini geri getirir.');
  });

  test('SABOTAJ — desen gerçekten ateşliyor mu', () {
    const String sabotaged = '''
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    ''';
    final bool wouldCatch = !sabotaged.contains(
        'val hasRealSigning = keyProps.getProperty("storeFile") != null');
    expect(wouldCatch, isTrue,
        reason: 'BULUCU BOZUK: guard\'ı tamamen kaldırılmış bir dosyayı '
            'bile ihlal olarak görmüyor');
  });
}
