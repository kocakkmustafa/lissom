/// Widget testleri için [AppFacts] kurucusu — config DOSYADAN okunur.
///
/// `rootBundle` widget testinde kilitlenebiliyor (aile gotcha'sı), o yüzden
/// üretim kodu yükleyiciyi enjekte edilebilir bıraktı ve testler bu yolu
/// kullanır. Config **gerçek** dosyadır: sahte bir batarya kurmak, yüzeyin
/// gerçek metinle taşıp taşmadığını ölçmeyi imkânsız kılardı (aile dersi:
/// gerçek metin fixture'dan uzundur).
library;

import 'dart:io';

import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

Battery batteryFromDisk() => Battery.parseJson(
  File('config/tests/lissom-assessment.v1.json').readAsStringSync(),
);

LibraryIa iaFromDisk() =>
    LibraryIa.parseJson(File('config/ia/library.v1.json').readAsStringSync());

/// Geçmiş katmanı ENJEKTE edilir — üç hâlin (ok · partial · unavailable)
/// üçü de sınanabilsin diye. Varsayılan: boş ve sağlıklı.
AppFacts factsFromDisk({SessionHistoryView? history}) {
  final Battery battery = batteryFromDisk();
  return AppFacts(
    ia: iaFromDisk(),
    battery: battery,
    liveness: deriveLiveness(battery),
    history: history ?? const SessionHistoryView.ok(<SessionRecord>[]),
    hatha: HathaCourse.parse(
      File('config/courses/hatha.v1.json').readAsStringSync(),
    ),
    hathaProgress: const HathaProgress(
      records: <HathaPracticeRecord>[],
      unreadableRecords: 0,
    ),
  );
}

/// Tek kayıtlık gerçekçi geçmiş — alanları çekirdeğin şemasından, uydurma
/// alan YOK.
SessionRecord recordOf({
  required String lessonId,
  required String lessonClass,
  DateTime? at,
  int unmeasuredUnits = 0,
  String? unmeasuredReason,
}) => SessionRecord(
  lessonId: lessonId,
  completedAt: at ?? DateTime.utc(2026, 8, 3, 9, 30),
  workedSeconds: 12,
  unitsCompleted: lessonClass == 'notMeasured' ? 0 : 1,
  unmeasuredUnits: unmeasuredUnits,
  unmeasuredReason: unmeasuredReason,
  plannedUnits: 1,
  unitLabel: 'attempt',
  lessonClass: lessonClass,
);
