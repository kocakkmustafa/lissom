// EXTERNAL DRAFT / COMPILE, FORMAT, ANALYZER, SDK TESTS UNRUN.
// Requires exact published Core 8f and one matching guarded main overlay.
// Real production LissomApp/locale host/owner context and real Core account UI.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/local_owner_context.dart';
import 'package:lissom/main.dart' as production;
import 'package:motion_account/motion_account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _ownerId = 'core-wiring-owner';
const _ownerEpoch = 41;
const _ownerProbeKey = ValueKey<String>('wiring:owner:41');
const _accountPageKey = ValueKey<String>('wiring:account:41');
const _draftName = 'Retained across EN TR AR';
const _copy = <String, (String, String, String)>{
  'en': ('Motion account', 'Display name', 'Lissom membership'),
  'tr': ('Motion hesabı', 'Görünen ad', 'Lissom üyeliği'),
  'ar': ('حساب Motion', 'الاسم المعروض', 'عضوية Lissom'),
};

final class _MemoryPreference implements LocalePreferenceStore {
  String? value = 'en';
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? tag) async {
    value = tag;
  }
}

// Public fixture shapes verified in immutable 8f account_localizations_test.
// No SupabaseClient constructor, transport, Auth Session or service is opened.
class _NoNetworkSupabase implements SupabaseClient {
  const _NoNetworkSupabase();
  @override
  GoTrueClient get auth => const _NoNetworkAuth();
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected fixture call: ${invocation.memberName}');
}

class _NoNetworkAuth implements GoTrueClient {
  const _NoNetworkAuth();
  @override
  Session? get currentSession => null;
  @override
  User? get currentUser => null;
  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected fixture call: ${invocation.memberName}');
}

class _ProfileAccount implements MotionAccountClient {
  int profileReads = 0;
  final savedNames = <String>[];
  @override
  SupabaseClient get supabase => const _NoNetworkSupabase();
  @override
  MotionApp get app => MotionApp.lissom;
  @override
  String get emailRedirectTo => production.kLissomAuthRedirect;
  @override
  User? get currentUser => const User(
    id: _ownerId, appMetadata: {}, userMetadata: null,
    aud: 'authenticated', createdAt: '2026-10-20T00:00:00Z',
  );
  @override
  Stream<AuthState> get authChanges => const Stream.empty();
  @override
  Future<Map<String, dynamic>?> loadProfile() async {
    profileReads++;
    return <String, dynamic>{'display_name': 'Initial fixture name'};
  }
  @override
  Future<void> saveDisplayName(String name) async {
    savedNames.add(name);
  }
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unexpected fixture call: ${invocation.memberName}');
}

class _OwnerProbe extends StatefulWidget {
  const _OwnerProbe({required this.child, super.key});
  final Widget child;
  @override
  State<_OwnerProbe> createState() => _OwnerProbeState();
}

class _OwnerProbeState extends State<_OwnerProbe> {
  final lifetime = Object();
  LissomLocalOwner? observedOwner;
  @override
  Widget build(BuildContext context) {
    observedOwner = LissomOwnerContext.maybeOf(context);
    return widget.child;
  }
}

Future<void> _waitForProductionCatalogs(
  WidgetTester tester, String tag, String expectedProfile,
) async {
  final ready = await tester.runAsync(() async {
    final elapsed = Stopwatch()..start();
    while (elapsed.elapsed < const Duration(seconds: 10)) {
      await tester.pump();
      final elements = find.byType(MotionAccountPage).evaluate();
      if (elements.length == 1) {
        final context = elements.single;
        final core = Localizations.of<MotionAccountLocalizations>(
          context, MotionAccountLocalizations);
        final app = LissomLocalizations.maybeOf(context);
        if (core != null &&
            identical(MotionAccountLocalizations.of(context), core) &&
            core.locale.toLanguageTag() == tag &&
            Localizations.localeOf(context).toLanguageTag() == tag &&
            app != null && app.catalogAvailable && app.tag == tag &&
            app.lookup('Profile') == expectedProfile &&
            find.text(_copy[tag]!.$1).evaluate().length == 1) {
          return true;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return false;
  });
  expect(ready, isTrue,
    reason: 'Production LissomApp must actually register both mounted catalogs for $tag; of fallback alone is insufficient.');
}

void main() {
  testWidgets('production LissomApp registers Core catalog and preserves owner/account draft EN TR AR', (tester) async {
    final preference = LissomLocaleController(store: _MemoryPreference());
    final account = _ProfileAccount();
    final owner = LissomLocalOwner(userId: _ownerId, epoch: _ownerEpoch);
    final scope = LissomLocalScope.account(_ownerId, owner: owner);
    expect(motionPaidFeaturesAvailable, isFalse);
    await preference.initialize();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      preference.dispose();
      await owner.retireAndDrain();
    });
    final expectedProfile = <String, String>{};
    for (final tag in _copy.keys) {
      // Same real rootBundle/preload pattern as owner_session_contract_test.
      // Actual production delegates still mount below; this parse is no proof.
      final raw = await tester.runAsync(() => rootBundle
        .loadString('config/l10n/$tag.json').timeout(const Duration(seconds: 10)));
      expect(raw, isNotNull);
      final parsed = LissomLocalizations.parse(raw!, tag);
      expect(parsed.catalogAvailable, isTrue);
      expectedProfile[tag] = parsed.lookup('Profile')!;
    }
    await tester.pumpWidget(LissomLocaleHost(
      controller: preference,
      // No test-authored MaterialApp or test localizationsDelegates here.
      child: production.LissomApp(localScope: scope,
        forcedAccountPage: _OwnerProbe(key: _ownerProbeKey,
          child: MotionAccountPage(key: _accountPageKey, account: account))),
    ));
    await _waitForProductionCatalogs(tester, 'en', expectedProfile['en']!);
    final appState = tester.state(find.byType(MaterialApp));
    final accountState = tester.state(find.byType(MotionAccountPage));
    final ownerState = tester.state<_OwnerProbeState>(find.byKey(_ownerProbeKey));
    final appKey = tester.widget<MaterialApp>(find.byType(MaterialApp)).key;
    expect(appKey, ValueKey<String>('lissom:${scope.lifetimeKey}:account'));
    final field = find.descendant(of: find.byType(MotionAccountPage), matching: find.byType(TextField));
    expect(field, findsOneWidget);
    await tester.ensureVisible(field);
    await tester.pump();
    await tester.enterText(field, _draftName);
    await tester.pump();
    for (final tag in _copy.keys) {
      expect(await preference.select(tag), isTrue);
      await _waitForProductionCatalogs(tester, tag, expectedProfile[tag]!);
      final context = tester.element(find.byType(MotionAccountPage));
      final registered = Localizations.of<MotionAccountLocalizations>(
        context, MotionAccountLocalizations);
      expect(registered, isNotNull);
      expect(MotionAccountLocalizations.of(context), same(registered));
      expect(registered!.membershipForApp('Lissom'), _copy[tag]!.$3);
      expect(find.text(_copy[tag]!.$1), findsOneWidget);
      expect(tester.widget<TextField>(field).decoration!.labelText, _copy[tag]!.$2);
      expect(tester.widget<TextField>(field).controller!.text, _draftName);
      expect(Directionality.of(context), tag == 'ar' ? TextDirection.rtl : TextDirection.ltr);
      expect(tester.state(find.byType(MaterialApp)), same(appState));
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).key, appKey);
      expect(tester.state(find.byType(MotionAccountPage)), same(accountState));
      expect(tester.state(find.byKey(_ownerProbeKey)), same(ownerState));
      expect(ownerState.observedOwner, same(owner));
      expect(scope.owner, same(owner));
      expect(owner.epoch, _ownerEpoch);
      expect(owner.isActive, isTrue);
      final delegates = tester.widget<MaterialApp>(find.byType(MaterialApp)).localizationsDelegates!.toList();
      expect(delegates.where((item) => identical(item, MotionAccountLocalizations.delegate)), hasLength(1));
      expect(delegates.where((item) => identical(item, GlobalMaterialLocalizations.delegate)), hasLength(1));
      expect(delegates.where((item) => identical(item, GlobalWidgetsLocalizations.delegate)), hasLength(1));
      expect(delegates.where((item) => identical(item, GlobalCupertinoLocalizations.delegate)), hasLength(1));
      expect(account.savedNames, isEmpty, reason: 'Locale changes must not submit profile drafts.');
    }
    final save = find.widgetWithText(FilledButton, 'حفظ الملف الشخصي');
    await tester.ensureVisible(save);
    await tester.pump();
    expect(save.hitTestable(), findsOneWidget);
    await tester.tap(save);
    for (var frame = 0; frame < 50; frame++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (account.savedNames.length == 1 &&
          find.text('تم حفظ الملف الشخصي.').evaluate().length == 1) {
        break;
      }
    }
    expect(account.savedNames, <String>[_draftName]);
    expect(account.profileReads, 1, reason: 'Locale selection must not recreate account State/read lifecycle.');
    expect(find.text('تم حفظ الملف الشخصي.'), findsOneWidget);
    expect(tester.state(find.byType(MotionAccountPage)), same(accountState));
    expect(tester.takeException(), isNull);
  });
}
