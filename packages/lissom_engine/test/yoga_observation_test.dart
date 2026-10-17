import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

String catalogText() {
  final fromApp = File('config/yoga/tasks.v1.json');
  return (fromApp.existsSync()
          ? fromApp
          : File('../../config/yoga/tasks.v1.json'))
      .readAsStringSync();
}

YogaTaskSelection select(
  YogaTaskSpec spec, {
  String? variant,
  String? view,
  String? side,
  String? version,
  String? sha,
  String? lesson,
}) => YogaTaskSelection(
  taskId: spec.id,
  courseId: spec.courseId,
  courseVersion: version ?? spec.courseVersion,
  courseSha256: sha ?? spec.courseSha256,
  lessonId: lesson ?? spec.lessonId,
  variant: variant ?? spec.variant,
  view: view ?? spec.views.first,
  actualSide: side ?? spec.sides.first,
);

SourceFrameEvent frame(
  int t, {
  int? missing,
  bool invalid = false,
  FrameSize? size,
}) => SourceFrameEvent(
  PoseFrame(
    tUs: t,
    modelVersion: 'synthetic.fixture.only',
    landmarks: List.generate(
      Lm.count,
      (i) => PoseLandmark(
        invalid && i == 0 ? double.nan : .4,
        .4,
        0,
        i == missing ? 0 : 1,
      ),
    ),
  ),
  size: size ?? const FrameSize(640, 480),
);

YogaPhaseEvidence evidence(
  YogaTaskSpec spec,
  YogaTaskSelection task,
  String phase, {
  YogaObservationState state = YogaObservationState.observed,
  String? taskId,
  String? variant,
  String? view,
  String? side,
  Set<int>? visible,
}) => YogaPhaseEvidence(
  state: state,
  reason: 'synthetic.fixture.only',
  taskId: taskId ?? spec.id,
  variant: variant ?? task.variant,
  view: view ?? task.view,
  actualSide: side ?? task.actualSide,
  phase: phase,
  observableLandmarks: visible ?? spec.requiredLandmarks.toSet(),
);

/// Test-only decoder. Production has no dependency or reference to this type.
class ReplayProvider implements YogaPhaseProvider {
  ReplayProvider(this.next);
  Future<YogaPhaseEvidence> Function() next;
  @override
  YogaProviderMode mode = YogaProviderMode.replay;
  @override
  String identity = 'synthetic.replay.v1';
  @override
  String? modelSha256 = 'a' * 64;
  @override
  String? calibrationSha256 = 'b' * 64;
  PoseFrame? received;
  int calls = 0;
  int closes = 0;
  @override
  Future<YogaPhaseEvidence> interpret(
    PoseFrame correctedFrame,
    YogaTaskSelection task,
  ) {
    calls++;
    received = correctedFrame;
    return next();
  }

  @override
  Future<void> close() async {
    closes++;
  }
}

void main() {
  late YogaTaskCatalog catalog;
  late YogaTaskSpec spec;
  late YogaTaskSelection selection;
  late ReplayProvider provider;
  late YogaObservationAdapter adapter;
  setUp(() {
    catalog = YogaTaskCatalog.parse(catalogText());
    spec = catalog.tasks.first;
    selection = select(spec);
    provider = ReplayProvider(
      () async => evidence(spec, selection, spec.phases.first),
    );
    adapter = YogaObservationAdapter.replay(
      catalog: catalog,
      selection: selection,
      provider: provider,
    );
  });
  tearDown(() => adapter.close());

  test(
    'app deferred manifest uses the published shared contract and stays closed',
    () {
      final manifest = catalog.deferredProviderManifest;
      expect(MotionProviderManifest.contractVersion, '1.0.0');
      expect(manifest.mode, MotionProviderMode.production);
      expect(manifest.modelSha256, isNull);
      expect(manifest.capabilities.keys, catalog.tasks.map((task) => task.id));
      expect(() => manifest.capabilities.clear(), throwsUnsupportedError);
      expect(
        MotionProviderManifest.fromJson(catalog.deferredManifest).toJson(),
        manifest.toJson(),
      );
      for (final task in catalog.tasks) {
        expect(
          catalog.productionReadiness(select(task)),
          MotionReadiness.calibrationRequired,
        );
      }
    },
  );

  test(
    'wire mutation cannot relabel the app production declaration or enable it',
    () {
      final wire = catalog.deferredManifest..['mode'] = 'replay';
      final requirement = MotionProviderRequirement(
        capability: spec.id,
        runtimeAbi: YogaTaskCatalog.runtimeAbi,
        inputSchema: YogaTaskCatalog.inputSchema,
        coordinateSpace: YogaTaskCatalog.coordinateSpace,
        actualModelSha256: null,
        actualCalibrationSha256: null,
        reviewedAcceptanceSha256: null,
      );
      expect(
        requirement.inspect(MotionProviderManifest.fromJson(wire)),
        MotionReadiness.replayOnly,
      );
      expect(
        catalog.deferredProviderManifest.mode,
        MotionProviderMode.production,
      );
      expect(
        catalog.productionReadiness(selection),
        MotionReadiness.calibrationRequired,
      );
    },
  );

  test('app manifest refuses an incompatible phase runtime', () {
    final requirement = MotionProviderRequirement(
      capability: spec.id,
      runtimeAbi: 'other.runtime.v1',
      inputSchema: YogaTaskCatalog.inputSchema,
      coordinateSpace: YogaTaskCatalog.coordinateSpace,
      actualModelSha256: null,
      actualCalibrationSha256: null,
      reviewedAcceptanceSha256: null,
    );
    expect(
      requirement.inspect(catalog.deferredProviderManifest),
      MotionReadiness.incompatible,
    );
  });

  test(
    'versioned h03/h07 tasks declare explicit view, real side and phase order',
    () {
      expect(catalog.tasks.map((s) => s.lessonId), ['h03', 'h07']);
      expect(catalog.tasks.first.phases, ['entering', 'holding', 'exiting']);
      expect(catalog.tasks.last.phases, [
        'liftingArm',
        'sideReach',
        'centerReturn',
        'loweringArm',
      ]);
      expect(catalog.tasks.last.sides, ['left', 'right']);
      expect(() => spec.phases.clear(), throwsUnsupportedError);
    },
  );

  for (final key in [
    'id',
    'schemaVersion',
    'contractVersion',
    'coordinateSpace',
  ]) {
    test('unknown $key fails closed', () {
      final json = jsonDecode(catalogText()) as Map<String, dynamic>;
      json[key] = 'unknown';
      expect(
        () => YogaTaskCatalog.parse(jsonEncode(json)),
        throwsFormatException,
      );
    });
  }

  for (final key in [
    'phases',
    'requiredLandmarks',
    'courseSha256',
    'maxFrameGapUs',
  ]) {
    test('invalid $key is rejected', () {
      final json = jsonDecode(catalogText()) as Map<String, dynamic>;
      json['tasks'][0][key] = switch (key) {
        'phases' => ['same', 'same'],
        'requiredLandmarks' => ['nonexistent_joint'],
        'courseSha256' => 'unknown',
        _ => 0,
      };
      expect(
        () => YogaTaskCatalog.parse(jsonEncode(json)),
        throwsFormatException,
      );
    });
  }

  test(
    'unsupported variant/view/side/lesson/course version/hash never resolves',
    () {
      for (final task in [
        select(spec, variant: 'seated'),
        select(spec, view: 'side'),
        select(spec, side: 'left'),
        select(spec, lesson: 'h99'),
        select(spec, version: '9.0.0'),
        select(spec, sha: 'c' * 64),
      ]) {
        expect(catalog.resolve(task), isNull);
        expect(catalog.productionReadiness(task), MotionReadiness.unsupported);
      }
    },
  );

  test(
    'production has no provider injection and returns no phase/time/progress',
    () async {
      final production = YogaObservationAdapter.production(
        catalog: catalog,
        selection: selection,
      );
      final result = await production.process(frame(1));
      expect(result.state, YogaObservationState.unsupported);
      expect(result.reason, 'calibrationRequired');
      expect(result.mode, YogaProviderMode.production);
      expect(result.phase, isNull);
      expect(result.startedAtUs, isNull);
      expect(result.endedAtUs, isNull);
      expect(result.sequenceObserved, isFalse);
      expect(result.progressEffect, 0);
      expect(result.establishesMastery, isFalse);
      await production.close();
    },
  );

  test(
    'unsupported selection abstains before calling even a replay provider',
    () async {
      final other = YogaObservationAdapter.replay(
        catalog: catalog,
        selection: select(spec, variant: 'wall-supported'),
        provider: provider,
      );
      expect((await other.process(frame(1))).reason, 'unsupportedTask');
      expect(provider.calls, 0);
      await other.close();
    },
  );

  for (final lesson in ['h03', 'h07']) {
    test(
      '$lesson ordered sequence is labelled replay and cannot establish mastery',
      () async {
        final task = catalog.tasks.firstWhere((s) => s.lessonId == lesson);
        final selected = select(task);
        final decoder = ReplayProvider(
          () async => evidence(task, selected, task.phases.first),
        );
        final session = YogaObservationAdapter.replay(
          catalog: catalog,
          selection: selected,
          provider: decoder,
        );
        var t = 0;
        YogaObservation? last;
        for (final phase in task.phases) {
          decoder.next = () async => evidence(task, selected, phase);
          last = await session.process(frame(t += 100000));
          expect(last.state, YogaObservationState.observed);
          expect(last.mode, YogaProviderMode.replay);
          expect(last.progressEffect, 0);
          expect(last.establishesMastery, isFalse);
        }
        expect(last!.sequenceObserved, isTrue);
        expect(last.startedAtUs, 100000);
        expect(last.endedAtUs, task.phases.length * 100000);
        expect((await session.process(frame(t + 1))).reason, 'phaseOrder');
        await session.close();
      },
    );
  }

  test(
    'wrong phase order resets the sequence and requires a fresh entry',
    () async {
      await adapter.process(frame(1));
      provider.next = () async => evidence(spec, selection, spec.phases.last);
      expect((await adapter.process(frame(2))).reason, 'phaseOrder');
      provider.next = () async => evidence(spec, selection, spec.phases[1]);
      expect((await adapter.process(frame(3))).sequenceObserved, isFalse);
    },
  );

  for (final key in ['task', 'variant', 'view', 'side']) {
    test('wrong $key binding cannot continue the selected lesson', () async {
      await adapter.process(frame(1));
      provider.next = () async => evidence(
        spec,
        selection,
        spec.phases[1],
        taskId: key == 'task' ? 'other.task' : null,
        variant: key == 'variant' ? 'seated' : null,
        view: key == 'view' ? 'side' : null,
        side: key == 'side' ? 'right' : null,
      );
      final result = await adapter.process(frame(2));
      expect(result.reason, 'wrongTaskBinding');
      expect(result.sequenceObserved, isFalse);
      expect(result.startedAtUs, isNull);
    });
  }

  for (final state in [
    YogaObservationState.uncertain,
    YogaObservationState.unobservable,
    YogaObservationState.unsupported,
  ]) {
    test('$state clears the prior interval', () async {
      await adapter.process(frame(1));
      provider.next = () async =>
          evidence(spec, selection, spec.phases[1], state: state);
      final result = await adapter.process(frame(2));
      expect(result.state, state);
      expect(result.startedAtUs, isNull);
      expect(result.sequenceObserved, isFalse);
    });
  }

  test(
    'missing required landmark mask or clearly absent raw landmark abstains',
    () async {
      provider.next = () async =>
          evidence(spec, selection, spec.phases.first, visible: {});
      expect((await adapter.process(frame(1))).reason, 'missingLandmarks');
      final calls = provider.calls;
      expect(
        (await adapter.process(
          frame(2, missing: spec.requiredLandmarks.first),
        )).reason,
        'missingLandmarks',
      );
      expect(provider.calls, calls);
    },
  );

  test('nonfinite raw frame never reaches the provider', () async {
    expect(
      (await adapter.process(frame(1, invalid: true))).reason,
      'invalidFrame',
    );
    expect(provider.calls, 0);
  });

  test('backward/duplicate clock and a long frame gap reset timing', () async {
    await adapter.process(frame(10));
    expect((await adapter.process(frame(10))).reason, 'clockDiscontinuity');
    await adapter.process(frame(20));
    final result = await adapter.process(frame(20 + spec.maxFrameGapUs + 1));
    expect(result.reason, 'clockDiscontinuity');
    expect(result.startedAtUs, isNull);
  });

  for (final reason in [
    'background',
    'permissionDenied',
    'accountChanged',
    'taskChanged',
    'calibrationChanged',
  ]) {
    test('$reason clears timing and retires an in-flight callback', () async {
      final pending = Completer<YogaPhaseEvidence>();
      provider.next = () => pending.future;
      final future = adapter.process(frame(1));
      adapter.interrupt(reason);
      pending.complete(evidence(spec, selection, spec.phases.first));
      final result = await future;
      expect(result.reason, 'retiredFrame');
      expect(result.state, YogaObservationState.unobservable);
      expect(result.startedAtUs, isNull);
      expect(result.sequenceObserved, isFalse);
    });
  }

  test('source state interrupts an already observed sequence', () async {
    await adapter.process(frame(1));
    final result = await adapter.process(
      const SourceStateEvent(NoPersonDetected()),
    );
    expect(result.reason, 'sourceInterrupted');
    expect(result.startedAtUs, isNull);
  });

  for (final change in ['model', 'calibration', 'identity', 'mode']) {
    test('$change change requires a new adapter', () async {
      await adapter.process(frame(1));
      switch (change) {
        case 'model':
          provider.modelSha256 = 'c' * 64;
        case 'calibration':
          provider.calibrationSha256 = 'c' * 64;
        case 'identity':
          provider.identity = 'changed';
        case 'mode':
          provider.mode = YogaProviderMode.production;
      }
      final result = await adapter.process(frame(2));
      expect(result.reason, 'providerChanged');
      expect(result.sequenceObserved, isFalse);
    });
  }

  test(
    'aspect correction preserves explicit real side without an implicit mirror',
    () async {
      await adapter.process(frame(1, size: const FrameSize(960, 480)));
      expect(provider.received![0].x, closeTo(.8, 1e-9));
      expect(provider.received!.modelVersion, 'synthetic.fixture.only');
    },
  );

  test(
    'provider error and overlapping frames cannot complete a sequence',
    () async {
      provider.next = () async => throw StateError('synthetic failure');
      expect((await adapter.process(frame(1))).reason, 'providerError');
      final pending = Completer<YogaPhaseEvidence>();
      provider.next = () => pending.future;
      final old = adapter.process(frame(2));
      expect((await adapter.process(frame(3))).reason, 'overlappingFrames');
      pending.complete(evidence(spec, selection, spec.phases.first));
      expect((await old).reason, 'retiredFrame');
    },
  );

  test(
    'close is idempotent, rejects late output and closes the provider once',
    () async {
      final pending = Completer<YogaPhaseEvidence>();
      provider.next = () => pending.future;
      final old = adapter.process(frame(1));
      final closing = adapter.close();
      expect(adapter.close(), same(closing));
      await closing;
      pending.complete(evidence(spec, selection, spec.phases.first));
      expect((await old).sequenceObserved, isFalse);
      expect((await adapter.process(frame(2))).reason, 'closed');
      expect(provider.closes, 1);
    },
  );

  test(
    'a production-labelled provider is not silently treated as a fixture',
    () {
      provider.mode = YogaProviderMode.production;
      expect(
        () => YogaObservationAdapter.replay(
          catalog: catalog,
          selection: selection,
          provider: provider,
        ),
        throwsArgumentError,
      );
    },
  );
}
