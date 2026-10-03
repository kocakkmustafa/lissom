import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/camera_pose_source.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

final class _ControlledSource implements StartablePoseSource {
  // Deliberately permits late events after dispose: the screen must reject
  // queued native callbacks without relying on a cooperative source.
  final StreamController<PoseSourceEvent> controller =
      StreamController<PoseSourceEvent>.broadcast(sync: true);
  int starts = 0;
  int disposals = 0;

  @override
  Stream<PoseSourceEvent> events() => controller.stream;

  @override
  Future<void> start() async => starts++;

  @override
  Future<void> dispose() async => disposals++;

  void emitAttempt() {
    for (int i = 0; i <= 12; i++) {
      controller.add(
        SourceFrameEvent(
          PoseFrame(
            tUs: i * 100000,
            landmarks: List<PoseLandmark>.generate(33, (int index) {
              return switch (index) {
                12 => const PoseLandmark(0.5, 0.35, 0, 1),
                14 => const PoseLandmark(0.5, 0.15, 0, 1),
                24 => const PoseLandmark(0.5, 0.60, 0, 1),
                _ => const PoseLandmark(0.5, 0.5, 0, 1),
              };
            }),
          ),
          size: const FrameSize(1080, 1920),
        ),
      );
    }
  }
}

final class _History implements SessionStore {
  final List<SessionRecord> records = <SessionRecord>[];
  Completer<void>? gate;
  @override
  Future<void> append(SessionRecord record) async {
    await gate?.future;
    records.add(record);
  }

  @override
  Future<List<SessionRecord>> recent({int? limit}) async => records;
  @override
  Future<int> unreadableRecords() async => 0;
  @override
  Future<int> workedSecondsFor(String lessonId) async => 0;
}

final class _Values implements AttemptValueStore {
  final List<AttemptValue> records = <AttemptValue>[];
  @override
  Future<void> append(AttemptValue value) async => records.add(value);
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async => records;
  @override
  Future<int> unreadableRecords() async => 0;
}

TestSpec _testSpec() => Battery.parseJson('''
{
  "id": "test", "version": "1",
  "tests": [{
    "id": "overhead_reach", "perSide": true, "holdSeconds": 2,
    "primaryMetric": "shoulder_flexion_{side}",
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": true,
      "bands": {"x": {"low": 100}}, "source": "Test fixture only"
    },
    "movementPresence": {
      "metric": "shoulder_flexion_{side}", "op": "gte", "value": 140
    }
  }]
}
''').tests['overhead_reach']!;

Future<void> _open(
  WidgetTester tester,
  _ControlledSource source,
  _History history,
  _Values values, {
  String language = 'en',
}) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: TextButton(
              key: const Key('openTest'),
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => LiveCaptureScreen(
                    test: _testSpec(),
                    batteryVersion: 'test',
                    sourceOverride: source,
                    storeLoader: () async => history,
                    attemptValueStoreLoader: () async => values,
                  ),
                ),
              ),
              child: const Text('Test home'),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.byKey(const Key('openTest')));
  await tester.pumpAndSettle();
  source.emitAttempt();
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('liveCapture.finish')), findsOneWidget);
}

void main() {
  for (final bool saveSucceeds in <bool>[true, false]) {
    testWidgets('pending save blocks retry until it settles: $saveSucceeds', (
      WidgetTester tester,
    ) async {
      final _ControlledSource source = _ControlledSource();
      final Completer<void> gate = Completer<void>();
      final _History history = _History()..gate = gate;
      final _Values values = _Values();
      await _open(tester, source, history, values);
      await tester.tap(find.byKey(const Key('liveCapture.finish')));
      await tester.pumpAndSettle();

      final OutlinedButton retry = tester.widget(
        find.byKey(const Key('liveCapture.tryAgain')),
      );
      expect(
        retry.onPressed,
        isNull,
        reason: 'a new attempt cannot own a prior pending save',
      );
      expect(history.records, isEmpty);
      expect(values.records, isEmpty);
      expect(source.starts, 1);

      if (saveSucceeds) {
        gate.complete();
      } else {
        gate.completeError(StateError('test write failure'));
      }
      await tester.pumpAndSettle();
      final OutlinedButton settledRetry = tester.widget(
        find.byKey(const Key('liveCapture.tryAgain')),
      );
      expect(settledRetry.onPressed, isNotNull);
      expect(history.records, hasLength(saveSucceeds ? 1 : 0));
      expect(values.records, hasLength(saveSucceeds ? 1 : 0));
      await tester.tap(find.byKey(const Key('liveCapture.tryAgain')));
      await tester.pumpAndSettle();
      expect(source.starts, 2);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await source.controller.close();
    });
  }

  for (final String language in <String>['en', 'tr']) {
    testWidgets(
      '$language background retires the attempt and rejects late frames',
      (WidgetTester tester) async {
        final _ControlledSource source = _ControlledSource();
        final _History history = _History();
        final _Values values = _Values();
        await _open(tester, source, history, values, language: language);
        final FilledButton staleFinish = tester.widget(
          find.byKey(const Key('liveCapture.finish')),
        );

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(source.disposals, 1);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        source.emitAttempt();
        staleFinish.onPressed!();
        await tester.pumpAndSettle();
        expect(
          find.text(
            language == 'tr' ? 'Ölçüm durduruldu' : 'Measurement stopped',
          ),
          findsOneWidget,
        );
        expect(history.records, isEmpty);
        expect(values.records, isEmpty);
        expect(
          source.starts,
          1,
          reason: 'a retired source cannot restart on resume',
        );
        expect(find.byKey(const Key('liveCapture.finish')), findsNothing);

        await tester.tap(find.byKey(const Key('liveCapture.returnToTest')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('openTest')), findsOneWidget);
        expect(source.disposals, 1, reason: 'route disposal cannot stop twice');
        await source.controller.close();
      },
    );
  }

  testWidgets('permission-prompt inactive state does not retire the camera', (
    WidgetTester tester,
  ) async {
    final _ControlledSource source = _ControlledSource();
    final _History history = _History();
    final _Values values = _Values();
    await _open(tester, source, history, values);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(source.disposals, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byKey(const Key('liveCapture.finish')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(source.disposals, 1);
    await source.controller.close();
  });

  testWidgets(
    'background preserves a completed result but retires its source',
    (WidgetTester tester) async {
      final _ControlledSource source = _ControlledSource();
      final _History history = _History();
      final _Values values = _Values();
      await _open(tester, source, history, values);
      await tester.tap(find.byKey(const Key('liveCapture.finish')));
      await tester.pumpAndSettle();
      expect(history.records, hasLength(1));
      expect(values.records, hasLength(1));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(source.disposals, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.textContaining("we'll track it from here"), findsOneWidget);
      expect(find.text('Back to test'), findsOneWidget);
      await tester.tap(find.byKey(const Key('liveCapture.tryAgain')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('openTest')), findsOneWidget);
      expect(source.starts, 1);
      expect(source.disposals, 1);
      expect(history.records, hasLength(1));
      await source.controller.close();
    },
  );
}
