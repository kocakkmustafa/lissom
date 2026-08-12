/// **ÖLÇÜM KAYDEDİLİYOR MU — ve TAKİP SÖZÜ olguya bağlı mı (L-285).**
///
/// Ölçüm (yayın-engeli turu, 2026-08-12): `live_capture_screen`de
/// `SessionStore`a yazma **SIFIR**di. Ve çeviri katmanı **zaten vardı**:
/// `recordFor` ve `appendPreserved` yazılmış, belgelenmiş, **sıfır
/// çağıranı** olan bir yoldu. *Yapılmış yol, rampası yok.*
///
/// Sonuç: kullanıcı ölçüm yapıyor, sayıyı görüyor, ekranı kapatıyor —
/// **sayı yok.** Progress ve geçmiş **kalıcı boş.** Ve sonuç ekranı
/// *"This is your starting point — **we'll track it from here**"* diyordu:
/// ***bugüne kadar TUTULAMAYAN bir vaat.***
///
/// ## Bu dosya İKİ ayrı şeyi ölçer, ve ikisi de gerekli
///
///  1. **Kayıt GERÇEKTEN diske iniyor mu** — sahte bir depoya değil,
///     çekirdeğin KENDİ `JsonlSessionStore`una, gerçek dosyaya. Sahte bir
///     depo, gerçeğin reddedeceği bir kaydı kabul edebilirdi
///     (`feedback-test-double-gercek-kural` sınıfı).
///  2. **Söz OLGUYA bağlı mı** — yazma başarısızsa *"we'll track it"*
///     cümlesi ÇIKMAMALI. Yazmayı bağlayıp cümleyi koşulsuz bırakmak,
///     kusuru bir katman derine taşımak olurdu.
///
/// ## 🪤 Neden İKİ AYRI koşum tipi (ölçülmüş bir tuzak)
///
/// İlk yazışımda ikisini TEK `testWidgets` içinde birleştirdim ve **üçü de
/// kırmızı yandı — kusur ÜRÜNDE değil TESTTEYDİ:** widget testleri
/// `FakeAsync` bölgesinde koşar ve **`pumpAndSettle` GERÇEK dosya I/O'sunu
/// BEKLEMEZ**; dosya hiç oluşmadan iddia okunuyordu.
///
/// → **Bölme:** gerçek diske yazma saf `test()` içinde (FakeAsync yok),
/// ekranın davranışı `testWidgets` içinde **kaydeden** bir depoyla. Böylece
/// *"gerçek yazıcı bu kaydı kabul ediyor mu"* ile *"ekran gerçekten
/// çağırıyor mu"* AYRI AYRI kanıtlanıyor — birleşik hâlde ikisi de
/// belirsizdi.
///
/// 🪤 Ayrıca birim `°` DEĞİL **`deg`** (config'ten gelir) — ilk iddiam
/// yanlış dizge arıyordu. *Bir yüzey iddiası, yüzeyin GERÇEK metniyle
/// yazılır, hatırlananla değil.*
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/narrow_surface.dart';

const FrameSize _size = FrameSize(1080, 1920);

/// `live_capture_screen_test.dart`ın KANONİK fixture'ı — ikinci bir kopya
/// icat edilmedi (aile kuralı: iki kaynak tek olgu).
PoseFrame _armFrame({required double elbowY, int tUs = 0}) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      12 => const PoseLandmark(0.5, 0.35, 0, 1),
      14 => PoseLandmark(0.5, elbowY, 0, 1),
      24 => const PoseLandmark(0.5, 0.60, 0, 1),
      _ => const PoseLandmark(0.5, 0.5, 0, 1),
    };
  });
  return PoseFrame(tUs: tUs, landmarks: lms);
}

TestSpec _overheadReach() => Battery.parseJson('''
{
  "id": "t", "version": "1",
  "tests": [{
    "id": "overhead_reach", "perSide": true, "holdSeconds": 2,
    "primaryMetric": "shoulder_flexion_{side}",
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": true,
      "bands": {"u40": {"low": 100}},
      "source": "TEST — kablolama sınaması, bant iddiası değil."
    },
    "movementPresence": {
      "metric": "shoulder_flexion_{side}", "op": "gte", "value": 140
    }
  }]
}
''').tests['overhead_reach']!;

List<PoseSourceEvent> _fullAttempt() => <PoseSourceEvent>[
      for (int i = 0; i <= 12; i++)
        SourceFrameEvent(_armFrame(elbowY: 0.15, tUs: i * 100000), size: _size),
    ];

/// Yazmayı REDDEDEN depo — çekirdeğin arayüzünü uygular, `append` patlar.
final class _FailingStore implements SessionStore {
  @override
  Future<void> append(SessionRecord record) async =>
      throw const FileSystemException('disk dolu (test)');
  @override
  Future<List<SessionRecord>> recent({int? limit}) async => <SessionRecord>[];
  @override
  Future<int> workedSecondsFor(String lessonId) async => 0;
  @override
  Future<int> unreadableRecords() async => 0;
}

/// KAYDEDEN depo — ekranın `append`i GERÇEKTEN çağırdığını ve HANGİ kaydı
/// verdiğini ölçer. Diske inme sorusu ayrı (saf `test()` bloğunda, gerçek
/// `JsonlSessionStore` ile).
final class _RecordingStore implements SessionStore {
  final List<SessionRecord> written = <SessionRecord>[];
  @override
  Future<void> append(SessionRecord record) async => written.add(record);
  @override
  Future<List<SessionRecord>> recent({int? limit}) async => written;
  @override
  Future<int> workedSecondsFor(String lessonId) async => 0;
  @override
  Future<int> unreadableRecords() async => 0;
}

Future<void> _run(
  WidgetTester tester, {
  required Future<SessionStore> Function() loader,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LiveCaptureScreen(
      test: _overheadReach(),
      batteryVersion: 'test',
      ageBand: 'u40',
      storeLoader: loader,
      clock: () => DateTime.utc(2026, 8, 12, 9, 30),
      sourceOverride: FakePoseSource(_fullAttempt()),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(find.byKey(const Key('liveCapture.finish')));
  await tester.pumpAndSettle();
}

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('lissom_persist'));
  tearDown(() => tmp.deleteSync(recursive: true));

  // ══ ① GERÇEK YAZICI — saf `test()`, FakeAsync YOK, gerçek dosya ══
  test('ekranın ürettiği kayıt GERÇEK JsonlSessionStore ile diske iniyor',
      () async {
    final File f = File('${tmp.path}/sessions.jsonl');
    final SessionStore store = JsonlSessionStore(f);

    // Ekranın kullandığı ÇEVİRİCİNİN AYNISI — ikinci bir kopya kurulsaydı
    // "gerçek yazıcı ekranın kaydını kabul ediyor mu" sorusu cevapsız kalırdı.
    final AssessmentResult r = AssessmentResult.measured(
      testId: 'overhead_reach',
      side: 'right',
      value: 168,
      unit: 'deg',
      provenance: <String, String>{'ageBand': 'u40'},
      bandFloors: const <String, double>{'low': 100},
      attemptMicros: 1200000,
    );
    await store.append(recordFor(
      test: _overheadReach(),
      result: r,
      completedAt: DateTime.utc(2026, 8, 12, 9, 30),
    ));

    expect(f.existsSync(), isTrue, reason: 'geçmiş dosyası HİÇ oluşmadı');
    final List<SessionRecord> saved = await store.recent();
    expect(saved, hasLength(1));
    expect(saved.single.lessonId, 'overhead_reach:right',
        reason: '`historyKeyFor` taraf dahil anahtar üretir');
    expect(saved.single.completedAt, DateTime.utc(2026, 8, 12, 9, 30),
        reason: 'kayıt zamanı ÇAĞIRANDAN gelir (enjekte edilebilir saat)');
    expect(saved.single.unitsCompleted, 1);
    expect(await store.unreadableRecords(), 0,
        reason: 'yazdığımız satırı KENDİ okuyucusu okuyamıyorsa kayıt '
            'kaybolmuş demektir (ek-yalnız depo, M-F-228 sınıfı)');
  });

  // ══ ② EKRAN GERÇEKTEN ÇAĞIRIYOR MU ══
  testWidgets('ekran ölçümü depoya YAZIYOR ve takip sözünü veriyor',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _RecordingStore store = _RecordingStore();

    await _run(tester, loader: () async => store);

    expect(store.written, hasLength(1),
        reason: 'kullanıcı bir ölçüm yaptı — ekran `append`i ÇAĞIRMALI. '
            'Bu çağrı 2026-08-12 öncesinde HİÇ YOKTU: `recordFor` yazılmış '
            'ama SIFIR çağıranı olan bir yoldu.');
    expect(store.written.single.lessonId, 'overhead_reach:right');
    expect(store.written.single.completedAt, DateTime.utc(2026, 8, 12, 9, 30));

    expect(find.text('This is your starting point — we\'ll track it from here.'),
        findsOneWidget,
        reason: 'yazma BAŞARILI — takip sözü verilebilir');
  });

  testWidgets(
      'yazma BAŞARISIZ → takip sözü VERİLMEZ, ekran çökmez, sebep söylenir',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _run(tester, loader: () async => _FailingStore());

    // ÇIKMAZ SOKAK YASAĞI: ölçüm yine görünür.
    // 🪤 Birim `deg` — `°` DEĞİL (config'ten gelir); ilk iddiam yanlış
    // dizgeyi arıyordu ve testi ürün kusuru sanacaktım.
    expect(find.byKey(const Key('liveCapture.tryAgain')), findsOneWidget,
        reason: 'POZİTİF ÇAPA — sonuç ekranı yine açık, çökme yok');

    expect(find.textContaining('we\'ll track it from here'), findsNothing,
        reason: 'KAYIT YOKKEN takip sözü vermek, kusuru bir katman derine '
            'taşımak olurdu — söz OLGUYA bağlıdır');
    expect(find.textContaining('could not be saved'), findsOneWidget,
        reason: 'sessizce yutmak yasak — kullanıcı kaydın düştüğünü bilmeli');
    expect(find.textContaining('disk dolu'), findsOneWidget,
        reason: 'sebep isimli gider (ikincil tonda)');
  });

  testWidgets('"Try again" kayıt hâlini SIFIRLAR — önceki denemenin '
      '"kaydedildi"si yeni denemeye taşınmaz', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    // `_RecordingStore` — gerçek `JsonlSessionStore` DEĞİL: widget testi
    // FakeAsync'te koşuyor ve gerçek disk I/O'su o saatte tamamlanmıyor
    // (bu dosyanın kendi tuzağı, sınıf dokümanında).
    final _RecordingStore store = _RecordingStore();
    await _run(tester, loader: () async => store);
    expect(find.textContaining('we\'ll track it from here'), findsOneWidget,
        reason: 'POZİTİF ÇAPA — ilk deneme kaydedildi');

    await tester.tap(find.byKey(const Key('liveCapture.tryAgain')));
    await tester.pump();

    // Yeni deneme HENÜZ bitmedi → sonuç ekranı yok, dolayısıyla eski
    // "kaydedildi" cümlesi de EKRANDA OLMAMALI.
    expect(find.textContaining('we\'ll track it from here'), findsNothing,
        reason: 'kayıt bir OLAY, durum değil — depo ek-yalnız; önceki '
            'denemenin hâli yeni denemenin ekranında yaşayamaz');
  });
}
