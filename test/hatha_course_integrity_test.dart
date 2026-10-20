import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/shell.dart';
import 'package:motion_content/motion_content.dart';

const String _manifestPath = 'assets/motion_content/manifest.json';

final class _CourseOverlayBundle extends CachingAssetBundle {
  _CourseOverlayBundle({
    this.courseBytes,
    this.missingManifest = false,
    this.missingCourse = false,
  });

  final Uint8List? courseBytes;
  final bool missingManifest;
  final bool missingCourse;
  final List<String> requestedPaths = <String>[];

  @override
  Future<ByteData> load(String key) {
    requestedPaths.add(key);
    if ((key == _manifestPath && missingManifest) ||
        (key == kHathaCourseAssetPath && missingCourse)) {
      throw StateError('asset unavailable: $key');
    }
    if (key == kHathaCourseAssetPath && courseBytes != null) {
      final Uint8List bytes = courseBytes!;
      return Future<ByteData>.value(
        ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes),
      );
    }
    return rootBundle.load(key);
  }
}

Future<ContentException> _blocked(_CourseOverlayBundle bundle) async {
  try {
    await loadVerifiedHathaCourse(bundle);
  } on ContentException catch (error) {
    return error;
  }
  throw StateError('Expected Hatha course integrity to block the bundle');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('real packaged manifest verifies the 60-lesson Hatha course', () async {
    final _CourseOverlayBundle bundle = _CourseOverlayBundle();
    final course = await loadVerifiedHathaCourse(bundle);

    expect(course.id, 'lissom.hatha.foundations');
    expect(course.modules, hasLength(10));
    expect(course.lessons, hasLength(60));
    expect(bundle.requestedPaths.first, _manifestPath);
    expect(
      bundle.requestedPaths.where((path) => path == kHathaCourseAssetPath),
      hasLength(2),
    );
  });

  test('same-length parseable course tamper is rejected by SHA', () async {
    final ByteData data = await rootBundle.load(kHathaCourseAssetPath);
    final Uint8List original = Uint8List.sublistView(data);
    final Uint8List changed = Uint8List.fromList(original);
    changed[changed.length - 1] = original.last == 10 ? 32 : 10;
    expect(changed.length, original.length);
    expect(() => jsonDecode(utf8.decode(changed)), returnsNormally);

    final _CourseOverlayBundle bundle = _CourseOverlayBundle(
      courseBytes: changed,
    );
    final ContentException error = await _blocked(bundle);
    expect(error.error.code, ContentErrorCode.hashMismatch);
    expect(bundle.requestedPaths, contains(kHathaCourseAssetPath));
  });

  test('truncated course is rejected by byte length', () async {
    final ByteData data = await rootBundle.load(kHathaCourseAssetPath);
    final Uint8List original = Uint8List.sublistView(data);
    final _CourseOverlayBundle bundle = _CourseOverlayBundle(
      courseBytes: Uint8List.fromList(original.sublist(0, original.length - 1)),
    );

    final ContentException error = await _blocked(bundle);
    expect(error.error.code, ContentErrorCode.sizeMismatch);
  });

  test('missing manifest and course stay named read failures', () async {
    final _CourseOverlayBundle missingManifest = _CourseOverlayBundle(
      missingManifest: true,
    );
    final ContentException manifestError = await _blocked(missingManifest);
    expect(manifestError.error.code, ContentErrorCode.missingAsset);
    expect(missingManifest.requestedPaths, <String>[_manifestPath]);

    final _CourseOverlayBundle missingCourse = _CourseOverlayBundle(
      missingCourse: true,
    );
    final ContentException courseError = await _blocked(missingCourse);
    expect(courseError.error.code, ContentErrorCode.missingAsset);
    expect(missingCourse.requestedPaths, contains(kHathaCourseAssetPath));
  });

  testWidgets('boot surface names course integrity failure', (
    WidgetTester tester,
  ) async {
    final ByteData data = await rootBundle.load(kHathaCourseAssetPath);
    final Uint8List changed = Uint8List.fromList(Uint8List.sublistView(data));
    changed[changed.length - 1] = changed.last == 10 ? 32 : 10;
    final _CourseOverlayBundle bundle = _CourseOverlayBundle(
      courseBytes: changed,
    );
    const String privateDetail = 'PRIVATE fixture course integrity detail';
    int loads = 0;
    final List<ContentErrorCode> failures = <ContentErrorCode>[];
    Future<AppFacts> loader() async {
      loads++;
      try {
        return await AppFacts.load(bundle: bundle);
      } on ContentException catch (error) {
        failures.add(error.error.code);
        throw StateError('$privateDetail: $error');
      }
    }

    await tester.pumpWidget(
      MaterialApp(
        home: LissomShell(loader: loader),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shell.loadFailure')), findsOneWidget);
    expect(failures, <ContentErrorCode>[ContentErrorCode.hashMismatch]);
    expect(find.text("Lissom couldn't start"), findsOneWidget);
    expect(
      find.text(
        'The files that describe the tests and the app layout could not be read.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining(privateDetail), findsNothing);
    expect(find.textContaining('hashMismatch'), findsNothing);
    expect(bundle.requestedPaths, contains(_manifestPath));
    final Finder retry = find.byKey(const Key('shell.retryLoad'));
    expect(retry.hitTestable(), findsOneWidget);
    await tester.tap(retry.hitTestable());
    await tester.pumpAndSettle();
    expect(loads, 2);
    expect(failures, <ContentErrorCode>[
      ContentErrorCode.hashMismatch,
      ContentErrorCode.hashMismatch,
    ]);
    expect(find.byKey(const Key('shell.loadFailure')), findsOneWidget);
    expect(find.textContaining(privateDetail), findsNothing);
    expect(find.textContaining('hashMismatch'), findsNothing);
  });
}
