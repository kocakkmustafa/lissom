/// Lissom giriş noktası — **measurementOnly** değerlendirme yüzeyi.
///
/// ⛔ **K8 + ADR-003 (bağlayıcı):** sayısal SKOR yok · karşılaştırma yok ·
/// MDC/klinik iddia yok. Gösterilen şey bir ÖLÇÜMDÜR, bir NOT değil —
/// "başlangıç noktan bu" anlatı sınıfı.
///
/// Kabuk yalnız KABLOLAMA (G-100): hiçbir hüküm burada yaşamaz, hepsi
/// `lissom_engine`'de ve versiyonlu config'te. Bu dosya hâlleri GÖSTERİR,
/// karar VERMEZ.
///
/// **Bilgi mimarisi (2026-08-07):** dört sekme — `home` · `library` ·
/// `progress` · `profile` — `config/ia/library.v1.json`'dan TÜRETİLİR.
/// Sekmelerden önce uygulama tek ekrandı ve tasarımın dört sekmesi kodda
/// karşılıksızdı; bu tur o boşluğu kapattı. Her sekmenin dürüst hâli
/// birinci-sınıf ekrandır: ölçülemeyen şey İSİMLİ gerekçeyle görünür,
/// vaat diliyle değil (M-F-186).
///
/// **Onboarding (2026-08-12, SIRA①):** `lib/`de onboarding SIFIR dosyaydı —
/// beş hattan dördünde en az bir ekran varken Lissom'da hiç yoktu (kod işi,
/// kurucu-manuel değil, koordinatör ölçümü). Giriş artık [OnboardingGate]:
/// tamamlanmamışsa [OnboardingFlow], tamamlanmışsa doğrudan [LissomShell].
library;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_account/motion_account.dart';

import 'app/lissom_theme.dart';
import 'app/local_account_bridge.dart';
import 'app/onboarding_gate.dart';

/// Supabase PKCE doğrulama ve şifre sıfırlama dönüşü her iki platformda da
/// aynı URI olarak kayıtlı olmalıdır.
const String kLissomAuthRedirect = 'com.yulalab.lissom://auth/callback';

/// L-348/LIS-P0-002: `google_fonts`un runtime ağ isteğini KAPATIR — iki
/// aile artık `assets/fonts/` altında bundle (`pubspec.yaml`, `tool/
/// fetch_fonts.sh`). Kapatılmadan önce ölçüldü: `PrivacyInfo.xcprivacy`nin
/// kendi yorumunda adıyla kayıtlı GERÇEK bir ağ davranışıydı (L-288),
/// icat edilmiş bir kusur değil.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  const String url = String.fromEnvironment('MOTION_SUPABASE_URL');
  const String publishableKey = String.fromEnvironment(
    'MOTION_SUPABASE_PUBLISHABLE_KEY',
  );

  if (url.isEmpty && publishableKey.isEmpty && !kReleaseMode) {
    runApp(const LissomApp());
    return;
  }
  if (url.isEmpty || publishableKey.isEmpty) {
    runApp(const _AccountSetupFailureApp());
    return;
  }
  try {
    final MotionAccountRuntime runtime = await MotionAccountRuntime.initialize(
      url: url,
      publishableKey: publishableKey,
      app: MotionApp.lissom,
      emailRedirectTo: kLissomAuthRedirect,
      onDeletedAccount: clearLissomLocalData,
      localAccountIds: listLissomLocalAccountIds,
    );
    runApp(LissomAccountHost(runtime: runtime));
  } on Object {
    runApp(const _AccountSetupFailureApp());
  }
}

class LissomApp extends StatelessWidget {
  const LissomApp({
    super.key,
    this.localScope = LissomLocalScope.guest,
    this.accountRouteBuilder,
    this.beforeMeasurement,
  });

  final LissomLocalScope localScope;
  final LissomAccountRouteBuilder? accountRouteBuilder;
  final Future<bool> Function(BuildContext)? beforeMeasurement;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    key: ValueKey<String>('lissom:${localScope.ownerKey}'),
    title: 'Lissom',
    theme: buildLissomTheme(),
    builder: (BuildContext context, Widget? child) =>
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: child ?? const SizedBox.shrink(),
        ),
    supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: OnboardingGate(
      localScope: localScope,
      accountRouteBuilder: accountRouteBuilder,
      beforeMeasurement: beforeMeasurement,
    ),
  );
}

/// The real account page is supplied only when Supabase initialization works.
/// Auth events replace the keyed MaterialApp and close routes that still hold
/// a previous owner's local journal loaders.
class LissomAccountHost extends StatefulWidget {
  const LissomAccountHost({required this.runtime, super.key});

  final MotionAccountRuntime runtime;

  @override
  State<LissomAccountHost> createState() => _LissomAccountHostState();
}

class _LissomAccountHostState extends State<LissomAccountHost> {
  @override
  void dispose() {
    widget.runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget accountPage(BuildContext _, String appId) {
      assert(appId == MotionApp.lissom.name);
      return MotionAccountPage(
        account: widget.runtime.account,
        initialPasswordRecovery: widget.runtime.isPasswordRecovery,
        clearLocalData: clearLissomLocalData,
        onRetryIdentity: widget.runtime.refreshIdentity,
      );
    }

    return MotionIdentityGate(
      runtime: widget.runtime,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.runtime.userId,
        builder: (BuildContext context, String? userId, Widget? child) =>
            LissomApp(
              localScope: userId == null
                  ? LissomLocalScope.guest
                  : LissomLocalScope.account(userId),
              accountRouteBuilder: accountPage,
              beforeMeasurement: (measurementContext) =>
                  requireMotionPaidAccess(
                    measurementContext,
                    account: widget.runtime.account,
                    accountPageBuilder: (pageContext) =>
                        accountPage(pageContext, MotionApp.lissom.name),
                  ),
            ),
      ),
    );
  }
}

class _AccountSetupFailureApp extends StatelessWidget {
  const _AccountSetupFailureApp();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: Builder(
      builder: (BuildContext context) {
        final bool tr = Localizations.localeOf(context).languageCode == 'tr';
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                tr
                    ? 'Lissom hesap hizmeti başlatılamadı. Uygulamayı yeniden açmayı dene.'
                    : 'Lissom account service could not start. Try opening the app again.',
              ),
            ),
          ),
        );
      },
    ),
  );
}
