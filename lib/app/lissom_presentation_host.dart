// DRAFT ONLY / compile UNRUN. App-side bridge uses the existing Core gate API;
// it does not pass unpublished constructor arguments or replace owner keys.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'lissom_appearance.dart';
import 'lissom_locales.dart';
import 'lissom_theme.dart';

class LissomPresentationHost extends StatefulWidget {
  const LissomPresentationHost({required this.child, super.key});
  final Widget child;

  @override
  State<LissomPresentationHost> createState() => _LissomPresentationHostState();
}

class _LissomPresentationHostState extends State<LissomPresentationHost>
    with WidgetsBindingObserver {
  late List<Locale> _deviceLocales =
      List<Locale>.of(WidgetsBinding.instance.platformDispatcher.locales);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    if (!mounted) { return; }
    setState(() { _deviceLocales = List<Locale>.of(locales ?? const <Locale>[]); });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.fromView(
    view: View.of(context),
    child: Builder(builder: (context) {
      final locale = LissomLocaleScope.maybeOf(context)?.locale ??
          resolveLissomLocale(_deviceLocales, kLissomSupportedLocales);
      final mode = LissomAppearanceScope.maybeOf(context)?.mode ?? ThemeMode.system;
      final brightness = switch (mode) {
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
      };
      return Localizations(
        locale: locale,
        delegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        child: Theme(
          data: buildLissomTheme(brightness: brightness, locale: locale),
          child: widget.child,
        ),
      );
    }),
  );
}
