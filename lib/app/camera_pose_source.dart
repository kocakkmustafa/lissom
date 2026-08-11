/// Gerçek kamera → `PoseSource` adaptörü (kamera-kabuğu sevki, 2026-08-12).
///
/// `LiveEvaluator`/`AssessmentEngine` DEĞİŞMEZ: `PoseSource` arayüzünü
/// (M-F-272) dolduran bu sınıf `FakePoseSource`'un yerine geçer, motor
/// hangi kaynaktan geldiğini AYIRT ETMEZ.
///
/// ## Ostinato'dan desen alındı, KOD alınmadı (M-F-295)
///
/// Ostinato'nun GERÇEK `camera_pose_source.dart`ı okundu — kopyalanmadı.
/// Arayüz şekli farklı: Ostinato'nunki `start()/stop()` + iki ayrı stream
/// (`frames`/`status`); Lissom'unki (`live_evaluator.dart`) TEK birleşik
/// `events()` stream'i + sealed `PoseSourceEvent`. Bu sınıf Lissom'un
/// KENDİ arayüzüne yazıldı.
///
/// ## Kapanış kilidi (O-076/C-195) BİLEREK YOK
///
/// Ölçüldü (`docs/C-195-YARIS-OLCUMU-2026-08-12.md`, koordinatör hükmü):
/// Ostinato'nun asıl tetiklediği yol (iki AYRI ekran, iki AYRI controller
/// örneği) Lissom'un TEK-EKRAN mimarisinde yapısal olarak yok. Kalan risk
/// (retry-sırasında-stop, dispose-sırasında-start) TEK State içinde —
/// [_enqueue] bunu yerel bir sıralamayla çözer, paylaşımlı süreç-geneli
/// kilit GEREKMEZ (O-076 çekirdek kuyrukta, beş hat ortak, yerel çözüm
/// ayrışma üretirdi).
///
/// ## Kanıt sınıfı DÜRÜST — Ostinato'nun kendi itirafıyla AYNI
///
/// Bu dosya plumbing + izin + hâlleri kanıtlar. GERÇEK GÖRÜNTÜ kanıtı YOK:
/// iOS simülatöründe kamera donanımı yok, `start()` sim'de muhtemelen
/// `noSuchCamera`/kurulum hatasına düşer ve dürüst hâl ekranı açılır
/// (çıkmaz-sokak değil). **Bağlandı ≠ canlı** — gerçek ölçüm cihaz-günü,
/// kurucu kuyruğunda (üç somut gerekçe taşıyor: Ostinato ölçüm-yüzeyi ·
/// `trigger` politikası · şimdi kalibrasyon eşiği).
library;

import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_camera/motion_camera.dart';
import 'package:motion_core/motion_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pose_model.dart';

final class CameraPoseSource implements PoseSource {
  CameraPoseSource({MotionCameraController? controller})
      : _camera = controller ?? MotionCameraController();

  final MotionCameraController _camera;
  final StreamController<PoseSourceEvent> _events =
      StreamController<PoseSourceEvent>.broadcast();
  StreamSubscription<CameraFrameEnvelope>? _frameSub;

  /// Sıradaki işlem — `start()`/`dispose()` birbirini BEKLER, çakışmaz
  /// (bkz. sınıf dokümanı, C-195 ölçümü).
  Future<void> _chain = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() op) {
    final Future<void> next =
        _chain.catchError((Object _, StackTrace __) {}).then((_) => op());
    _chain = next;
    return next;
  }

  @override
  Stream<PoseSourceEvent> events() => _events.stream;

  Future<void> start() => _enqueue(_start);

  Future<void> _start() async {
    _events.add(const SourceStateEvent(LiveIdle()));
    final PermissionStatus perm = await Permission.camera.request();
    if (!perm.isGranted) {
      _events.add(SourceStateEvent(permissionState(perm)));
      return;
    }
    try {
      final String modelPath = await materializePoseModel();
      final CameraSessionInfo info = await _camera.start(
        modelPath: modelPath,
        modelId: kPoseModelId,
      );
      final FrameSize size = FrameSize(info.width, info.height);
      _frameSub = _camera.frames().listen(
        (CameraFrameEnvelope e) => _onEnvelope(e, size),
        onError: (Object err) =>
            _events.add(SourceStateEvent(failureState(err))),
      );
    } on CameraException catch (e) {
      _events.add(SourceStateEvent(failureState(e)));
    } on Object catch (e) {
      _events.add(SourceStateEvent(
          SetupFailed(code: 'unexpected', userText: 'Something unexpected '
              'happened while starting the camera ($e). Try again.')));
    }
  }

  void _onEnvelope(CameraFrameEnvelope e, FrameSize size) {
    // `PassPlan.uprightOnly` (varsayılan) HER zaman bu geçişi çalıştırır;
    // olmaması planlama hatası olurdu — `CameraFrameEnvelope.pass` kendi
    // `StateError`ünü fırlatır, kare-başına sessizce yutulmaz.
    if (!e.ran(BodyOrientation.upright)) return;
    final PoseFrame? frame = e.pass(BodyOrientation.upright);
    if (frame == null) {
      // MediaPipe kimseyi görmedi — uydurma bir okuma YOK.
      _events.add(const SourceStateEvent(NoPersonDetected()));
      return;
    }
    _events.add(SourceFrameEvent(frame, size: size));
  }

  @override
  Future<void> dispose() async {
    await _enqueue(_stop);
    await _events.close();
  }

  Future<void> _stop() async {
    await _frameSub?.cancel();
    _frameSub = null;
    try {
      await _camera.stop();
    } on Object {
      // Durdurmada arıza kullanıcıyı ilgilendirmez: oturum zaten bitiyor
      // (Ostinato deseni, camera_pose_source.dart `stop()`).
    }
  }
}

/// Üst-düzey fonksiyonlar (metot DEĞİL) — gerçek kamera donanımı OLMADAN,
/// yalnız `PermissionStatus`/`CameraException` DEĞERLERİ kurularak test
/// edilebilsin diye. `MotionCameraController` bir `MethodChannel` sarmalı
/// ve `flutter test`te platform kanalı mocklanmadan çağrılamaz — ama BU
/// eşleme mantığı saf, ve saf olan test edilir (Ostinato'nun "kanıt sınıfı
/// dürüst" itirafının Lissom'daki karşılığı: plumbing'in TAMAMI değil,
/// test EDİLEBİLEN kısmı sınanır).
@visibleForTesting
LiveSessionState permissionState(PermissionStatus perm) {
  final bool permanent = perm.isPermanentlyDenied || perm.isRestricted;
  return PermissionDenied(
    kind: permanent
        ? PermissionDenialKind.permanent
        : PermissionDenialKind.transient,
    userText: permanent
        ? 'Camera access is off for Lissom. Open Settings to turn it on.'
        : 'Lissom needs camera access to measure. Try again.',
  );
}

@visibleForTesting
LiveSessionState failureState(Object err) {
  if (err is CameraException) {
    if (err.failure == CameraFailure.permissionDenied) {
      return const PermissionDenied(
        kind: PermissionDenialKind.transient,
        userText: 'Lissom needs camera access to measure. Try again.',
      );
    }
    return SetupFailed(
      code: err.failure.code,
      userText: 'The camera could not start (${err.failure.code}). Try again.',
    );
  }
  return SetupFailed(
    code: 'unexpected',
    userText: 'Something unexpected happened ($err). Try again.',
  );
}
