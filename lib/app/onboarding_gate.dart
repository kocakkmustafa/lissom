/// Kök geçit — onboarding tamamlanmış mı, `LissomShell`'e mi onboarding'e
/// mi girilir. `LissomShell`'in kendi `FutureBuilder` deseniyle AYNI
/// disiplin (bkz. `shell.dart`): **ÇIKMAZ-SOKAK YASAĞI (M-F-267)** — okuma
/// patlarsa ekran yine AÇILIR ve sebebi SÖYLER, sonsuz spinner/sessiz boş
/// ekran YOK.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'app_facts.dart';
import 'attempt_values.dart';
import 'lissom_theme.dart';
import 'local_account_bridge.dart';
import 'locale_text.dart';
import 'onboarding_flow.dart';
import 'onboarding_store.dart';
import 'shell.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    super.key,
    this.storeLoader,
    this.shellLoader,
    this.poseSourceLoader,
    this.sessionStoreLoader,
    this.attemptValueStoreLoader,
    this.localScope = LissomLocalScope.guest,
    this.accountRouteBuilder,
    this.beforeMeasurement,
    this.measurementAvailable,
  });

  /// A signed-in host passes a different scope for each authenticated user.
  /// The guest scope retains all legacy file paths and is never migrated here.
  final LissomLocalScope localScope;
  final LissomAccountRouteBuilder? accountRouteBuilder;
  final Future<bool> Function(BuildContext)? beforeMeasurement;

  /// Optional test seam for the future camera journey. Production callers
  /// leave this null so the shared release policy decides availability.
  final bool? measurementAvailable;

  /// Testte enjekte edilebilir: `rootBundle`/`path_provider` widget testinde
  /// kilitlenebiliyor (aile gotcha'sı), o yüzden yükleyici ÇAĞIRANA ait —
  /// `LissomShell.loader`'la AYNI sözleşme.
  final Future<OnboardingStore> Function()? storeLoader;

  /// `LissomShell`e AYNEN geçirilir — `shell_test.dart`'ın kendi deseni:
  /// enjekte edilmezse `LissomShell`in varsayılanı (`AppFacts.load`,
  /// `rootBundle` ister) çalışır, widget testinde SONSUZ ASILI kalır.
  final Future<AppFacts> Function()? shellLoader;

  /// **A1 DİKİŞİNİN SON HALKASI (L-309).** Kök geçit ⇒ kabuk ⇒ home ⇒ canlı
  /// ölçüm. `ageBand`ın izlediği yolun AYNISI — ve o yol zaten şu cümleyle
  /// gerekçelendirilmişti: *"akmazsa kullanıcı ZORUNLU bir seçim yapar ve
  /// seçim HİÇBİR ŞEYİ değiştirmez"*. Burada akmayan şey **ölçümün
  /// kendisiydi**: yürüyüş taze kurulumdan başlayamıyordu.
  final PoseSource Function()? poseSourceLoader;
  final Future<SessionStore> Function()? sessionStoreLoader;

  /// D13/F2 — `LissomShell`e AYNEN geçirilir, `sessionStoreLoader`la AYNI
  /// sözleşme.
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  late Future<_Loaded> _loaded = _load();

  /// [OnboardingFlow] tamamlandığında BURADA çevrilir — `_loaded`'ı yeniden
  /// okutup diskten teyit ETMİYORUZ (yazma az önce, aynı çağrı zincirinde
  /// oldu; tekrar okumak gereksiz bir I/O turu olurdu).
  bool _completed = false;

  /// Akış AZ ÖNCE tamamlandıysa bandı buradan alırız — `_loaded`'daki profil
  /// AÇILIŞTA okundu ve o profilde bant HENÜZ YOK. Bu alan olmasaydı bandın
  /// ilk etkisi bir sonraki açılışta görülürdü (ilk ölçüm yanlış bantla).
  OnboardingProfile? _justCompleted;

  @override
  void didUpdateWidget(covariant OnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localScope.lifetimeKey != widget.localScope.lifetimeKey) {
      _completed = false;
      _justCompleted = null;
      _loaded = _load();
    }
  }

  Future<_Loaded> _load() async {
    final OnboardingStore store =
        await (widget.storeLoader ??
            () => openOnboardingStore(scope: widget.localScope))();
    final OnboardingProfile profile = await store.read();
    return _Loaded(store, profile);
  }

  void _openAccount() {
    final LissomAccountRouteBuilder? builder = widget.accountRouteBuilder;
    if (builder == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => builder(context, kLissomMotionAppId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Loaded>(
    future: _loaded,
    builder: (BuildContext c, AsyncSnapshot<_Loaded> s) {
      if (s.hasError) {
        return _GateFailureScreen(
          error: '${s.error}',
          onRetry: () => setState(() {
            _loaded = _load();
          }),
        );
      }
      if (!s.hasData) return const _GateLoadingScreen();

      if (_completed || s.data!.profile.completed) {
        // Onboarding'de BEYAN EDİLEN yaş bandı buradan aşağı akar
        // (kabuk → home → canlı ölçüm → motor). Akmazsa kullanıcı
        // ZORUNLU bir seçim yapar ve seçim HİÇBİR ŞEYİ değiştirmez —
        // L-262 sınıfı: olmayan bir yeteneği kullanıcıya anlatmak.
        //
        // Sıra önemli: AZ ÖNCE tamamlanan profil, açılışta okunanı EZER.
        return LissomShell(
          loader: widget.shellLoader,
          localScope: widget.localScope,
          accountRouteBuilder: widget.accountRouteBuilder,
          beforeMeasurement: widget.beforeMeasurement,
          measurementAvailable: widget.measurementAvailable,
          ageBand: (_justCompleted ?? s.data!.profile).ageBand,
          poseSourceLoader: widget.poseSourceLoader,
          sessionStoreLoader: widget.sessionStoreLoader,
          attemptValueStoreLoader: widget.attemptValueStoreLoader,
        );
      }
      return OnboardingFlow(
        store: s.data!.store,
        onOpenAccount: widget.accountRouteBuilder == null ? null : _openAccount,
        onDone: (OnboardingProfile p) => setState(() {
          _completed = true;
          _justCompleted = p;
        }),
      );
    },
  );
}

final class _Loaded {
  const _Loaded(this.store, this.profile);
  final OnboardingStore store;
  final OnboardingProfile profile;
}

class _GateLoadingScreen extends StatelessWidget {
  const _GateLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: LissomColors.screenBackground),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _GateFailureScreen extends StatelessWidget {
  const _GateFailureScreen({required this.error, required this.onRetry});
  static const Key key_ = Key('onboarding.gate.loadFailure');
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      key: key_,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  localeText(
                    context,
                    "Lissom couldn't check your setup: $error",
                    'Lissom kurulumunu denetleyemedi: $error',
                  ),
                  style: t.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('onboarding.gate.retry'),
                  onPressed: onRetry,
                  child: Text(localeText(context, 'Try again', 'Yeniden dene')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
