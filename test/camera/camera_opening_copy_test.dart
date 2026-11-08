import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/camera/lesson_camera_section.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom_engine/lissom_engine.dart';

const String _permEn =
    'Lissom uses the camera only when you start the optional camera practice in a lesson. The image is processed on this device to find body positions; video is not recorded or uploaded.';
const String _privEn =
    'Images, video and body positions are not recorded, stored or sent to us or anyone else. Spoken corrections use your device\'s speech engine.';
const String _permTr =
    'Lissom kamerayı yalnız bir derste isteğe bağlı kamera çalışmasını başlattığında kullanır. Görüntü vücut konumlarını bulmak için bu cihazda işlenir; video kaydedilmez veya yüklenmez.';
const String _privTr =
    'Görüntü, video ve vücut konumları kaydedilmez, saklanmaz, bize ya da başkasına gönderilmez. Sesli düzeltmeler cihazının kendi konuşma motorunu kullanır.';

const Key _permKey = Key('camera.lesson.permissionNote');
const Key _privKey = Key('camera.lesson.privacyNote');

const List<String> _locales = <String>[
  'ar',
  'de',
  'en',
  'es-419',
  'fr',
  'hi',
  'id',
  'it',
  'ja',
  'ko',
  'pl',
  'pt-BR',
  'tr',
  'zh-Hans',
];

CameraPoseCatalog _catalog() => CameraPoseCatalog.parse(
  File('config/yoga/camera-poses.v1.json').readAsStringSync(),
);

Widget _section({
  required String lessonId,
  required bool canStart,
  Locale locale = const Locale('en'),
  Future<CameraPoseCatalog> Function()? loader,
}) => MaterialApp(
  locale: locale,
  supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
  localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  theme: buildLissomTheme(locale: locale),
  home: Scaffold(
    body: SingleChildScrollView(
      child: LessonCameraSection(
        courseId: 'lissom.hatha.foundations',
        lessonId: lessonId,
        canStart: canStart,
        catalogLoader: loader ?? () async => _catalog(),
      ),
    ),
  ),
);

Map<String, dynamic> _messages(String loc) =>
    (jsonDecode(File('config/l10n/$loc.json').readAsStringSync())
            as Map<String, dynamic>)['messages']
        as Map<String, dynamic>;

final class _NoWriteStore implements HathaProgressStore {
  @override
  Future<HathaProgress> read() async =>
      const HathaProgress(records: [], unreadableRecords: 0);
  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async =>
      throw StateError('must not write');
}

void main() {
  testWidgets('camera lesson shows both notes in English', (t) async {
    await t.pumpWidget(_section(lessonId: 'h03', canStart: true));
    await t.pumpAndSettle();
    expect(find.byKey(_permKey), findsOneWidget);
    expect(find.byKey(_privKey), findsOneWidget);
    expect(find.text(_permEn), findsOneWidget);
    expect(find.text(_privEn), findsOneWidget);
  });

  testWidgets('camera lesson shows both notes in Turkish', (t) async {
    await t.pumpWidget(
      _section(lessonId: 'h03', canStart: true, locale: const Locale('tr')),
    );
    await t.pumpAndSettle();
    expect(find.byKey(_permKey), findsOneWidget);
    expect(find.byKey(_privKey), findsOneWidget);
    expect(find.text(_permTr), findsOneWidget);
    expect(find.text(_privTr), findsOneWidget);
  });

  testWidgets('notes are read before permission: visible while locked', (
    t,
  ) async {
    await t.pumpWidget(_section(lessonId: 'h03', canStart: false));
    await t.pumpAndSettle();
    expect(find.text(_permEn), findsOneWidget);
    expect(find.text(_privEn), findsOneWidget);
    expect(find.byKey(const Key('camera.lesson.locked')), findsOneWidget);
    final OutlinedButton b = t.widget(
      find.byKey(const Key('camera.lesson.start.mountain')),
    );
    expect(b.onPressed, isNull);
  });

  testWidgets('a lesson the camera does not assess has no notes', (t) async {
    await t.pumpWidget(_section(lessonId: 'h31', canStart: true));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.lesson.notAssessed')), findsOneWidget);
    expect(find.byKey(_permKey), findsNothing);
    expect(find.byKey(_privKey), findsNothing);
    expect(find.text(_permEn), findsNothing);
    expect(find.text(_privEn), findsNothing);
  });

  testWidgets('a catalog that fails to load has no notes', (t) async {
    await t.pumpWidget(
      _section(
        lessonId: 'h03',
        canStart: true,
        loader: () async => throw StateError('no catalog'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.lesson.failed')), findsOneWidget);
    expect(find.byKey(_permKey), findsNothing);
    expect(find.byKey(_privKey), findsNothing);
  });

  testWidgets('with the flag closed the lesson draws no camera section', (
    t,
  ) async {
    final HathaCourse course = HathaCourse.parse(
      File('config/courses/hatha.v1.json').readAsStringSync(),
    );
    await t.pumpWidget(
      MaterialApp(
        home: HathaLessonScreen(
          course: course,
          lesson: course.lessonById('h03')!,
          store: _NoWriteStore(),
          isRepeat: false,
          cameraTrialOpen: false,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(HathaLessonScreen), findsOneWidget);
    expect(find.byKey(LessonCameraSection.sectionKey), findsNothing);
    expect(find.byKey(_permKey), findsNothing);
    expect(find.byKey(_privKey), findsNothing);
    expect(find.text(_permEn), findsNothing);
    expect(find.text(_privEn), findsNothing);
  });

  group('catalogs', () {
    test('all 14 locales carry both keys, non-empty', () {
      expect(_locales.length, 14);
      for (final String loc in _locales) {
        final Map<String, dynamic> m = _messages(loc);
        for (final String k in <String>[_permEn, _privEn]) {
          expect(m.containsKey(k), isTrue, reason: '$loc missing key');
          expect((m[k] as String).trim(), isNotEmpty, reason: loc);
        }
      }
    });

    test('en value equals key', () {
      final Map<String, dynamic> m = _messages('en');
      expect(m[_permEn], _permEn);
      expect(m[_privEn], _privEn);
    });

    test('tr value is the reviewed Turkish copy', () {
      final Map<String, dynamic> m = _messages('tr');
      expect(m[_permEn], _permTr);
      expect(m[_privEn], _privTr);
    });

    test('the 12 other locales are translated, not the English key', () {
      for (final String loc in _locales) {
        if (loc == 'en' || loc == 'tr') continue;
        final Map<String, dynamic> m = _messages(loc);
        expect(m[_permEn], isNot(_permEn), reason: loc);
        expect(m[_privEn], isNot(_privEn), reason: loc);
        expect(m[_permEn], contains('Lissom'), reason: loc);
      }
    });
  });
}
