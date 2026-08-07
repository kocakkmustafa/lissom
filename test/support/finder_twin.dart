/// **POZİTİF İKİZ — "aracım çalışıyor mu?" (L-255).**
///
/// JabLab bir testi **vakum-doğru** geçerken yakaladı: `FilledButton`ı
/// `ButtonStyleButton` diye aramak **her zaman sıfır** döndürüyor —
/// `find.byType` **alt sınıfları eşleştirmez.** Test yeşildi ve hiçbir şey
/// ölçmüyordu.
///
/// > ***Sıfır bekleyen bir kapı, bozuk aracı asla göstermez.***
///
/// **Bu bende özellikle pahalı, çünkü kapılarımın çoğu YOKLUK ölçüyor:**
/// *"gauge yok"* · *"tezahürat yok"* · *"tıbbi dil yok"* ·
/// *"`improved`/`worsened` yok"*. Yokluk ölçen bir kapı **zaten sıfır
/// bekler**, yani **bozuk bir bulucu ile doğru bir sonuç birbirinden ayırt
/// edilemez.**
///
/// Bu, *"vakum kapısı ölçüm araçlarına da gerekir"* dersinin **tamamlayıcısı**
/// ve ikisi FARKLI şeyi yakalar:
///   - **vakum kapısı** → *"hiç bulamadım"*
///   - **pozitif ikiz** → *"aracım bozuk"*
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// [probe] içeren asgari bir ağaç kurar ve [finder]'ın onu GERÇEKTEN
/// bulduğunu doğrular.
///
/// Kullanımı zorunlu olduğu yer: **bir yokluk iddiasının yanı.**
/// `expect(find.byType(X), findsNothing)` tek başına, `X`in yanlış/soyut bir
/// tip olduğu durumda da geçer — ve o hâlde sonsuza kadar yeşil kalır.
Future<void> expectFinderWorks(
  WidgetTester tester, {
  required Widget probe,
  required Finder finder,
  required String what,
}) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: probe)));
  await tester.pump();
  expect(finder, findsWidgets,
      reason: 'BULUCU BOZUK: «$what» — bu bulucu, olması GEREKEN şeyi bile '
          'bulamıyor. Onunla yazılmış her `findsNothing` iddiası vakum-doğru '
          've sonsuza kadar yeşil.');
}

/// Yokluk iddialarının kullandığı `CustomPaint` yüklemi — **tek adres.**
///
/// Yüklem burada yaşıyor ki hem yokluk iddiası hem pozitif ikiz **aynı** kodu
/// kullansın. İki ayrı kopya olsaydı, ikiz kendi kopyasının çalıştığını
/// kanıtlar, asıl iddianınkini değil.
Iterable<Element> paintersIn(WidgetTester tester) =>
    find.byType(CustomPaint).evaluate().where(
        (Element e) => (e.widget as CustomPaint).painter != null);

/// Kanıt için: gerçekten çizen bir `CustomPaint`.
class ProbePainter extends CustomPainter {
  const ProbePainter();
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// **UYGULAMANIN ÇİZDİĞİ** painter'lar — çerçevenin kendi çizimi HARİÇ.
///
/// [paintersIn] tam kabukta **fazla genişti**: Flutter'ın `Material` widget'ı
/// her kart/çubuk için `_ShapeBorderPainter` üretiyor. O painter'ları
/// yasaklamak, **ürün doğru davranırken kırmızıya dönen** bir kapı olurdu
/// (JabLab dersi).
///
/// Ayrım **türetilmiş**, elle yazılmış liste değil: çerçevenin dahili
/// painter'ları kütüphane-özel (`_` ile başlar); sevk edilen bir uygulama
/// painter'ı ise **public** bir sınıftır.
///
/// ⚠️ **Bu katmanın ölçmediği:** dosya-içi `_GaugePainter` gibi ÖZEL bir
/// uygulama painter'ı. Onu **kaynak katmanı** yakalar (`lib/` içinde
/// `extends CustomPainter` / `painter:` YASAK) — iki katman birlikte kapatır,
/// tek başına hiçbiri kapatmaz.
Iterable<Element> appAuthoredPainters(WidgetTester tester) =>
    paintersIn(tester).where((Element e) =>
        !'${(e.widget as CustomPaint).painter.runtimeType}'.startsWith('_'));
