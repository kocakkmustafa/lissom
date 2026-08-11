/// Onboarding kalıcılığı — `OnboardingStore` round-trip + bozuk-dosya
/// toleransı (SIRA①, 2026-08-12).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/onboarding_store.dart';

void main() {
  late Directory tmp;
  late File file;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lissom-onboarding-test');
    file = File('${tmp.path}/onboarding.json');
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  test('notStarted() completed=false, tüm alanlar null', () {
    const OnboardingProfile p = OnboardingProfile.notStarted();
    expect(p.completed, isFalse);
    expect(p.ageBand, isNull);
    expect(p.gender, isNull);
    expect(p.painNotes, isNull);
  });

  test('dosya YOKSA notStarted döner (çökme değil)', () async {
    final JsonOnboardingStore store = JsonOnboardingStore(file);
    final OnboardingProfile p = await store.read();
    expect(p.completed, isFalse);
  });

  test('bozuk JSON notStarted döner (çökme değil)', () async {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('{ bu json değil');
    final JsonOnboardingStore store = JsonOnboardingStore(file);
    final OnboardingProfile p = await store.read();
    expect(p.completed, isFalse,
        reason: 'bozuk dosya en kötü ihtimalle onboarding\'i TEKRARLATIR, '
            'çökme veya sessiz veri kaybı üretmemeli');
  });

  test('yazma → okuma tam TUTAR (tüm alanlar)', () async {
    final JsonOnboardingStore store = JsonOnboardingStore(file);
    await store.write(const OnboardingProfile(
      completed: true,
      ageBand: '40-59',
      gender: 'non-binary',
      painNotes: 'left shoulder, old injury',
    ));
    final OnboardingProfile read = await store.read();
    expect(read.completed, isTrue);
    expect(read.ageBand, '40-59');
    expect(read.gender, 'non-binary');
    expect(read.painNotes, 'left shoulder, old injury');
  });

  test('opsiyonel alanlar boşken JSON\'da HİÇ görünmez', () async {
    final JsonOnboardingStore store = JsonOnboardingStore(file);
    await store.write(const OnboardingProfile(completed: true, ageBand: 'u40'));
    final String raw = file.readAsStringSync();
    expect(raw, isNot(contains('gender')));
    expect(raw, isNot(contains('painNotes')));
  });

  test('copyWith yalnız belirtilen alanı değiştirir', () {
    const OnboardingProfile base = OnboardingProfile(completed: false, ageBand: 'u40');
    final OnboardingProfile updated = base.copyWith(completed: true);
    expect(updated.completed, isTrue);
    expect(updated.ageBand, 'u40', reason: 'dokunulmayan alan KORUNMALI');
  });
}
