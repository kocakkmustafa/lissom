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
/// dosya GRADLE'I ÇALIŞTIRMAZ; kaynak metninin kendisinin hâlâ kritik
/// parçayı taşıdığını doğrular — `shipped_claim_test.dart`nin
/// `wellness_lint.py` kaynak-doğrulama desenindeki AYNI teknik. Biri
/// sessizce silinirse (ör. bir refactor sırasında) bu kapı KIRMIZI yanar;
/// Native kabul ayrıca false/boş opt-in ve generic assemble/wrapper görev
/// grafikleriyle doğrulanmalıdır; CI'ın explicit-true koşumu ret yollarını
/// tek başına kanıtlamaz.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _gradlePath = 'android/app/build.gradle.kts';

void main() {
  test('debug signing requires an exact true property value', () {
    final String src = File(_gradlePath).readAsStringSync();
    expect(
      src,
      contains(
        'providers.gradleProperty("allowDebugSigning").orNull == "true"',
      ),
    );
    expect(src, isNot(contains('hasProperty("allowDebugSigning")')));
  });

  test('release guard reads actual app tasks and leaves no debug fallback', () {
    final String src = File(_gradlePath).readAsStringSync();
    expect(src, contains('gradle.taskGraph.whenReady {'));
    expect(src, contains('val graph = this'));
    expect(src, isNot(contains('gradle.taskGraph.whenReady { graph ->')));
    expect(src, contains('graph.allTasks.any { task ->'));
    expect(src, contains('task.project == project'));
    expect(src, contains('task.name.contains("Release", ignoreCase = true)'));
    expect(src, contains('if (!hasRealSigning && !allowDebugSigning)'));
    expect(src, contains('else -> signingConfig = null'));
    expect(src, contains('throw GradleException('));
    expect(src, isNot(contains('gradle.startParameter.taskNames')));
    expect(
      src,
      isNot(
        contains('else -> signingConfig = signingConfigs.getByName("debug")'),
      ),
    );
  });

  test('real signing and explicit local debug signing remain distinct', () {
    final String src = File(_gradlePath).readAsStringSync();
    expect(
      src,
      contains(
        'val hasRealSigning = keyProps.getProperty("storeFile") != null',
      ),
    );
    expect(src, contains('signingConfigs.getByName("release")'));
    expect(src, contains('allowDebugSigning -> {'));
    expect(src, contains('signingConfigs.getByName("debug")'));
    expect(src, contains('logger.warn('));
  });
}
