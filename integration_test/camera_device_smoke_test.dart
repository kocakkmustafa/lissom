// Camera coaching trial — device smoke (no taps needed, no image leaves the
// phone: only numbers are reported, no screenshot of the camera screen).
//
// flutter drive --profile -d <device> \
//   --dart-define=LISSOM_CAMERA_TRIAL=true \
//   --driver=test_driver/camera_smoke_driver.dart \
//   --target=integration_test/camera_device_smoke_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lissom/app/camera/camera_coach_screen.dart';
import 'package:lissom/app/camera/coach_speaker.dart';
import 'package:lissom/app/camera_pose_source.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final class _SilentSpeaker implements CoachSpeaker {
  int said = 0;
  @override
  Future<void> speak(String text, Locale locale) async => said++;
  @override
  Future<void> stop() async {}
}

/// Records what the camera source delivers while the real screen runs.
final class _MeteredSource implements StartablePoseSource {
  _MeteredSource(this.inner);
  final CameraPoseSource inner;
  final List<int> frameUs = <int>[];
  final List<int> coachUs = <int>[];
  final Map<String, int> states = <String, int>{};
  FrameSize? size;
  late final CameraCoach probe;

  @override
  Stream<PoseSourceEvent> events() => inner.events().map((PoseSourceEvent e) {
    switch (e) {
      case SourceFrameEvent(frame: final PoseFrame f, size: final FrameSize z):
        frameUs.add(f.tUs);
        size = z;
        final Stopwatch sw = Stopwatch()..start();
        probe.add(f, z, f.tUs);
        coachUs.add(sw.elapsedMicroseconds);
      case SourceStateEvent(state: final LiveSessionState s):
        states[s.runtimeType.toString()] =
            (states[s.runtimeType.toString()] ?? 0) + 1;
    }
    return e;
  });

  @override
  Future<void> start() => inner.start();

  @override
  Future<void> dispose() => inner.dispose();
}

/// Numbers only: stderr (console) and Documents/lissom-camera-smoke.json,
/// read back with `xcrun devicectl device copy from`.
Future<void> _emit(Map<String, Object?> report) async {
  final String json = jsonEncode(report);
  stderr.writeln('LISSOM_SMOKE_JSON:$json');
  final Directory docs = await getApplicationDocumentsDirectory();
  await File('${docs.path}/lissom-camera-smoke.json').writeAsString(json);
}

int _median(List<int> v) {
  if (v.isEmpty) return -1;
  final List<int> s = List<int>.of(v)..sort();
  return s[s.length ~/ 2];
}

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final Map<String, Object?> report = <String, Object?>{};

  testWidgets('engine cost per frame on this device', (WidgetTester t) async {
    final CameraPoseCatalog cat = await loadCameraPoseCatalog();
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('mountain')!,
    );
    const FrameSize size = FrameSize(720, 1280);
    PoseFrame frame(int i) => PoseFrame(
      tUs: i * 33333,
      landmarks: <PoseLandmark>[
        for (int j = 0; j < Lm.count; j++)
          PoseLandmark(0.5 + 0.01 * (j % 3), 0.1 + 0.025 * j, 0, 0.9),
      ],
    );
    final List<PoseFrame> frames = <PoseFrame>[
      for (int i = 0; i < 3000; i++) frame(i),
    ];
    final Stopwatch sw = Stopwatch()..start();
    for (final PoseFrame f in frames) {
      coach.add(f, size, f.tUs);
    }
    sw.stop();
    report['engineUsPerFrame'] = sw.elapsedMicroseconds / frames.length;
    await _emit(report);
    expect(report['engineUsPerFrame']! as double, lessThan(5000));
  });

  testWidgets('real camera: start, preview texture, frame rate', (
    WidgetTester t,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    PermissionStatus perm = await Permission.camera.status;
    report['permissionBefore'] = perm.name;
    if (!perm.isGranted) {
      // A person must answer the system dialog; without one, stop here.
      perm = await Permission.camera.request().timeout(
        const Duration(seconds: 25),
        onTimeout: () => PermissionStatus.denied,
      );
      report['permissionAsked'] = true;
    }
    report['permission'] = perm.name;
    if (!perm.isGranted) {
      binding.reportData = report;
      await _emit(report);
      return;
    }
    final CameraPoseCatalog cat = await loadCameraPoseCatalog();
    final _MeteredSource src = _MeteredSource(CameraPoseSource(preview: true));
    src.probe = CameraCoach(catalog: cat, pose: cat.pose('mountain')!);
    final _SilentSpeaker speaker = _SilentSpeaker();
    await t.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: CameraCoachScreen(
          catalog: cat,
          pose: cat.pose('mountain')!,
          sourceFactory: () => src,
          speaker: speaker,
        ),
      ),
    );
    final Stopwatch wall = Stopwatch()..start();
    while (wall.elapsed < const Duration(seconds: 15)) {
      await t.pump(const Duration(milliseconds: 100));
    }
    final session = src.inner.session.value;
    report['sessionStarted'] = session != null;
    report['previewTextureId'] = session?.previewTextureId;
    report['sessionSize'] = session == null
        ? null
        : '${session.width}x${session.height}';
    report['mirrorShown'] = find
        .byKey(const Key('camera.coach.mirror'))
        .evaluate()
        .isNotEmpty;
    report['frames'] = src.frameUs.length;
    if (src.frameUs.length > 1) {
      report['fps'] =
          (src.frameUs.length - 1) /
          ((src.frameUs.last - src.frameUs.first) / 1e6);
    }
    report['coachUsMedian'] = _median(src.coachUs);
    report['sourceStates'] = src.states;
    report['spoken'] = speaker.said;
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    binding.reportData = report;
    // Without a driver (wireless device), the numbers go to a file.
    await _emit(report);
  });
}
