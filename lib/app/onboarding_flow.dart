/// Onboarding akışı — O1 Welcome → O2 Disclaimer → O3 Camera permission →
/// O4 Profile → O5 Measurement limits (`docs/design/UI-BRIEF.md` §2.1).
///
/// **O3 yayın politikası (2026-10-02):** ortak ölçüm kapısı kapalıysa
/// yalnız bilgi gösterir, kamera izni istemez. Ertelenmiş izin yolu
/// `measurementAvailable: true` ile ayrı sınanır; üretim varsayılanı
/// Home ekranıyla aynı `motionPaidFeaturesAvailable` sabitidir.
///
/// **Tarihsel O3 (2026-08-12):** `CameraPoseSource` bağlandığı GÜN,
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
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;
import 'package:permission_handler/permission_handler.dart';

import 'lissom_theme.dart';
import 'lissom_palette.dart';
import 'locale_text.dart';
import 'onboarding_store.dart';
import 'surfaces.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.store,
    required this.onDone,
    this.onRequestPermission,
    this.onOpenSettings,
    this.onOpenAccount,
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  final OnboardingStore store;

  /// Testable permission request; production uses the existing camera channel.
  final Future<PermissionStatus> Function()? onRequestPermission;

  /// OS ayarlarını açar; testte enjekte edilir (platform kanalı widget
  /// testinde doğrulanamaz). Bkz. O3 — [_CameraInfoStep].
  final Future<bool> Function()? onOpenSettings;

  /// Only supplied after a real shared-account page is wired by the host.
  final VoidCallback? onOpenAccount;
  final bool measurementAvailable;

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
  bool _saveFailed = false;

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
    if (!_canContinue) { return; }
    final int i = _index;
    if (i == _order.length - 1) {
      _finish();
      return;
    }
    setState(() => _step = _order[i + 1]);
  }

  Future<void> _finish() async {
    if (_saving) { return; }
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    // `gender`/`painNotes` YAZILMIYOR — onboarding onları artık TOPLAMIYOR
    // (L-281). Şema alanları duruyor ki daha eski bir build'in yazdığı
    // profil hâlâ ayrıştırılabilsin; bu akış onlara asla değer koymaz.
    final OnboardingProfile profile = OnboardingProfile(
      completed: true,
      ageBand: _ageBand,
    );
    try {
      await widget.store.write(profile);
    } on Object {
      if (mounted) { setState(() => _saveFailed = true); }
      return;
    } finally {
      if (mounted) { setState(() => _saving = false); }
    }
    if (!mounted) { return; }
    // Diske YAZILAN nesnenin AYNISI geçiyor — ikinci bir kopya kurulsaydı
    // iki kaynak tek olgu olurdu (L-272) ve sessizce ayrışabilirdi.
    widget.onDone(profile);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration:  BoxDecoration(
          gradient: LissomPalette.of(context).screenBackground,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: LissomEyebrow(
                    localeTemplate(
                      context,
                      'Step {step} of {total}',
                      '{total} adımın {step}. adımı',
                      <String, Object>{
                        'step': localizedInteger(context, _index + 1),
                        'total': localizedInteger(context, _order.length),
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  key: ValueKey<_Step>(_step),
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
                  children: <Widget>[_stepContent(t)],
                ),
              ),
              if (_saveFailed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      key: const Key('onboarding.saveError'),
                      localeText(
                        context,
                        'Your profile could not be saved. Tap Get started to try again.',
                        'Profil kaydedilemedi. Başla düğmesine dokunarak yeniden dene.',
                      ),
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: t.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              if (_step == _Step.welcome && widget.onOpenAccount != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          localeText(
                            context,
                            'Study the written yoga courses without an account or camera. A Motion account is optional. Live camera measurements and subscription sales are closed in this release.',
                            'Yazılı yoga kurslarını hesap veya kamera olmadan çalışabilirsin. Motion hesabı isteğe bağlıdır. Bu sürümde canlı kamera ölçümleri ve abonelik satışı kapalıdır.',
                          ),
                          style: t.textTheme.bodySmall,
                        ),
                        TextButton(
                          key: const Key('onboarding.accountEntry'),
                          onPressed: widget.onOpenAccount,
                          child: Text(localeText(context, 'Account', 'Hesap')),
                        ),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton(
                    key: const Key('onboarding.continue'),
                    onPressed: (_canContinue && !_saving) ? _next : null,
                    child: Text(
                      _index == _order.length - 1
                          ? localeText(context, 'Get started', 'Başla')
                          : localeText(context, 'Continue', 'Devam et'),
                    ),
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
    _Step.camera => _CameraInfoStep(
      onRequestPermission:
          widget.onRequestPermission ?? Permission.camera.request,
      onOpenSettings: widget.onOpenSettings ?? openAppSettings,
      measurementAvailable: widget.measurementAvailable,
    ),
    _Step.profile => _ProfileStep(
      ageBand: _ageBand,
      onAgeBand: (String v) => setState(() => _ageBand = v),
    ),
    _Step.limits => _LimitsStep(
      measurementAvailable: widget.measurementAvailable,
    ),
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
        Text(
          localeText(context, 'Welcome to Lissom', 'Lissom’a hoş geldin'),
          style: t.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        // "measures, doesn't guess" — UI-BRIEF §0'ın ürün cümlesinin özeti,
        // §1 marka tonuyla AYNI kayıt (kesinlik taklidi yok, ölçtüğünü söyler).
        Text(
          localeText(
            context,
            'Lissom offers written yoga courses with practice tasks, '
                'adaptations and self-checks. Practice records stay on this '
                'device and reflect your own reports. Live camera '
                'measurements and subscription sales are closed in this release.',
            'Lissom, çalışma görevleri, uyarlamalar ve öz denetimler içeren '
                'yazılı yoga kursları sunar. Çalışma kayıtları bu cihazda '
                'kalır ve kendi çalışma kaydını gösterir. Bu sürümde canlı '
                'kamera ölçümleri ve abonelik satışı kapalıdır.',
          ),
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
      'Lissom is a general wellness app offering Hatha yoga practice. '
      'Live camera measurements are closed in this release. It is not a '
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
        LissomEyebrow(
          localeText(context, 'Before you continue', 'Devam etmeden önce'),
        ),
        const SizedBox(height: 10),
        Text(
          localeText(
            context,
            text,
            'Lissom, Hatha yoga çalışması sunan genel sağlıklı yaşam amaçlı '
            'bir uygulamadır. Bu sürümde canlı kamera ölçümleri kapalıdır. '
            'Tıbbi cihaz değildir; herhangi bir hastalığı '
            'teşhis veya tedavi etmez. Tıbbi ya da fizyoterapi tavsiyesinin '
            'yerine geçmez. Ağrın, sakatlığın veya bir sağlık sorunun '
            'varsa yeni bir hareket programına başlamadan önce yetkin '
            'bir sağlık uzmanına danış.',
          ),
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        LissomFocusFrame(child: InkWell(
          key: const Key('onboarding.disclaimer.ack'),
          onTap: () => onChanged(!acked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: acked,
                onChanged: (bool? v) => onChanged(v ?? false),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    localeText(context, 'I understand', 'Anladım'),
                    style: t.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        )),
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
  const _CameraInfoStep({
    required this.onRequestPermission,
    required this.onOpenSettings,
    required this.measurementAvailable,
  });

  final Future<PermissionStatus> Function() onRequestPermission;
  final Future<bool> Function() onOpenSettings;
  final bool measurementAvailable;

  @override
  State<_CameraInfoStep> createState() => _CameraInfoStepState();
}

class _CameraInfoStepState extends State<_CameraInfoStep> {
  PermissionStatus? _status;
  bool _requesting = false;
  bool _openingSettings = false;
  bool _requestFailed = false;
  bool _settingsFailed = false;

  bool get _busy => _requesting || _openingSettings;

  Future<void> _requestPermission() async {
    if (!widget.measurementAvailable || _busy) { return; }
    setState(() {
      _requesting = true;
      _requestFailed = false;
      _settingsFailed = false;
    });
    try {
      final PermissionStatus status = await widget.onRequestPermission();
      if (mounted) { setState(() => _status = status); }
    } on Object {
      if (mounted) {
        setState(() {
          _status = null;
          _requestFailed = true;
        });
      }
    } finally {
      if (mounted) { setState(() => _requesting = false); }
    }
  }

  Future<void> _openSettings() async {
    if (!widget.measurementAvailable || _busy) { return; }
    setState(() {
      _openingSettings = true;
      _settingsFailed = false;
    });
    try {
      final bool opened = await widget.onOpenSettings();
      if (mounted && !opened) { setState(() => _settingsFailed = true); }
    } on Object {
      if (mounted) { setState(() => _settingsFailed = true); }
    } finally {
      if (mounted) { setState(() => _openingSettings = false); }
    }
  }

  /// Sistem bir daha SORMAYACAK — tek yol OS ayarları.
  /// `_statusText`'in kalıcı-ret dalıyla AYNI koşul; ikisi ayrışırsa metin
  /// *"Settings"* der ama düğme çıkmaz (ya da tersi), o yüzden tek ifade.
  bool get _isPermanentlyDenied {
    final PermissionStatus? s = _status;
    return s != null && (s.isPermanentlyDenied || s.isRestricted);
  }

  String _statusText(BuildContext context) {
    final PermissionStatus? s = _status;
    if (s == null) { return ''; }
    if (s.isGranted) {
      return localeText(
        context,
        'Camera access granted.',
        'Kamera izni verildi.',
      );
    }
    if (_isPermanentlyDenied) {
      return localeText(
        context,
        'Camera access is off, and the system will not ask again. '
            'You can turn it on in Settings — the rest of Lissom still '
            'works without it.',
        'Kamera erişimi kapalı ve sistem tekrar sormayacak. Ayarlar’dan '
            'açabilirsin. Lissom’un diğer bölümleri kamera olmadan da çalışır.',
      );
    }
    return localeText(
      context,
      'Camera access was not granted. You can try again later — the '
          'rest of Lissom still works without it.',
      'Kamera izni verilmedi. Daha sonra tekrar deneyebilirsin; '
          'Lissom’un diğer bölümleri kamera olmadan da çalışır.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    if (!widget.measurementAvailable) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(
            localeText(context, 'About the camera', 'Kamera hakkında'),
          ),
          const SizedBox(height: 10),
          Text(
            localeText(
              context,
              'Camera measurements are closed in this release. '
                  'We do not request camera access; the written yoga courses work '
                  'without it.',
              'Bu sürümde kamera ölçümleri kapalıdır. Kamera izni istemiyoruz; '
                  'yazılı yoga kursları kamera olmadan çalışır.',
            ),
            style: t.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LissomEyebrow(
          localeText(context, 'About the camera', 'Kamera hakkında'),
        ),
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
          localeText(
            context,
            'When you take a measurement, Lissom reads your movement through '
                'the camera in real time. The video is never recorded and never '
                'leaves this device.',
            'Ölçüm yaparken Lissom hareketini kameradan anlık olarak okur. '
                'Video kaydedilmez ve bu cihazdan dışarı gönderilmez.',
          ),
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          localeText(
            context,
            'Test results and dates are saved in Lissom\'s local app storage. '
                'Lissom does not upload or sync them to your Motion account.',
            'Test sonuçları ve tarihleri Lissom\'un yerel uygulama alanına '
                'kaydedilir. Lissom bunları Motion hesabına yüklemez veya eşitlemez.',
          ),
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('onboarding.camera.requestPermission'),
            onPressed: _busy ? null : _requestPermission,
            child: Text(
              _requestFailed
                  ? localeText(context, 'Try again', 'Yeniden dene')
                  : _status == null
                  ? localeText(
                      context,
                      'Allow camera access',
                      'Kamera izni ver',
                    )
                  : localeText(context, 'Check again', 'Yeniden denetle'),
            ),
          ),
        ),
        if (_requestFailed) ...<Widget>[
          const SizedBox(height: 10),
          Semantics(
            key: const Key('onboarding.camera.requestError'),
            liveRegion: true,
            child: Text(
              localeText(
                context,
                'Camera access could not be checked. Try again, or continue without the camera.',
                'Kamera erişimi denetlenemedi. Yeniden dene veya kamera olmadan devam et.',
              ),
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.error,
              ),
            ),
          ),
        ],
        if (_status != null) ...<Widget>[
          const SizedBox(height: 10),
          Text(_statusText(context), style: t.textTheme.bodySmall),
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
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              key: const Key('onboarding.camera.openSettings'),
              onPressed: _busy ? null : _openSettings,
              child: Text(localeText(context, 'Open Settings', 'Ayarları aç')),
            ),
          ),
        ],
        if (_settingsFailed) ...<Widget>[
          const SizedBox(height: 10),
          Semantics(
            key: const Key('onboarding.camera.settingsError'),
            liveRegion: true,
            child: Text(
              localeText(
                context,
                'Settings could not be opened. Try again, or open your device settings yourself. You can also continue without the camera.',
                'Ayarlar açılamadı. Yeniden dene veya cihaz ayarlarını kendin aç. Kamera olmadan da devam edebilirsin.',
              ),
              style: t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.error,
              ),
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
        LissomEyebrow(localeText(context, 'About you', 'Senin hakkında')),
        const SizedBox(height: 4),
        Text(
          localeText(
            context,
            'Reference ranges vary by age. Choose your age range to continue '
                'so Lissom can use the appropriate range.',
            'Değerlendirme aralıkları yaşa göre değişir. Devam etmek için '
                'yaş aralığını seç; Lissom buna uygun aralığı kullansın.',
          ),
          style: t.textTheme.bodySmall?.copyWith(
            color: LissomPalette.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          localeText(context, 'Age range', 'Yaş aralığı'),
          style: t.textTheme.titleSmall,
        ),
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
                label: Text(switch (band) {
                  'u40' => localeText(context, 'Under 40', '40 yaş altı'),
                  '40-59' => localeText(context, '40–59', '40–59 yaş'),
                  '60plus' => localeText(
                    context,
                    '60 or over',
                    '60 yaş ve üzeri',
                  ),
                  _ => band,
                }),
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
  const _LimitsStep({required this.measurementAvailable});

  final bool measurementAvailable;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LissomEyebrow(
          localeText(
            context,
            'What measurement can and cannot tell you',
            'Ölçümün gösterebildikleri ve sınırları',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          MeasurementLimitsFootnote.localizedContext(
            context,
            measurementAvailable: measurementAvailable,
          ),
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          MeasurementLimitsFootnote.localizedLimits(context),
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          MeasurementLimitsFootnote.localizedAccuracy(context),
          style: t.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
