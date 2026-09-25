/// Test detay sayfası — SON DEĞER + trend (D13/F2).
///
/// Bu dosyanın en önemli tek satırı `mixed_provenance` testi DEĞİL, **dil**
/// testi: gerçek bir MDC verisi yokken bu ekran "gelişme"/"kötüleşme" iddia
/// EDEMEZ (orkestratör hükmü, `D12`). Ham değer + tarih, o kadar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/test_detail_screen.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Testte ELLE kurulan bir depo — gerçek `JsonlAttemptValueStore`ın diskle
/// ilişkisi `attempt_values_test.dart`ta ayrıca sınanıyor (aynı iddiayı iki
/// yerde bakmak olurdu). Burada ölçülen ekranın DAVRANIŞI.
final class _FakeStore implements AttemptValueStore {
  _FakeStore(this.entries);
  final List<AttemptValue> entries;
  int unreadable = 0;

  @override
  Future<void> append(AttemptValue value) async => entries.add(value);
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async {
    final List<AttemptValue> out =
        entries.where((AttemptValue v) => v.lessonId == lessonId).toList();
    out.sort((AttemptValue a, AttemptValue b) =>
        b.completedAt.compareTo(a.completedAt));
    return out;
  }

  @override
  Future<int> unreadableRecords() async => unreadable;
}

final class _FailingStore implements AttemptValueStore {
  @override
  Future<void> append(AttemptValue value) async {}
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async =>
      throw const FormatException('disk hatası (test)');
  @override
  Future<int> unreadableRecords() async => 0;
}

AttemptValue _v(String lessonId, double value, DateTime at,
        {String model = 'pose_landmarker_full'}) =>
    AttemptValue(
      lessonId: lessonId,
      completedAt: at,
      value: value,
      unit: 'deg',
      tier: 'measuredBelowRange',
      provenance: <String, String>{'model': model},
    );

TestSpec _overheadReach() =>
    batteryFromDisk().tests['overhead_reach']!;

Future<void> _pump(WidgetTester tester, TestSpec test,
    Future<AttemptValueStore> Function() loader, {Locale? locale}) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: buildLissomTheme(),
    home: TestDetailScreen(test: test, attemptValueStoreLoader: loader),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('SON DEĞER: en yeni okuma başlıkta, birimiyle birlikte',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 140, DateTime.utc(2026, 8, 1)),
      _v('overhead_reach:right', 147.5, DateTime.utc(2026, 8, 14)),
    ]);
    await _pump(tester, _overheadReach(), () async => store);

    // `findsWidgets` — 147.5 hem başlıkta HEM de tam listenin ilk satırında
    // görünür; bu KASITLI (liste "her okuma", başlık yalnız SONuncusu).
    expect(find.textContaining('147.5deg'), findsWidgets,
        reason: 'SON (en yeni tarihli) değer görünmeli — 140 değil');
    expect(find.textContaining('14 Aug 2026'), findsWidgets,
        reason: 'mutlak tarih — göreli süre DEĞİL (§5.2)');
  });

  testWidgets('H-24 ASİMETRİSİ: DOLU hâl de kendi sınırını söylüyor — '
      'yalnız boş/okunamayan hâl değil', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 147.5, DateTime.utc(2026, 8, 14)),
    ]);
    await _pump(tester, _overheadReach(), () async => store);

    expect(find.textContaining('not compared or judged'), findsOneWidget,
        reason: 'boş/okunamayan hâller kendini tam açıklıyor; dolu hâl de '
            'öyle olmalı — aksi H-24nin tam sınıfı (dürüstlük yalnız '
            'başarısızlıkta konuşur)');
  });

  testWidgets('TREND: hem yeni hem eski değer listede, İKİSİ de',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 140, DateTime.utc(2026, 8, 1)),
      _v('overhead_reach:right', 147.5, DateTime.utc(2026, 8, 14)),
    ]);
    await _pump(tester, _overheadReach(), () async => store);

    expect(find.textContaining('140deg'), findsWidgets,
        reason: 'eski okuma listede kaybolmamalı — bu SON DEĞER değil TREND');
    expect(find.textContaining('147.5deg'), findsWidgets);
  });

  testWidgets(
      'DÜRÜSTLÜK: hiçbir "gelişme/kötüleşme" dili YOK — gerçek MDC verisi yok',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    // Bilerek BÜYÜK bir fark (140→170): bir eşik-dayanaklı ekran burada
    // "improved"/"+30" yazma isteğine en çok kapılacağı yerde sınanır.
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 140, DateTime.utc(2026, 8, 1)),
      _v('overhead_reach:right', 170, DateTime.utc(2026, 8, 14)),
    ]);
    await _pump(tester, _overheadReach(), () async => store);

    final Iterable<String> onScreen = tester
        .widgetList<Text>(find.byType(Text))
        .map((Text w) => w.data ?? '')
        .where((String s) => s.isNotEmpty);
    for (final String s in onScreen) {
      final String low = s.toLowerCase();
      for (final String banned in <String>[
        'improve', 'better', 'worse', 'declin', 'progress', 'change of',
        '+30', '+21%',
      ]) {
        expect(low.contains(banned), isFalse,
            reason: 'karşılaştırma/gelişme dili sızdı («$s» içinde '
                '"$banned"): gerçek MDC verisi yokken bu bir uydurma iddia '
                'olurdu (orkestratör hükmü, D12)');
      }
    }
  });

  testWidgets('BOŞ HÂL: hiç okuma yoksa adıyla söylenir, "0" sessizce değil',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _pump(tester, _overheadReach(), () async => _FakeStore(<AttemptValue>[]));

    expect(find.byKey(TestDetailScreen.emptyKey), findsOneWidget);
    expect(find.textContaining('No readings recorded'), findsOneWidget);
    expect(find.textContaining('value and date'), findsOneWidget);
    expect(find.textContaining('conditions'), findsNothing);
  });

  testWidgets('Türkçe boş test ayrıntısı yalnız gösterilen alanları söyler',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _pump(tester, _overheadReach(),
        () async => _FakeStore(<AttemptValue>[]), locale: const Locale('tr'));

    expect(find.byKey(TestDetailScreen.emptyKey), findsOneWidget);
    expect(find.textContaining('değer ve tarih'), findsOneWidget);
    expect(find.textContaining('koşullar'), findsNothing);
  });

  testWidgets('OKUNAMAYAN: depo patlarsa "hiç yok" DEMEZ, çökmez',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _pump(tester, _overheadReach(), () async => _FailingStore());

    expect(find.byKey(TestDetailScreen.unavailableKey), findsOneWidget,
        reason: '"hiç ölçmedin" ile "okuyamıyoruz" karıştırılamaz '
            '(C-280/H-13 sınıfı)');
    expect(find.byKey(TestDetailScreen.emptyKey), findsNothing);
  });

  testWidgets('Türkçe test geçmişi ham depo hatasını göstermiyor',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _pump(tester, _overheadReach(), () async => _FailingStore(),
        locale: const Locale('tr'));

    expect(find.byKey(TestDetailScreen.unavailableKey), findsOneWidget);
    expect(find.textContaining('Uygulamayı yeniden açıp'), findsOneWidget);
    expect(find.textContaining('FormatException'), findsNothing);
    expect(find.textContaining('disk hatası (test)'), findsNothing);
  });

  testWidgets('PER-SIDE: sağ dolu, sol boş — İKİSİ de AYRI görünür, '
      'ortalanmaz', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    expect(_overheadReach().perSide, isTrue,
        reason: 'çapa — bu test gerçekten perSide değilse aşağıki iddia '
            'anlamsız');
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 150, DateTime.utc(2026, 8, 14)),
    ]);
    await _pump(tester, _overheadReach(), () async => store);

    expect(find.textContaining('150deg'), findsWidgets,
        reason: 'sağ taraf gösterilmeli');
    expect(find.textContaining('Left'), findsWidgets,
        reason: 'sol taraf SESSİZCE atlanmamalı — sıfır okuması adıyla '
            'söylenmeli, tek seride sağla ORTALANMAMALI');
  });

  testWidgets('OKUNAMAYAN SAYISI: partial durumda sayı adıyla, gizlenmez',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _FakeStore store = _FakeStore(<AttemptValue>[
      _v('overhead_reach:right', 150, DateTime.utc(2026, 8, 14)),
    ])
      ..unreadable = 2;
    await _pump(tester, _overheadReach(), () async => store);

    expect(find.textContaining('2 recorded reading'), findsOneWidget,
        reason: 'okunamayan kayıt sayısı M-F-228 sınıfı — sessiz kayıp '
            'yasak, veri VARKEN de');
  });
}
