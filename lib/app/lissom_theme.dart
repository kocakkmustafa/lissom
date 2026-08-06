/// Lissom görsel dili — claude.ai/design paneli çıktısının Flutter kod hâli.
///
/// Kaynak: `claude.ai/design` projesi `28cd0df6…` → `Lissom.dc.html`,
/// Foundations bölümü (palet · tip ölçeği · biçim/gölge · hareket). Değerler
/// tasarımdan BİREBİR — bu dosya icat etmez, TAŞIR.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class LissomColors {
  static const Color peach = Color(0xFFF0C4A8);
  static const Color rose = Color(0xFFE0BFD0);
  static const Color mist = Color(0xFFBACDDE);
  static const Color cream = Color(0xFFF5E6D0);
  static const Color roseDeep = Color(0xFFB0748F);
  static const Color roseDeepHover = Color(0xFF8E5A73);
  static const Color mistDeep = Color(0xFF8FAEC8);
  static const Color canvas = Color(0xFFF3EDE9);
  static const Color card = Color(0xFFFFFCFA);
  static const Color ink = Color(0xFF38313A);

  static const Color bodySecondary = Color(0xFF6B6069);
  static const Color labelMuted = Color(0xFF9C929B);
  static const Color note = Color(0xFF8B7F88);
  static const Color metaMono = Color(0xFFA79DA5);
  static const Color hairline = Color(0xFFF2EBEC);

  /// Ekran zemini — her mockup ekranında tekrarlanan sıcak diyagonal gradyan.
  static const LinearGradient screenBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFFBF3EE), Color(0xFFF5E8E4), Color(0xFFEEDDE7)],
    stops: <double>[0.0, 0.46, 1.0],
  );
}

abstract final class LissomRadii {
  static const double board = 30;
  static const double card = 26;
  static const double inner = 20;
  static const double pill = 999;
}

/// Gölgeler geniş, alçak-opasiteli, sıcak-tonlu — hiçbir zaman keskin kenar.
/// Kaynak: `0 22px 44px -26px rgba(88,64,76,.3)` (Foundations · Shape & shadow).
abstract final class LissomShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x33584050),
      blurRadius: 44,
      offset: Offset(0, 22),
      spreadRadius: -18,
    ),
  ];
}

/// Tasarımın adlandırdığı geçiş süreleri — anlık/keskin YOK, hepsi
/// yavaş-süzülen (Foundations · Motion).
abstract final class LissomMotion {
  static const Duration glide = Duration(milliseconds: 520);
  static const Duration settle = Duration(milliseconds: 280);
  static const Duration easeOut = Duration(milliseconds: 600);
  static const Duration rest = Duration(milliseconds: 900);
  static const Duration breathe = Duration(seconds: 14);
}

/// IBM Plex Mono — `TextTheme`'de karşılığı olmayan meta/birim/referans metni.
abstract final class LissomMono {
  static TextStyle style({double fontSize = 12, Color? color}) =>
      GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        color: color ?? LissomColors.metaMono,
        height: 1,
      );
}

ThemeData buildLissomTheme() {
  final TextTheme sans = GoogleFonts.nunitoSansTextTheme();
  final TextTheme serif = GoogleFonts.newsreaderTextTheme();

  TextStyle display(double size, {FontWeight weight = FontWeight.w300}) =>
      serif.displayLarge!.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: LissomColors.ink,
        letterSpacing: -0.015 * size,
        height: 1.06,
      );

  TextStyle label(double size, Color color) => sans.labelLarge!.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.16 * size,
        color: color,
        height: 1,
      );

  final TextTheme textTheme = TextTheme(
    displayLarge: display(56),
    displayMedium: display(40),
    displaySmall: display(34),
    headlineLarge: display(30),
    headlineMedium: display(26, weight: FontWeight.w400),
    headlineSmall: display(22, weight: FontWeight.w400),
    titleLarge: sans.titleLarge!.copyWith(
        fontSize: 17, fontWeight: FontWeight.w600, color: LissomColors.ink),
    titleMedium: sans.titleMedium!.copyWith(
        fontSize: 15, fontWeight: FontWeight.w600, color: LissomColors.ink),
    titleSmall: sans.titleSmall!.copyWith(
        fontSize: 13.5, fontWeight: FontWeight.w600, color: LissomColors.ink),
    bodyLarge: sans.bodyLarge!.copyWith(
        fontSize: 17, height: 1.65, color: LissomColors.ink),
    bodyMedium: sans.bodyMedium!.copyWith(
        fontSize: 14, height: 1.6, color: LissomColors.bodySecondary),
    bodySmall: sans.bodySmall!.copyWith(
        fontSize: 12.5, height: 1.5, color: LissomColors.labelMuted),
    labelLarge: label(11, LissomColors.labelMuted),
    labelMedium: label(11, LissomColors.roseDeepHover),
    labelSmall: label(10.5, LissomColors.labelMuted),
  );

  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: LissomColors.roseDeep,
    brightness: Brightness.light,
  ).copyWith(
    primary: LissomColors.roseDeep,
    onPrimary: Colors.white,
    secondary: LissomColors.mistDeep,
    surface: LissomColors.card,
    onSurface: LissomColors.ink,
    surfaceContainerHighest: LissomColors.canvas,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LissomColors.canvas,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: LissomColors.ink,
      titleTextStyle: textTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: LissomColors.roseDeep,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: textTheme.titleSmall?.copyWith(color: Colors.white),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: LissomColors.hairline,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.iOS: _LissomGlideTransitionsBuilder(),
        TargetPlatform.android: _LissomGlideTransitionsBuilder(),
      },
    ),
  );
}

/// 12px dikey kayma + cross-fade, 520ms — Foundations · Motion "glide".
/// Kenardan kaydırma YOK: bu ailenin keskin/hızlı JabLab diline karşıt kararı.
class _LissomGlideTransitionsBuilder extends PageTransitionsBuilder {
  const _LissomGlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: curved.drive(
          Tween<Offset>(begin: const Offset(0, 0.014), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}

/// Foundations panelindeki tekrarlanan kart deseni: `#FFFCFA` zemin, 26px
/// köşe, geniş yumuşak gölge. Bu tasarımda tek en-çok-tekrarlanan yüzey
/// birimi olduğu için burada tek adres — her ekranda yeniden icat edilmez.
class LissomCard extends StatelessWidget {
  const LissomCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.gradient,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? LissomColors.card) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(LissomRadii.card),
          boxShadow: LissomShadows.soft,
        ),
        child: Padding(padding: padding, child: child),
      );
}

/// Eyebrow etiket — 11px, geniş harf aralığı, büyük harf. Bölüm başlıkları ve
/// "MEASURED", "Not measured" gibi durum etiketleri bu stili paylaşır.
class LissomEyebrow extends StatelessWidget {
  const LissomEyebrow(this.text, {this.color, super.key});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: color ?? LissomColors.labelMuted),
      );
}
