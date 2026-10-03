import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'support/facts_from_disk.dart';

final class _NoWriteHathaStore implements HathaProgressStore {
  @override
  Future<HathaProgress> read() async =>
      const HathaProgress(records: [], unreadableRecords: 0);
  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async =>
      throw StateError('must not write');
}

final class _RetryStore implements OnboardingStore {
  int writes = 0;
  OnboardingProfile? written;
  Completer<void>? gate;

  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();

  @override
  Future<void> write(OnboardingProfile profile) async {
    writes++;
    if (gate != null) {
      await gate!.future;
    } else if (writes == 1) {
      throw const FileSystemException('injected disk failure');
    }
    written = profile;
  }
}

Future<void> _finishSteps(WidgetTester tester) async {
  Future<void> next() async {
    await tester.tap(find.byKey(const Key('onboarding.continue')));
    await tester.pumpAndSettle();
  }

  await next();
  await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
  await tester.pumpAndSettle();
  await next();
  await next();
  await tester.tap(find.byKey(const Key('onboarding.ageBand.40-59')));
  await tester.pumpAndSettle();
  await next();
}

Widget _host(
  String language,
  OnboardingStore store,
  ValueChanged<OnboardingProfile> onDone,
) => MaterialApp(
  locale: Locale(language),
  supportedLocales: const [Locale('en'), Locale('tr')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: OnboardingFlow(store: store, onDone: onDone),
);

void main() {
  for (final language in ['en', 'tr']) {
    testWidgets('transient onboarding load can retry $language', (
      tester,
    ) async {
      int attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: const [Locale('en'), Locale('tr')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: OnboardingGate(
            storeLoader: () async {
              if (++attempts == 1) throw const FileSystemException('transient');
              return _RetryStore();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('onboarding.gate.loadFailure')),
        findsOneWidget,
      );
      final retry = find.byKey(const Key('onboarding.gate.retry'));
      expect(retry, findsOneWidget);
      expect(
        find.text(language == 'tr' ? 'Yeniden dene' : 'Try again'),
        findsOneWidget,
      );
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'onboarding disk failure keeps profile and allows retry $language',
      (tester) async {
        final store = _RetryStore();
        int done = 0;
        await tester.pumpWidget(_host(language, store, (_) => done++));
        await tester.pumpAndSettle();
        await _finishSteps(tester);
        await tester.tap(find.byKey(const Key('onboarding.continue')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(done, 0);
        expect(find.byKey(const Key('onboarding.saveError')), findsOneWidget);
        expect(
          find.text(
            language == 'tr'
                ? 'Profil kaydedilemedi. Başla düğmesine dokunarak yeniden dene.'
                : 'Your profile could not be saved. Tap Get started to try again.',
          ),
          findsOneWidget,
        );
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const Key('onboarding.continue')),
              )
              .onPressed,
          isNotNull,
        );
        await tester.tap(find.byKey(const Key('onboarding.continue')));
        await tester.pumpAndSettle();
        expect(done, 1);
        expect(store.writes, 2);
        expect(store.written!.ageBand, '40-59');
        expect(store.written!.completed, isTrue);
        expect(find.byKey(const Key('onboarding.saveError')), findsNothing);
      },
    );

    for (final lessonId in ['h03', 'h04']) {
      testWidgets(
        '$lessonId preparation does not assume locked h05 $language',
        (tester) async {
          final course = HathaCourse.parse(
            File('config/courses/hatha.v1.json').readAsStringSync(),
          );
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(language),
              supportedLocales: const [Locale('en'), Locale('tr')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: HathaLessonScreen(
                course: course,
                lesson: course.lessonById(lessonId)!,
                store: _NoWriteHathaStore(),
                isRepeat: false,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('hatha.session.preparation')),
            findsOneWidget,
          );
          expect(
            find.textContaining(
              language == 'tr' ? 'h05 dersini hatırla' : 'Recall lesson h05',
            ),
            findsNothing,
          );
          expect(
            find.textContaining(
              language == 'tr'
                  ? 'eklemleri rahat aralıkta'
                  : 'move joints gently within a comfortable range',
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('hatha.session.prepared')),
            findsOneWidget,
          );
        },
      );
    }
  }

  testWidgets('late onboarding save after route disposal does not open shell', (
    tester,
  ) async {
    final store = _RetryStore()..gate = Completer<void>();
    int done = 0;
    await tester.pumpWidget(_host('en', store, (_) => done++));
    await tester.pumpAndSettle();
    await _finishSteps(tester);
    await tester.tap(find.byKey(const Key('onboarding.continue')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    store.gate!.completeError(const FileSystemException('late disk failure'));
    await tester.pumpAndSettle();
    expect(done, 0);
    expect(tester.takeException(), isNull);
  });

  for (final kind in [
    LissomLocalFile.onboarding,
    LissomLocalFile.attemptValues,
  ]) {
    test('retired account rejects stale ${kind.name} writes', () async {
      final root = await Directory.systemTemp.createTemp('lissom-retired-');
      addTearDown(() => root.delete(recursive: true));
      final alice = LissomLocalScope.account('account-a');
      final bob = LissomLocalScope.account('account-b');
      Future<void> write(LissomLocalScope owner) {
        if (kind == LissomLocalFile.onboarding) {
          return JsonOnboardingStore(
            owner.file(root, kind),
          ).write(const OnboardingProfile(completed: true, ageBand: 'u40'));
        }
        return JsonlAttemptValueStore(owner.file(root, kind)).append(
          AttemptValue(
            lessonId: 'overhead_reach:right',
            completedAt: DateTime.utc(2026, 10, 1),
            value: 90,
            unit: 'deg',
            tier: 'measurementOnly',
            provenance: const {},
          ),
        );
      }

      await write(alice);
      await write(bob);
      await write(LissomLocalScope.guest);
      await clearLissomLocalData(
        'account-a',
        supportDirectory: () async => root,
      );
      await expectLater(write(alice), throwsStateError);
      expect(await alice.directory(root).exists(), isFalse);
      expect(await bob.file(root, kind).exists(), isTrue);
      expect(await LissomLocalScope.guest.file(root, kind).exists(), isTrue);
    });
  }

  test('session factory serializes two writers without lost records', () async {
    final root = await Directory.systemTemp.createTemp(
      'lissom-session-retired-',
    );
    addTearDown(() => root.delete(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final alice = LissomLocalScope.account('session-a');
    final first = await openSessionStore(scope: alice);
    final second = await openSessionStore(scope: alice);
    await Future.wait([
      first.append(recordOf(lessonId: 'first', lessonClass: 'measurementOnly')),
      second.append(
        recordOf(lessonId: 'second', lessonClass: 'measurementOnly'),
      ),
    ]);
    expect((await first.recent()).map((e) => e.lessonId).toSet(), {
      'first',
      'second',
    });
    expect(await first.unreadableRecords(), 0);
    expect(await first.workedSecondsFor('first'), 12);
  });

  test('retired session factory rejects stale writer', () async {
    final root = await Directory.systemTemp.createTemp('lissom-session-stale-');
    addTearDown(() => root.delete(recursive: true));
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final alice = LissomLocalScope.account('session-a');
    final first = await openSessionStore(scope: alice);
    await first.append(
      recordOf(lessonId: 'first', lessonClass: 'measurementOnly'),
    );
    await clearLissomLocalData('session-a', supportDirectory: () async => root);
    await expectLater(
      first.append(recordOf(lessonId: 'stale', lessonClass: 'measurementOnly')),
      throwsStateError,
    );
    expect(await alice.directory(root).exists(), isFalse);
  });
}
