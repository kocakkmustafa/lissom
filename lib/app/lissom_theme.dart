/// Lissom visual language. Runtime colors resolve through an immutable
/// context ThemeExtension. The legacy light constants below preserve existing
/// public/test contracts during migration; product UI no longer reads them.
library;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoThemeData, CupertinoTextThemeData;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'lissom_palette.dart';

abstract final class LissomColors {
  static const Color peach = Color(0xFFF0C4A8);
  static const Color rose = Color(0xFFE0BFD0);
  static const Color mist = Color(0xFFBACDDE);
  static const Color cream = Color(0xFFF5E6D0);
  static const Color roseDeep = Color(0xFFB0748F);

  /// **Vurgu METNİ tonu.** #8E5A73'ten #86556D'ye koyulaştırıldı (L-234):
  /// eskisi ekranın en koyu gradyan durağında **4,18:1** veriyordu, eşik 4.5.
  /// Ton (331°) ve doygunluk (0,224) AYNEN korundu — yalnız açıklık düştü,
  /// yani tasarımın rengi değil okunabilirliği değişti.
  ///
  /// ⚠️ Eşiğe TAM oturan değer (#87566E, 4,498) BİLEREK seçilmedi: kayan
  /// noktada 4,498 < 4,5 ve kapı kıl payı kırmızı yanıyordu. Sınırın ÜSTÜNDE
  /// bir marj (4,565) alınıyor — eşiğe teğet geçen bir renk, ilk yuvarlama
  /// farkında geri döner.
  static const Color roseDeepHover = Color(0xFF86556D);

  /// **Beyaz metin taşıyan dolgular için** — adı rengini değil SÖZLEŞMESİNİ
  /// söyler.
  ///
  /// [roseDeep] marka/seed rengidir ve beyazla **3,66:1** verir; 13,5px
  /// normal ağırlıktaki bir buton etiketi için WCAG AA eşiği **4,5**.
  /// Yani birincil buton etiketi ölçülebilir biçimde okunmuyordu
  /// (L-264 — sekme turu açılır açılmaz yakaladı).
  ///
  /// Üç yol vardı ve en dar olanı seçildi:
  ///   - `roseDeep`i koyulaştırmak → **marka/seed rengini** değiştirirdi
  ///   - `roseDeepHover` kullanmak → hover ile durgun hâl **aynılaşırdı**
  ///   - **bu:** yalnız dolgu için asgari koyulaştırma (ton korunur, ×0,89)
  ///
  /// Eşik icat değil: **4,5 dış bir standart** (WCAG 2.2 AA, normal metin).
  static const Color fillForWhiteText = Color(0xFF9C677F);
  static const Color mistDeep = Color(0xFF8FAEC8);
  static const Color canvas = Color(0xFFF3EDE9);
  static const Color card = Color(0xFFFFFCFA);
  static const Color ink = Color(0xFF38313A);

  static const Color bodySecondary = Color(0xFF6B6069);

  /// ⚠️ **METİN İÇİN KULLANILMAZ (L-234).** Ölçüldü: kart üstünde **2,94:1**,
  /// gradyan sonunda **2,31:1** — WCAG normal-metin eşiği 4.5. Bu bir üslup
  /// notu değil: 11px bir bölüm başlığı 2,94:1'de *okunmuyor*, yalnız
  /// *duruyor*. Aile hükmü: **"görünmeyen bir dürüst hâl, susmakla aynı
  /// şeydir."**
  ///
  /// Süs amaçlı, anlam TAŞIMAYAN ikon/çizgi için kalabilir; anlam taşıyan her
  /// şey [bodySecondary] kullanır. `contrast_test.dart` bunu zorluyor.
  static const Color labelMuted = Color(0xFF9C929B);

  // NOT: `note` (#8B7F88) KALDIRILDI — `LissomMono` ve `LissomColors.note`
  // aynı sınıftı: hiçbir çağıranı yoktu VE metin olarak kullanılsaydı 3,75:1
  // ile doğardı (eşik 4.5). Ölü bir token, bir gün birinin eline geçen
  // yüklü bir silahtır.

  /// Kart gradyanlarının koyu uçları — **metin bunların üstünde çiziliyor**,
  /// o yüzden kontrast kapısının ZEMİN listesinde yer almak zorundalar.
  ///
  /// ⚠️ Bu ikisi `battery_summary_view.dart` içinde HAM `Color(0x…)` olarak
  /// gömülüydü ve kapı onları HİÇ ÖLÇMEDİ (L-236). Geçiyorlar (5,56 / 5,43) —
  /// ama bu şans, kapı değildi. JabLab'ın cümlesi: *"örüntüyü değil örneği
  /// düzeltmişim."* Token'a çevrilmelerinin sebebi renkleri değil, kapının
  /// onları GÖREBİLMESİ.
  static const Color cardWarmEnd = Color(0xFFFCF5F0);
  static const Color cardNeutralEnd = Color(0xFFF7F3F0);

  /// ⚠️ **METİN İÇİN KULLANILMAZ (L-234).** Kart üstünde 2,57:1, gradyan
  /// üstünde **2,01:1** — bu depodaki en okunmaz renkti ve tam olarak
  /// ölçüm-sınırı beyanının (açık ihlal ⑱'in kapanışı) rengiydi. Yani
  /// uygulamanın en önemli dürüstlük cümlesi, en okunmaz cümlesiydi.
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

// NOT: `LissomMono` (IBM Plex Mono token'ı) KALDIRILDI — iki ayrı kusuru
// birden taşıyordu (L-224 + L-234): ① hiçbir çağıranı yoktu, ② varsayılan
// rengi `metaMono`ydu, yani kullanılsaydı 2,57:1 ile doğardı. Ayrıca
// kullanılması `google_fonts`un ÜÇÜNCÜ bir yazı tipini çalışma anında
// indirmesine yol açardı (L-222). Tasarımın mono token'ı gerekirse geri
// gelir — ama okunabilir bir renkle ve gömülü bir yazı tipiyle.

ThemeData buildLissomTheme({
  Brightness brightness = Brightness.light,
  Locale? locale,
}) {
  final bool joinedOrDenseScript = <String>{
    'ar',
    'hi',
    'ja',
    'ko',
    'zh',
  }.contains(locale?.languageCode);
  final LissomPalette p = brightness == Brightness.dark
      ? LissomPalette.dark
      : LissomPalette.light;
  final TextTheme sans = GoogleFonts.nunitoSansTextTheme();
  final TextTheme serif = GoogleFonts.newsreaderTextTheme();

  TextStyle display(double size, {FontWeight weight = FontWeight.w300}) =>
      serif.displayLarge!.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: p.textPrimary,
        letterSpacing: joinedOrDenseScript ? 0 : -0.015 * size,
        height: joinedOrDenseScript ? 1.24 : 1.06,
      );

  TextStyle label(double size, Color color) => sans.labelLarge!.copyWith(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: joinedOrDenseScript ? 0 : 0.16 * size,
    color: color,
    height: joinedOrDenseScript ? 1.3 : 1,
  );

  final TextTheme textTheme = TextTheme(
    displayLarge: display(56),
    displayMedium: display(40),
    displaySmall: display(34),
    headlineLarge: display(30),
    headlineMedium: display(26, weight: FontWeight.w400),
    headlineSmall: display(22, weight: FontWeight.w400),
    titleLarge: sans.titleLarge!.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
    ),
    titleMedium: sans.titleMedium!.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
    ),
    titleSmall: sans.titleSmall!.copyWith(
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: p.textPrimary,
    ),
    bodyLarge: sans.bodyLarge!.copyWith(
      fontSize: 17,
      height: 1.65,
      color: p.textPrimary,
    ),
    bodyMedium: sans.bodyMedium!.copyWith(
      fontSize: 14,
      height: 1.6,
      color: p.textSecondary,
    ),
    bodySmall: sans.bodySmall!.copyWith(
      fontSize: 12.5,
      height: 1.5,
      color: p.textSecondary,
    ),
    labelLarge: label(11, p.textSecondary),
    labelMedium: label(11, p.accentText),
    labelSmall: label(10.5, p.textSecondary),
  );

  final TextStyle buttonLabel = TextStyle(
    fontFamily: textTheme.titleSmall?.fontFamily,
    fontFamilyFallback: textTheme.titleSmall?.fontFamilyFallback,
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    height: joinedOrDenseScript ? 1.4 : null,
  );
  Color filledBackground(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return p.disabledSurface;
    }
    if (states.contains(WidgetState.pressed)) {
      return p.primaryPressed;
    }
    if (states.contains(WidgetState.hovered)) {
      return p.primaryHover;
    }
    return p.primaryFill;
  }

  Color filledForeground(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled)
      ? p.disabledForeground
      : p.onPrimary;
  Color actionForeground(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled)
      ? p.disabledForeground
      : p.accentText;
  Color actionBackground(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return p.disabledSurface;
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.pressed)) {
      return p.card;
    }
    return Colors.transparent;
  }

  BorderSide actionSide(Set<WidgetState> states) => BorderSide(
    color: states.contains(WidgetState.disabled)
        ? p.disabledForeground
        : p.focusRing,
    width: states.contains(WidgetState.focused) ? 3 : 1,
  );
  final ButtonStyle actionStyle = ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(actionForeground),
    backgroundColor: WidgetStateProperty.resolveWith(actionBackground),
    overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    textStyle: WidgetStatePropertyAll<TextStyle>(buttonLabel),
    side: WidgetStateProperty.resolveWith<BorderSide?>(
      (states) => states.contains(WidgetState.focused)
          ? actionSide(states)
          : BorderSide.none,
    ),
  );

  final ColorScheme scheme =
      ColorScheme.fromSeed(
        seedColor: p.brandSeed,
        brightness: brightness,
      ).copyWith(
        primary: p.accentText,
        onPrimary: p.onPrimary,
        primaryContainer: p.selection,
        onPrimaryContainer: p.onSelection,
        secondary: p.secondary,
        onSecondary: p.onPrimary,
        tertiary: p.secondary,
        onTertiary: p.onPrimary,
        tertiaryContainer: p.secondaryContainer,
        onTertiaryContainer: p.onSecondaryContainer,
        surface: p.card,
        onSurface: p.textPrimary,
        surfaceContainerLowest: p.canvas,
        surfaceContainerLow: p.card,
        surfaceContainer: p.card,
        surfaceContainerHigh: p.cardNeutralEnd,
        surfaceContainerHighest: p.disabledSurface,
        secondaryContainer: p.secondaryContainer,
        onSecondaryContainer: p.onSecondaryContainer,
        onSurfaceVariant: p.textSecondary,
        outline: p.outline,
        outlineVariant: p.divider,
        surfaceTint: Colors.transparent,
        shadow: p.shadow,
        error: p.error,
        onError: p.onError,
        errorContainer: p.errorContainer,
        onErrorContainer: p.onErrorContainer,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    extensions: <ThemeExtension<dynamic>>[p],
    disabledColor: p.disabledForeground,
    focusColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    iconTheme: IconThemeData(color: p.textSecondary),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accentText,
      selectionColor: p.selection,
      selectionHandleColor: p.accentText,
    ),
    colorScheme: scheme,
    scaffoldBackgroundColor: p.canvas,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.textPrimary,
      systemOverlayStyle: brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: textTheme.titleLarge,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(filledBackground),
        foregroundColor: WidgetStateProperty.resolveWith(filledForeground),
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        textStyle: WidgetStatePropertyAll<TextStyle>(buttonLabel),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
          (states) =>
              states.contains(WidgetState.focused) &&
                  !states.contains(WidgetState.disabled)
              ? BorderSide(color: p.onPrimary, width: 3)
              : BorderSide.none,
        ),
      ),
    ),
    // 2026-08-12 EKLENDİ (kamera-kabuğu sevki): `OutlinedButton` üç yeni
    // ekranda belirdi (onboarding kamera adımı · canlı ölçüm "Try again" ·
    // home "See what each test measures") ve varsayılan Material3 rengi
    // BU zeminde kontrast BATIRIYORDU (`rendered_contrast_test.dart` ölçtü:
    // 2,81:1, eşik 4.5) — `roseDeepHover` [LissomColors] ZATEN bu zemin
    // için doğrulanmış vurgu-metni tonu (L-234, 4,565:1 marjlı), ikinci bir
    // renk İCAT EDİLMEDİ.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: actionStyle.copyWith(
        side: WidgetStateProperty.resolveWith(actionSide),
        padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: actionStyle),
    iconButtonTheme: IconButtonThemeData(style: actionStyle),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.selection,
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => buttonLabel.copyWith(
          color: states.contains(WidgetState.selected)
              ? p.onSelection
              : p.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? p.onSelection
              : p.textSecondary,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : states.contains(WidgetState.selected)
            ? p.onSelection
            : p.textPrimary,
      ),
      iconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : states.contains(WidgetState.selected)
            ? p.onSelection
            : p.textSecondary,
      ),
      selectedColor: p.onSelection,
      selectedTileColor: p.selection,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : states.contains(WidgetState.selected)
            ? p.accentText
            : p.outline,
      ),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledSurface
            : states.contains(WidgetState.selected)
            ? p.primaryFill
            : p.card,
      ),
      checkColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : p.onPrimary,
      ),
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? p.disabledForeground
              : states.contains(WidgetState.focused)
              ? p.focusRing
              : p.outline,
          width: states.contains(WidgetState.focused) ? 3 : 1.5,
        ),
      ),
      overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.disabled) ? p.disabledSurface : p.card,
      ),
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.disabled)
              ? p.disabledForeground
              : p.textSecondary,
        ),
      ),
      hintStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.disabled)
              ? p.disabledForeground
              : p.textSecondary,
        ),
      ),
      helperStyle: TextStyle(color: p.textSecondary),
      errorStyle: TextStyle(color: p.error),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : p.textSecondary,
      ),
      suffixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? p.disabledForeground
            : p.textSecondary,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: p.outline),
      ),
      border: OutlineInputBorder(borderSide: BorderSide(color: p.outline)),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: p.disabledForeground),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: p.focusRing, width: 3),
      ),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: p.error)),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: p.error, width: 3),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.card,
      contentTextStyle: textTheme.bodyMedium,
      actionTextColor: p.accentText,
      disabledActionTextColor: p.disabledForeground,
      closeIconColor: p.textSecondary,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: brightness,
      primaryColor: p.accentText,
      primaryContrastingColor: p.onPrimary,
      scaffoldBackgroundColor: p.canvas,
      barBackgroundColor: p.card,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(color: p.textPrimary, fontSize: 17),
        actionTextStyle: TextStyle(color: p.accentText, fontSize: 17),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.iOS: _LissomGlideTransitionsBuilder(),
        TargetPlatform.android: _LissomGlideTransitionsBuilder(),
        TargetPlatform.fuchsia: _LissomGlideTransitionsBuilder(),
        TargetPlatform.linux: _LissomGlideTransitionsBuilder(),
        TargetPlatform.macOS: _LissomGlideTransitionsBuilder(),
        TargetPlatform.windows: _LissomGlideTransitionsBuilder(),
      },
    ),
  );
}

/// Küçük oransal dikey kayma ve cross-fade. Süre PageRoute tarafından belirlenir.
/// Reduced motion görsel geçişi doğrudan atlar; 12px/520ms kabulü iddia edilmez.
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
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }
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
  Widget build(BuildContext context) {
    final p = LissomPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? p.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(LissomRadii.card),
        boxShadow: p.softShadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Locale-aware capitals for eyebrow labels. Dart's toUpperCase is locale
/// independent, so Turkish/Azerbaijani "i" became dotless "I" ("SENIN"
/// instead of "SENİN"); dotless "ı" already maps to "I".
String lissomUpperCase(String text, Locale? locale) {
  final String? language = locale?.languageCode;
  if (language == 'tr' || language == 'az') {
    return text.replaceAll('i', '\u0130').toUpperCase();
  }
  return text.toUpperCase();
}

/// Eyebrow etiket — 11px, geniş harf aralığı, büyük harf. Bölüm başlıkları ve
/// "MEASURED", "Not measured" gibi durum etiketleri bu stili paylaşır.
class LissomEyebrow extends StatelessWidget {
  const LissomEyebrow(this.text, {this.color, super.key});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    lissomUpperCase(text, Localizations.maybeLocaleOf(context)),
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: color ?? LissomPalette.of(context).textSecondary,
    ),
  );
}

/// Visible focus for custom tappable cards. The Focus node does not add a tab
/// stop; descendant InkWell retains its existing activation and semantics.
class LissomFocusFrame extends StatefulWidget {
  const LissomFocusFrame({required this.child, super.key});
  final Widget child;
  @override
  State<LissomFocusFrame> createState() => _LissomFocusFrameState();
}

class _LissomFocusFrameState extends State<LissomFocusFrame> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onFocusChange: (value) {
      if (mounted) {
        setState(() => _focused = value);
      }
    },
    child: DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LissomRadii.card),
        border: _focused
            ? Border.all(color: LissomPalette.of(context).focusRing, width: 3)
            : null,
      ),
      child: widget.child,
    ),
  );
}

class LissomLoadingIndicator extends StatelessWidget {
  const LissomLoadingIndicator({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    liveRegion: true,
    child: ExcludeSemantics(
      child: MediaQuery.disableAnimationsOf(context)
          ? Icon(
              Icons.hourglass_empty,
              color: LissomPalette.of(context).textSecondary,
            )
          : CircularProgressIndicator(
              color: LissomPalette.of(context).accentText,
            ),
    ),
  );
}
