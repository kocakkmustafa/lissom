import 'dart:async';

import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_account_bridge.dart';

/// The page captures this client before its dialog. Core pins the token when
/// deleteCommonAccount is called; the host rejects stale same-UUID initiation.
final class LissomEpochAccountClient extends MotionAccountClient {
  LissomEpochAccountClient({
    required MotionAccountClient account,
    required this.registry,
    required this.ticket,
    this.canInitiate,
  }) : _account = account,
       _openingSession = account.supabase.auth.currentSession,
       super(
         supabase: account.supabase,
         app: account.app,
         emailRedirectTo: account.emailRedirectTo,
       );

  final LissomOwnerRegistry registry;
  final LissomDeletionTicket ticket;
  final MotionAccountClient _account;
  final Session? _openingSession;
  final bool Function()? canInitiate;

  @override
  User? get currentUser => _account.currentUser;

  @override
  Stream<AuthState> get authChanges => _account.authChanges;

  @override
  Future<AuthResponse> signUp({required String email, required String password}) =>
      _account.signUp(email: email, password: password);

  @override
  Future<AuthResponse> signIn({required String email, required String password}) =>
      _account.signIn(email: email, password: password);

  @override
  Future<void> sendPasswordReset(String email) => _account.sendPasswordReset(email);

  @override
  Future<void> resendConfirmation(String email) => _account.resendConfirmation(email);

  @override
  Future<UserResponse> updatePassword(String password) => _account.updatePassword(password);

  @override
  Future<void> signOut() => _account.signOut();

  @override
  Future<Map<String, dynamic>?> loadProfile() => _account.loadProfile();

  @override
  Future<void> saveDisplayName(String name) => _account.saveDisplayName(name);

  @override
  Future<MotionMembershipStatus> membershipStatus() => _account.membershipStatus();

  @override
  Future<bool> hasActiveMembership() => _account.hasActiveMembership();

  @override
  Future<void> deleteCommonAccount({
    Future<void> Function(String userId)? afterRemoteDelete,
  }) {
    if (currentUser?.id != ticket.userId || !registry.isCurrentTicket(ticket) ||
        !identical(supabase.auth.currentSession, _openingSession) ||
        (canInitiate != null && !canInitiate!())) {
      return Future<void>.error(const LissomCleanupConflict());
    }
    return _account.deleteCommonAccount(afterRemoteDelete: afterRemoteDelete);
  }
}
