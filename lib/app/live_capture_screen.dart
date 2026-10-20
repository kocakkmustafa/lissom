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
import 'package:permission_handler/permission_handler.dart'
    show openAppSettings;

import 'assessment_history.dart';
import 'attempt_values.dart';
import 'camera_pose_source.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';
import 'local_owner.dart';
import 'local_owner_context.dart';
import 'pose_model.dart';
import 'surfaces.dart';

class LiveCaptureScreen extends StatefulWidget {
  const LiveCaptureScreen({
    required this.test,
    required this.batteryVersion,
    this.cameraSetup,
    this.side = 'right',
    this.ageBand,
    this.sourceOverride,
    this.onOpenSettings,
    this.storeLoader,
    this.attemptValueStoreLoader,
    this.clock,
    super.key,
  });

  /// Geçmiş deposu. Testte enjekte edilir — `openSessionStore` altında
  /// `path_provider` var ve widget testinde kilitleniyor (aile gotcha'sı,
  /// `LissomShell.loader` ile AYNI sözleşme).
  final Future<SessionStore> Function()? storeLoader;

  /// Deneme-değeri deposu — `storeLoader`la AYNI enjeksiyon sözleşmesi
  /// (D13, `attempt_values.dart`). Çekirdek deponun YANINDA, ondan BAĞIMSIZ
  /// bir dosya; ikisi ayrı sebeplerle ayrı ayrı başarısız olabilir.
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;

  /// Kayıt zamanı ÇAĞIRANDAN gelir — `recordFor`un kendi sözleşmesi
  /// (`DateTime.now()` içeride üretilseydi zaman-sıralı senaryolar
  /// sınanamazdı).
  final DateTime Function()? clock;

  /// OS ayarlarını açar. Testte enjekte edilir (`sourceOverride`la AYNI
  /// sözleşme) — `openAppSettings` bir platform kanalı çağırır ve widget
  /// testinde doğrulanamaz; enjeksiyon olmadan "düğme GERÇEKTEN bir şey
  /// yapıyor mu" sorusu ölçülemezdi, yalnız düğmenin VARLIĞI ölçülebilirdi.
  final Future<bool> Function()? onOpenSettings;

  final TestSpec test;
  final String batteryVersion;

  /// Kameranın nereye konacağı — config'ten (`L-330`). ⛔ `null` ise kart
  /// **hiç çizilmez**: uydurulmuş bir kurulum tarifi, hiç tarif olmamasından
  /// kötüdür.
  final CameraSetup? cameraSetup;
  final String side;

  /// Onboarding'de BEYAN EDİLEN yaş bandı — zincirin son halkası
  /// (onboarding → geçit → kabuk → home → BURASI → motor).
  ///
  /// `null` → beyan yok; `ScoringSpec.floorsFor(null)` en muhafazakâr bandı
  /// seçer. Doğrulama [_effectiveAgeBand]'de, çünkü bir bandın GEÇERLİLİĞİ
  /// teste özgüdür (nitel testlerin bandı hiç yoktur).
  final String? ageBand;

  /// Testte enjekte edilebilir (`FakePoseSource`) — `LissomShell`in
  /// `loader` deseniyle AYNI sözleşme. `null` iken gerçek `CameraPoseSource`.
  final PoseSource? sourceOverride;

  @override
  State<LiveCaptureScreen> createState() => _LiveCaptureScreenState();
}

/// Motora GERÇEKTEN geçen bant — beyan edilen bandın BU test için geçerli
/// olanı, yoksa `null`.
///
/// **Neden süzgeç var:** `ScoringSpec.floorsFor` tanımadığı bir bantta
/// `BatteryError` **FIRLATIR**. Beyan edilen bant bu testin config'inde yoksa
/// (config sürümü değişti, bant yeniden adlandırıldı) motora geçirmek ölçüm
/// ekranını bir **çıkmaz sokağa** çevirirdi — M-F-267 ÇIKMAZ-SOKAK YASAĞI.
/// Düşürülür ve en muhafazakâr banda dönülür: kullanıcı hak etmediği bir
/// "yetersiz" hükmüne SOKULMAZ (`floorsFor`un kendi gerekçesi).
///
/// ⚠️ Bu bir **emniyet kemeri**, koruma DEĞİL. Sapmayı asıl engelleyen
/// `test/age_band_wiring_test.dart` kapısıdır (her bant × her test için
/// `floorsFor` FIRLATMAMALI). Kemer sessiz de değildir: düşen beyan
/// provenance'a `ageBandDeclaredButUnknown` olarak İSİMLE yazılır.
@visibleForTesting
String? effectiveAgeBand(TestSpec test, String? declared) {
  if (declared == null) return null;
  final Map<String, Map<String, double>> bands = test.scoring.bandFloorsByAge;
  // Nitel test — bandı hiç yok, `floorsFor` zaten null döner.
  if (bands.isEmpty) return null;
  return bands.containsKey(declared) ? declared : null;
}

/// Ekranın motoru kurduğu TEK yol — ekran bunun dışında `AssessmentEngine`
/// kurmaz. Testin bandın motora GERÇEKTEN ulaştığını ölçebildiği yer burası:
/// `_LiveCaptureScreenState` özel bir sınıf, dışarıdan okunamaz.
@visibleForTesting
AssessmentEngine buildLiveEngine({
  required TestSpec test,
  required String side,
  required String? declaredAgeBand,
  required String batteryVersion,
  required double? Function(PoseFrame frame, String metricName) metricReader,
}) {
  final String? effective = effectiveAgeBand(test, declaredAgeBand);

  // İKİ AYRI OLGU, tek koşulda birleştirilemez (bu dosyanın kapısı ilk
  // yazılışımda tam bunu yakaladı):
  //   ① beyan VAR, test BANTLI, ama bandı tanımıyor  → SAPMA, kaydedilir
  //   ② beyan VAR, test BANTSIZ (nitel)              → NORMAL, damgalanmaz
  // İkisini "effective == null" diye birleştirmek, geçerli bir beyanı
  // "bilinmeyen" diye damgalayıp kaydı YANLIŞ hâle getiriyordu.
  final Map<String, Map<String, double>> bands = test.scoring.bandFloorsByAge;
  final bool unknownForThisTest =
      declaredAgeBand != null &&
      bands.isNotEmpty &&
      !bands.containsKey(declaredAgeBand);

  return AssessmentEngine(
    test: test,
    side: side,
    ageBand: effective,
    metricReader: metricReader,
    provenance: <String, String>{
      'modelId': kPoseModelId,
      'batteryVersion': batteryVersion,
      // Ölçümü HANGİ bandın skorladığı kaydın parçasıdır (M-F-07 sınıfı).
      // Boş dize = hiçbiri: ya beyan yok, ya test bantsız.
      'ageBand': effective ?? '',
      // Sessiz düşürme YOK — yalnız ① hâlinde.
      if (unknownForThisTest) 'ageBandDeclaredButUnknown': declaredAgeBand,
    },
  );
}

class _LiveCaptureScreenState extends State<LiveCaptureScreen>
    with WidgetsBindingObserver {
  late final PoseSource _source = widget.sourceOverride ?? CameraPoseSource();
  late final LiveEvaluator _evaluator = LiveEvaluator(
    test: widget.test,
    side: widget.side,
    source: _source,
  );
  late AssessmentEngine _engine = _newEngine();

  StreamSubscription<LiveSessionState>? _stateSub;
  StreamSubscription<PoseSourceEvent>? _rawSub;
  FrameSize? _latestSize;

  LiveSessionState _state = const LiveIdle();
  AssessmentResult? _result;
  bool _sourceRetired = false;
  LissomLocalOwner? _owner;
  LissomResourceLease? _resource;
  Future<void>? _sourceClose;

  AssessmentEngine _newEngine() => buildLiveEngine(
    test: widget.test,
    side: widget.side,
    declaredAgeBand: widget.ageBand,
    batteryVersion: widget.batteryVersion,
    metricReader: _readMetric,
  );

  double? _readMetric(PoseFrame frame, String metricName) {
    final FrameSize? size = _latestSize;
    if (size == null) return null;
    return CoreMetricReader(frameSize: size).read(frame, metricName);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _owner = LissomOwnerContext.maybeOf(context);
    if (_owner?.isActive == false) {
      _sourceRetired = true;
      return;
    }
    _resource = _owner?.registerResource(_closeSource);
    _stateSub = _evaluator.states().listen((LiveSessionState s) {
      if (mounted && !_sourceRetired) setState(() => _state = s);
    });
    _rawSub = _source.events().listen(_onRawEvent);
    final PoseSource s = _source;
    if (s is StartablePoseSource) {
      s.start();
    }
  }

  void _onRawEvent(PoseSourceEvent e) {
    if (_sourceRetired || _result != null) return;
    if (e is SourceFrameEvent) {
      _latestSize = e.size;
      _engine.process(e.frame);
    }
  }

  /// Sonucun geçmişe YAZILDIĞI mı yoksa YAZILAMADIĞI mı — üçüncü hâl
  /// (`null`) *"henüz denenmedi"*. Sonuç ekranındaki takip CÜMLESİ buna
  /// bakar: yazılmadıysa *"we'll track it from here"* **yalan olur.**
  bool? _saved;
  String? _saveError;

  Future<void> _finish() async {
    if (_sourceRetired || _result != null || !_state.canMeasure) return;
    final AssessmentResult r = _engine.finish();
    setState(() => _result = r);
    await _persist(r);
  }

  /// ⑬ (L-285) — ÖLÇÜMÜ KAYDET.
  ///
  /// Bu yol bugüne kadar **hiç yoktu**: `recordFor` ve `appendPreserved`
  /// yazılmış, belgelenmiş ve **sıfır çağıranı** olan bir çeviri katmanıydı.
  /// Kullanıcı ölçüm yapıyor, sayıyı görüyor, ekranı kapatıyordu — **sayı
  /// yok.** Progress ve geçmiş kalıcı boştu.
  ///
  /// `appendPreserved` DEĞİL `recordFor` kullanılıyor: o fonksiyon
  /// `AssessmentSession`ın çok-bloklu orkestrası içindir (yarım blok
  /// girmesin diye), bu ekran ise TEK bir `AssessmentEngine` koşturuyor.
  ///
  /// **Ölçülemeyen deneme de YAZILIR** — `recordFor`un kendi hükmü:
  /// *"kaydetmemek, yarın yüzeyin '1 deneme' demesine yol açardı;
  /// sessizlik yalan söyler."*
  Future<void> _persist(AssessmentResult r) async {
    final DateTime completedAt = (widget.clock ?? DateTime.now)();
    try {
      _owner?.checkActive();
      final SessionStore store =
          await (widget.storeLoader ?? openSessionStore)();
      _owner?.checkActive();
      await store.append(
        recordFor(test: widget.test, result: r, completedAt: completedAt),
      );
      // D13/F2 — ölçülen DEĞER çekirdek kaydına hiç girmiyor (KASITLI, aile
      // şeması: `session_store.dart` "attempt-level provenance... is
      // attempt-level data, this is a session-level record" diyor).
      // Lissom-sahipli yan defter tam bunu taşır (`attempt_values.dart`,
      // L-316'nın çözümü). Yalnız GERÇEKTEN ölçülmüş bir denemede yazılır —
      // `notMeasured`ın zaten değeri yok.
      if (r.value != null) {
        final AttemptValueStore valueStore =
            await (widget.attemptValueStoreLoader ?? openAttemptValueStore)();
        _owner?.checkActive();
        await valueStore.append(
          AttemptValue(
            lessonId: historyKeyFor(widget.test, r.side),
            completedAt: completedAt,
            value: r.value!,
            unit: r.unit!,
            tier: r.tier.name,
            bandLabel: r.bandLabel,
            lowestBandFloor: r.lowestBandFloor,
            provenance: r.provenance,
          ),
        );
      }
      if (mounted && (_owner?.isActive ?? true)) {
        setState(() => _saved = true);
      }
    } on Object catch (e) {
      // ÇIKMAZ SOKAK YASAĞI (M-F-267): yazma patlarsa ekran ÇÖKMEZ — ama
      // SUSMAZ da. Sessizce yutmak, kullanıcıya tutulmayan bir takip sözü
      // vermenin ta kendisi olurdu.
      //
      // İKİ YAZMA TEK SÖZ TAŞIR (D13): `_saved` yalnız İKİSİ DE başarılıysa
      // true olur. Oturum yazılıp değer düşerse "kaydedildi" demek, sayının
      // kaybolduğunu gizlemek olurdu — L-316'nın kendisi, bir katman derinde.
      if (mounted && (_owner?.isActive ?? true)) {
        setState(() {
          _saved = false;
          _saveError = '$e';
        });
      }
    }
  }

  void _tryAgain() {
    if (_sourceRetired) {
      Navigator.of(context).maybePop();
      return;
    }
    if (_saved == null) return;
    setState(() {
      _result = null;
      // Kayıt hâli DENEME BAŞINADIR — sıfırlanmazsa yeni denemenin ekranı
      // ÖNCEKİ denemenin "kaydedildi"sini gösterir (kayıt bir OLAY, durum
      // değil; depo ek-yalnız).
      _saved = null;
      _saveError = null;
      _engine = _newEngine();
    });
    final PoseSource s = _source;
    if (s is StartablePoseSource) {
      s.start();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Inactive also occurs during an OS permission prompt; it is not proof
    // that the app entered the background. A retired source is never resumed.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_sourceRetired) return;
      setState(_retireSource);
    }
  }

  void _retireSource() {
    final Future<void> close = _resource?.close() ?? _closeSource();
    unawaited(close.then<void>((_) {}, onError: (Object _, StackTrace __) {}));
  }

  Future<void> _closeSource() {
    if (!_sourceRetired) {
      _sourceRetired = true;
      _stateSub?.cancel();
      _rawSub?.cancel();
    }
    return _sourceClose ??= _source.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retireSource();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(configText(context, widget.test.name))),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: _result != null
                ? _ResultView(
                    result: _result!,
                    onTryAgain: _tryAgain,
                    saved: _saved,
                    saveError: _saveError,
                    sourceRetired: _sourceRetired,
                  )
                : _sourceRetired
                ? const _InterruptedView()
                : _LiveView(
                    test: widget.test,
                    state: _state,
                    onFinish: _finish,
                    onOpenSettings: widget.onOpenSettings ?? openAppSettings,
                    cameraSetup: widget.cameraSetup,
                  ),
          ),
        ),
      ),
    );
  }
}

class _InterruptedView extends StatelessWidget {
  const _InterruptedView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          liveRegion: true,
          child: Text(
            localeText(context, 'Measurement stopped', 'Ölçüm durduruldu'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          localeText(
            context,
            'Lissom went into the background, so this attempt was not saved. '
                'Return to the test and start a new attempt when you are ready.',
            'Lissom arka plana geçtiği için bu deneme kaydedilmedi. '
                'Hazır olduğunda test sayfasına dönüp yeni bir deneme başlat.',
          ),
        ),
        const Spacer(),
        OutlinedButton(
          key: const Key('liveCapture.returnToTest'),
          onPressed: () => Navigator.of(context).maybePop(),
          child: Text(localeText(context, 'Back to test', 'Teste dön')),
        ),
      ],
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({
    required this.test,
    required this.state,
    required this.onFinish,
    required this.onOpenSettings,
    this.cameraSetup,
  });

  /// Kurulum tarifi — `null` ise kart çizilmez (L-330).
  final CameraSetup? cameraSetup;
  final TestSpec test;
  final LiveSessionState state;
  final VoidCallback onFinish;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final LiveSessionState s = state;
    // ⚠️ İÇERİK KAYDIRILABİLİR, düğme SABİT (L-293).
    //
    // Önizleme beyanı eklenince bu ekran **375pt'te 118 piksel TAŞTI** —
    // dar-yüzey kapısı (`pinNarrowSurface`) yakaladı, 800pt varsayılanında
    // hiçbir işaret yoktu (Ostinato'nun ölçtüğü sınıf).
    //
    // Metni KISALTMADIM: bir dürüstlük beyanının boyunu YERLEŞİMİN
    // belirlemesi, tam da kaçındığımız şey olurdu. Bunun yerine dürüst
    // hâller büyüyebilsin diye içerik kaydırılabilir yapıldı; *"I'm done"*
    // düğmesi **altta sabit** kalıyor (erişimi kaydırmaya bağlamak, ölçümü
    // bitirmeyi zorlaştırırdı).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Olgu [DevicePassClaim]'den TÜRETİLİR (L-318). Bu ekranın ÇERÇEVESİ
                // ötekilerden farklı (burada dört kalem tek tek sayılıyor —
                // koordinatör şartı, 2026-08-12) ama OLGU aynı ve tek kaynaktan gelir.
                // ⇒ Farklı sunum meşru, farklı OLGU değil.
                // 🔴 **KURULUM TARİFİ config'te VARDI, hiçbir yüzeye ULAŞMIYORDU
                // (L-330, H-24 ②).** `globalCameraSetup` mesafe/yükseklik aralığını,
                // kadraj kuralını ve yaw toleransını taşıyor — ve **ayrıştırıcısı bile
                // yoktu.** Yani kullanıcı telefonu nereye koyacağını bilmiyordu, ama
                // ölçüm sonradan *"kadraj yüzünden okunamadı"* diyebiliyordu.
                // > ***BİR ÜRÜN, BAŞARISIZLIĞIN SEBEBİNİ SONRADAN SÖYLEYEBİLİYORSA,
                // > ONU ÖNCEDEN DE SÖYLEYEBİLİR.***
                // ⛔ `null` ise kart HİÇ çizilmez — uydurulmuş bir kurulum tarifi,
                // hiç tarif olmamasından kötüdür (ve boş kart A3 ihlali olurdu).
                if (cameraSetup != null) ...<Widget>[
                  _CameraSetupCard(setup: cameraSetup!, test: test),
                  const SizedBox(height: 12),
                ],
                NamedGapCard(
                  title: localeText(
                    context,
                    'Not verified on a real device',
                    'Gerçek cihazda doğrulanmadı',
                  ),
                  reason: localeText(
                    context,
                    'This connects the camera, the measurement engine, and '
                        'the live display for the first time. '
                        '${DevicePassClaim.notTried}.',
                    'Kamera, ölçüm motoru ve canlı ekran bu sürümde bağlandı; gerçek cihaz denemesi yapılmadı.',
                  ),
                  // Koordinatör şartı (2026-08-12): "tek tek say" — dört kalem
                  // BİRLEŞTİRİLMEDEN, isimle. Kamera simülatörde donanımı olmadığı
                  // için hiçbiri bu makinede sınanamadı.
                  detail: localeText(
                    context,
                    '${DevicePassClaim.stillNeedsLead}: the permission dialog · '
                        'the camera frame stream · landmark quality in real light · the '
                        'calibration threshold (yaw ≤10°).',
                    'Cihazda doğrulanması gerekenler: izin penceresi · kamera kare akışı · gerçek ışıkta eklem noktalarının kalitesi · kalibrasyon eşiği (yaw ≤10°).',
                  ),
                ),
                const SizedBox(height: 12),
                // PLACEHOLDER(asset): kamera akışının canlı görüntüsü (Texture tabanlı önizleme) — unblocked by: motion_camera'nın önizleme texture'ı sunması (registrar.textures); pinli f13bdc9'da YOK, çekirdek turu kalem #5 — user-surface: liveCapture.noPreview
                //
                // **SINIFIN ADI: ERTELENMİŞ** (M-F-287 üçlüsü: imkânsız /
                // ertelenmiş / ölçülmemiş). *İmkânsız* olsaydı "bir kamera bunu
                // göremez" derdik; *ölçülmemiş* olsaydı "bilmiyoruz" derdik.
                // Ertelenmiş = YAPILABİLİR, biz yapmadık → cümle sorumluluğu
                // ÜSTLENİR ve TARİH VERMEZ ("yet" yasak, M-F-186).
                //
                // JabLab ve Gravita aynı çekirdek kısıtını aynı sınıfa koydu (aynı
                // pin, aynı `registrar.textures` yolu) — farklı sınıflandırmak,
                // TEK bir kısıtı üç ayrı şeymiş gibi okuturdu.
                //
                // 🔴 L-292 ölçümü: bu yokluk 2026-08-12'ye kadar BENDE SESSİZDİ.
                // JabLab'ınki beyanlıydı, benimki değildi — kullanıcı ekranı
                // açıyor, kamera görüntüsü görmüyor, ve hiçbir şey neden olduğunu
                // söylemiyordu. Aynı yokluk, iki hatta İKİ AYRI SINIF.
                NamedGapCard(
                  key: Key('liveCapture.noPreview'),
                  title: localeText(
                    context,
                    'No camera image on this screen',
                    'Bu ekranda kamera görüntüsü yok',
                  ),
                  reason: localeText(
                    context,
                    'Lissom reads your movement from the camera, but it does '
                        'not show you the picture here. That view is left out on '
                        'purpose — we have not built it.',
                    'Lissom hareketini kameradan okur ancak görüntüyü bu ekranda göstermez. Bu sürümde görüntü önizlemesi bulunmuyor.',
                  ),
                  detail: localeText(
                    context,
                    'Nothing is hidden by this: the measurement below runs '
                        'on the live camera either way, and the video never leaves '
                        'this device.',
                    'Ölçüm canlı kamerayla çalışır; video cihazdan ayrılmaz.',
                  ),
                ),
                const SizedBox(height: 18),
                Text(_stateText(context, s), style: t.textTheme.titleMedium),
                if (s case PermissionDenied(
                  :final bool retryMakesSense,
                )) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      retryMakesSense
                          ? localeText(
                              context,
                              'You can try again.',
                              'Yeniden deneyebilirsin.',
                            )
                          : localeText(
                              context,
                              'Open Settings to turn camera access on for Lissom.',
                              'Lissom için kamera erişimini Ayarlar’dan aç.',
                            ),
                      style: t.textTheme.bodySmall?.copyWith(
                        color: LissomColors.bodySecondary,
                      ),
                    ),
                  ),
                  // ⛔ ÇIKMAZ SOKAK (L-283): kalıcı rette metin *"Open Settings"*
                  // DİYORDU ama hiçbir kontrol yoktu ve `canMeasure` false olduğu
                  // için ekranda BAŞKA düğme de kalmıyordu — kullanıcıya bir
                  // TALİMAT verilip onu uygulayacak YOL verilmiyordu.
                  // ⚠️ Düğmenin KENDİSİ burada DEĞİL, altta SABİT alanda (L-293) —
                  // gerekçesi aşağıda.
                ],
              ],
            ),
          ),
        ),
        // ⛔ HÂLİN BİRİNCİL EYLEMİ SABİT ALANDA — kaydırmanın ARKASINDA DEĞİL.
        //
        // 🪤 İlk denememde *"Open Settings"*i kaydırılabilir içeriğin içinde
        // bıraktım ve **375pt'te y=986'ya**, yani katlamanın ALTINA düştü:
        // kalıcı retten çıkışın TEK yolu, kullanıcının kaydırmayı akıl
        // etmesine bağlı hâle geldi. Bu, L-283'te kapattığım kusurun
        // (*yol var ama kullanıcı oraya varamıyor*) zayıflatılmış hâliydi
        // ve testin `tap()` uyarısı yakaladı — *"widget is actually
        // off-screen"*.
        //
        // → Kural: bu ekranda hâlin **birincil eylemi** (ölçümü bitir ·
        // ayarlara git) daima ALTTA ve DAİMA görünür; açıklayıcı metin
        // kaydırılabilir, EYLEM değil. İkisi aynı anda doğmaz
        // (`canMeasure` kalıcı rette false).
        if (s.canMeasure)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton(
                key: const Key('liveCapture.finish'),
                onPressed: onFinish,
                child: Text(localeText(context, "I'm done", 'Bitirdim')),
              ),
            ),
          )
        else if (s case PermissionDenied(retryMakesSense: false))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                key: const Key('liveCapture.openSettings'),
                onPressed: () => unawaited(onOpenSettings()),
                child: Text(
                  localeText(context, 'Open Settings', 'Ayarları aç'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _stateText(
    BuildContext context,
    LiveSessionState state,
  ) => switch (state) {
    LiveIdle() => localeText(
      context,
      'Getting the camera ready.',
      'Kamera hazırlanıyor.',
    ),
    PermissionDenied() => localeText(
      context,
      state.userText,
      'Lissom ölçüm yapmak için kamera erişimine ihtiyaç duyar.',
    ),
    NoPersonDetected() => localeText(
      context,
      'No one is in frame. Step into the camera view.',
      'Kadrajda kimse yok. Kamera görüşüne geç.',
    ),
    JointsOutOfFrame(:final String missingGroup) => switch (missingGroup) {
      'lower-body' => localeText(
        context,
        'The lower-body joints this measurement needs are out of frame.',
        'Alt beden eklemleri kadraj dışında.',
      ),
      'upper-body' => localeText(
        context,
        'The upper-body joints this measurement needs are out of frame.',
        'Üst beden eklemleri kadraj dışında.',
      ),
      _ => localeText(
        context,
        'The joints this measurement needs are out of frame.',
        'Gerekli eklemler kadraj dışında.',
      ),
    },
    Measuring(:final LiveReading reading) =>
      reading.hasMeasurement
          ? localeTemplate(
              context,
              'Measuring: {reading}',
              'Ölçülüyor: {reading}',
              <String, Object>{
                'reading':
                    '${localizedDecimal(context, reading.degrees!, fractionDigits: 0)}°',
              },
            )
          : configText(context, reading.narrative!),
    SetupFailed() => localeText(
      context,
      state.userText,
      'Kamera başlatılamadı. Yeniden dene.',
    ),
  };
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.onTryAgain,
    required this.saved,
    required this.saveError,
    required this.sourceRetired,
  });

  final AssessmentResult result;
  final VoidCallback onTryAgain;

  /// `null` = yazma henüz bitmedi · `true` = geçmişe girdi · `false` = giremedi.
  final bool? saved;
  final String? saveError;
  final bool sourceRetired;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final AssessmentResult r = result;
    final String headline = r.isMeasured
        ? '${localizedDecimal(context, r.value!, fractionDigits: 0)}${r.unit ?? ''}'
        : localeText(context, 'Not measured', 'Ölçüm alınamadı');
    // ⚠️ TAKİP SÖZÜ, YAZMA BAŞARILIYSA VERİLİR (L-285).
    //
    // Bu cümle ("we'll track it from here") 08-07'den beri ekrandaydı ve
    // **hiçbir yazma yolu yoktu** — yani bugüne kadar TUTULAMAYAN bir
    // vaatti. Yazma bağlandı; ama yazma BAŞARISIZ olabilir, ve o hâlde
    // aynı cümle yine yalan olurdu. Söz artık OLGUYA bağlı.
    final String detail = switch ((r.isMeasured, saved)) {
      (false, _) => localeTemplate(
        context,
        'Reason: {reason}.',
        'Neden: {reason}.',
        <String, Object>{
          'reason': localeText(
            context,
            _resultReason(r.code.name),
            _resultReasonTr(r.code.name),
          ),
        },
      ),
      (true, true) => localeText(
        context,
        'Measurement saved. You can see earlier values on the test page.',
        'Ölçüm kaydedildi. Önceki değerleri test sayfasında görebilirsin.',
      ),
      (true, false) => localeText(
        context,
        'Measured, but this could not be saved to your history, '
            'so it will not appear in Progress.',
        'Ölçüm yapıldı ancak geçmişe kaydedilemedi; İlerleme ekranında görünmez.',
      ),
      (true, null) => localeText(
        context,
        'Saving this measurement…',
        'Ölçüm kaydediliyor…',
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(headline, style: t.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          detail,
          key: const Key('liveCapture.resultDetail'),
          style: t.textTheme.bodyMedium,
        ),
        if (saved == false && saveError != null) ...<Widget>[
          const SizedBox(height: 6),
          // Ham OS hatası Türkçeye çevrilemez ve yerel yol içerebilir.
          // Kaydın düşmesi ana satırda açık; burada yeniden deneme yolu var.
          Text(
            localeText(
              context,
              'Saving failed. Try again.',
              'Kaydetme sırasında hata oluştu. Yeniden dene.',
            ),
            style: t.textTheme.bodySmall?.copyWith(
              color: LissomColors.bodySecondary,
            ),
          ),
        ],
        const Spacer(),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('liveCapture.tryAgain'),
            onPressed: saved == null && !sourceRetired ? null : onTryAgain,
            child: Text(
              sourceRetired
                  ? localeText(context, 'Back to test', 'Teste dön')
                  : localeText(context, 'Try again', 'Yeniden dene'),
            ),
          ),
        ),
      ],
    );
  }

  static String _resultReason(String code) => switch (code) {
    'noAttemptDetected' => 'no movement was detected',
    'setupTimedOut' => 'the setup did not settle in time',
    'measurementTimedOut' => 'the reading did not settle in time',
    'aborted' => 'the attempt was stopped by a form check',
    'trackingLost' => 'the camera lost track of you',
    'lowConfidence' => 'the reading was not confident enough to keep',
    _ => 'no measurement could be taken',
  };

  static String _resultReasonTr(String code) => switch (code) {
    'noAttemptDetected' => 'hareket algılanmadı',
    'setupTimedOut' => 'kurulum zamanında tamamlanmadı',
    'measurementTimedOut' => 'ölçüm zamanında tamamlanmadı',
    'trackingLost' => 'kamera takibi kaybetti',
    'lowConfidence' => 'ölçüm güvenilir bulunmadı',
    'aborted' => 'deneme durduruldu',
    _ => 'ölçüm alınamadı',
  };
}

/// **Ölçümden ÖNCE: telefonu nereye koyacaksın (L-330).**
///
/// Her satır config'ten TÜRETİLİR; eksik alan **satırı düşürür**, uydurma
/// değer üretmez. Kart yalnız en az bir satır varsa çizilir (çağıran
/// `cameraSetup != null` kontrolünü yapıyor, ve `CameraSetup.parse` boş bloğu
/// zaten `null`a düşürüyor — *iki katman, tek karar*).
class _CameraSetupCard extends StatelessWidget {
  const _CameraSetupCard({required this.setup, required this.test});
  static const Key key_ = Key('liveCapture.cameraSetup');
  final CameraSetup setup;
  final TestSpec test;

  // The floor block in assessment-blocks.v1.json needs a lower camera than
  // the battery's global standing-height range.
  static const Set<String> _floorTests = <String>{
    'active_straight_leg_raise',
    'plank_hold',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<String> lines = <String>[
      if (test.instruction.trim().isNotEmpty) test.instruction,
      if (setup.distanceCm != null)
        localeTemplate(
          context,
          'Stand about {min}–{max} cm from the camera.',
          'Kameradan yaklaşık {min}–{max} cm uzakta dur.',
          <String, Object>{
            'min': localizedInteger(context, setup.distanceCm![0]),
            'max': localizedInteger(context, setup.distanceCm![1]),
          },
        ),
      if (_floorTests.contains(test.id))
        localeText(
          context,
          'Lower the phone to floor height for this test.',
          'Bu test için telefonu yere yakın bir yüksekliğe indir.',
        )
      else if (setup.heightCm != null)
        localeTemplate(
          context,
          'Put the phone {min}–{max} cm off the floor.',
          'Telefonu yerden {min}–{max} cm yüksekliğe koy.',
          <String, Object>{
            'min': localizedInteger(context, setup.heightCm![0]),
            'max': localizedInteger(context, setup.heightCm![1]),
          },
        ),
      if (setup.framingRule != null) setup.framingRule!,
      if (setup.yawToleranceDeg != null)
        localeTemplate(
          context,
          'Keep the angle described for this test; more than {degrees}° of turn and the reading is not used.',
          'Bu testte tarif edilen kamera açısını koru; {degrees}° üzerindeki dönüşlerde ölçüm kullanılmaz.',
          <String, Object>{
            'degrees': localizedConfigNumber(context, setup.yawToleranceDeg!),
          },
        ),
    ];
    return LissomCard(
      key: key_,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(
            localeText(context, 'Before you start', 'Başlamadan önce'),
          ),
          const SizedBox(height: 8),
          for (final String l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '· ${configText(context, l)}',
                style: t.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
