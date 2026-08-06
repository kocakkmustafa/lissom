/// Aile standardı (Ostinato ölçtü, 2026-08-06): `flutter_test`in varsayılan
/// yüzeyi **800 mantıksal piksel** — gerçek en-dar yaygın telefonun
/// (iPhone SE, 375pt) neredeyse İKİ KATI. Bu genişlikte koşan bir taşma testi
/// YEŞİL yanabilir ve YANLIŞ GÜVEN verir; Ostinato tam bunu ölçtü (Live
/// ekranının başlık çubuğu 375pt'e sabitlenince 112–195px taştı, 800pt'te
/// hiçbir işaret yoktu).
///
/// `pumpWidget` çağıran HER taşma/yerleşim testi bu genişliğe SABİTLENİR —
/// tercih değil, kapı. Ekran kanıtını en dar cihazda almak (L-214) yalnız
/// TEK BİR anlık kontroldü; bu, aynı sınırı KALICI REGRESYON KAPISI yapar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// En dar yaygın **genişlik** (375pt, iPhone SE 3. nesil) × iPhone X sınıfı
/// **yükseklik** (812pt).
///
/// ⚠️ **Bu bir cihaz değil, bir STRES YÜZEYİ** — ve karışıklık gerçekten
/// oldu: gerçek iPhone SE 3. nesil **375×667**tir, 812 değil (simülatörde
/// ölçüldü, 750×1334 piksel). Taşmayı belirleyen şey GENİŞLİK olduğu için
/// kapı geçerli; yükseklik bilerek daha uzun tutuluyor ki test tek ekranda
/// daha çok içerik görebilsin. Adın "SE" demediğine dikkat: bir cihaz adı
/// yazsaydık, yanlış bir cihaz iddiası taşırdı.
const Size kNarrowStressSurface = Size(375, 812);

/// `tester.view`'ı [kNarrowStressSurface]'a sabitler ve testin sonunda
/// otomatik geri alır. Her `testWidgets` gövdesinin İLK satırı olmalı.
void pinNarrowSurface(WidgetTester tester) {
  tester.view.physicalSize = kNarrowStressSurface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// [finder] görünene kadar kaydırır.
///
/// **Neden gerekli ve neden bu bir TUZAK:** `ListView(children: …)` çocukları
/// TEMBEL kurar — ekranın altında kalan bir widget ağaçta HİÇ YOKTUR ve
/// `skipOffstage: false` bile onu bulamaz. Yani kaydırmadan yazılmış bir
/// "bu beyan sayfada var" testi, beyan silinse bile aynı şekilde kırmızı
/// yanar — ve daha kötüsü, ekrana SIĞAN bir sayfada yanlışlıkla yeşil yanıp
/// beyanın varlığını KANITLAMIŞ gibi görünür. Dar yüzeyde (375pt) bu fark
/// büyür, çünkü daha az şey sığar.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
