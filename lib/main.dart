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

import 'dart:async';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_account/motion_account.dart';

import 'app/lissom_theme.dart';
import 'app/lissom_appearance.dart';
import 'app/lissom_presentation_host.dart';
import 'app/account_epoch_client.dart';
import 'app/auth_session_fence.dart';
import 'app/app_facts.dart';
import 'app/local_account_bridge.dart';
import 'app/local_owner.dart';
import 'app/local_owner_context.dart';
import 'app/locale_text.dart';
import 'app/lissom_locales.dart';
import 'app/lissom_localizations.dart';
import 'app/onboarding_gate.dart';
import 'app/onboarding_store.dart';
import 'package:lissom_engine/lissom_engine.dart' show PoseSource;

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
  final appearance = LissomAppearanceController();
  final locale = LissomLocaleController();
  // Independent installation reads run together before the first Flutter app.
  // Each has its own bounded read deadline and visible failure fallback.
  await Future.wait<void>(<Future<void>>[
    appearance.initialize(),
    locale.initialize(),
  ]);
  void launch(Widget child) => runApp(
    LissomAppearanceHost(
      controller: appearance,
      child: LissomLocaleHost(
        controller: locale,
        child: LissomPresentationHost(child: child),
      ),
    ),
  );

  const String url = String.fromEnvironment('MOTION_SUPABASE_URL');
  const String publishableKey = String.fromEnvironment(
    'MOTION_SUPABASE_PUBLISHABLE_KEY',
  );

  if (url.isEmpty && publishableKey.isEmpty && !kReleaseMode) {
    launch(const LissomApp());
    return;
  }
  if (url.isEmpty || publishableKey.isEmpty) {
    launch(const _AccountSetupFailureApp());
    return;
  }
  final LissomOwnerRegistry owners = LissomOwnerRegistry();
  try {
    await owners.initialize();
    final MotionAccountRuntime runtime = await MotionAccountRuntime.initialize(
      url: url,
      publishableKey: publishableKey,
      app: MotionApp.lissom,
      emailRedirectTo: kLissomAuthRedirect,
      onDeletedAccount: owners.eraseConfirmedAccount,
      localAccountIds: () => listLissomLocalAccountIds(
        supportDirectory: () async => owners.supportDirectory,
      ),
    );
    launch(LissomAccountHost(runtime: runtime, owners: owners));
  } on Object {
    owners.dispose();
    launch(const _AccountSetupFailureApp());
  }
}

class LissomApp extends StatelessWidget {
  const LissomApp({
    super.key,
    this.localScope = LissomLocalScope.guest,
    this.accountRouteBuilder,
    this.beforeMeasurement,
    this.forcedAccountPage,
    this.factsLoader,
    this.poseSourceLoader,
    this.measurementAvailable,
    this.onboardingLoader,
  });

  final LissomLocalScope localScope;
  final LissomAccountRouteBuilder? accountRouteBuilder;
  final Future<bool> Function(BuildContext)? beforeMeasurement;
  final Widget? forcedAccountPage;
  final Future<AppFacts> Function()? factsLoader;
  final PoseSource Function()? poseSourceLoader;
  final bool? measurementAvailable;
  final Future<OnboardingStore> Function()? onboardingLoader;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    key: ValueKey<String>(
      'lissom:${localScope.lifetimeKey}:${forcedAccountPage == null ? 'course' : 'account'}',
    ),
    title: 'Lissom',
    theme: buildLissomTheme(locale: _lissomAppearanceLocale(context)),
    darkTheme: buildLissomTheme(
      brightness: Brightness.dark,
      locale: _lissomAppearanceLocale(context),
    ),
    themeMode: LissomAppearanceScope.maybeOf(context)?.mode ?? ThemeMode.system,
    themeAnimationDuration: Duration.zero,
    builder: (BuildContext context, Widget? child) {
      final Widget content = AnnotatedRegion<SystemUiOverlayStyle>(
        value: lissomSystemOverlayStyle(context),
        child: child ?? const SizedBox.shrink(),
      );
      final LissomLocalOwner? owner = localScope.owner;
      return owner == null
          ? content
          : LissomOwnerContext(owner: owner, child: content);
    },
    locale: LissomLocaleScope.maybeOf(context)?.locale,
    supportedLocales: kLissomSupportedLocales,
    localeListResolutionCallback: resolveLissomLocale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      LissomLocalizationsDelegate(),
      MotionAccountLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home:
        forcedAccountPage ??
        OnboardingGate(
          localScope: localScope,
          accountRouteBuilder: accountRouteBuilder,
          beforeMeasurement: beforeMeasurement,
          shellLoader: factsLoader,
          poseSourceLoader: poseSourceLoader,
          measurementAvailable: measurementAvailable,
          storeLoader: onboardingLoader,
        ),
  );
}

/// The real account page is supplied only when Supabase initialization works.
/// Auth events replace the keyed MaterialApp and close routes that still hold
/// a previous owner's local journal loaders.
class LissomAccountHost extends StatefulWidget {
  const LissomAccountHost({
    required this.runtime,
    this.owners,
    this.factsLoader,
    this.poseSourceLoader,
    this.measurementAvailable,
    this.onboardingLoader,
    super.key,
  });

  final MotionAccountRuntime runtime;
  final LissomOwnerRegistry? owners;
  final Future<AppFacts> Function()? factsLoader;
  final PoseSource Function()? poseSourceLoader;
  final bool? measurementAvailable;
  final Future<OnboardingStore> Function(LissomLocalScope)? onboardingLoader;

  @override
  State<LissomAccountHost> createState() => _LissomAccountHostState();
}

class _LissomAccountHostState extends State<LissomAccountHost> {
  late LissomOwnerRegistry _owners = widget.owners ?? LissomOwnerRegistry();
  StreamSubscription<Object?>? _authSubscription;
  LissomLocalScope? _scope;
  Future<void>? _closing;
  Object? _closeError;
  bool _recovering = false;
  bool _ownerEvent = false;
  bool _mayOpen = true;
  late LissomAuthSessionFence _sessionFence;
  bool _sessionReplacementPending = false;
  bool _credentialRefreshPending = false;
  String? _lastUserId;
  MotionIdentityPhase? _lastPhase;
  int _runtimeRevision = 0;

  @override
  void initState() {
    super.initState();
    _owners.addListener(_changed);
    _attachRuntime(widget.runtime);
    _initializeOwners();
    _synchronize();
  }

  void _initializeOwners() {
    final LissomOwnerRegistry owners = _owners;
    owners.initialize().then<void>(
      (_) {
        if (mounted && identical(_owners, owners)) _changed();
      },
      onError: (Object error, StackTrace _) {
        if (!mounted || !identical(_owners, owners)) {
          return;
        }
        _closeError = error;
        _changed();
      },
    );
  }

  void _attachRuntime(
    MotionAccountRuntime runtime, {
    bool preserveSessionFence = false,
  }) {
    runtime.userId.addListener(_changed);
    runtime.passwordRecovery.addListener(_changed);
    runtime.identityVerification.addListener(_verificationChanged);
    if (!preserveSessionFence) {
      _sessionFence = LissomAuthSessionFence(
        runtime.account.supabase.auth.currentSession,
      );
      _sessionReplacementPending = false;
    }
    _authSubscription = runtime.account.authChanges.listen(
      (state) {
        if (!mounted || !identical(widget.runtime, runtime)) {
          return;
        }
        // The actual public Session reference distinguishes a replay from a
        // replacement. Only a matching tokenRefreshed event keeps storage E.
        final LissomSessionChange change = _sessionFence.observe(
          runtime.account.supabase.auth.currentSession,
          event: state,
        );
        _observeSessionChange(runtime, change);
        if (change != LissomSessionChange.none) _changed();
      },
      onError: (Object _, StackTrace __) {
        // Consume this subscription's error and stop resources immediately.
        // Identity/recovery routing still follows the canonical runtime.
        if (!mounted || !identical(widget.runtime, runtime)) {
          return;
        }
        // Signed-out/null is already canonical guest admission, and Core may
        // report the same values without notifying. Reopen only after successful
        // drain; _closing/_closeError still block pending or failed closure.
        _mayOpen =
            runtime.phase.value == MotionIdentityPhase.signedOut &&
            runtime.userId.value == null;
        _retireScope();
        setState(() {});
      },
    );
  }

  void _observeSessionChange(
    MotionAccountRuntime runtime,
    LissomSessionChange change,
  ) {
    if (change == LissomSessionChange.none) {
      return;
    }
    _credentialRefreshPending = change == LissomSessionChange.credentialRefresh;
    if (change == LissomSessionChange.replacement) {
      final String? id = runtime.account.supabase.auth.currentSession?.user.id;
      if (id != null) _owners.invalidateTickets(id);
      _sessionReplacementPending = id != null;
      _ownerEvent = true;
      _retireScope(); // Synchronous admission/resource retirement before await.
    }
    // Keep canonical identity verification; do not infer success from this void
    // Future and cached phase/userId. The credential fence deliberately stays
    // closed until a public Session-bound verification proof is available.
    unawaited(
      runtime.refreshIdentity().then<void>(
        (_) {},
        onError: (Object _, StackTrace __) {},
      ),
    );
  }

  void _reconcileActualSession() {
    final MotionAccountRuntime runtime = widget.runtime;
    _observeSessionChange(
      runtime,
      _sessionFence.observe(runtime.account.supabase.auth.currentSession),
    );
  }

  void _detachRuntime(MotionAccountRuntime runtime) {
    runtime.userId.removeListener(_changed);
    runtime.passwordRecovery.removeListener(_changed);
    runtime.identityVerification.removeListener(_verificationChanged);
    _authSubscription?.cancel();
    _authSubscription = null;
  }

  @override
  void didUpdateWidget(covariant LissomAccountHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.runtime == widget.runtime &&
        oldWidget.owners == widget.owners) {
      return;
    }
    _detachRuntime(oldWidget.runtime);
    _retireScope();
    if (oldWidget.owners != widget.owners) {
      _owners.removeListener(_changed);
      _owners.dispose();
      _owners = widget.owners ?? LissomOwnerRegistry();
      _owners.addListener(_changed);
      _initializeOwners();
    }
    if (oldWidget.runtime != widget.runtime) oldWidget.runtime.dispose();
    _runtimeRevision++;
    _ownerEvent = true;
    _lastPhase = null;
    _attachRuntime(
      widget.runtime,
      preserveSessionFence: identical(oldWidget.runtime, widget.runtime),
    );
    _synchronize();
  }

  void _verificationChanged() {
    // Let the matching SDK event classify refresh before reconciling a pulse.
    scheduleMicrotask(() {
      if (!mounted) {
        return;
      }
      final runtime = widget.runtime;
      if (runtime.isCurrentSessionVerified) {
        _sessionFence.bindVerified(
          runtime.account.supabase.auth.currentSession,
        );
        _sessionReplacementPending = false;
        _credentialRefreshPending = false;
        _mayOpen = true;
      }
      _changed();
    });
  }

  void _changed() {
    _synchronize();
    if (mounted) {
      setState(() {});
    }
  }

  void _retireScope() {
    final LissomLocalScope? old = _scope;
    if (old == null) {
      return;
    }
    _scope = null;
    final Future<void> closing = old.owner!.retireAndDrain();
    _closing = closing;
    closing.then<void>(
      (_) {
        if (!mounted || !identical(_closing, closing)) {
          return;
        }
        _closing = null;
        _changed();
      },
      onError: (Object error, StackTrace _) {
        if (!mounted || !identical(_closing, closing)) {
          return;
        }
        _closing = null;
        _closeError = error;
        _changed();
      },
    );
  }

  void _synchronize() {
    // Silent same-user recoverSession has no auth event. Reconcile only at
    // existing host admission points; no idle immediate-notification claim.
    _reconcileActualSession();
    final MotionIdentityPhase phase = widget.runtime.phase.value;
    final String? id = widget.runtime.userId.value;
    final bool recovery = widget.runtime.passwordRecovery.value;
    final bool admitted =
        !widget.runtime.isDisposed &&
        ((phase == MotionIdentityPhase.signedOut &&
                id == null &&
                widget.runtime.account.supabase.auth.currentSession == null) ||
            (phase == MotionIdentityPhase.verified &&
                id != null &&
                widget.runtime.isCurrentSessionVerified));
    final bool changed =
        _ownerEvent ||
        id != _lastUserId ||
        phase != _lastPhase ||
        recovery != _recovering;
    if (changed) _mayOpen = true;
    _lastUserId = id;
    _lastPhase = phase;
    _recovering = recovery;
    _ownerEvent = false;
    final bool preserveRefresh =
        _credentialRefreshPending &&
        !_sessionReplacementPending &&
        _scope != null &&
        widget.runtime.account.supabase.auth.currentSession?.user.id == id &&
        phase != MotionIdentityPhase.signedOut &&
        phase != MotionIdentityPhase.unavailable &&
        !widget.runtime.isDisposed;
    if ((!admitted && !preserveRefresh) ||
        recovery ||
        (changed && !preserveRefresh) ||
        (_scope?.owner?.isActive == false)) {
      _retireScope();
    }
    if (!admitted ||
        recovery ||
        _scope != null ||
        _closing != null ||
        _closeError != null ||
        !_mayOpen ||
        _sessionReplacementPending ||
        !_owners.isInitialized ||
        (id != null && _owners.isFenced(id))) {
      return;
    }
    _scope = _owners.openScope(
      phase == MotionIdentityPhase.signedOut ? null : id,
    );
    _mayOpen = false;
  }

  Widget _accountPage(BuildContext _, String appId) {
    assert(appId == MotionApp.lissom.name);
    _reconcileActualSession();
    final MotionAccountClient account = widget.runtime.account;
    final LissomAuthSessionFence pageSessionFence = _sessionFence;
    final LissomOwnerRegistry pageOwners = _owners;
    final String? id = account.currentUser?.id;
    final LissomDeletionTicket? ticket = id == null
        ? null
        : pageOwners.captureTicket(id);
    final MotionAccountClient pageAccount = ticket == null
        ? account
        : LissomEpochAccountClient(
            account: account,
            registry: pageOwners,
            ticket: ticket,
            canInitiate: () =>
                widget.runtime.isCurrentSessionVerified &&
                pageSessionFence.canInitiate(
                  account.supabase.auth.currentSession,
                ),
          );
    return ValueListenableBuilder<bool>(
      valueListenable: widget.runtime.passwordRecovery,
      builder: (BuildContext context, bool recovering, Widget? child) =>
          MotionAccountPage(
            account: pageAccount,
            initialPasswordRecovery: recovering,
            clearLocalData: ticket == null
                ? null
                : (String confirmedId) =>
                      pageOwners.eraseWithTicket(ticket, confirmedId),
            onRetryIdentity: widget.runtime.refreshIdentity,
          ),
    );
  }

  @override
  void dispose() {
    _detachRuntime(widget.runtime);
    _owners.removeListener(_changed);
    _retireScope();
    _owners.dispose();
    widget.runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LissomLocalScope? scope = _scope;
    return MotionIdentityGate(
      runtime: widget.runtime,
      child: _recovering && _owners.isInitialized
          ? LissomApp(
              key: ValueKey<String>(
                'recovery:$_runtimeRevision:${widget.runtime.userId.value}',
              ),
              forcedAccountPage: _accountPage(context, MotionApp.lissom.name),
            )
          : scope == null
          ? LissomApp(
              key: ValueKey<String>('closed:$_runtimeRevision'),
              forcedAccountPage: Builder(
                builder: (BuildContext context) => Scaffold(
                  key: const Key('lissom.owner.closed'),
                  body: Center(
                    child: Text(
                      _closeError == null
                          ? _sessionReplacementPending
                                ? localeText(
                                    context,
                                    'Your account session changed. Reopen Lissom.',
                                    'Hesap oturumun değişti. Lissom’u yeniden aç.',
                                  )
                                : localeText(
                                    context,
                                    'Account resources are closing.',
                                    'Hesap kaynakları kapatılıyor.',
                                  )
                          : localeText(
                              context,
                              'Account resources could not close. Reopen Lissom.',
                              'Hesap kaynakları kapatılamadı. Lissom’u yeniden aç.',
                            ),
                    ),
                  ),
                ),
              ),
            )
          : LissomApp(
              // A fresh storage epoch is a cold public Core gate admission.
              key: ValueKey<String>('owner:${scope.lifetimeKey}'),
              localScope: scope,
              accountRouteBuilder: _accountPage,
              factsLoader: widget.factsLoader,
              poseSourceLoader: widget.poseSourceLoader,
              measurementAvailable: widget.measurementAvailable,
              onboardingLoader: widget.onboardingLoader == null
                  ? null
                  : () => widget.onboardingLoader!(scope),
              beforeMeasurement: (measurementContext) =>
                  requireMotionPaidAccess(
                    measurementContext,
                    account: widget.runtime.account,
                    accountPageBuilder: (pageContext) =>
                        _accountPage(pageContext, MotionApp.lissom.name),
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
    theme: buildLissomTheme(locale: _lissomAppearanceLocale(context)),
    darkTheme: buildLissomTheme(
      brightness: Brightness.dark,
      locale: _lissomAppearanceLocale(context),
    ),
    themeMode: LissomAppearanceScope.maybeOf(context)?.mode ?? ThemeMode.system,
    themeAnimationDuration: Duration.zero,
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: lissomSystemOverlayStyle(context),
      child: child ?? const SizedBox.shrink(),
    ),
    locale: LissomLocaleScope.maybeOf(context)?.locale,
    supportedLocales: kLissomSupportedLocales,
    localeListResolutionCallback: resolveLissomLocale,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      LissomLocalizationsDelegate(),
      MotionAccountLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    home: Builder(
      builder: (BuildContext context) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                localeText(
                  context,
                  'Lissom account service could not start. Try opening the app again.',
                  'Lissom hesap hizmeti başlatılamadı. Uygulamayı yeniden açmayı dene.',
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Locale _lissomAppearanceLocale(BuildContext context) =>
    LissomLocaleScope.maybeOf(context)?.locale ??
    Localizations.maybeLocaleOf(context) ??
    resolveLissomLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
      kLissomSupportedLocales,
    );

SystemUiOverlayStyle lissomSystemOverlayStyle(BuildContext context) =>
    (Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        );
