/// Aile sayfası kapısı — canlı-3 / engelli-9 (L-206) + **ZORUNLU dürüstlük
/// kutusu** + vaat dili yasağı.
///
/// **Pozitif ikiz iki yönü de sınıyor** (koordinatör şartı): canlı-3 canlı
/// GÖRÜNÜR **ve** engelli-9 İSİMLİ görünür. Tek yön sınanırsa, hepsini
/// engelli gösteren (ya da hepsini canlı gösteren) bir yüzey de geçerdi.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/copy_gate.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

LibraryFamily _batteryFamily(AppFacts f) =>
    f.ia.built.singleWhere((LibraryFamily x) => x.id == 'assessment_battery');

Future<void> _pumpBattery(WidgetTester tester, AppFacts f) async {
  await tester.pumpWidget(MaterialApp(
      home: FamilyPage(family: _batteryFamily(f), facts: f)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('türetim: 3 canlı · 9 engelli — sayılar TÜRETİLİR', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    // Pozitif kontrol: config GERÇEKTEN okundu mu? Boşsa aşağıdaki iki yön de
    // trivially geçerdi (L-183 vacuous-geçiş sınıfı).
    expect(f.liveness.length, 12,
        reason: 'batarya 12 test taşımalı, okunan: ${f.liveness.length}');
    expect(f.live.map((TestLiveness x) => x.testId).toList()..sort(),
        <String>['active_straight_leg_raise', 'deep_squat', 'overhead_reach'],
        reason: 'canlı küme köprüden TÜRETİLİR; değiştiyse köprü değişmiş '
            'olmalı (kMetricBindings) — burayı elle güncellemek türetimi '
            'yalana çevirir');
    expect(f.blocked, hasLength(9));

    for (final TestLiveness x in f.blocked) {
      expect(x.blocker, isNotNull);
      expect(x.blocker!.trim(), isNotEmpty,
          reason: '${x.testId} gerekçesiz engelli — L-135 ihlali');
    }
  });

  testWidgets('YÜZEY: canlı-3 canlı görünür VE engelli-9 isimli görünür', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pumpBattery(tester, factsFromDisk());

    // YÖN 1 — canlı testler yüzeyde (insan-okur ad, TestSpec.name'den TAŞINIR).
    expect(find.text('Overhead Reach'), findsOneWidget);
    expect(find.text('Deep Squat'), findsOneWidget);
    expect(find.text('Active Straight Leg Raise'), findsOneWidget);
    expect(find.textContaining('MEASURED BY CAMERA IN THIS BUILD (3)'),
        findsOneWidget);

    // YÖN 2 — engelli testler de yüzeyde, GEREKÇELİ.
    expect(find.textContaining('NOT MEASURED BY CAMERA (9)'), findsOneWidget);
    expect(
        find.textContaining('measurement engine', skipOffstage: false),
        findsWidgets,
        reason: 'engel gerekçesi yüzeyde görünmüyorsa "isimli engel" iddiası '
            'boş kalır');
  });

  testWidgets('engel gerekçesi DOĞRU ANATOMİYİ adlandırır (L-196 sınıfı)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    // ankle_dorsiflexion'ın metriği `tibia_inclination` — KAVAL KEMİĞİ.
    // Bir önceki turda bu gerekçe "gövde" diyordu ve ekran kanıtı yakaladı.
    // Artık iddia TESTLE de tutuluyor: gerekçe kaval kemiğini adlandırmalı ve
    // gövdeden BAHSETMEMELİ.
    final TestLiveness ankle = f.liveness
        .singleWhere((TestLiveness x) => x.testId == 'ankle_dorsiflexion');
    expect(ankle.blocker, contains('Shin angle'));
    expect(ankle.blocker!.toLowerCase(), isNot(contains('trunk')),
        reason: 'ankle_dorsiflexion gövdeyi ölçmüyor — yanlış anatomi geri '
            'geldi');

    // Karşıt yön: gövde metriği olan test GERÇEKTEN gövdeyi adlandırmalı.
    // (Tek yön sınanırsa "hiçbir gerekçede trunk geçmesin" gibi yanlış bir
    // kural da geçerdi.)
    final TestLiveness bend = f.liveness
        .singleWhere((TestLiveness x) => x.testId == 'lateral_bend');
    expect(bend.blocker!.toLowerCase(), contains('trunk'));
  });

  testWidgets('HAM METRİK ID yüzeye SIZMAZ (L-220 — ekran kanıtı yakaladı)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    // Sızabilecek TÜM id'ler config'ten TÜRETİLİR — elle yazılmış bir
    // "yasaklı kelimeler" listesi, yeni bir metrik eklendiğinde sessizce
    // bayatlardı.
    final Set<String> internalIds = <String>{
      ...f.battery.derivedMeasures.keys,
      ...kUnbridgedMetrics.keys,
      ...<String>['shoulder_flexion', 'knee_flexion', 'hip_flexion'],
    };
    expect(internalIds, isNotEmpty, reason: 'pozitif kontrol');

    for (final TestLiveness x in f.blocked) {
      for (final String id in internalIds) {
        expect(x.blocker!.contains(id), isFalse,
            reason: '${x.testId} gerekçesinde HAM METRİK ID var: «$id» — '
                'dahili sözlük kullanıcı yüzeyine ait değil. Bu tam olarak '
                '`plank_hold`da simülatörde görülen kusur.');
      }
      // Geliştirici jargonu da sızmaz.
      expect(x.blocker!.toLowerCase(), isNot(contains('not declared (')));
    }
  });

  testWidgets('FAZ-TÜREVLİ testler doğru sınıfla adlandırılır', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    // `hold_duration` config'te `derivedMeasures.source = phase` — geometri
    // DEĞİL. Türetim bunu config'ten okur, Dart'ta ikinci bir liste yok.
    expect(f.battery.derivedMeasures['hold_duration']?.isPhaseDerived, isTrue);

    for (final String id in <String>['plank_hold', 'single_leg_balance']) {
      final TestLiveness t =
          f.liveness.singleWhere((TestLiveness x) => x.testId == id);
      expect(t.blocker, contains('timed by the session'),
          reason: '$id faz-türevli bir büyüklük kullanıyor; gerekçe bunu '
              'söylemeli');
      // ⛔ "çalışmıyor" İDDİA EDİLMEZ — ölçülmedi.
      expect(t.blocker!.toLowerCase(), isNot(contains('does not work')));
    }
  });

  testWidgets('DÜRÜSTLÜK KUTUSU zorunlu — iki listesi de yüzeyde', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await _pumpBattery(tester, f);

    await scrollTo(tester, find.byKey(FamilyPage.honestyKey));
    expect(find.byKey(FamilyPage.honestyKey), findsOneWidget);
    expect(find.byKey(HonestyBoxCard.measuredKey), findsOneWidget);
    expect(find.byKey(HonestyBoxCard.notMeasuredKey), findsOneWidget);

    // Kutunun İÇERİĞİ config'ten TAŞINIR — widget'ın kendi metni değil.
    final HonestyBox box = _batteryFamily(f).honestyBox;
    expect(find.text(box.notMeasured.first, skipOffstage: false),
        findsOneWidget,
        reason: 'kutu var ama config metnini taşımıyorsa kutu bir dekordur');
  });

  testWidgets('kalıcı ölçüm-sınırı beyanı sayfada (uyum maddesi ⑱)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pumpBattery(tester, factsFromDisk());
    await scrollTo(tester, find.byKey(MeasurementLimitsFootnote.key_));
    expect(find.byKey(MeasurementLimitsFootnote.key_), findsOneWidget);
    // Marj SAYISI yok, marjın ÖLÇÜLMEDİĞİ beyanı var. Bir sayı belirirse
    // (ör. "±5°") o sayının bir ölçümü olmalı — bu kapı onu görünür yapar.
    expect(find.textContaining('±', skipOffstage: false), findsNothing,
        reason: 'kod tabanında ölçülmüş bir doğruluk marjı YOK; bir marj '
            'işareti belirdiyse uydurulmuş demektir (madde ⑫)');
  });

  testWidgets('VAAT DİLİ ve TEZAHÜRAT yok — "yet" dahil', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pumpBattery(tester, factsFromDisk());
    expectNoBannedCopy(tester);
  });

  testWidgets('inşa EDİLMEMİŞ aile: kurs listesi YOK, adlar VAR', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    final LibraryFamily yoga =
        f.ia.families.singleWhere((LibraryFamily x) => x.id == 'yoga_styles');

    await tester.pumpWidget(
        MaterialApp(home: FamilyPage(family: yoga, facts: f)));
    await tester.pumpAndSettle();

    // Adlar görünür (genişlik saklanmıyor)...
    expect(find.byKey(FamilyPage.namedChildrenKey), findsOneWidget);
    expect(find.text('Hatha', skipOffstage: false), findsOneWidget);
    // ...ama test listesi/kurs kartı YOK (sahte doluluk yasağı).
    expect(find.byKey(FamilyPage.liveListKey), findsNothing);
    expect(find.byKey(FamilyPage.blockedListKey), findsNothing);
    // Kutu burada da ZORUNLU.
    expect(find.byKey(FamilyPage.honestyKey), findsOneWidget);
    expectNoBannedCopy(tester);
  });

  testWidgets('"What Lissom doesn\'t do" — defter atfı SIZMAZ, dışlamalar VAR',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      home: WhatLissomDoesntDoScreen(
          items: f.ia.whyNot, excluded: f.battery.excluded),
    ));
    await tester.pumpAndSettle();

    // Ürün sınırları config'ten (5 kalem, elle yazılmış Dart ikizi SİLİNDİ).
    expect(f.ia.whyNot, hasLength(5));
    expect(find.byKey(WhatLissomDoesntDoScreen.boundariesKey), findsOneWidget);

    // Bağlanmamış dışlama KENDİ satırını alır — `cervical_rotation` daha önce
    // hiçbir yüzeyde görünmüyordu (L-219).
    await scrollTo(tester, find.byKey(WhatLissomDoesntDoScreen.excludedKey));
    expect(find.text('Cervical rotation'), findsOneWidget);

    // Ham id de defter atfı da SIZMAZ (L-223, ekran kanıtı yakaladı).
    expect(find.textContaining('cervical_rotation', skipOffstage: false),
        findsNothing);
    expectNoBannedCopy(tester);
    // Atıf config'te DURUYOR — silinmedi, yalnız yüzeyden çıkarıldı.
    expect(
        f.battery.excluded
            .every((ExcludedTest e) => (e.record ?? '').isNotEmpty),
        isTrue,
        reason: 'izlenebilirlik kaybolmamalı — atıf `record` alanında yaşar');
  });

  test('config asset olarak KAYITLI (yoksa canlı cihazda okunamaz)', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    for (final String path in <String>[
      'config/tests/lissom-assessment.v1.json',
      'config/ia/library.v1.json',
    ]) {
      final String dir = '${path.substring(0, path.lastIndexOf('/'))}/';
      expect(pubspec.contains(path) || pubspec.contains('- $dir'), isTrue,
          reason: 'asset kaydı olmadan `rootBundle` cihazda FIRLATIR — test '
              'dosyadan okuduğu için bunu yakalamaz, o yüzden ayrı iddia: '
              '$path');
      expect(File(path).existsSync(), isTrue);
      expect(jsonDecode(File(path).readAsStringSync()),
          isA<Map<String, dynamic>>());
    }
  });
}
