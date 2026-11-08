/// Camera data boundary (LIS-P1-02). TEST_ONLY: everything here runs with fake
/// sources; nothing was run on a device.
///
/// The camera trial claims: image, video and landmarks never leave the
/// device; with the flag closed the camera path is never triggered; a refused
/// permission never breaks the lesson. These tests hold those claims within
/// the limits below.
///
/// Limits (be honest about what is NOT proven):
/// - The dynamic counter sees only `dart:io` `HttpClient` creation. It does
///   not see a raw `Socket`, native/platform channels, the native side of
///   `motion_camera`, or text-to-speech.
/// - The real `CameraPoseSource` path is not run (a `FakePoseSource` feeds
///   the coach).
/// - The static scan covers exactly the discovered set: every `.dart` file
///   under `lib/` and `packages/lissom_engine/lib/` that mentions
///   `PoseSource`, `PoseFrame`, `CameraPoseSource`, `motion_camera` or
///   `package:camera`, plus the fixed camera files. Anything else (Core
///   packages, native code) is out of scope.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ashtanga_course.dart';
import 'package:lissom/app/camera/camera_coach_screen.dart';
import 'package:lissom/app/camera/coach_speaker.dart';
import 'package:lissom/app/camera/lesson_camera_section.dart';
import 'package:lissom/app/camera/mirror_camera.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/lissom_release_policy.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'side_figure.dart';

// ---------------------------------------------------------------- helpers

CameraPoseCatalog _catalog() => CameraPoseCatalog.parse(
  File('config/yoga/camera-poses.v1.json').readAsStringSync(),
);

HathaCourse _ashtanga() =>
    HathaCourse.parse(File(kAshtangaCourseAssetPath).readAsStringSync());

HathaCourse _hatha() =>
    HathaCourse.parse(File(kHathaCourseAssetPath).readAsStringSync());

List<PoseSourceEvent> _frames(double seconds) => <PoseSourceEvent>[
  for (int i = 0; i < (seconds * 30).round(); i++)
    SourceFrameEvent(sideFigure(tUs: i * 33333), size: kPortrait),
];

PoseSource _denied() => FakePoseSource(const <PoseSourceEvent>[
  SourceStateEvent(
    PermissionDenied(
      kind: PermissionDenialKind.permanent,
      userText: 'Camera access is off for Lissom.',
    ),
  ),
]);

final class _Speaker implements CoachSpeaker {
  @override
  Future<void> speak(String text, Locale locale) async {}
  @override
  Future<void> stop() async {}
}

final class _RefusedMirror implements MirrorCamera {
  @override
  Future<MirrorFailure?> open() async => MirrorFailure.permissionPermanent;
  @override
  Widget preview() => const SizedBox();
  @override
  Future<void> close() async {}
}

final class _Store implements HathaProgressStore {
  int marked = 0;
  @override
  Future<HathaProgress> read() async => const HathaProgress(
    records: <HathaPracticeRecord>[],
    unreadableRecords: 0,
  );
  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async =>
      marked++;
}

void _tall(WidgetTester t) {
  t.view.physicalSize = const Size(1200, 6400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Widget _app(Widget child) => MaterialApp(
  theme: buildLissomTheme(locale: const Locale('en')),
  home: child,
);

/// Opens [lesson] from a launcher so the lesson route can pop like in the app.
Widget _lessonLauncher({
  required HathaCourse course,
  required String lessonId,
  required HathaProgressStore store,
  bool? cameraTrialOpen,
  Future<CameraPoseCatalog> Function()? catalogLoader,
  PoseSource Function()? sourceFactory,
}) => _app(
  Builder(
    builder: (BuildContext context) => Scaffold(
      body: TextButton(
        key: const Key('test.open'),
        onPressed: () => Navigator.of(context).push<bool>(
          MaterialPageRoute<bool>(
            builder: (_) => cameraTrialOpen == null
                ? HathaLessonScreen(
                    course: course,
                    lesson: course.lessonById(lessonId)!,
                    store: store,
                    isRepeat: false,
                    cameraCatalogLoader: catalogLoader,
                    cameraSourceFactory: sourceFactory,
                  )
                : HathaLessonScreen(
                    course: course,
                    lesson: course.lessonById(lessonId)!,
                    store: store,
                    isRepeat: false,
                    cameraTrialOpen: cameraTrialOpen,
                    cameraCatalogLoader: catalogLoader,
                    cameraSourceFactory: sourceFactory,
                  ),
          ),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

/// Counts client creations and hands the call on to the override that was
/// installed before (flutter_test's own mock), so that one stays in force.
final class _CountingHttpOverrides extends HttpOverrides {
  _CountingHttpOverrides(this._previous);
  final HttpOverrides? _previous;
  int clients = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    clients++;
    return _previous?.createHttpClient(context) ??
        super.createHttpClient(context);
  }
}

// ------------------------------------------------------- static scanning

/// Removes block comments and full-line comments (incl. doc comments), plus
/// trailing `// ...` that follows `;`, `{` or `}`. String literals stay, so a
/// URI literal is still seen.
String stripComments(String source) {
  final String noBlock = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return noBlock
      .split('\n')
      .where((String l) => !l.trimLeft().startsWith('//'))
      .map((String l) => l.replaceFirst(RegExp(r'(?<=[;{}])\s*//.*$'), ''))
      .join('\n');
}

final Map<String, RegExp> _networkTraces = <String, RegExp>{
  'package:http': RegExp(r'package:http/'),
  'package:dio': RegExp(r'package:dio/'),
  'HttpClient': RegExp(r'\bHttpClient\b'),
  'WebSocket': RegExp(r'\bWebSocket\b'),
  'Socket': RegExp(r'\b(Raw)?(Secure)?Socket\b'),
  'web_socket_channel': RegExp(r'web_socket_channel'),
  'HttpServer': RegExp(r'\bHttpServer\b'),
  'InternetAddress': RegExp(r'\bInternetAddress\b'),
  'Process.run/start': RegExp(r'\bProcess\.(run|start)\b'),
  '.upload(': RegExp(r'\.upload\('),
  'supabase': RegExp('supabase', caseSensitive: false),
  'firebase': RegExp('firebase', caseSensitive: false),
  'analytics': RegExp('analytics', caseSensitive: false),
  'http(s):// literal': RegExp(r'''['"]https?://'''),
};

List<String> networkTraces(String source) {
  final String code = stripComments(source);
  return <String>[
    for (final MapEntry<String, RegExp> e in _networkTraces.entries)
      if (e.value.hasMatch(code)) e.key,
  ];
}

List<File> _dartFilesIn(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList()
      ..sort((File a, File b) => a.path.compareTo(b.path));

final RegExp _cameraConsumer = RegExp(
  r'\b(PoseSource|PoseFrame|CameraPoseSource)\b|motion_camera|package:camera',
);

/// The one named exemption from discovery. `lib/main.dart` is account and
/// session code (Supabase auth); it only hands the
/// `PoseSource Function()? poseSourceLoader` type on to the shell and never
/// touches frames or landmarks. The exemption holds only while main.dart
/// stays free of [_frameLevelTokens] (see the guard test): if one appears,
/// main.dart re-enters the scanned set and the scan fails on its Supabase code.
const String _exemptFromDiscovery = 'lib/main.dart';

final RegExp _frameLevelTokens = RegExp(
  r'\b(PoseFrame|CameraPoseSource|SourceFrameEvent|PoseSourceEvent)\b|'
  r'Landmark|poseSourceLoader\s*(!|\?)?\s*\(\s*\)\s*(!|\?)?\s*\.|\.events\s*\(|'
  r'motion_camera|package:camera',
);

bool _isExempt(File f) =>
    _rel(f) == _exemptFromDiscovery &&
    !_frameLevelTokens.hasMatch(stripComments(f.readAsStringSync()));

/// Fixed camera files plus DISCOVERY: any file under lib/ or the engine that
/// mentions a pose source, a pose frame or the camera plugins.
List<File> _cameraDataPathFiles() {
  final Map<String, File> found = <String, File>{
    for (final File f in <File>[
      ..._dartFilesIn('lib/app/camera'),
      File('lib/app/camera_pose_source.dart'),
      File('lib/app/pose_model.dart'),
      ..._dartFilesIn('packages/lissom_engine/lib/src/camera'),
      for (final File f in <File>[
        ..._dartFilesIn('lib'),
        ..._dartFilesIn('packages/lissom_engine/lib'),
      ])
        if (_cameraConsumer.hasMatch(stripComments(f.readAsStringSync())) &&
            !_isExempt(f))
          f,
    ])
      _rel(f): f,
  };
  return found.values.toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));
}

String _rel(File f) => f.path.replaceAll('\\', '/');

void main() {
  group('egress: frames and landmarks stay on the device', () {
    // Limit: counts dart:io HttpClient creation only; not raw sockets, native
    // channels, motion_camera native code or TTS. FakePoseSource feeds the
    // coach, the real CameraPoseSource does not run. TEST_ONLY.
    testWidgets('a coached hold (fake source) creates zero dart:io '
        'HttpClients while frames flow', (t) async {
      _tall(t);
      final HttpOverrides? previous = HttpOverrides.current;
      final _CountingHttpOverrides counter = _CountingHttpOverrides(previous);
      HttpOverrides.global = counter;
      addTearDown(() => HttpOverrides.global = previous);

      final CameraPoseCatalog cat = _catalog();
      await t.pumpWidget(
        _app(
          CameraCoachScreen(
            catalog: cat,
            pose: cat.pose('mountain')!,
            sourceFactory: () => FakePoseSource(_frames(20)),
            speaker: _Speaker(),
          ),
        ),
      );
      await t.pumpAndSettle();

      // Positive anchor: the coach really consumed the frames.
      expect(find.byKey(const Key('camera.coach.done')), findsOneWidget);
      expect(find.text('Held 15 of 15 seconds'), findsOneWidget);
      expect(counter.clients, 0);
    });

    test('discovered camera/pose-consuming sources carry no network trace', () {
      final List<File> files = _cameraDataPathFiles();
      final Set<String> names = files.map((File f) => _rel(f)).toSet();
      expect(files, isNotEmpty);
      expect(
        names,
        containsAll(<String>[
          'lib/app/live_capture_screen.dart',
          'lib/app/camera_pose_source.dart',
          'lib/app/camera/lesson_camera_section.dart',
          'lib/app/camera/camera_coach_screen.dart',
          'packages/lissom_engine/lib/src/live_evaluator.dart',
          'lib/app/pose_model.dart',
          'packages/lissom_engine/lib/src/camera/camera_coach.dart',
        ]),
      );
      final Map<String, List<String>> hits = <String, List<String>>{
        for (final File f in files)
          if (networkTraces(f.readAsStringSync()).isNotEmpty)
            _rel(f): networkTraces(f.readAsStringSync()),
      };
      expect(hits, isEmpty);
    });

    test('exempt lib/main.dart mentions only the PoseSource type', () {
      final String code = stripComments(
        File(_exemptFromDiscovery).readAsStringSync(),
      );
      expect(code, contains('PoseSource'));
      expect(_frameLevelTokens.hasMatch(code), isFalse);
      expect(_isExempt(File(_exemptFromDiscovery)), isTrue);
      // Planted token: the exemption must drop.
      expect(_frameLevelTokens.hasMatch('$code\nPoseFrame f;'), isTrue);
      // Reaching the frame stream without naming PoseFrame must drop it too
      // (reviewer note: `poseSourceLoader!().events().listen(...)`).
      expect(
        _frameLevelTokens.hasMatch('$code\nx = poseSourceLoader!().events();'),
        isTrue,
      );
      expect(
        _frameLevelTokens.hasMatch('$code\ns.events().listen((e) {});'),
        isTrue,
      );
      expect(
        _frameLevelTokens.hasMatch('$code\nfinal e = SourceFrameEvent;'),
        isTrue,
      );
    });

    test('the scanner itself catches planted traces and ignores comments', () {
      expect(networkTraces('final c = HttpClient();'), contains('HttpClient'));
      expect(networkTraces("import 'package:http/http.dart';"), isNotEmpty);
      expect(networkTraces("const u = 'https://example.com/x';"), isNotEmpty);
      expect(networkTraces('await s.upload(bytes);'), isNotEmpty);
      expect(networkTraces('final s = WebSocket.connect(u);'), isNotEmpty);
      expect(networkTraces('final x = Supabase.instance;'), isNotEmpty);
      expect(
        networkTraces("import 'package:web_socket_channel/io.dart';"),
        isNotEmpty,
      );
      expect(
        networkTraces('final s = await HttpServer.bind(a, 1);'),
        isNotEmpty,
      );
      expect(
        networkTraces('final a = InternetAddress.loopbackIPv4;'),
        isNotEmpty,
      );
      expect(
        networkTraces('await Process.run("curl", <String>[]);'),
        isNotEmpty,
      );
      expect(
        networkTraces('final s = await RawSocket.connect(a, 1);'),
        isNotEmpty,
      );
      expect(
        networkTraces('/// see https://example.com/docs\n// HttpClient\n'),
        isEmpty,
      );
      expect(
        networkTraces('/* HttpClient\n https://x */\nfinal a = 1;'),
        isEmpty,
      );
    });
  });

  group('permission refused: the lesson goes on without the camera', () {
    testWidgets('Ashtanga a03: refused camera shows the card, lesson still '
        'records practice', (t) async {
      _tall(t);
      final HathaCourse course = _ashtanga();
      expect(HathaSessionPreparation.requiredFor('a03'), isFalse);
      final _Store store = _Store();
      await t.pumpWidget(
        _lessonLauncher(
          course: course,
          lessonId: 'a03',
          store: store,
          cameraTrialOpen: true,
          catalogLoader: () async => _catalog(),
          sourceFactory: _denied,
        ),
      );
      await t.tap(find.byKey(const Key('test.open')));
      await t.pumpAndSettle();

      final Finder start = find.byWidgetPredicate(
        (Widget w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(
              'camera.lesson.start.',
            ),
      );
      expect(start, findsWidgets);
      await t.ensureVisible(start.first);
      await t.tap(start.first);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('camera.coach.permission')), findsOneWidget);
      expect(find.byKey(const Key('camera.coach.settings')), findsOneWidget);

      await t.pageBack();
      await t.pumpAndSettle();

      expect(find.byType(HathaLessonScreen), findsOneWidget);
      expect(find.byKey(LessonCameraSection.sectionKey), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.byKey(const Key('camera.lesson.failed')), findsNothing);
      expect(t.takeException(), isNull);

      // Reflection and practice still work, and the refusal does not block
      // the practice record.
      final Finder reflect = find.byKey(HathaLessonScreen.reflectionKey);
      await t.ensureVisible(reflect);
      await t.tap(reflect);
      await t.pumpAndSettle();
      final Finder practice = find.byKey(HathaLessonScreen.practiceKey);
      await t.ensureVisible(practice);
      expect(t.widget<FilledButton>(practice).onPressed, isNotNull);
      await t.tap(practice);
      await t.pumpAndSettle();
      expect(store.marked, 1);
      expect(t.takeException(), isNull);
    });

    testWidgets('a refused mirror names the refusal, section stays put', (
      t,
    ) async {
      _tall(t);
      await t.pumpWidget(
        _app(
          Scaffold(
            body: LessonCameraSection(
              courseId: 'lissom.ashtanga.foundations.beginner',
              lessonId: 'a03',
              canStart: true,
              catalogLoader: () async => _catalog(),
              mirrorCamera: _RefusedMirror.new,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.byKey(const Key('camera.lesson.mirror')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('camera.mirror.settings')), findsOneWidget);
      expect(find.byKey(const Key('camera.mirror.status')), findsOneWidget);

      await t.tap(find.byKey(const Key('camera.mirror.back')));
      await t.pumpAndSettle();
      expect(find.byKey(LessonCameraSection.sectionKey), findsOneWidget);
      expect(find.byKey(const Key('camera.lesson.mirror')), findsOneWidget);
      expect(find.byKey(const Key('camera.lesson.failed')), findsNothing);
      expect(t.takeException(), isNull);
    });
  });

  group('flag closed: the camera path is not triggered', () {
    Future<void> check(
      WidgetTester t,
      HathaCourse course,
      String lessonId,
    ) async {
      _tall(t);
      int loaderCalls = 0;
      int factoryCalls = 0;
      await t.pumpWidget(
        _lessonLauncher(
          course: course,
          lessonId: lessonId,
          store: _Store(),
          // cameraTrialOpen left out: default (closed).
          catalogLoader: () async {
            loaderCalls++;
            return _catalog();
          },
          sourceFactory: () {
            factoryCalls++;
            return FakePoseSource(const <PoseSourceEvent>[]);
          },
        ),
      );
      await t.tap(find.byKey(const Key('test.open')));
      await t.pumpAndSettle();
      expect(find.byType(HathaLessonScreen), findsOneWidget);
      expect(find.byKey(LessonCameraSection.sectionKey), findsNothing);
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('camera.lesson.'),
        ),
        findsNothing,
      );
      expect(find.byKey(const Key('yoga.lesson.availability')), findsOneWidget);
      expect(loaderCalls, 0);
      expect(factoryCalls, 0);
    }

    testWidgets('control: with the flag open the same rig fires the loader '
        'and the source factory (counters can fire)', (t) async {
      _tall(t);
      int loaderCalls = 0;
      int factoryCalls = 0;
      await t.pumpWidget(
        _lessonLauncher(
          course: _ashtanga(),
          lessonId: 'a03',
          store: _Store(),
          cameraTrialOpen: true,
          catalogLoader: () async {
            loaderCalls++;
            return _catalog();
          },
          sourceFactory: () {
            factoryCalls++;
            return FakePoseSource(const <PoseSourceEvent>[]);
          },
        ),
      );
      await t.tap(find.byKey(const Key('test.open')));
      await t.pumpAndSettle();
      expect(loaderCalls, 1);
      expect(factoryCalls, 0);
      final Finder start = find.byWidgetPredicate(
        (Widget w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(
              'camera.lesson.start.',
            ),
      );
      await t.ensureVisible(start.first);
      await t.tap(start.first);
      await t.pumpAndSettle();
      expect(find.byType(CameraCoachScreen), findsOneWidget);
      expect(factoryCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('lesson in the camera catalog (a03)', (t) async {
      await check(t, _ashtanga(), 'a03');
    });

    testWidgets('lesson outside the camera catalog (h31)', (t) async {
      await check(t, _hatha(), 'h31');
    });

    test('catalog membership is what the two tests above assume', () {
      final CameraPoseCatalog cat = _catalog();
      expect(
        cat.posesForLesson('lissom.ashtanga.foundations.beginner', 'a03'),
        isNotEmpty,
      );
      expect(cat.posesForLesson('lissom.hatha.foundations', 'h31'), isEmpty);
    });

    test('camera screens are constructed only where expected', () {
      final List<File> all = _dartFilesIn('lib');
      expect(all, isNotEmpty);
      Set<String> callers(String name) => <String>{
        for (final File f in all)
          if (RegExp(
            '\\b$name\\(',
          ).hasMatch(stripComments(f.readAsStringSync())))
            _rel(f),
      };
      expect(callers('LessonCameraSection'), <String>{
        'lib/app/camera/lesson_camera_section.dart',
        'lib/app/hatha_course_screen.dart',
      });
      expect(callers('CameraCoachScreen'), <String>{
        'lib/app/camera/camera_coach_screen.dart',
        'lib/app/camera/lesson_camera_section.dart',
      });
      expect(callers('MirrorScreen'), <String>{
        'lib/app/camera/mirror_screen.dart',
        'lib/app/camera/lesson_camera_section.dart',
      });

      // The single LessonCameraSection call is guarded by the flag.
      final String screen = File(
        'lib/app/hatha_course_screen.dart',
      ).readAsStringSync();
      expect(
        RegExp(r'\bLessonCameraSection\(').allMatches(screen),
        hasLength(1),
      );
      expect(
        RegExp(
          r'if \(widget\.cameraTrialOpen\)\s*LessonCameraSection\(',
        ).hasMatch(screen),
        isTrue,
      );
    });

    test(
      'the trial flag constant appears only in policy and lesson screen',
      () {
        final Set<String> users = <String>{
          for (final File f in _dartFilesIn('lib'))
            if (stripComments(
              f.readAsStringSync(),
            ).contains('lissomCameraCoachingTrialOpen'))
              _rel(f),
        };
        expect(users, <String>{
          'lib/app/lissom_release_policy.dart',
          'lib/app/hatha_course_screen.dart',
        });
        expect(lissomCameraCoachingTrialOpen, isFalse);
      },
    );
  });
}
