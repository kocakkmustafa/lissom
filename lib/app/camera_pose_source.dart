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
/// ## Sahipli kapanış
///
/// İzin/model hazırlığından önce bir Core capture lease yaratılır. Dispose
/// isteği hazırlık kuyruğunu beklemeden senkron retire eder; admitted native
/// iş, raw stream iptali ve exact owner ACK/readback Core close bariyerindedir.
/// Eski/ret edilmiş route başka bir route'un native oturumunu durduramaz.
/// Uygulamanın varsayılan controller lifetime'ı route'ları aşar; uncertain
/// kapanış yeni controller yaratarak geçilmez. Gerçek native kabul ayrı kalır.
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

/// `PoseSource.events()`/`.dispose()` yeterli DEĞİL bir GERÇEK kaynak için:
/// bir izin isteği + native oturum açılışı gerektiği için AYRI bir
/// `start()` adımı şart — `FakePoseSource` bunu istemez (`events()`
/// çağrılınca script'i hemen yayar). `LiveCaptureScreen` kaynağın
/// `StartablePoseSource` olup olmadığını KONTROL EDER (bkz. o dosya) —
/// `PoseSource`'un kendisi (motorda yaşıyor) değiştirilmedi.
abstract interface class StartablePoseSource implements PoseSource {
  Future<void> start();
}

// Keep Core's controller-local closure quarantine across route-created sources.
// Tests inject their own controller; production does not recreate this on retry.
final MotionCameraController _appCameraController = MotionCameraController();

final class CameraPoseSource implements StartablePoseSource {
  /// Callback injection holds preparation in lifecycle tests. The defaults
  /// still request OS permission and unpack the pinned model.
  CameraPoseSource({
    MotionCameraController? controller,
    Future<PermissionStatus> Function()? requestPermission,
    Future<String> Function()? prepareModel,
  }) : _capture = (controller ?? _appCameraController).createCaptureLease(),
       _requestPermission = requestPermission ?? Permission.camera.request,
       _prepareModel = prepareModel ?? materializePoseModel;

  final CameraCaptureLease _capture;
  final Future<PermissionStatus> Function() _requestPermission;
  final Future<String> Function() _prepareModel;
  final StreamController<PoseSourceEvent> _events =
      StreamController<PoseSourceEvent>.broadcast();
  StreamSubscription<CameraFrameEnvelope>? _frameSub;
  bool _retired = false;
  Future<void>? _disposeFuture;

  /// Serialize preparation attempts. Disposal never queues behind permission
  /// or materialization; Core owns the admitted native start/close barrier.
  Future<void> _chain = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() op) {
    final Future<void> next = _chain
        .catchError((Object _, StackTrace __) {})
        .then((_) => op());
    _chain = next;
    return next;
  }

  @override
  Stream<PoseSourceEvent> events() => _events.stream.where((_) => !_retired);

  @override
  Future<void> start() =>
      _retired || _capture.isRetired ? Future<void>.value() : _enqueue(_start);

  void _emit(PoseSourceEvent event) {
    if (!_retired && !_events.isClosed) _events.add(event);
  }

  Future<void> _start() async {
    if (_retired || _capture.isRetired || _capture.sessionInfo != null) return;
    _emit(const SourceStateEvent(LiveIdle()));
    try {
      if (_retired) return;
      final PermissionStatus perm = await _requestPermission();
      if (_retired) return;
      if (!perm.isGranted) {
        _emit(SourceStateEvent(permissionState(perm)));
        return;
      }
      final String modelPath = await _prepareModel();
      if (_retired) return;
      final CameraSessionInfo info = await _capture.start(
        modelPath: modelPath,
        modelId: kPoseModelId,
      );
      if (_retired) return;
      final FrameSize size = FrameSize(info.width, info.height);
      _frameSub = _capture.frames().listen(
        (CameraFrameEnvelope e) => _onEnvelope(e, size),
        onError: (Object err) => _emit(SourceStateEvent(failureState(err))),
      );
    } on CameraException catch (e) {
      _emit(SourceStateEvent(failureState(e)));
    } on Object {
      _emit(
        SourceStateEvent(
          SetupFailed(
            code: 'unexpected',
            userText:
                'Something unexpected happened while starting the camera. Try again.',
          ),
        ),
      );
    }
  }

  void _onEnvelope(CameraFrameEnvelope e, FrameSize size) {
    if (_retired) return;
    // `PassPlan.uprightOnly` (varsayılan) HER zaman bu geçişi çalıştırır;
    // olmaması planlama hatası olurdu — `CameraFrameEnvelope.pass` kendi
    // `StateError`ünü fırlatır, kare-başına sessizce yutulmaz.
    if (!e.ran(BodyOrientation.upright)) return;
    final PoseFrame? frame = e.pass(BodyOrientation.upright);
    if (frame == null) {
      // MediaPipe kimseyi görmedi — uydurma bir okuma YOK.
      _emit(const SourceStateEvent(NoPersonDetected()));
      return;
    }
    _emit(SourceFrameEvent(frame, size: size));
  }

  @override
  Future<void> dispose() {
    _retired = true;
    _capture.retire();
    final existing = _disposeFuture;
    if (existing != null) return existing;
    final nativeClosed = _capture.close();
    final frameSub = _frameSub;
    _frameSub = null;
    // A paused app listener may delay its local done event. It owns no native
    // resource and must not delay the host's close/drain barrier.
    unawaited(_events.close());
    final closing = Future.wait<void>(<Future<void>>[
      nativeClosed,
      if (frameSub != null) frameSub.cancel(),
    ]).then<void>((_) {});
    _disposeFuture = closing;
    // Preserve the failing Future for callers while observing fire-and-forget
    // route teardown. Uncertain closure must never be reported as success.
    unawaited(
      closing.then<void>((_) {}, onError: (Object _, StackTrace __) {}),
    );
    return closing;
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
    // 🔴 **TALİMAT BURADAN ÇIKARILDI — cihazda yürürken görüldü (L-320).**
    // Ekran bu metni bir ÜST satır olarak basıyor, altına da `kind`den
    // TÜRETİLEN bir yönerge ekliyor. İkisi de talimat taşıyınca kullanıcı
    // aynı cümleyi iki kez okuyordu:
    //   *"Camera access is off for Lissom. **Open Settings to turn it on.**"*
    //   *"**Open Settings to turn camera access on for Lissom.**"*
    // (Geçici dalda da aynısı: *"… Try again."* + *"You can try again."*)
    //
    // ⇒ Roller ayrıldı: **kaynak OLGUYU bildirir, ekran EYLEMİ sunar.**
    // Bu yalnız tekrarı silmiyor, katman sınırını da düzeltiyor — bir poz
    // kaynağının kullanıcıya *ne yapması gerektiğini* söylemesi zaten onun
    // işi değildi.
    // > ***AYNI CÜMLEYİ İKİ KATMAN BİRDEN SÖYLÜYORSA, BİRİ ONU
    // > SÖYLEMEMELİDİR — VE HANGİSİ OLDUĞU KATMAN SINIRINDAN OKUNUR.***
    userText: permanent
        ? 'Camera access is off for Lissom.'
        : 'Lissom needs camera access to measure.',
  );
}

@visibleForTesting
LiveSessionState failureState(Object err) {
  if (err is CameraException) {
    if (err.failure == CameraFailure.permissionDenied) {
      return const PermissionDenied(
        kind: PermissionDenialKind.transient,
        // Talimat yok — eylem ekranın işi (yukarıdaki gerekçe, L-320).
        userText: 'Lissom needs camera access to measure.',
      );
    }
    return SetupFailed(
      code: err.failure.code,
      userText: 'The camera could not start. Try again.',
    );
  }
  return SetupFailed(
    code: 'unexpected',
    userText:
        'Something unexpected happened while starting the camera. Try again.',
  );
}
