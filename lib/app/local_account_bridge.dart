import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'local_write_guard.dart';
import 'local_owner.dart';

/// Must match the app identifier used by the shared Motion entitlement table.
const String kLissomMotionAppId = 'lissom';

/// The host supplies the real account page when the shared package is pinned.
/// No account action is shown until this builder is provided.
typedef LissomAccountRouteBuilder =
    Widget Function(BuildContext context, String appId);

enum LissomLocalFile {
  onboarding('onboarding.json'),
  sessions('sessions.jsonl'),
  attemptValues('attempt_values.jsonl'),
  hathaProgress('hatha_progress.jsonl');

  const LissomLocalFile(this.fileName);
  final String fileName;
}

/// Owns only local file routing. Authentication and entitlements belong to the
/// shared Motion account host; neither can be inferred from a directory name.
final class LissomLocalScope {
  const LissomLocalScope._(this.userId, [this.owner]);

  /// Preserves the existing on-device paths for users without an account.
  static const LissomLocalScope guest = LissomLocalScope._(null);

  /// Use the authenticated provider's opaque user ID, never an email address.
  /// The restricted alphabet prevents path traversal and path separators.
  factory LissomLocalScope.account(String userId, {LissomLocalOwner? owner}) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(userId)) {
      throw ArgumentError.value(userId, 'userId', 'Invalid account ID');
    }
    if (owner != null && owner.userId != userId) {
      throw ArgumentError('The local lifetime belongs to another account');
    }
    return LissomLocalScope._(userId, owner);
  }

  factory LissomLocalScope.guestWithOwner(LissomLocalOwner owner) {
    if (owner.userId != null) throw ArgumentError('Not a guest lifetime');
    return LissomLocalScope._(null, owner);
  }

  final String? userId;
  final LissomLocalOwner? owner;

  bool get isGuest => userId == null;
  String get ownerKey => userId == null ? 'guest' : 'account:$userId';
  String get lifetimeKey => '$ownerKey:${owner?.epoch ?? 0}';

  Directory directory(Directory supportDirectory) {
    final Directory root = owner?.supportDirectory ?? supportDirectory;
    return userId == null
        ? Directory('${root.path}/lissom')
        : Directory('${root.path}/lissom/accounts/$userId');
  }

  File file(Directory supportDirectory, LissomLocalFile kind) =>
      File('${directory(supportDirectory).path}/${kind.fileName}');
}

final class LissomCleanupConflict implements Exception {
  const LissomCleanupConflict();

  @override
  String toString() => 'LissomCleanupConflict';
}

/// Captured before the account page/dialog; never resolves a mutable owner.
final class LissomDeletionTicket {
  const LissomDeletionTicket._({
    required this.userId,
    required this.epoch,
    required this.supportDirectory,
    required this.namespacePath,
    required this.canonicalPaths,
    required this.ownerHandles,
    required Object registryIdentity,
  }) : _registryIdentity = registryIdentity;

  final String userId;
  final int epoch;
  final Directory supportDirectory;
  final String namespacePath;
  final List<String> canonicalPaths;
  final List<LissomLocalOwner> ownerHandles;
  final Object _registryIdentity;
}

/// Auth epochs and per-UUID erasure fences are host policy, not Core IO.
final class LissomOwnerRegistry extends ChangeNotifier {
  LissomOwnerRegistry({
    Future<Directory> Function()? supportDirectory,
    Directory? canonicalSupportDirectory,
  }) : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory,
       _boundRoot = canonicalSupportDirectory?.absolute;

  final Future<Directory> Function() _supportDirectory;
  final Object _ticketIdentity = Object();
  Directory? _boundRoot;
  Future<void>? _initializing;
  final Map<String?, int> _epochs = <String?, int>{};
  final Map<String?, Set<LissomLocalOwner>> _owners =
      <String?, Set<LissomLocalOwner>>{};
  final Map<String, Future<void>> _erasures = <String, Future<void>>{};
  final Set<String> _pendingCleanup = <String>{};
  int _nextEpoch = 0;
  bool _disposed = false;

  bool get isInitialized => _boundRoot != null;
  Directory get supportDirectory => _requireSupportRoot();

  /// Resolve once before account runtime/UI admission. Every owned handle and
  /// ticket uses this same immutable root, including delayed cleanup callbacks.
  Future<void> initialize() {
    if (_disposed) return Future<void>.error(LissomOwnerClosed());
    if (_boundRoot != null) return Future<void>.value();
    if (_initializing != null) return _initializing!;
    final Completer<void> initialized = Completer<void>();
    _initializing = initialized.future;
    Future<Directory>.sync(_supportDirectory).then<void>(
      (Directory root) {
        if (_disposed) {
          initialized.completeError(LissomOwnerClosed());
          return;
        }
        _boundRoot = root.absolute;
        notifyListeners();
        initialized.complete();
      },
      onError: (Object error, StackTrace stack) =>
          initialized.completeError(error, stack),
    );
    return initialized.future;
  }

  Directory _requireSupportRoot() {
    if (_disposed || _boundRoot == null) {
      throw StateError('Initialize the local owner root before admission');
    }
    return _boundRoot!;
  }

  bool isFenced(String userId) =>
      _erasures.containsKey(userId) || _pendingCleanup.contains(userId);

  /// Signed-in replacement events invalidate pre-dialog tickets immediately.
  /// Normal token refresh does not call this method.
  void invalidateTickets(String userId) {
    _epochs[userId] = ++_nextEpoch;
  }

  LissomLocalScope openScope(String? userId) {
    if (userId != null) LissomLocalScope.account(userId);
    if (_disposed || (userId != null && isFenced(userId))) {
      throw LissomOwnerClosed();
    }
    final Directory root = _requireSupportRoot();
    final int epoch = ++_nextEpoch;
    _epochs[userId] = epoch;
    final LissomLocalOwner owner = LissomLocalOwner(
      userId: userId, epoch: epoch, supportDirectory: root,
    );
    _owners.putIfAbsent(userId, () => <LissomLocalOwner>{}).add(owner);
    return userId == null
        ? LissomLocalScope.guestWithOwner(owner)
        : LissomLocalScope.account(userId, owner: owner);
  }

  LissomDeletionTicket captureTicket(String userId) {
    final LissomLocalScope scope = LissomLocalScope.account(userId);
    final Directory root = _requireSupportRoot();
    return LissomDeletionTicket._(
      userId: userId,
      epoch: _epochs.putIfAbsent(userId, () => ++_nextEpoch),
      supportDirectory: root,
      namespacePath: scope.directory(root).path,
      canonicalPaths: List<String>.unmodifiable(<String>[
        for (final LissomLocalFile kind in LissomLocalFile.values)
          for (final String suffix in <String>['', '.tmp'])
            '${scope.file(root, kind).path}$suffix',
      ]),
      ownerHandles: List<LissomLocalOwner>.unmodifiable(
        _owners[userId] ?? <LissomLocalOwner>{},
      ),
      registryIdentity: _ticketIdentity,
    );
  }

  bool isCurrentTicket(LissomDeletionTicket ticket) =>
      !_disposed &&
      identical(ticket._registryIdentity, _ticketIdentity) &&
      !isFenced(ticket.userId) &&
      _epochs[ticket.userId] == ticket.epoch;

  Future<void> eraseWithTicket(LissomDeletionTicket ticket, String confirmedId) {
    if (confirmedId != ticket.userId || _disposed ||
        !identical(ticket._registryIdentity, _ticketIdentity) ||
        _epochs[ticket.userId] != ticket.epoch) {
      return Future<void>.error(const LissomCleanupConflict());
    }
    final Future<void>? existing = _erasures[confirmedId];
    if (existing != null) return existing;
    if (isFenced(confirmedId)) {
      return Future<void>.error(const LissomCleanupConflict());
    }
    return _eraseNamespace(
      confirmedId,
      root: ticket.supportDirectory,
      namespacePath: ticket.namespacePath,
      owners: ticket.ownerHandles,
    );
  }

  /// Permanent Core callbacks confirm a UUID namespace, including its current
  /// lifetime. Fence+retirement happen synchronously before path-provider IO.
  Future<void> eraseConfirmedAccount(String confirmedId) {
    final LissomLocalScope scope = LissomLocalScope.account(confirmedId);
    final Future<void>? existing = _erasures[confirmedId];
    if (existing != null) return existing;
    final Directory root = _requireSupportRoot();
    return _eraseNamespace(
      confirmedId,
      root: root,
      namespacePath: scope.directory(root).path,
      owners: List<LissomLocalOwner>.unmodifiable(
        _owners[confirmedId] ?? <LissomLocalOwner>{},
      ),
    );
  }

  Future<void> _eraseNamespace(
    String confirmedId, {
    required Directory root,
    required String namespacePath,
    required List<LissomLocalOwner> owners,
  }) {
    if (LissomLocalScope.account(confirmedId).directory(root).path !=
        namespacePath) {
      return Future<void>.error(const LissomCleanupConflict());
    }
    final Completer<void> erased = Completer<void>();
    _erasures[confirmedId] = erased.future;
    _pendingCleanup.add(confirmedId);
    final List<Future<void>> drains = <Future<void>>[
      for (final LissomLocalOwner owner in owners)
        owner.retireAndDrain(),
    ];
    if (!_disposed) notifyListeners();
    () async {
      try {
        await Future.wait(drains);
        await clearLissomLocalData(
          confirmedId,
          supportDirectory: () async => root,
        );
        _pendingCleanup.remove(confirmedId);
        erased.complete();
      } catch (error, stack) {
        // Retained handles stay closed; a later verified callback can retry.
        erased.completeError(error, stack);
      } finally {
        _erasures.remove(confirmedId);
        if (!_disposed) notifyListeners();
      }
    }();
    return erased.future;
  }

  @override
  void dispose() {
    _disposed = true;
    for (final Set<LissomLocalOwner> owners in _owners.values) {
      for (final LissomLocalOwner owner in owners) {
        unawaited(owner.retireAndDrain().then<void>(
          (_) {},
          onError: (Object _, StackTrace __) {},
        ));
      }
    }
    super.dispose();
  }
}

/// Lists only local account directories that can belong to a Supabase UUID.
/// The guest directory and malformed names never enter Core reconciliation.
/// Refuse linked ancestors, then enumerate one level without following links.
Future<Iterable<String>> listLissomLocalAccountIds({
  Future<Directory> Function()? supportDirectory,
}) async {
  final Directory root =
      await (supportDirectory ?? getApplicationSupportDirectory)();
  final Directory lissom = Directory('${root.path}/lissom');
  final Directory accounts = Directory('${lissom.path}/accounts');
  for (final Directory directory in <Directory>[lissom, accounts]) {
    final FileSystemEntityType type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) return const <String>[];
    if (type != FileSystemEntityType.directory) {
      throw StateError('Refusing to list account data through a link or file');
    }
  }

  final RegExp uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  final List<String> ids = <String>[];
  await for (final FileSystemEntity entity in accounts.list(
    followLinks: false,
  )) {
    final String name = entity.path.substring(accounts.path.length + 1);
    if (uuid.hasMatch(name) &&
        await FileSystemEntity.type(entity.path, followLinks: false) ==
            FileSystemEntityType.directory) {
      ids.add(name);
    }
  }
  ids.sort();
  return ids;
}

/// Fits MotionAccountPage.clearLocalData. It removes only this authenticated
/// user's local Lissom directory. Legacy guest data and other account IDs are
/// intentionally untouched; no guest record is silently claimed or migrated.
Future<void> clearLissomLocalData(
  String userId, {
  Future<Directory> Function()? supportDirectory,
}) async {
  final LissomLocalScope scope = LissomLocalScope.account(userId);
  final Directory root =
      await (supportDirectory ?? getApplicationSupportDirectory)();
  final Directory target = scope.directory(root);
  final String accountsPath = '${root.path}/lissom/accounts';
  for (final String path in <String>[
    '${root.path}/lissom',
    accountsPath,
    target.path,
  ]) {
    if (await FileSystemEntity.type(path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw StateError('Refusing to delete account data through a link');
    }
  }
  await LissomLocalWriteGuard.retireAndClear(target.path, () async {
    if (await target.exists()) await target.delete(recursive: true);
  });
}
