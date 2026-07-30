/// Geçmiş kablolaması — YALNIZ benim çevirim ve delta senaryolarım.
///
/// Depo değişmezleri (bozuk-satır toleransı, atomik yazım, v1 okuma, boş
/// geçmiş yolu) ÇEKİRDEK testlerinde çivili; burada tekrarlamak, aynı iddiayı
/// iki yerde bakmak demek olurdu. Buradaki her test Lissom'a özgü bir
/// çeviri kararını sınıyor.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

Battery _battery() => Battery.parseJson(
    File('config/tests/lissom-assessment.v1.json').readAsStringSync());

final DateTime _t0 = DateTime.utc(2026, 7, 30, 9);

AssessmentResult _measured(String id, double v,
        {Map<String, double>? bands,
        String? lesson,
        String side = 'right',
        int? micros = 12_000_000}) =>
    AssessmentResult.measured(
      testId: id,
      side: side,
      value: v,
      unit: 'deg',
      provenance: const <String, String>{'t': 'x'},
      bandFloors: bands,
      lessonClass: lesson,
      attemptMicros: micros,
    );

void main() {
  late Directory tmp;
  late JsonlSessionStore store;
  final Battery battery = _battery();
  TestSpec spec(String id) => battery.tests[id]!;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lissom_hist');
    store = JsonlSessionStore(File('${tmp.path}/sessions.jsonl'));
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  group('sınıf damgası — en-az-yetki KASITLI kullanılıyor', () {
    test('measurementOnly, tier scored OLSA BİLE scored yazılmaz', () {
      // Canlı vaka: overhead_reach HEM bantlı (u40 low:150) HEM
      // measurementOnly. 150° tier=scored üretir.
      final AssessmentResult r = _measured('overhead_reach', 150,
          bands: <String, double>{'low': 130}, lesson: 'measurementOnly');
      expect(r.tier, ResultTier.scored, reason: 'vaka gerçekten bu tuzağı kurar');

      final SessionRecord rec =
          recordFor(test: spec('overhead_reach'), result: r, completedAt: _t0);
      expect(rec.lessonClass, LissomLessonClass.measurementOnly);
      expect(rec.isScoredClass, isFalse,
          reason: 'doğrulanmış referansa hiç kıyaslanmamış ölçüm geçmişe '
              'skorlanmış olarak geçemez (M-F-186)');
    });

    test('bandın altı coached — skor DEĞİL (M-F-71 madde 5 geçmişte de)', () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: _measured('lateral_bend', 10,
            bands: <String, double>{'low': 18}),
        completedAt: _t0,
      );
      expect(rec.lessonClass, LissomLessonClass.coached);
      expect(rec.isScoredClass, isFalse);
    });

    test('gerçekten kıyaslanan ölçüm scored — iddia KISILMIYOR', () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: _measured('lateral_bend', 30,
            bands: <String, double>{'low': 18, 'normal': 26}),
        completedAt: _t0,
      );
      expect(rec.lessonClass, LissomLessonClass.scored);
      expect(rec.isScoredClass, isTrue,
          reason: 'aşırı-ihtiyat da bir dürüstlük hatası: hak edilen '
              'kıyas gizlenmez');
    });

    test('bantsız test qualitative — "henüz yok" ile karışmaz', () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: _measured('lateral_bend', 30),
        completedAt: _t0,
      );
      expect(rec.lessonClass, LissomLessonClass.qualitative);
      expect(rec.lessonClass, isNot(LissomLessonClass.measurementOnly));
    });
  });

  group('ölçülemeyen deneme ilerlemeyi DÜŞÜRMEZ', () {
    test('girişim başladı, hüküm verilemedi → çalışma sayılır, sebep isimli',
        () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: AssessmentResult.notMeasured(
          testId: 'lateral_bend',
          side: 'right',
          code: ResultCode.trackingLost,
          provenance: const <String, String>{'t': 'x'},
          attemptMicros: 9_000_000,
        ),
        completedAt: _t0,
      );
      expect(rec.unitsCompleted, 0, reason: 'ölçülen birim yok');
      expect(rec.unmeasuredUnits, 1, reason: 'ama çalışma OLDU');
      expect(rec.attemptedUnits, 1);
      expect(rec.isComplete, isTrue,
          reason: 'analiz edilemeyen deneme ilerlemeyi ASLA düşürmez');
      expect(rec.unmeasuredReason, 'trackingLost');
      expect(rec.workedSeconds, 9);
    });

    test('girişim HİÇ algılanmadı → sayılacak çalışma da yok', () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: AssessmentResult.notMeasured(
          testId: 'lateral_bend',
          side: 'right',
          code: ResultCode.noAttemptDetected,
          provenance: const <String, String>{'t': 'x'},
        ),
        completedAt: _t0,
      );
      expect(rec.unmeasuredUnits, 0,
          reason: '"çalışma olmadı" ile "çalışma oldu ama ölçülemedi" '
              'farklı iddialar');
      expect(rec.workedSeconds, 0);
      expect(rec.isComplete, isFalse);
    });
  });

  group('birim beyanı ÖLÇÜLENİ söyler', () {
    test('config reps:3 derken kayıt 1 deneme der', () {
      // Ölçüm: reps alanının okuyucusu YOK, motor finish() başına TEK
      // deneme penceresi kapatıyor. plannedUnits:3 yazmak her testi
      // sonsuza dek 1/3 tamamlanmamış gösterirdi.
      final SessionRecord rec = recordFor(
        test: spec('overhead_reach'),
        result: _measured('overhead_reach', 150, lesson: 'measurementOnly'),
        completedAt: _t0,
      );
      expect(rec.plannedUnits, 1);
      expect(rec.unitLabel, 'attempt');
      expect(rec.isComplete, isTrue,
          reason: 'kullanıcı uygulamanın İSTEDİĞİ her şeyi yaptı');
    });

    test('workedSeconds deneme penceresinden — duvar saatinden DEĞİL', () {
      final SessionRecord rec = recordFor(
        test: spec('lateral_bend'),
        result: _measured('lateral_bend', 30, micros: 4_400_000),
        completedAt: _t0,
      );
      expect(rec.workedSeconds, 4,
          reason: 'hazırlık fazı dâhil edilse kazanılmayan kapılar geçilirdi');
    });
  });

  group('geçmiş anahtarı', () {
    test('perSide testte taraf anahtarda — asimetri ortalamada kaybolmaz',
        () async {
      final TestSpec t = spec('overhead_reach');
      expect(t.perSide, isTrue);
      await store.append(recordFor(
          test: t,
          result: _measured('overhead_reach', 170,
              side: 'right', lesson: 'measurementOnly'),
          completedAt: _t0));
      await store.append(recordFor(
          test: t,
          result: _measured('overhead_reach', 120,
              side: 'left', micros: 8_000_000, lesson: 'measurementOnly'),
          completedAt: _t0.add(const Duration(minutes: 1))));

      expect(await store.workedSecondsFor('overhead_reach:right'), 12);
      expect(await store.workedSecondsFor('overhead_reach:left'), 8);
      expect(await store.workedSecondsFor('overhead_reach'), 0,
          reason: 'taraflar tek seriye KATILMIYOR — donuk sol omuz ile '
              'hareketli sağ omuz "ortalama iyi" diye okunamaz');
    });

    test('çift-taraflı testte uydurma taraf ayrımı YOK', () {
      final TestSpec t = spec('deep_squat');
      expect(t.perSide, isFalse);
      expect(historyKeyFor(t, 'bilateral'), 'deep_squat');
    });
  });

  group('yarım oturum geçmişe SIZMAZ (M-F-133/3)', () {
    test('yalnız tamamlanmış blokların ölçümleri yazılır', () async {
      final BlockConfig cfg = BlockConfig.parse(
        jsonDecode(File('config/tests/assessment-blocks.v1.json')
            .readAsStringSync()) as Map<String, dynamic>,
        batteryTestIds: battery.tests.keys.toSet(),
      );
      final AssessmentSession s = AssessmentSession(blocks: cfg.blocks);
      final AssessmentBlock first = cfg.blocks.first;
      s.beginBlock(first.id, calibrationProfile: 'cal-A');
      for (final String id in first.testIds) {
        s.record(first.id, _measured(id, 100));
      }
      final AssessmentBlock second = cfg.blocks[1];
      s.beginBlock(second.id, calibrationProfile: 'cal-B');
      s.record(second.id, _measured(second.testIds.first, 30));

      final int written = await appendPreserved(
        session: s, battery: battery, store: store, completedAt: _t0);
      expect(written, first.testIds.length);
      final List<SessionRecord> back = await store.recent();
      expect(back.length, first.testIds.length);
      expect(
          back.any((SessionRecord r) =>
              r.lessonId.startsWith(second.testIds.first)),
          isFalse,
          reason: 'yarım bloğun ölçümü kalıcılaşırsa tek-kalibrasyon kuralı '
              'geçmiş katmanından sessizce gevşer');
    });
  });

  group('yazıp okuma turu — benim alanlarım hayatta kalıyor', () {
    test('measurementOnly sınıfı diskten geri okunduğunda KORUNUR', () async {
      await store.append(recordFor(
        test: spec('overhead_reach'),
        result: _measured('overhead_reach', 150,
            bands: <String, double>{'low': 130}, lesson: 'measurementOnly'),
        completedAt: _t0,
      ));
      final SessionRecord back = (await store.recent()).single;
      expect(back.lessonClass, LissomLessonClass.measurementOnly);
      expect(back.isScoredClass, isFalse,
          reason: 'sınıf yazım anında damgalanır; disk turu onu skorlanmışa '
              'çeviremez');
      expect(back.unitLabel, 'attempt');
      expect(back.workedSeconds, 12);
    });
  });
}
