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
import 'package:lissom/app/shell.dart';

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
    // Sıra iddiası → uzun yüzey (genişlik yine 375).
    pinTallSurface(tester);
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
    //
    // ⚠️ Önce `breath_meditation` ADIYLA çivilenmişti ve `children.isEmpty`
    // bir ÖN KOŞUL olarak yazılmıştı (L-261). O aile bir gün çocuk kazanırsa
    // test **yanlış gerekçeyle** kırılır — ve asıl kural ("0 named" uydurma)
    // sessizce sınanmaz olur. Kural aileye değil, HÂLE bağlı: çocuksuz OLAN
    // her aile.
    final Iterable<LibraryFamily> childless =
        f.ia.families.where((LibraryFamily x) => x.children.isEmpty);
    expect(childless, isNotEmpty,
        reason: 'VAKUM: hiçbir aile çocuksuz değil, yani "sayı uydurma" '
            'kuralı bu turda HİÇ sınanmadı. Kural hâlâ geçerli — sınayacak '
            'örnek kalmadıysa bu bir olgudur, sessizce geçilmez.');
    for (final LibraryFamily fam in childless) {
      expect(fam.inventoryLine, isNot(contains('0 named')),
          reason: '«${fam.title}» çocuksuz ama envanter satırı bir SAYI '
              'uyduruyor. Yokluk, sıfırla anlatılmaz.');
    }
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

  testWidgets('GEZİNME KURALI: beyan edilen dokunuş sınırı ÖLÇÜLÜR (L-240)',
      (WidgetTester tester) async {
    // `navigationRules` bloğunun okuyucusu YOKTU — beyan edilmiş, ölçülebilir
    // bir kısıt iki yıl boyunca hiç sınanmadı. Artık sınanıyor: sayı
    // config'ten TÜRETİLİR, teste yazılmaz.
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => f),
    ));
    await tester.pumpAndSettle();

    // HOME → aktif kurs: kaç DOKUNUŞ?
    //
    // ⚠️ **KAPININ SINIRI — isimle:** kural DOKUNUŞ sayıyor, kaydırma değil.
    // Düğme ekranın altında olduğu için önce kaydırıyoruz ve bu sayıya
    // GİRMİYOR. Yani kapı "kaç dokunuş" sorusunu kapatır, "ne kadar zahmet"
    // sorusunu kapatmaz — uzun bir kaydırma iki dokunuşu ucuz göstermez.
    // (WCAG kapısının "luminans ölçer, ayırt edilebilirliği değil" sınırının
    // aynı sınıfı.)
    int taps = 0;
    await scrollTo(tester, find.text('See what each test measures'));
    await tester.tap(find.text('See what each test measures'));
    taps++;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assessment Battery'));
    taps++;
    await tester.pumpAndSettle();
    expect(find.byType(FamilyPage), findsOneWidget,
        reason: 'aktif kursa ulaşılamadı');
    expect(taps, lessThanOrEqualTo(f.ia.navigation.maxTapsHomeToActiveCourse),
        reason: 'home→aktif kurs $taps dokunuş, beyan edilen sınır '
            '${f.ia.navigation.maxTapsHomeToActiveCourse}');
  });

  testWidgets('yasaklı yüzey kopyası yok', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    await pump(tester, factsFromDisk());
    expectNoBannedCopy(tester);
  });
}
