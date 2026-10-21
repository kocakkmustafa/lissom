import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_progress.dart';

void main() {
  test(
    'all four bundled paths persist and reopen independently in one real file',
    () async {
      final root = await Directory.systemTemp.createTemp('lissom-four-course-');
      addTearDown(() => root.delete(recursive: true));
      final file = File('${root.path}/practice.jsonl');
      final courses = [
        for (final name in [
          'hatha',
          'chair-office',
          'vinyasa-standing',
          'yin-supported',
        ])
          HathaCourse.parse(
            File('config/courses/$name.v1.json').readAsStringSync(),
          ),
      ];
      final completed = <String>{};
      for (final course in courses) {
        final store = JsonlHathaProgressStore(file);
        await expectLater(
          store.markPracticed(course, course.lessons.last.id),
          throwsStateError,
        );
        for (final lesson in course.lessons) {
          await store.markPracticed(course, lesson.id);
        }
        completed.add(course.id);
        final reopened = await JsonlHathaProgressStore(file).read();
        expect(reopened.unreadableRecords, 0);
        for (final candidate in courses) {
          expect(
            reopened.practicedIn(candidate),
            completed.contains(candidate.id)
                ? candidate.lessons.map((lesson) => lesson.id).toSet()
                : isEmpty,
          );
        }
      }
      final finalProgress = await JsonlHathaProgressStore(file).read();
      // Hatha 60 + chair/office 15 + Vinyasa 14 + Yin 12 (Ashtanga ayrı).
      expect(finalProgress.records, hasLength(101));
      expect(file.readAsLinesSync(), hasLength(101));
    },
  );
}
