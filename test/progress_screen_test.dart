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
  testWidgets('KIYAS KAPALI beyanı ekranın TEPESİNDE ve sebebi yazılı', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(
      tester,
      SessionHistoryView.ok(<SessionRecord>[
        recordOf(lessonId: 'overhead_reach', lessonClass: 'measurementOnly'),
      ]),
    );

    expect(find.byKey(ProgressScreen.comparisonNoticeKey), findsOneWidget);
    // Beyan, defterden ÖNCE gelmeli — aşağıda olsaydı kaydırmayan kullanıcı
    // listeyi bir ilerleme grafiği sanardı.
    final double noticeY =
        tester.getTopLeft(find.byKey(ProgressScreen.comparisonNoticeKey)).dy;
    await scrollTo(tester, find.byKey(ProgressScreen.ledgerKey));
    expect(noticeY, lessThan(400));

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
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CustomPaint).evaluate().where((Element e) {
      final CustomPaint p = e.widget as CustomPaint;
      return p.painter != null;
    }), isEmpty,
        reason: 'çizilmiş bir grafik/gösterge belirdi — §5.1 hükmü ölçüm için '
            'dolum/trend göstergesini yasaklıyor');
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
