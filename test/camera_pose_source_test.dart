/// `CameraPoseSource` — eşleme ve app-owned yaşam döngüsü kanıtı.
///
/// Bu dosyanın SINIRI isimle: gerçek `MotionCameraController` bir
/// `MethodChannel` sarmalı ve `flutter test`te platform kanalı
/// mocklanmadan çağrılamaz. Burada gerçek kontrol/olay kanal sözleşmesi
/// sentetik backend ile yürütülür; gecikmiş izin/model/start sonrası
/// dispose, owned ACK/readback, kare/olay susturma ve iki-owner geçiş sınanır.
/// SDK lease altında yürütülene kadar bu dosya test hazırlığıdır. Yerel kaynak
/// kanıtıdır; gerçek kamera, izin ekranı ve native kapanış cihazda açıktır.
/// `permissionState`/`failureState` saf değer eşlemeleri de korunur.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/camera_pose_source.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_camera/motion_camera.dart';
import 'package:permission_handler/permission_handler.dart';

final class _NativeCameraBackend {
  static const control = MethodChannel('motion_camera/control');
  static const frames = MethodChannel('motion_camera/frames');
  final calls = <String>[];
  final frameCalls = <String>[];
  final controlCalls = <MethodCall>[];
  final streamCalls = <MethodCall>[];
  final startEntered = Completer<void>();
  final stopEntered = Completer<void>();
  final listenEntered = Completer<void>();
  final cancelEntered = Completer<void>();
  final readbackEntered = Completer<void>();
  Completer<void>? startGate;
  Completer<void>? stopGate;
  Completer<void>? listenGate;
  Completer<void>? cancelGate;
  Completer<void>? readbackGate;
  String? heldReadbackOwner;
  PlatformException? startFailure;
  PlatformException? listenFailure;
  PlatformException? cancelFailure;
  bool ownedUnavailable = false;
  bool delayNativeBegin = false;
  String? _nativeOwner;
  String _phase = 'closed';
  String? listenerOwner;
  int? listenerGeneration;
  int _generation = 0;
  int _closeSequence = 0;
  Future<void>? _physicalClosing;
  final generations = <String, int>{};
  final acknowledgements = <Map<String, Object>>[];
  final readbacks = <Map<String, Object>>[];
  Map<String, Object> Function(Map<String, Object>)? corruptAck;
  Map<String, Object> Function(Map<String, Object>)? corruptReadback;
  bool get running => _phase != 'closed';
  String? get activeOwner => running ? _nativeOwner : null;
  String get phase => _phase;

  // Match the native lifecycle helper: finishClose retains the current owner;
  // a new begin is admitted only from CLOSED and replaces that owner. A foreign
  // observation is absent/closed generation zero, without a tombstone table.
  Map<String, Object> _facts(String owner, {int nonce = 0}) => <String, Object>{
    'protocol': 1,
    'ownerId': owner,
    'generation': _nativeOwner == owner ? _generation : 0,
    'state': _nativeOwner == owner ? _phase : 'closed',
    'captureClosed': _nativeOwner != owner || _phase == 'closed',
    'modelsClosed': _nativeOwner != owner || _phase == 'closed',
    'closeSequence': _closeSequence,
    'nonce': nonce,
  };

  void _checkCanBegin() {
    if (_phase == 'closed') return;
    throw PlatformException(code: _phase == 'closing' || _phase == 'uncertain'
        ? 'close-uncertain' : 'already-running');
  }

  Future<void> _closePhysical(String owner) {
    if (_nativeOwner != owner || _phase == 'closed') return Future<void>.value();
    if (_phase == 'closing') return _physicalClosing!;
    _phase = 'closing';
    return _physicalClosing = () async {
      await stopGate?.future;
      _phase = 'closed';
      _closeSequence++;
      // Deliberately retain _nativeOwner and generation until the next begin.
    }();
  }

  void install() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(control, (call) async {
      calls.add(call.method);
      controlCalls.add(call);
      if (ownedUnavailable) throw MissingPluginException();
      final args = call.arguments! as Map<Object?, Object?>;
      final owner = args['ownerId']! as String;
      if (call.method == 'startOwned') {
        if (!startEntered.isCompleted) startEntered.complete();
        _checkCanBegin();
        void begin() {
          _nativeOwner = owner;
          _physicalClosing = null;
          _phase = 'opening';
          generations[owner] = ++_generation;
        }
        if (!delayNativeBegin) begin();
        await startGate?.future;
        if (startFailure != null) throw startFailure!;
        if (delayNativeBegin) {
          // Explicit adversarial late-start seam: an absent ACK can precede
          // native begin. It still cannot begin while another owner is live.
          _checkCanBegin();
          begin();
        }
        if (_nativeOwner != owner || _phase != 'opening') {
          throw PlatformException(code: 'session-interrupted');
        }
        _phase = 'running';
        final generation = generations[owner]!;
        return <String, Object>{
          'protocol': 1,
          'ownerId': owner,
          'generation': generation,
          'w': 1080,
          'h': 1920,
          'clock': 'monotonic',
          'library': 'fixture-library',
        };
      }
      if (call.method == 'stopOwned') {
        if (!stopEntered.isCompleted) stopEntered.complete();
        await _closePhysical(owner);
        final facts = corruptAck?.call(_facts(owner)) ?? _facts(owner);
        acknowledgements.add(facts);
        return facts;
      }
      if (call.method == 'readback') {
        if (!readbackEntered.isCompleted) readbackEntered.complete();
        if (heldReadbackOwner == null || heldReadbackOwner == owner) {
          await readbackGate?.future;
        }
        final original = _facts(owner, nonce: args['nonce']! as int);
        final facts = corruptReadback?.call(original) ?? original;
        readbacks.add(facts);
        return facts;
      }
      throw StateError('Unexpected native camera method ${call.method}');
    });
    messenger.setMockMethodCallHandler(frames, (call) async {
      frameCalls.add(call.method);
      streamCalls.add(call);
      final args = call.arguments as Map<Object?, Object?>?;
      final owner = args?['ownerId'] as String?;
      final generation = args?['generation'] as int?;
      if (call.method == 'listen') {
        if (!listenEntered.isCompleted) listenEntered.complete();
        if (owner != _nativeOwner || generation != _generation || _phase != 'running') {
          throw PlatformException(code: 'session-interrupted');
        }
        listenerOwner = owner;
        listenerGeneration = generation;
        await listenGate?.future;
        if (listenFailure != null) throw listenFailure!;
        return null;
      }
      if (call.method == 'cancel') {
        if (!cancelEntered.isCompleted) cancelEntered.complete();
        // Clear only this listener at entry, never in a late reply continuation.
        if (listenerOwner == owner && listenerGeneration == generation) {
          listenerOwner = null;
          listenerGeneration = null;
        }
        if (owner == _nativeOwner && generation == _generation) {
          unawaited(_closePhysical(owner!));
        }
        await cancelGate?.future;
        if (cancelFailure != null) throw cancelFailure!;
        return null;
      }
      throw StateError('Unexpected native frame method ${call.method}');
    });
  }

  void uninstall() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(control, null);
    messenger.setMockMethodCallHandler(frames, null);
  }

  Future<void> emitFrame({bool person = true, String? owner, int? generation}) => _emit(
    const StandardMethodCodec().encodeSuccessEnvelope(<String, Object?>{
      'ownerId': owner ?? activeOwner,
      'generation': generation ?? generations[owner ?? activeOwner],
      't': 1000,
      'w': 1080,
      'h': 1920,
      'model': 'fixture-library+pose_landmarker_full.v1',
      'clock': 'monotonic',
      'infUs': 100,
      'dropped': 0,
      'up': person ? Float32List(132) : null,
    }),
  );

  Future<void> emitError() => _emit(
    const StandardMethodCodec().encodeErrorEnvelope(
      code: 'camera-permission-denied',
    ),
  );

  Future<void> emitEndOfStream() => _emit(null);

  Future<void> emitMalformed() => _emit(
    const StandardMethodCodec().encodeSuccessEnvelope(<String, Object>{
      'ownerId': activeOwner!, 'generation': _generation,
    }),
  );

  Future<void> _emit(ByteData? data) async {
    if (listenerOwner == null) return;
    final delivered = Completer<void>();
    ServicesBinding.instance.channelBuffers.push(
      frames.name,
      data,
      (_) => delivered.complete(),
    );
    await delivered.future;
    await Future<void>.delayed(Duration.zero);
  }
}

CameraPoseSource _fixtureSource(MotionCameraController controller) => CameraPoseSource(
  controller: controller,
  requestPermission: () async => PermissionStatus.granted,
  prepareModel: () async => '/fixture/model.task',
);

Matcher get _uncertainClose => throwsA(isA<CameraException>().having(
  (error) => error.failure, 'failure', CameraFailure.closeUncertain,
));

final class _TrackingController extends MotionCameraController {
  _TrackingController(this.order);
  final List<String> order;

  @override
  CameraCaptureLease createCaptureLease() {
    order.add('lease');
    return super.createCaptureLease();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('camera retirement cancels pending preparation', () {
    late _NativeCameraBackend native;
    late MotionCameraController controller;
    setUp(() {
      native = _NativeCameraBackend()..install();
      controller = MotionCameraController(
        controlTimeout: const Duration(milliseconds: 100),
      );
    });
    tearDown(() => native.uninstall());

    test('capture lease is created synchronously before permission and model', () async {
      final order = <String>[];
      final source = CameraPoseSource(
        controller: _TrackingController(order),
        requestPermission: () async {
          order.add('permission');
          return PermissionStatus.granted;
        },
        prepareModel: () async {
          order.add('model');
          return '/fixture/model.task';
        },
      );
      expect(order, <String>['lease']);
      await source.start();
      expect(order, <String>['lease', 'permission', 'model']);
      await source.dispose();
    });

    test(
      'dispose during delayed permission never prepares or starts native',
      () async {
        final permissionEntered = Completer<void>();
        final permission = Completer<PermissionStatus>();
        var modelCalls = 0;
        final source = CameraPoseSource(
          controller: controller,
          requestPermission: () {
            permissionEntered.complete();
            return permission.future;
          },
          prepareModel: () async {
            modelCalls++;
            return '/fixture/model.task';
          },
        );
        final events = <PoseSourceEvent>[];
        final subscription = source.events().listen(events.add);
        final starting = source.start();
        await permissionEntered.future;
        await Future<void>.delayed(Duration.zero);
        events.clear();
        final retiring = source.dispose();
        var disposed = false;
        unawaited(retiring.then((_) => disposed = true));
        try {
          await Future<void>.delayed(Duration.zero);
          expect(disposed, isTrue, reason: 'Permission preparation owns no native work');
        } finally {
          permission.complete(PermissionStatus.granted);
          await starting;
          await retiring;
          await subscription.cancel();
        }
        expect(modelCalls, 0);
        expect(
          native.calls,
          isEmpty,
          reason: 'No native start means no stop ownership',
        );
        expect(events, isEmpty);
      },
    );

    test(
      'synchronous preparation disposal drops a queued idle event',
      () async {
        late CameraPoseSource source;
        Future<void>? retiring;
        source = CameraPoseSource(
          controller: controller,
          requestPermission: () {
            retiring = source.dispose();
            return Future<PermissionStatus>.value(PermissionStatus.granted);
          },
          prepareModel: () async => '/fixture/model.task',
        );
        final events = <PoseSourceEvent>[];
        final subscription = source.events().listen(events.add);
        await source.start();
        await retiring;
        expect(events, isEmpty);
        expect(
          native.calls,
          isEmpty,
          reason: 'No native start means no stop ownership',
        );
        await subscription.cancel();
      },
    );

    test('dispose during delayed model never starts native', () async {
      final modelEntered = Completer<void>();
      final model = Completer<String>();
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () {
          modelEntered.complete();
          return model.future;
        },
      );
      final starting = source.start();
      await modelEntered.future;
      final retiring = source.dispose();
      var disposed = false;
      unawaited(retiring.then((_) => disposed = true));
      try {
        await Future<void>.delayed(Duration.zero);
        expect(disposed, isTrue, reason: 'Model preparation owns no native work');
      } finally {
        model.complete('/fixture/model.task');
        await starting;
        await retiring;
      }
      expect(
        native.calls,
        isEmpty,
        reason: 'No native start means no stop ownership',
      );
      expect(native.frameCalls, isEmpty);
    });

    test(
      'start after disposal makes no permission or native request',
      () async {
        var permissionCalls = 0;
        var modelCalls = 0;
        final source = CameraPoseSource(
          controller: controller,
          requestPermission: () async {
            permissionCalls++;
            return PermissionStatus.granted;
          },
          prepareModel: () async {
            modelCalls++;
            return '/fixture/model.task';
          },
        );
        await source.dispose();
        await source.start();
        expect(permissionCalls, 0);
        expect(modelCalls, 0);
        expect(
          native.calls,
          isEmpty,
          reason: 'No native start means no stop ownership',
        );
      },
    );

    test(
      'pending native start retires without a frame subscription and awaits stop',
      () async {
        native.startGate = Completer<void>();
        native.stopGate = Completer<void>();
        final source = CameraPoseSource(
          controller: controller,
          requestPermission: () async => PermissionStatus.granted,
          prepareModel: () async => '/fixture/model.task',
        );
        final events = <PoseSourceEvent>[];
        final subscription = source.events().listen(events.add);
        final starting = source.start();
        await native.startEntered.future;
        await Future<void>.delayed(Duration.zero);
        events.clear();
        final retiring = source.dispose();
        var retired = false;
        unawaited(retiring.then((_) => retired = true));
        try {
          native.startGate!.complete();
          await starting;
          await native.stopEntered.future;
          expect(retired, isFalse);
          expect(native.running, isTrue);
          expect(native.frameCalls, isEmpty);
          expect(events, isEmpty);
        } finally {
          native.stopGate!.complete();
          await retiring;
          await subscription.cancel();
        }
        expect(native.running, isFalse);
        expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
      },
    );

    test('late pending native failure emits no retired setup event', () async {
      native.startGate = Completer<void>();
      native.startFailure = PlatformException(code: 'model-load-failed');
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final events = <PoseSourceEvent>[];
      final subscription = source.events().listen(events.add);
      final starting = source.start();
      await native.startEntered.future;
      await Future<void>.delayed(Duration.zero);
      events.clear();
      final retiring = source.dispose();
      native.startGate!.complete();
      await starting;
      await retiring;
      expect(events, isEmpty);
      expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
      await subscription.cancel();
    });

    test(
      'retirement immediately suppresses frames, no-person and stream errors',
      () async {
        native.stopGate = Completer<void>();
        final source = CameraPoseSource(
          controller: controller,
          requestPermission: () async => PermissionStatus.granted,
          prepareModel: () async => '/fixture/model.task',
        );
        final events = <PoseSourceEvent>[];
        final subscription = source.events().listen(events.add);
        await source.start();
        await native.emitFrame();
        expect(events.whereType<SourceFrameEvent>(), hasLength(1));
        events.clear();
        final retiring = source.dispose();
        try {
          await source.start();
          await native.emitFrame();
          await native.emitFrame(person: false);
          await native.emitError();
          expect(events, isEmpty);
        } finally {
          native.stopGate!.complete();
          await retiring;
          await subscription.cancel();
        }
        expect(events, isEmpty);
        expect(native.running, isFalse);
        expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
      },
    );

    test('repeated disposal shares its future and one native stop', () async {
      native.stopGate = Completer<void>();
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      await source.start();
      final first = source.dispose();
      final second = source.dispose();
      await native.stopEntered.future;
      native.stopGate!.complete();
      await Future.wait(<Future<void>>[first, second]);
      expect(identical(first, second), isTrue);
      expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
    });

    test('busy-rejected B disposal preserves active A and its frame owner', () async {
      final a = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final b = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final aEvents = <PoseSourceEvent>[];
      final bEvents = <PoseSourceEvent>[];
      final aSub = a.events().listen(aEvents.add);
      final bSub = b.events().listen(bEvents.add);
      try {
        await a.start();
        final aOwner = native.activeOwner!;
        await native.emitFrame();
        expect(aEvents.whereType<SourceFrameEvent>(), hasLength(1));
        await b.start();
        await Future<void>.delayed(Duration.zero);
        expect(
          bEvents.whereType<SourceStateEvent>().map((event) => event.state)
              .whereType<SetupFailed>().single.code,
          'already-running',
        );
        await b.dispose();
        expect(native.activeOwner, aOwner);
        await native.emitFrame();
        expect(aEvents.whereType<SourceFrameEvent>(), hasLength(2));
        final bStart = native.controlCalls.where((call) => call.method == 'startOwned').last;
        final bOwner = (bStart.arguments! as Map<Object?, Object?>)['ownerId'];
        expect(bOwner, isNot(aOwner));
        expect(
          native.controlCalls.where((call) => call.method == 'stopOwned')
              .map((call) => (call.arguments! as Map<Object?, Object?>)['ownerId']),
          <Object?>[bOwner],
        );
        expect(native.frameCalls, <String>['listen']);
        expect(native.calls, isNot(contains('stop')));
      } finally {
        await b.dispose();
        await a.dispose();
        await aSub.cancel();
        await bSub.cancel();
      }
    });

    for (final permission in <PermissionStatus>[
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied,
    ]) {
      test('denied B $permission disposal preserves active A', () async {
        final a = CameraPoseSource(
          controller: controller,
          requestPermission: () async => PermissionStatus.granted,
          prepareModel: () async => '/fixture/model.task',
        );
        final b = CameraPoseSource(
          controller: controller,
          requestPermission: () async => permission,
          prepareModel: () async => throw StateError('Denied B must not prepare'),
        );
        final aEvents = <PoseSourceEvent>[];
        final bEvents = <PoseSourceEvent>[];
        final aSub = a.events().listen(aEvents.add);
        final bSub = b.events().listen(bEvents.add);
        try {
          await a.start();
          final owner = native.activeOwner;
          await native.emitFrame();
          await b.start();
          await Future<void>.delayed(Duration.zero);
          final denial = bEvents.whereType<SourceStateEvent>()
              .map((event) => event.state).whereType<PermissionDenied>().single;
          expect(denial.kind, permission == PermissionStatus.permanentlyDenied
              ? PermissionDenialKind.permanent : PermissionDenialKind.transient);
          await b.dispose();
          expect(native.activeOwner, owner);
          expect(native.calls, <String>['startOwned']);
          await native.emitFrame();
          expect(aEvents.whereType<SourceFrameEvent>(), hasLength(2));
        } finally {
          await b.dispose();
          await a.dispose();
          await aSub.cancel();
          await bSub.cancel();
        }
      });
    }

    test('paused A close drains before B; late A cancel and dispose preserve B', () async {
      final a = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final aEvents = <PoseSourceEvent>[];
      final aSub = a.events().listen(aEvents.add);
      await a.start();
      final aOwner = native.activeOwner!;
      final aGeneration = native.generations[aOwner]!;
      await native.emitFrame();
      final beforePause = aEvents.length;
      aSub.pause();
      await native.emitFrame();
      await native.emitFrame(person: false);
      final retiring = a.dispose();
      await retiring.timeout(const Duration(seconds: 1));
      expect(native.frameCalls, <String>['listen', 'cancel']);
      final aCancel = native.streamCalls.last.arguments! as Map<Object?, Object?>;
      expect(aCancel, <String, Object>{'ownerId': aOwner, 'generation': aGeneration});
      final b = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final bEvents = <PoseSourceEvent>[];
      final bSub = b.events().listen(bEvents.add);
      try {
        await b.start();
        final bOwner = native.activeOwner!;
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(1));
        aSub.resume();
        await Future<void>.delayed(Duration.zero);
        expect(aEvents, hasLength(beforePause),
            reason: 'Paused old frame/state events are filtered when resumed after retirement');
        final beforeCancel = native.streamCalls.length;
        final beforeDispose = native.controlCalls.length;
        await aSub.cancel();
        expect(identical(a.dispose(), retiring), isTrue);
        await a.dispose();
        expect(native.streamCalls, hasLength(beforeCancel));
        expect(native.controlCalls, hasLength(beforeDispose));
        expect(native.activeOwner, bOwner);
        await native.emitFrame(owner: aOwner, generation: aGeneration);
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(1));
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(2));
      } finally {
        await aSub.cancel();
        await b.dispose();
        await bSub.cancel();
      }
    });

    test('held raw cancel reply keeps close pending before caller admits B', () async {
      native.cancelGate = Completer<void>();
      final a = _fixtureSource(controller);
      final b = _fixtureSource(controller);
      final aSub = a.events().listen((_) {});
      final bEvents = <PoseSourceEvent>[];
      final bSub = b.events().listen(bEvents.add);
      await a.start();
      final aOwner = native.activeOwner!;
      final aGeneration = native.generations[aOwner]!;
      aSub.pause();
      final closing = a.dispose();
      var closed = false;
      var bAdmitted = false;
      unawaited(closing.then((_) => closed = true));
      final successor = closing.then((_) async {
        bAdmitted = true;
        await b.start();
      });
      try {
        await native.cancelEntered.future;
        await Future<void>.delayed(Duration.zero);
        expect(native.phase, 'closed', reason: 'Native stop ACK may precede the raw cancel RPC reply');
        expect(closed, isFalse);
        expect(bAdmitted, isFalse, reason: 'The caller waits the complete close barrier');
        expect(native.readbacks, isEmpty);
        expect(native.calls.where((method) => method == 'readback'), isEmpty);
        expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
        expect(native.frameCalls, <String>['listen', 'cancel']);
        expect(identical(a.dispose(), closing), isTrue);
        native.cancelGate!.complete();
        await closing;
        await successor;
        expect(closed, isTrue);
        expect(bAdmitted, isTrue);
        expect(native.readbacks, hasLength(1));
        final bOwner = native.activeOwner!;
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(1));
        final beforeLateCancel = native.streamCalls.length;
        final beforeLateDispose = native.controlCalls.length;
        aSub.resume();
        await aSub.cancel();
        await a.dispose();
        expect(native.streamCalls, hasLength(beforeLateCancel));
        expect(native.controlCalls, hasLength(beforeLateDispose));
        expect(native.activeOwner, bOwner);
        await native.emitFrame(owner: aOwner, generation: aGeneration);
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(1));
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(2));
      } finally {
        if (!native.cancelGate!.isCompleted) native.cancelGate!.complete();
        await closing;
        await successor;
        await aSub.cancel();
        await b.dispose();
        await bSub.cancel();
      }
    });

    test('held raw listen reply drains before cancel RPC and fresh readback', () async {
      native.listenGate = Completer<void>();
      final source = _fixtureSource(controller);
      await source.start();
      await native.listenEntered.future;
      final closing = source.dispose();
      var closed = false;
      unawaited(closing.then((_) => closed = true));
      try {
        await Future<void>.delayed(Duration.zero);
        expect(native.phase, 'closed');
        expect(closed, isFalse);
        expect(native.cancelEntered.isCompleted, isFalse);
        expect(native.frameCalls, <String>['listen']);
        expect(native.calls.where((method) => method == 'readback'), isEmpty);
        native.listenGate!.complete();
        await closing;
        expect(closed, isTrue);
        expect(native.frameCalls, <String>['listen', 'cancel']);
        expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
      } finally {
        if (!native.listenGate!.isCompleted) native.listenGate!.complete();
        await closing;
      }
    });

    for (final rpc in <String>['listen', 'cancel']) {
      test('raw $rpc RPC error preserves failed close and shared quarantine', () async {
        if (rpc == 'listen') {
          native.listenFailure = PlatformException(code: 'fixture-listen-error');
        } else {
          native.cancelFailure = PlatformException(code: 'fixture-cancel-error');
        }
        final a = _fixtureSource(controller);
        final aEvents = <PoseSourceEvent>[];
        final aSub = a.events().listen(aEvents.add);
        await a.start();
        if (rpc == 'listen') {
          await native.cancelEntered.future;
          await Future<void>.delayed(Duration.zero);
          expect(aEvents.whereType<SourceStateEvent>().map((event) => event.state)
              .whereType<SetupFailed>().single.code, 'close-uncertain');
        }
        final closing = a.dispose();
        await expectLater(closing, _uncertainClose);
        expect(identical(closing, a.dispose()), isTrue);
        expect(native.frameCalls, <String>['listen', 'cancel']);
        expect(native.calls.where((method) => method == 'readback'), isEmpty);
        expect(native.running, isFalse);
        final b = _fixtureSource(controller);
        final bEvents = <PoseSourceEvent>[];
        final bSub = b.events().listen(bEvents.add);
        await b.start();
        await Future<void>.delayed(Duration.zero);
        expect(bEvents.whereType<SourceStateEvent>().map((event) => event.state)
            .whereType<SetupFailed>().single.code, 'close-uncertain');
        expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
        await b.dispose();
        await aSub.cancel();
        await bSub.cancel();
      });

      testWidgets('raw $rpc reply timeout cannot be escaped by another source', (tester) async {
        final gate = Completer<void>();
        if (rpc == 'listen') native.listenGate = gate;
        if (rpc == 'cancel') native.cancelGate = gate;
        final a = _fixtureSource(controller);
        Future<void>? starting;
        var startSettled = false;
        if (rpc == 'listen') {
          starting = a.start().whenComplete(() => startSettled = true);
          // The listen transport reply is intentionally held. Observe dispatch,
          // then close concurrently; awaiting start here would deadlock.
          for (var i = 0; i < 40 && !native.listenEntered.isCompleted; i++) {
            await tester.pump(const Duration(milliseconds: 1));
          }
          expect(native.startEntered.isCompleted, isTrue);
          expect(native.listenEntered.isCompleted, isTrue);
        } else {
          await tester.runAsync(a.start);
        }
        final closing = a.dispose();
        var closeSettled = false;
        final failure = expectLater(closing, _uncertainClose)
            .whenComplete(() => closeSettled = true);
        for (var i = 0; i < 40 && !closeSettled; i++) {
          await tester.pump(const Duration(milliseconds: 25));
          await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
        }
        expect(closeSettled, isTrue, reason: 'Every uncertain close timeout must settle within the bounded clock drain.');
        await failure;
        await tester.pump();
        expect(identical(closing, a.dispose()), isTrue);
        expect(native.frameCalls, <String>['listen', 'cancel']);
        expect(native.calls.where((method) => method == 'readback'), isEmpty);
        final b = _fixtureSource(controller);
        await tester.runAsync(b.start);
        expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
        gate.complete();
        await tester.pump();
        if (starting != null) {
          for (var i = 0; i < 40 && !startSettled; i++) {
            await tester.pump(const Duration(milliseconds: 1));
          }
          expect(startSettled, isTrue, reason: 'Original start must join after the held reply.');
          await starting;
        }
        final c = _fixtureSource(controller);
        await tester.runAsync(c.start);
        expect(native.calls.where((method) => method == 'startOwned'), hasLength(1),
            reason: 'A late transport reply does not clear the shared controller quarantine');
        await tester.runAsync(b.dispose);
        await tester.runAsync(c.dispose);
      });
    }

    for (final fault in <String>['end-of-stream', 'malformed-envelope']) {
      test('raw $fault stops delivery and preserves uncertain close', () async {
        final a = _fixtureSource(controller);
        final events = <PoseSourceEvent>[];
        final sub = a.events().listen(events.add);
        await a.start();
        await native.emitFrame();
        expect(events.whereType<SourceFrameEvent>(), hasLength(1));
        if (fault == 'end-of-stream') {
          await native.emitEndOfStream();
        } else {
          await native.emitMalformed();
        }
        await native.cancelEntered.future;
        await Future<void>.delayed(Duration.zero);
        expect(events.whereType<SourceStateEvent>().map((event) => event.state)
            .whereType<SetupFailed>().single.code, 'close-uncertain');
        await expectLater(a.dispose(), _uncertainClose);
        expect(native.calls.where((method) => method == 'readback'), isEmpty);
        await native.emitFrame();
        expect(events.whereType<SourceFrameEvent>(), hasLength(1));
        final b = _fixtureSource(controller);
        await b.start();
        expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
        await b.dispose();
        await sub.cancel();
      });
    }

    test('physical A close then B begin makes late A readback absent generation zero', () async {
      final a = _fixtureSource(controller);
      final b = _fixtureSource(controller);
      final aSub = a.events().listen((_) {});
      final bEvents = <PoseSourceEvent>[];
      final bSub = b.events().listen(bEvents.add);
      await a.start();
      final aOwner = native.activeOwner!;
      final aGeneration = native.generations[aOwner]!;
      native.heldReadbackOwner = aOwner;
      native.readbackGate = Completer<void>();
      final closing = a.dispose();
      try {
        await native.readbackEntered.future;
        expect(native.phase, 'closed');
        expect(native.acknowledgements.single['generation'], aGeneration);
        // Intentional protocol race, not host admission: Core does not impose
        // a global lease barrier. The normal host waits retireAndDrain first.
        await b.start();
        final bOwner = native.activeOwner!;
        expect(bOwner, isNot(aOwner));
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(1));
        native.readbackGate!.complete();
        await closing;
        final late = native.readbacks.single;
        expect(late['ownerId'], aOwner);
        expect(late['generation'], 0);
        expect(late['state'], 'closed');
        expect(late['closeSequence'], native.acknowledgements.single['closeSequence']);
        final beforeLateCancel = native.streamCalls.length;
        final beforeLateDispose = native.controlCalls.length;
        await aSub.cancel();
        await a.dispose();
        expect(native.streamCalls, hasLength(beforeLateCancel));
        expect(native.controlCalls, hasLength(beforeLateDispose));
        expect(native.activeOwner, bOwner);
        await native.emitFrame();
        expect(bEvents.whereType<SourceFrameEvent>(), hasLength(2));
      } finally {
        if (!native.readbackGate!.isCompleted) native.readbackGate!.complete();
        await closing;
        await aSub.cancel();
        await b.dispose();
        await bSub.cancel();
      }
    });

    test('native begin refuses B while A physical close is still pending', () async {
      native.stopGate = Completer<void>();
      final a = _fixtureSource(controller);
      final b = _fixtureSource(controller);
      final bEvents = <PoseSourceEvent>[];
      final bSub = b.events().listen(bEvents.add);
      await a.start();
      final aOwner = native.activeOwner!;
      final closing = a.dispose();
      try {
        await native.stopEntered.future;
        expect(native.phase, 'closing');
        await b.start();
        await Future<void>.delayed(Duration.zero);
        expect(bEvents.whereType<SourceStateEvent>().map((event) => event.state)
            .whereType<SetupFailed>().single.code, 'close-uncertain');
        await b.dispose();
        expect(native.phase, 'closing');
        expect(native.activeOwner, aOwner);
        expect(native.readbacks.single['generation'], 0, reason: 'Busy B never owned A native session');
        native.stopGate!.complete();
        await closing;
        final c = _fixtureSource(controller);
        await c.start();
        expect(native.activeOwner, isNot(aOwner));
        await c.dispose();
      } finally {
        if (!native.stopGate!.isCompleted) native.stopGate!.complete();
        await closing;
        await b.dispose();
        await bSub.cancel();
      }
    });

    test('absent-owner ACK drains late native start then closes exact owner again', () async {
      native.delayNativeBegin = true;
      native.startGate = Completer<void>();
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final starting = source.start();
      await native.startEntered.future;
      final retiring = source.dispose();
      await native.stopEntered.future;
      final owner = (native.controlCalls.first.arguments! as Map<Object?, Object?>)['ownerId'];
      var disposed = false;
      unawaited(retiring.then((_) => disposed = true));
      await Future<void>.delayed(Duration.zero);
      expect(disposed, isFalse);
      expect(native.acknowledgements.single['generation'], 0);
      native.startGate!.complete();
      await starting;
      await retiring;
      expect(native.calls, <String>['startOwned', 'stopOwned', 'stopOwned', 'readback']);
      expect(native.acknowledgements.last['generation'], native.generations[owner]);
      expect(
        native.controlCalls.map((call) => (call.arguments! as Map<Object?, Object?>)['ownerId']),
        everyElement(owner),
      );
      final nonce = (native.controlCalls.last.arguments! as Map<Object?, Object?>)['nonce'];
      expect(nonce, isA<int>());
      expect(nonce! as int, greaterThan(0));
      expect(native.running, isFalse);
      expect(native.frameCalls, isEmpty);
    });

    test('active start is idempotent and does not reprepare or subscribe twice', () async {
      var permissionCalls = 0;
      var modelCalls = 0;
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async {
          permissionCalls++;
          return PermissionStatus.granted;
        },
        prepareModel: () async {
          modelCalls++;
          return '/fixture/model.task';
        },
      );
      await Future.wait(<Future<void>>[source.start(), source.start()]);
      await source.start();
      expect(permissionCalls, 1);
      expect(modelCalls, 1);
      expect(native.calls, <String>['startOwned']);
      expect(native.frameCalls, <String>['listen']);
      await source.dispose();
    });

    test('foreign close ACK preserves failure and quarantines the shared controller', () async {
      native.corruptAck = (facts) => <String, Object>{...facts, 'ownerId': 'foreign-owner'};
      final a = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      await a.start();
      final first = a.dispose();
      expect(identical(first, a.dispose()), isTrue);
      await expectLater(first, throwsA(isA<CameraException>().having(
        (error) => error.failure, 'failure', CameraFailure.closeUncertain,
      )));
      final b = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final events = <PoseSourceEvent>[];
      final sub = b.events().listen(events.add);
      await b.start();
      await Future<void>.delayed(Duration.zero);
      expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
      expect(events.whereType<SourceStateEvent>().map((event) => event.state)
          .whereType<SetupFailed>().single.code, 'close-uncertain');
      await b.dispose();
      await sub.cancel();
    });

    test('close ACK generation mismatch preserves closure failure', () async {
      native.corruptAck = (facts) => <String, Object>{
        ...facts, 'generation': (facts['generation']! as int) + 1,
      };
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      await source.start();
      await expectLater(source.dispose(), throwsA(isA<CameraException>().having(
        (error) => error.failure, 'failure', CameraFailure.closeUncertain,
      )));
    });

    for (final field in <String>['nonce', 'generation', 'modelsClosed', 'closeSequence']) {
      test('fresh readback $field mismatch fails closure', () async {
        native.corruptReadback = (facts) => <String, Object>{
          ...facts,
          field: switch (field) {
            'nonce' => (facts['nonce']! as int) + 1,
            'generation' => (facts['generation']! as int) + 1,
            'modelsClosed' => false,
            _ => (facts['closeSequence']! as int) - 1,
          },
        };
        final source = CameraPoseSource(
          controller: controller,
          requestPermission: () async => PermissionStatus.granted,
          prepareModel: () async => '/fixture/model.task',
        );
        await source.start();
        await expectLater(source.dispose(), throwsA(isA<CameraException>().having(
          (error) => error.failure, 'failure', CameraFailure.closeUncertain,
        )));
      });
    }

    test('unsupported owned plugin has a named failure and no legacy fallback', () async {
      native.ownedUnavailable = true;
      final source = CameraPoseSource(
        controller: controller,
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final events = <PoseSourceEvent>[];
      final sub = source.events().listen(events.add);
      await source.start();
      await Future<void>.delayed(Duration.zero);
      expect(events.whereType<SourceStateEvent>().map((event) => event.state)
          .whereType<SetupFailed>().single.code, 'owned-protocol-unavailable');
      await expectLater(source.dispose(), throwsA(isA<CameraException>().having(
        (error) => error.failure, 'failure', CameraFailure.closeUncertain,
      )));
      expect(native.calls, isNot(contains('start')));
      expect(native.calls, isNot(contains('stop')));
      await sub.cancel();
    });

    testWidgets('default route controller retains timeout quarantine after late ACK', (tester) async {
      await tester.runAsync(() async {
      native.stopGate = Completer<void>();
      CameraPoseSource defaultSource() => CameraPoseSource(
        requestPermission: () async => PermissionStatus.granted,
        prepareModel: () async => '/fixture/model.task',
      );
      final a = defaultSource();
      await a.start();
      await expectLater(a.dispose().timeout(const Duration(seconds: 40)),
          throwsA(isA<CameraException>().having(
            (error) => error.failure, 'failure', CameraFailure.closeUncertain)));
      final b = defaultSource();
      await b.start();
      expect(native.calls.where((method) => method == 'startOwned'), hasLength(1));
      native.stopGate!.complete();
      await Future<void>.delayed(Duration.zero);
      final c = defaultSource();
      await c.start();
      expect(native.calls.where((method) => method == 'startOwned'), hasLength(1),
          reason: 'Late ACK and a fresh route must not create a new default controller');
      await b.dispose();
      await c.dispose();
      });
    }, timeout: const Timeout(Duration(seconds: 60)));

    for (final pendingStage in <String>['permission', 'model']) {
      test(
        'pre-start $pendingStage disposal preserves another source camera',
        () async {
          final preparationEntered = Completer<void>();
          final preparation = Completer<void>();
          final sourceA = CameraPoseSource(
            controller: controller,
            requestPermission: () async {
              if (pendingStage == 'permission') {
                preparationEntered.complete();
                await preparation.future;
              }
              return PermissionStatus.granted;
            },
            prepareModel: () async {
              if (pendingStage == 'model') {
                preparationEntered.complete();
                await preparation.future;
              }
              return '/fixture/model.task';
            },
          );
          final sourceB = CameraPoseSource(
            controller: controller,
            requestPermission: () async => PermissionStatus.granted,
            prepareModel: () async => '/fixture/model.task',
          );
          final startingA = sourceA.start();
          await preparationEntered.future;
          final retiringA = sourceA.dispose();
          try {
            await sourceB.start();
            expect(native.running, isTrue);
            preparation.complete();
            await startingA;
            await retiringA;
            expect(
              native.running,
              isTrue,
              reason:
                  'A never issued native start; its disposal must preserve B',
            );
            expect(native.calls, <String>['startOwned']);
          } finally {
            if (!preparation.isCompleted) preparation.complete();
            await startingA;
            await retiringA;
            await sourceB.dispose();
          }
          expect(native.running, isFalse);
          expect(native.calls, <String>['startOwned', 'stopOwned', 'readback']);
        },
      );
    }

    for (final permission in <PermissionStatus>[
      PermissionStatus.denied,
      PermissionStatus.permanentlyDenied,
    ]) {
      test(
        'active $permission keeps its denial mapping and never starts native',
        () async {
          var modelCalls = 0;
          final source = CameraPoseSource(
            controller: controller,
            requestPermission: () async => permission,
            prepareModel: () async {
              modelCalls++;
              return '/fixture/model.task';
            },
          );
          final events = <PoseSourceEvent>[];
          final subscription = source.events().listen(events.add);
          await source.start();
          // Observe the active denial before requesting retirement; queued
          // events are deliberately suppressed once disposal is requested.
          await Future<void>.delayed(Duration.zero);
          await source.dispose();
          final denial = events
              .whereType<SourceStateEvent>()
              .map((event) => event.state)
              .whereType<PermissionDenied>()
              .single;
          expect(
            denial.kind,
            permission == PermissionStatus.permanentlyDenied
                ? PermissionDenialKind.permanent
                : PermissionDenialKind.transient,
          );
          expect(modelCalls, 0);
          expect(
            native.calls,
            isEmpty,
            reason: 'Denied permission never owns native stop',
          );
          await subscription.cancel();
        },
      );
    }
  });

  group('permissionState — kalıcı/geçici ayrımı KORUNUYOR', () {
    test(
      'reddedildi (geçici) → PermissionDenied.transient, "tekrar dene" ANLAMLI',
      () {
        final LiveSessionState s = permissionState(PermissionStatus.denied);
        expect(s, isA<PermissionDenied>());
        final PermissionDenied p = s as PermissionDenied;
        expect(p.kind, PermissionDenialKind.transient);
        expect(p.retryMakesSense, isTrue);
      },
    );

    test(
      'kalıcı reddedildi → PermissionDenied.permanent, "tekrar dene" ANLAMSIZ',
      () {
        final LiveSessionState s = permissionState(
          PermissionStatus.permanentlyDenied,
        );
        expect(s, isA<PermissionDenied>());
        final PermissionDenied p = s as PermissionDenied;
        expect(p.kind, PermissionDenialKind.permanent);
        expect(
          p.retryMakesSense,
          isFalse,
          reason:
              'kalıcı rette "tekrar dene" göstermek kullanıcıyı hiçbir '
              'yere varmayan bir düğmeye hapseder — LiveSessionState '
              'dokümanının desen 2 hükmü',
        );
      },
    );

    test('kısıtlı (ebeveyn kontrolü vb.) → KALICI sayılır, geçici DEĞİL', () {
      final LiveSessionState s = permissionState(PermissionStatus.restricted);
      expect((s as PermissionDenied).kind, PermissionDenialKind.permanent);
    });

    test('her iki hâlde de userText BOŞ DEĞİL', () {
      for (final PermissionStatus st in <PermissionStatus>[
        PermissionStatus.denied,
        PermissionStatus.permanentlyDenied,
        PermissionStatus.restricted,
      ]) {
        expect(permissionState(st).userText, isNotEmpty);
      }
    });
  });

  group('failureState — CameraFailure kodları İSİMLE taşınıyor', () {
    test(
      'permissionDenied → PermissionDenied (geçici), izin akışıyla AYNI hâl',
      () {
        final LiveSessionState s = failureState(
          const CameraException(CameraFailure.permissionDenied, null),
        );
        expect(s, isA<PermissionDenied>());
      },
    );

    test(
      'diğer HER CameraFailure kodu → SetupFailed, kod SESSİZCE yutulmaz',
      () {
        for (final CameraFailure f in CameraFailure.values) {
          if (f == CameraFailure.permissionDenied) continue;
          final LiveSessionState s = failureState(CameraException(f, null));
          expect(
            s,
            isA<SetupFailed>(),
            reason: '${f.name}: isimsiz bir jenerik hataya düşmemeli',
          );
          expect(
            (s as SetupFailed).code,
            f.code,
            reason:
                'kod DEĞİŞTİRİLMEDEN taşınmalı — battery_summary '
                'deseni: bilinmeyen kod bile GÖSTERİLİR',
          );
        }
      },
    );

    test('CameraException OLMAYAN bir hata bile isimsiz düşmez', () {
      final LiveSessionState s = failureState(StateError('beklenmeyen'));
      expect(s, isA<SetupFailed>());
      expect((s as SetupFailed).code, 'unexpected');
      expect(
        s.userText,
        contains('beklenmeyen'),
        reason:
            'ham hata metni yutulmamalı, kullanıcı diline karışmasa '
            'bile İZ olarak kalmalı',
      );
    });
  });
}
