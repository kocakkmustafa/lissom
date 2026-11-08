import 'hatha_course.dart';

/// "Beginner" path: a selection from the existing Hatha course, not a course
/// of its own. It is the consecutive opening sequence h01–h10 (arrival h01–h06
/// plus standing h07–h10). Hatha lessons form a prerequisite chain, so a
/// consecutive run is the only selection a new user can open end to end.
///
/// The path owns no lessons, no progress record and no access rule: every
/// lesson is the Hatha lesson with the same id, practice is recorded against
/// the Hatha course id/version, and the Hatha access gate applies unchanged.
const List<String> hathaBeginnerPathLessonIds = <String>[
  'h01',
  'h02',
  'h03',
  'h04',
  'h05',
  'h06',
  'h07',
  'h08',
  'h09',
  'h10',
];

/// First Hatha lesson after the path, used for the "continue Hatha" hint.
const String hathaBeginnerPathNextLessonId = 'h11';

/// The path lessons, in order, resolved from [course]. Lessons that [course]
/// does not contain are skipped, so a non-Hatha course yields an empty list.
List<HathaLesson> hathaBeginnerPathLessons(HathaCourse course) => <HathaLesson>[
  for (final String id in hathaBeginnerPathLessonIds)
    if (course.lessonById(id) case final HathaLesson lesson) lesson,
];

/// Whether [course] can host the path: every path id exists in it.
bool hathaBeginnerPathAvailable(HathaCourse course) =>
    hathaBeginnerPathLessons(course).length ==
    hathaBeginnerPathLessonIds.length;
