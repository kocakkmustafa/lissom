/// A5 yapı testleri — statü-örgüsünün YÜZEYDE çivilenmesi.
///
/// Buradaki testlerin çoğu "şu metin var mı" değil **"hangi BÖLÜMDE"** sorusunu
/// sorar. Sadece varlığı soran bir test, iki bölüm birleştirilse bile geçerdi.
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/battery_summary_view.dart';
import 'package:lissom/app/summary_strings.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/narrow_surface.dart';

Battery _battery() => Battery.parseJson(
    File('config/tests/lissom-assessment.v1.json').readAsStringSync());

AssessmentResult _measured(String id, double v,
        {Map<String, double>? bands, String? lesson}) =>
    AssessmentResult.measured(
      testId: id,
      side: 'right',
      value: v,
      unit: 'deg',
      provenance: const <String, String>{'t': 'x'},
      bandFloors: bands,
      lessonClass: lesson,
    );

void main() {
  BatterySummary summaryOf(Map<String, AssessmentResult> results) =>
      BatterySummary.from(battery: _battery(), results: results);

  // Tek nokta: HER `testWidgets` bu yoldan pompalıyor, o yüzden en-dar-cihaz
  // sabitlemesi burada — 9 çağrı sitesine dokunmaya gerek yok ve yeni bir
  // test yazan biri unutamaz (L-214 aile standardı, Ostinato ölçtü: varsayılan
  // test yüzeyi 800pt, gerçek en-dar telefonun neredeyse iki katı).
  Future<void> pump(WidgetTester tester, BatterySummary s) {
    pinNarrowSurface(tester);
    return tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BatterySummaryView(summary: s),
    ));
  }

  Finder inSection(Key section, String text) =>
      find.descendant(of: find.byKey(section), matching: find.text(text));

  /// Bir satırın TÜM metinleri — envanter testi için. Bir dolum-çubuğu ya da
  /// hedef sayısı eklenirse envanter DEĞİŞİR, yani test kırılır.
  List<String> textsIn(WidgetTester tester, Key rowKey) => tester
      .widgetList<Text>(
          find.descendant(of: find.byKey(rowKey), matching: find.byType(Text)))
      .map((Text t) => t.data ?? '')
      .toList(growable: false);

  group('bölümler yüzeyde AYRIK', () {
    testWidgets('measurementOnly satırının gerekçesi notCompared bölümünde, '
        'scored bölümünde DEĞİL', (WidgetTester tester) async {
      final BatterySummary s = summaryOf(<String, AssessmentResult>{
        'overhead_reach': _measured('overhead_reach', 150,
            bands: <String, double>{'low': 130}, lesson: 'measurementOnly'),
        'lateral_bend':
            _measured('lateral_bend', 30, bands: <String, double>{'low': 18}),
      });
      await pump(tester, s);
      final String note = s.notCompared.single.userNote!;
      expect(inSection(BatterySummaryView.notComparedSectionKey, note),
          findsOneWidget);
      expect(inSection(BatterySummaryView.scoredSectionKey, note), findsNothing,
          reason: 'kıyaslanmamış ölçümün gerekçesi bantlı bölümde görünürse '
              'kullanıcı sayıyı KIYASLANMIŞ okur (M-F-186)');
    });

    testWidgets('measurementOnly değeri notCompared bölümünde GÖRÜNÜR — '
        'ölçüm çalıştı, saklanmıyor', (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'overhead_reach':
                _measured('overhead_reach', 150, lesson: 'measurementOnly'),
          }));
      expect(
          inSection(BatterySummaryView.notComparedSectionKey,
              SummaryStrings.value(150, 'deg')),
          findsOneWidget);
    });

    testWidgets('notCompared, notMeasured\'dan ÖNCE gelir',
        (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'overhead_reach':
                _measured('overhead_reach', 150, lesson: 'measurementOnly'),
            'lateral_bend': AssessmentResult.notMeasured(
              testId: 'lateral_bend',
              side: 'right',
              code: ResultCode.trackingLost,
              provenance: const <String, String>{'t': 'x'},
            ),
          }));
      // Yerleşimden bağımsız: ListView'ın çocuk SIRASINA bakıyoruz.
      final ListView lv = tester.widget<ListView>(find.byType(ListView));
      final List<Widget> kids =
          (lv.childrenDelegate as SliverChildListDelegate).children;
      int indexOf(Key k) => kids.indexWhere((Widget w) => w.key == k);
      expect(indexOf(BatterySummaryView.notComparedSectionKey),
          lessThan(indexOf(BatterySummaryView.notMeasuredSectionKey)),
          reason: 'ölçüm satırı eksiklikler bölgesine sürüklenemez');
    });

    testWidgets('her bölüm YALNIZ kendi listesini basar — yabancı satır '
        'HANGİ ŞEKİLDE basılırsa basılsın yakalanır',
        (WidgetTester tester) async {
      final BatterySummary s = summaryOf(<String, AssessmentResult>{
        'overhead_reach':
            _measured('overhead_reach', 150, lesson: 'measurementOnly'),
        'lateral_bend':
            _measured('lateral_bend', 30, bands: <String, double>{'low': 18}),
        'deep_squat': _measured('deep_squat', 40, lesson: 'measurementOnly'),
      });
      await pump(tester, s);

      // Bu, metin-tabanlı ayrım testinin YAKALAYAMADIĞI kusuru kapatıyor:
      // bir notCompared satırı `_scoredRow` ile bantlı bölümün İÇİNDE
      // basılırsa ad+değer+tire görünür — gerekçesi hiç basılmaz, yani
      // "gerekçe yanlış bölümde mi" sorusu SESSİZ kalır ve kullanıcı sayıyı
      // kıyaslanmış okur. Bölümün satır KİMLİKLERİNİ saymak, render biçiminden
      // bağımsız olarak yabancı satırı görür.
      void expectSectionHolds(Key section, List<SummaryRow> own) {
        final int rows = tester
            .widgetList<Column>(find.descendant(
                of: find.byKey(section), matching: find.byType(Column)))
            .where((Column c) => c.key != section)
            .length;
        expect(rows, own.length,
            reason: 'bölüm ${own.length} satır sahibi ama $rows satır basıyor '
                '— fazlası yabancı, eksiği kayıp');
      }

      expectSectionHolds(BatterySummaryView.scoredSectionKey, s.scored);
      expectSectionHolds(
          BatterySummaryView.notComparedSectionKey, s.notCompared);
      expect(s.notCompared.length, 2, reason: 'vaka anlamlı olsun');
    });

    testWidgets('boş bölüm HİÇ basılmaz', (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'lateral_bend':
                _measured('lateral_bend', 30, bands: <String, double>{'low': 18}),
          }));
      expect(find.byKey(BatterySummaryView.scoredSectionKey), findsOneWidget);
      expect(find.byKey(BatterySummaryView.belowRangeSectionKey), findsNothing);
      expect(find.byKey(BatterySummaryView.notComparedSectionKey), findsNothing);
    });
  });

  group('SABOTAJ vakaları — bu testler kırmızı yanmak İÇİN var', () {
    testWidgets('bandın altındaki satır SADECE ad + değer + tire basar '
        '(dolum-çubuğu için hedef sayısı YOK)', (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'lateral_bend': _measured('lateral_bend', 10,
                bands: <String, double>{'low': 18, 'normal': 26}),
          }));
      final List<String> texts = textsIn(
          tester, BatterySummaryView.rowKey('belowRange', 'lateral_bend'));
      expect(texts.length, 3,
          reason: 'envanter büyüdüyse satıra bir şey eklendi — §5.1 hedef '
              'tabanı YÜZEYE çıkarmayı yasaklıyor');
      expect(texts[1], SummaryStrings.value(10, 'deg'));
      expect(texts[2], SummaryStrings.noJudgement);
      for (final String t in texts) {
        expect(t.contains('18'), isFalse,
            reason: 'en düşük bant tabanı (18) yüzeye SIZMIŞ — bu bir '
                'dolum-çubuğunun ilk adımı');
        expect(t, isNot(anyOf('low', 'normal')),
            reason: 'bandın altındaki değere bant adı verilemez');
      }
    });

    testWidgets('hiçbir yerde "yakında/beta" sözcüğü YOK',
        (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'overhead_reach':
                _measured('overhead_reach', 150, lesson: 'measurementOnly'),
            'lateral_bend':
                _measured('lateral_bend', 30, bands: <String, double>{'low': 18}),
            'thoracic_rotation': AssessmentResult.notMeasured(
              testId: 'thoracic_rotation',
              side: 'right',
              code: ResultCode.lowConfidence,
              provenance: const <String, String>{'t': 'x'},
            ),
          }));
      final List<String> all = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => (t.data ?? '').toLowerCase())
          .toList(growable: false);
      // POZİTİF ÇAPA (ikiz taraması bulgusu): yalnız-yokluk iddiası, ağaç
      // HİÇ bir şey basmasa da geçerdi. Boş bir ekranda "yasak sözcük yok"
      // doğrudur ve hiçbir şey kanıtlamaz.
      expect(all.length, greaterThan(6),
          reason: 'üç satır + başlıklar basılmalı; boş ağaçta bu tarama '
              'boşa geçer');
      expect(all, contains(SummaryStrings.header.toLowerCase()));
      for (final String word in SummaryStrings.forbiddenSurfaceWords) {
        for (final String rendered in all) {
          expect(rendered.contains(word), isFalse,
              reason: 'çalışan bir ölçümün yanında "$word" yazmak, '
                  'kullanıcının yaptığı işi sahiplenmemektir (M-F-186)');
        }
      }
    });

    // NOT: "mobilya sabitlerinin kendisi yasak sözcük taşımaz" iddiası
    // BURADAN KALDIRILDI ve `tools/status_weave_check.py`'ye taşındı.
    // Sebep ikiz taramasından çıktı: elle yazılmış bir sabit LİSTESİ
    // üzerinde dönen test, biri sabiti yeniden adlandırıp listeden
    // düşürdüğünde SESSİZCE geçmeye devam ederdi — yalnız-yokluk iddiasının
    // en sinsi hâli. Python kapısı dosyadaki TÜM `static const String`
    // değerlerini TÜRETEREK tarıyor; liste küçülemez.
  });

  group('ölçülemeyen satır', () {
    testWidgets('sebep İSİMLE görünür, sayı yerine tahmin YOK',
        (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'lateral_bend': AssessmentResult.notMeasured(
              testId: 'lateral_bend',
              side: 'right',
              code: ResultCode.trackingLost,
              provenance: const <String, String>{'t': 'x'},
            ),
          }));
      final List<String> texts = textsIn(
          tester, BatterySummaryView.rowKey('notMeasured', 'lateral_bend'));
      expect(texts.length, 2, reason: 'ad + sebep; uydurulmuş değer YOK');
      expect(texts[1], SummaryStrings.reason('trackingLost'));
    });

    test('bilinmeyen sebep kodu YUTULMAZ, kodun kendisi gösterilir', () {
      expect(SummaryStrings.reason('someNewCode'), contains('someNewCode'),
          reason: 'isimsiz bir başarısızlık L-135\'in ta kendisi');
    });
  });

  group('beyan', () {
    testWidgets('"MEASUREMENTS, NOT MARKS" yüzeyin TEPESİNDE',
        (WidgetTester tester) async {
      await pump(
          tester,
          summaryOf(<String, AssessmentResult>{
            'lateral_bend': _measured('lateral_bend', 30),
          }));
      expect(find.byKey(BatterySummaryView.headerKey), findsOneWidget);
      final ListView lv = tester.widget<ListView>(find.byType(ListView));
      final List<Widget> kids =
          (lv.childrenDelegate as SliverChildListDelegate).children;
      expect(kids.first.key, BatterySummaryView.headerKey,
          reason: 'bir satırın altına düşen beyan o satıra ait dipnot gibi '
              'okunur — bu iddia ekranın tamamı hakkında');
    });
  });
}
