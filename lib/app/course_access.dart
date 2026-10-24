import 'package:flutter/widgets.dart';
import 'package:motion_entitlements/motion_entitlements.dart'
    show isLessonUnlocked;

import 'hatha_course.dart';

/// First-release access model (founder decision A, 2026-10-23): the opening
/// part of every course is free; the remaining lessons, including the
/// independent practice and extension modules, need a Lissom or Motion+
/// subscription. Practice records stay readable whatever the access state.
///
/// Free part = the shortest whole-module prefix that covers at least one third
/// of the course's lessons. Module ids are listed explicitly so a content edit
/// cannot silently widen or narrow the free part; `course_access_test` checks
/// that the list still satisfies the rule.
const Map<String, Set<String>> kFreeModuleIds = <String, Set<String>>{
  // 24 of 60 lessons.
  'lissom.hatha.foundations': <String>{
    'arrival',
    'standing',
    'floor_preparation',
    'seated',
  },
  // 6 of 15 lessons.
  'lissom.chair-office.beginner': <String>{'arrival', 'seated_movement'},
  // 5 of 14 lessons.
  'lissom.vinyasa.supported-standing.beginner': <String>{'v-foundations'},
  // 5 of 12 lessons.
  'lissom.yin.supported.beginner': <String>{'y-foundations'},
  // 7 of 19 lessons.
  'lissom.ashtanga.foundations.beginner': <String>{
    'a.foundations',
    'a.standing',
  },
};

/// Unknown courses are not free: a new course must be listed on purpose.
///
/// The decision itself is the shared Core lesson lock (`isLessonUnlocked`,
/// Core R1). Lissom passes its approved count — the lessons of the leading
/// free modules — as `freeLessonLimit`, so the Core default formula (which
/// may cut a module in half, e.g. Hatha 20/60) never applies here. A free
/// module listed after a paid one does not widen the prefix.
bool isFreeLesson(HathaCourse course, String lessonId) {
  final Set<String>? free = kFreeModuleIds[course.id];
  if (free == null || course.modules.isEmpty) return false;
  final List<HathaLesson> lessons = course.lessons;
  final int index = lessons.indexWhere((HathaLesson l) => l.id == lessonId);
  if (index < 0) return false;
  int freePrefix = 0;
  for (final HathaModule module in course.modules) {
    if (!free.contains(module.id)) break;
    freePrefix += module.lessons.length;
  }
  return isLessonUnlocked(
    lessonIndex: index,
    totalLessons: lessons.length,
    firstModuleLessonCount: course.modules.first.lessons.length,
    entitled: false,
    freeLessonLimit: freePrefix,
  );
}

int freeLessonCount(HathaCourse course) =>
    course.lessons.where((HathaLesson l) => isFreeLesson(course, l.id)).length;

/// Supplies the paid-lesson gate to every course screen below the app.
///
/// [ensureAccess] runs the shared Motion flow (sign in → membership check →
/// membership page with purchase/restore/manage) and returns whether the
/// lesson may open. A positive answer is remembered for this app lifetime;
/// the app replaces this scope (and so forgets it) when the account changes.
class LissomCourseAccess extends StatefulWidget {
  const LissomCourseAccess({
    required this.ensureAccess,
    required this.child,
    super.key,
  });

  final Future<bool> Function(BuildContext context)? ensureAccess;
  final Widget child;

  /// Null outside the app (isolated screen tests): no gate is applied there.
  static LissomCourseAccessState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CourseAccessScope>()?.state;

  @override
  State<LissomCourseAccess> createState() => LissomCourseAccessState();
}

class LissomCourseAccessState extends State<LissomCourseAccess> {
  bool _subscribed = false;

  bool get subscribed => _subscribed;

  /// False when this build has no account service to sell or verify access.
  bool get hasGate => widget.ensureAccess != null;

  bool canOpen(HathaCourse course, String lessonId) =>
      _subscribed || isFreeLesson(course, lessonId);

  /// Free lessons open at once. Paid lessons run the gate; without a gate
  /// (no account service in this build) they stay closed.
  Future<bool> requestOpen(
    BuildContext context,
    HathaCourse course,
    String lessonId,
  ) async {
    if (canOpen(course, lessonId)) return true;
    final Future<bool> Function(BuildContext)? gate = widget.ensureAccess;
    if (gate == null) return false;
    final bool allowed = await gate(context);
    if (allowed && mounted) setState(() => _subscribed = true);
    return allowed;
  }

  @override
  Widget build(BuildContext context) => _CourseAccessScope(
    state: this,
    subscribed: _subscribed,
    child: widget.child,
  );
}

class _CourseAccessScope extends InheritedWidget {
  const _CourseAccessScope({
    required this.state,
    required this.subscribed,
    required super.child,
  });

  final LissomCourseAccessState state;
  final bool subscribed;

  @override
  bool updateShouldNotify(_CourseAccessScope old) =>
      old.subscribed != subscribed;
}
