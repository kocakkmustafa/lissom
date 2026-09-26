import 'dart:convert';

/// A guided lesson is teachable without camera evidence. The only accepted
/// completion mode in this first course is the learner's own practice record.
enum HathaEvidenceMode { selfReport }

final class HathaText {
  const HathaText(this.en, this.tr);

  factory HathaText.read(Object? raw, String path) {
    if (raw is! Map) throw FormatException('$path must be translated');
    final String? en = raw['en'] as String?;
    final String? tr = raw['tr'] as String?;
    if (en == null || tr == null || en.trim().isEmpty || tr.trim().isEmpty) {
      throw FormatException('$path needs nonempty en and tr');
    }
    return HathaText(en.trim(), tr.trim());
  }

  final String en;
  final String tr;
}

final class HathaLesson {
  const HathaLesson({
    required this.id,
    required this.title,
    required this.objective,
    required this.steps,
    required this.practice,
    required this.selfCheck,
    required this.adaptation,
    required this.stopSignal,
    required this.mediaBrief,
    required this.sourceIds,
    required this.prerequisites,
    required this.minutes,
    required this.evidenceMode,
  });

  final String id;
  final HathaText title;
  final HathaText objective;
  final List<HathaText> steps;
  final HathaText practice;
  final HathaText selfCheck;
  final HathaText adaptation;
  final HathaText stopSignal;
  final HathaText mediaBrief;
  final List<String> sourceIds;
  final List<String> prerequisites;
  final int minutes;
  final HathaEvidenceMode evidenceMode;
}

final class HathaModule {
  const HathaModule({
    required this.id,
    required this.title,
    required this.outcome,
    required this.lessons,
  });

  final String id;
  final HathaText title;
  final HathaText outcome;
  final List<HathaLesson> lessons;
}

final class HathaCourse {
  const HathaCourse({
    required this.id,
    required this.version,
    required this.title,
    required this.intro,
    required this.sources,
    required this.modules,
  });

  factory HathaCourse.parse(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('course must be an object');
    }
    if (decoded['schemaVersion'] != 1) {
      throw const FormatException('unsupported Hatha course schema');
    }
    final String id = _id(decoded['id'], 'id');
    final String version = _required(decoded['version'], 'version');
    final Object? rawSources = decoded['sources'];
    if (rawSources is! Map || rawSources.isEmpty) {
      throw const FormatException('sources must not be empty');
    }
    final Map<String, String> sources = <String, String>{};
    for (final MapEntry<dynamic, dynamic> entry in rawSources.entries) {
      final String sourceId = _id(entry.key, 'source ID');
      final String url = _required(entry.value, 'source $sourceId');
      final Uri? uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
        throw FormatException('source $sourceId must be an HTTPS URL');
      }
      sources[sourceId] = url;
    }
    final Object? rawModules = decoded['modules'];
    if (rawModules is! List || rawModules.isEmpty) {
      throw const FormatException('modules must not be empty');
    }
    final Set<String> moduleIds = <String>{};
    final Set<String> priorLessonIds = <String>{};
    final List<HathaModule> modules = <HathaModule>[];
    for (final Object? moduleRaw in rawModules) {
      if (moduleRaw is! Map) {
        throw const FormatException('module is not an object');
      }
      final String moduleId = _id(moduleRaw['id'], 'module ID');
      if (!moduleIds.add(moduleId)) {
        throw FormatException('duplicate module $moduleId');
      }
      final Object? rawLessons = moduleRaw['lessons'];
      if (rawLessons is! List || rawLessons.isEmpty) {
        throw FormatException('$moduleId has no lessons');
      }
      final List<HathaLesson> lessons = <HathaLesson>[];
      for (final Object? lessonRaw in rawLessons) {
        if (lessonRaw is! Map) {
          throw FormatException('$moduleId contains a non-object lesson');
        }
        final String lessonId = _id(lessonRaw['id'], 'lesson ID');
        if (priorLessonIds.contains(lessonId)) {
          throw FormatException('duplicate lesson $lessonId');
        }
        final List<String> prerequisites = _ids(
          lessonRaw['prerequisites'],
          '$lessonId.prerequisites',
        );
        for (final String prerequisite in prerequisites) {
          if (!priorLessonIds.contains(prerequisite)) {
            throw FormatException(
              '$lessonId has a missing or later prerequisite '
              '$prerequisite',
            );
          }
        }
        final List<String> sourceIds = _ids(
          lessonRaw['sourceIds'],
          '$lessonId.sourceIds',
        );
        if (sourceIds.isEmpty ||
            sourceIds.any(
              (String sourceId) => !sources.containsKey(sourceId),
            )) {
          throw FormatException('$lessonId has missing or unknown sources');
        }
        final Object? stepRaw = lessonRaw['steps'];
        if (stepRaw is! List || stepRaw.length < 4) {
          throw FormatException('$lessonId needs at least four teaching steps');
        }
        final int? minutes = (lessonRaw['minutes'] as num?)?.toInt();
        if (minutes == null || minutes < 3 || minutes > 60) {
          throw FormatException('$lessonId has invalid minutes');
        }
        // There is no yoga holdout. Reject any accidental scoring promise in
        // content instead of hiding it behind presentation copy.
        if (lessonRaw['evidenceMode'] != 'self_report') {
          throw FormatException('$lessonId requests unsupported evidence mode');
        }
        lessons.add(
          HathaLesson(
            id: lessonId,
            title: HathaText.read(lessonRaw['title'], '$lessonId.title'),
            objective: HathaText.read(
              lessonRaw['objective'],
              '$lessonId.objective',
            ),
            steps: stepRaw
                .map<HathaText>(
                  (Object? x) => HathaText.read(x, '$lessonId.steps'),
                )
                .toList(growable: false),
            practice: HathaText.read(
              lessonRaw['practice'],
              '$lessonId.practice',
            ),
            selfCheck: HathaText.read(
              lessonRaw['selfCheck'],
              '$lessonId.selfCheck',
            ),
            adaptation: HathaText.read(
              lessonRaw['adaptation'],
              '$lessonId.adaptation',
            ),
            stopSignal: HathaText.read(
              lessonRaw['stopSignal'],
              '$lessonId.stopSignal',
            ),
            mediaBrief: HathaText.read(
              lessonRaw['mediaBrief'],
              '$lessonId.mediaBrief',
            ),
            sourceIds: List<String>.unmodifiable(sourceIds),
            prerequisites: List<String>.unmodifiable(prerequisites),
            minutes: minutes,
            evidenceMode: HathaEvidenceMode.selfReport,
          ),
        );
        priorLessonIds.add(lessonId);
      }
      modules.add(
        HathaModule(
          id: moduleId,
          title: HathaText.read(moduleRaw['title'], '$moduleId.title'),
          outcome: HathaText.read(moduleRaw['outcome'], '$moduleId.outcome'),
          lessons: List<HathaLesson>.unmodifiable(lessons),
        ),
      );
    }
    return HathaCourse(
      id: id,
      version: version,
      title: HathaText.read(decoded['title'], 'title'),
      intro: HathaText.read(decoded['intro'], 'intro'),
      sources: Map<String, String>.unmodifiable(sources),
      modules: List<HathaModule>.unmodifiable(modules),
    );
  }

  final String id;
  final String version;
  final HathaText title;
  final HathaText intro;
  final Map<String, String> sources;
  final List<HathaModule> modules;

  List<HathaLesson> get lessons => modules
      .expand<HathaLesson>((HathaModule module) => module.lessons)
      .toList(growable: false);

  HathaLesson? lessonById(String lessonId) {
    for (final HathaLesson lesson in lessons) {
      if (lesson.id == lessonId) return lesson;
    }
    return null;
  }
}

String _required(Object? raw, String path) {
  if (raw is! String || raw.trim().isEmpty) {
    throw FormatException('$path must not be empty');
  }
  return raw.trim();
}

String _id(Object? raw, String path) {
  final String value = _required(raw, path);
  if (!RegExp(r'^[a-z][a-z0-9._-]*$').hasMatch(value)) {
    throw FormatException('$path has invalid characters');
  }
  return value;
}

List<String> _ids(Object? raw, String path) {
  if (raw is! List) throw FormatException('$path must be a list');
  final List<String> ids = raw
      .map<String>((Object? x) => _id(x, path))
      .toList(growable: false);
  if (ids.toSet().length != ids.length) {
    throw FormatException('$path contains duplicates');
  }
  return ids;
}
