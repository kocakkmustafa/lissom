import 'dart:math' as math;

import 'package:motion_core/motion_core.dart';

/// Landscape phone frame, as the setup screen asks for.
const FrameSize kLandscape = FrameSize(1920, 1080);

/// A synthetic person seen from the side, facing +x, standing upright.
/// Units are frame heights (isotropic); [frame] converts to MediaPipe's
/// normalized coordinates. [trunkLeanDeg] tilts the upper body forward
/// around the hips; [frontFacing] turns the shoulders to the camera.
PoseFrame sideFigure({
  int tUs = 0,
  double trunkLeanDeg = 0,
  double armRaiseDeg = 0,
  bool frontFacing = false,
  double visibility = 0.95,
  double scale = 1,
  bool seated = false,
  FrameSize size = kLandscape,
}) {
  final double cx = size.aspect / 2;
  final Map<int, (double, double)> p = <int, (double, double)>{};
  final double ankleY = 0.9;
  final double hipY = seated ? 0.62 : 0.47;
  final double kneeY = seated ? 0.62 : 0.68;
  final double kneeX = seated ? cx + 0.2 * scale : cx;
  final double ankleX = seated ? cx + 0.2 * scale : cx;
  final double hipX = cx;
  final double w = frontFacing ? 0.2 : 0.015;
  for (final (int l, int r, double x, double y) in <(int, int, double, double)>[
    (Lm.leftHip, Lm.rightHip, hipX, hipY),
    (Lm.leftKnee, Lm.rightKnee, kneeX, kneeY),
    (Lm.leftAnkle, Lm.rightAnkle, ankleX, ankleY),
    (Lm.leftHeel, Lm.rightHeel, ankleX - 0.02, ankleY + 0.02),
    (Lm.leftFootIndex, Lm.rightFootIndex, ankleX + 0.08, ankleY + 0.02),
  ]) {
    p[l] = (x - w / 2, y);
    p[r] = (x + w / 2, y);
  }
  // Upper body: rotate around the hip by the lean.
  final double a = trunkLeanDeg * math.pi / 180;
  (double, double) up(double dist, [double ahead = 0]) => (
    hipX + dist * math.sin(a) + ahead * math.cos(a),
    hipY - dist * math.cos(a) + ahead * math.sin(a),
  );
  final (double, double) sh = up(0.25 * scale);
  p[Lm.leftShoulder] = (sh.$1 - w / 2, sh.$2);
  p[Lm.rightShoulder] = (sh.$1 + w / 2, sh.$2);
  final (double, double) ear = up(0.32 * scale, 0.01);
  p[Lm.leftEar] = ear;
  p[Lm.rightEar] = ear;
  p[Lm.nose] = up(0.33 * scale, 0.04);
  for (final int i in <int>[1, 2, 3, 4, 5, 6, 9, 10]) {
    p[i] = up(0.33 * scale, 0.03);
  }
  // Arms: hang along the trunk, raised forward by armRaiseDeg.
  final double r = a + armRaiseDeg * math.pi / 180;
  for (final (int s, int e, int wr, int pk, int ix, int th)
      in const <(int, int, int, int, int, int)>[
        (
          Lm.leftShoulder,
          Lm.leftElbow,
          Lm.leftWrist,
          Lm.leftPinky,
          Lm.leftIndex,
          Lm.leftThumb,
        ),
        (
          Lm.rightShoulder,
          Lm.rightElbow,
          Lm.rightWrist,
          Lm.rightPinky,
          Lm.rightIndex,
          Lm.rightThumb,
        ),
      ]) {
    final (double, double) o = p[s]!;
    p[e] = (o.$1 + 0.14 * math.sin(r), o.$2 + 0.14 * math.cos(r));
    p[wr] = (o.$1 + 0.27 * math.sin(r), o.$2 + 0.27 * math.cos(r));
    p[pk] = p[wr]!;
    p[ix] = p[wr]!;
    p[th] = p[wr]!;
  }
  return PoseFrame(
    tUs: tUs,
    landmarks: <PoseLandmark>[
      for (int i = 0; i < Lm.count; i++)
        PoseLandmark(p[i]!.$1 / size.aspect, p[i]!.$2, 0, visibility),
    ],
  );
}
