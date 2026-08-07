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

/// **BELGE SIRASI** iddiaları için uzun yüzey — 375 GENİŞ, 2400 yüksek.
///
/// Neden ayrı: *"A, B'den önce gelir"* iddiası bir YERLEŞİM kuralıdır, bir
/// sığma kuralı değil. Dar-ve-kısa yüzeyde ikisinden biri katlamanın altında
/// kalır, tembel liste onu HİÇ KURMAZ ve `getTopLeft` "bulunamadı" der —
/// yani test, ölçmek istediği şeyi değil ekran boyunu ölçer. Kaydırmak da
/// çözmez: kaydırınca bu kez öteki ağaçtan düşer.
///
/// ⚠️ **Genişlik AYNEN 375 kalıyor.** Taşma/okunabilirlik kapıları hâlâ
/// `pinNarrowSurface` kullanır; bu yalnız sıra sorusu içindir.
void pinTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 2400);
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
/// **YATAY yüzey — 812×375.** Kapı envanterinin bulduğu kör nokta (L-244).
///
/// 375pt kapısı ailenin en olgun taşma kapısı, ama **yalnız PORTRE ölçüyordu.**
/// Ölçüldü: `lib/` altında `setPreferredOrientations` HİÇ YOK ve
/// `ios/Runner/Info.plist` üç yönü birden açıyor
/// (`Portrait` · `LandscapeLeft` · `LandscapeRight`). Yani telefonu çeviren
/// kullanıcı **hiç sınanmamış bir yerleşim** görüyor.
///
/// Kapı bir ekseni ölçüyordu ve o eksende çok iyiydi; ikinci eksende hiç
/// bakılmamıştı — *yeşil bir kapı, bakılmayan bir alan üretir.*
void pinLandscapeSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(812, 375);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
