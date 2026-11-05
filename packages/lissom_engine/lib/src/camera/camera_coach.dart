/// Camera coaching for one pose: setup check → "in the pose" → hold timer →
/// one spoken correction at a time.
///
/// Targeted mode only (E07/E09: naming an unknown pose is unreliable): the
/// lesson says which pose is expected and the coach answers "you are / are
/// not in it". It never scores, never grades and never says a pose is good
/// for health. Corrections only ask for less range, softer joints or better
/// alignment (catalog rule). Pure Dart: frames in, states out; the app owns
/// the camera, the screen and the voice.
library;

import 'dart:math' as math;

import 'package:motion_core/motion_core.dart';

import 'camera_pose_catalog.dart';
import 'pose_features.dart';

/// Why the camera cannot judge yet. Each has its own sentence in the app.
enum CameraSetupIssue {
  /// No body found in the frame.
  noPerson,

  /// Head, hips, knees or ankles are missing or at the frame edge.
  bodyNotFull,

  /// The body is facing the camera; the lessons are judged from the side.
  notSideOn,

  /// The body fills too much of the frame.
  tooClose,

  /// The body is too small in the frame.
  tooFar,

  /// Landmarks are uncertain (usually low light or a busy background).
  unclearView,
}

/// Checks one frame against the setup limits. `null` = setup is fine.
CameraSetupIssue? cameraSetupIssue(
  PoseFrame? frame,
  FrameSize size,
  CameraSetupLimits limits,
) {
  if (frame == null) return CameraSetupIssue.noPerson;
  final List<int> req = limits.requiredLandmarks;
  final double mean =
      req.fold(0.0, (double a, int i) => a + frame.visibility(i)) / req.length;
  if (mean < 0.2) return CameraSetupIssue.noPerson;
  for (final int i in req) {
    final PoseLandmark l = frame[i];
    if (l.visibility < limits.minVisibility ||
        l.x < limits.edgeMargin ||
        l.x > 1 - limits.edgeMargin ||
        l.y < limits.edgeMargin ||
        l.y > 1 - limits.edgeMargin) {
      return CameraSetupIssue.bodyNotFull;
    }
  }
  if (mean < limits.minMeanVisibility) return CameraSetupIssue.unclearView;
  final double top = frame[Lm.nose].y;
  final double bottom = math.max(frame[Lm.leftAnkle].y, frame[Lm.rightAnkle].y);
  final double height = bottom - top;
  if (height > limits.maxBodyHeight) return CameraSetupIssue.tooClose;
  if (height < limits.minBodyHeight) return CameraSetupIssue.tooFar;
  final Map<String, double>? f = cameraFrameFeatures(frame, size);
  final double? ratio = f?[CameraFeature.shoulderWidthRatio];
  if (ratio == null || ratio > limits.maxShoulderWidthRatio) {
    return CameraSetupIssue.notSideOn;
  }
  return null;
}

/// Per-feature median over the frames of the last [seconds].
final class CameraFeatureWindow {
  CameraFeatureWindow({required this.seconds, required this.minFrames});

  final double seconds;
  final int minFrames;
  final List<(int, Map<String, double>)> _frames =
      <(int, Map<String, double>)>[];

  void add(int tUs, Map<String, double>? features) {
    if (features != null) _frames.add((tUs, features));
    final int cut = tUs - (seconds * 1e6).round();
    _frames.removeWhere(((int, Map<String, double>) e) => e.$1 < cut);
  }

  void clear() => _frames.clear();

  /// `null` until [minFrames] judgeable frames fall inside the window.
  Map<String, double>? median() {
    if (_frames.length < minFrames) return null;
    final Map<String, double> out = <String, double>{};
    for (final String k in CameraFeature.all) {
      final List<double> v = <double>[
        for (final (int, Map<String, double>) e in _frames) ?e.$2[k],
      ]..sort();
      if (v.isEmpty) continue;
      final int n = v.length;
      out[k] = n.isOdd ? v[n ~/ 2] : (v[n ~/ 2 - 1] + v[n ~/ 2]) / 2;
    }
    return out;
  }
}

enum CameraCoachPhase {
  /// Setup is not yet stable; nothing is judged.
  setup,

  /// Setup is fine; waiting for the expected pose.
  waiting,

  /// The pose was confirmed; the hold timer runs while it holds.
  holding,

  /// The hold time was reached.
  done,
}

final class CameraCoachState {
  const CameraCoachState({
    required this.phase,
    required this.setupIssue,
    required this.inPose,
    required this.heldSeconds,
    required this.targetSeconds,
    this.speak,
  });

  final CameraCoachPhase phase;

  /// Current setup problem, if any (also while holding: the timer pauses).
  final CameraSetupIssue? setupIssue;

  /// Whether the last window is in the expected pose.
  final bool inPose;
  final double heldSeconds;
  final int targetSeconds;

  /// A correction to say now (at most one per state, already rate-limited).
  final CameraCorrection? speak;
}

/// The coach for one pose. Feed it every frame in time order.
final class CameraCoach {
  CameraCoach({required this.catalog, required this.pose})
    : _window = CameraFeatureWindow(
        seconds: catalog.windowSeconds,
        minFrames: catalog.minWindowFrames,
      ),
      _voice = FeedbackPrioritizer(
        minConfidence: 0,
        globalCooldownUs: (catalog.cooldownSeconds * 1e6).round(),
        perCodeCooldownUs: (catalog.cooldownSeconds * 1e6).round(),
      );

  final CameraPoseCatalog catalog;
  final CameraPoseSpec pose;
  final CameraFeatureWindow _window;
  final FeedbackPrioritizer _voice;
  final Map<String, int> _spoken = <String, int>{};

  CameraCoachPhase _phase = CameraCoachPhase.setup;
  int? _setupOkSinceUs;
  int? _setupBadSinceUs;
  int? _inPoseSinceUs;
  int? _lastUs;
  double _held = 0;

  CameraCoachPhase get phase => _phase;

  CameraCoachState add(PoseFrame? frame, FrameSize size, int tUs) {
    final int dtUs = _lastUs == null ? 0 : math.max(0, tUs - _lastUs!);
    _lastUs = tUs;
    final CameraSetupIssue? issue = cameraSetupIssue(
      frame,
      size,
      catalog.setup,
    );
    final int stableUs = (catalog.setup.stableSeconds * 1e6).round();

    if (issue == null) {
      _setupBadSinceUs = null;
      _setupOkSinceUs ??= tUs;
    } else {
      _setupOkSinceUs = null;
      _setupBadSinceUs ??= tUs;
    }

    if (_phase == CameraCoachPhase.done) return _state(issue, false);

    if (_phase == CameraCoachPhase.setup) {
      if (_setupOkSinceUs != null && tUs - _setupOkSinceUs! >= stableUs) {
        _phase = CameraCoachPhase.waiting;
      } else {
        return _state(issue, false);
      }
    } else if (_setupBadSinceUs != null &&
        tUs - _setupBadSinceUs! >= stableUs) {
      // Lost the view for a while: back to setup. The held time is kept.
      _window.clear();
      _inPoseSinceUs = null;
      _phase = _held > 0 ? CameraCoachPhase.holding : CameraCoachPhase.setup;
      if (_phase == CameraCoachPhase.setup) return _state(issue, false);
    }

    _window.add(
      tUs,
      issue == null && frame != null ? cameraFrameFeatures(frame, size) : null,
    );
    final Map<String, double>? w = _window.median();
    final bool inPose = issue == null && pose.inPose(w);

    if (inPose) {
      _inPoseSinceUs ??= tUs;
    } else {
      _inPoseSinceUs = null;
    }

    if (_phase == CameraCoachPhase.waiting) {
      if (_inPoseSinceUs != null && tUs - _inPoseSinceUs! >= stableUs) {
        _phase = CameraCoachPhase.holding;
      }
      return _state(issue, inPose);
    }

    // Holding: time counts only while the pose holds.
    if (inPose) _held += dtUs / 1e6;
    if (_held >= pose.holdSeconds) {
      _held = pose.holdSeconds.toDouble();
      _phase = CameraCoachPhase.done;
      return _state(issue, inPose);
    }
    CameraCorrection? speak;
    if (inPose && _held >= catalog.firstDelaySeconds) {
      final CameraCorrection? c = pose.firstCorrection(w);
      if (c != null && (_spoken[c.id] ?? 0) < catalog.maxRepeatsPerHold) {
        final FeedbackDecision d = _voice.consider(<FeedbackCandidate>[
          FeedbackCandidate(
            code: c.id,
            severity: FeedbackSeverity.major,
            tUs: tUs,
          ),
        ], tUs);
        if (d.willSpeak) {
          _spoken[c.id] = (_spoken[c.id] ?? 0) + 1;
          speak = c;
        }
      }
    }
    return _state(issue, inPose, speak: speak);
  }

  CameraCoachState _state(
    CameraSetupIssue? issue,
    bool inPose, {
    CameraCorrection? speak,
  }) => CameraCoachState(
    phase: _phase,
    setupIssue: issue,
    inPose: inPose,
    heldSeconds: _held,
    targetSeconds: pose.holdSeconds,
    speak: speak,
  );
}
