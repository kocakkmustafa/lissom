import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/progress_screen.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

HathaCourse _course(String name) =>
    HathaCourse.parse(File('config/courses/$name.v1.json').readAsStringSync());

AppFacts _facts({bool allCourses = true, HathaProgress? progress}) {
  final base = factsFromDisk();
  return AppFacts(
    ia: base.ia,
    battery: base.battery,
    liveness: base.liveness,
    history: base.history,
    hatha: base.hatha,
    chairOffice: _course('chair-office'),
    vinyasa: allCourses ? _course('vinyasa-standing') : null,
    yin: allCourses ? _course('yin-supported') : null,
    hathaProgress: progress ?? base.hathaProgress,
  );
}

Future<void> _pump(WidgetTester tester, Widget screen, String language) async {
  pinTallSurface(tester, height: 6000);
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
    final lessonWord = turkish ? 'dersi' : 'lessons';

    testWidgets(
      'library inventory includes all four actual courses ($language)',
      (tester) async {
        final facts = _facts();
        await _pump(tester, LibraryScreen(facts: facts), language);
        final summary = find.textContaining(
          '${facts.hatha!.lessons.length} Hatha $lessonWord',
        );
        expect(summary, findsOneWidget);
        final text = tester.widget<Text>(summary).data!;
        expect(
          text,
          contains(
            '${facts.chairOffice!.lessons.length} '
            '${turkish ? 'sandalye / ofis' : 'chair / office'} $lessonWord',
          ),
        );
        expect(
          text,
          contains('${facts.vinyasa!.lessons.length} Vinyasa $lessonWord'),
        );
        expect(text, contains('${facts.yin!.lessons.length} Yin $lessonWord'));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('unavailable courses add no invented inventory ($language)', (
      tester,
    ) async {
      final facts = _facts(allCourses: false);
      await _pump(tester, LibraryScreen(facts: facts), language);
      final summary = find.textContaining(
        '${facts.hatha!.lessons.length} Hatha $lessonWord',
      );
      expect(summary, findsOneWidget);
      final text = tester.widget<Text>(summary).data!;
      expect(
        text,
        contains(
          '${facts.chairOffice!.lessons.length} '
          '${turkish ? 'sandalye / ofis' : 'chair / office'} $lessonWord',
        ),
      );
      expect(text, isNot(contains('Vinyasa')));
      expect(text, isNot(contains('Yin')));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Yin counts current units as self-recorded participation ($language)',
      (tester) async {
        final yin = _course('yin-supported');
        final hatha = _course('hatha');
        HathaPracticeRecord record(
          HathaCourse course,
          String lesson, {
          String? version,
        }) => HathaPracticeRecord(
          lessonId: lesson,
          courseId: course.id,
          courseVersion: version ?? course.version,
          practicedAt: DateTime.utc(2026, 10, 10),
        );
        final progress = HathaProgress(
          records: [
            record(yin, 'y01'),
            record(yin, 'y02'),
            record(yin, 'y01'), // Repeated records remain one unit.
            record(yin, 'y03', version: '0.0.0'),
            record(hatha, 'y04'), // A different course cannot count for Yin.
            record(hatha, 'h01'),
          ],
          unreadableRecords: 0,
        );
        final facts = _facts(progress: progress);
        await _pump(tester, ProgressScreen(facts: facts), language);
        final heading = find.text(
          turkish ? 'Yin katılımı' : 'Yin participation',
        );
        expect(heading, findsOneWidget);
        final card = find.ancestor(
          of: heading,
          matching: find.byType(LissomCard),
        );
        expect(card, findsOneWidget);
        final summary = find.descendant(
          of: card,
          matching: find.textContaining(
            turkish
                ? 'birimde katılım kaydı'
                : 'units with participation records',
          ),
        );
        expect(summary, findsOneWidget);
        final text = tester.widget<Text>(summary).data!;
        expect(text, startsWith('2/${yin.lessons.length} '));
        expect(text, contains(turkish ? 'öz kayıt' : 'self-recorded'));
        expect(
          text,
          contains(
            turkish
                ? 'fiziksel beceri gösterilmez'
                : 'physical skill is not established',
          ),
        );
        expect(
          text,
          isNot(contains(turkish ? 'ders çalışıldı' : 'lessons practised')),
        );
        // Existing module totals and another course's self-record count survive.
        expect(
          find.descendant(
            of: card,
            matching: find.text('2/${yin.modules.first.lessons.length}'),
          ),
          findsOneWidget,
        );
        final hathaCard = find.ancestor(
          of: find.text(turkish ? 'Hatha çalışması' : 'Hatha practice'),
          matching: find.byType(LissomCard),
        );
        expect(hathaCard, findsOneWidget);
        expect(
          find.descendant(
            of: hathaCard,
            matching: find.textContaining(
              '1/${hatha.lessons.length} ${turkish ? 'ders çalışıldı' : 'lessons practised'}',
            ),
          ),
          findsOneWidget,
        );
        expect(progress.oldVersionCount(yin), 1);
        expect(progress.records, hasLength(6));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
