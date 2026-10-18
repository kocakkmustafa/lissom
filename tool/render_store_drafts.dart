// Explicit opt-in host UI drafts, never physical-device or signed-package proof.
// LISSOM_STORE_DRAFT_DIR=/absolute/output flutter test --no-pub tool/render_store_drafts.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ashtanga_course.dart';
import 'package:lissom/app/chair_office_course.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/vinyasa_course.dart';
import 'package:lissom/app/yin_course.dart';
import 'package:lissom_engine/lissom_engine.dart';

final class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

final class _ReadOnlyEmptyProgress implements HathaProgressStore {
  @override
  Future<HathaProgress> read() async =>
      const HathaProgress(records: [], unreadableRecords: 0);
  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) =>
      throw StateError('Draft renderer must not create practice history');
}

Future<AppFacts> _facts() async {
  final bundle = _DiskBundle();
  final battery = Battery.parseJson(
    File('config/tests/lissom-assessment.v1.json').readAsStringSync(),
  );
  return AppFacts(
    ia: LibraryIa.parseJson(
      File('config/ia/library.v1.json').readAsStringSync(),
    ),
    battery: battery,
    liveness: deriveLiveness(battery),
    history: const SessionHistoryView.ok([]),
    hatha: HathaCourse.parse(
      File('config/courses/hatha.v1.json').readAsStringSync(),
    ),
    chairOffice: await loadVerifiedChairOfficeCourse(bundle),
    vinyasa: await loadVerifiedVinyasaCourse(bundle),
    yin: await loadVerifiedYinCourse(bundle),
    ashtanga: await loadVerifiedAshtangaCourse(bundle),
    hathaProgress: const HathaProgress(records: [], unreadableRecords: 0),
  );
}

void main() {
  final output = Platform.environment['LISSOM_STORE_DRAFT_DIR'];
  if (output == null || !output.startsWith('/')) {
    throw StateError('Set an absolute LISSOM_STORE_DRAFT_DIR explicitly');
  }
  final directory = Directory(output);
  GoogleFonts.config.allowRuntimeFetching = false;
  for (final language in ['en', 'tr']) {
    testWidgets('host store drafts $language', (tester) async {
      tester.view.physicalSize = const Size(1290, 2796);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final loader = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await loader.load();
      });
      final facts = await tester.runAsync(_facts);
      expect(facts, isNotNull);
      final temporary = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('lissom-draft-'),
      ))!;
      addTearDown(() => temporary.delete(recursive: true));
      const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(pathChannel, (_) async => temporary.path);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(pathChannel, null),
      );
      final boundary = GlobalKey();

      Future<void> show(Widget body) async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  Container(
                    height: 24,
                    color: const Color(0xFF38313A),
                    alignment: Alignment.center,
                    child: Text(
                      language == 'tr'
                          ? 'YEREL HOST TASLAĞI • CİHAZ KANITI DEĞİL'
                          : 'LOCAL HOST DRAFT • NOT DEVICE EVIDENCE',
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      locale: Locale(language),
                      supportedLocales: const [Locale('en'), Locale('tr')],
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      theme: buildLissomTheme(),
                      home: body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          await GoogleFonts.pendingFonts();
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      Future<void> capture(String screen) async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await tester.runAsync(
          () => render.toImage(pixelRatio: 3),
        );
        final bytes = await tester.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.png),
        );
        await tester.runAsync(() async {
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$language-$screen.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
        });
        image!.dispose();
        expect(tester.takeException(), isNull);
      }

      await show(
        LissomShell(loader: () async => facts!, measurementAvailable: false),
      );
      await capture('home');
      await tester.tap(find.byType(NavigationDestination).at(1));
      await tester.pumpAndSettle();
      await capture('library');
      await tester.tap(find.byType(NavigationDestination).at(2));
      await tester.pumpAndSettle();
      await capture('progress-empty');
      await show(
        HathaLessonScreen(
          course: facts!.hatha!,
          lesson: facts.hatha!.lessonById('h01')!,
          store: _ReadOnlyEmptyProgress(),
          isRepeat: false,
        ),
      );
      await capture('written-lesson');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }
}
