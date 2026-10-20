import 'dart:async';

import 'local_owner.dart';

/// Serializes course writes and account deletion within this app process.
/// A deleted account's pending screens keep an invalid lease and cannot
/// recreate its directory after the account host has removed local data.
final class LissomLocalWriteGuard {
  LissomLocalWriteGuard(this.directoryPath, {LissomLocalOwner? owner})
    : owner = owner ?? _legacyOwners.putIfAbsent(
        directoryPath,
        () => LissomLocalOwner(userId: null, epoch: 0),
      );

  final String directoryPath;
  final LissomLocalOwner owner;
  static final Map<String, Future<void>> _tails = <String, Future<void>>{};
  static final Map<String, LissomLocalOwner> _legacyOwners =
      <String, LissomLocalOwner>{};

  /// A read admitted after a write observes that write's terminal state.
  /// Reads do not join the write queue: a writer must use its private reader
  /// when checking prerequisites, so it cannot wait for its own completion.
  Future<T> read<T>(Future<T> Function() operation) => owner.io.run(() async {
    final Future<void>? precedingWrites = _tails[directoryPath];
    if (precedingWrites != null) await precedingWrites;
    owner.checkActive();
    return operation();
  });

  Future<T> write<T>(Future<T> Function() operation) => owner.io.run(
    () => _serialize(directoryPath, () {
      owner.checkActive();
      return operation();
    }),
  );

  static Future<void> retireAndClear(
    String directoryPath,
    Future<void> Function() clear,
  ) {
    final LissomLocalOwner owner = LissomLocalWriteGuard(directoryPath).owner;
    final Future<void> drained = owner.retireAndDrain();
    return _serialize(directoryPath, () async {
      await drained;
      await clear();
    });
  }

  static Future<T> _serialize<T>(
    String path,
    Future<T> Function() operation,
  ) async {
    final Future<void> previous = _tails[path] ?? Future<void>.value();
    final Completer<void> done = Completer<void>();
    final Future<void> tail = done.future;
    _tails[path] = tail;
    await previous;
    try {
      return await operation();
    } finally {
      done.complete();
      if (identical(_tails[path], tail)) _tails.remove(path);
    }
  }
}
