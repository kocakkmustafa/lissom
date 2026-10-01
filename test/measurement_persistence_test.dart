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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom/app/attempt_values.dart';
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

/// **L-355 — GERÇEKTEN düşük-güven bir kare, `SourceStateEvent` değil.**
///
/// `_FailingStore` testi "yazma patlarsa" durumunu sınıyor — bu ONDAN
/// FARKLI: yazma sorunsuz ama ÖLÇÜMÜN KENDİSİ hiç alınamıyor, çünkü
/// kamera kaliteyi göremiyor. `motion_core`nun `ConfidenceGate.evaluate()`si
/// (pin `f13bdc9`, `confidence_gate.dart`) `required: []` geçildiğinde bile
/// `LmRegion.torso` [11,12,23,24] denetimini KOŞULSUZ yapar — torso
/// landmark'larından BİRİ `torsoThreshold` (varsayılan 0,6) altındaysa kare
/// `torsoUnreliable` ile `judgeable: false` döner. Kol açısı `_armFrame`yle
/// AYNI (elbowY: 0.15, "girişim gerçekleşseydi geçerdi") — yalnız right_
/// shoulder(12) görünürlüğü 0,1: GÜVEN düşük, HAREKET değil, iki neden
/// karışmasın diye.
PoseFrame _lowConfidenceArmFrame({int tUs = 0}) {
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      12 => const PoseLandmark(0.5, 0.35, 0, 0.1), // sağ omuz — DÜŞÜK GÜVEN
      14 => const PoseLandmark(0.5, 0.15, 0, 1),
      24 => const PoseLandmark(0.5, 0.60, 0, 1),
      _ => const PoseLandmark(0.5, 0.5, 0, 1),
    };
  });
  return PoseFrame(tUs: tUs, landmarks: lms);
}

/// `_fullAttempt()`le AYNI uzunluk/zamanlama — tek fark kare KALİTESİ,
/// böylece iki senaryo yalnız güven ekseninde ayrışır.
List<PoseSourceEvent> _lowConfidenceAttempt() => <PoseSourceEvent>[
      for (int i = 0; i <= 12; i++)
        SourceFrameEvent(_lowConfidenceArmFrame(tUs: i * 100000), size: _size),
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

/// D13 — `_persist()`in İKİNCİ yazması. Varsayılan olarak KABUL EDER: bu
/// dosyanın testleri "oturum kaydı" davranışını sınıyor, deneme-değerini
/// DEĞİL (o `attempt_values_test.dart`ta) — burada sessizce reddeden bir
/// varsayılan, ilgisiz testleri yanlış sebeple kırardı.
final class _RecordingAttemptValueStore implements AttemptValueStore {
  final List<AttemptValue> written = <AttemptValue>[];
  @override
  Future<void> append(AttemptValue value) async => written.add(value);
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async =>
      written.where((AttemptValue v) => v.lessonId == lessonId).toList();
  @override
  Future<int> unreadableRecords() async => 0;
}

Future<void> _run(
  WidgetTester tester, {
  required Future<SessionStore> Function() loader,
  Future<AttemptValueStore> Function()? attemptLoader,
  List<PoseSourceEvent>? script,
  Locale? locale,
}) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale,
    supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    theme: buildLissomTheme(),
    home: LiveCaptureScreen(
      test: _overheadReach(),
      batteryVersion: 'test',
      ageBand: 'u40',
      storeLoader: loader,
      attemptValueStoreLoader:
          attemptLoader ?? (() async => _RecordingAttemptValueStore()),
      clock: () => DateTime.utc(2026, 8, 12, 9, 30),
      sourceOverride: FakePoseSource(script ?? _fullAttempt()),
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
    final _RecordingAttemptValueStore values = _RecordingAttemptValueStore();

    await _run(tester,
        loader: () async => store, attemptLoader: () async => values);

    expect(store.written, hasLength(1),
        reason: 'kullanıcı bir ölçüm yaptı — ekran `append`i ÇAĞIRMALI. '
            'Bu çağrı 2026-08-12 öncesinde HİÇ YOKTU: `recordFor` yazılmış '
            'ama SIFIR çağıranı olan bir yoldu.');
    expect(store.written.single.lessonId, 'overhead_reach:right');
    expect(store.written.single.completedAt, DateTime.utc(2026, 8, 12, 9, 30));

    // D13 — İKİNCİ yazma da GERÇEKTEN çağrılıyor mu, yoksa yalnız birinci mi
    // çalışıyor? Bu satır olmadan bir regresyon (attempt-value yazması
    // sessizce atlanır) bu testte GÖRÜNMEZ kalırdı.
    expect(values.written, hasLength(1),
        reason: 'ölçülen DEĞER de yazılmalı (D13) — yalnız oturum kaydı '
            'değil');
    expect(values.written.single.lessonId, 'overhead_reach:right');
    expect(values.written.single.value, greaterThan(0),
        reason: 'gerçek motor bir açı üretti — sıfır/negatif sahte bir '
            'değer olurdu');
    // Sabit bir sayı VARSAYMAK yerine EKRANLA çapraz doğrula: depoya
    // yazılan ve kullanıcının gördüğü sayı AYNI olmalı — ayrışırlarsa
    // kullanıcı gördüğü sayıyı bir daha hiç göremez (L-316'nın tam
    // kendisi, yalnız yazma katmanında).
    expect(
      find.textContaining(values.written.single.value.toStringAsFixed(0)),
      findsWidgets,
      reason: 'depoya yazılan sayı ekranda gösterilenle UYUŞMUYOR',
    );

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

  testWidgets('Türkçe kayıt hatası ham işletim sistemi metnini göstermiyor',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await _run(tester,
        loader: () async => _FailingStore(), locale: const Locale('tr'));

    expect(find.textContaining('geçmişe kaydedilemedi'), findsOneWidget);
    expect(find.textContaining('Kaydetme sırasında hata oluştu'),
        findsOneWidget);
    expect(find.textContaining('disk dolu'), findsNothing);
    expect(find.byKey(const Key('liveCapture.tryAgain')), findsOneWidget);
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

  // ══ ③ DÜŞÜK GÜVEN — roadmap LIS-P0-003 Step 4, L-355 ══
  //
  // Bu dosyanın var olan üç testi "yazma başarılı/başarısız" eksenini
  // sınıyordu; HİÇBİRİ kamera KENDİSİ düşük-güvenliyken ne olduğunu
  // gerçek karelerle sınamıyordu (`ResultCode.lowConfidence` her yerde
  // yalnız DOĞRUDAN kurulan `AssessmentResult` nesneleriyle test
  // ediliyordu — bkz. workspace/DEFTER.md L-355, `grep -rn lowConfidence
  // test/` ölçümü). Bu boşluk roadmap'in kendi Step 4'üydü: "invalid
  // trial'ın ölçüm yazmadığını ve retry reason taşıdığını doğrula."
  testWidgets(
      'düşük güven → DEĞER yazılmaz, oturum kaydı yazılır, sebep İSİMLİ '
      '(L-355)', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final _RecordingStore store = _RecordingStore();
    final _RecordingAttemptValueStore values = _RecordingAttemptValueStore();

    await _run(tester,
        loader: () async => store,
        attemptLoader: () async => values,
        script: _lowConfidenceAttempt());

    // Oturum kaydı: düşük-güven deneme de bir OLAYDIR, YAZILIR (L-285'in
    // hükmü — sessizce atlanırsa yarının yüzeyi "0 deneme" der, bu yalandır).
    expect(store.written, hasLength(1),
        reason: 'düşük-güven deneme de gerçekten oldu — kaydı düşerse '
            'geçmiş "hiç denemedin" der, ki denedi');

    // AMA değer YAZILMAZ — `AssessmentResult.notMeasured`in `value`si zaten
    // null, `_persist`teki `if (r.value != null)` kapısı ikinci yazmayı hiç
    // ÇAĞIRMAMALI. Bu satır olmadan bir regresyon (sahte bir sayının ikinci
    // depoya sızması) GÖRÜNMEZ kalırdı.
    expect(values.written, isEmpty,
        reason: 'ölçülemeyen bir denemenin DEĞERİ yoktur — yazılırsa '
            'fabrikasyon bir sayı geçmişe/trend\'e karışır');

    // Ekran sahte bir açı GÖSTERMEZ — başlık literal "Not measured".
    expect(find.text('Not measured'), findsOneWidget,
        reason: 'düşük güvenden türetilmiş bir sayı ekranda GÖRÜNMEMELİ');

    // Sebep İSİMLİ gider — roadmap'in "retry reason"ı.
    expect(find.text('Reason: lowConfidence.'), findsOneWidget,
        reason: 'kullanıcı NEDEN ölçülemediğini görmeli — isimsiz "tekrar '
            'dene" yeterli değil (ResultCode.lowConfidence.name)');

    // Takip sözü yalnız GERÇEK ölçüm için — bkz. yukarıdaki "yazma
    // BAŞARISIZ" testinin AYNI ilkesi, burada NEDENİ farklı (yazma değil
    // ölçüm başarısız).
    expect(find.textContaining('we\'ll track it from here'), findsNothing,
        reason: 'ölçülmedi — "izleyeceğiz" sözü tutulamayan bir vaat olurdu');

    expect(find.byKey(const Key('liveCapture.tryAgain')), findsOneWidget,
        reason: 'retry yolu düşük-güvende de açık olmalı — çıkmaz sokak '
            'yasağı (M-F-267)');
  });
}
