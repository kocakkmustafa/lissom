import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/locale_text.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  String language, {
  double height = 6000,
}) async {
  pinTallSurface(tester, height: height);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'tr']) {
    final turkish = language == 'tr';
    final closed = turkish
        ? 'canlı kamera ölçümleri'
        : 'Live camera measurements';
    final closure = turkish ? 'kapalıdır' : 'closed in this release';
    for (final tab in ['Library', 'Progress', 'Profile']) {
      testWidgets('$tab agrees with the closed release camera ($language)', (
        tester,
      ) async {
        expect(
          motionPaidFeaturesAvailable,
          isFalse,
          reason: 'This copy is bound to the current closed release policy.',
        );
        final facts = factsFromDisk();
        final screen = switch (tab) {
          'Library' => LibraryScreen(facts: facts),
          'Progress' => ProgressScreen(facts: facts),
          _ => ProfileScreen(facts: facts),
        };
        await _pump(tester, screen, language);
        final messages = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data ?? '')
            .toList();
        expect(
          messages.any(
            (text) => text.contains(closed) && text.contains(closure),
          ),
          isTrue,
        );
        expect(
          messages.any(
            (text) => text.contains(
              turkish
                  ? 'canlı ölçüm başlatabilir'
                  : 'can start a live measurement',
            ),
          ),
          isFalse,
        );
        if (tab != 'Profile') {
          final note = find.descendant(
            of: find.byKey(CaptureUnavailableNote.key_),
            matching: find.byType(Text),
          );
          expect(note, findsOneWidget);
          expect(tester.widget<Text>(note).data!, contains(closure));
          expect(
            tester.widget<Text>(note).data!,
            contains(turkish ? 'kamera olmadan çalışır' : 'without a camera'),
          );
        }
        if (tab == 'Library') {
          final total = facts.battery.tests.length;
          expect(
            find.textContaining(
              turkish
                  ? '$total test · motorda ${facts.live.length} kamera ölçüm yolu'
                  : '$total tests · ${facts.live.length} camera measurement paths in the engine',
            ),
            findsOneWidget,
          );
          expect(
            messages.any(
              (text) => text.contains(
                turkish
                    ? 'kamerayla ölçülebiliyor'
                    : 'measurable by camera in this build',
              ),
            ),
            isFalse,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets(
      'battery inventory describes engine paths, not open capture ($language)',
      (tester) async {
        final AppFacts facts = factsFromDisk();
        final family = facts.ia.built.firstWhere(
          (family) => !family.teachingOnly,
        );
        expect(facts.live, isNotEmpty); // Exercise real, retained engine paths.
        await _pump(tester, FamilyPage(family: family, facts: facts), language);
        expect(find.byKey(FamilyPage.liveListKey), findsOneWidget);
        final heading = turkish
            ? 'Motordaki kamera ölçüm yolları (${facts.live.length})'
            : 'Camera measurement paths in the engine (${facts.live.length})';
        final oldHeading = turkish
            ? 'Bu sürümde kamerayla ölçülenler'
            : 'Measured by camera in this build';
        expect(find.text(heading.toUpperCase()), findsOneWidget);
        expect(find.textContaining(oldHeading.toUpperCase()), findsNothing);
        final note = find.descendant(
          of: find.byKey(CaptureUnavailableNote.key_),
          matching: find.byType(Text),
        );
        expect(note, findsOneWidget);
        expect(tester.widget<Text>(note).data!, contains(closure));
        expect(
          tester.getTopLeft(note).dy,
          lessThan(tester.getTopLeft(find.byKey(FamilyPage.liveListKey)).dy),
        );
        final honesty = find.byKey(FamilyPage.honestyKey);
        expect(
          find.descendant(
            of: honesty,
            matching: find.text(
              (turkish
                      ? 'Ölçüm motorunun kapsamı'
                      : 'Measurement engine coverage')
                  .toUpperCase(),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.text(
            (turkish ? 'Neyi ölçer?' : 'What this measures').toUpperCase(),
          ),
          findsNothing,
        );
        final footnote = find.byKey(MeasurementLimitsFootnote.key_);
        final context = find.descendant(
          of: footnote,
          matching: find.textContaining(
            turkish
                ? 'kamera ölçümü alındığında'
                : 'when a camera reading is taken',
          ),
        );
        expect(context, findsOneWidget);
        expect(tester.widget<Text>(context).data!, contains(closure));
        for (final test in facts.live) {
          expect(
            find.text(
              configText(tester.element(find.byType(FamilyPage)), test.name),
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'family camera closure is visible after Library navigation ($language)',
      (tester) async {
        final facts = factsFromDisk();
        final family = facts.ia.built.firstWhere(
          (family) => !family.teachingOnly,
        );
        await _pump(tester, LibraryScreen(facts: facts), language, height: 667);
        final entry = find.text(
          configText(tester.element(find.byType(LibraryScreen)), family.title),
        );
        await tester.ensureVisible(entry);
        await tester.tap(entry);
        await tester.pumpAndSettle();
        expect(find.byType(FamilyPage), findsOneWidget);
        final note = find.descendant(
          of: find.byKey(CaptureUnavailableNote.key_),
          matching: find.byType(Text),
        );
        expect(note, findsOneWidget);
        expect(tester.widget<Text>(note).data!, contains(closure));
        final screen = tester.getRect(find.byType(Scaffold).last);
        final noteRect = tester.getRect(note);
        expect(noteRect.top, greaterThanOrEqualTo(screen.top));
        expect(noteRect.bottom, lessThanOrEqualTo(screen.bottom));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
