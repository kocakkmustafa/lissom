/// Home kapısı — dört bölüm, üç geçmiş hâli, **geri sayım estetiği YOK.**
///
/// §5.2 hükmünün sınanabilir hâli: `retest_countdown` bir DAVET olmalı. Bir
/// davetin sınanabilir imzası, geri sayımın imzasının YOKLUĞUDUR — gün
/// sayısı, "kaldı/kaçırdın/gecikti" dili, aciliyet işareti. Bunların hepsi
/// burada aranır ve BULUNMAMALIDIR.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:motion_core/motion_core.dart';

import 'support/copy_gate.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  Future<void> pump(WidgetTester tester, AppFacts f) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: Scaffold(
          body: HomeScreen(facts: f, onOpenLibrary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('IA config\'in DÖRT bölümü de yüzeyde ve SIRASI config\'ten', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await pump(tester, f);

    // Pozitif kontrol: config gerçekten dört bölüm mü beyan ediyor?
    expect(f.ia.homeSections.map((HomeSection s) => s.id).toList(), <String>[
      'today',
      'retest_countdown',
      'continue',
      'quick_start',
    ]);

    for (final Key k in <Key>[
      HomeScreen.todayKey,
      HomeScreen.retestKey,
      HomeScreen.continueKey,
      HomeScreen.quickStartKey,
    ]) {
      await scrollTo(tester, find.byKey(k));
      expect(find.byKey(k), findsOneWidget);
    }
  });

  testWidgets('GERİ SAYIM ESTETİĞİ YOK — vade, suçlama, aciliyet aranır', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      factsFromDisk(
        history: SessionHistoryView.ok(<SessionRecord>[
          recordOf(lessonId: 'overhead_reach', lessonClass: 'measurementOnly'),
        ]),
      ),
    );
    await scrollTo(tester, find.byKey(HomeScreen.retestKey));

    final Iterable<String> copy = tester
        .widgetList<Text>(find.byType(Text, skipOffstage: false))
        .map((Text w) => (w.data ?? '').toLowerCase());

    for (final String banned in <String>[
      'days left',
      'days to go',
      'overdue',
      'you missed',
      'missed',
      'late',
      'due',
      'streak',
      'reminder',
    ]) {
      expect(
        copy.any((String s) => s.contains(banned)),
        isFalse,
        reason:
            'geri sayım/suçlama dili: «$banned» — §5.2 hükmü DAVET '
            'diyor, vade değil',
      );
    }

    // Pozitif yön: kart GERÇEKTEN bir şey söylüyor (yokluk testi tek başına,
    // ekran boşsa da geçerdi — L-183).
    //
    // ⚠️ Çapa değişti (L-242): eskiden *"when you are ready"* arıyordu, ama o
    // cümle YAPILAMAYAN bir eyleme davetti — kullanıcı ölçüm başlatamıyor.
    // Yayın envanteri onu "fazla" olarak işaretledi ve kaldırıldı.
    expect(
      find.textContaining('Your last measurement', skipOffstage: false),
      findsWidgets,
    );
  });

  testWidgets('geçmiş AÇILAMADIYSA tarih ve sayı GÖSTERİLMEZ', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      factsFromDisk(
        history: const SessionHistoryView.unavailable(
          'PathNotFoundException: /private/history/session-token',
        ),
      ),
    );
    await scrollTo(tester, find.byKey(HomeScreen.retestKey));

    // "Hiç yapmadın" ≠ "bilmiyorum": boş liste burada bilgi DEĞİL.
    expect(find.textContaining("couldn't open your history"), findsOneWidget);
    expect(
      find.textContaining('Nothing has been measured'),
      findsNothing,
      reason:
          'depo açılmadığında yokluk iddiası edilemez — kullanıcının '
          'ölçümleri orada olabilir',
    );
    // Sebep yutulmaz ama HAM istisna/OS yolu gösterilmez: kullanıcıya güvenli
    // bir sonraki adım söylenir (progress ekranıyla aynı gizlilik sözleşmesi).
    expect(
      find.text('Reopen Lissom and check your records again.'),
      findsOneWidget,
    );
    expect(find.textContaining('PathNotFoundException'), findsNothing);
    expect(find.textContaining('/private/history'), findsNothing);
    expect(find.textContaining('session-token'), findsNothing);
  });

  testWidgets('BOZUK kayıt varsa sayı ALT SINIR olduğu SÖYLENİR (M-F-228)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      factsFromDisk(
        history: SessionHistoryView.partial(<SessionRecord>[
          recordOf(lessonId: 'deep_squat', lessonClass: 'measurementOnly'),
        ], 7),
      ),
    );
    await scrollTo(tester, find.byKey(HomeScreen.retestKey));
    expect(
      find.textContaining('7 stored records could not be read'),
      findsOneWidget,
    );
    expect(find.textContaining('floor, not a total'), findsOneWidget);
  });

  testWidgets('ilk sürüm ölçümü başlatmaz, kataloğu açık tutar', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: Scaffold(
          body: HomeScreen(facts: factsFromDisk(), onOpenLibrary: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Camera assessments and subscriptions are not open'),
      findsOneWidget,
    );
    await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
    expect(find.byKey(HomeScreen.startMeasurementKey), findsNothing);
    expect(find.text('See what each test measures'), findsOneWidget);
  });

  testWidgets('quick start ÖLÜ BUTON içermez — "Start a measurement" GERÇEKTEN '
      'LiveCaptureScreen\'e gider (2026-08-12, kamera-kabuğu sevki)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts facts = factsFromDisk();
    bool opened = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: Scaffold(
          body: HomeScreen(
            facts: facts,
            onOpenLibrary: () => opened = true,
            measurementAvailable: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));

    // ⚠️ Bu testin ÖNCEKİ hâli tam tersini iddia ediyordu: "Start" düğmesi
    // YOK, çünkü canlı-tur ekranı yoktu. `LiveCaptureScreen` bağlanınca o
    // iddia YALANA döndü — koordinatörün "bugün doğru olan bir dürüstlük
    // metni bir sonraki commit'le yalana dönebilir" dediği sınıfın testler
    // içindeki hâli. Bu satır o dönüşün kaydı.
    expect(
      facts.live,
      isNotEmpty,
      reason:
          'gerçek config canlı test taşımıyorsa bu test hiçbir şey '
          'kanıtlamaz — POZİTİF ÇAPA',
    );
    expect(find.byKey(HomeScreen.startMeasurementKey), findsOneWidget);

    await tester.tap(find.byKey(HomeScreen.startMeasurementKey));
    await tester.pumpAndSettle();
    expect(
      find.byType(LiveCaptureScreen),
      findsOneWidget,
      reason:
          'düğme GERÇEKTEN canlı ölçüm ekranına gitmeli — ölü buton '
          'sınıfının tam tersi',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('See what each test measures'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  testWidgets('paid access denied leaves live measurement closed', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    int guardCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: Scaffold(
          body: HomeScreen(
            facts: factsFromDisk(),
            onOpenLibrary: () {},
            measurementAvailable: true,
            beforeMeasurement: (_) async {
              guardCalls++;
              return false;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
    await tester.tap(find.byKey(HomeScreen.startMeasurementKey));
    await tester.pumpAndSettle();

    expect(guardCalls, 1);
    expect(find.byType(LiveCaptureScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('yasaklı yüzey kopyası yok (üç geçmiş hâlinde de)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    for (final SessionHistoryView h in <SessionHistoryView>[
      const SessionHistoryView.ok(<SessionRecord>[]),
      const SessionHistoryView.unavailable('boom'),
      SessionHistoryView.partial(<SessionRecord>[
        recordOf(
          lessonId: 'ankle_dorsiflexion:left',
          lessonClass: 'notMeasured',
          unmeasuredUnits: 1,
          unmeasuredReason: 'lowConfidence',
        ),
      ], 2),
    ]) {
      await pump(tester, factsFromDisk(history: h));
      expectNoBannedCopy(tester);
    }
  });
}
