import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';

import 'support/facts_from_disk.dart';
import 'support/listing_json.dart';

final class _ProfileStore implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async {}
}

Widget _host(String language, Widget child) => MaterialApp(
  locale: Locale(language),
  supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  home: child,
);

void main() {
  for (final String language in <String>['en', 'tr']) {
    testWidgets('$language release onboarding never requests a closed camera', (
      WidgetTester tester,
    ) async {
      final List<String> permissionCalls = <String>[];
      const MethodChannel channel = MethodChannel(
        'flutter.baseflow.com/permissions/methods',
      );
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        MethodCall call,
      ) async {
        permissionCalls.add(call.method);
        return null;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      await tester.pumpWidget(
        _host(language, OnboardingFlow(store: _ProfileStore(), onDone: (_) {})),
      );
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('onboarding.camera.requestPermission')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('onboarding.camera.openSettings')),
        findsNothing,
      );
      expect(
        find.textContaining(
          language == 'tr'
              ? 'Kamera izni istemiyoruz'
              : 'We do not request camera access',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding.ageBand.u40')), findsOneWidget);
      expect(permissionCalls, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$language boundary acknowledges the natural-breath lesson', (
      WidgetTester tester,
    ) async {
      final facts = factsFromDisk();
      expect(facts.hatha!.lessons.any((lesson) => lesson.id == 'h02'), isTrue);
      await tester.pumpWidget(
        _host(
          language,
          WhatLissomDoesntDoScreen(
            items: facts.ia.whyNot,
            excluded: facts.battery.excluded,
            poseTiers: facts.ia.poseTiers,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          language == 'tr'
              ? 'doğal nefes çalışması vardır'
              : 'includes natural-breath practice',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('no breath or meditation content at all'),
        findsNothing,
      );
      expect(
        find.textContaining('nefes ve meditasyon içeriği de bulunmaz'),
        findsNothing,
      );
    });
  }

  for (final String path in <String>[
    listingPath,
    'docs/store/listing.tr-TR.json',
  ]) {
    test('current draft course provenance matches bundled bytes: $path', () {
      final Map<String, dynamic> listing = readListing(path);
      final Map<String, dynamic> current =
          (listing[r'$coursePreparationCurrent'] as Map)
              .cast<String, dynamic>();
      final File file = File('config/courses/hatha.v1.json');
      final Map<String, dynamic> course =
          (jsonDecode(file.readAsStringSync()) as Map).cast<String, dynamic>();
      expect(current['asset'], 'config/courses/hatha.v1.json');
      expect(
        current['sha256'],
        sha256.convert(file.readAsBytesSync()).toString(),
      );
      expect(current['version'], course['version']);
      final List<dynamic> modules = course['modules'] as List<dynamic>;
      final int lessonCount = modules.fold<int>(
        0,
        (int total, dynamic module) =>
            total + (module['lessons'] as List).length,
      );
      expect(current['lessonCount'], lessonCount);
      expect(current['mediaIncluded'], isFalse);
      expect(current['physicalDeviceAccepted'], isFalse);
    });
  }
}
