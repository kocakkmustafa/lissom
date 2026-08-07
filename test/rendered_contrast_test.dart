/// **ÇİZİLEN metnin kontrastı (L-247)** — token varsayılanının değil.
///
/// Koordinatörün sorusu doğrudandı: *"bu gece 9 engelli testin gerekçelerini
/// ve 'What Lissom doesn't do'yu güçlendirdin — **o satırların kontrastını
/// ölçtün mü?**"*
///
/// Dürüst cevap: **hayır.** `contrast_test.dart` tema stillerinin
/// VARSAYILAN renklerini ölçüyordu. Ama bir yüzey rengi **yerinde** geçebilir
/// (`style: t.textTheme.bodySmall?.copyWith(color: …)`) ve o yol kapının
/// DIŞINDAYDI. JabLab'ın J-126'sı tam bu: *kapı token varsayılanlarını
/// ölçüyordu, yüzeyler rengi yerinde geçiyordu.*
///
/// **Bir satıra dokunmak, o satırı denetlemek değildir.** Bu gece o satırların
/// metnini güçlendirdim; okunurluklarını hiç ölçmedim.
///
/// Bu kapı ekranı GERÇEKTEN kurar, ağaçtaki her `Text`in **etkin** stilini
/// çözer (`DefaultTextStyle` + widget'ın kendi `style`ı) ve en kötü zemine
/// karşı ölçer.
///
/// ## ⚠️ BU KAPININ SINIRI — isimle
///
/// Tarama yalnız **KURULMUŞ** widget'ları görür. `ListView` tembel olduğu için
/// katlamanın altında kalan metin ağaçta HİÇ YOKTUR ve kapı onu ölçmez —
/// *yani kapının kapsamı, yüzeyin yüksekliği kadardır.* O yüzden yüzey
/// içeriğin TAMAMINI alacak kadar uzun kuruluyor ve her testte bir POZİTİF
/// ÇAPA, beklenen bölümlerin gerçekten basıldığını doğruluyor. Çapasız bir
/// kontrast taraması, boş bir ağaçta da yeşil yanar.
///
/// ## Neden EN KÖTÜ zemin
///
/// Bir metnin altındaki gerçek pikseli widget ağacından çıkarmak, kart
/// gradyanları ve ekran gradyanı yüzünden kırılgan bir tahmin olurdu. Bunun
/// yerine uygulamadaki **en koyu zemin** (`#EEDDE7`, ekran gradyanının son
/// durağı) kullanılıyor: orada geçen metin her yerde geçer. Muhafazakâr taraf
/// doğru taraf — ve varsayım yerine bir ÜST SINIR ölçüyor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';

import 'support/contrast.dart';
import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Uygulamadaki en koyu zemin — ekran gradyanının son durağı.
const Color kDarkestSurface = Color(0xFFEEDDE7);

/// Bir `Text`in ARKASINDAKİ gerçek zemin.
///
/// ⚠️ Yüklem ilk hâlinde **her** metni sayfa arka planına (`kDarkestSurface`)
/// göre ölçüyordu ve sekme turu açılır açılmaz Home'daki birincil butonu
/// **1,30:1** diye kırmızıya çevirdi. Ürün doğruydu: buton `roseDeep`
/// dolgulu, etiketi **beyaz** — yani kapı, beyaz metni PEMBE SAYFAYA karşı
/// ölçüyordu. Yanlış çift, yanlış sonuç (L-264).
///
/// **Muafiyet yazmadım** — muafiyet, arkasına gerçek bir kusurun
/// saklanabileceği bir delik açardı. Bunun yerine zemin **temadan
/// TÜRETİLİYOR**: dolgulu butonun içindeki metin, butonun dolgusuna karşı
/// ölçülür. Tema rengi değişirse ölçüm kendiliğinden onu izler.
Color _backgroundFor(Element e) {
  Element? button;
  e.visitAncestorElements((Element a) {
    if (a.widget is FilledButton) {
      button = a;
      return false;
    }
    return true;
  });
  if (button == null) return kDarkestSurface;

  // ⚠️ İlk yazımda dolgu rengi burada SABİTLENMİŞTİ (`LissomColors.roseDeep`)
  // ve tema düzeltilince kapı ESKİ rengi ölçmeye devam etti — yani düzeltmeyi
  // görmedi. Tek-adres ilkesi kendi kapıma çarptı: zemin TEMADAN okunur.
  final ThemeData t = Theme.of(button!);
  final Color? fill = t.filledButtonTheme.style?.backgroundColor
      ?.resolve(<WidgetState>{});
  return fill ?? t.colorScheme.primary;
}

/// Ağaçtaki her `Text`in ETKİN rengi + boyutu, ve eşiği geçip geçmediği.
List<String> _failures(WidgetTester tester) {
  final List<String> out = <String>[];
  for (final Element e in tester.elementList(find.byType(Text))) {
    final Text w = e.widget as Text;
    final String data = w.data ?? '';
    if (data.trim().isEmpty) continue;
    // Etkin stil: ata `DefaultTextStyle` + widget'ın kendi `style`ı.
    final TextStyle effective =
        DefaultTextStyle.of(e).style.merge(w.style);
    final Color? color = effective.color;
    final double size = effective.fontSize ?? 14;
    if (color == null) continue;
    final double threshold =
        Wcag.forText(size, effective.fontWeight ?? FontWeight.w400);
    final double ratio = contrastRatio(color, _backgroundFor(e));
    if (ratio < threshold) {
      out.add('${ratio.toStringAsFixed(2)}:1 (eşik $threshold, ${size}px) '
          '«${data.length > 60 ? "${data.substring(0, 60)}…" : data}»');
    }
  }
  return out;
}

void main() {
  testWidgets('ENGELLİ TEST GEREKÇELERİ çizildiği hâliyle okunuyor', (
    WidgetTester tester,
  ) async {
    pinTallSurface(tester, height: 6000);
    final AppFacts f = factsFromDisk();
    final LibraryFamily battery =
        f.ia.built.singleWhere((LibraryFamily x) => x.id == 'assessment_battery');
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: FamilyPage(family: battery, facts: f),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: gerekçeler GERÇEKTEN ağaçta mı? Boş ağaçta bu tarama
    // hiçbir şey kanıtlamaz (L-183).
    expect(find.textContaining('measurement engine'), findsWidgets,
        reason: 'engel gerekçeleri basılmamış — tarama boşa gidiyor');

    final List<String> fails = _failures(tester);
    expect(fails, isEmpty,
        reason: 'engel gerekçesi okunmuyor — "görünmeyen bir dürüst hâl, '
            'susmakla aynı şeydir":\n${fails.join("\n")}');
  });

  testWidgets('"What Lissom doesn\'t do" çizildiği hâliyle okunuyor', (
    WidgetTester tester,
  ) async {
    // Sayfa uzun: sınırlar + dışlamalar + poz katmanları + dipnot. Yüzey
    // içeriğin TAMAMINI alacak kadar uzun olmalı, yoksa kapı görmediğini
    // ölçmüş sayılır.
    pinTallSurface(tester, height: 6000);
    final AppFacts f = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: WhatLissomDoesntDoScreen(
          items: f.ia.whyNot,
          excluded: f.battery.excluded,
          poseTiers: f.ia.poseTiers),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: üç katman da basılmış olmalı — sınırlar, dışlamalar,
    // poz katmanları.
    expect(find.byKey(WhatLissomDoesntDoScreen.boundariesKey), findsOneWidget);
    expect(find.byKey(WhatLissomDoesntDoScreen.excludedKey), findsOneWidget);
    expect(find.byKey(WhatLissomDoesntDoScreen.tiersKey), findsOneWidget);

    final List<String> fails = _failures(tester);
    expect(fails, isEmpty,
        reason: 'sınır metni okunmuyor:\n${fails.join("\n")}');
  });

  testWidgets('HER SEKMEDE çizilen metin okunuyor — kapsam kabuk turundan', (
    WidgetTester tester,
  ) async {
    // ⚠️ J-151 (L-264): **bir kusuru bulduğun yüzeyde düzeltmek, onu ürünün
    // geri kalanında düzeltmek değildir.**
    //
    // Bu kapı (L-247) yazıldığında yalnız `FamilyPage` ve
    // `WhatLissomDoesntDoScreen` geziliyordu — o gün BAKTIĞIM iki yüzey.
    // Dört sekmenin dördü de KAPSAM DIŞIYDI, üstelik hepsi bu kapıdan
    // ÖNCE (`4de4322`, 02:19) inşa edilmişti. Yani kusur değil, kapsam
    // eksikti — L-258'in (gauge yasağı 5 yüzeyin 1'inde) kardeşi.
    //
    // Kapsam yine ELLE LİSTE değil: sekmeler config'in kendi `tabs`
    // listesinden geziliyor.
    pinTallSurface(tester, height: 6000);
    final AppFacts facts = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget,
        reason: 'kabuk açılmadı — tur boş yüzey geziyor olurdu');

    final List<String> all = <String>[];
    int textsSeen = 0;
    for (int i = 0; i < facts.ia.tabs.length; i++) {
      await tester.tap(find.byType(NavigationDestination).at(i));
      await tester.pumpAndSettle();
      textsSeen += find.byType(Text).evaluate().length;
      all.addAll(_failures(tester)
          .map((String f) => '«${facts.ia.tabs[i]}» $f'));
    }

    // POZİTİF ÇAPA: tur gerçekten metin gördü mü? (L-183)
    expect(textsSeen, greaterThan(20),
        reason: 'tur boyunca yalnız $textsSeen metin görüldü — tarama '
            'çalışmıyor ve aşağıdaki yeşil vakum-doğru');

    expect(all, isEmpty,
        reason: 'Sekmelerde okunmayan metin var — "görünmeyen bir dürüst '
            'hâl, susmakla aynı şeydir":\n${all.join("\n")}');
  });

  testWidgets('KAPI KIRMIZI YANABİLİYOR — çizilen renk yerinde geçilirse', (
    WidgetTester tester,
  ) async {
    // Sabotaj: bir yüzey rengi YERİNDE geçerse (token varsayılanı değil),
    // tema-düzeyi kapı bunu GÖREMEZ ama bu kapı görmeli. J-126'nın tam hâli.
    pinNarrowSurface(tester);
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Builder(builder: (BuildContext c) {
        final ThemeData t = Theme.of(c);
        return Scaffold(
          body: Text('yerinde geçilmiş sönük renk',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFFA79DA5))),
        );
      }),
    ));
    await tester.pumpAndSettle();
    expect(_failures(tester), isNotEmpty,
        reason: 'kapı yerinde-geçilen rengi göremiyorsa, J-126 boşluğu '
            'kapanmamış demektir');
  });
}
