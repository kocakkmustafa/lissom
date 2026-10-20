import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:permission_handler/permission_handler.dart';

import 'support/narrow_surface.dart';

// Injected channel outcomes exercise the real onboarding widget. They do not
// establish native permission, Settings, or physical accessibility acceptance.
const Key _requestKey = Key('onboarding.camera.requestPermission');
const Key _settingsKey = Key('onboarding.camera.openSettings');
const Key _requestErrorKey = Key('onboarding.camera.requestError');
const Key _settingsErrorKey = Key('onboarding.camera.settingsError');
const Key _continueKey = Key('onboarding.continue');
const String _privateDetail = 'private-test-detail';

class _Store implements OnboardingStore {
  int writes = 0;

  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();

  @override
  Future<void> write(OnboardingProfile profile) async {
    writes++;
  }
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final Finder target = find.byKey(key);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<_Store> _pumpToCamera(
  WidgetTester tester, {
  required String language,
  required Future<PermissionStatus> Function() request,
  required Future<bool> Function() openSettings,
  bool measurementAvailable = true,
}) async {
  final _Store store = _Store();
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildLissomTheme(),
      home: OnboardingFlow(
        store: store,
        measurementAvailable: measurementAvailable,
        onRequestPermission: request,
        onOpenSettings: openSettings,
        onDone: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(
    find.text(language == 'tr' ? '5 adımın 1. adımı' : 'Step 1 of 5'),
    findsOneWidget,
  );
  await _tap(tester, _continueKey);
  await _tap(tester, const Key('onboarding.disclaimer.ack'));
  await _tap(tester, _continueKey);
  expect(
    find.text(language == 'tr' ? '5 adımın 3. adımı' : 'Step 3 of 5'),
    findsOneWidget,
  );
  return store;
}

void _expectContinueEnabled(WidgetTester tester) {
  expect(
    tester.widget<FilledButton>(find.byKey(_continueKey)).onPressed,
    isNotNull,
  );
}

void _expectLiveError(WidgetTester tester, Key key, String text) {
  final Finder error = find.byKey(key);
  expect(error, findsOneWidget);
  expect(tester.widget<Semantics>(error).properties.liveRegion, isTrue);
  expect(find.text(text), findsOneWidget);
  expect(find.textContaining(_privateDetail), findsNothing);
}

void main() {
  for (final String language in <String>['en', 'tr']) {
    final bool turkish = language == 'tr';
    final String requestError = turkish
        ? 'Kamera erişimi denetlenemedi. Yeniden dene veya kamera olmadan devam et.'
        : 'Camera access could not be checked. Try again, or continue without the camera.';
    final String settingsError = turkish
        ? 'Ayarlar açılamadı. Yeniden dene veya cihaz ayarlarını kendin aç. Kamera olmadan da devam edebilirsin.'
        : 'Settings could not be opened. Try again, or open your device settings yourself. You can also continue without the camera.';

    testWidgets('request exception permits a visible retry in $language', (
      WidgetTester tester,
    ) async {
      pinNarrowSurface(tester);
      int requests = 0;
      final _Store store = await _pumpToCamera(
        tester,
        language: language,
        request: () async {
          requests++;
          if (requests == 1) {
            throw PlatformException(code: 'test', message: _privateDetail);
          }
          return PermissionStatus.granted;
        },
        openSettings: () async => true,
      );

      await _tap(tester, _requestKey);
      _expectLiveError(tester, _requestErrorKey, requestError);
      expect(
        tester.widget<OutlinedButton>(find.byKey(_requestKey)).onPressed,
        isNotNull,
      );
      _expectContinueEnabled(tester);
      await _tap(tester, _requestKey);
      expect(requests, 2);
      expect(find.byKey(_requestErrorKey), findsNothing);
      expect(
        find.text(turkish ? 'Kamera izni verildi.' : 'Camera access granted.'),
        findsOneWidget,
      );
      expect(store.writes, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'pending request admits one action and keeps exit in $language',
      (WidgetTester tester) async {
        pinNarrowSurface(tester);
        final Completer<PermissionStatus> pending =
            Completer<PermissionStatus>();
        int requests = 0;
        await _pumpToCamera(
          tester,
          language: language,
          request: () {
            requests++;
            return pending.future;
          },
          openSettings: () async => true,
        );
        await tester.ensureVisible(find.byKey(_requestKey));
        await tester.tap(find.byKey(_requestKey));
        await tester.tap(find.byKey(_requestKey));
        await tester.pump();
        expect(requests, 1);
        expect(
          tester.widget<OutlinedButton>(find.byKey(_requestKey)).onPressed,
          isNull,
        );
        _expectContinueEnabled(tester);
        await _tap(tester, _continueKey);
        expect(find.byKey(_requestKey), findsNothing);
        pending.complete(PermissionStatus.granted);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    for (final bool throws in <bool>[false, true]) {
      testWidgets(
        'request completes after dispose, throws=$throws, $language',
        (WidgetTester tester) async {
          pinNarrowSurface(tester);
          final Completer<PermissionStatus> pending =
              Completer<PermissionStatus>();
          await _pumpToCamera(
            tester,
            language: language,
            request: () => pending.future,
            openSettings: () async => true,
          );
          await _tap(tester, _requestKey);
          await tester.pumpWidget(const SizedBox.shrink());
          if (throws) {
            pending.completeError(
              PlatformException(code: 'test', message: _privateDetail),
            );
          } else {
            pending.complete(PermissionStatus.granted);
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('Settings failure retries, throws=$throws, $language', (
        WidgetTester tester,
      ) async {
        pinNarrowSurface(tester);
        int settingsCalls = 0;
        int requests = 0;
        await _pumpToCamera(
          tester,
          language: language,
          request: () async {
            requests++;
            return PermissionStatus.permanentlyDenied;
          },
          openSettings: () async {
            settingsCalls++;
            if (settingsCalls == 1) {
              if (throws) {
                throw PlatformException(code: 'test', message: _privateDetail);
              }
              return false;
            }
            return true;
          },
        );
        await _tap(tester, _requestKey);
        await _tap(tester, _settingsKey);
        _expectLiveError(tester, _settingsErrorKey, settingsError);
        expect(
          tester.widget<FilledButton>(find.byKey(_settingsKey)).onPressed,
          isNotNull,
        );
        _expectContinueEnabled(tester);
        await _tap(tester, _settingsKey);
        expect(settingsCalls, 2);
        expect(
          requests,
          1,
          reason: 'Opening Settings does not grant permission',
        );
        expect(find.byKey(_settingsErrorKey), findsNothing);
        expect(
          find.text(
            turkish ? 'Kamera izni verildi.' : 'Camera access granted.',
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'Settings completes after dispose, throws=$throws, $language',
        (WidgetTester tester) async {
          pinNarrowSurface(tester);
          final Completer<bool> pending = Completer<bool>();
          await _pumpToCamera(
            tester,
            language: language,
            request: () async => PermissionStatus.permanentlyDenied,
            openSettings: () => pending.future,
          );
          await _tap(tester, _requestKey);
          await _tap(tester, _settingsKey);
          _expectContinueEnabled(tester);
          await tester.pumpWidget(const SizedBox.shrink());
          if (throws) {
            pending.completeError(
              PlatformException(code: 'test', message: _privateDetail),
            );
          } else {
            pending.complete(false);
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('pending Settings serializes camera actions in $language', (
      WidgetTester tester,
    ) async {
      pinNarrowSurface(tester);
      final Completer<bool> pending = Completer<bool>();
      int settingsCalls = 0;
      int requests = 0;
      await _pumpToCamera(
        tester,
        language: language,
        request: () async {
          requests++;
          return PermissionStatus.permanentlyDenied;
        },
        openSettings: () {
          settingsCalls++;
          return pending.future;
        },
      );
      await _tap(tester, _requestKey);
      await tester.ensureVisible(find.byKey(_settingsKey));
      await tester.tap(find.byKey(_settingsKey));
      await tester.tap(find.byKey(_settingsKey));
      await tester.pump();
      expect(settingsCalls, 1);
      expect(requests, 1);
      expect(
        tester.widget<FilledButton>(find.byKey(_settingsKey)).onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(find.byKey(_requestKey)).onPressed,
        isNull,
      );
      _expectContinueEnabled(tester);
      pending.complete(false);
      await tester.pumpAndSettle();
      _expectLiveError(tester, _settingsErrorKey, settingsError);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'closed camera has no permission or Settings action in $language',
      (WidgetTester tester) async {
        pinNarrowSurface(tester);
        int requests = 0;
        int settingsCalls = 0;
        await _pumpToCamera(
          tester,
          language: language,
          measurementAvailable: false,
          request: () async {
            requests++;
            throw PlatformException(code: 'test', message: _privateDetail);
          },
          openSettings: () async {
            settingsCalls++;
            throw PlatformException(code: 'test', message: _privateDetail);
          },
        );
        expect(
          find.textContaining(
            turkish
                ? 'yazılı yoga kursları kamera olmadan çalışır'
                : 'the written yoga courses work without it',
          ),
          findsOneWidget,
        );
        expect(find.byKey(_requestKey), findsNothing);
        expect(find.byKey(_settingsKey), findsNothing);
        expect(find.byKey(_requestErrorKey), findsNothing);
        expect(find.byKey(_settingsErrorKey), findsNothing);
        _expectContinueEnabled(tester);
        await _tap(tester, _continueKey);
        expect(requests, 0);
        expect(settingsCalls, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
