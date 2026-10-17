import 'dart:io';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'support/facts_from_disk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapVisible(WidgetTester t, String key) async {
  final target = find.byKey(Key(key));
  if (target.hitTestable().evaluate().isEmpty) {
    await t.scrollUntilVisible(
      target,
      300,
      maxScrolls: 100,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await t.ensureVisible(target);
  await t.pumpAndSettle();
  expect(target.hitTestable(), findsOneWidget);
  await t.tap(target.hitTestable());
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

Future<void> mount(WidgetTester t, Widget home, String language) async {
  t.view.physicalSize = const Size(320, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: home,
    ),
  );
  await t.pumpAndSettle();
}

class Store implements HathaProgressStore {
  int reads = 0, writes = 0;
  @override
  Future<HathaProgress> read() async {
    reads++;
    return const HathaProgress(records: [], unreadableRecords: 0);
  }

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    writes++;
  }
}

void main() {
  for (final language in ['en', 'tr']) {
    testWidgets(
      '$language library recall reaches the five actual courses without practice writes at 320px/2x',
      (t) async {
        HathaCourse course(String file) => HathaCourse.parse(
          File('config/courses/$file.v1.json').readAsStringSync(),
        );
        final base = factsFromDisk();
        final courses = {
          'hatha': course('hatha'),
          'chair': course('chair-office'),
          'vinyasa': course('vinyasa-standing'),
          'yin': course('yin-supported'),
          'ashtanga': course('ashtanga-foundations'),
        };
        final facts = AppFacts(
          ia: base.ia,
          battery: base.battery,
          liveness: base.liveness,
          history: base.history,
          hatha: courses['hatha'],
          chairOffice: courses['chair'],
          vinyasa: courses['vinyasa'],
          yin: courses['yin'],
          ashtanga: courses['ashtanga'],
        );
        final store = Store();
        await mount(
          t,
          Scaffold(
            body: LibraryScreen(
              facts: facts,
              hathaStoreLoader: () async => store,
            ),
          ),
          language,
        );
        await tapVisible(t, 'study-review-entry');
        for (final entry in courses.entries) {
          final key = 'study-course-${entry.key}';
          final target = find.byKey(Key(key));
          await t.scrollUntilVisible(
            target,
            300,
            maxScrolls: 100,
            scrollable: find.byType(Scrollable).first,
          );
          final button = find.descendant(
            of: target,
            matching: find.byType(FilledButton),
          );
          await t.ensureVisible(button);
          await t.pumpAndSettle();
          await t.tap(button.hitTestable());
          await t.pumpAndSettle();
          expect(
            t
                .widget<HathaCourseScreen>(find.byType(HathaCourseScreen))
                .course
                .id,
            entry.value.id,
          );
          expect(store.writes, 0);
          await t.tap(find.byType(BackButton));
          await t.pumpAndSettle();
        }
        expect(store.reads, courses.length);
        expect(store.writes, 0);
        expect(t.takeException(), isNull);
      },
    );
  }
}
