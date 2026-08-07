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
  testWidgets('KURAL: canlılık köprüden TÜRETİLİR — sayı DEĞİL, kural ölçülür',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    // ⚠️ **BU TEST BİR KEZ YENİDEN YAZILDI (L-239, JabLab aktarımı):**
    // *"Fazla geniş bir test, ürün DOĞRU genişlerken kırmızıya döner."*
    //
    // Eski hâli bugünün sayılarını çiviliyordu — `liveness.length == 12`,
    // canlı küme `['active_straight_leg_raise','deep_squat',
    // 'overhead_reach']`, `blocked hasLength(9)`. Köprü 8/19'dan büyüdüğü an
    // üçü de kırmızı yanardı: **bir şey bozulduğu için değil, İLERLEDİĞİ
    // için.** Ve düzeltme yolu "beklenen listeyi elle güncellemek" olurdu —
    // yani türetimi elle yazmak, testin kapatmaya çalıştığı hatanın ta
    // kendisi.
    //
    // Ölçülen şey artık bir DENKLİK: bir test canlıdır ⟺ birincil
    // metriklerinin HEPSİ köprüde. Bu kural köprü büyüse de küçülse de aynı
    // kalır.
    final Set<String> bridged =
        kMetricBindings.map((MetricBinding b) => b.lissomMetric).toSet();
    for (final TestLiveness x in f.liveness) {
      final bool shouldBeLive = x.metrics.every(bridged.contains);
      expect(x.isLive, shouldBeLive,
          reason: '${x.testId}: canlılık köprüyle uyuşmuyor — '
              'metrikler ${x.metrics}, köprüde ${x.metrics.where(bridged.contains)}');
    }

    // POZİTİF ÇAPA (iki yönlü): kural boş kümede de doğrudur. Hem canlı hem
    // engelli EN AZ BİR üye olmalı — yoksa yukarıdaki döngü hiçbir şey
    // kanıtlamaz (L-183).
    expect(f.live, isNotEmpty, reason: 'hiç canlı test yok — türetim ölmüş');
    expect(f.blocked, isNotEmpty,
        reason: 'hiç engelli test yok — ya köprü tamamlandı (o zaman bu satır '
            'ZAFERLE silinir) ya da türetim kırık');

    // Okuyucu hiçbir testi DÜŞÜRMÜYOR — sayı çivilemeden bütünlük kontrolü.
    final Map<String, dynamic> raw = jsonDecode(
        File('config/tests/lissom-assessment.v1.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(f.liveness.length, (raw['tests'] as List<dynamic>).length,
        reason: 'config\'te N test var ama türetim M üretti — okuyucu kayıt '
            'düşürüyor');

    for (final TestLiveness x in f.blocked) {
      expect(x.blocker, isNotNull);
      expect(x.blocker!.trim(), isNotEmpty,
          reason: '${x.testId} gerekçesiz engelli — L-135 ihlali');
    }
  });

  testWidgets('YÜZEY: canlı görünür VE engelli İSİMLİ görünür', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await _pumpBattery(tester, f);

    // YÖN 1 — canlı testlerin ADI yüzeyde. Ad listesi TÜRETİLİR: elle yazılmış
    // üç ad, köprü büyüyünce eksik kalırdı ve test yine de yeşil yanardı.
    for (final TestLiveness x in f.live) {
      expect(find.text(x.name, skipOffstage: false), findsOneWidget,
          reason: 'canlı test yüzeyde yok: ${x.name}');
    }
    // Başlıktaki SAYI da türetilir — "3" yazmak, ürün ilerleyince yalan olurdu.
    expect(
        find.textContaining(
            'MEASURED BY CAMERA IN THIS BUILD (${f.live.length})'),
        findsOneWidget);

    // YÖN 2 — engelli testler de yüzeyde, GEREKÇELİ.
    expect(
        find.textContaining('NOT MEASURED BY CAMERA (${f.blocked.length})'),
        findsOneWidget);
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

  test('TERS İKİZ: kapı fazla genişlerse canlı cümleler ölür (L-248)', () {
    // Cümleler DEPODAN türetilir — kopyalansalardı üründen ayrışır ve ikiz
    // var olmayan bir metni korurdu.
    final AppFacts f = factsFromDisk();
    final List<String> live = <String>[
      // whyNot sınırları — parantez içinde GERÇEK gerekçe taşıyorlar
      ...f.ia.whyNot.map((WhyNotItem w) => w.reason),
      // engel gerekçeleri — "not"/"does not" dolu ama ihlal DEĞİL
      ...f.blocked.map((TestLiveness x) => x.blocker!),
      // ölçülmüş dışlamalar
      ...f.battery.excluded.map((ExcludedTest e) => e.reason),
      // poz katmanlarının gerekçeleri
      ...f.ia.poseTiers
          .where((PoseTier t) => t.reason != null)
          .map((PoseTier t) => t.reason!),
    ];
    expectGateStaysNarrow(live);
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
          items: f.ia.whyNot,
          excluded: f.battery.excluded,
          poseTiers: f.ia.poseTiers),
    ));
    await tester.pumpAndSettle();

    // Ürün sınırları config'ten (5 kalem, elle yazılmış Dart ikizi SİLİNDİ).
    // Sayı DEĞİL kural: okuyucu hiçbir kalemi düşürmüyor (L-239).
    final Map<String, dynamic> rawIa = jsonDecode(
        File('config/ia/library.v1.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(
        f.ia.whyNot.length,
        ((rawIa['whyNotPage'] as Map<String, dynamic>)['items']
                as List<dynamic>)
            .length);
    expect(f.ia.whyNot, isNotEmpty, reason: 'pozitif çapa');
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
