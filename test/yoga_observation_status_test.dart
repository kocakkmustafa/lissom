import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/yoga_observation_status.dart';
import 'package:lissom_engine/lissom_engine.dart';

class DiskBundle extends CachingAssetBundle {
  DiskBundle({this.tamper});
  final String? tamper;
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    if (key == tamper) bytes[bytes.length - 1] ^= 1;
    final padded = Uint8List(bytes.length + 16)
      ..setRange(8, bytes.length + 8, bytes);
    return ByteData.view(padded.buffer, 8, bytes.length);
  }
}

YogaTaskCatalog catalog() =>
    YogaTaskCatalog.parse(File(kYogaTasksAsset).readAsStringSync());
HathaCourse course(String file) =>
    HathaCourse.parse(File('config/courses/$file.v1.json').readAsStringSync());

Widget host(
  HathaCourse value,
  String lesson,
  String locale,
  Future<YogaTaskCatalog> Function() loader,
) => MaterialApp(
  theme: buildLissomTheme(),
  locale: Locale(locale),
  supportedLocales: const [Locale('tr'), Locale('en')],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: const TextScaler.linear(2)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: YogaObservationStatusCard(
        course: value,
        lessonId: lesson,
        catalogLoader: loader,
      ),
    ),
  ),
);

void main() {
  test('bundled catalog and course hashes are verified using exact ByteData slices', () async {
    final value = await loadYogaTaskCatalog(bundle: DiskBundle());
    expect(value.tasks.length, 2);
    expect(value.deferredManifest['mode'], 'production');
    expect(value.deferredManifest['modelSha256'], isNull);
  });
  for (final asset in [kYogaTasksAsset, 'config/courses/hatha.v1.json']) {
    test(
      'tampered $asset is rejected instead of advertising support',
      () async {
        await expectLater(
          loadYogaTaskCatalog(bundle: DiskBundle(tamper: asset)),
          throwsFormatException,
        );
      },
    );
  }

  for (final language in ['tr', 'en']) {
    for (final file in [
      'hatha',
      'chair-office',
      'vinyasa-standing',
      'yin-supported',
      'ashtanga-foundations',
    ]) {
      testWidgets(
        '$language $file availability is explicit at 320px and 200% text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 812);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final value = course(file);
          final lesson = file == 'hatha' ? 'h03' : value.lessons.first.id;
          await tester.pumpWidget(
            host(value, lesson, language, () async => catalog()),
          );
          await tester.pumpAndSettle();
          final expected = file == 'hatha'
              ? (language == 'tr'
                    ? 'Kalibrasyon gerekli.'
                    : 'Calibration required.')
              : (language == 'tr' ? 'desteklenmiyor.' : 'not supported');
          expect(find.textContaining(expected), findsOneWidget);
          expect(
            find.textContaining(
              language == 'tr' ? 'kendi beyanındır' : 'self-recorded',
            ),
            findsOneWidget,
          );
          expect(find.byType(FilledButton), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'h07 has the same closed calibration gate; unsupported Hatha lessons stay closed',
    (tester) async {
      final value = course('hatha');
      Future<YogaTaskCatalog> loader() async => catalog();
      await tester.pumpWidget(host(value, 'h07', 'tr', loader));
      await tester.pumpAndSettle();
      expect(find.textContaining('Kalibrasyon gerekli.'), findsOneWidget);
      await tester.pumpWidget(host(value, 'h08', 'tr', loader));
      await tester.pumpAndSettle();
      expect(find.textContaining('desteklenmiyor.'), findsOneWidget);
    },
  );

  testWidgets(
    'missing configuration is a recoverable status and retry never enables capture',
    (tester) async {
      var calls = 0;
      Future<YogaTaskCatalog> loader() async {
        calls++;
        if (calls == 1) throw const FormatException('synthetic missing');
        return catalog();
      }

      await tester.pumpWidget(host(course('hatha'), 'h03', 'tr', loader));
      await tester.pumpAndSettle();
      expect(find.textContaining('Dersine devam edebilirsin.'), findsOneWidget);
      await tester.tap(find.byKey(const Key('yoga.observation.retry')));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.textContaining('Kalibrasyon gerekli.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'late catalog load cannot carry prior-lesson availability to the next lesson',
    (tester) async {
      final first = Completer<YogaTaskCatalog>();
      final next = Completer<YogaTaskCatalog>();
      final value = course('hatha');
      await tester.pumpWidget(host(value, 'h03', 'tr', () => first.future));
      await tester.pump();
      await tester.pumpWidget(host(value, 'h08', 'tr', () => next.future));
      await tester.pump();
      first.complete(catalog());
      await tester.pump();
      expect(find.textContaining('Kalibrasyon gerekli.'), findsNothing);
      next.complete(catalog());
      await tester.pumpAndSettle();
      expect(find.textContaining('desteklenmiyor.'), findsOneWidget);
    },
  );
}
