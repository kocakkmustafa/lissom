import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../lissom_palette.dart';
import '../lissom_theme.dart';
import '../locale_text.dart';
import 'mirror_camera.dart';

/// Mirror (trial): the front camera's live preview, nothing else — no hint,
/// no score, no frame read. Released when the screen closes or the app
/// leaves the foreground; reopened on return.
class MirrorScreen extends StatefulWidget {
  const MirrorScreen({required this.title, this.camera, super.key});

  final String title;
  final MirrorCamera Function()? camera;

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen>
    with WidgetsBindingObserver {
  MirrorCamera? _camera;
  MirrorFailure? _failure;
  bool _live = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  void _open() {
    final MirrorCamera camera = _camera =
        (widget.camera ?? DeviceMirrorCamera.new)();
    _failure = null;
    unawaited(
      camera.open().then((MirrorFailure? f) {
        if (!mounted || !identical(_camera, camera)) {
          unawaited(camera.close());
          return;
        }
        setState(() {
          _failure = f;
          _live = f == null;
          if (f != null) _release();
        });
      }),
    );
  }

  void _release() {
    final MirrorCamera? c = _camera;
    _camera = null;
    _live = false;
    if (c != null) unawaited(c.close().catchError((Object _) {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused ||
          AppLifecycleState.hidden ||
          AppLifecycleState.detached:
        if (_camera != null) setState(_release);
      case AppLifecycleState.resumed:
        if (_camera == null && _failure != MirrorFailure.permissionDenied) {
          setState(_open);
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MirrorCamera? camera = _camera;
    final MirrorFailure? f = _failure;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LissomPalette.of(context).screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          children: <Widget>[
            LissomEyebrow(
              localeText(context, 'Mirror · trial', 'Ayna · deneme'),
            ),
            const SizedBox(height: 10),
            if (_live && camera != null)
              ClipRRect(
                key: const Key('camera.mirror.preview'),
                borderRadius: BorderRadius.circular(16),
                child: camera.preview(),
              )
            else
              LissomCard(
                key: const Key('camera.mirror.status'),
                child: Text(switch (f) {
                  null => localeText(
                    context,
                    'Starting the camera…',
                    'Kamera açılıyor…',
                  ),
                  MirrorFailure.permissionDenied ||
                  MirrorFailure.permissionPermanent => localeText(
                    context,
                    'Camera access is off for Lissom. You can turn it on in Settings.',
                    'Lissom için kamera izni kapalı. Ayarlar’dan açabilirsin.',
                  ),
                  MirrorFailure.noCamera => localeText(
                    context,
                    'No camera was found on this device.',
                    'Bu cihazda kamera bulunamadı.',
                  ),
                  MirrorFailure.failed => localeText(
                    context,
                    'The camera could not start. Go back and try again.',
                    'Kamera başlatılamadı. Geri dönüp yeniden dene.',
                  ),
                }),
              ),
            const SizedBox(height: 12),
            Text(
              localeText(
                context,
                'The mirror only shows the front camera. It gives no hints and no score, and the image is not recorded or sent.',
                'Ayna yalnız ön kamerayı gösterir. İpucu ya da puan vermez; görüntü kaydedilmez, gönderilmez.',
              ),
              key: const Key('camera.mirror.honesty'),
            ),
            const SizedBox(height: 16),
            if (f == MirrorFailure.permissionPermanent ||
                f == MirrorFailure.permissionDenied)
              OutlinedButton(
                key: const Key('camera.mirror.settings'),
                onPressed: () => unawaited(openAppSettings()),
                child: Text(
                  localeText(context, 'Open Settings', 'Ayarlar’ı aç'),
                ),
              ),
            FilledButton(
              key: const Key('camera.mirror.back'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localeText(context, 'Back to the lesson', 'Derse dön'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
