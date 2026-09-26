import 'dart:async';

/// Serializes course writes and account deletion within this app process.
/// A deleted account's pending screens keep an invalid lease and cannot
/// recreate its directory after the account host has removed local data.
final class LissomLocalWriteGuard {
  LissomLocalWriteGuard(this.directoryPath);

  final String directoryPath;
  static final Map<String, Future<void>> _tails = <String, Future<void>>{};
  static final Set<String> _retired = <String>{};

  Future<T> write<T>(Future<T> Function() operation) => _serialize(
    directoryPath,
    () async {
      if (_retired.contains(directoryPath)) {
        throw StateError('This account was deleted; course writing is closed');
      }
      return operation();
    },
  );

  static Future<void> retireAndClear(
    String directoryPath,
    Future<void> Function() clear,
  ) {
    _retired.add(directoryPath);
    return _serialize(directoryPath, clear);
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
