/// **DAR EKRAN İÇERİK/YERLEŞİM KAPISI — 375×812.**
///
/// Altı yüzey normal süitte gerçek config ve geçmişle çizilir; içerik
/// çapasının erişilebilirliği ve Flutter yerleşim istisnaları sınanır.
/// Normal koşum piksel karşılaştırması veya yeni görüntü üretimi yapmaz.
/// Aşağıdaki opt-in bayrağı yalnız eski golden karşılaştırmasını açar.
///
/// Bu ailenin en pahalı dersi: *testler metnin VARLIĞINI sınar, DOĞRULUĞUNU
/// sınamaz.* 95 yeşil test, `ankle_dorsiflexion`ın gerekçesinde "gövde"
/// yazdığını göremedi; onu bir EKRAN yakaladı. O yüzden ekran kanıtı bir
/// kapıdır ve **en dar cihazda** alınır (L-214).
///
/// ## Neden simülatör değil, golden
///
/// ⚠️ **BU BÖLÜMDE BİR İDDİAM YANLIŞ ÇIKTI.** Önce *"bu makinede iPhone SE
/// cihaz tipi hiç yok"* yazmıştım — `simctl list devicetypes` çıktısını
/// KIRPMIŞTIM. SE 3. nesil hem cihaz tipi olarak var hem de
/// `Lissom-Narrow-StressTest` adıyla kurulu. Metin kanıt gibi duruyordu;
/// oysa eksik bir komut çıktısıydı.
///
/// Golden yine de değerli ve sebebi başka: **gerçek SE 375×667** iken bu
/// yüzey 375×812 — aynı genişlikte DAHA ÇOK içerik tek karede görünüyor.
/// Yani golden yapıyı, simülatör metni kanıtlıyor.
///
/// ## Bu kanıtın SINIRI — isimle
///
/// `google_fonts` `flutter_test` altında ağdan yazı tipi ÇEKEMEZ (aile
/// gotcha'sı), yani golden'lar **yedek yazı tipiyle** çizilir. Bu görüntüler
/// **yapıyı, içeriği ve taşmayı** kanıtlar; **tipografiyi KANITLAMAZ.**
/// Tipografi kanıtı ayrı bir simülatör turu ister — ya da yazı tiplerinin
/// pakete gömülmesi (aynı iş, uygulamanın çevrimdışı ilk açılışını da
/// düzeltir; lisans kararı olduğu için koordinatörde).
///
/// ## Nasıl koşulur
///
/// ```
/// LISSOM_SCREEN_EVIDENCE=1 flutter test test/screen_evidence_test.dart \
///   --update-goldens
/// ```
///
/// Bayraksız yapısal kontroller KOŞAR. Golden'lar makineden makineye piksel
/// farkı verir; karşılaştırma/görüntü güncellemesi elle tetiklenir ve ayrı
/// kanıttır. `--update-goldens` olmadan mevcut baseline ile karşılaştırılır.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

const String _out = '../docs/kanit';
final bool _goldensEnabled =
    Platform.environment['LISSOM_SCREEN_EVIDENCE'] == '1';

/// **DAR ve İSİMLİ bir bastırma.** `google_fonts` `allowRuntimeFetching:
/// false` altında paketlenmemiş her yazı tipi için fırlatıyor (bkz.
/// `flutter_test_config.dart` — bu bir test ayarı değil, ÜRETİMDEKİ bir
/// bulgunun testteki gölgesi, L-218).
///
/// Bastırma **yalnız o istisnayı** yutar: mesajı `allowRuntimeFetching`
/// içermeyen her istisna YENİDEN FIRLATILIR. Genel bir `takeException()`
/// döngüsü, aradığımız gerçek yerleşim hatalarını da sessizce yerdi — ve bir
/// kanıt üreticisinin kanıtladığı şeyi yutması, kanıtı değersiz kılar.
void _drainKnownFontExceptions(WidgetTester tester) {
  while (true) {
    final Object? e = tester.takeException();
    if (e == null) return;
    if (!'$e'.contains('allowRuntimeFetching')) {
      throw StateError('kanıt turunda BEKLENMEYEN istisna: $e');
    }
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  _drainKnownFontExceptions(tester);
}

Future<void> _shot(WidgetTester tester, Widget body, String name) async {
  await tester.pumpWidget(MaterialApp(theme: buildLissomTheme(), home: body));
  await _settle(tester);
  expect(find.byType(MaterialApp), findsOneWidget);
  if (_goldensEnabled) {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$_out/$name.png'),
    );
  }
  _drainKnownFontExceptions(tester);
}

Future<void> _contentAnchor(WidgetTester tester, Key key) async {
  final Finder anchor = find.byKey(key);
  await scrollTo(tester, anchor);
  expect(anchor, findsOneWidget);
  _drainKnownFontExceptions(tester);
}

void main() {
  final AppFacts facts = factsFromDisk(
    history: SessionHistoryView.ok(<SessionRecord>[
      recordOf(lessonId: 'overhead_reach', lessonClass: 'measurementOnly'),
      recordOf(
        lessonId: 'ankle_dorsiflexion:left',
        lessonClass: 'notMeasured',
        at: DateTime.utc(2026, 7, 28),
        unmeasuredUnits: 1,
        unmeasuredReason: 'lowConfidence',
      ),
    ]),
  );

  testWidgets('kanıt · kabuk + home', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _shot(
      tester,
      LissomShell(loader: () async => facts),
      'ia-375pt-home-2026-08-07',
    );
    await _contentAnchor(tester, HomeScreen.hathaCourseKey);
    expect(find.byType(LissomShell), findsOneWidget);
  });

  testWidgets('kanıt · library', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _shot(
      tester,
      Scaffold(body: LibraryScreen(facts: facts)),
      'ia-375pt-library-2026-08-07',
    );
    await _contentAnchor(tester, LibraryScreen.builtSectionKey);
    expect(facts.ia.built, isNotEmpty);
  });

  testWidgets('kanıt · progress (kıyas kapalı)', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _shot(
      tester,
      Scaffold(body: ProgressScreen(facts: facts)),
      'ia-375pt-progress-2026-08-07',
    );
    await _contentAnchor(tester, ProgressScreen.comparisonNoticeKey);
    await _contentAnchor(tester, ProgressScreen.ledgerKey);
    expect(facts.history.records, hasLength(2));
  });

  testWidgets('kanıt · profile', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _shot(
      tester,
      Scaffold(body: ProfileScreen(facts: facts)),
      'ia-375pt-profile-2026-08-07',
    );
    await _contentAnchor(tester, ProfileScreen.whyNotEntryKey);
  });

  testWidgets('kanıt · batarya aile sayfası (engelli gerekçeler)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final LibraryFamily fam = facts.ia.built.firstWhere(
      (LibraryFamily family) => !family.teachingOnly,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: FamilyPage(family: fam, facts: facts),
      ),
    );
    await _settle(tester);
    // Engelli listesine KADAR kaydır — yanlış anatomi tam orada yakalanmıştı.
    await scrollTo(tester, find.byKey(FamilyPage.blockedListKey));
    _drainKnownFontExceptions(tester);
    expect(find.byKey(FamilyPage.blockedListKey), findsOneWidget);
    expect(facts.blocked, isNotEmpty);
    if (_goldensEnabled) {
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('$_out/ia-375pt-battery-blockers-2026-08-07.png'),
      );
    }
    _drainKnownFontExceptions(tester);
  });

  testWidgets('kanıt · what Lissom doesn\'t do (dışlananlar dahil)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _shot(
      tester,
      WhatLissomDoesntDoScreen(
        items: facts.ia.whyNot,
        excluded: facts.battery.excluded,
        poseTiers: facts.ia.poseTiers,
      ),
      'ia-375pt-what-lissom-doesnt-do-2026-08-07',
    );
    await _contentAnchor(tester, WhatLissomDoesntDoScreen.boundariesKey);
    await _contentAnchor(tester, WhatLissomDoesntDoScreen.excludedKey);
  });
}
