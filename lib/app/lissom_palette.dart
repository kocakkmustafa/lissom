// DRAFT ONLY. NOT APPLIED OR SDK-CHECKED. Palette semantics; no global mutable state.
import 'package:flutter/material.dart';

@immutable
final class LissomPalette extends ThemeExtension<LissomPalette> {
  const LissomPalette({
    required this.canvas,
    required this.card,
    required this.cardWarmEnd,
    required this.cardNeutralEnd,
    required this.screenStart,
    required this.screenMiddle,
    required this.screenEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentText,
    required this.brandSeed,
    required this.primaryFill,
    required this.primaryHover,
    required this.primaryPressed,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.bannerStart,
    required this.bannerEnd,
    required this.onBanner,
    required this.outline,
    required this.divider,
    required this.focusRing,
    required this.disabledSurface,
    required this.disabledForeground,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.markerFill,
    required this.onMarker,
    required this.selection,
    required this.onSelection,
    required this.shadow,
    required this.onError,
  });

  final Color canvas;
  final Color card;
  final Color cardWarmEnd;
  final Color cardNeutralEnd;
  final Color screenStart;
  final Color screenMiddle;
  final Color screenEnd;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentText;
  final Color brandSeed;
  final Color primaryFill;
  final Color primaryHover;
  final Color primaryPressed;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color bannerStart;
  final Color bannerEnd;
  final Color onBanner;
  final Color outline;
  final Color divider;
  final Color focusRing;
  final Color disabledSurface;
  final Color disabledForeground;
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color markerFill;
  final Color onMarker;
  final Color selection;
  final Color onSelection;
  final Color shadow;
  final Color onError;

  static const LissomPalette light = LissomPalette(
    canvas: Color(0xFFF3EDE9),
    card: Color(0xFFFFFCFA),
    cardWarmEnd: Color(0xFFFCF5F0),
    cardNeutralEnd: Color(0xFFF7F3F0),
    screenStart: Color(0xFFFBF3EE),
    screenMiddle: Color(0xFFF5E8E4),
    screenEnd: Color(0xFFEEDDE7),
    textPrimary: Color(0xFF38313A),
    textSecondary: Color(0xFF6B6069),
    accentText: Color(0xFF86556D),
    brandSeed: Color(0xFFB0748F),
    primaryFill: Color(0xFF9C677F),
    primaryHover: Color(0xFF8F5C74),
    primaryPressed: Color(0xFF815269),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF476277),
    secondaryContainer: Color(0xFFBACDDE),
    onSecondaryContainer: Color(0xFF38313A),
    bannerStart: Color(0xFFF5E6D0),
    bannerEnd: Color(0xFFF0C4A8),
    onBanner: Color(0xFF38313A),
    outline: Color(0xFF877783),
    divider: Color(0xFFF2EBEC),
    focusRing: Color(0xFF86556D),
    disabledSurface: Color(0xFFE2D8DE),
    disabledForeground: Color(0xFF685B65),
    error: Color(0xFF9E263E),
    errorContainer: Color(0xFFFCE4E8),
    onErrorContainer: Color(0xFF7C1631),
    markerFill: Color(0xFF38313A),
    onMarker: Color(0xFFFFFFFF),
    selection: Color(0xFFE0BFD0),
    onSelection: Color(0xFF38313A),
    shadow: Color(0x33584050),
    onError: Color(0xFFFFFFFF),
  );

  static const LissomPalette dark = LissomPalette(
    canvas: Color(0xFF211B22),
    card: Color(0xFF2D252E),
    cardWarmEnd: Color(0xFF35282E),
    cardNeutralEnd: Color(0xFF312A32),
    screenStart: Color(0xFF1B171C),
    screenMiddle: Color(0xFF241D25),
    screenEnd: Color(0xFF2D2230),
    textPrimary: Color(0xFFF6EEE8),
    textSecondary: Color(0xFFD2C2CC),
    accentText: Color(0xFFEDB5D0),
    brandSeed: Color(0xFFB0748F),
    primaryFill: Color(0xFFD7A6BC),
    primaryHover: Color(0xFFE3B6CA),
    primaryPressed: Color(0xFFC994AE),
    onPrimary: Color(0xFF2D1B28),
    secondary: Color(0xFFAAC4D9),
    secondaryContainer: Color(0xFF30414F),
    onSecondaryContainer: Color(0xFFD8E9F5),
    bannerStart: Color(0xFF50323D),
    bannerEnd: Color(0xFF3D2D2D),
    onBanner: Color(0xFFF6EEE8),
    outline: Color(0xFFA493A2),
    divider: Color(0xFF4A3A47),
    focusRing: Color(0xFFEDB5D0),
    disabledSurface: Color(0xFF433744),
    disabledForeground: Color(0xFFCABAC6),
    error: Color(0xFFFFB0BA),
    errorContainer: Color(0xFF542C39),
    onErrorContainer: Color(0xFFFFD8DF),
    markerFill: Color(0xFFF6EEE8),
    onMarker: Color(0xFF2D252E),
    selection: Color(0xFF604355),
    onSelection: Color(0xFFF6EEE8),
    shadow: Color(0x66000000),
    onError: Color(0xFF2D252E),
  );

  static LissomPalette of(BuildContext context) {
    return fromTheme(Theme.of(context));
  }

  // Standalone widget/test callers may use a stock MaterialApp. Production
  // entry surfaces still register and test the extension explicitly.
  static LissomPalette fromTheme(ThemeData theme) =>
      theme.extension<LissomPalette>() ??
      (theme.brightness == Brightness.dark ? dark : light);

  LinearGradient get screenBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[screenStart, screenMiddle, screenEnd],
    stops: const <double>[0, .46, 1],
  );
  LinearGradient get warmCardBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[card, cardWarmEnd],
  );
  LinearGradient get neutralCardBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[card, cardNeutralEnd],
  );
  LinearGradient get declarationBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[bannerStart, bannerEnd],
  );
  List<BoxShadow> get softShadow => <BoxShadow>[
    BoxShadow(
      color: shadow,
      blurRadius: 44,
      offset: const Offset(0, 22),
      spreadRadius: -18,
    ),
  ];

  @override
  LissomPalette copyWith({
    Color? canvas,
    Color? card,
    Color? cardWarmEnd,
    Color? cardNeutralEnd,
    Color? screenStart,
    Color? screenMiddle,
    Color? screenEnd,
    Color? textPrimary,
    Color? textSecondary,
    Color? accentText,
    Color? brandSeed,
    Color? primaryFill,
    Color? primaryHover,
    Color? primaryPressed,
    Color? onPrimary,
    Color? secondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? bannerStart,
    Color? bannerEnd,
    Color? onBanner,
    Color? outline,
    Color? divider,
    Color? focusRing,
    Color? disabledSurface,
    Color? disabledForeground,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? markerFill,
    Color? onMarker,
    Color? selection,
    Color? onSelection,
    Color? shadow,
    Color? onError,
  }) => LissomPalette(
    canvas: canvas ?? this.canvas,
    card: card ?? this.card,
    cardWarmEnd: cardWarmEnd ?? this.cardWarmEnd,
    cardNeutralEnd: cardNeutralEnd ?? this.cardNeutralEnd,
    screenStart: screenStart ?? this.screenStart,
    screenMiddle: screenMiddle ?? this.screenMiddle,
    screenEnd: screenEnd ?? this.screenEnd,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    accentText: accentText ?? this.accentText,
    brandSeed: brandSeed ?? this.brandSeed,
    primaryFill: primaryFill ?? this.primaryFill,
    primaryHover: primaryHover ?? this.primaryHover,
    primaryPressed: primaryPressed ?? this.primaryPressed,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
    bannerStart: bannerStart ?? this.bannerStart,
    bannerEnd: bannerEnd ?? this.bannerEnd,
    onBanner: onBanner ?? this.onBanner,
    outline: outline ?? this.outline,
    divider: divider ?? this.divider,
    focusRing: focusRing ?? this.focusRing,
    disabledSurface: disabledSurface ?? this.disabledSurface,
    disabledForeground: disabledForeground ?? this.disabledForeground,
    error: error ?? this.error,
    errorContainer: errorContainer ?? this.errorContainer,
    onErrorContainer: onErrorContainer ?? this.onErrorContainer,
    markerFill: markerFill ?? this.markerFill,
    onMarker: onMarker ?? this.onMarker,
    selection: selection ?? this.selection,
    onSelection: onSelection ?? this.onSelection,
    shadow: shadow ?? this.shadow,
    onError: onError ?? this.onError,
  );

  @override
  LissomPalette lerp(covariant LissomPalette? other, double t) {
    if (other == null) {
      return this;
    }
    return LissomPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardWarmEnd: Color.lerp(cardWarmEnd, other.cardWarmEnd, t)!,
      cardNeutralEnd: Color.lerp(cardNeutralEnd, other.cardNeutralEnd, t)!,
      screenStart: Color.lerp(screenStart, other.screenStart, t)!,
      screenMiddle: Color.lerp(screenMiddle, other.screenMiddle, t)!,
      screenEnd: Color.lerp(screenEnd, other.screenEnd, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      brandSeed: Color.lerp(brandSeed, other.brandSeed, t)!,
      primaryFill: Color.lerp(primaryFill, other.primaryFill, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      bannerStart: Color.lerp(bannerStart, other.bannerStart, t)!,
      bannerEnd: Color.lerp(bannerEnd, other.bannerEnd, t)!,
      onBanner: Color.lerp(onBanner, other.onBanner, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      disabledSurface: Color.lerp(disabledSurface, other.disabledSurface, t)!,
      disabledForeground: Color.lerp(
        disabledForeground,
        other.disabledForeground,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(
        onErrorContainer,
        other.onErrorContainer,
        t,
      )!,
      markerFill: Color.lerp(markerFill, other.markerFill, t)!,
      onMarker: Color.lerp(onMarker, other.onMarker, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      onSelection: Color.lerp(onSelection, other.onSelection, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
    );
  }
}
