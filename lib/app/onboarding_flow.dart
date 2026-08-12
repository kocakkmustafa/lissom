/// Onboarding akışı — O1 Welcome → O2 Disclaimer → O3 Camera permission →
/// O4 Profile → O5 Measurement limits (`docs/design/UI-BRIEF.md` §2.1).
///
/// **O3 (2026-08-12 GÜNCELLENDİ):** `CameraPoseSource` bağlandığı GÜN,
/// AYNI commit'te O3 brief'in aslına döndü — gerçek bir izin isteği
/// (`test/onboarding_camera_gate_test.dart` bunu zorluyor, koordinatör
/// şartı: "bugün doğru olan bir dürüstlük metni, bir sonraki commit'le
/// yalana dönebilir"). İzin isteği kullanıcı dokunuşuyla tetiklenir,
/// ekran açılır açılmaz otomatik DEĞİL.
///
/// ⛔ **O6 hâlâ BİLEREK atlandı** — "canlı iskelet önizlemeli kamera
/// kurulumu" ayrı, daha büyük bir iş (canlı-ölçüm ekranı), isimli açık.
///
/// O4 (profil) brief'te "izin verildi" dalına bağlıydı; burada KOŞULSUZ
/// gösteriliyor — yaş bandı toplamak kamera durumundan bağımsız bir iştir
/// ve kamera bağlandığı gün kullanıcı ikinci bir onboarding turu görmemeli.
library;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'lissom_theme.dart';
import 'onboarding_store.dart';
import 'surfaces.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({required this.store, required this.onDone, super.key});

  final OnboardingStore store;

  /// Akış TAMAMLANDIĞINDA, **az önce YAZILAN profille** çağrılır — kabuğa
  /// geçiş çağıranın sorumluluğu (bu widget navigasyon kararı VERMEZ).
  ///
  /// ⚠️ Profil parametresi şart: geçit `_loaded`'ı diskten YENİDEN OKUMUYOR
  /// (bilerek — yazma aynı çağrı zincirinde oldu). Bu yüzden onboarding'i
  /// AZ ÖNCE bitiren kullanıcının bandı buradan geçmezse, kabuk açılışta
  /// okunmuş BOŞ profili görür ve bant ancak **bir sonraki açılışta**
  /// etki ederdi — yani ilk ölçüm sessizce yanlış bantla koşardı.
  final ValueChanged<OnboardingProfile> onDone;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _Step { welcome, disclaimer, camera, profile, limits }

/// Kullanıcıya görünen ETİKET — anahtar DEĞİL. Anahtarların tek adresi
/// [kOfferedAgeBands]; buradan bir bant EKSİKSE ekranda ham config değeri
/// («60plus») görünür, o yüzden `age_band_wiring_test.dart` kapsamı sınar.
const Map<String, String> kAgeBandLabels = <String, String>{
  'u40': 'Under 40',
  '40-59': '40–59',
  '60plus': '60 or over',
};

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.welcome;
  bool _disclaimerAcked = false;
  String? _ageBand;
  String _gender = '';
  String _painNotes = '';
  bool _saving = false;

  static const List<_Step> _order = _Step.values;

  int get _index => _order.indexOf(_step);

  bool get _canContinue => switch (_step) {
        _Step.welcome => true,
        _Step.disclaimer => _disclaimerAcked,
        _Step.camera => true,
        _Step.profile => _ageBand != null,
        _Step.limits => true,
      };

  void _next() {
    if (!_canContinue) return;
    final int i = _index;
    if (i == _order.length - 1) {
      _finish();
      return;
    }
    setState(() => _step = _order[i + 1]);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final OnboardingProfile profile = OnboardingProfile(
      completed: true,
      ageBand: _ageBand,
      gender: _gender.trim().isEmpty ? null : _gender.trim(),
      painNotes: _painNotes.trim().isEmpty ? null : _painNotes.trim(),
    );
    await widget.store.write(profile);
    if (!mounted) return;
    // Diske YAZILAN nesnenin AYNISI geçiyor — ikinci bir kopya kurulsaydı
    // iki kaynak tek olgu olurdu (L-272) ve sessizce ayrışabilirdi.
    widget.onDone(profile);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration:
            const BoxDecoration(gradient: LissomColors.screenBackground),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      LissomEyebrow('Step ${_index + 1} of ${_order.length}'),
                ),
              ),
              Expanded(
                child: ListView(
                  key: ValueKey<_Step>(_step),
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                  children: <Widget>[_stepContent(t)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    key: const Key('onboarding.continue'),
                    onPressed: (_canContinue && !_saving) ? _next : null,
                    child: Text(
                        _index == _order.length - 1 ? 'Get started' : 'Continue'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepContent(ThemeData t) => switch (_step) {
        _Step.welcome => const _WelcomeStep(),
        _Step.disclaimer => _DisclaimerStep(
            acked: _disclaimerAcked,
            onChanged: (bool v) => setState(() => _disclaimerAcked = v),
          ),
        _Step.camera => const _CameraInfoStep(),
        _Step.profile => _ProfileStep(
            ageBand: _ageBand,
            onAgeBand: (String v) => setState(() => _ageBand = v),
            onGender: (String v) => _gender = v,
            onPainNotes: (String v) => _painNotes = v,
          ),
        _Step.limits => const _LimitsStep(),
      };
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Welcome to Lissom', style: t.textTheme.headlineSmall),
        const SizedBox(height: 12),
        // "measures, doesn't guess" — UI-BRIEF §0'ın ürün cümlesinin özeti,
        // §1 marka tonuyla AYNI kayıt (kesinlik taklidi yok, ölçtüğünü söyler).
        Text(
          'Lissom uses your phone\'s camera to measure how you move, and '
          'tells you plainly what it measured and what it did not. It '
          'measures — it does not guess.',
          style: t.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _DisclaimerStep extends StatelessWidget {
  const _DisclaimerStep({required this.acked, required this.onChanged});

  final bool acked;
  final ValueChanged<bool> onChanged;

  /// `config/copy/disclaimers.en.json` → `disclaimers.onboarding.text`,
  /// BİREBİR (bkz. `MeasurementLimitsFootnote.limitsCopy` ile aynı sözleşme
  /// — TAŞINDI, UYDURULMADI).
  static const String text =
      'Lissom is a general wellness app. It uses your phone\'s camera to '
      'estimate movement capacity for tracking purposes only. It is not a '
      'medical device, does not diagnose or treat any condition, and is '
      'not a substitute for professional medical or physical therapy '
      'advice. If you have pain, an injury, or a medical condition, talk '
      'to a qualified healthcare provider before starting any new '
      'movement routine.';

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const LissomEyebrow('Before you continue'),
        const SizedBox(height: 10),
        Text(text, style: t.textTheme.bodyMedium),
        const SizedBox(height: 18),
        InkWell(
          key: const Key('onboarding.disclaimer.ack'),
          onTap: () => onChanged(!acked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(value: acked, onChanged: (bool? v) => onChanged(v ?? false)),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('I understand', style: t.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// O3 — Camera permission (UI-BRIEF §2.1 aslına dönüldü, 2026-08-12).
///
/// Önceki hâli "bu build'de yakalanamaz" diyordu (bkz. `surfaces.dart`
/// içindeki dürüst-yokluk widget'ı) — DOĞRUYDU o gün, kamera kabuğu bağlı
/// değildi. `CameraPoseSource`
/// bağlandığı bu commit'te bu ekran da güncellendi (AYNI commit — koordinatör
/// şartı, `test/onboarding_camera_gate_test.dart` bunu zorluyor).
///
/// İzin isteği KULLANICI DOKUNUŞUYLA tetiklenir, ekran açılır açılmaz
/// OTOMATİK değil — hem daha iyi UX hem de widget testinde platform kanalı
/// olmadan bu adımdan (`onboarding.continue`ya dokunarak) geçilebilmesi
/// için (bkz. `onboarding_flow_test.dart`, düğmeye hiç dokunmuyor).
class _CameraInfoStep extends StatefulWidget {
  const _CameraInfoStep();

  @override
  State<_CameraInfoStep> createState() => _CameraInfoStepState();
}

class _CameraInfoStepState extends State<_CameraInfoStep> {
  PermissionStatus? _status;
  bool _requesting = false;

  Future<void> _requestPermission() async {
    setState(() => _requesting = true);
    final PermissionStatus status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _status = status;
      _requesting = false;
    });
  }

  String get _statusText {
    final PermissionStatus? s = _status;
    if (s == null) return '';
    if (s.isGranted) {
      return 'Camera access granted.';
    }
    if (s.isPermanentlyDenied || s.isRestricted) {
      return 'Camera access is off. You can turn it on later in Settings — '
          'the rest of Lissom still works without it.';
    }
    return 'Camera access was not granted. You can try again later — the '
        'rest of Lissom still works without it.';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const LissomEyebrow('About the camera'),
        const SizedBox(height: 10),
        Text(
          'When you take a measurement, Lissom reads your movement through '
          'the camera in real time. The video never leaves this device — '
          'nothing is recorded, saved, or sent anywhere.',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Lissom has no account and no server of its own, so there is '
          'nowhere for your data to go.',
          style: t.textTheme.bodySmall
              ?.copyWith(color: LissomColors.bodySecondary),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            key: const Key('onboarding.camera.requestPermission'),
            onPressed: _requesting ? null : _requestPermission,
            child: Text(_status == null ? 'Allow camera access' : 'Check again'),
          ),
        ),
        if (_status != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(_statusText, style: t.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _ProfileStep extends StatefulWidget {
  const _ProfileStep({
    required this.ageBand,
    required this.onAgeBand,
    required this.onGender,
    required this.onPainNotes,
  });

  final String? ageBand;
  final ValueChanged<String> onAgeBand;
  final ValueChanged<String> onGender;
  final ValueChanged<String> onPainNotes;

  @override
  State<_ProfileStep> createState() => _ProfileStepState();
}

class _ProfileStepState extends State<_ProfileStep> {

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const LissomEyebrow('About you'),
        const SizedBox(height: 4),
        Text(
          'Scoring bands are age-based. Without an age range, Lissom uses '
          'the most conservative band so it does not overstate anything.',
          style: t.textTheme.bodySmall
              ?.copyWith(color: LissomColors.bodySecondary),
        ),
        const SizedBox(height: 16),
        Text('Age range', style: t.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: <Widget>[
            // Gösterilen bantlar [kOfferedAgeBands]'ten TÜRETİLİR — etiket
            // haritasından DEĞİL. Tek adres motorun tanıdığı bantlar;
            // etiket yalnız o bantların kullanıcı yüzü.
            for (final String band in kOfferedAgeBands)
              ChoiceChip(
                key: Key('onboarding.ageBand.$band'),
                label: Text(kAgeBandLabels[band] ?? band),
                selected: widget.ageBand == band,
                onSelected: (_) => widget.onAgeBand(band),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Gender (optional)', style: t.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          key: const Key('onboarding.gender'),
          onChanged: widget.onGender,
          decoration: const InputDecoration(
            hintText: 'Prefer not to say by default',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        Text('Pain or injury history (optional)', style: t.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          key: const Key('onboarding.painNotes'),
          onChanged: widget.onPainNotes,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Anything Lissom should know about',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _LimitsStep extends StatelessWidget {
  const _LimitsStep();

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const LissomEyebrow('What measurement can and cannot tell you'),
        const SizedBox(height: 10),
        Text(MeasurementLimitsFootnote.limitsCopy, style: t.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Text(MeasurementLimitsFootnote.accuracyStatement,
            style: t.textTheme.bodyMedium),
      ],
    );
  }
}
