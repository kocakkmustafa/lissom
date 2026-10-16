import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';

import 'support/facts_from_disk.dart';

class _Store implements HathaProgressStore {
  bool failRead = false;
  int writes = 0;
  Completer<void>? saveGate;

  @override
  Future<HathaProgress> read() async {
    if (failRead) throw const FileSystemException('injected read failure');
    return const HathaProgress(records: [], unreadableRecords: 0);
  }

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    writes++;
    await saveGate?.future;
  }
}

final _entries = <String, List<String>>{
  'hatha': ['Open Hatha course', 'Hatha kursunu aç'],
  'chair-office': ['Open chair / office path', 'Sandalye / ofis yolunu aç'],
  'vinyasa-standing': [
    'Open supported standing Vinyasa',
    'Destekli ayakta Vinyasa yolunu aç',
  ],
  'yin-supported': ['Open supported Yin', 'Destekli Yin yolunu aç'],
};

AppFacts _facts() {
  final base = factsFromDisk();
  HathaCourse course(String name) => HathaCourse.parse(
    File('config/courses/$name.v1.json').readAsStringSync(),
  );
  return AppFacts(
    ia: base.ia,
    battery: base.battery,
    liveness: base.liveness,
    history: base.history,
    hatha: base.hatha,
    chairOffice: course('chair-office'),
    vinyasa: course('vinyasa-standing'),
    yin: course('yin-supported'),
    hathaProgress: base.hathaProgress,
  );
}

Future<void> _pump(
  WidgetTester tester,
  String language,
  Future<HathaProgressStore> Function() loader,
) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final facts = _facts();
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: FamilyPage(
        family: facts.ia.built.firstWhere((f) => f.teachingOnly),
        facts: facts,
        hathaStoreLoader: loader,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Finder> _entry(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.scrollUntilVisible(button, 250);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  return button;
}

void main() {
  for (final language in ['en', 'tr']) {
    for (final entry in _entries.entries) {
      for (final failure in ['open', 'read']) {
        testWidgets('${entry.key} $failure failure retries at 320px/2x $language', (
          tester,
        ) async {
          final store = _Store();
          var attempts = 0;
          await _pump(tester, language, () async {
            attempts++;
            if (attempts == 1 && failure == 'open') {
              throw const FileSystemException('injected open failure');
            }
            store.failRead = attempts == 1 && failure == 'read';
            return store;
          });
          final label = entry.value[language == 'tr' ? 1 : 0];
          await tester.tap(await _entry(tester, label));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final message = find.text(
            language == 'tr'
                ? 'Çalışma kaydın açılamadı. Yeniden denemek için kurs düğmesine dokun.'
                : 'Your practice record could not be opened. Tap the course button to try again.',
          );
          await tester.ensureVisible(message);
          await tester.pumpAndSettle();
          expect(message, findsOneWidget);
          expect(find.byType(HathaCourseScreen), findsNothing);
          await tester.tap(await _entry(tester, label));
          await tester.pumpAndSettle();
          expect(attempts, 2);
          expect(find.byType(HathaCourseScreen), findsOneWidget);
          final opened = tester.widget<HathaCourseScreen>(
            find.byType(HathaCourseScreen),
          );
          expect(
            opened.course.id,
            HathaCourse.parse(
              File('config/courses/${entry.key}.v1.json').readAsStringSync(),
            ).id,
          );
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          expect(message, findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('pending entry opens a single course on repeated taps', (
    tester,
  ) async {
    final gate = Completer<HathaProgressStore>();
    var attempts = 0;
    await _pump(tester, 'en', () {
      attempts++;
      return gate.future;
    });
    final button = await _entry(tester, _entries['hatha']!.first);
    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();
    expect(attempts, 1);
    gate.complete(_Store());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during entry load cannot open a late course', (
    tester,
  ) async {
    final gate = Completer<HathaProgressStore>();
    await _pump(tester, 'en', () => gate.future);
    await tester.tap(await _entry(tester, _entries['hatha']!.first));
    await tester.pumpWidget(const MaterialApp(home: Text('Left library')));
    gate.complete(_Store());
    await tester.pumpAndSettle();
    expect(find.byType(HathaCourseScreen), findsNothing);
    expect(find.text('Left library'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('repeated save taps write once and return to the course', (
    tester,
  ) async {
    final store = _Store()..saveGate = Completer<void>();
    await _pump(tester, 'en', () async => store);
    await tester.tap(await _entry(tester, _entries['hatha']!.first));
    await tester.pumpAndSettle();
    final continueButton = find.byKey(HathaCourseScreen.continueKey);
    await tester.scrollUntilVisible(continueButton, 250);
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    final reflection = find.byKey(HathaLessonScreen.reflectionKey);
    await tester.scrollUntilVisible(
      reflection,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(reflection);
    await tester.pumpAndSettle();
    await tester.tap(reflection);
    await tester.pumpAndSettle();
    final save = find.byKey(HathaLessonScreen.practiceKey);
    await tester.scrollUntilVisible(
      save,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.tap(save);
    await tester.pump();
    final writes = store.writes;
    store.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(writes, 1);
    expect(find.byType(HathaLessonScreen), findsNothing);
    expect(find.byType(HathaCourseScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
