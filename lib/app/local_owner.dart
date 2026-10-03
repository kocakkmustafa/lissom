import 'dart:async';
import 'dart:io';

import 'package:motion_core/motion_core.dart';

final class LissomOwnerClosed extends StateError {
  LissomOwnerClosed() : super('This local owner was retired');
}

/// Host files are not Core journals. Their admitted IO needs its own barrier.
final class LissomLocalIoLease {
  bool _active = true;
  final Set<Future<void>> _pending = <Future<void>>{};
  Future<void>? _drain;

  bool get isActive => _active;

  void checkActive() {
    if (!_active) throw LissomOwnerClosed();
  }

  Future<T> run<T>(Future<T> Function() action) async {
    checkActive();
    final Completer<void> settled = Completer<void>();
    _pending.add(settled.future);
    try {
      final T value = await action();
      checkActive();
      return value;
    } finally {
      _pending.remove(settled.future);
      settled.complete();
    }
  }

  Future<void> retireAndDrain() {
    _active = false;
    return _drain ??= Future.wait(_pending.toList()).then((_) {});
  }
}

/// One verified UI/storage lifetime. A fresh same-UUID session gets a new one.
final class LissomLocalOwner {
  LissomLocalOwner({
    required this.userId,
    required this.epoch,
    this.supportDirectory,
  });

  final String? userId;
  final int epoch;
  final Directory? supportDirectory;
  final SessionStoreWriteLease journalWrites = SessionStoreWriteLease();
  final LissomLocalIoLease io = LissomLocalIoLease();
  final Set<LissomResourceLease> _resources = <LissomResourceLease>{};
  bool _active = true;
  Future<void>? _drain;

  bool get isActive => _active;

  void checkActive() {
    if (!_active) throw LissomOwnerClosed();
  }

  LissomResourceLease registerResource(Future<void> Function() retireAndClose) {
    checkActive();
    final LissomResourceLease lease = LissomResourceLease._(
      retireAndClose,
      (LissomResourceLease closed) => _resources.remove(closed),
    );
    _resources.add(lease);
    return lease;
  }

  Future<void> retireAndDrain() {
    if (_drain != null) return _drain!;
    final Completer<void> drained = Completer<void>();
    _drain = drained.future;
    _active = false;
    // Every admission flag and resource retirement runs before the first await.
    final Future<void> journals = journalWrites.retireAndDrain();
    final Future<void> host = io.retireAndDrain();
    final List<Future<void>> resources = <Future<void>>[
      for (final LissomResourceLease resource in _resources.toList())
        resource.close(),
    ];
    Future.wait(<Future<void>>[
      journals,
      host,
      ...resources,
    ]).then<void>(
      (_) => drained.complete(),
      onError: (Object error, StackTrace stack) =>
          drained.completeError(error, stack),
    );
    return _drain!;
  }
}

/// A failed close stays in the owner's barrier; uncertainty is not success.
final class LissomResourceLease {
  LissomResourceLease._(this._retireAndClose, this._onClosed);

  final Future<void> Function() _retireAndClose;
  final void Function(LissomResourceLease) _onClosed;
  Future<void>? _closing;

  Future<void> close() {
    final Future<void>? existing = _closing;
    if (existing != null) return existing;
    final Completer<void> closed = Completer<void>();
    final Future<void> closing = closed.future;
    _closing = closing;
    // Observe fire-and-forget disposal errors without changing the barrier.
    unawaited(closing.then<void>((_) {}, onError: (Object _, StackTrace __) {}));
    Future<void>.sync(_retireAndClose).then<void>(
      (_) {
        _onClosed(this);
        closed.complete();
      },
      onError: (Object error, StackTrace stack) =>
          closed.completeError(error, stack),
    );
    return closing;
  }
}
