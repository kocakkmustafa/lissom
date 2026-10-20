import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'hatha_course.dart';
import 'local_account_bridge.dart';
import 'local_write_guard.dart';
import 'local_owner.dart';

final class HathaPracticeRecord {
  const HathaPracticeRecord({
    required this.lessonId,
    required this.courseId,
    required this.courseVersion,
    required this.practicedAt,
  });

  final String lessonId;
  final String courseId;
  final String courseVersion;
  final DateTime practicedAt;

  Map<String, Object> toJson() => <String, Object>{
    'v': 1,
    'lessonId': lessonId,
    'courseId': courseId,
    'courseVersion': courseVersion,
    'evidence': 'self_report',
    'practicedAt': practicedAt.toUtc().toIso8601String(),
  };

  static HathaPracticeRecord parse(Map<String, dynamic> value) {
    if (value['v'] != 1 || value['evidence'] != 'self_report') {
      throw const FormatException('unsupported practice record');
    }
    final String lessonId = value['lessonId'] as String;
    final String courseId = value['courseId'] as String;
    final String version = value['courseVersion'] as String;
    final DateTime? at = DateTime.tryParse(value['practicedAt'] as String);
    if (lessonId.isEmpty || courseId.isEmpty || version.isEmpty || at == null) {
      throw const FormatException('incomplete practice record');
    }
    return HathaPracticeRecord(
      lessonId: lessonId,
      courseId: courseId,
      courseVersion: version,
      practicedAt: at,
    );
  }
}

final class HathaProgress {
  const HathaProgress({required this.records, required this.unreadableRecords});

  final List<HathaPracticeRecord> records;
  final int unreadableRecords;

  Set<String> practicedIn(HathaCourse course) => records
      .where(
        (HathaPracticeRecord r) =>
            r.courseId == course.id && r.courseVersion == course.version,
      )
      .map((HathaPracticeRecord r) => r.lessonId)
      .where((String id) => course.lessonById(id) != null)
      .toSet();

  int oldVersionCount(HathaCourse course) => records
      .where(
        (HathaPracticeRecord r) =>
            r.courseId == course.id && r.courseVersion != course.version,
      )
      .length;
}

abstract interface class HathaProgressStore {
  Future<HathaProgress> read();

  /// May be repeated. This is a practice record, never a form grade.
  Future<void> markPracticed(HathaCourse course, String lessonId);
}

final class JsonlHathaProgressStore implements HathaProgressStore {
  JsonlHathaProgressStore(
    this._file, {
    bool Function()? canWrite,
    LissomLocalOwner? owner,
  }) : _writeGuard = LissomLocalWriteGuard(_file.parent.path, owner: owner),
      _canWrite = canWrite;

  final File _file;
  final LissomLocalWriteGuard _writeGuard;
  final bool Function()? _canWrite;

  void _assertWritable() {
    if (_canWrite?.call() == false) {
      throw StateError('Account changed; reopen the course to record practice');
    }
  }

  @override
  Future<HathaProgress> read() => _writeGuard.read(_read);

  Future<HathaProgress> _read() async {
    final FileSystemEntityType type = await FileSystemEntity.type(
      _file.path,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) {
      return const HathaProgress(
        records: <HathaPracticeRecord>[],
        unreadableRecords: 0,
      );
    }
    if (type != FileSystemEntityType.file) {
      throw FileSystemException(
        'Hatha progress is not a regular file',
        _file.path,
      );
    }
    final List<HathaPracticeRecord> records = <HathaPracticeRecord>[];
    int unreadable = 0;
    for (final String raw in (await _file.readAsString()).split('\n')) {
      final String line = raw.trim();
      if (line.isEmpty) continue;
      try {
        records.add(
          HathaPracticeRecord.parse(
            (jsonDecode(line) as Map).cast<String, dynamic>(),
          ),
        );
      } on Object {
        unreadable++;
      }
    }
    return HathaProgress(
      records: List<HathaPracticeRecord>.unmodifiable(records),
      unreadableRecords: unreadable,
    );
  }

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) =>
      _writeGuard.write(() => _markPracticed(course, lessonId));

  Future<void> _markPracticed(HathaCourse course, String lessonId) async {
    _assertWritable();
    final HathaLesson? lesson = course.lessonById(lessonId);
    if (lesson == null) throw ArgumentError.value(lessonId, 'lessonId');
    // Already inside the directory's write queue. The public read barrier
    // waits for admitted writes, including this one; use the private reader.
    final HathaProgress before = await _read();
    final Set<String> practiced = before.practicedIn(course);
    if (!practiced.containsAll(lesson.prerequisites)) {
      throw StateError('Practice the prerequisite lesson first');
    }
    final HathaPracticeRecord record = HathaPracticeRecord(
      lessonId: lessonId,
      courseId: course.id,
      courseVersion: course.version,
      practicedAt: DateTime.now().toUtc(),
    );
    final String existing = await _file.exists()
        ? await _file.readAsString()
        : '';
    final String prefix = existing.isNotEmpty && !existing.endsWith('\n')
        ? '$existing\n'
        : existing;
    final String next = '$prefix${jsonEncode(record.toJson())}\n';
    final File tmp = File('${_file.path}.tmp');
    _assertWritable();
    _writeGuard.owner.checkActive();
    await tmp.parent.create(recursive: true);
    _writeGuard.owner.checkActive();
    await tmp.writeAsString(next, flush: true);
    _writeGuard.owner.checkActive();
    if (_canWrite?.call() == false) {
      await tmp.delete();
      throw StateError('Account changed; reopen the course to record practice');
    }
    await tmp.rename(_file.path);
  }
}

Future<HathaProgressStore> openHathaProgressStore({
  LissomLocalScope scope = LissomLocalScope.guest,
  bool Function()? canWrite,
}) async {
  scope.owner?.checkActive();
  final Directory support = scope.owner?.supportDirectory ??
      await getApplicationSupportDirectory();
  scope.owner?.checkActive();
  return JsonlHathaProgressStore(
    scope.file(support, LissomLocalFile.hathaProgress),
    canWrite: canWrite,
    owner: scope.owner,
  );
}
