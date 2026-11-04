/// The camera coaching catalog (`config/yoga/camera-poses.v1.json`).
///
/// Every number the camera uses lives in that file: pose families
/// (`define`), the lesson's safe form (`corrections`), setup limits and
/// speech timing. This file only reads it and refuses a malformed one.
library;

import 'dart:convert';

import 'pose_features.dart';

final class CameraRangeCheck {
  const CameraRangeCheck({required this.feature, this.min, this.max});

  final String feature;
  final double? min;
  final double? max;

  /// Missing value never passes: an unseen joint is not a correct joint.
  bool passes(double? value) {
    if (value == null) return false;
    if (min != null && value < min!) return false;
    if (max != null && value > max!) return false;
    return true;
  }

  static CameraRangeCheck fromJson(Map<String, dynamic> j) {
    final String feature = j['feature'] as String;
    if (!CameraFeature.all.contains(feature)) {
      throw FormatException('unknown camera feature "$feature"');
    }
    final double? min = (j['min'] as num?)?.toDouble();
    final double? max = (j['max'] as num?)?.toDouble();
    if (min == null && max == null) {
      throw FormatException('check on "$feature" has neither min nor max');
    }
    if (min != null && max != null && min > max) {
      throw FormatException('check on "$feature" has min > max');
    }
    return CameraRangeCheck(feature: feature, min: min, max: max);
  }
}

/// One spoken correction: fires when its feature leaves its range.
final class CameraCorrection {
  const CameraCorrection({
    required this.id,
    required this.check,
    required this.english,
    required this.turkish,
  });

  /// Stable code (`<pose>.<index>`); the wording is content, not identity.
  final String id;
  final CameraRangeCheck check;
  final String english;
  final String turkish;
}

final class CameraLessonRef {
  const CameraLessonRef(this.courseId, this.lessonId);
  final String courseId;
  final String lessonId;
}

enum CameraPosture { standing, chair, floor }

final class CameraPoseSpec {
  CameraPoseSpec({
    required this.id,
    required this.posture,
    required this.nameEnglish,
    required this.nameTurkish,
    required List<CameraLessonRef> lessons,
    required this.holdSeconds,
    required List<CameraRangeCheck> define,
    required List<CameraCorrection> corrections,
    this.yarProxy,
    this.evidence,
  }) : lessons = List.unmodifiable(lessons),
       define = List.unmodifiable(define),
       corrections = List.unmodifiable(corrections);

  final String id;
  final CameraPosture posture;
  final String nameEnglish;
  final String nameTurkish;
  final List<CameraLessonRef> lessons;
  final int holdSeconds;
  final List<CameraRangeCheck> define;
  final List<CameraCorrection> corrections;

  /// YAR class used to measure true accept offline; not used at runtime.
  final String? yarProxy;

  /// Offline evidence class (`independent-pass`, `in-data-below`, …); the
  /// whole feature is a trial whatever this says.
  final String? evidence;

  bool inPose(Map<String, double>? window) =>
      window != null && define.every((c) => c.passes(window[c.feature]));

  /// The first correction (priority order) whose feature is out of range.
  /// A feature that is not visible does not trigger a correction.
  CameraCorrection? firstCorrection(Map<String, double>? window) {
    if (window == null) return null;
    for (final CameraCorrection c in corrections) {
      final double? v = window[c.check.feature];
      if (v != null && !c.check.passes(v)) return c;
    }
    return null;
  }
}

final class CameraSetupLimits {
  const CameraSetupLimits({
    required this.requiredLandmarks,
    required this.minVisibility,
    required this.minMeanVisibility,
    required this.edgeMargin,
    required this.maxShoulderWidthRatio,
    required this.minBodyHeight,
    required this.maxBodyHeight,
    required this.stableSeconds,
    this.minFloorExtent = 0.30,
    this.maxFloorExtent = 0.98,
    this.maxFloorShoulderSpread = 0.45,
  });

  /// Floor poses (M2): body length along its longest image axis replaces
  /// head-to-ankle height, and 2-D shoulder spread replaces the horizontal
  /// shoulder width (a lying body is seen end-on along x).
  final double minFloorExtent;
  final double maxFloorExtent;
  final double maxFloorShoulderSpread;

  final List<int> requiredLandmarks;
  final double minVisibility;
  final double minMeanVisibility;
  final double edgeMargin;
  final double maxShoulderWidthRatio;
  final double minBodyHeight;
  final double maxBodyHeight;
  final double stableSeconds;
}

final class CameraPoseCatalog {
  CameraPoseCatalog({
    required this.version,
    required this.windowSeconds,
    required this.minWindowFrames,
    required this.setup,
    required this.cooldownSeconds,
    required this.maxRepeatsPerHold,
    required this.firstDelaySeconds,
    required List<CameraPoseSpec> poses,
  }) : poses = List.unmodifiable(poses);

  final String version;
  final double windowSeconds;
  final int minWindowFrames;
  final CameraSetupLimits setup;
  final double cooldownSeconds;
  final int maxRepeatsPerHold;
  final double firstDelaySeconds;
  final List<CameraPoseSpec> poses;

  CameraPoseSpec? pose(String id) {
    for (final CameraPoseSpec p in poses) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Poses the camera checks in this lesson, in catalog order. Empty = the
  /// camera does not assess this lesson (the app says so honestly).
  List<CameraPoseSpec> posesForLesson(String courseId, String lessonId) => [
    for (final CameraPoseSpec p in poses)
      if (p.lessons.any(
        (CameraLessonRef l) => l.courseId == courseId && l.lessonId == lessonId,
      ))
        p,
  ];

  static CameraPoseCatalog parse(String source) {
    final Map<String, dynamic> j = jsonDecode(source) as Map<String, dynamic>;
    if (j['schemaVersion'] != 1) {
      throw const FormatException('camera catalog schemaVersion must be 1');
    }
    if (j['view'] != 'side') {
      throw const FormatException('camera catalog supports the side view only');
    }
    final Map<String, dynamic> w = j['window'] as Map<String, dynamic>;
    final Map<String, dynamic> s = j['setup'] as Map<String, dynamic>;
    final Map<String, dynamic> sp = j['speech'] as Map<String, dynamic>;
    final Map<String, dynamic> fl =
        (j['setupFloor'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final Set<String> ids = <String>{};
    final List<CameraPoseSpec> poses = <CameraPoseSpec>[];
    for (final dynamic raw in j['poses'] as List<dynamic>) {
      final Map<String, dynamic> p = raw as Map<String, dynamic>;
      final String id = p['id'] as String;
      if (!ids.add(id)) throw FormatException('duplicate camera pose "$id"');
      final Map<String, dynamic> name = p['name'] as Map<String, dynamic>;
      final List<dynamic> corr = p['corrections'] as List<dynamic>;
      final List<dynamic> define = p['define'] as List<dynamic>;
      if (define.isEmpty) throw FormatException('pose "$id" defines nothing');
      poses.add(
        CameraPoseSpec(
          id: id,
          posture: CameraPosture.values.byName(p['posture'] as String),
          nameEnglish: name['en'] as String,
          nameTurkish: name['tr'] as String,
          lessons: <CameraLessonRef>[
            for (final dynamic l in p['lessons'] as List<dynamic>)
              CameraLessonRef(
                (l as Map<String, dynamic>)['course'] as String,
                l['lesson'] as String,
              ),
          ],
          holdSeconds: p['holdSeconds'] as int,
          define: <CameraRangeCheck>[
            for (final dynamic d in define)
              CameraRangeCheck.fromJson(d as Map<String, dynamic>),
          ],
          corrections: <CameraCorrection>[
            for (int i = 0; i < corr.length; i++)
              CameraCorrection(
                id: '$id.$i',
                check: CameraRangeCheck.fromJson(
                  corr[i] as Map<String, dynamic>,
                ),
                english:
                    ((corr[i] as Map<String, dynamic>)['say']
                            as Map<String, dynamic>)['en']
                        as String,
                turkish:
                    ((corr[i] as Map<String, dynamic>)['say']
                            as Map<String, dynamic>)['tr']
                        as String,
              ),
          ],
          yarProxy: p['yarProxy'] as String?,
          evidence: p['evidence'] as String?,
        ),
      );
    }
    return CameraPoseCatalog(
      version: j['version'] as String,
      windowSeconds: (w['seconds'] as num).toDouble(),
      minWindowFrames: w['minFrames'] as int,
      setup: CameraSetupLimits(
        requiredLandmarks: <int>[
          for (final dynamic i in s['requiredLandmarks'] as List<dynamic>)
            i as int,
        ],
        minVisibility: (s['minVisibility'] as num).toDouble(),
        minMeanVisibility: (s['minMeanVisibility'] as num).toDouble(),
        edgeMargin: (s['edgeMargin'] as num).toDouble(),
        maxShoulderWidthRatio: (s['maxShoulderWidthRatio'] as num).toDouble(),
        minBodyHeight: (s['minBodyHeight'] as num).toDouble(),
        maxBodyHeight: (s['maxBodyHeight'] as num).toDouble(),
        stableSeconds: (s['stableSeconds'] as num).toDouble(),
        minFloorExtent: (fl['minBodyExtent'] as num?)?.toDouble() ?? 0.30,
        maxFloorExtent: (fl['maxBodyExtent'] as num?)?.toDouble() ?? 0.98,
        maxFloorShoulderSpread:
            (fl['maxShoulderSpread'] as num?)?.toDouble() ?? 0.45,
      ),
      cooldownSeconds: (sp['cooldownSeconds'] as num).toDouble(),
      maxRepeatsPerHold: sp['maxRepeatsPerHold'] as int,
      firstDelaySeconds: (sp['firstDelaySeconds'] as num).toDouble(),
      poses: poses,
    );
  }
}
