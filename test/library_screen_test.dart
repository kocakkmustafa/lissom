/// Library kapısı — §5.4 hükmü **YAPISAL olarak** sınanır.
///
/// Hükmün üç yasağı var ve üçü de "göze öyle görünüyor" ile ölçülemez:
///
///   1. **Eşit-ağırlık listeleme YASAK.** Sınanabilir imza: inşa edilmiş aile
///      ile inşa edilmemiş aile AYNI widget'la basılmamalı. Ölçüm: kart
///      (`LissomCard`) sayısı, aile sayısına eşit OLMAMALI.
///   2. **Ayrı yol-haritası sayfası YASAK.** Sınanabilir imza: inşa
///      edilmemiş ailelerin ADLARI kütüphane ekranının KENDİSİNDE görünür —
///      bir alt sayfaya sürülmez.
///   3. **Aktif dalga birinci sınıf.** Sınanabilir imza: kütüphanede ilk
///      görünen bölüm inşa edilmiş olan.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';

import 'support/copy_gate.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

Future<void> pump(WidgetTester tester, AppFacts f) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: Scaffold(body: LibraryScreen(facts: f)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('TAM GENİŞLİK: altı ailenin ADI da kütüphane ekranında', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await pump(tester, f);

    // ⚠️ SAYI DEĞİL KURAL (L-239): "6 aile · 1 inşa · 5 bekleyen" bugünün
    // hâli. Bir aile inşa edilince (ürünün AMACI bu) `built hasLength(1)`
    // kırmızı yanardı — ilerleme, kusur değil. Ölçülen kural: her aile iki
    // kovadan BİRİNDE ve toplam korunuyor.
    expect(f.ia.built.length + f.ia.notBuilt.length, f.ia.families.length,
        reason: 'bir aile iki kovada birden ya da hiçbirinde');
    expect(f.ia.families, isNotEmpty, reason: 'pozitif çapa');
    expect(f.ia.built, isNotEmpty,
        reason: 'hiç inşa edilmiş aile yok — kütüphane "bu derlemede" '
            'bölümü boş kalır');
    expect(f.ia.notBuilt, isNotEmpty,
        reason: 'hiç bekleyen aile yok — ya hepsi inşa edildi (bu satır '
            'ZAFERLE silinir) ya da config kırık');

    for (final LibraryFamily fam in f.ia.families) {
      await scrollTo(tester, find.text(fam.title));
      expect(find.text(fam.title), findsOneWidget,
          reason: '${fam.id} kütüphanede görünmüyor — genişlik bir alt '
              'sayfaya sürülmüş olur (§5.4 yol-haritası yasağı)');
    }
  });

  testWidgets('KATMANLI: aktif aile ÖNCE, inşa edilmemişler AYRI bölümde', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(tester, factsFromDisk());

    final double builtY =
        tester.getTopLeft(find.byKey(LibraryScreen.builtSectionKey)).dy;
    final double pendingY =
        tester.getTopLeft(find.byKey(LibraryScreen.notBuiltSectionKey)).dy;
    expect(builtY, lessThan(pendingY),
        reason: 'aktif dalga birinci sınıf yerleşim ALMALI');
  });

  testWidgets('EŞİT AĞIRLIK YASAĞI: iki grup aynı widget\'la basılmaz', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await pump(tester, f);

    // Kartlar YALNIZ inşa edilmiş aileye ait. Beş aile de kart alsaydı sayı
    // 6 olurdu — bu tam olarak "sahte doluluk"un imzası.
    final int cards = tester
        .widgetList(find.descendant(
          of: find.byKey(LibraryScreen.builtSectionKey),
          matching: find.byType(LissomCard),
        ))
        .length;
    expect(cards, f.ia.built.length);
    expect(
        find.descendant(
          of: find.byKey(LibraryScreen.notBuiltSectionKey),
          matching: find.byType(LissomCard),
        ),
        findsNothing,
        reason: 'inşa edilmemiş aile birinci-sınıf kart alırsa sahte doluluk '
            'üretilir (§5.4)');
  });

  testWidgets('inşa edilmemiş ailenin DÜRÜST tek satırı envanterden TÜRETİLİR',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await pump(tester, f);

    final LibraryFamily yoga =
        f.ia.families.singleWhere((LibraryFamily x) => x.id == 'yoga_styles');
    // Satır sayıyı TÜRETİR — testin de türetmesi gerekir, yoksa config'e
    // altıncı bir stil eklendiğinde test ürün doğru büyürken kırmızı yanar.
    expect(yoga.children, isNotEmpty, reason: 'pozitif çapa');
    expect(yoga.inventoryLine,
        '${yoga.children.length} named · none in this build.');
    await scrollTo(tester, find.text(yoga.title));
    // `findsWidgets`: `population_packs` de 5 çocuk taşıyor, yani AYNI dürüst
    // satırı üretiyor. Bu bir çakışma değil bir olgu — satır türetimli olduğu
    // için aynı envanter aynı cümleyi verir.
    expect(find.text(yoga.inventoryLine), findsWidgets);

    // Çocuğu olmayan aile için SAYI UYDURULMAZ.
    final LibraryFamily breath = f.ia.families
        .singleWhere((LibraryFamily x) => x.id == 'breath_meditation');
    expect(breath.children, isEmpty);
    expect(breath.inventoryLine, isNot(contains('0 named')));
  });

  testWidgets('aile sayfasına gitmek ÇALIŞIR (≤3 dokunuş kuralı)', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    await pump(tester, factsFromDisk());
    await tester.tap(find.text('Assessment Battery'));
    await tester.pumpAndSettle();
    expect(find.byType(FamilyPage), findsOneWidget);
  });

  testWidgets('yasaklı yüzey kopyası yok', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await pump(tester, factsFromDisk());
    expectNoBannedCopy(tester);
  });
}
