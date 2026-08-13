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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'lissom_theme.dart';
import 'onboarding_store.dart';
import 'surfaces.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.store,
    required this.onDone,
    this.onOpenSettings,
    super.key,
  });

  final OnboardingStore store;

  /// OS ayarlarını açar; testte enjekte edilir (platform kanalı widget
  /// testinde doğrulanamaz). Bkz. O3 — [_CameraInfoStep].
  final Future<bool> Function()? onOpenSettings;

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
    // `gender`/`painNotes` YAZILMIYOR — onboarding onları artık TOPLAMIYOR
    // (L-281). Şema alanları duruyor ki daha eski bir build'in yazdığı
    // profil hâlâ ayrıştırılabilsin; bu akış onlara asla değer koymaz.
    final OnboardingProfile profile =
        OnboardingProfile(completed: true, ageBand: _ageBand);
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
        _Step.camera =>
          _CameraInfoStep(onOpenSettings: widget.onOpenSettings ?? openAppSettings),
        _Step.profile => _ProfileStep(
            ageBand: _ageBand,
            onAgeBand: (String v) => setState(() => _ageBand = v),
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
  const _CameraInfoStep({required this.onOpenSettings});

  final Future<bool> Function() onOpenSettings;

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

  /// Sistem bir daha SORMAYACAK — tek yol OS ayarları.
  /// `_statusText`'in kalıcı-ret dalıyla AYNI koşul; ikisi ayrışırsa metin
  /// *"Settings"* der ama düğme çıkmaz (ya da tersi), o yüzden tek ifade.
  bool get _isPermanentlyDenied {
    final PermissionStatus? s = _status;
    return s != null && (s.isPermanentlyDenied || s.isRestricted);
  }

  String get _statusText {
    final PermissionStatus? s = _status;
    if (s == null) return '';
    if (s.isGranted) {
      return 'Camera access granted.';
    }
    if (_isPermanentlyDenied) {
      return 'Camera access is off, and the system will not ask again. '
          'You can turn it on in Settings — the rest of Lissom still '
          'works without it.';
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
        // 🔴 **ÖZNE BELİRSİZLİĞİ = BAYAT YOKLUK CÜMLESİ (H-10 sınıfı, L-319).**
        // Eski hâli: *"The video never leaves this device — nothing is
        // recorded, saved, or sent anywhere."* Cümlenin öznesi VİDEOYDU ama
        // *"nothing is … saved"* **her şey** diye okunur — ve Lissom artık
        // ölçüm kaydını (`sessions.jsonl`) diske YAZIYOR (A1, `L-309`).
        // ⇒ Bu ekran, Progress'in *"the test and the date … appear in this
        // list"* cümlesiyle **çelişiyordu**; kullanıcı ilk açılışta
        // *"hiçbir şey saklanmıyor"* öğrenip sonra listesini buluyordu.
        // > ***BİR YOKLUK CÜMLESİNİN ÖZNESİ BELİRSİZSE, YOKLUK BÜYÜR:***
        // > *okuyucu onu en geniş haliyle anlar, ve en geniş hâli yalandır.*
        // ⇒ Özne artık AÇIK, ve saklananın ne olduğu ADIYLA söyleniyor.
        Text(
          'When you take a measurement, Lissom reads your movement through '
          'the camera in real time. The video is never recorded and never '
          'leaves this device.',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'What is written down is which test you measured and when. That '
          'file stays on this phone and is not sent anywhere.',
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
        // ⛔ ÇIKMAZ SOKAK (L-283): kalıcı rette metin *"You can turn it on
        // later in Settings"* diyor, ama oraya GİDEN yol yoktu. Kalan tek
        // kontrol ("Check again") kullanıcı ayarları AÇIP izni değiştirene
        // kadar hiçbir gözle görülür şey yapmaz — ve uygulama ona ayarları
        // açmanın bir yolunu VERMİYORDU. Yani düğme, kullanıcının fiilen
        // izleyebildiği yol boyunca ATIL kalıyordu.
        //
        // "Check again" KALDI: kullanıcı ayarlardan dönünce durumu
        // yeniden okumanın tek yolu o (ve o an GERÇEKTEN çalışır).
        if (_isPermanentlyDenied) ...<Widget>[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const Key('onboarding.camera.openSettings'),
              onPressed: () => unawaited(widget.onOpenSettings()),
              child: const Text('Open Settings'),
            ),
          ),
        ],
      ],
    );
  }
}

/// O4 — profil. **Yalnız yaş bandı toplanır** (L-281).
///
/// `gender` ve `pain/injury` alanları 2026-08-12'de KALDIRILDI. Koordinatör
/// hükmü: ***okuyucusu olmayan alan, okunuyormuş gibi konuşamaz.***
/// `painNotes`un ipucu (*"Anything Lissom should know about"*) bir VAATTİ:
/// kullanıcı sakatlığını yazıp ölçümde dikkate alınacağını umardı — oysa
/// hiçbir kural/guard/metrik onu okumuyordu (ölçüldü).
///
/// **Neden düşürüldü, "ipucunu düzelt" yerine:** ikisinin de tek seferlik
/// maliyeti aynı çıktı (ölçüldü — depo testleri MODEL düzeyinde, ikisinde de
/// ayakta kalıyor). Farkı SÜREKLİ maliyet yaptı: *"buraya yaz, okumuyoruz"*
/// diyen bir alan her metin turunda ve her mağaza gizlilik-beyanında yeniden
/// savunulmak zorundadır — ve **serbest metinli sakatlık geçmişi, okunmasa
/// bile beyan edilmesi gereken bir sağlık verisi toplama noktasıdır.**
/// Girdiyi kaldırmak o noktayı da kaldırır.
///
/// 📌 Geri gelme koşulu ZAMAN DEĞİL: bu alanlar *"sonra"* değil, **onları
/// OKUYAN üretim kodu var olduğunda** geri gelir.
class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.ageBand, required this.onAgeBand});

  final String? ageBand;
  final ValueChanged<String> onAgeBand;

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
                selected: ageBand == band,
                onSelected: (_) => onAgeBand(band),
              ),
          ],
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
