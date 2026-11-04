import 'dart:convert';
import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

import 'side_figure.dart';

CameraPoseCatalog _catalog() => CameraPoseCatalog.parse(
  File('../../config/yoga/camera-poses.v1.json').readAsStringSync(),
);

/// Feeds [seconds] of 30 fps frames from [make] and returns every state.
List<CameraCoachState> _run(
  CameraCoach coach,
  double seconds,
  PoseFrame Function(int tUs) make, {
  int startUs = 0,
}) => <CameraCoachState>[
  for (int i = 0; i < (seconds * 30).round(); i++)
    coach.add(make(startUs + i * 33333), kLandscape, startUs + i * 33333),
];

void main() {
  test('feature parity with the Python reference', () {
    final Map<String, dynamic> fx =
        jsonDecode(
              File(
                'test/fixtures/camera/feature_parity.v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    int judged = 0;
    for (final dynamic raw in fx['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      final PoseFrame frame = PoseFrame(
        tUs: 0,
        landmarks: <PoseLandmark>[
          for (final dynamic r in c['landmarks'] as List<dynamic>)
            PoseLandmark(
              ((r as List<dynamic>)[0] as num).toDouble(),
              (r[1] as num).toDouble(),
              (r[2] as num).toDouble(),
              (r[3] as num).toDouble(),
            ),
        ],
      );
      final Map<String, double>? got = cameraFrameFeatures(
        frame,
        FrameSize(c['width'] as int, c['height'] as int),
      );
      final Map<String, dynamic>? want = c['features'] as Map<String, dynamic>?;
      if (want == null) {
        expect(got, isNull);
        continue;
      }
      judged++;
      expect(got, isNotNull);
      expect(got!.keys.toSet(), want.keys.toSet());
      for (final String k in want.keys) {
        expect(got[k], closeTo((want[k] as num).toDouble(), 1e-6), reason: k);
      }
    }
    expect(judged, greaterThan(30));
  });

  test('catalog: at least 20 side-view poses, standing and chair', () {
    final CameraPoseCatalog cat = _catalog();
    expect(cat.poses.length, greaterThanOrEqualTo(20));
    expect(
      cat.poses.map((CameraPoseSpec p) => p.posture).toSet(),
      <CameraPosture>{CameraPosture.standing, CameraPosture.chair},
    );
    for (final CameraPoseSpec p in cat.poses) {
      expect(p.lessons, isNotEmpty, reason: p.id);
      expect(p.holdSeconds, inInclusiveRange(5, 30), reason: p.id);
    }
  });

  test('catalog refuses unknown features and empty checks', () {
    final Map<String, dynamic> j =
        jsonDecode(
              File('../../config/yoga/camera-poses.v1.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    ((j['poses'] as List<dynamic>).first
        as Map<String, dynamic>)['define'] = <dynamic>[
      <String, dynamic>{'feature': 'wristPoetry', 'min': 1},
    ];
    expect(
      () => CameraPoseCatalog.parse(jsonEncode(j)),
      throwsA(isA<FormatException>()),
    );
  });

  test('setup: front-facing, cut-off and far bodies are named', () {
    final CameraSetupLimits s = _catalog().setup;
    expect(cameraSetupIssue(sideFigure(), kLandscape, s), isNull);
    expect(
      cameraSetupIssue(sideFigure(frontFacing: true), kLandscape, s),
      CameraSetupIssue.notSideOn,
    );
    expect(
      cameraSetupIssue(sideFigure(visibility: 0.3), kLandscape, s),
      CameraSetupIssue.bodyNotFull,
    );
    expect(
      cameraSetupIssue(sideFigure(visibility: 0.6), kLandscape, s),
      CameraSetupIssue.unclearView,
    );
    expect(cameraSetupIssue(null, kLandscape, s), CameraSetupIssue.noPerson);
  });

  test('mountain: setup, confirm, hold to the target, then done', () {
    final CameraPoseCatalog cat = _catalog();
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('mountain')!,
    );
    final List<CameraCoachState> s = _run(
      coach,
      25,
      (int t) => sideFigure(tUs: t),
    );
    expect(s.first.phase, CameraCoachPhase.setup);
    expect(
      s.any((CameraCoachState x) => x.phase == CameraCoachPhase.holding),
      isTrue,
    );
    expect(s.last.phase, CameraCoachPhase.done);
    expect(s.last.heldSeconds, 15);
    expect(s.every((CameraCoachState x) => x.speak == null), isTrue);
  });

  test('timer does not run while out of the pose', () {
    final CameraPoseCatalog cat = _catalog();
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('mountain')!,
    );
    _run(coach, 6, (int t) => sideFigure(tUs: t));
    final double held = _run(
      coach,
      2,
      (int t) => sideFigure(tUs: t),
      startUs: 6000000,
    ).last.heldSeconds;
    // A deep forward fold is not mountain: the timer stops.
    final List<CameraCoachState> out = _run(
      coach,
      5,
      (int t) => sideFigure(tUs: t, trunkLeanDeg: 70),
      startUs: 8000000,
    );
    expect(out.last.inPose, isFalse);
    expect(out.last.heldSeconds, closeTo(held, 1.2));
    expect(out.last.phase, CameraCoachPhase.holding);
  });

  test('one correction at a time, rate-limited, at most twice', () {
    final CameraPoseCatalog cat = _catalog();
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('mountain')!,
    );
    // 10 degrees forward: still mountain (<=12) but outside the safe form (>7).
    final List<CameraCoachState> s = _run(
      coach,
      40,
      (int t) => sideFigure(tUs: t, trunkLeanDeg: 10),
    );
    final List<CameraCoachState> spoken = <CameraCoachState>[
      for (final CameraCoachState x in s)
        if (x.speak != null) x,
    ];
    expect(spoken, isNotEmpty);
    expect(spoken.length, lessThanOrEqualTo(cat.maxRepeatsPerHold));
    expect(spoken.first.speak!.id, 'mountain.0');
    expect(
      spoken.first.heldSeconds,
      greaterThanOrEqualTo(cat.firstDelaySeconds),
    );
  });

  test('targeted: arms raised is not mountain but is the arm-raise pose', () {
    final CameraPoseCatalog cat = _catalog();
    final Map<String, double>? f = cameraFrameFeatures(
      sideFigure(armRaiseDeg: 160),
      kLandscape,
    );
    expect(cat.pose('mountain')!.inPose(f), isFalse);
    expect(cat.pose('standing-arm-raise')!.inPose(f), isTrue);
  });

  test('chair seat is judged as seated, not standing', () {
    final CameraPoseCatalog cat = _catalog();
    final Map<String, double>? f = cameraFrameFeatures(
      sideFigure(seated: true),
      kLandscape,
    );
    expect(cat.pose('seated-upright')!.inPose(f), isTrue);
    expect(cat.pose('mountain')!.inPose(f), isFalse);
  });

  test('lessons map to poses; unmapped lessons get none', () {
    final CameraPoseCatalog cat = _catalog();
    expect(
      cat
          .posesForLesson('lissom.hatha.foundations', 'h03')
          .map((CameraPoseSpec p) => p.id),
      contains('mountain'),
    );
    expect(cat.posesForLesson('lissom.hatha.foundations', 'h29'), isEmpty);
  });
}
