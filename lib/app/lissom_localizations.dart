import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lissom_locales.dart';

/// Source-English keys are shared by UI, config and unchanged course content.
/// Unknown keys remain readable in English; unavailable catalogs are visible
/// in the language settings and never counted as translated acceptance.
final class LissomLocalizations {
  LissomLocalizations._(this.tag, this.messages, this.catalogAvailable);

  factory LissomLocalizations.parse(String raw, String tag) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map ||
        decoded['schemaVersion'] != 1 ||
        decoded['id'] != 'lissom.l10n.$tag' ||
        decoded['locale'] != tag ||
        decoded['messages'] is! Map) {
      throw const FormatException('Invalid localization catalog');
    }
    final Map<String, Object> messages = <String, Object>{};
    for (final MapEntry<dynamic, dynamic> entry
        in (decoded['messages'] as Map).entries) {
      if (entry.key is! String || (entry.key as String).trim().isEmpty) {
        throw const FormatException('Invalid localization source key');
      }
      final String source = entry.key as String;
      final Object? translation = entry.value;
      if (translation is String && translation.trim().isNotEmpty) {
        _checkArguments(source, translation);
        messages[source] = translation;
      } else if (translation is Map && translation['other'] is String) {
        final Map<String, String> forms = <String, String>{};
        for (final MapEntry<dynamic, dynamic> form in translation.entries) {
          if (!const <String>{
                'zero',
                'one',
                'two',
                'few',
                'many',
                'other',
              }.contains(form.key) ||
              form.value is! String ||
              (form.value as String).trim().isEmpty) {
            throw const FormatException('Invalid plural localization');
          }
          _checkArguments(source, form.value as String);
          forms[form.key as String] = form.value as String;
        }
        messages[source] = Map<String, String>.unmodifiable(forms);
      } else {
        throw const FormatException('Invalid localization value');
      }
    }
    return LissomLocalizations._(
      tag,
      Map<String, Object>.unmodifiable(messages),
      true,
    );
  }

  factory LissomLocalizations.unavailable(String tag) =>
      LissomLocalizations._(tag, const <String, Object>{}, false);

  final String tag;
  final Map<String, Object> messages;
  final bool catalogAvailable;

  static LissomLocalizations? maybeOf(BuildContext context) =>
      Localizations.of<LissomLocalizations>(context, LissomLocalizations);

  String? lookup(String source, {String? pluralCategory}) {
    final Object? value = messages[source];
    if (value is String) return value;
    if (value is Map<String, String>) {
      return value[pluralCategory ?? 'other'] ?? value['other'];
    }
    return null;
  }

  static Set<String> argumentsOf(String template) => RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)\}',
  ).allMatches(template).map((RegExpMatch match) => match.group(1)!).toSet();

  static void _checkArguments(String source, String translation) {
    Map<String, int> counts(String template) {
      final Map<String, int> result = <String, int>{};
      for (final RegExpMatch match in RegExp(
        r'\{([A-Za-z][A-Za-z0-9_]*)\}',
      ).allMatches(template)) {
        result.update(
          match.group(1)!,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      return result;
    }

    if (!mapEquals(counts(source), counts(translation))) {
      throw const FormatException('Localization placeholders differ');
    }
  }
}

class LissomLocalizationsDelegate
    extends LocalizationsDelegate<LissomLocalizations> {
  const LissomLocalizationsDelegate({this.bundle});

  final AssetBundle? bundle;

  @override
  bool isSupported(Locale locale) => kLissomSupportedLocales.any(
    (Locale supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<LissomLocalizations> load(Locale locale) async {
    final String tag = canonicalLocaleTag(locale);
    try {
      return LissomLocalizations.parse(
        await (bundle ?? rootBundle).loadString('config/l10n/$tag.json'),
        tag,
      );
    } on Object {
      return LissomLocalizations.unavailable(tag);
    }
  }

  @override
  bool shouldReload(LissomLocalizationsDelegate old) => old.bundle != bundle;
}

String localizedInteger(BuildContext context, int number) {
  final MaterialLocalizations? material =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  return material?.formatDecimal(number) ?? number.toString();
}

/// Keeps the existing measurement precision; changes display separators only.
/// Numeric storage, reference ranges and units remain unmodified.
String localizedDecimal(
  BuildContext context,
  double number, {
  int fractionDigits = 1,
}) {
  if (fractionDigits < 0 || fractionDigits > 6) {
    throw ArgumentError.value(fractionDigits, 'fractionDigits');
  }
  if (!number.isFinite) return '—';
  // Native int.parse has an int64 ceiling. A corrupt/legacy finite value
  // must remain displayable instead of throwing while opening its history.
  if (number.abs() >= 1e18) return localizedConfigNumber(context, number);
  final List<String> parts = number
      .abs()
      .toStringAsFixed(fractionDigits)
      .split('.');
  final String integer = localizedInteger(context, int.parse(parts[0]));
  final String one = localizedInteger(context, 1);
  final String negativeOne = localizedInteger(context, -1);
  final String minus = negativeOne.endsWith(one)
      ? negativeOne.substring(0, negativeOne.length - one.length)
      : '-';
  final String sign = number < 0 ? minus : '';
  if (parts.length == 1) return '$sign$integer';
  final String fraction = parts[1]
      .split('')
      .map((String digit) => localizedInteger(context, int.parse(digit)))
      .join();
  final String tag = canonicalLocaleTag(Localizations.localeOf(context));
  final String separator = switch (tag) {
    'tr' || 'pt-BR' || 'de' || 'fr' => ',',
    _ => '.',
  };
  return '$sign$integer$separator$fraction';
}

/// Configuration bounds keep their source precision, including fractional
/// tolerances. Only decimal separators/digits change; no bound is rounded.
String localizedConfigNumber(BuildContext context, num number) {
  if (!number.isFinite) return '—';
  final String tag = canonicalLocaleTag(Localizations.localeOf(context));
  final String separator = switch (tag) {
    'tr' || 'pt-BR' || 'de' || 'fr' => ',',
    _ => '.',
  };
  return number.toString().split('').map((String character) {
    if (character == '.') return separator;
    final int? digit = int.tryParse(character);
    return digit == null ? character : localizedInteger(context, digit);
  }).join();
}

String localizedDate(BuildContext context, DateTime date) {
  final MaterialLocalizations? material =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  final DateTime local = date.toLocal();
  // Material's medium date deliberately omits the year. A historical journal
  // needs the full local calendar date, including its year.
  return material?.formatFullDate(local) ??
      '${local.year}-${local.month.toString().padLeft(2, '0')}-'
          '${local.day.toString().padLeft(2, '0')}';
}

/// Integer count categories for the eight fixed product locales. Non-integer
/// measurements never use grammatical count/plural selection.
String lissomPluralCategory(String tag, int count) {
  final int n = count.abs();
  if (tag == 'ja') return 'other';
  if (tag == 'ar') {
    if (n == 0) return 'zero';
    if (n == 1) return 'one';
    if (n == 2) return 'two';
    if (n % 100 >= 3 && n % 100 <= 10) return 'few';
    if (n % 100 >= 11 && n % 100 <= 99) return 'many';
    return 'other';
  }
  if ((tag == 'es-419' || tag == 'fr' || tag == 'pt-BR') &&
      n != 0 &&
      n % 1000000 == 0) {
    return 'many';
  }
  if (tag == 'fr' || tag == 'pt-BR') return n <= 1 ? 'one' : 'other';
  return n == 1 ? 'one' : 'other';
}
