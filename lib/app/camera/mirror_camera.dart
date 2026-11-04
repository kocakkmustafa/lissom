import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

import 'camera_handoff.dart';

enum MirrorFailure { permissionDenied, permissionPermanent, noCamera, failed }

/// Mirror: a live front-camera preview and nothing else (Ostinato K8
/// method). No image stream, no recording, no audio: the image goes from the
/// sensor to the screen and app code never reads it.
abstract interface class MirrorCamera {
  /// `null` = the preview is live.
  Future<MirrorFailure?> open();

  /// Only after [open] returned `null`.
  Widget preview();

  /// Idempotent; safe before, during or after [open].
  Future<void> close();
}

final class DeviceMirrorCamera implements MirrorCamera {
  DeviceMirrorCamera({
    Future<PermissionStatus> Function()? requestPermission,
    Future<List<CameraDescription>> Function()? cameras,
  }) : _requestPermission = requestPermission ?? Permission.camera.request,
       _cameras = cameras ?? availableCameras;

  final Future<PermissionStatus> Function() _requestPermission;
  final Future<List<CameraDescription>> Function() _cameras;
  CameraController? _controller;
  Future<void>? _closing;
  bool _closed = false;

  @override
  Future<MirrorFailure?> open() async {
    try {
      await awaitCameraHandoff();
      if (_closed) return MirrorFailure.failed;
      final PermissionStatus p = await _requestPermission();
      if (_closed) return MirrorFailure.failed;
      if (!p.isGranted) {
        return p.isPermanentlyDenied || p.isRestricted
            ? MirrorFailure.permissionPermanent
            : MirrorFailure.permissionDenied;
      }
      final List<CameraDescription> all = await _cameras();
      if (all.isEmpty) return MirrorFailure.noCamera;
      final CameraDescription lens = all.firstWhere(
        (CameraDescription c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => all.first,
      );
      if (_closed) return MirrorFailure.failed;
      final CameraController c = _controller = CameraController(
        lens,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await c.initialize();
      return _closed ? MirrorFailure.failed : null;
    } on CameraException catch (e) {
      unawaited(close());
      return switch (e.code) {
        'CameraAccessDenied' ||
        'CameraAccessDeniedWithoutPrompt' ||
        'CameraAccessRestricted' => MirrorFailure.permissionPermanent,
        _ => MirrorFailure.failed,
      };
    } on Object {
      unawaited(close());
      return MirrorFailure.failed;
    }
  }

  @override
  Widget preview() => CameraPreview(_controller!);

  @override
  Future<void> close() => _closing ??= _close();

  Future<void> _close() {
    _closed = true;
    final Future<void> done = _controller?.dispose() ?? Future<void>.value();
    noteCameraRelease(done);
    return done;
  }
}
