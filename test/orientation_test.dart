/// **YATAY YÜZEY KAPISI (L-244)** — kapı envanterinin bulduğu kör nokta.
///
/// Soru dışarıdan soruldu: *"375pt kapısı neyi ÖLÇMÜYOR?"* Cevap: **yatayı.**
/// Ölçüldü — `lib/` altında `setPreferredOrientations` HİÇ YOK ve
/// `ios/Runner/Info.plist` üç yönü birden açıyor. Telefonu çeviren kullanıcı
/// hiç sınanmamış bir yerleşim görüyor.
///
/// Bu test bir HÜKÜM vermiyor (yatay desteklenmeli mi — ürün kararı); yalnız
/// **bugünün gerçeğini ölçüyor**: yatayda taşma var mı?
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  for (final (String name, Widget Function(AppFacts) build) in <(
    String,
    Widget Function(AppFacts)
  )>[
    ('home', (AppFacts f) => HomeScreen(facts: f, onOpenLibrary: () {})),
    ('library', (AppFacts f) => LibraryScreen(facts: f)),
    ('progress', (AppFacts f) => ProgressScreen(facts: f)),
    ('profile', (AppFacts f) => ProfileScreen(facts: f)),
  ]) {
    testWidgets('YATAY 812×375 — $name taşmıyor', (WidgetTester tester) async {
      pinLandscapeSurface(tester);
      await tester.pumpWidget(MaterialApp(
        theme: buildLissomTheme(),
        home: Scaffold(body: build(factsFromDisk())),
      ));
      await tester.pumpAndSettle();
      // `RenderFlex overflowed` bir istisna olarak yükselir; sessiz kalırsa
      // taşma YOK demektir.
      expect(tester.takeException(), isNull,
          reason: '$name yatayda taşıyor — kullanıcı telefonu çevirebiliyor '
              '(Info.plist üç yönü açıyor, kilit yok)');
    });
  }
}
