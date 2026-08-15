/// `attempt_values.jsonl` — Lissom-sahipli yan defter (D13).
///
/// `JsonlSessionStore`ın kendi değişmezleri (bozuk-satır toleransı, atomik
/// yazım, sürüm ayrımı) ÇEKİRDEK testlerinde çivili ve burada TEKRARLANMAZ
/// (`assessment_history_test.dart`ın kendi kuralı). Ama bu depo ÇEKİRDEK
/// DEĞİL — Lissom-sahipli, yeni kod, hiçbir yerde başka test yok. Üçlü
/// sabotaj burada (bozuk / yanlış-tip / bilinmeyen-şema) ZORUNLU: bu
/// dosyanın kendisi ölçmezse, hiçbir şey ölçmez.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/attempt_values.dart';

void main() {
  late Directory tmp;
  late File f;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('lissom_attempt_values');
    f = File('${tmp.path}/attempt_values.jsonl');
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  AttemptValue value({
    String lessonId = 'overhead_reach:right',
    double v = 147.5,
    DateTime? at,
  }) =>
      AttemptValue(
        lessonId: lessonId,
        completedAt: at ?? DateTime.utc(2026, 8, 16, 10),
        value: v,
        unit: 'deg',
        tier: 'measuredBelowRange',
        bandLabel: null,
        lowestBandFloor: 150,
        provenance: const <String, String>{
          'model': 'pose_landmarker_full',
          'batteryVersion': 'v1',
        },
      );

  group('gerçek yazıp-okuma turu', () {
    test('yazılan değer diske iniyor ve TÜM alanlar hayatta kalıyor',
        () async {
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      await store.append(value());

      expect(f.existsSync(), isTrue, reason: 'dosya HİÇ oluşmadı');
      final List<AttemptValue> back = await store.forLesson('overhead_reach:right');
      expect(back, hasLength(1));
      expect(back.single.value, 147.5,
          reason: 'ölçülen SAYININ KENDİSİ — bu dosyanın var olma sebebi');
      expect(back.single.unit, 'deg');
      expect(back.single.tier, 'measuredBelowRange');
      expect(back.single.lowestBandFloor, 150);
      expect(back.single.provenance, <String, String>{
        'model': 'pose_landmarker_full',
        'batteryVersion': 'v1',
      }, reason: 'kıyas mantığı provenance olmadan kurulamaz — ikisi de canlı');
      expect(await store.unreadableRecords(), 0);
    });

    test('sıralama YENİDEN ESKİYE — SessionStore.recent ile AYNI sözleşme',
        () async {
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      await store.append(value(v: 140, at: DateTime.utc(2026, 8, 1)));
      await store.append(value(v: 150, at: DateTime.utc(2026, 8, 10)));

      final List<AttemptValue> back = await store.forLesson('overhead_reach:right');
      expect(back.map((AttemptValue v) => v.value).toList(), <double>[150, 140],
          reason: '"SON DEĞER" sırayı bu sözleşmeye güvenerek okuyacak — '
              'tersse en son ölçülen, en eski gösterilir');
    });

    test('yalnız İSTENEN lessonId döner — testler arasına sızma yok',
        () async {
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      await store.append(value(lessonId: 'overhead_reach:right', v: 150));
      await store.append(value(lessonId: 'overhead_reach:left', v: 90));

      final List<AttemptValue> right = await store.forLesson('overhead_reach:right');
      expect(right, hasLength(1));
      expect(right.single.value, 150,
          reason: 'sol tarafın değeri sağın trendine karışırsa asimetri '
              'ortalamada kaybolur — aynı sınıf risk assessment_history\'de '
              'zaten ölçülü (taraf anahtarı)');
    });
  });

  group('ilk açılış BOŞ geçmiştir, KAYIP geçmiş değil', () {
    test('yok olan dosya ok/0 okur, çökmez', () async {
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      expect(f.existsSync(), isFalse, reason: 'çapa — dosya GERÇEKTEN yok');
      expect(await store.forLesson('overhead_reach:right'), isEmpty);
      expect(await store.unreadableRecords(), 0,
          reason: 'ilk açılış "hiç yazılmadı"dır, "okunamadı" değil');
    });
  });

  group('ÜÇLÜ SABOTAJ — H-26/M-F-228 sınıfı, sessiz kayıp YOK', () {
    test('BOZUK satır: geçmişi silmez, sayılır, taşınır', () async {
      await f.writeAsString(
        '${'{"v":1,"lessonId":"overhead_reach:right","completedAt":'
            '"2026-08-16T10:00:00.000Z","value":150,"unit":"deg",'
            '"tier":"scored","provenance":{}}'}\n'
        'BU SATIR JSON DEĞİL — güç kaybı ortasında kesilmiş yazım\n',
      );
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      final List<AttemptValue> back = await store.forLesson('overhead_reach:right');

      expect(back, hasLength(1),
          reason: 'SAĞLAM satır bozuk satırın yanında bile OKUNMALI — bir '
              'kusur ayları ikinci kez kaybettirmemeli');
      expect(await store.unreadableRecords(), 1,
          reason: 've bozukluk SESSİZ olmamalı — sayılıp yüzeye taşınmalı');
    });

    test('YANLIŞ TİP: value bir dize ise satır atlanır, çökme YOK', () async {
      await f.writeAsString(
        '{"v":1,"lessonId":"overhead_reach:right","completedAt":'
        '"2026-08-16T10:00:00.000Z","value":"yüz elli","unit":"deg",'
        '"tier":"scored","provenance":{}}\n',
      );
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      final List<AttemptValue> back = await store.forLesson('overhead_reach:right');
      expect(back, isEmpty, reason: 'tip-hatalı satır bir DEĞER üretemez');
      expect(await store.unreadableRecords(), 1,
          reason: 'tip hatası bir crash DEĞİL bir SAYILI kayıp olmalı '
              '(try/catch Object, yalnız FormatException değil)');
    });

    test('BİLİNMEYEN ŞEMA: v alanı bu yazıcının sürümünden farklıysa '
        'sessizce atlanır (H-21 dersi)', () async {
      await f.writeAsString(
        '{"v":99,"lessonId":"overhead_reach:right","completedAt":'
        '"2026-08-16T10:00:00.000Z","value":150,"unit":"deg",'
        '"tier":"scored","provenance":{}}\n',
      );
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      final List<AttemptValue> back = await store.forLesson('overhead_reach:right');

      expect(back, isEmpty,
          reason: 'bu okuyucu v99u tanımıyor — uydurma bir okuma yerine '
              'ATLAMA doğru');
      expect(await store.unreadableRecords(), 1,
          reason: 'H-21: sürümsüz/bilinmeyen-sürümlü kayıt SESSİZCE '
              'atlanmamalı — sınıfını yaz, say');
    });

    test('SÜRÜM ALANI HİÇ YOKSA (v eksik) de aynı sınıfa girer — '
        'varsayılan 0 asla `schemaVersion`a eşit değil', () async {
      await f.writeAsString(
        '{"lessonId":"overhead_reach:right","completedAt":'
        '"2026-08-16T10:00:00.000Z","value":150,"unit":"deg",'
        '"tier":"scored","provenance":{}}\n',
      );
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      expect(await store.forLesson('overhead_reach:right'), isEmpty);
      expect(await store.unreadableRecords(), 1,
          reason: 'H-21in kendi vakası: sürümsüz kayıt sessizce atlanırdı — '
              'burada SAYILI atlanıyor mu, asıl soru bu');
    });
  });

  group('atomik yazım — yarım satır bir sonraki okumayı bozmaz', () {
    test('.tmp dosyası okuma yolunda GÖRÜNMEZ', () async {
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);
      await store.append(value());
      expect(File('${f.path}.tmp').existsSync(), isFalse,
          reason: 'rename sonrası geçici dosya KALMAMALI — kalırsa bir '
              'sonraki yazım onu görmez ama kullanıcı diskte yetim bir '
              'dosya biriktirir');
    });
  });
}
