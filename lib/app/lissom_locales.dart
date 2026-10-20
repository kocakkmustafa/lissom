import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart'
    show visibleForTesting, FlutterError, FlutterErrorDetails, ErrorDescription;
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
  Locale('it'),
  Locale('ko'),
  Locale('id'),
  Locale('pl'),
  Locale('hi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
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
  'it': 'Italiano',
  'ko': '한국어',
  'id': 'Bahasa Indonesia',
  'pl': 'Polski',
  'hi': 'हिन्दी',
  'zh-Hans': '简体中文',
};

/// Resolve only the approved script/dialects. Traditional Chinese is not
/// presented as a translated Simplified Chinese interface.
Locale? _supportedDeviceLocale(Locale locale) {
  final String language = locale.languageCode;
  if (language == 'zh') {
    final String? script = locale.scriptCode;
    if (script != null && script != 'Hans') return null;
    if (script == null &&
        const <String>{'TW', 'HK', 'MO'}.contains(locale.countryCode)) {
      return null;
    }
    return const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  }
  return switch (language) {
    'es' => const Locale('es', '419'),
    'pt' => const Locale('pt', 'BR'),
    'en' ||
    'tr' ||
    'de' ||
    'fr' ||
    'ja' ||
    'ar' ||
    'it' ||
    'ko' ||
    'id' ||
    'pl' ||
    'hi' => Locale(language),
    _ => null,
  };
}

bool isLissomLocaleSupported(Locale locale) =>
    _supportedDeviceLocale(locale) != null;

String canonicalLocaleTag(Locale locale) =>
    (_supportedDeviceLocale(locale) ?? const Locale('en')).toLanguageTag();

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
    final Locale? supported = _supportedDeviceLocale(locale);
    if (supported != null) return supported;
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
    this.readDeadline = const Duration(seconds: 2),
  }) : _store = store,
       _openStore = openStore ?? FileLocalePreferenceStore.open;

  LocalePreferenceStore? _store;
  final Future<LocalePreferenceStore> Function() _openStore;
  final Duration readDeadline;
  Future<void>? _initialization;
  int _readGeneration = 0;
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
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> initialize() {
    if (_disposed) {
      return Future<void>.value();
    }
    return _initialization ??= _load();
  }

  Future<void> _load() async {
    final int generation = ++_readGeneration;
    try {
      // Open + read share one UI bootstrap deadline. Keep all results local:
      // late IO may finish, but cannot rewrite controller state or its store.
      final result = await (() async {
        final LocalePreferenceStore store = _store ?? await _openStore();
        final String? value = await store.read();
        if (value != null && lissomLocaleForTag(value) == null) {
          throw const FormatException('Unsupported locale preference');
        }
        return (store, value);
      })().timeout(readDeadline);
      if (_disposed || generation != _readGeneration) {
        return;
      }
      _store = result.$1;
      _tag = result.$2;
      _readFailed = false;
    } on Object {
      if (_disposed || generation != _readGeneration) {
        return;
      }
      // Initial null means the visible existing system-language fallback.
      // Do not delete or overwrite unreadable preference bytes.
      _readFailed = true;
    } finally {
      if (!_disposed && generation == _readGeneration) {
        _ready = true;
        _changed();
      }
    }
  }

  Future<bool> select(String? tag) async {
    if (!_ready || _saving || _disposed) {
      return false;
    }
    if (tag != null && lissomLocaleForTag(tag) == null) {
      throw ArgumentError.value(tag, 'tag', 'Unsupported product locale');
    }
    ++_readGeneration;
    _saving = true;
    _writeFailed = false;
    _changed();
    try {
      final LocalePreferenceStore store = _store ?? await _openStore();
      // Retirement while opening must not admit a new preference mutation.
      if (_disposed) {
        return false;
      }
      _store = store;
      // No timeout/cancel/blind retry for an already-admitted file write.
      await store.write(tag);
      if (_disposed) {
        return false;
      }
      _tag = tag;
      _readFailed = false;
      return true;
    } on Object {
      if (!_disposed) {
        _writeFailed = true;
      }
      return false;
    } finally {
      _saving = false;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_readGeneration;
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
/// The first controller and its ownership are fixed for this State lifetime.
/// Replacing it requires a new host Key and an intentional new child lifetime.
/// Same-key argument changes keep the initial controller and report a diagnostic
/// in profile/release too. A caller-provided controller stays caller-owned.
class LissomLocaleHost extends StatefulWidget {
  const LissomLocaleHost({required this.child, this.controller, super.key})
    : createController = null;

  @visibleForTesting
  const LissomLocaleHost.owned({
    required this.child,
    required this.createController,
    super.key,
  }) : controller = null;

  final Widget child;
  final LissomLocaleController? controller;
  final LissomLocaleController Function()? createController;

  @override
  State<LissomLocaleHost> createState() => _LissomLocaleHostState();
}

class _LissomLocaleHostState extends State<LissomLocaleHost> {
  late final bool _ownsController;
  late final LissomLocaleController _controller;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        widget.createController?.call() ??
        LissomLocaleController();
    unawaited(_controller.initialize());
  }

  @override
  void didUpdateWidget(LissomLocaleHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller) ||
        !identical(oldWidget.createController, widget.createController)) {
      // This is an integration diagnostic, not a localized product error.
      // It contains no raw IO, preference value or account information.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError(
            'LissomLocaleHost controller lifetime is immutable. '
            'The initial controller remains active. Use a new host Key to '
            'replace it intentionally.',
          ),
          library: 'Lissom language',
          context: ErrorDescription(
            'while updating an installation locale host',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) => !_controller.isReady
        ? const SizedBox.shrink(key: Key('locale.bootstrap.pending'))
        : LissomLocaleScope(controller: _controller, child: child!),
  );
}
