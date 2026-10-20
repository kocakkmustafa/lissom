import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Product locales. Dialects remain explicit instead of following an account.
const List<Locale> kLissomSupportedLocales = <Locale>[
  Locale('en'),
  Locale('tr'),
  Locale('es', '419'),
  Locale('pt', 'BR'),
  Locale('de'),
  Locale('fr'),
  Locale('ja'),
  Locale('ar'),
];

const Map<String, String> kLissomLanguageNames = <String, String>{
  'en': 'English',
  'tr': 'Türkçe',
  'es-419': 'Español (Latinoamérica)',
  'pt-BR': 'Português (Brasil)',
  'de': 'Deutsch',
  'fr': 'Français',
  'ja': '日本語',
  'ar': 'العربية',
};

String canonicalLocaleTag(Locale locale) => switch (locale.languageCode) {
  'es' => 'es-419',
  'pt' => 'pt-BR',
  'tr' || 'de' || 'fr' || 'ja' || 'ar' => locale.languageCode,
  _ => 'en',
};

Locale? lissomLocaleForTag(String? tag) {
  if (tag == null) return null;
  for (final Locale locale in kLissomSupportedLocales) {
    if (canonicalLocaleTag(locale) == tag) return locale;
  }
  return null;
}

/// Respect device preference order and use only the approved product dialects.
Locale resolveLissomLocale(List<Locale>? requested, Iterable<Locale> _) {
  for (final Locale locale in requested ?? const <Locale>[]) {
    if (kLissomSupportedLocales.any(
      (Locale supported) => supported.languageCode == locale.languageCode,
    )) {
      return lissomLocaleForTag(canonicalLocaleTag(locale))!;
    }
  }
  return const Locale('en');
}

abstract interface class LocalePreferenceStore {
  Future<String?> read();
  Future<void> write(String? tag);
}

/// Installation preference only. It never opens an owner or practice journal.
final class FileLocalePreferenceStore implements LocalePreferenceStore {
  FileLocalePreferenceStore(this.file);

  final File file;

  static Future<LocalePreferenceStore> open() async {
    final Directory support = await getApplicationSupportDirectory();
    return FileLocalePreferenceStore(
      File('${support.path}/lissom-preferences/locale.v1.json'),
    );
  }

  @override
  Future<String?> read() async {
    if (!await file.exists()) return null;
    final Object? decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map || decoded['schemaVersion'] != 1) {
      throw const FormatException('Unsupported locale preference');
    }
    final Object? tag = decoded['locale'];
    if (tag == 'system') return null;
    if (tag is! String || lissomLocaleForTag(tag) == null) {
      throw const FormatException('Unsupported locale preference');
    }
    return tag;
  }

  @override
  Future<void> write(String? tag) async {
    if (tag != null && lissomLocaleForTag(tag) == null) {
      throw ArgumentError.value(tag, 'tag', 'Unsupported product locale');
    }
    await file.parent.create(recursive: true);
    final File pending = File('${file.path}.pending');
    await pending.writeAsString(
      jsonEncode(<String, Object>{
        'schemaVersion': 1,
        'locale': tag ?? 'system',
      }),
      flush: true,
    );
    // The previous preference survives a failed write before replacement.
    await pending.rename(file.path);
  }
}

/// Changes take effect after persistence, so a failed write cannot look saved.
final class LissomLocaleController extends ChangeNotifier {
  LissomLocaleController({
    LocalePreferenceStore? store,
    Future<LocalePreferenceStore> Function()? openStore,
  }) : _store = store,
       _openStore = openStore ?? FileLocalePreferenceStore.open;

  LocalePreferenceStore? _store;
  final Future<LocalePreferenceStore> Function() _openStore;
  Future<void>? _initialization;
  String? _tag;
  bool _disposed = false;
  bool _ready = false;
  bool _saving = false;
  bool _readFailed = false;
  bool _writeFailed = false;

  String? get tag => _tag;
  Locale? get locale => lissomLocaleForTag(_tag);
  bool get isReady => _ready;
  bool get isSaving => _saving;
  bool get readFailed => _readFailed;
  bool get writeFailed => _writeFailed;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() => _initialization ??= _load();

  Future<void> _load() async {
    try {
      final LocalePreferenceStore store = _store ??= await _openStore();
      final String? value = await store.read();
      if (value != null && lissomLocaleForTag(value) == null) {
        throw const FormatException('Unsupported locale preference');
      }
      _tag = value;
      _readFailed = false;
    } on Object {
      _tag = null;
      _readFailed = true;
    } finally {
      _ready = true;
      _changed();
    }
  }

  Future<bool> select(String? tag) async {
    if (!_ready || _saving || _disposed) return false;
    if (tag != null && lissomLocaleForTag(tag) == null) {
      throw ArgumentError.value(tag, 'tag', 'Unsupported product locale');
    }
    _saving = true;
    _writeFailed = false;
    _changed();
    try {
      final LocalePreferenceStore store = _store ??= await _openStore();
      await store.write(tag);
      _tag = tag;
      _readFailed = false;
      return true;
    } on Object {
      _writeFailed = true;
      return false;
    } finally {
      _saving = false;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class LissomLocaleScope extends InheritedNotifier<LissomLocaleController> {
  const LissomLocaleScope({
    required LissomLocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LissomLocaleController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LissomLocaleScope>()?.notifier;
}

/// Above account gates and keyed owner navigators: switching users does not
/// switch installation language or move preference bytes between accounts.
class LissomLocaleHost extends StatefulWidget {
  const LissomLocaleHost({required this.child, this.controller, super.key});

  final Widget child;
  final LissomLocaleController? controller;

  @override
  State<LissomLocaleHost> createState() => _LissomLocaleHostState();
}

class _LissomLocaleHostState extends State<LissomLocaleHost> {
  late final LissomLocaleController _controller =
      widget.controller ?? LissomLocaleController();

  @override
  void initState() {
    super.initState();
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LissomLocaleScope(controller: _controller, child: widget.child);
}
