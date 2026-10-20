import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';

/// Hold a concrete store's filesystem read after IO admission.
final class _DelayedReadFile implements File {
  _DelayedReadFile(this.file);

  final File file;
  final Completer<void> entered = Completer<void>();
  final Completer<void> release = Completer<void>();

  @override
  String get path => file.path;
  @override
  Directory get parent => file.parent;
  @override
  Future<bool> exists() => file.exists();
  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    if (!entered.isCompleted) entered.complete();
    await release.future;
    return file.readAsString(encoding: encoding);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late LissomOwnerRegistry registry;
  const String alice = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const String bob = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

  setUp(() async {
    root = await Directory.systemTemp.createTemp('lissom-owner-adoption-');
    registry = LissomOwnerRegistry(canonicalSupportDirectory: root);
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => root.path);
  });

  tearDown(() async {
    registry.dispose();
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await root.delete(recursive: true);
  });

  test(
    'factory shares one journal lease across retained read/write handles',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final SessionStore first = await openSessionStore(scope: scope);
      final SessionStore second = await openSessionStore(scope: scope);
      await first.append(
        recordOf(lessonId: 'first', lessonClass: 'measurementOnly'),
      );
      await registry.eraseConfirmedAccount(alice);
      await expectLater(
        first.append(
          recordOf(lessonId: 'late', lessonClass: 'measurementOnly'),
        ),
        throwsA(isA<StateError>()),
      );
      for (final SessionStore store in <SessionStore>[first, second]) {
        await expectLater(
          store.recent(),
          throwsA(isA<SessionStoreRetiredException>()),
        );
        await expectLater(
          store.workedSecondsFor('first'),
          throwsA(isA<SessionStoreRetiredException>()),
        );
        await expectLater(
          store.unreadableRecords(),
          throwsA(isA<SessionStoreRetiredException>()),
        );
      }
      expect(await scope.directory(root).exists(), isFalse);
    },
  );

  test(
    'admitted IO drains before exact deletion and UUID admission is fenced',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final File file = scope.file(root, LissomLocalFile.onboarding);
      await file.parent.create(recursive: true);
      await file.writeAsString('old');
      final Completer<void> entered = Completer<void>();
      final Completer<void> release = Completer<void>();
      final Future<void> io = scope.owner!.io.run(() async {
        entered.complete();
        await release.future;
        await file.writeAsString('admitted');
      });
      final Future<void> rejected = expectLater(
        io,
        throwsA(isA<LissomOwnerClosed>()),
      );
      await entered.future;
      bool erased = false;
      final Future<void> erasure = registry.eraseConfirmedAccount(alice).then((
        _,
      ) {
        erased = true;
      });
      expect(scope.owner!.isActive, isFalse);
      expect(scope.owner!.journalWrites.isActive, isFalse);
      expect(registry.isFenced(alice), isTrue);
      expect(
        () => registry.openScope(alice),
        throwsA(isA<LissomOwnerClosed>()),
      );
      await Future<void>.delayed(Duration.zero);
      expect(erased, isFalse);
      expect(await file.readAsString(), 'old');
      release.complete();
      await rejected;
      await erasure;
      expect(await file.exists(), isFalse);
      expect(registry.isFenced(alice), isFalse);
    },
  );

  test(
    'old page ticket after fresh A is pending and preserves exact files',
    () async {
      registry.openScope(alice);
      final LissomDeletionTicket ticket = registry.captureTicket(alice);
      registry.invalidateTickets(alice);
      final LissomLocalScope fresh = registry.openScope(alice);
      final File file = fresh.file(root, LissomLocalFile.sessions);
      await file.parent.create(recursive: true);
      await file.writeAsString('fresh A marker');
      await expectLater(
        registry.eraseWithTicket(ticket, alice),
        throwsA(isA<LissomCleanupConflict>()),
      );
      expect(fresh.owner!.isActive, isTrue);
      expect(await file.readAsString(), 'fresh A marker');
    },
  );

  test(
    'captured A ticket after B clears only A and protects guest/B file set',
    () async {
      final LissomLocalScope a = registry.openScope(alice);
      final LissomDeletionTicket ticket = registry.captureTicket(alice);
      final LissomLocalScope b = registry.openScope(bob);
      final LissomLocalScope guest = registry.openScope(null);
      for (final LissomLocalScope scope in <LissomLocalScope>[a, b, guest]) {
        for (final LissomLocalFile kind in LissomLocalFile.values) {
          for (final String suffix in <String>['', '.tmp']) {
            final File file = File('${scope.file(root, kind).path}$suffix');
            await file.parent.create(recursive: true);
            await file.writeAsString('${scope.ownerKey}:${kind.name}:$suffix');
          }
        }
      }
      await registry.eraseWithTicket(ticket, alice);
      expect(await a.directory(root).exists(), isFalse);
      for (final LissomLocalScope scope in <LissomLocalScope>[b, guest]) {
        expect(scope.owner!.isActive, isTrue);
        for (final LissomLocalFile kind in LissomLocalFile.values) {
          for (final String suffix in <String>['', '.tmp']) {
            expect(
              await File(
                '${scope.file(root, kind).path}$suffix',
              ).readAsString(),
              '${scope.ownerKey}:${kind.name}:$suffix',
            );
          }
        }
      }
    },
  );

  test(
    'confirmed runtime erasure legitimately retires current same UUID lifetime',
    () async {
      final LissomLocalScope old = registry.openScope(alice);
      final LissomLocalScope fresh = registry.openScope(alice);
      final OnboardingStore store = await openOnboardingStore(scope: fresh);
      await store.write(const OnboardingProfile(completed: true));
      await registry.eraseConfirmedAccount(alice);
      expect(old.owner!.isActive, isFalse);
      expect(fresh.owner!.isActive, isFalse);
      await expectLater(store.read(), throwsA(isA<LissomOwnerClosed>()));
      expect(await fresh.directory(root).exists(), isFalse);
    },
  );

  test(
    'host reads held across retirement never publish onboarding data',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final File file = scope.file(root, LissomLocalFile.onboarding);
      await file.parent.create(recursive: true);
      await file.writeAsString('{"completed":true,"ageBand":"u40"}');
      final _DelayedReadFile delayed = _DelayedReadFile(file);
      final OnboardingStore store = JsonOnboardingStore(
        delayed,
        owner: scope.owner,
      );
      final Future<OnboardingProfile> read = store.read();
      final Future<void> rejected = expectLater(
        read,
        throwsA(isA<LissomOwnerClosed>()),
      );
      await delayed.entered.future;
      bool erased = false;
      final Future<void> drain = registry.eraseConfirmedAccount(alice).then((
        _,
      ) {
        erased = true;
      });
      await Future<void>.delayed(Duration.zero);
      expect(erased, isFalse);
      expect(await file.exists(), isTrue);
      delayed.release.complete();
      await rejected;
      await drain;
      expect(await file.exists(), isFalse);
    },
  );

  test(
    'Core journal read held at filesystem drains before captured UUID delete',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final SessionStore writer = await openSessionStore(scope: scope);
      await writer.append(
        recordOf(lessonId: 'old', lessonClass: 'measurementOnly'),
      );
      final File file = scope.file(root, LissomLocalFile.sessions);
      final _DelayedReadFile delayed = _DelayedReadFile(file);
      final SessionStore reader = JsonlSessionStore(
        delayed,
        writeLease: scope.owner!.journalWrites,
      );
      final Future<List<SessionRecord>> read = reader.recent();
      final Future<void> rejected = expectLater(
        read,
        throwsA(isA<SessionStoreRetiredException>()),
      );
      await delayed.entered.future;
      bool erased = false;
      final Future<void> drain = registry.eraseConfirmedAccount(alice).then((
        _,
      ) {
        erased = true;
      });
      await Future<void>.delayed(Duration.zero);
      expect(erased, isFalse);
      expect(await file.exists(), isTrue);
      delayed.release.complete();
      await rejected;
      await drain;
      expect(await file.exists(), isFalse);
    },
  );

  test(
    'onboarding and attempt retained stores close without deleting on logout',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final OnboardingStore onboarding = await openOnboardingStore(
        scope: scope,
      );
      final AttemptValueStore values = await openAttemptValueStore(
        scope: scope,
      );
      await onboarding.write(const OnboardingProfile(completed: true));
      await scope.owner!.retireAndDrain();
      await expectLater(onboarding.read(), throwsA(isA<LissomOwnerClosed>()));
      await expectLater(
        onboarding.write(const OnboardingProfile.notStarted()),
        throwsA(isA<LissomOwnerClosed>()),
      );
      await expectLater(
        values.forLesson('test'),
        throwsA(isA<LissomOwnerClosed>()),
      );
      await expectLater(
        values.unreadableRecords(),
        throwsA(isA<LissomOwnerClosed>()),
      );
      expect(
        await scope.file(root, LissomLocalFile.onboarding).exists(),
        isTrue,
      );
      final OnboardingStore reopened = await openOnboardingStore(
        scope: registry.openScope(alice),
      );
      expect((await reopened.read()).completed, isTrue);
      await expectLater(onboarding.read(), throwsA(isA<LissomOwnerClosed>()));
      await expectLater(
        values.append(
          AttemptValue(
            lessonId: 'late',
            completedAt: DateTime.utc(2026, 10, 2),
            value: 1,
            unit: 'degrees',
            tier: 'measured',
            provenance: const <String, String>{},
          ),
        ),
        throwsA(isA<LissomOwnerClosed>()),
      );
    },
  );

  test(
    'Hatha retained store closes reads/writes and fresh handle preserves schema',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final HathaProgressStore old = await openHathaProgressStore(scope: scope);
      final course = factsFromDisk().hatha!;
      await old.markPracticed(course, 'h01');
      final File file = scope.file(root, LissomLocalFile.hathaProgress);
      final Map<String, dynamic> row =
          jsonDecode((await file.readAsString()).trim())
              as Map<String, dynamic>;
      expect(row['v'], 1);
      expect(row['evidence'], 'self_report');
      expect(row['courseVersion'], course.version);
      await scope.owner!.retireAndDrain();
      await expectLater(old.read(), throwsA(isA<LissomOwnerClosed>()));
      await expectLater(
        old.markPracticed(course, 'h01'),
        throwsA(isA<LissomOwnerClosed>()),
      );
      final HathaProgressStore fresh = await openHathaProgressStore(
        scope: registry.openScope(alice),
      );
      expect((await fresh.read()).practicedIn(course), <String>{'h01'});
      await expectLater(old.read(), throwsA(isA<LissomOwnerClosed>()));
    },
  );

  test(
    'unbound legacy factory rejects lifetime retired during path-provider IO',
    () async {
      final LissomLocalOwner owner = LissomLocalOwner(userId: alice, epoch: 99);
      final LissomLocalScope scope = LissomLocalScope.account(
        alice,
        owner: owner,
      );
      final Completer<void> entered = Completer<void>();
      final Completer<void> release = Completer<void>();
      const MethodChannel channel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async {
            entered.complete();
            await release.future;
            return root.path;
          });
      final Future<OnboardingStore> opening = openOnboardingStore(scope: scope);
      final Future<void> rejected = expectLater(
        opening,
        throwsA(isA<LissomOwnerClosed>()),
      );
      await entered.future;
      await owner.retireAndDrain();
      release.complete();
      await rejected;
      expect(await scope.directory(root).exists(), isFalse);
    },
  );

  test('registry binds one root before ticket or owner admission', () async {
    final Completer<Directory> supplied = Completer<Directory>();
    int calls = 0;
    final LissomOwnerRegistry waiting = LissomOwnerRegistry(
      supportDirectory: () {
        calls++;
        return supplied.future;
      },
    );
    expect(waiting.isInitialized, isFalse);
    expect(() => waiting.openScope(alice), throwsStateError);
    expect(() => waiting.captureTicket(alice), throwsStateError);
    final Future<void> first = waiting.initialize();
    expect(identical(waiting.initialize(), first), isTrue);
    expect(calls, 1);
    supplied.complete(root);
    await first;
    final LissomLocalScope scope = waiting.openScope(alice);
    final LissomDeletionTicket ticket = waiting.captureTicket(alice);
    expect(scope.owner!.supportDirectory!.path, root.absolute.path);
    expect(ticket.namespacePath, scope.directory(root).path);
    expect(ticket.canonicalPaths, <String>[
      for (final LissomLocalFile kind in LissomLocalFile.values)
        for (final String suffix in <String>['', '.tmp'])
          '${scope.file(root, kind).path}$suffix',
    ]);
    expect(ticket.ownerHandles, <LissomLocalOwner>[scope.owner!]);
    expect(() => ticket.ownerHandles.clear(), throwsUnsupportedError);
    expect(() => ticket.canonicalPaths.clear(), throwsUnsupportedError);
    await waiting.initialize();
    expect(calls, 1);
    waiting.dispose();
  });

  test(
    'all owned factories and delayed page erasure keep the initialized root',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final LissomDeletionTicket ticket = registry.captureTicket(alice);
      final Directory laterRoot = Directory('${root.path}/later-provider-root');
      final File unrelated = LissomLocalScope.account(
        alice,
      ).file(laterRoot, LissomLocalFile.sessions);
      await unrelated.parent.create(recursive: true);
      await unrelated.writeAsString('later-root data');
      int providerCalls = 0;
      const MethodChannel channel = MethodChannel(
        'plugins.flutter.io/path_provider',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) async {
            providerCalls++;
            return laterRoot.path;
          });
      final SessionStore history = await openSessionStore(scope: scope);
      final AttemptValueStore attempts = await openAttemptValueStore(
        scope: scope,
      );
      final OnboardingStore onboarding = await openOnboardingStore(
        scope: scope,
      );
      final HathaProgressStore hatha = await openHathaProgressStore(
        scope: scope,
      );
      await history.append(
        recordOf(lessonId: 'bound', lessonClass: 'measurementOnly'),
      );
      await attempts.append(
        AttemptValue(
          lessonId: 'bound',
          completedAt: DateTime.utc(2026, 10, 2),
          value: 1,
          unit: 'degrees',
          tier: 'measured',
          provenance: const <String, String>{},
        ),
      );
      await onboarding.write(const OnboardingProfile(completed: true));
      await hatha.markPracticed(factsFromDisk().hatha!, 'h01');
      for (final LissomLocalFile kind in LissomLocalFile.values) {
        expect(await scope.file(root, kind).exists(), isTrue);
      }
      expect(providerCalls, 0);
      await registry.eraseWithTicket(ticket, alice);
      expect(await scope.directory(root).exists(), isFalse);
      expect(await unrelated.readAsString(), 'later-root data');
      expect(providerCalls, 0);
    },
  );

  test(
    'resource close is synchronous and erasure waits for its shared barrier',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      bool retired = false;
      final Completer<void> release = Completer<void>();
      final LissomResourceLease resource = scope.owner!.registerResource(() {
        retired = true;
        return release.future;
      });
      final Future<void> erasure = registry.eraseConfirmedAccount(alice);
      expect(retired, isTrue);
      expect(identical(resource.close(), resource.close()), isTrue);
      expect(registry.isFenced(alice), isTrue);
      expect(identical(registry.eraseConfirmedAccount(alice), erasure), isTrue);
      release.complete();
      await erasure;
    },
  );

  test(
    'synchronous resource callback throw keeps exact files and UUID fenced',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final File file = scope.file(root, LissomLocalFile.sessions);
      await file.parent.create(recursive: true);
      await file.writeAsString('preserve synchronous failure');
      int calls = 0;
      final LissomResourceLease resource = scope.owner!.registerResource(() {
        calls++;
        throw StateError('synchronous uncertain close');
      });
      final Future<void> erasure = registry.eraseConfirmedAccount(alice);
      expect(calls, 1);
      expect(scope.owner!.isActive, isFalse);
      await expectLater(erasure, throwsStateError);
      await expectLater(resource.close(), throwsStateError);
      expect(calls, 1);
      expect(await file.readAsString(), 'preserve synchronous failure');
      expect(
        () => registry.openScope(alice),
        throwsA(isA<LissomOwnerClosed>()),
      );
    },
  );

  test('duplicate current page cleanup shares pending UUID barrier', () async {
    final LissomLocalScope scope = registry.openScope(alice);
    final LissomDeletionTicket ticket = registry.captureTicket(alice);
    final Completer<void> release = Completer<void>();
    scope.owner!.registerResource(() => release.future);
    final Future<void> first = registry.eraseWithTicket(ticket, alice);
    expect(identical(registry.eraseWithTicket(ticket, alice), first), isTrue);
    expect(() => registry.openScope(alice), throwsA(isA<LissomOwnerClosed>()));
    release.complete();
    await first;
  });

  test(
    'failed resource close preserves files and keeps UUID fenced for retry',
    () async {
      final LissomLocalScope scope = registry.openScope(alice);
      final File file = scope.file(root, LissomLocalFile.sessions);
      await file.parent.create(recursive: true);
      await file.writeAsString('preserve');
      scope.owner!.registerResource(
        () => Future<void>.error(StateError('uncertain close')),
      );
      await expectLater(
        registry.eraseConfirmedAccount(alice),
        throwsStateError,
      );
      expect(await file.readAsString(), 'preserve');
      expect(registry.isFenced(alice), isTrue);
      expect(
        () => registry.openScope(alice),
        throwsA(isA<LissomOwnerClosed>()),
      );
      expect(registry.openScope(bob).owner!.isActive, isTrue);
    },
  );
  for (final saving in <bool>[false, true]) {
    test(
      'chair owner retires during awaited ${saving ? "save" : "read"}',
      () async {
        final scope = registry.openScope(alice);
        final course = HathaCourse.parse(
          File('config/courses/chair-office.v1.json').readAsStringSync(),
        );
        final file = scope.file(root, LissomLocalFile.hathaProgress);
        final original = JsonlHathaProgressStore(file, owner: scope.owner);
        await original.markPracticed(course, 'c01');
        final before = await file.readAsString();
        final delayed = _DelayedReadFile(file);
        final retained = JsonlHathaProgressStore(delayed, owner: scope.owner);
        final Future<Object?> pending = saving
            ? retained.markPracticed(course, 'c02')
            : retained.read();
        final rejected = expectLater(
          pending,
          throwsA(isA<LissomOwnerClosed>()),
        );
        await delayed.entered.future;
        final drain = scope.owner!.retireAndDrain();
        final other = registry.openScope(bob);
        delayed.release.complete();
        await rejected;
        await drain;
        expect(await file.readAsString(), before);
        final otherStore = await openHathaProgressStore(scope: other);
        expect((await otherStore.read()).practicedIn(course), isEmpty);
        final reopened = await openHathaProgressStore(
          scope: registry.openScope(alice),
        );
        expect((await reopened.read()).practicedIn(course), <String>{'c01'});
      },
    );
  }  for (final saving in <bool>[false, true]) {
    test(
      'Vinyasa owner retires during awaited ${saving ? "save" : "read"}',
      () async {
        final scope = registry.openScope(alice);
        final course = HathaCourse.parse(
          File('config/courses/vinyasa-standing.v1.json').readAsStringSync(),
        );
        final file = scope.file(root, LissomLocalFile.hathaProgress);
        final original = JsonlHathaProgressStore(file, owner: scope.owner);
        await original.markPracticed(course, 'v01');
        final before = await file.readAsString();
        final delayed = _DelayedReadFile(file);
        final retained = JsonlHathaProgressStore(delayed, owner: scope.owner);
        final Future<Object?> pending = saving
            ? retained.markPracticed(course, 'v02')
            : retained.read();
        final rejected = expectLater(
          pending,
          throwsA(isA<LissomOwnerClosed>()),
        );
        await delayed.entered.future;
        final drain = scope.owner!.retireAndDrain();
        final other = registry.openScope(bob);
        delayed.release.complete();
        await rejected;
        await drain;
        expect(await file.readAsString(), before);
        final otherStore = await openHathaProgressStore(scope: other);
        expect((await otherStore.read()).practicedIn(course), isEmpty);
        final reopened = await openHathaProgressStore(
          scope: registry.openScope(alice),
        );
        expect((await reopened.read()).practicedIn(course), <String>{'v01'});
      },
    );
  }

  for (final saving in <bool>[false, true]) {
    test(
      'Yin owner retires during awaited ${saving ? "save" : "read"}',
      () async {
        final scope = registry.openScope(alice);
        final course = HathaCourse.parse(
          File('config/courses/yin-supported.v1.json').readAsStringSync(),
        );
        final file = scope.file(root, LissomLocalFile.hathaProgress);
        final original = JsonlHathaProgressStore(file, owner: scope.owner);
        await original.markPracticed(course, 'y01');
        final before = await file.readAsString();
        final delayed = _DelayedReadFile(file);
        final retained = JsonlHathaProgressStore(delayed, owner: scope.owner);
        final Future<Object?> pending = saving
            ? retained.markPracticed(course, 'y02')
            : retained.read();
        final rejected = expectLater(
          pending,
          throwsA(isA<LissomOwnerClosed>()),
        );
        await delayed.entered.future;
        final drain = scope.owner!.retireAndDrain();
        final other = registry.openScope(bob);
        delayed.release.complete();
        await rejected;
        await drain;
        expect(await file.readAsString(), before);
        final otherStore = await openHathaProgressStore(scope: other);
        expect((await otherStore.read()).practicedIn(course), isEmpty);
        final reopened = await openHathaProgressStore(
          scope: registry.openScope(alice),
        );
        expect((await reopened.read()).practicedIn(course), <String>{'y01'});
      },
    );
  }
}
