import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/ashtanga_course.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/yin_course.dart';

final class _CourseBytes extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key != kYinCourseAssetPath && key != kAshtangaCourseAssetPath) {
      throw StateError('Unexpected course asset request');
    }
    final bytes = File(key).readAsBytesSync();
    final padded = Uint8List(bytes.length + 8)
      ..setRange(4, bytes.length + 4, bytes);
    return ByteData.view(padded.buffer, 4, bytes.length);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'editorial content retains existing journal bytes and next-lesson admission',
    () async {
      final yin = await loadVerifiedYinCourse(_CourseBytes());
      final ashtanga = await loadVerifiedAshtangaCourse(_CourseBytes());
      expect(yin.id, 'lissom.yin.supported.beginner');
      expect(ashtanga.id, 'lissom.ashtanga.foundations.beginner');
      expect(yin.version, '1.0.0');
      expect(ashtanga.version, '1.0.0');

      final directory = await Directory.systemTemp.createTemp(
        'lissom-editorial-history-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/practice.jsonl');
      // Frozen old-format records, authored before this content change. Never
      // produce this fixture through the current record serializer at runtime.
      final oldBytes = File(
        'test/fixtures/pre_editorial_course_history.v1.jsonl',
      ).readAsBytesSync();
      await file.writeAsBytes(oldBytes, flush: true);
      final store = JsonlHathaProgressStore(file);
      final before = await store.read();
      expect(before.records, hasLength(10));
      expect(before.unreadableRecords, 1);
      expect(before.practicedIn(yin), {'y01', 'y02', 'y03'});
      expect(before.practicedIn(ashtanga), {'a01', 'a02', 'a03'});
      expect(before.oldVersionCount(yin), 1);
      expect(before.oldVersionCount(ashtanga), 1);
      expect(before.records.first.practicedAt, DateTime.utc(2026, 10, 19, 8));
      expect(await file.readAsBytes(), orderedEquals(oldBytes));

      // A content edit must not grant the final lesson or rewrite old records.
      await expectLater(store.markPracticed(yin, 'y08'), throwsStateError);
      await expectLater(store.markPracticed(ashtanga, 'a13'), throwsStateError);
      expect(await file.readAsBytes(), orderedEquals(oldBytes));

      await store.markPracticed(yin, 'y04');
      await store.markPracticed(ashtanga, 'a04');
      final bytesAfter = await file.readAsBytes();
      expect(bytesAfter.length, greaterThan(oldBytes.length));
      expect(bytesAfter.sublist(0, oldBytes.length), orderedEquals(oldBytes));
      final reopened = await JsonlHathaProgressStore(file).read();
      expect(reopened.records, hasLength(12));
      expect(reopened.unreadableRecords, 1);
      expect(reopened.practicedIn(yin), {'y01', 'y02', 'y03', 'y04'});
      expect(reopened.practicedIn(ashtanga), {'a01', 'a02', 'a03', 'a04'});
      expect(reopened.oldVersionCount(yin), 1);
      expect(reopened.oldVersionCount(ashtanga), 1);
      expect(
        reopened.records
            .where((r) => r.courseId == 'lissom.hatha.foundations')
            .single
            .lessonId,
        'h01',
      );
      expect(reopened.records.first.practicedAt, DateTime.utc(2026, 10, 19, 8));
    },
  );
}
