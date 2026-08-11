/// Canlı ölçüm ekranı — kamera-kabuğu sevkinin SIRA③'ü (2026-08-12).
///
/// **Bağlandı ≠ canlı — isimli, isimle:**
///
/// | Doğrulandı BUGÜN | Cihazda DOĞRULANMADI |
/// |---|---|
/// | İzin akışı (kod yolu, saf mantık testleriyle) | İzin akışının GERÇEK cihazda diyalog açtığı |
/// | Motor bağlantısı (`AssessmentEngine.process`) | Kare akışının GERÇEK kamerada aktığı |
/// | Hâl makinesi (`LiveEvaluator`/`LiveSessionState`) | Landmark kalitesinin GERÇEK ışıkta/mesafede yeterli olduğu |
/// | — | Kalibrasyon eşiğinin (yaw ≤10°, ADR-002) GERÇEK kullanımda tutması |
///
/// Simülatörde kamera donanımı yok — `start()` muhtemelen `noSuchCamera`ya
/// düşer ve dürüst hâl ekranı açılır (çıkmaz-sokak değil, Ostinato deseni).
///
/// ## Kasıtlı olarak KÜÇÜK bırakılan kapsam — isimle
///
/// - **Tek test, tek deneme.** `AssessmentSession`in çok-bloklu orkestrası
///   (`assessment_session.dart`) BAĞLANMADI — bu ekran TEK bir
///   `AssessmentEngine` koşumu. Bir sonraki tur: blok akışı.
/// - **Bitiş MANUEL** ("I'm done" düğmesi). Faz-makinesi tabanlı otomatik
///   tekrar-algılama (`motion_core`'un `PhaseStateMachine`ı) BAĞLANMADI —
///   ayrı, daha büyük bir iş.
/// - **Kalibrasyon profili YOK.** `provenance`taki `calibrationProfile`
///   alanı bilerek boş (M-F-07 alanı — bir sonraki tur).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'camera_pose_source.dart';
import 'lissom_theme.dart';
import 'pose_model.dart';
import 'surfaces.dart';

class LiveCaptureScreen extends StatefulWidget {
  const LiveCaptureScreen({
    required this.test,
    required this.batteryVersion,
    this.side = 'right',
    this.sourceOverride,
    super.key,
  });

  final TestSpec test;
  final String batteryVersion;
  final String side;

  /// Testte enjekte edilebilir (`FakePoseSource`) — `LissomShell`in
  /// `loader` deseniyle AYNI sözleşme. `null` iken gerçek `CameraPoseSource`.
  final PoseSource? sourceOverride;

  @override
  State<LiveCaptureScreen> createState() => _LiveCaptureScreenState();
}

class _LiveCaptureScreenState extends State<LiveCaptureScreen> {
  late final PoseSource _source = widget.sourceOverride ?? CameraPoseSource();
  late final LiveEvaluator _evaluator =
      LiveEvaluator(test: widget.test, side: widget.side, source: _source);
  late AssessmentEngine _engine = _newEngine();

  StreamSubscription<LiveSessionState>? _stateSub;
  StreamSubscription<PoseSourceEvent>? _rawSub;
  FrameSize? _latestSize;

  LiveSessionState _state = const LiveIdle();
  AssessmentResult? _result;

  AssessmentEngine _newEngine() => AssessmentEngine(
        test: widget.test,
        side: widget.side,
        metricReader: _readMetric,
        provenance: <String, String>{
          'modelId': kPoseModelId,
          'batteryVersion': widget.batteryVersion,
        },
      );

  double? _readMetric(PoseFrame frame, String metricName) {
    final FrameSize? size = _latestSize;
    if (size == null) return null;
    return CoreMetricReader(frameSize: size).read(frame, metricName);
  }

  @override
  void initState() {
    super.initState();
    _stateSub = _evaluator.states().listen((LiveSessionState s) {
      if (mounted) setState(() => _state = s);
    });
    _rawSub = _source.events().listen(_onRawEvent);
    final PoseSource s = _source;
    if (s is StartablePoseSource) {
      s.start();
    }
  }

  void _onRawEvent(PoseSourceEvent e) {
    if (_result != null) return; // deneme bitti, motor daha fazla kare almaz
    if (e is SourceFrameEvent) {
      _latestSize = e.size;
      _engine.process(e.frame);
    }
  }

  void _finish() {
    setState(() => _result = _engine.finish());
  }

  void _tryAgain() {
    setState(() {
      _result = null;
      _engine = _newEngine();
    });
    final PoseSource s = _source;
    if (s is StartablePoseSource) {
      s.start();
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _rawSub?.cancel();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.test.name)),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: _result != null
                ? _ResultView(result: _result!, onTryAgain: _tryAgain)
                : _LiveView(state: _state, onFinish: _finish),
          ),
        ),
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({required this.state, required this.onFinish});

  final LiveSessionState state;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final LiveSessionState s = state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const NamedGapCard(
          title: 'Not verified on a real device',
          reason: 'This connects the camera, the measurement engine, and '
              'the live display for the first time. It has not been tried '
              'on a real phone: permission dialogs, real frame quality, '
              'and calibration still need a device pass.',
        ),
        const SizedBox(height: 18),
        Text(s.userText, style: t.textTheme.titleMedium),
        if (s case PermissionDenied(:final bool retryMakesSense))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              retryMakesSense
                  ? 'You can try again.'
                  : 'Open Settings to turn camera access on for Lissom.',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: LissomColors.bodySecondary),
            ),
          ),
        const Spacer(),
        if (s.canMeasure)
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const Key('liveCapture.finish'),
              onPressed: onFinish,
              child: const Text("I'm done"),
            ),
          ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.onTryAgain});

  final AssessmentResult result;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final AssessmentResult r = result;
    final String headline = r.isMeasured
        ? '${r.value!.toStringAsFixed(0)}${r.unit ?? ''}'
        : 'Not measured';
    final String detail = r.isMeasured
        ? 'This is your starting point — we\'ll track it from here.'
        : 'Reason: ${r.code.name}.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(headline, style: t.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(detail, style: t.textTheme.bodyMedium),
        const Spacer(),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            key: const Key('liveCapture.tryAgain'),
            onPressed: onTryAgain,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}
