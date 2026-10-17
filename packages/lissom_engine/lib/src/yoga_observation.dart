/// Selected-task observation plumbing, not a yoga classifier or form grade.
library;

import 'dart:convert';

import 'package:motion_core/motion_core.dart';

import 'live_evaluator.dart';

enum YogaObservationState { observed, uncertain, unobservable, unsupported }

enum YogaProviderMode { production, replay }

final class YogaTaskSpec {
  YogaTaskSpec({
    required this.id,
    required this.courseId,
    required this.courseVersion,
    required this.courseSha256,
    required this.lessonId,
    required this.variant,
    required List<String> views,
    required List<String> sides,
    required List<String> phases,
    required List<int> requiredLandmarks,
    required this.maxFrameGapUs,
  }) : views = List.unmodifiable(views),
       sides = List.unmodifiable(sides),
       phases = List.unmodifiable(phases),
       requiredLandmarks = List.unmodifiable(requiredLandmarks);

  final String id;
  final String courseId;
  final String courseVersion;
  final String courseSha256;
  final String lessonId;
  final String variant;
  final List<String> views;
  final List<String> sides;
  final List<String> phases;
  final List<int> requiredLandmarks;

  /// Technical continuity limit, not a physical hold/pose tolerance.
  final int maxFrameGapUs;

  bool accepts(YogaTaskSelection s) =>
      s.taskId == id &&
      s.courseId == courseId &&
      s.courseVersion == courseVersion &&
      s.courseSha256 == courseSha256 &&
      s.lessonId == lessonId &&
      s.variant == variant &&
      views.contains(s.view) &&
      sides.contains(s.actualSide);
}

final class YogaTaskSelection {
  const YogaTaskSelection({
    required this.taskId,
    required this.courseId,
    required this.courseVersion,
    required this.courseSha256,
    required this.lessonId,
    required this.variant,
    required this.view,
    required this.actualSide,
  });

  final String taskId;
  final String courseId;
  final String courseVersion;
  final String courseSha256;
  final String lessonId;
  final String variant;
  final String view;
  final String actualSide;
}

final class YogaTaskCatalog {
  YogaTaskCatalog(List<YogaTaskSpec> tasks) : tasks = List.unmodifiable(tasks);
  final List<YogaTaskSpec> tasks;

  factory YogaTaskCatalog.parse(String raw) {
    try {
      final json = jsonDecode(raw) as Map;
      if (json['id'] != 'lissom.yoga.tasks' ||
          json['schemaVersion'] != 1 ||
          json['contractVersion'] != '1.0.0' ||
          json['coordinateSpace'] != 'image2d.aspectCorrected') {
        throw const FormatException('unsupported yoga task contract');
      }
      final tasks = <YogaTaskSpec>[];
      final ids = <String>{};
      for (final value in json['tasks'] as List) {
        final v = value as Map;
        String text(String key) {
          final s = v[key] as String;
          if (s.isEmpty || s.trim() != s) throw FormatException(key);
          return s;
        }

        List<String> strings(String key) {
          final list = (v[key] as List).cast<String>();
          if (list.isEmpty ||
              list.toSet().length != list.length ||
              list.any((s) => s.isEmpty || s.trim() != s)) {
            throw FormatException(key);
          }
          return list;
        }

        final id = text('id');
        final sha = text('courseSha256');
        final phases = strings('phases');
        final views = strings('views');
        final sides = strings('sides');
        final required = strings(
          'requiredLandmarks',
        ).map(Lm.names.indexOf).toList();
        final gap = v['maxFrameGapUs'] as int;
        if (!ids.add(id) ||
            sha.length != 64 ||
            !RegExp(r'^[0-9a-f]+$').hasMatch(sha) ||
            phases.length < 2 ||
            required.any((i) => i < 0) ||
            gap <= 0 ||
            !views.every(const {'front', 'side'}.contains) ||
            !sides.every(const {'none', 'left', 'right'}.contains)) {
          throw const FormatException('invalid yoga task');
        }
        tasks.add(
          YogaTaskSpec(
            id: id,
            courseId: text('courseId'),
            courseVersion: text('courseVersion'),
            courseSha256: sha,
            lessonId: text('lessonId'),
            variant: text('variant'),
            views: views,
            sides: sides,
            phases: phases,
            requiredLandmarks: required,
            maxFrameGapUs: gap,
          ),
        );
      }
      return YogaTaskCatalog(tasks);
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('malformed yoga task catalog');
    }
  }

  static const runtimeAbi = 'lissom.yoga.phase.v1';
  static const inputSchema = 'body33.image.v1';
  static const coordinateSpace = 'image2d.aspectCorrected';

  /// Published shared contract; no artifact or acceptance receipt is supplied.
  MotionProviderManifest get deferredProviderManifest => MotionProviderManifest(
    providerId: 'lissom.yoga.deferred',
    providerVersion: '1.0.0',
    mode: MotionProviderMode.production,
    runtimeAbi: runtimeAbi,
    inputSchema: inputSchema,
    coordinateSpace: coordinateSpace,
    modelSha256: null,
    capabilities: {
      for (final task in tasks)
        task.id: const MotionCapability(
          state: MotionCapabilityState.calibrationRequired,
        ),
    },
  );

  Map<String, Object?> get deferredManifest =>
      deferredProviderManifest.toJson();

  /// Exact app-owned task binding is checked before the shared readiness gate.
  /// Null receipts are intentional: training and calibration remain deferred.
  MotionReadiness productionReadiness(YogaTaskSelection selection) {
    if (resolve(selection) == null) return MotionReadiness.unsupported;
    return MotionProviderRequirement(
      capability: selection.taskId,
      runtimeAbi: runtimeAbi,
      inputSchema: inputSchema,
      coordinateSpace: coordinateSpace,
      actualModelSha256: null,
      actualCalibrationSha256: null,
      reviewedAcceptanceSha256: null,
    ).inspect(deferredProviderManifest);
  }

  YogaTaskSpec? resolve(YogaTaskSelection selection) {
    for (final task in tasks) {
      if (task.accepts(selection)) return task;
    }
    return null;
  }
}

/// A provider owns the calibrated interpretation of the corrected 2D frame.
/// No implementation infers phases from ROM battery names or joint thresholds.
abstract interface class YogaPhaseProvider {
  YogaProviderMode get mode;
  String get identity;
  String? get modelSha256;
  String? get calibrationSha256;
  Future<YogaPhaseEvidence> interpret(
    PoseFrame correctedFrame,
    YogaTaskSelection task,
  );
  Future<void> close();
}

final class YogaPhaseEvidence {
  YogaPhaseEvidence({
    required this.state,
    required this.reason,
    required this.taskId,
    required this.variant,
    required this.view,
    required this.actualSide,
    this.phase,
    Set<int> observableLandmarks = const {},
  }) : observableLandmarks = Set.unmodifiable(observableLandmarks);
  final YogaObservationState state;
  final String reason;
  final String taskId;
  final String variant;
  final String view;
  final String actualSide;
  final String? phase;
  final Set<int> observableLandmarks;
}

final class YogaObservation {
  const YogaObservation({
    required this.state,
    required this.reason,
    required this.selection,
    required this.mode,
    required this.epoch,
    this.phase,
    this.startedAtUs,
    this.endedAtUs,
    this.sequenceObserved = false,
    this.modelSha256,
    this.calibrationSha256,
  });
  final YogaObservationState state;
  final String reason;
  final YogaTaskSelection selection;
  final YogaProviderMode mode;
  final int epoch;
  final String? phase;
  final int? startedAtUs;
  final int? endedAtUs;
  final bool sequenceObserved;
  final String? modelSha256;
  final String? calibrationSha256;
  int get progressEffect => 0;
  bool get establishesMastery => false;
}

/// Production is intentionally closed until a separately accepted provider,
/// calibration and reviewed acceptance are available. No production
/// constructor accepts a replay provider, manifest flag or fixture injection.
final class YogaObservationAdapter {
  YogaObservationAdapter.production({
    required this.catalog,
    required this.selection,
  }) : mode = YogaProviderMode.production,
       _provider = null;

  YogaObservationAdapter.replay({
    required this.catalog,
    required this.selection,
    required YogaPhaseProvider provider,
  }) : mode = YogaProviderMode.replay,
       _provider = provider {
    if (provider.mode != YogaProviderMode.replay) {
      throw ArgumentError(
        'replay constructor requires an explicit replay provider',
      );
    }
    _providerIdentity = provider.identity;
    _modelSha256 = provider.modelSha256;
    _calibrationSha256 = provider.calibrationSha256;
  }

  final YogaTaskCatalog catalog;
  final YogaTaskSelection selection;
  final YogaProviderMode mode;
  final YogaPhaseProvider? _provider;
  String? _providerIdentity;
  String? _modelSha256;
  String? _calibrationSha256;

  bool get _providerChanged =>
      _provider?.identity != _providerIdentity ||
      _provider?.modelSha256 != _modelSha256 ||
      _provider?.calibrationSha256 != _calibrationSha256;
  int _epoch = 0;
  int _phaseIndex = -1;
  int? _startedAtUs;
  int? _lastTUs;
  bool _busy = false;
  bool _closed = false;
  Future<void>? _closing;

  YogaObservation _result(
    YogaObservationState state,
    String reason, {
    String? phase,
    int? end,
    bool complete = false,
  }) => YogaObservation(
    state: state,
    reason: reason,
    selection: selection,
    mode: mode,
    epoch: _epoch,
    phase: phase,
    startedAtUs: state == YogaObservationState.observed ? _startedAtUs : null,
    endedAtUs: state == YogaObservationState.observed ? end : null,
    sequenceObserved: complete,
    modelSha256: _provider?.modelSha256,
    calibrationSha256: _provider?.calibrationSha256,
  );

  void _reset() {
    _phaseIndex = -1;
    _startedAtUs = null;
    _lastTUs = null;
  }

  /// Call synchronously on background, permission loss, account, task, view,
  /// model or calibration change. A retired adapter must never be reused.
  YogaObservation interrupt(String reason) {
    _epoch++;
    _reset();
    return _result(YogaObservationState.unobservable, reason);
  }

  Future<YogaObservation> process(PoseSourceEvent event) async {
    if (_closed) return _result(YogaObservationState.unsupported, 'closed');
    final spec = catalog.resolve(selection);
    if (spec == null) {
      return _result(YogaObservationState.unsupported, 'unsupportedTask');
    }
    final provider = _provider;
    if (provider == null) {
      return _result(YogaObservationState.unsupported, switch (catalog
          .productionReadiness(selection)) {
        MotionReadiness.calibrationRequired => 'calibrationRequired',
        MotionReadiness.unsupported => 'unsupportedTask',
        _ => 'providerUnavailable',
      });
    }
    if (provider.mode != mode || _providerChanged) {
      interrupt('providerChanged');
      return _result(YogaObservationState.unsupported, 'providerChanged');
    }
    if (event is! SourceFrameEvent) return interrupt('sourceInterrupted');
    if (_busy) return interrupt('overlappingFrames');
    final frame = event.frame;
    final size = event.size;
    if (frame.tUs < 0 ||
        frame.landmarks.length != Lm.count ||
        size.width <= 0 ||
        size.height <= 0 ||
        frame.landmarks.any(
          (p) =>
              !p.x.isFinite ||
              !p.y.isFinite ||
              !p.z.isFinite ||
              !p.visibility.isFinite ||
              p.visibility < 0 ||
              p.visibility > 1,
        )) {
      return interrupt('invalidFrame');
    }
    if (spec.requiredLandmarks.any(
      (i) =>
          frame[i].visibility <= 0 ||
          frame[i].x < 0 ||
          frame[i].x > 1 ||
          frame[i].y < 0 ||
          frame[i].y > 1,
    )) {
      return interrupt('missingLandmarks');
    }
    final last = _lastTUs;
    if (last != null &&
        (frame.tUs <= last || frame.tUs - last > spec.maxFrameGapUs)) {
      return interrupt('clockDiscontinuity');
    }
    _busy = true;
    final turn = _epoch;
    try {
      final evidence = await provider.interpret(
        frame.toIsotropic(size),
        selection,
      );
      if (_closed || turn != _epoch) {
        return _result(YogaObservationState.unobservable, 'retiredFrame');
      }
      if (_providerChanged || provider.mode != mode) {
        return interrupt('providerChanged');
      }
      _lastTUs = frame.tUs;
      if (evidence.taskId != spec.id ||
          evidence.variant != selection.variant ||
          evidence.view != selection.view ||
          evidence.actualSide != selection.actualSide) {
        return interrupt('wrongTaskBinding');
      }
      if (evidence.state != YogaObservationState.observed) {
        _reset();
        return _result(evidence.state, evidence.reason);
      }
      if (!spec.requiredLandmarks.every(
        evidence.observableLandmarks.contains,
      )) {
        return interrupt('missingLandmarks');
      }
      final phase = spec.phases.indexOf(evidence.phase ?? '');
      if (phase < 0 || (phase != _phaseIndex && phase != _phaseIndex + 1)) {
        return interrupt('phaseOrder');
      }
      if (_phaseIndex == -1) _startedAtUs = frame.tUs;
      _phaseIndex = phase;
      final complete = phase == spec.phases.length - 1;
      final result = _result(
        YogaObservationState.observed,
        'replayPhase',
        phase: evidence.phase,
        end: frame.tUs,
        complete: complete,
      );
      if (complete) _reset();
      return result;
    } on Object {
      if (_closed || turn != _epoch) {
        return _result(YogaObservationState.unobservable, 'retiredFrame');
      }
      return interrupt('providerError');
    } finally {
      _busy = false;
    }
  }

  Future<void> close() {
    final existing = _closing;
    if (existing != null) return existing;
    _closed = true;
    interrupt('closed');
    return _closing = Future<void>.sync(() async {
      await _provider?.close();
    });
  }
}
