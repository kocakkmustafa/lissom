/// Progress kapısı — **karşılaştırma KAPALI hâli TASARLANMIŞTIR.**
///
/// Bu testlerin çoğu bir YOKLUK sınıyor (trend yok, improved/worsened yok) ve
/// yokluk testleri tek başına vakum-doğru olabilir (aile dersi 4: bir şeyi
/// kaldırınca onun yokluğunu iddia eden testler ölçmeyi bırakır). O yüzden her
/// yokluk iddiasının yanında bir VARLIK iddiası duruyor: kıyasın neden
/// yapılmadığı ekranda YAZILI olmalı ve defter satırları GERÇEKTEN basılmalı.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:motion_core/motion_core.dart';

import 'support/copy_gate.dart';
import 'support/finder_twin.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

Future<void> pump(WidgetTester tester, SessionHistoryView h) async {
  final AppFacts f = factsFromDisk(history: h);
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: Scaffold(body: ProgressScreen(facts: f)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('KIYAS KAPALI beyanı defterden ÖNCE ve sebebi yazılı', (
    WidgetTester tester,
  ) async {
    // Sıra iddiası → uzun yüzey (genişlik yine 375). Kısa yüzeyde defter
    // katlamanın altında kalıyor ve tembel liste onu hiç kurmuyor.
    pinTallSurface(tester);
    await pump(
      tester,
      SessionHistoryView.ok(<SessionRecord>[
        recordOf(lessonId: 'overhead_reach', lessonClass: 'measurementOnly'),
      ]),
    );

    expect(find.byKey(ProgressScreen.comparisonNoticeKey), findsOneWidget);
    // ⚠️ Burada eskiden `noticeY < 400` yazıyordu — SİHİRLİ SAYI, ve tam da
    // kendi "sayıyı değil kuralı ölç" dersimin (L-239) ihlali. Ekrana bir
    // beyan kartı eklenince 429'a kaydı ve test ürün DOĞRU değişirken
    // kırmızı yandı. Ölçülen kural: beyan defterden ÖNCE gelir.
    final double noticeY =
        tester.getTopLeft(find.byKey(ProgressScreen.comparisonNoticeKey)).dy;
    final double ledgerY =
        tester.getTopLeft(find.byKey(ProgressScreen.ledgerKey)).dy;
    expect(noticeY, lessThan(ledgerY),
        reason: 'kıyas beyanı defterin ALTINDA kalırsa, kaydırmayan kullanıcı '
            'listeyi bir ilerleme grafiği sanar');

    // Sebep GERÇEKTEN yazılı: hangi üç koşulun doğrulanamadığı.
    expect(find.textContaining('same model'), findsOneWidget);
    expect(find.textContaining('does not record any of those three'),
        findsOneWidget);
  });

  testWidgets('improved/worsened dili YOK — ve trend widget\'ı da yok', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      SessionHistoryView.ok(<SessionRecord>[
        recordOf(lessonId: 'deep_squat', lessonClass: 'measurementOnly'),
        recordOf(
            lessonId: 'deep_squat',
            lessonClass: 'measurementOnly',
            at: DateTime.utc(2026, 7, 20)),
      ]),
    );
    expectNoBannedCopy(tester);

    // ⛔ Dolum/gauge yasağı — tip düzeyinde.
    //
    // ⚠️ Bu üç iddia YOKLUK ölçüyor, yani **bozuk bir bulucu ile doğru bir
    // sonuç birbirinden ayırt edilemez** (L-255). Bulucuların çalıştığını
    // aşağıdaki POZİTİF İKİZ kanıtlıyor — o test olmadan bu satırlar
    // vakum-doğru olabilir ve sonsuza kadar yeşil kalır.
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(paintersIn(tester), isEmpty,
        reason: 'çizilmiş bir grafik/gösterge belirdi — §5.1 hükmü ölçüm için '
            'dolum/trend göstergesini yasaklıyor');
  });

  testWidgets('POZİTİF İKİZ: gauge bulucuları GERÇEKTEN buluyor (L-255)', (
    WidgetTester tester,
  ) async {
    // *Sıfır bekleyen bir kapı, bozuk aracı asla göstermez.* Gauge yasağı bu
    // ürünün en sert kuralı (§5.1: "50°'de neredeyse boş bir çubuk, grafikle
    // söylenmiş bir yetersizsin hükmüdür") — bulucusu kanıtsız kalamaz.
    pinNarrowSurface(tester);
    await expectFinderWorks(tester,
        probe: const LinearProgressIndicator(value: 0.4),
        finder: find.byType(LinearProgressIndicator),
        what: 'dolum çubuğu bulucusu');
    await expectFinderWorks(tester,
        probe: const CircularProgressIndicator(value: 0.4),
        finder: find.byType(CircularProgressIndicator),
        what: 'ilerleme halkası bulucusu');

    // `CustomPaint` YÜKLEMİ de ikizlenir — ve iddia ile ikiz AYNI fonksiyonu
    // kullanır (`paintersIn`), yoksa ikiz kendi kopyasını kanıtlar.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: CustomPaint(painter: ProbePainter(), size: Size(10, 10)),
      ),
    ));
    await tester.pump();
    expect(paintersIn(tester), isNotEmpty,
        reason: 'BULUCU BOZUK: çizen bir CustomPaint bile görülmüyor — '
            'gauge yasağının yüklemi vakum-doğru');
  });

  testWidgets('BOŞ hâl: kayıt yok — ve bu bir HATA değil', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(tester, const SessionHistoryView.ok(<SessionRecord>[]));
    await scrollTo(tester, find.byKey(ProgressScreen.emptyKey));
    expect(find.byKey(ProgressScreen.emptyKey), findsOneWidget);
    expect(find.byKey(ProgressScreen.ledgerKey), findsNothing);
    expectNoBannedCopy(tester);
  });

  testWidgets('AÇILAMADI hâli BOŞ hâlden AYRI — sayı gösterilmez', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(tester, const SessionHistoryView.unavailable('FileSystemException'));
    await scrollTo(tester, find.byKey(ProgressScreen.unavailableKey));
    expect(find.byKey(ProgressScreen.unavailableKey), findsOneWidget);
    expect(find.byKey(ProgressScreen.emptyKey), findsNothing,
        reason: '"hiç yapmadın" ile "bilmiyorum" AYNI ekranı paylaşamaz');
    expect(find.textContaining('FileSystemException'), findsOneWidget);
  });

  testWidgets('ölçülemeyen deneme DÜŞÜRÜLMEZ — sebebi isimli görünür', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      SessionHistoryView.ok(<SessionRecord>[
        recordOf(
          lessonId: 'plank_hold',
          lessonClass: 'notMeasured',
          unmeasuredUnits: 1,
          unmeasuredReason: 'trackingLost',
        ),
      ]),
    );
    await scrollTo(tester, find.byKey(ProgressScreen.ledgerKey));
    expect(find.text('Plank Hold'), findsOneWidget);
    // Ham kod SIZMAZ, kullanıcı dili görünür.
    expect(find.textContaining('trackingLost'), findsNothing);
    expect(find.textContaining('the camera lost track of you'), findsOneWidget);
  });

  testWidgets('taraf ayrımı KORUNUR — sol/sağ ortalanmaz', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      SessionHistoryView.ok(<SessionRecord>[
        recordOf(
            lessonId: 'hamstring_reach:left', lessonClass: 'measurementOnly'),
        recordOf(
            lessonId: 'hamstring_reach:right', lessonClass: 'measurementOnly'),
      ]),
    );
    await scrollTo(tester, find.byKey(ProgressScreen.ledgerKey));
    expect(find.textContaining('left', skipOffstage: false), findsOneWidget);
    expect(find.textContaining('right', skipOffstage: false), findsOneWidget);
  });
}
