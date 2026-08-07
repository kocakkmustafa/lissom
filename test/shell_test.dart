/// Dört sekmeli kabuk kapısı.
///
/// En önemli iddia: **sekme kümesi config ile kod arasında SESSİZCE
/// ayrışamaz.** Bilinen sekmeleri gösterip bilinmeyeni atlayan bir kabuk,
/// ailenin 4. dersinin canlı örneği olurdu: config'e eklenen bir sekme hiç
/// görünmez, hiçbir test kırmızıya dönmez, kimse fark etmez.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';

import 'support/copy_gate.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

Future<void> _pump(WidgetTester tester, Future<AppFacts> Function() loader) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LissomShell(loader: loader),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dört sekme config\'ten TÜRETİLİR ve dördü de yüzeyde', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await _pump(tester, () async => f);

    // Pozitif kontrol: config gerçekten dört sekme beyan ediyor mu?
    expect(f.ia.tabs, <String>['home', 'library', 'progress', 'profile']);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
        hasLength(4));
    for (final String label in <String>[
      'Home',
      'Library',
      'Progress',
      'Profile',
    ]) {
      expect(find.text(label), findsOneWidget,
          reason: 'sekme etiketi id\'den TÜRETİLİR; eksikse türetim kırık');
    }
    expect(find.byType(HomeScreen), findsOneWidget,
        reason: 'açılış sekmesi home olmalı');
  });

  testWidgets('sekme değişimi GERÇEKTEN ekran değiştirir', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pump(tester, () async => factsFromDisk());

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(find.byType(ProgressScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('AYRIŞMA KAPISI: config beşinci sekme derse kabuk SÖYLER', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts base = factsFromDisk();
    final AppFacts drifted = AppFacts(
      ia: LibraryIa(
        tabs: <String>[...base.ia.tabs, 'coach'],
        homeSections: base.ia.homeSections,
        families: base.ia.families,
        whyNot: base.ia.whyNot,
        poseTiers: base.ia.poseTiers,
        navigation: base.ia.navigation,
      ),
      battery: base.battery,
      liveness: base.liveness,
      history: base.history,
    );
    await _pump(tester, () async => drifted);

    // Sessizce dört sekme GÖSTERMEZ — farkı basar, iki kümeyi de adıyla.
    expect(find.byType(NavigationBar), findsNothing);
    // İKİ kümeyi de basar: config'in dediği (fazladan `coach` ile) ve kodun
    // uyguladığı. Yalnız birini basmak, farkın hangi tarafta olduğunu
    // gizlerdi.
    expect(find.textContaining('coach'), findsOneWidget);
    expect(find.textContaining('This build implements:'), findsOneWidget);
    expect(find.textContaining('Layout file declares:'), findsOneWidget);
  });

  testWidgets('ÇIKMAZ-SOKAK YASAĞI: config patlasa da ekran AÇILIR ve söyler', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pump(tester,
        () async => throw const FormatException('bozuk ia config'));
    expect(find.text("Lissom couldn't start"), findsOneWidget);
    expect(find.textContaining('bozuk ia config'), findsOneWidget,
        reason: 'sebep YUTULMAZ — kullanıcı neyin patladığını görür');
  });

  testWidgets('dört sekmenin HİÇBİRİNDE yasaklı yüzey kopyası yok', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await _pump(tester, () async => factsFromDisk());
    for (final String tab in <String>['Home', 'Library', 'Progress', 'Profile']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expectNoBannedCopy(tester);
    }
  });
}
