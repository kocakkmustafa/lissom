/// **GEZİLEBİLİR EKRAN SAYISI — KAPIDAN ÖLÇÜLÜR (L-270).**
///
/// Koordinatörün sorusu tek cümle:
///
/// > ***Bugün, KABUĞA girmiş bir kullanıcı kaç ayrı ekrana GİDEBİLİYOR?***
///
/// ⚠️ **CÜMLE 2026-08-12'de DARALTILDI (L-281) — sayı DEĞİŞMEDİ.**
/// Eskiden *"uygulamayı AÇAN bir kullanıcı"* diyordu. Bu, onboarding
/// eklendiğinden beri (aynı gün, `OnboardingGate` artık uygulamanın girişi)
/// kapının ÖLÇTÜĞÜNDEN GENİŞ bir cümleydi: kapı `LissomShell`i sürüyor,
/// açılışı DEĞİL. Sayı kabuk için doğruydu, **iddiası kapsamını aşıyordu.**
///
/// **Gravita aynı şerhi bağımsız düştü → 2/5, aile ölçü-tanımı sorunu.**
/// Koordinatör hükmü: ***şimdi cümleyi daralt, ölçüyü değiştirme*** —
/// kapsamı büyütmek SAYIYI değiştirir, ve o sayı panoya + aile
/// karşılaştırmasına giriyor; vardiya ortasında birimi değiştirmek
/// kıyaslanabilirliği sessizce bozar (*bir eşik, doğrulandığı ÖLÇÜM
/// BİRİMİYLE geçerlidir*). Onboarding-dahil tanım **çekirdek turunda.**
///
/// Kurucu sabah **inşa turu sırasına** karar verecek ve elindeki sayı
/// **02:00'de** ölçülmüş; arada 200+ commit geçti. **Bayat öncülle verilen
/// sıra kararı yanlış çıkar** — bu gecenin dört-tur blokajıyla (*"M-F-22
/// yasaklıyor"* sanısı) **aynı sınıf**.
///
/// ## Sayma kuralı (beş hatta ORTAK, karşılaştırılabilir olsun diye)
///
/// **Sayılır:** **kabuktan** başlayarak, **yalnız ekranda görünen kontrollere
/// basarak** ulaşılan her ayrı ekran. (Onboarding akışı bu sayıya DAHİL
/// DEĞİL — kapı onu sürmüyor; tanım genişletilirse sayı da değişir.)
///
/// ## 📏 LISSOM'UN SAYMA KURALI — açıkça (koordinatör talebi, 2026-08-12)
///
/// Gravita uyardı: *"senin 6/2'n, Choreia'nın 5/3'ü ve Gravita'nın 7/4'ü
/// aynı şeyi ölçmüyor olabilir — fark İÇERİK değil SAYMA KURALI olabilir."*
/// Haklı. Bu sayılar panoya ve aile karşılaştırmasına giriyor; **kural
/// yazılmadan karşılaştırmak, birim hatasının aile ölçeğindeki hâli olur.**
/// Aşağısı Lissom'un kuralıdır — **ölçü DEĞİŞMEDİ, yalnız YAZILDI.**
///
/// 1. **Başlangıç noktası: KABUK** (`LissomShell`), uygulama kökü DEĞİL.
///    `OnboardingGate` sürülmüyor → **onboarding akışı DIŞARIDA** (ne KATI
///    ne GENİŞ). Onboarding-dahil tanım çekirdek turunda karara bağlanacak.
/// 2. **Sekme gövdesi GENİŞ'te 1 yüzey SAYILIR, KATI'da SAYILMAZ.**
///    Lissom'un kabuğu tek `Scaffold` içinde `switch`le gövde değiştiriyor
///    ve `NavigationBar` hep görünür — yani dört sekme "ayrı rota" değil.
///    → **GENİŞ = 4 sekme + rotalar · KATI = yalnız rotalar.**
///    *(Gravita'nın GEVŞEK'i dört gövdeyi 4 sayıp KATI'da 1 rota sayıyor —
///    aynı mimari, aynı okuma; sayılar bu yüzden kıyaslanabilir.)*
/// 3. **KATI'ya girmenin ölçütü `Navigator.push`tur** — kod okunarak değil,
///    turda gerçekten yeni bir rota açılarak (`pushedRoutes`).
/// 4. **Aday envanteri ELLE yazılır** (`kCountableScreens`), desenle
///    TÜRETİLMEZ. **İsimli sınır:** listeye eklenmemiş yeni bir ekran bu
///    kapıya GÖRÜNMEZ. Desenle türetme denendi ve YANLIŞ saydı (L-270:
///    `*screen*.dart` deseni `FamilyPage`i kaçırıyordu) — elle liste, dar
///    ama DÜRÜST; genişlemeyi kapı değil insan fark eder.
/// 5. **Modal/sheet/dialog sayılmaz** · kabuk kroması (NavigationBar)
///    sayılmaz · yükleme ve hata hâlleri sayılmaz.
/// 6. **"Var ama ulaşılamıyor" AYRI raporlanır** ve sayıya girmez;
///    kabuğa hiç bağlanmamış tipler (`BatterySummaryView`) **sayım dışı**
///    diye ADIYLA basılır — sıfır olması bir başarı değil bir ÖLÇÜMDÜR.
/// 7. **Kapı ALT SINIR tutar (6), üst sınır YOK** — büyümeyi yasaklamaz,
///    küçülmeyi yakalar.
///
/// 🪤 **Kuralın gizli bir dayanağı var, adıyla:** tur bir rota açtığında
/// alttaki sekme gövdesi widget ağacında KALIR; sayının doğru çıkmasının
/// sebebi `find.byType`ın varsayılan **`skipOffstage: true`** davranışı +
/// her adımda `pumpAndSettle`. Biri değişirse (ör. saydam rota) sayım
/// SESSİZCE bozulur — bu satır o günü tutmak için burada.
/// **Sayılmaz:** kodda tanımlı ama hiçbir yerden ulaşılamayan · yalnız
/// derin-bağlantı/test kancasıyla açılan · ayrı ekran olmayan modal/sheet.
///
/// ## Neden statik tarama DEĞİL
///
/// Önce sınıf-atıf taraması yaptım ve **`FamilyPage`'i "erişilemez" gösterdi**
/// — oysa Library'den bir dokunuşla açılıyor. Sebep: sınıf kendi tanım
/// dosyasında kullanılıyordu ve filtrem o dosyayı dışlıyordu. *Ölçüm aracı
/// yanlış sayı verdi;* koordinatörün kendi deseninin Ostinato'ya **3** deyip
/// gerçeğin **11** çıkmasıyla aynı sınıf.
///
/// **Bu yüzden sayı KABUĞU SÜREREK ölçülüyor** ve kapı kalıcı: sayı bir daha
/// bayatlamaz.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Ekran sayılan tipler — **tek adres**. Kabuk kromu (NavigationBar) ve
/// yükleme/hata hâlleri ekran değildir.
const List<Type> kCountableScreens = <Type>[
  HomeScreen,
  LibraryScreen,
  ProgressScreen,
  ProfileScreen,
  FamilyPage,
  WhatLissomDoesntDoScreen,
];

Type? _visibleScreen(WidgetTester tester) {
  for (final Type t in kCountableScreens) {
    if (find.byType(t).evaluate().isNotEmpty) return t;
  }
  return null;
}

/// Taze kabuk açar — alt ekrana girince kabuk çubuğu kaybolduğu için her
/// yol SIFIRDAN yürünür. Deterministik ve "geri düğmesi var mı" varsayımı
/// yapmaz.
Future<AppFacts> _boot(WidgetTester tester) async {
  // Boş ağaç: aksi hâlde aynı tipteki kabuk yeniden kullanılıyor ve ÖNCEKİ
  // turda itilmiş rota ayakta kalıyor — tur kendi geçmişini ölçer.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  final AppFacts facts = factsFromDisk();
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LissomShell(loader: () async => facts),
  ));
  await tester.pumpAndSettle();
  return facts;
}

Future<void> _openTab(WidgetTester tester, AppFacts f, String id) async {
  await tester.tap(find.byType(NavigationDestination).at(f.ia.tabs.indexOf(id)));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('GEZİLEBİLİR EKRAN SAYISI — kabuğu sürerek', (
    WidgetTester tester,
  ) async {
    pinTallSurface(tester, height: 6000);
    final Set<Type> reached = <Type>{};
    // İKİ OKUMA ayrı tutulur (L-271). Koordinatörün kanonik kuralı "ayrı
    // ROTA"; ama Lissom'un kabuğu TEK Scaffold içinde `switch`le gövde
    // değiştiriyor ve `NavigationBar` HEP görünür — yani sekmelerim, kuralın
    // "sayılmaz" dediği üç maddenin üçüne birden uyuyor. Kuralın AMACI ise
    // "navigasyon kabuğu eksik mi" ve sekmeler kabuğun KENDİSİ.
    //
    // Bu yüzden tek sayı beyan etmiyorum: ikisi de ölçülüyor ve hangi kural
    // kazanırsa kazansın ölçüm geçerli kalıyor.
    final Set<Type> pushedRoutes = <Type>{};
    final List<String> paths = <String>[];

    // ① Sekmeler — kabuğun KENDİ rotasından, elle liste değil.
    AppFacts facts = await _boot(tester);
    for (final String tab in facts.ia.tabs) {
      await _openTab(tester, facts, tab);
      final Type? s = _visibleScreen(tester);
      if (s != null && reached.add(s)) paths.add('$s  ← sekme «$tab»');
    }

    // ② Her sekmede GÖRÜNEN her butona bir kez bas (her seferinde taze kabuk).
    for (final String tab in facts.ia.tabs) {
      for (int b = 0; b < 12; b++) {
        facts = await _boot(tester);
        await _openTab(tester, facts, tab);
        // ⚠️ Tur ÖNCE yalnız butonlara basıyordu ve `WhatLissomDoesntDoScreen`i
        // "ulaşılamıyor" saydı — oysa Profile'daki bir KARTIN `onTap`'iyle
        // açılıyor. Ölçüm aracı eksik saydı; koordinatörün deseninin
        // Ostinato'ya 3 deyip gerçeğin 11 çıkmasıyla aynı sınıf.
        final Finder all = find.byWidgetPredicate((Widget w) =>
            w is FilledButton ||
            w is TextButton ||
            (w is InkWell && w.onTap != null) ||
            (w is GestureDetector && w.onTap != null));
        if (all.evaluate().length <= b) break;
        await tester.tap(all.at(b), warnIfMissed: false);
        await tester.pumpAndSettle();
        final Type? s = _visibleScreen(tester);
        if (s != null && reached.add(s)) {
          pushedRoutes.add(s);
          paths.add('$s  ← «$tab» sekmesindeki ${b + 1}. buton  [ROTA]');
        }
      }
    }

    // ③ Library'deki aile kartları — liste öğeleri de GÖRÜNEN kontrol.
    final List<String> titles =
        facts.ia.families.map((LibraryFamily f) => f.title).toList();
    for (final String title in titles) {
      facts = await _boot(tester);
      await _openTab(tester, facts, 'library');
      final Finder card = find.text(title);
      if (card.evaluate().isEmpty) continue;
      await tester.tap(card.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      final Type? s = _visibleScreen(tester);
      if (s != null && reached.add(s)) {
        pushedRoutes.add(s);
        paths.add('$s  ← Library «$title»  [ROTA]');
      }
    }

    // POZİTİF ÇAPA: tur gerçekten gezdi mi (L-183)?
    expect(reached, isNotEmpty,
        reason: 'hiçbir ekrana ulaşılamadı — tur çalışmıyor ve aşağıdaki '
            'sayı vakum-doğru');

    // ignore: avoid_print
    print('\n═══ GEZİLEBİLİR EKRAN (KABUK-İÇİ) — İKİ OKUMA ═══');
    // ignore: avoid_print
    print('  KATI  (yalnız ayrı ROTA, push/go)        : ${pushedRoutes.length}');
    // ignore: avoid_print
    print('  GENİŞ (sekme hedefleri + rotalar)        : ${reached.length}');
    for (final String p in paths) {
      // ignore: avoid_print
      print('  · $p');
    }
    final List<Type> unreached =
        kCountableScreens.where((Type t) => !reached.contains(t)).toList();
    // ignore: avoid_print
    print('═══ VAR AMA ULAŞILAMIYOR: ${unreached.length} ═══');
    for (final Type t in unreached) {
      // ignore: avoid_print
      print('  🔴 $t');
    }

    // KALICI KAPI: sayı DÜŞERSE kırmızı. Üst sınır YOK — kapı büyümeyi
    // yasaklamaz, KÜÇÜLMEYİ yakalar (L-239: sayıyı değil kuralı ölç; buradaki
    // kural "gezilebilirlik geriye gitmez").
    // Ve KODDA TANIMLI ama sayılmayanlar ayrıca raporlanır — `BatterySummaryView`
    // bu listede (L-225: kabuktan hiçbir atıf yok, karar koordinatörde).
    // ignore: avoid_print
    print('═══ SAYIM DIŞI (tanımlı, kabuğa hiç bağlanmamış) ═══\n'
        '  🔴 BatterySummaryView — L-225, açık karar');

    // Kapı GENİŞ okumayı tutuyor (kullanıcının gidebildiği ayrı yer sayısı);
    // KATI okuma raporda ayrıca basılıyor. Hangi kural kazanırsa kazansın
    // ölçüm geçerli kalır (L-271).
    expect(reached.length, greaterThanOrEqualTo(6),
        reason: 'Gezilebilir ekran (GENİŞ) 6\'nın altına düştü. Bir ekran kodda '
            'DURUYOR ama artık ulaşılamıyor olabilir — repliğin varlığı, '
            'tetiğinin varlığı değildir.');
  });
}
