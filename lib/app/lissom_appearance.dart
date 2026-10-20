// DRAFT ONLY: not applied, formatted, analyzed, or tested by Flutter.
// Installation preference, above all account/owner lifetimes.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

abstract interface class AppearancePreferenceStore {
  Future<ThemeMode> read();
  Future<void> write(ThemeMode mode);
}

final class FileAppearancePreferenceStore implements AppearancePreferenceStore {
  FileAppearancePreferenceStore(this.file);
  final File file;

  static Future<AppearancePreferenceStore> open() async {
    final support = await getApplicationSupportDirectory();
    return FileAppearancePreferenceStore(
      File('${support.path}/lissom-preferences/appearance.v1.json'),
    );
  }

  static ThemeMode parse(String value) => switch (value) {
    'system' => ThemeMode.system,
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => throw const FormatException('Unsupported appearance'),
  };

  @override
  Future<ThemeMode> read() async {
    if (!await file.exists()) {
      return ThemeMode.system;
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map ||
        decoded['schemaVersion'] != 1 ||
        decoded['mode'] is! String) {
      throw const FormatException('Unsupported appearance preference');
    }
    return parse(decoded['mode'] as String);
  }

  @override
  Future<void> write(ThemeMode mode) async {
    await file.parent.create(recursive: true);
    final pending = File('${file.path}.pending');
    await pending.writeAsString(
      jsonEncode(<String, Object>{'schemaVersion': 1, 'mode': mode.name}),
      flush: true,
    );
    await pending.rename(file.path);
  }
}

final class LissomAppearanceController extends ChangeNotifier {
  LissomAppearanceController({
    AppearancePreferenceStore? store,
    Future<AppearancePreferenceStore> Function()? openStore,
    this.readDeadline = const Duration(seconds: 2),
  }) : _store = store,
       _openStore = openStore ?? FileAppearancePreferenceStore.open;

  AppearancePreferenceStore? _store;
  final Future<AppearancePreferenceStore> Function() _openStore;
  final Duration readDeadline;
  ThemeMode _mode = ThemeMode.system;
  bool _ready = false;
  bool _saving = false;
  bool _disposed = false;
  bool _readFailed = false;
  bool _writeFailed = false;
  bool _reading = false;
  bool _writePendingLong = false;
  Timer? _writeNotice;
  int _readGeneration = 0;
  Future<void>? _initialization;

  ThemeMode get mode => _mode;
  bool get isReady => _ready;
  bool get isSaving => _saving;
  bool get readFailed => _readFailed;
  bool get writeFailed => _writeFailed;
  bool get isReading => _reading;
  bool get writePendingLong => _writePendingLong;

  void _changed() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> initialize() => _initialization ??= _load();

  Future<void> retryRead() {
    if (_saving || _reading || _disposed) {
      return Future<void>.value();
    }
    return _load();
  }

  Future<void> _load() async {
    final generation = ++_readGeneration;
    _reading = true;
    _changed();
    try {
      final result = await (() async {
        final store = _store ?? await _openStore();
        final mode = await store.read();
        return (store, mode);
      })().timeout(readDeadline);
      if (_disposed || generation != _readGeneration) {
        return;
      }
      _store = result.$1;
      _mode = result.$2;
      _readFailed = false;
    } on Object {
      if (_disposed || generation != _readGeneration) {
        return;
      }
      // Does not delete/replace unreadable preference or inspect owner data.
      // On first boot system is the honest fallback; retry keeps last mode.
      _readFailed = true;
    } finally {
      if (!_disposed && generation == _readGeneration) {
        _ready = true;
        _reading = false;
        _changed();
      }
    }
  }

  Future<bool> select(ThemeMode mode) async {
    if (!_ready || _reading || _saving || _disposed) {
      return false;
    }
    ++_readGeneration;
    _saving = true;
    _writeFailed = false;
    _writePendingLong = false;
    _writeNotice = Timer(const Duration(seconds: 3), () {
      if (_disposed || !_saving) {
        return;
      }
      _writePendingLong = true;
      _changed();
    });
    _changed();
    try {
      final store = _store ??= await _openStore();
      // A reopened store may finish after the controller was retired.
      // Guard admission before any new write; an already-started write is
      // deliberately not claimed cancelable.
      if (_disposed) {
        return false;
      }
      // No blind timeout/retry of an unfinished write: it could overwrite a
      // newer choice later. A separate bounded-UI/uncertain-write design is
      // an explicit acceptance item, not silently claimed solved here.
      await store.write(mode);
      if (_disposed) {
        return false;
      }
      _mode = mode;
      _readFailed = false;
      return true;
    } on Object {
      if (!_disposed) {
        _writeFailed = true;
      }
      return false;
    } finally {
      _writeNotice?.cancel();
      _writeNotice = null;
      _saving = false;
      _writePendingLong = false;
      _changed();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _writeNotice?.cancel();
    ++_readGeneration;
    super.dispose();
  }
}

final class LissomAppearanceScope
    extends InheritedNotifier<LissomAppearanceController> {
  const LissomAppearanceScope({
    required LissomAppearanceController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static LissomAppearanceController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LissomAppearanceScope>()!
      .notifier!;

  static LissomAppearanceController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LissomAppearanceScope>()
      ?.notifier;
}

// Production preloads the controller before runApp. The gate also makes
// delayed injected/test bootstrap safe: no themed app is built before ready.
// Retrying a failed read never tears down an already-mounted owner subtree.
// Controller identity and ownership are fixed at State creation. Replacing a
// controller requires a new host Key (and therefore an intentional new child
// lifetime). Same-key argument changes retain the first controller and report
// a diagnostic in release/profile too; they never silently transfer ownership.
final class LissomAppearanceHost extends StatefulWidget {
  const LissomAppearanceHost({required this.child, this.controller, super.key})
    : createController = null;

  // Deterministic ownership tests use a memory store without a native plugin.
  // Production keeps the normal constructor and default file-backed instance.
  @visibleForTesting
  const LissomAppearanceHost.owned({
    required this.child,
    required this.createController,
    super.key,
  }) : controller = null;

  final Widget child;
  final LissomAppearanceController? controller;
  final LissomAppearanceController Function()? createController;

  @override
  State<LissomAppearanceHost> createState() => _LissomAppearanceHostState();
}

final class _LissomAppearanceHostState extends State<LissomAppearanceHost> {
  late final bool _ownsController;
  late final LissomAppearanceController _controller;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        widget.createController?.call() ??
        LissomAppearanceController();
    unawaited(_controller.initialize());
  }

  @override
  void didUpdateWidget(LissomAppearanceHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller) ||
        !identical(oldWidget.createController, widget.createController)) {
      // This diagnostic is not behind assert: profile/release must not silently
      // imply a rebind. No controller value, raw storage error or account data
      // is included, and the diagnostic is never rendered as product UI.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: StateError(
            'LissomAppearanceHost controller lifetime is immutable. '
            'The initial controller remains active. Use a new host Key to '
            'replace it intentionally.',
          ),
          library: 'Lissom appearance',
          context: ErrorDescription('while updating an appearance host'),
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
        ? const SizedBox.shrink(key: Key('appearance.bootstrap.pending'))
        : LissomAppearanceScope(controller: _controller, child: child!),
  );
}

// Integration contract, to implement in root's single-writer source window:
// 1. WidgetsFlutterBinding.ensureInitialized().
// 2. final appearance = LissomAppearanceController();
// 3. await appearance.initialize(); // before the first themed Flutter frame.
// 4. runApp(LissomAppearanceHost(controller: appearance,
//      child: LissomLocaleHost(child: LissomPresentationHost(
//        child: currentAccountOrGuestHost))));
// 5. Every MaterialApp uses theme, darkTheme, themeMode from this scope;
//    themeAnimationDuration: Duration.zero prevents theme-lerp contrast dips.
// 6. Bootstrap failure is visible in the real localized Profile card + Retry.
//    No fake "saved" toast; selection changes only after persisted success.
// Native launch screen precedes Flutter and cannot read this JSON preference:
// first-Frame correctness does not establish native launch flash acceptance.
