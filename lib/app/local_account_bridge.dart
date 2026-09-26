import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'local_write_guard.dart';

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
  const LissomLocalScope._(this.userId);

  /// Preserves the existing on-device paths for users without an account.
  static const LissomLocalScope guest = LissomLocalScope._(null);

  /// Use the authenticated provider's opaque user ID, never an email address.
  /// The restricted alphabet prevents path traversal and path separators.
  factory LissomLocalScope.account(String userId) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(userId)) {
      throw ArgumentError.value(userId, 'userId', 'Invalid account ID');
    }
    return LissomLocalScope._(userId);
  }

  final String? userId;

  bool get isGuest => userId == null;
  String get ownerKey => userId == null ? 'guest' : 'account:$userId';

  Directory directory(Directory supportDirectory) => userId == null
      ? Directory('${supportDirectory.path}/lissom')
      : Directory('${supportDirectory.path}/lissom/accounts/$userId');

  File file(Directory supportDirectory, LissomLocalFile kind) =>
      File('${directory(supportDirectory).path}/${kind.fileName}');
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
