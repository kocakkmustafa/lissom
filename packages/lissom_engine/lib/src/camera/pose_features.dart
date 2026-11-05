/// Side-view pose features for the camera coaching trial.
///
/// Reference implementation: `tool/camera_model/features.py`. Both must give
/// the same numbers for the same landmarks; `test/camera_feature_parity_test`
/// checks it against `test/fixtures/camera/feature_parity.v1.json`, which
/// the Python file writes.
///
/// Geometry uses Core's isotropic frame ([PoseFrame.toIsotropic]) and
/// [jointAngle2D]; this file only names which joints form which angle.
library;

import 'dart:math' as math;

import 'package:motion_core/motion_core.dart';

/// Feature names, in the order the config and the reference use them.
abstract final class CameraFeature {
  static const String trunkLean = 'trunkLean';
  static const String hip = 'hip';
  static const String kneeNear = 'kneeNear';
  static const String kneeMin = 'kneeMin';
  static const String kneeMax = 'kneeMax';
  static const String frontKnee = 'frontKnee';
  static const String rearKnee = 'rearKnee';
  static const String liftedKnee = 'liftedKnee';
  static const String standingKnee = 'standingKnee';
  static const String shoulderFlex = 'shoulderFlex';
  static const String elbow = 'elbow';
  static const String headDrop = 'headDrop';
  static const String thighFromVertical = 'thighFromVertical';
  static const String ankleLift = 'ankleLift';
  static const String stanceSplit = 'stanceSplit';
  static const String headBelowHip = 'headBelowHip';
  static const String shoulderWidthRatio = 'shoulderWidthRatio';
  static const String ankleDrop = 'ankleDrop';
  static const String facing = 'facing';

  static const List<String> all = <String>[
    trunkLean,
    hip,
    kneeNear,
    kneeMin,
    kneeMax,
    frontKnee,
    rearKnee,
    liftedKnee,
    standingKnee,
    shoulderFlex,
    elbow,
    headDrop,
    thighFromVertical,
    ankleLift,
    stanceSplit,
    headBelowHip,
    shoulderWidthRatio,
    ankleDrop,
    facing,
  ];
}

/// Computes the features of one frame. Returns `null` when the frame is not
/// judgeable (shoulders and hips not visible, or the torso too small).
/// A missing entry in the result means that feature's joints were not
/// visible; it is never replaced by zero.
Map<String, double>? cameraFrameFeatures(
  PoseFrame raw,
  FrameSize size, {
  double minVisibility = 0.5,
  double pairVisibility = 0.3,
}) {
  for (final int i in const <int>[
    Lm.leftShoulder,
    Lm.rightShoulder,
    Lm.leftHip,
    Lm.rightHip,
  ]) {
    if (raw.visibility(i) < minVisibility) return null;
  }
  final PoseFrame f = raw.toIsotropic(size);
  Vec3 p(int i) => Vec3.xy(f[i].x, f[i].y);
  bool ok(List<int> idx) =>
      idx.every((int i) => f.visibility(i) >= minVisibility);
  bool okPair(List<int> idx) =>
      idx.every((int i) => f.visibility(i) >= pairVisibility);
  double deg(double rad) => rad * radToDeg;

  final Vec3 sh = midpoint(p(Lm.leftShoulder), p(Lm.rightShoulder));
  final Vec3 hp = midpoint(p(Lm.leftHip), p(Lm.rightHip));
  final double torso = math.sqrt(
    (sh.x - hp.x) * (sh.x - hp.x) + (sh.y - hp.y) * (sh.y - hp.y),
  );
  if (torso < 0.03) return null;

  // Facing direction from the feet (toe ahead of heel), else the nose.
  double fx = 0;
  int n = 0;
  for (final (int heel, int toe) in const <(int, int)>[
    (Lm.leftHeel, Lm.leftFootIndex),
    (Lm.rightHeel, Lm.rightFootIndex),
  ]) {
    if (ok(<int>[heel, toe])) {
      fx += p(toe).x - p(heel).x;
      n++;
    }
  }
  if (n == 0 || (fx / n).abs() < 0.02 * torso) {
    fx = ok(const <int>[Lm.nose]) ? p(Lm.nose).x - sh.x : 0;
  }
  final double facing = fx > 0
      ? 1
      : fx < 0
      ? -1
      : 0;

  double sideScore(List<int> idx) =>
      idx.fold(0.0, (double a, int i) => a + f.visibility(i));
  final bool nearLeft =
      sideScore(const <int>[
        Lm.leftShoulder,
        Lm.leftHip,
        Lm.leftKnee,
        Lm.leftAnkle,
      ]) >=
      sideScore(const <int>[
        Lm.rightShoulder,
        Lm.rightHip,
        Lm.rightKnee,
        Lm.rightAnkle,
      ]);
  final int shI = nearLeft ? Lm.leftShoulder : Lm.rightShoulder;
  final int elI = nearLeft ? Lm.leftElbow : Lm.rightElbow;
  final int wrI = nearLeft ? Lm.leftWrist : Lm.rightWrist;
  final int hipI = nearLeft ? Lm.leftHip : Lm.rightHip;
  final int knI = nearLeft ? Lm.leftKnee : Lm.rightKnee;
  final int anI = nearLeft ? Lm.leftAnkle : Lm.rightAnkle;

  final Map<String, double> out = <String, double>{
    CameraFeature.facing: facing,
  };
  void put(String key, double v) {
    if (v.isFinite) out[key] = v;
  }

  final double dx = sh.x - hp.x;
  final double dy = sh.y - hp.y;
  final double trunk = math.atan2(facing * dx, -dy);
  if (facing != 0) put(CameraFeature.trunkLean, deg(trunk));
  if (ok(<int>[shI, hipI, knI])) {
    put(CameraFeature.hip, deg(jointAngle2D(p(shI), p(hipI), p(knI))));
    put(
      CameraFeature.thighFromVertical,
      deg(
        jointAngle2D(
          Vec3.xy(hp.x, hp.y) + (p(knI) - p(hipI)),
          Vec3.xy(hp.x, hp.y),
          Vec3.xy(hp.x, hp.y + 1),
        ),
      ),
    );
  }
  if (ok(<int>[hipI, knI, anI])) {
    put(CameraFeature.kneeNear, deg(jointAngle2D(p(hipI), p(knI), p(anI))));
  }
  double? kneeOf(int h, int k, int a) {
    if (!okPair(<int>[h, k, a])) return null;
    final double v = deg(jointAngle2D(p(h), p(k), p(a)));
    return v.isFinite ? v : null;
  }

  final double? kl = kneeOf(Lm.leftHip, Lm.leftKnee, Lm.leftAnkle);
  final double? kr = kneeOf(Lm.rightHip, Lm.rightKnee, Lm.rightAnkle);
  final List<double> knees = <double>[?kl, ?kr];
  if (knees.isNotEmpty) {
    put(CameraFeature.kneeMin, knees.reduce(math.min));
    put(CameraFeature.kneeMax, knees.reduce(math.max));
  }
  if (okPair(const <int>[Lm.leftAnkle, Lm.rightAnkle])) {
    final Vec3 la = p(Lm.leftAnkle);
    final Vec3 ra = p(Lm.rightAnkle);
    put(CameraFeature.ankleLift, (la.y - ra.y).abs() / torso);
    put(CameraFeature.stanceSplit, (la.x - ra.x).abs() / torso);
    if (kl != null && kr != null) {
      final bool liftedLeft = la.y < ra.y;
      put(CameraFeature.liftedKnee, liftedLeft ? kl : kr);
      put(CameraFeature.standingKnee, liftedLeft ? kr : kl);
      if (facing != 0) {
        final bool frontLeft = facing * (la.x - ra.x) > 0;
        put(CameraFeature.frontKnee, frontLeft ? kl : kr);
        put(CameraFeature.rearKnee, frontLeft ? kr : kl);
      }
    }
  }
  final List<double> flex = <double>[];
  for (final (int s, int e, int h) in const <(int, int, int)>[
    (Lm.leftShoulder, Lm.leftElbow, Lm.leftHip),
    (Lm.rightShoulder, Lm.rightElbow, Lm.rightHip),
  ]) {
    if (ok(<int>[s, e, h])) {
      final double a = deg(jointAngle2D(p(e), p(s), p(h)));
      if (a.isFinite) flex.add(a);
    }
  }
  if (flex.isNotEmpty) put(CameraFeature.shoulderFlex, flex.reduce(math.max));
  if (ok(<int>[shI, elI, wrI])) {
    put(CameraFeature.elbow, deg(jointAngle2D(p(shI), p(elI), p(wrI))));
  }
  final List<Vec3> ears = <Vec3>[
    for (final int i in const <int>[Lm.leftEar, Lm.rightEar])
      if (ok(<int>[i])) p(i),
  ];
  if (ears.isNotEmpty && facing != 0) {
    final double ex =
        ears.fold(0.0, (double a, Vec3 e) => a + e.x) / ears.length;
    final double ey =
        ears.fold(0.0, (double a, Vec3 e) => a + e.y) / ears.length;
    final double neck = math.atan2(facing * (ex - sh.x), -(ey - sh.y));
    final double d = deg(neck - trunk);
    put(CameraFeature.headDrop, _wrapDeg(d));
  }
  if (ok(const <int>[Lm.nose])) {
    put(CameraFeature.headBelowHip, (p(Lm.nose).y - hp.y) / torso);
  }
  put(
    CameraFeature.shoulderWidthRatio,
    (p(Lm.leftShoulder).x - p(Lm.rightShoulder).x).abs() / torso,
  );
  final List<double> ankleYs = <double>[
    for (final int i in const <int>[Lm.leftAnkle, Lm.rightAnkle])
      if (ok(<int>[i])) p(i).y,
  ];
  if (ankleYs.isNotEmpty) {
    // Lowest visible ankle below the hips, in torso lengths: standing
    // ~1.6-1.9, sitting on a chair ~0.8-1.1, sitting on the floor ~0.
    put(CameraFeature.ankleDrop, (ankleYs.reduce(math.max) - hp.y) / torso);
  }
  return out;
}

/// Python's `(d + 180) % 360 - 180` (result in [-180, 180)).
double _wrapDeg(double d) {
  final double m = (d + 180.0) % 360.0;
  return (m < 0 ? m + 360.0 : m) - 180.0;
}
