import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/local_write_guard.dart';

void main() {
  test(
    'a read waits for the already admitted write, across guard instances',
    () async {
      final owner = LissomLocalOwner(userId: null, epoch: 1);
      final writer = LissomLocalWriteGuard(
        'read-barrier-success',
        owner: owner,
      );
      final reader = LissomLocalWriteGuard(
        'read-barrier-success',
        owner: owner,
      );
      final release = Completer<void>();
      int stored = 0;
      bool readStarted = false;
      final write = writer.write(() async {
        await release.future;
        stored = 1;
      });
      final read = reader.read(() async {
        readStarted = true;
        return stored;
      });
      await Future<void>.delayed(Duration.zero);
      expect(readStarted, isFalse);
      release.complete();
      await write;
      expect(await read, 1);
      await owner.retireAndDrain();
    },
  );

  test('a write failure releases readers to the previous data', () async {
    final owner = LissomLocalOwner(userId: null, epoch: 2);
    final guard = LissomLocalWriteGuard('read-barrier-failure', owner: owner);
    final release = Completer<void>();
    final write = guard.write<void>(() async {
      await release.future;
      throw StateError('Synthetic write failure');
    });
    final rejected = expectLater(write, throwsStateError);
    final read = guard.read(() async => 'old data');
    release.complete();
    await rejected;
    expect(await read, 'old data');
    await owner.retireAndDrain();
  });

  test('an unrelated directory read does not wait for another write', () async {
    final owner = LissomLocalOwner(userId: null, epoch: 3);
    final writer = LissomLocalWriteGuard('read-barrier-path-a', owner: owner);
    final reader = LissomLocalWriteGuard('read-barrier-path-b', owner: owner);
    final release = Completer<void>();
    final write = writer.write(() => release.future);
    expect(await reader.read(() async => 7), 7);
    release.complete();
    await write;
    await owner.retireAndDrain();
  });

  test(
    'retiring an owner rejects a waiting read before its operation starts',
    () async {
      final owner = LissomLocalOwner(userId: null, epoch: 4);
      final guard = LissomLocalWriteGuard('read-barrier-retire', owner: owner);
      final release = Completer<void>();
      bool readStarted = false;
      final write = guard.write(() => release.future);
      final writeRejected = expectLater(
        write,
        throwsA(isA<LissomOwnerClosed>()),
      );
      final read = guard.read(() async {
        readStarted = true;
        return 1;
      });
      final readRejected = expectLater(read, throwsA(isA<LissomOwnerClosed>()));
      final retired = owner.retireAndDrain();
      release.complete();
      await Future.wait<void>([writeRejected, readRejected, retired]);
      expect(readStarted, isFalse);
    },
  );

  for (final name in <String>[
    'hatha',
    'chair-office',
    'vinyasa-standing',
    'yin-supported',
    'ashtanga-foundations',
  ]) {
    test(
      '$name reload queued during save observes the real persisted record',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'lissom-read-write-',
        );
        final owner = LissomLocalOwner(userId: null, epoch: 5);
        addTearDown(() async {
          await owner.retireAndDrain();
          await directory.delete(recursive: true);
        });
        final course = HathaCourse.parse(
          File('config/courses/$name.v1.json').readAsStringSync(),
        );
        final file = File('${directory.path}/practice.jsonl');
        final guard = LissomLocalWriteGuard(directory.path, owner: owner);
        final store = JsonlHathaProgressStore(file, owner: owner);
        final release = Completer<void>();
        final precedingIo = guard.write(() => release.future);
        final save = store.markPracticed(course, course.lessons.first.id);
        final reload = store.read();
        release.complete();
        // The timeout makes a writer waiting for its own read fail boundedly.
        await Future.wait<void>([
          precedingIo,
          save,
        ]).timeout(const Duration(seconds: 5));
        final visible = await reload.timeout(const Duration(seconds: 5));
        final reopened = await JsonlHathaProgressStore(
          file,
          owner: owner,
        ).read();
        expect(visible.practicedIn(course), {course.lessons.first.id});
        expect(visible.records, hasLength(1));
        expect(visible.unreadableRecords, 0);
        expect(reopened.practicedIn(course), visible.practicedIn(course));
        expect(file.readAsLinesSync(), hasLength(1));
      },
    );
  }
}
