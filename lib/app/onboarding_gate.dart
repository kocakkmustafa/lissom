/// Kök geçit — onboarding tamamlanmış mı, `LissomShell`'e mi onboarding'e
/// mi girilir. `LissomShell`'in kendi `FutureBuilder` deseniyle AYNI
/// disiplin (bkz. `shell.dart`): **ÇIKMAZ-SOKAK YASAĞI (M-F-267)** — okuma
/// patlarsa ekran yine AÇILIR ve sebebi SÖYLER, sonsuz spinner/sessiz boş
/// ekran YOK.
library;

import 'package:flutter/material.dart';

import 'app_facts.dart';
import 'lissom_theme.dart';
import 'onboarding_flow.dart';
import 'onboarding_store.dart';
import 'shell.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, this.storeLoader, this.shellLoader});

  /// Testte enjekte edilebilir: `rootBundle`/`path_provider` widget testinde
  /// kilitlenebiliyor (aile gotcha'sı), o yüzden yükleyici ÇAĞIRANA ait —
  /// `LissomShell.loader`'la AYNI sözleşme.
  final Future<OnboardingStore> Function()? storeLoader;

  /// `LissomShell`e AYNEN geçirilir — `shell_test.dart`'ın kendi deseni:
  /// enjekte edilmezse `LissomShell`in varsayılanı (`AppFacts.load`,
  /// `rootBundle` ister) çalışır, widget testinde SONSUZ ASILI kalır.
  final Future<AppFacts> Function()? shellLoader;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  late final Future<_Loaded> _loaded = _load();

  /// [OnboardingFlow] tamamlandığında BURADA çevrilir — `_loaded`'ı yeniden
  /// okutup diskten teyit ETMİYORUZ (yazma az önce, aynı çağrı zincirinde
  /// oldu; tekrar okumak gereksiz bir I/O turu olurdu).
  bool _completed = false;

  Future<_Loaded> _load() async {
    final OnboardingStore store =
        await (widget.storeLoader ?? openOnboardingStore)();
    final OnboardingProfile profile = await store.read();
    return _Loaded(store, profile);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Loaded>(
        future: _loaded,
        builder: (BuildContext c, AsyncSnapshot<_Loaded> s) {
          if (s.hasError) return _GateFailureScreen(error: '${s.error}');
          if (!s.hasData) return const _GateLoadingScreen();

          if (_completed || s.data!.profile.completed) {
            return LissomShell(loader: widget.shellLoader);
          }
          return OnboardingFlow(
            store: s.data!.store,
            onDone: () => setState(() => _completed = true),
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
  const _GateFailureScreen({required this.error});
  static const Key key_ = Key('onboarding.gate.loadFailure');
  final String error;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      key: key_,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Lissom couldn't check your setup: $error",
              style: t.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
