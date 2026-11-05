import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/camera/camera_coach_screen.dart';
import 'package:lissom/app/camera/coach_speaker.dart';
import 'package:lissom/app/camera/lesson_camera_section.dart';
import 'package:lissom/app/camera/mirror_camera.dart';
import 'package:lissom/app/camera/mirror_screen.dart';
import 'package:lissom/app/lissom_release_policy.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'side_figure.dart';

CameraPoseCatalog _catalog() => CameraPoseCatalog.parse(
  File('config/yoga/camera-poses.v1.json').readAsStringSync(),
);

final class _Speaker implements CoachSpeaker {
  final List<String> said = <String>[];
  int stops = 0;
  @override
  Future<void> speak(String text, Locale locale) async => said.add(text);
  @override
  Future<void> stop() async => stops++;
}

final class _Mirror implements MirrorCamera {
  _Mirror(this.result);
  final MirrorFailure? result;
  int closes = 0;
  @override
  Future<MirrorFailure?> open() async => result;
  @override
  Widget preview() => const ColoredBox(color: Color(0xFF000000));
  @override
  Future<void> close() async => closes++;
}

List<PoseSourceEvent> _frames(double seconds, {double lean = 0}) =>
    <PoseSourceEvent>[
      for (int i = 0; i < (seconds * 30).round(); i++)
        SourceFrameEvent(
          sideFigure(tUs: i * 33333, trunkLeanDeg: lean),
          size: kPortrait,
        ),
    ];

void _tall(WidgetTester t) {
  t.view.physicalSize = const Size(1200, 3200);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Widget _app(Widget child) => MaterialApp(
  theme: buildLissomTheme(locale: const Locale('en')),
  home: child,
);

void main() {
  test('the camera trial flag is closed by default', () {
    expect(lissomCameraCoachingTrialOpen, isFalse);
  });

  testWidgets('a camera lesson lists its poses and the mirror', (t) async {
    await t.pumpWidget(
      _app(
        Scaffold(
          body: LessonCameraSection(
            courseId: 'lissom.hatha.foundations',
            lessonId: 'h03',
            canStart: true,
            catalogLoader: () async => _catalog(),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(
      find.byKey(const Key('camera.lesson.start.mountain')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('camera.lesson.mirror')), findsOneWidget);
    expect(find.textContaining('trial'), findsWidgets);
    expect(find.byKey(const Key('camera.lesson.locked')), findsNothing);
  });

  testWidgets('before preparation the camera cannot start', (t) async {
    await t.pumpWidget(
      _app(
        Scaffold(
          body: LessonCameraSection(
            courseId: 'lissom.hatha.foundations',
            lessonId: 'h03',
            canStart: false,
            catalogLoader: () async => _catalog(),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.lesson.locked')), findsOneWidget);
    final OutlinedButton b = t.widget(
      find.byKey(const Key('camera.lesson.start.mountain')),
    );
    expect(b.onPressed, isNull);
  });

  testWidgets('a lesson outside the catalog says so honestly', (t) async {
    await t.pumpWidget(
      _app(
        Scaffold(
          body: LessonCameraSection(
            courseId: 'lissom.hatha.foundations',
            lessonId: 'h29',
            canStart: true,
            catalogLoader: () async => _catalog(),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(
      find.text('The camera does not assess this lesson.'),
      findsOneWidget,
    );
  });

  testWidgets('coach: confirms the pose, counts the hold and finishes', (
    t,
  ) async {
    _tall(t);
    final CameraPoseCatalog cat = _catalog();
    final _Speaker speaker = _Speaker();
    await t.pumpWidget(
      _app(
        CameraCoachScreen(
          catalog: cat,
          pose: cat.pose('mountain')!,
          sourceFactory: () => FakePoseSource(_frames(20)),
          speaker: speaker,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.coach.done')), findsOneWidget);
    expect(find.text('Held 15 of 15 seconds'), findsOneWidget);
    expect(speaker.said, isEmpty);
    expect(find.byKey(const Key('camera.coach.honesty')), findsOneWidget);
  });

  testWidgets('coach: says one correction and shows it', (t) async {
    _tall(t);
    final CameraPoseCatalog cat = _catalog();
    final _Speaker speaker = _Speaker();
    await t.pumpWidget(
      _app(
        CameraCoachScreen(
          catalog: cat,
          pose: cat.pose('mountain')!,
          sourceFactory: () => FakePoseSource(_frames(12, lean: 10)),
          speaker: speaker,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(speaker.said, <String>['Bring your shoulders over your hips.']);
    expect(find.byKey(const Key('camera.coach.correction')), findsOneWidget);
    expect(find.text('You are in Mountain stance.'), findsOneWidget);
  });

  testWidgets('coach: a front view asks to turn sideways', (t) async {
    _tall(t);
    final CameraPoseCatalog cat = _catalog();
    await t.pumpWidget(
      _app(
        CameraCoachScreen(
          catalog: cat,
          pose: cat.pose('mountain')!,
          sourceFactory: () => FakePoseSource(<PoseSourceEvent>[
            for (int i = 0; i < 30; i++)
              SourceFrameEvent(
                sideFigure(tUs: i * 33333, frontFacing: true),
                size: kPortrait,
              ),
          ]),
          speaker: _Speaker(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Turn so your side faces the phone.'), findsOneWidget);
  });

  testWidgets('coach: denied permission offers Settings', (t) async {
    _tall(t);
    final CameraPoseCatalog cat = _catalog();
    await t.pumpWidget(
      _app(
        CameraCoachScreen(
          catalog: cat,
          pose: cat.pose('mountain')!,
          sourceFactory: () => FakePoseSource(const <PoseSourceEvent>[
            SourceStateEvent(
              PermissionDenied(
                kind: PermissionDenialKind.permanent,
                userText: 'Camera access is off for Lissom.',
              ),
            ),
          ]),
          speaker: _Speaker(),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.coach.permission')), findsOneWidget);
    expect(find.byKey(const Key('camera.coach.settings')), findsOneWidget);
  });

  testWidgets('mirror shows the preview and releases it on close', (t) async {
    final _Mirror m = _Mirror(null);
    await t.pumpWidget(_app(MirrorScreen(title: 'Mirror', camera: () => m)));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.mirror.preview')), findsOneWidget);
    await t.pumpWidget(_app(const SizedBox()));
    expect(m.closes, 1);
  });

  testWidgets('mirror names a refused camera', (t) async {
    await t.pumpWidget(
      _app(
        MirrorScreen(
          title: 'Mirror',
          camera: () => _Mirror(MirrorFailure.permissionPermanent),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byKey(const Key('camera.mirror.settings')), findsOneWidget);
  });
}
