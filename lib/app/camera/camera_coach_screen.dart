import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_camera/motion_camera.dart'
    show CameraSessionInfo, MotionCameraPreview;
import 'package:motion_core/motion_core.dart';
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import '../camera_pose_source.dart';
import '../lissom_palette.dart';
import '../lissom_theme.dart';
import '../locale_text.dart';
import 'camera_catalog_copy.dart';
import 'camera_handoff.dart';
import 'coach_speaker.dart';

const String kCameraPosesAsset = 'config/yoga/camera-poses.v1.json';

Future<CameraPoseCatalog> loadCameraPoseCatalog({AssetBundle? bundle}) async =>
    CameraPoseCatalog.parse(
      await (bundle ?? rootBundle).loadString(kCameraPosesAsset),
    );

/// Camera coaching for one pose (trial). Shows the mirror (the same camera
/// session's preview texture, Core motion_camera 0.4.0) with the body
/// outline and a vertical reference line drawn from the landmarks on top, the
/// hold timer and the one current correction, which is also spoken. Without
/// a preview texture it shows the outline alone. App code never reads the
/// image; it goes from the camera to the screen.
class CameraCoachScreen extends StatefulWidget {
  const CameraCoachScreen({
    required this.catalog,
    required this.pose,
    this.sourceFactory,
    this.speaker,
    super.key,
  });

  final CameraPoseCatalog catalog;
  final CameraPoseSpec pose;
  final PoseSource Function()? sourceFactory;
  final CoachSpeaker? speaker;

  @override
  State<CameraCoachScreen> createState() => _CameraCoachScreenState();
}

class _CameraCoachScreenState extends State<CameraCoachScreen>
    with WidgetsBindingObserver {
  PoseSource? _source;
  StreamSubscription<PoseSourceEvent>? _sub;
  late CameraCoach _coach;
  late final CoachSpeaker _speaker = widget.speaker ?? DeviceCoachSpeaker();
  CameraCoachState? _state;
  LiveSessionState? _sourceState;
  PoseFrame? _frame;
  // The bridge delivers portrait frames (Core motion_camera contract).
  FrameSize _size = const FrameSize(720, 1280);
  CameraCorrection? _lastSaid;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // motion_camera normalizes frames to portrait: a landscape phone would
    // turn the body sideways in the image, so this screen stays portrait.
    unawaited(
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]),
    );
    _coach = CameraCoach(catalog: widget.catalog, pose: widget.pose);
    unawaited(_start());
  }

  Future<void> _start() async {
    final PoseSource source =
        (widget.sourceFactory ?? () => CameraPoseSource(preview: true))();
    _source = source;
    _sub = source.events().listen(_onEvent);
    await awaitCameraHandoff();
    if (!mounted || !identical(_source, source)) return;
    if (source is StartablePoseSource) await source.start();
  }

  void _stop() {
    final PoseSource? source = _source;
    _source = null;
    unawaited(_sub?.cancel());
    _sub = null;
    if (source != null) noteCameraRelease(source.dispose());
    unawaited(_speaker.stop());
  }

  void _onEvent(PoseSourceEvent e) {
    if (!mounted) return;
    switch (e) {
      case SourceStateEvent(state: final LiveSessionState s):
        if (s is NoPersonDetected) {
          final int t = (_frame?.tUs ?? 0) + 33333;
          _apply(_coach.add(null, _size, t), null);
        } else {
          setState(() => _sourceState = s);
        }
      case SourceFrameEvent(frame: final PoseFrame f, size: final FrameSize z):
        _size = z;
        _apply(_coach.add(f, z, f.tUs), f);
    }
  }

  void _apply(CameraCoachState s, PoseFrame? f) {
    final CameraCorrection? say = s.speak;
    if (say != null) {
      unawaited(
        _speaker.speak(
          cameraCatalogText(context, say.english, say.turkish),
          Localizations.localeOf(context),
        ),
      );
    }
    setState(() {
      _sourceState = null;
      _state = s;
      _frame = f;
      if (say != null) _lastSaid = say;
      if (s.phase == CameraCoachPhase.done) _stop();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_source != null) setState(() => _paused = true);
      _stop();
    }
  }

  void _resume() {
    setState(() {
      _paused = false;
      _frame = null;
      _state = null;
      _sourceState = null;
      _coach = CameraCoach(catalog: widget.catalog, pose: widget.pose);
    });
    unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    unawaited(
      SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]),
    );
    super.dispose();
  }

  String _setupText(BuildContext context, CameraSetupIssue issue) =>
      switch (issue) {
        CameraSetupIssue.noPerson => localeText(
          context,
          'No one is in view. Step into the camera view.',
          'Görüntüde kimse yok. Kameranın görüş alanına gir.',
        ),
        CameraSetupIssue.bodyNotFull => localeText(
          context,
          'Your whole body must be in view, head to feet.',
          'Baştan ayağa tüm vücudun görünmeli.',
        ),
        CameraSetupIssue.notSideOn => localeText(
          context,
          'Turn so your side faces the phone.',
          'Yanın telefona bakacak şekilde dön.',
        ),
        CameraSetupIssue.tooClose => localeText(
          context,
          'Move a little further from the phone.',
          'Telefondan biraz uzaklaş.',
        ),
        CameraSetupIssue.tooFar => localeText(
          context,
          'Come a little closer to the phone.',
          'Telefona biraz yaklaş.',
        ),
        CameraSetupIssue.unclearView => localeText(
          context,
          'The view is not clear. Add light or choose a plainer background.',
          'Görüntü net değil. Işığı artır ya da daha sade bir arka plan seç.',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CameraCoachState? s = _state;
    final String poseName = cameraCatalogText(
      context,
      widget.pose.nameEnglish,
      widget.pose.nameTurkish,
    );
    final LiveSessionState? src = _sourceState;
    final List<Widget> status = <Widget>[];
    if (_paused) {
      status.add(
        Text(
          localeText(
            context,
            'The camera stopped while Lissom was in the background.',
            'Lissom arka plandayken kamera durdu.',
          ),
          key: const Key('camera.coach.paused'),
        ),
      );
    } else if (src is PermissionDenied) {
      status.add(
        Text(
          localeText(
            context,
            'Camera access is off for Lissom. You can turn it on in Settings.',
            'Lissom için kamera izni kapalı. Ayarlar’dan açabilirsin.',
          ),
          key: const Key('camera.coach.permission'),
        ),
      );
    } else if (src is SetupFailed) {
      status.add(
        Text(
          localeText(
            context,
            'The camera could not start. Go back and try again.',
            'Kamera başlatılamadı. Geri dönüp yeniden dene.',
          ),
          key: const Key('camera.coach.failed'),
        ),
      );
    } else if (s == null) {
      status.add(
        Text(localeText(context, 'Starting the camera…', 'Kamera açılıyor…')),
      );
    } else if (s.phase == CameraCoachPhase.setup) {
      status.add(
        Text(
          s.setupIssue == null
              ? localeText(
                  context,
                  'Hold still for a moment…',
                  'Bir an sabit dur…',
                )
              : _setupText(context, s.setupIssue!),
          key: const Key('camera.coach.setup'),
          style: theme.textTheme.titleMedium,
        ),
      );
    } else if (s.phase == CameraCoachPhase.done) {
      status.add(
        Text(
          localeText(
            context,
            'Time is up. Come out of the pose slowly and rest.',
            'Süre tamam. Duruştan yavaşça çık ve dinlen.',
          ),
          key: const Key('camera.coach.done'),
          style: theme.textTheme.titleMedium,
        ),
      );
    } else {
      status.add(
        Text(
          s.setupIssue != null
              ? _setupText(context, s.setupIssue!)
              : s.inPose
              ? localeTemplate(
                  context,
                  'You are in {pose}.',
                  '{pose} duruşundasın.',
                  <String, Object>{'pose': poseName},
                )
              : localeTemplate(
                  context,
                  'You are not in {pose}.',
                  '{pose} duruşunda değilsin.',
                  <String, Object>{'pose': poseName},
                ),
          key: const Key('camera.coach.pose'),
          style: theme.textTheme.titleMedium,
        ),
      );
    }
    if (s != null &&
        (s.phase == CameraCoachPhase.holding ||
            s.phase == CameraCoachPhase.done)) {
      status.add(const SizedBox(height: 8));
      status.add(
        Text(
          localeTemplate(
            context,
            'Held {held} of {target} seconds',
            '{target} saniyenin {held} saniyesi tutuldu',
            <String, Object>{
              'held': localizedInteger(context, s.heldSeconds.floor()),
              'target': localizedInteger(context, s.targetSeconds),
            },
          ),
          key: const Key('camera.coach.timer'),
        ),
      );
    }
    final CameraCorrection? said = _lastSaid;
    return Scaffold(
      appBar: AppBar(title: Text(poseName)),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LissomPalette.of(context).screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          children: <Widget>[
            LissomEyebrow(
              localeText(
                context,
                'Camera coaching · trial',
                'Kamera koçluğu · deneme',
              ),
            ),
            const SizedBox(height: 10),
            if (s == null || s.phase == CameraCoachPhase.setup)
              LissomCard(
                key: const Key('camera.coach.setupGuide'),
                child: Text(
                  localeText(
                    context,
                    'Stand the phone upright, about 2.5–3 m away, with your side facing it. Keep your whole body in view and stay alone in the frame.',
                    'Telefonu dik olarak yaklaşık 2,5–3 m uzağa koy; yanın telefona baksın. Tüm vücudun görünsün ve kadrajda yalnız ol.',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ...status,
            if (said != null && !_paused) ...<Widget>[
              const SizedBox(height: 12),
              LissomCard(
                key: const Key('camera.coach.correction'),
                child: Text(
                  cameraCatalogText(context, said.english, said.turkish),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _CoachView(
              source: _source,
              size: _size,
              painter: _BodyOutlinePainter(
                frame: _frame,
                color: s != null && s.inPose
                    ? LissomPalette.of(context).primaryFill
                    : LissomPalette.of(context).textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (src is PermissionDenied)
              OutlinedButton(
                key: const Key('camera.coach.settings'),
                onPressed: () => unawaited(openAppSettings()),
                child: Text(
                  localeText(context, 'Open Settings', 'Ayarlar’ı aç'),
                ),
              ),
            if (_paused)
              OutlinedButton(
                key: const Key('camera.coach.resume'),
                onPressed: _resume,
                child: Text(
                  localeText(context, 'Start again', 'Yeniden başlat'),
                ),
              ),
            FilledButton(
              key: const Key('camera.coach.back'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localeText(context, 'Back to the lesson', 'Derse dön'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              localeText(
                context,
                'This is a coaching hint, not a score or a health assessment. Stop whenever you need to. The camera image stays on this phone; it is not recorded or sent.',
                'Bu bir koçluk ipucudur; puan ya da sağlık değerlendirmesi değildir. İstediğin an dur. Kamera görüntüsü bu telefonda kalır; kaydedilmez, gönderilmez.',
              ),
              key: const Key('camera.coach.honesty'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// The mirror with the outline on top when the source offers a preview
/// texture (Core motion_camera 0.4.0, one camera for both); otherwise the
/// outline alone on a plain card. The texture image never reaches app code.
class _CoachView extends StatelessWidget {
  const _CoachView({
    required this.source,
    required this.size,
    required this.painter,
  });

  final PoseSource? source;
  final FrameSize size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    final PoseSource? s = source;
    final Widget outline = AspectRatio(
      aspectRatio: size.aspect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: LissomPalette.of(context).card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomPaint(
          key: const Key('camera.coach.outline'),
          painter: painter,
        ),
      ),
    );
    if (s is! CameraPoseSource) return outline;
    return ValueListenableBuilder<CameraSessionInfo?>(
      valueListenable: s.session,
      builder: (BuildContext context, CameraSessionInfo? info, _) =>
          info?.previewTextureId == null
          ? outline
          : ClipRRect(
              key: const Key('camera.coach.mirror'),
              borderRadius: BorderRadius.circular(16),
              child: MotionCameraPreview(
                session: info!,
                overlay: CustomPaint(painter: painter),
              ),
            ),
    );
  }
}

/// Draws the body from landmarks, plus a dashed vertical reference line
/// through the hips (a plumb line to compare the trunk with — a reference,
/// not a target the learner must reach).
class _BodyOutlinePainter extends CustomPainter {
  _BodyOutlinePainter({required this.frame, required this.color});

  final PoseFrame? frame;
  final Color color;

  static const List<(int, int)> _bones = <(int, int)>[
    (Lm.leftShoulder, Lm.rightShoulder),
    (Lm.leftShoulder, Lm.leftElbow),
    (Lm.leftElbow, Lm.leftWrist),
    (Lm.rightShoulder, Lm.rightElbow),
    (Lm.rightElbow, Lm.rightWrist),
    (Lm.leftShoulder, Lm.leftHip),
    (Lm.rightShoulder, Lm.rightHip),
    (Lm.leftHip, Lm.rightHip),
    (Lm.leftHip, Lm.leftKnee),
    (Lm.leftKnee, Lm.leftAnkle),
    (Lm.rightHip, Lm.rightKnee),
    (Lm.rightKnee, Lm.rightAnkle),
    (Lm.leftAnkle, Lm.leftFootIndex),
    (Lm.rightAnkle, Lm.rightFootIndex),
    (Lm.leftShoulder, Lm.leftEar),
    (Lm.rightShoulder, Lm.rightEar),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final PoseFrame? f = frame;
    if (f == null) return;
    final Paint p = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    Offset at(int i) => Offset(f[i].x * size.width, f[i].y * size.height);
    for (final (int a, int b) in _bones) {
      if (f.visibility(a) < 0.5 || f.visibility(b) < 0.5) continue;
      canvas.drawLine(at(a), at(b), p);
    }
    if (f.visibility(Lm.nose) >= 0.5) {
      canvas.drawCircle(at(Lm.nose), 8, p..style = PaintingStyle.stroke);
    }
    if (f.visibility(Lm.leftHip) >= 0.5 && f.visibility(Lm.rightHip) >= 0.5) {
      final double x = (at(Lm.leftHip).dx + at(Lm.rightHip).dx) / 2;
      final Paint line = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 2;
      for (double y = 0; y < size.height; y += 18) {
        canvas.drawLine(Offset(x, y), Offset(x, y + 9), line);
      }
    }
  }

  @override
  bool shouldRepaint(_BodyOutlinePainter old) =>
      old.frame != frame || old.color != color;
}
