import 'package:supabase_flutter/supabase_flutter.dart';

enum LissomSessionChange { none, credentialRefresh, replacement }

/// Tracks credential reference changes, without deciding identity or recovery.
///
/// The initial binding is captured at the initialized runtime's host boundary.
/// A changed credential closes initiation until the host observes Core
/// isCurrentSessionVerified for the exact public Session. This helper never
/// verifies identity itself.
final class LissomAuthSessionFence {
  LissomAuthSessionFence(Session? session)
      : _observed = session,
        _credential = session;

  Session? _observed;
  Session? _credential;
  bool _credentialBound = true;

  void bindVerified(Session? current) {
    if (!identical(current, _observed)) return;
    _credential = current;
    _credentialBound = true;
  }

  bool canInitiate(Session? current) =>
      _credentialBound && identical(_credential, current);

  LissomSessionChange observe(Session? current, {AuthState? event}) {
    if (identical(current, _observed)) return LissomSessionChange.none;
    final bool ordinaryRefresh = event?.event == AuthChangeEvent.tokenRefreshed &&
        identical(event?.session, current) &&
        current != null && _observed != null &&
        current.user.id == _observed!.user.id;
    _observed = current;
    _credentialBound = false;
    return ordinaryRefresh
        ? LissomSessionChange.credentialRefresh
        : LissomSessionChange.replacement;
  }
}
