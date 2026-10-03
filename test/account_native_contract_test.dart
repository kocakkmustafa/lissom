import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/main.dart';
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final class _GateAccount extends MotionAccountClient {
  _GateAccount() : super(
    supabase: SupabaseClient(
      'https://fixture.invalid',
      'public-fixture',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    ),
    app: MotionApp.lissom,
    emailRedirectTo: kLissomAuthRedirect,
  );

  @override
  User? get currentUser => null;
  @override
  Stream<AuthState> get authChanges => const Stream<AuthState>.empty();
}

final class _GateRuntime implements MotionAccountRuntime {
  @override
  final _GateAccount account = _GateAccount();
  @override
  final ValueNotifier<MotionIdentityPhase> phase = ValueNotifier(
    MotionIdentityPhase.verifying,
  );
  @override
  final ValueNotifier<String?> userId = ValueNotifier('stored-user');
  @override
  final ValueNotifier<bool> passwordRecovery = ValueNotifier(false);
  @override
  bool get isPasswordRecovery => passwordRecovery.value;
  @override
  Listenable get identityVerification => phase;
  @override
  bool get isCurrentSessionVerified => false;
  @override
  bool get isDisposed => _disposed;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    phase.dispose();
    userId.dispose();
    passwordRecovery.dispose();
    unawaited(account.supabase.dispose());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Lissom account ID and PKCE callback match native registration', () {
    expect(kLissomMotionAppId, MotionApp.lissom.name);
    final Uri redirect = Uri.parse(kLissomAuthRedirect);
    expect(redirect.scheme, 'com.yulalab.lissom');
    expect(redirect.host, 'auth');
    expect(redirect.path, '/callback');
    expect(redirect.query, isEmpty);

    final String android = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(android, contains('android.permission.INTERNET'));
    expect(android, contains('android:scheme="${redirect.scheme}"'));
    expect(android, contains('android:host="${redirect.host}"'));
    expect(android, contains('android:path="${redirect.path}"'));
    expect(android, contains('android.intent.action.VIEW'));

    final String ios = File('ios/Runner/Info.plist').readAsStringSync();
    expect(ios, contains('<key>CFBundleURLSchemes</key>'));
    expect(ios, contains('<string>${redirect.scheme}</string>'));
  });

  testWidgets('unverified stored identity never opens the Lissom shell', (
    WidgetTester tester,
  ) async {
    final _GateRuntime runtime = _GateRuntime();
    await tester.pumpWidget(LissomAccountHost(runtime: runtime));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(OnboardingGate), findsNothing);

    runtime.phase.value = MotionIdentityPhase.unavailable;
    await tester.pump();
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OnboardingGate), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
