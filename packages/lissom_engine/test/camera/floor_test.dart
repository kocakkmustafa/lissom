import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

import 'side_figure.dart';

CameraPoseCatalog _catalog() => CameraPoseCatalog.parse(
  File('../../config/yoga/camera-poses.v1.json').readAsStringSync(),
);

void main() {
  test('floor poses are in the catalog with their own setup', () {
    final CameraPoseCatalog cat = _catalog();
    final List<CameraPoseSpec> floor = <CameraPoseSpec>[
      for (final CameraPoseSpec p in cat.poses)
        if (p.posture == CameraPosture.floor) p,
    ];
    expect(floor.length, 15);
    expect(cat.poses.length, 35);
    expect(cat.setup.minFloorExtent, lessThan(cat.setup.maxFloorExtent));
  });

  test('lying flat is lying rest, not knees-to-chest or bridge', () {
    final CameraPoseCatalog cat = _catalog();
    final Map<String, double>? f = cameraFrameFeatures(
      lyingFigure(),
      kPortrait,
    );
    expect(cat.pose('lying-rest')!.inPose(f), isTrue);
    expect(cat.pose('knees-to-chest')!.inPose(f), isFalse);
    expect(cat.pose('small-bridge')!.inPose(f), isFalse);
    expect(cat.pose('mountain')!.inPose(f), isFalse);
  });

  test('knees toward the chest and a small bridge are told apart', () {
    final CameraPoseCatalog cat = _catalog();
    final Map<String, double>? k = cameraFrameFeatures(
      lyingFigure(kneesUp: true),
      kPortrait,
    );
    final Map<String, double>? b = cameraFrameFeatures(
      lyingFigure(hipsLifted: true),
      kPortrait,
    );
    expect(cat.pose('knees-to-chest')!.inPose(k), isTrue);
    expect(cat.pose('lying-rest')!.inPose(k), isFalse);
    expect(cat.pose('small-bridge')!.inPose(b), isTrue);
  });

  test('floor setup uses body length, not standing height', () {
    final CameraSetupLimits s = _catalog().setup;
    final frame = lyingFigure();
    expect(
      cameraSetupIssue(frame, kPortrait, s, posture: CameraPosture.floor),
      isNull,
    );
    // The same lying body fails the standing check (too short top to toe).
    expect(cameraSetupIssue(frame, kPortrait, s), isNotNull);
  });

  test('floor coach confirms lying rest and counts the hold', () {
    final CameraPoseCatalog cat = _catalog();
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('lying-rest')!,
    );
    CameraCoachState? last;
    for (int i = 0; i < 40 * 30; i++) {
      last = coach.add(lyingFigure(tUs: i * 33333), kPortrait, i * 33333);
    }
    expect(last!.phase, CameraCoachPhase.done);
  });
}
