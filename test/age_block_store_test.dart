import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/age_block_store.dart';

void main() {
  late Directory temp;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('lissom_age_block_');
  });
  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('a fresh device starts unblocked', () async {
    final store = AgeBlockStore(directory: () async => temp);
    await store.load();
    expect(store.blocked, isFalse);
  });

  test('a recorded block survives a restart', () async {
    final first = AgeBlockStore(directory: () async => temp);
    await first.load();
    await first.markBlocked();
    expect(first.blocked, isTrue);

    final restarted = AgeBlockStore(directory: () async => temp);
    await restarted.load();
    expect(restarted.blocked, isTrue);
  });

  test('an unreadable location starts unblocked', () async {
    final store = AgeBlockStore(
      directory: () async => throw const FileSystemException('denied'),
    );
    await store.load();
    expect(store.blocked, isFalse);
    await store.markBlocked();
    expect(store.blocked, isTrue, reason: 'in-memory block holds this run');
  });

  test('production wires the durable block into the shared account page', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, contains('await ageBlock.load();'));
    expect(main, contains('ageBlock: ageBlock'));
    expect(main, contains('ageBlocked: widget.ageBlock?.blocked ?? false'));
    expect(main, contains('unawaited(widget.ageBlock!.markBlocked())'));
    // Sales are open on the account page (membership status + options).
    expect(main, contains('membershipAvailable: true'));
    // Core R1: camera has its own closed gate; paid lessons use the sales one.
    expect(main, contains('requireMotionCameraAccess('));
    expect(main, contains('salesAvailable: true'));
  });

  test('Core R3 store age signal stays on its production default', () {
    // MotionAccountPage reads the store age range itself (Core R3 K1); the
    // app must not replace it with a no-op, and iOS needs the entitlement.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, isNot(contains('storeAgeSignal:')));
    final entitlements = File(
      'ios/Runner/Runner.entitlements',
    ).readAsStringSync();
    expect(
      entitlements,
      contains('<key>com.apple.developer.declared-age-range</key>'),
    );
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    expect(
      'CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;'
          .allMatches(project)
          .length,
      3, // Debug, Release, Profile of the Runner target.
    );
  });

  test('Core R4 teen purchase policy stays on its default until K-2', () {
    // Core R4 adds teenPurchasePolicy; its default (parentalConsentRequired)
    // keeps the R3 behaviour: a teen still waiting for parental consent sees
    // no offers, restore stays open. A founder K-2 choice goes to the account
    // page and both access gates together, so this test changes with it.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main, isNot(contains('teenPurchasePolicy:')));
    expect(main, isNot(contains('storeFamilyControls')));
  });
}
