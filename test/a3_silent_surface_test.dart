/// **A3 — SESSİZ ORAN, PAYDA GENİŞLETİLMİŞ (L-315).**
///
/// Tanım bu dosyada DEĞİL: `docs/A3-SESSIZ-ORAN-TANIMI.md`, ve o dosya bu
/// testten **ÖNCEKİ bir commit'te** duruyor. Goodhart karşıtı kanıt beyan
/// değil **git tarihinin sırası** — doğrulaması tanım dosyasının 3. satırında.
///
/// ═══════════════════════════════════════════════════════════════════
/// ## NE GENİŞLEDİ
/// ═══════════════════════════════════════════════════════════════════
///
/// `reachable_but_empty_test.dart` A3'ü **6 batarya ailesi** üzerinde ölçüyor.
/// Kullanıcının gerçekten gezdiği **ekranlar** o paydaya hiç girmemişti. Bu
/// dosya onları ekler. ⛔ Eskisi **değiştirilmedi** — iki ayrı payda, iki ayrı
/// dosya; *birleştirmek, iki farklı birimi tek sayıya toplamak olurdu.*
///
/// ═══════════════════════════════════════════════════════════════════
/// ## İKİ DETEKTÖR — ve HER BİRİ NE YAKALAMAZ
/// ═══════════════════════════════════════════════════════════════════
///
/// Tanımın ⓒ¹ (BAŞLIKLI BOŞLUK) kovası bu ağaçta **iki ayrı biçimde** ortaya
/// çıkıyor, ve tek detektör ikisini birden göremez:
///
/// **D1 · SAYILI BAŞLIK** — `LissomEyebrow('… (0)')`. Başlık sayıyı KENDİ
/// taşıyor; altındaki liste boşsa başlık sıfırı ilan eder ve gövde yoktur.
/// *Neden ayrı detektör gerekti:* bu başlıklar **liste döndüren kuruculardan**
/// (`_batteryBody`) geliyor — kardeş içerikleri kendi `Column`larında DEĞİL,
/// bir üstteki ortak `Column`da. Ağaç-ataya bakan bir kontrol onları
/// **dolu sanır.**
/// ⛔ D1'in görmediği: sayı taşımayan bir başlık.
///
/// **D2 · GÖVDESİZ BAŞLIK** — başlığın kendi `Column`u, başlık metinleri
/// dışında **hiçbir `Text` çizmiyor**. `home_screen.dart`'ın `switch`
/// varsayılanı tam bu: `LissomEyebrow(s.title)` her hâlükârda çiziliyor,
/// gövde `_ => SizedBox.shrink()` olabiliyor.
/// ⛔ D2'nin görmediği: liste döndüren kurucudaki başlık (yukarıdaki sebep).
///
/// > ***İKİ DETEKTÖRÜN BİRLİKTE KAPSAMADIĞI BİR ALAN VAR VE ADI YAZILI:***
/// > *sayı taşımayan **ve** liste döndüren bir kurucudan gelen başlık,*
/// > *ikisinden de geçer.* Bugün `lib/` altında böyle bir başlık YOK
/// > (`_uncountedInListBuilders` bunu SAYARAK doğruluyor, beyanla değil) —
/// > ama biri eklenirse bu kapı **susar.** Kör nokta ADIYLA duruyor;
/// > *bir kapının kapsamını yazmamak, kapsamı sonsuz sanmaktır.*
///
/// ═══════════════════════════════════════════════════════════════════
/// ## İKİ PENCERE — tek sayıya TOPLANMAZ
/// ═══════════════════════════════════════════════════════════════════
///
/// **BUGÜN** — sevk edilen config + TAZE KURULUM (geçmiş boş). Kullanıcının
/// ilk açılışta gerçekten gördüğü hâl.
/// **YARIN** — veri kaynakları teker teker boşaltılır. Bu bir *hayal senaryo*
/// değil: config **sürümlü ve değiştirilebilir**, yani bu ürünün ASIL değişim
/// yüzeyi. Bir config düzenlemesi bugün sessizce başlıklı boşluk üretebilir.
///
/// ⛔ İkisi tek orana TOPLANMAZ. Kendi ölçülmüş kazam: *bir sayı penceresi
/// yazılmadan karşılaştırılamaz.*
///
/// ═══════════════════════════════════════════════════════════════════
/// ## POZİTİF KONTROL — kopyayı değil, GERÇEK fonksiyonu sınar
/// ═══════════════════════════════════════════════════════════════════
///
/// JabLab `J-232`'nin tuzağı: *fixture bir KOPYAYI sınasaydı, gerçek
/// yürüyüştekinin ateşlendiğini kanıtlamazdı.* O yüzden [titledVoids] **tek
/// fonksiyon** ve hem gerçek yüzeyler hem pozitif kontroller onu çağırır.
/// İki pozitif kontrol var, her detektör için bir tane — *bir detektörün
/// öttüğünü görmek, ÖTEKİNİN öttüğünü kanıtlamaz.*
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

// ═══════════════════════════════════════════════════════════════════
// DETEKTÖR — tek adres, hem gerçek yüzeyler hem pozitif kontroller için
// ═══════════════════════════════════════════════════════════════════

/// Sayıyı başlıktan okur. `(0)` → sıfır ilan eden başlık.
final RegExp _kCount = RegExp(r'\((\d+)\)');

/// Bir ⓒ¹ bulgusu — hangi detektör, hangi başlık.
final class TitledVoid {
  const TitledVoid(this.detector, this.eyebrow);
  final String detector;
  final String eyebrow;
  @override
  String toString() => '[$detector] «$eyebrow»';
}

/// ÇİZİLMİŞ ağaçtaki tüm BAŞLIKLI BOŞLUKLARI döndürür.
///
/// ⚠️ `LissomEyebrow.text` **alanından** okunuyor, çizilmiş `Text`in
/// dizesinden DEĞİL — `build` metodu `toUpperCase()` uyguluyor ve Türkçe
/// `i→İ` dönüşümü dize karşılaştırmasını sessizce bozardı. *Bir kapının
/// girdisi, dönüştürülmüş çıktı değil kaynak alan olmalıdır.*
List<TitledVoid> titledVoids(WidgetTester tester) {
  final List<TitledVoid> found = <TitledVoid>[];
  for (final Element e in find.byType(LissomEyebrow).evaluate()) {
    final LissomEyebrow eb = e.widget as LissomEyebrow;

    // ── D1 · SAYILI BAŞLIK ──────────────────────────────────────────
    final RegExpMatch? m = _kCount.firstMatch(eb.text);
    if (m != null && int.parse(m.group(1)!) == 0) {
      found.add(TitledVoid('D1 SAYILI', eb.text));
      continue;
    }

    // ── D2 · GÖVDESİZ BAŞLIK ────────────────────────────────────────
    Element? column;
    e.visitAncestorElements((Element a) {
      if (a.widget is Column) {
        column = a;
        return false;
      }
      return true;
    });
    if (column == null) continue;

    // `LissomEyebrow` TAM BİR `Text` kurar (lissom_theme.dart:304). O yüzden
    // "içerik metni" = toplam Text − başlık sayısı. Bu bir tahmin değil,
    // widget'ın yapısından türetilmiş bir eşitlik.
    int texts = 0;
    int eyebrows = 0;
    void walk(Element x) {
      if (x.widget is Text) texts++;
      if (x.widget is LissomEyebrow) eyebrows++;
      x.visitChildren(walk);
    }

    column!.visitChildren(walk);
    if (texts - eyebrows <= 0) {
      found.add(TitledVoid('D2 GÖVDESİZ', eb.text));
    }
  }
  return found;
}

/// Çizilmiş BOŞ durumda ⓐ ve ⓑ kovalarını sayar.
///
/// **ⓑ SÖYLEYEN** = `NamedGapCard` — bu ağaçta *"neden burada bir şey yok"*un
/// TEK adresi (`surfaces.dart`, M-F-186'nın uygulanabilir hâli). Kovanın
/// birimini bir widget'a bağlamak, *"gerekçe var mı"* sorusunu metin
/// yorumundan **yapıya** taşır — bir cümlenin gerekçe SAYILIP sayılmadığına
/// karar vermek zorunda kalmam.
/// **ⓐ SUNAN** = basılabilir gerçek bir kontrol (`ButtonStyleButton` ve
/// TÜREVLERİ).
///
/// 🪤 **İLK YAZIMIM ⓐ'yı 0 SAYDI ve bu YANLIŞTI.** `find.byType`
/// **TAM çalışma-zamanı tipini** eşler; `FilledButton` bir
/// `ButtonStyleButton` ALT SINIFI olduğu için hiç eşleşmedi. Taze kurulumda
/// Home gerçekten bir düğme çiziyor — yani sayım *"düğme yok"* demiyordu,
/// ***"düğme ARAMADIM"*** diyordu ve ikisi aynı sıfır gibi görünüyordu.
/// ⇒ `byWidgetPredicate` + `is` ile alt sınıflar dahil.
/// > ***BİR SIFIR, ARADIĞINI BULAMAMAKLA ARAMAMIŞ OLMAK ARASINDA AYRIM
/// > YAPMAZ — ve ölçüm aracının tip eşlemesi, bulguya dönüşmeden önce
/// > POZİTİF ÇAPAYLA yakalanır.***
///
/// ⚠️ Bu sayım [titledVoids] ile AYNI ağaç üstünde ve AYNI anda yapılır —
/// ayrı bir koşumda yapılsaydı iki sayı iki farklı duruma ait olurdu ve
/// toplamları anlamsızlaşırdı.
(int, int) _census(WidgetTester tester) => (
      find
          .byWidgetPredicate((Widget w) => w is ButtonStyleButton)
          .evaluate()
          .length,
      find.byWidgetPredicate((Widget w) => w is NamedGapCard).evaluate().length,
    );

Future<void> _pump(WidgetTester tester, Widget body) async {
  await tester.pumpWidget(
    MaterialApp(theme: buildLissomTheme(), home: Scaffold(body: body)),
  );
  await tester.pumpAndSettle();
}

/// Kaydırılabilir yüzeyin TAMAMINI dolaşır — *katlamanın altındaki bir
/// başlıklı boşluk, ağaçta HİÇ YOKTUR ve kapı onu göremez.* Bu, bu hattın
/// `L-297`'de ödediği kaza (kaydırmayan yürüyüş altı aileden birine ulaştı
/// ve "0 kusur" diye SAHTE TEMİZ rapor edecekti).
Future<List<TitledVoid>> _sweep(WidgetTester tester) async {
  final Map<String, TitledVoid> seen = <String, TitledVoid>{};
  void collect() {
    for (final TitledVoid v in titledVoids(tester)) {
      seen['${v.detector}|${v.eyebrow}'] = v;
    }
  }

  collect();
  final Finder scroller = find.byType(Scrollable);
  if (scroller.evaluate().isNotEmpty) {
    for (int i = 0; i < 14; i++) {
      await tester.drag(scroller.first, const Offset(0, -320));
      await tester.pumpAndSettle();
      collect();
    }
  }
  return seen.values.toList(growable: false);
}

void main() {
  // ═════════════════════════════════════════════════════════════════
  // POZİTİF KONTROLLER — GERÇEK detektörün öttüğü, her iki yön için
  // ═════════════════════════════════════════════════════════════════

  testWidgets('POZİTİF KONTROL D1: "(0)" başlığı YAKALANIR',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);

    // ⚠️ **BU KONTROL BİR KEZ GERÇEK EKRANDAYDI — ve DÜZELTME onu bozdu.**
    // Kayıt, çünkü kanıt bir kez alınır ve tarihiyle durur:
    //
    //   · GERÇEK `FamilyPage` (`liveness` boş)  → D1 **2 bulgu** verdi:
    //       «Measured by camera in this build (0)» · «Not measured by camera (0)»
    //   · GERÇEK `LibraryScreen` (`families` hepsi inşa edilmiş)
    //                                          → D1 **1 bulgu** verdi:
    //       «Planned, not in this build (0)»
    //
    // Üçü de bu turda KAPATILDI. Kapatınca tetik kalmadı — ve *bir kapıyı
    // güçlendiren düzeltme, ötme kanıtını geçersiz kılar.* O yüzden kalıcı
    // kontrol artık asgari bir ağaç:
    //
    // ⇒ Bu hâliyle kanıtladığı: **detektör çalışıyor**, her koşuda.
    // ⇒ Kanıtlamadığı: ürün ağacına bakıp bakmadığı — onu iki pencere testi
    //    sağlıyor, çünkü **aynı [titledVoids] fonksiyonunu** gerçek
    //    ekranların üstünde çağırıyorlar (J-232: kopya sınanmaz).
    // ⛔ Tetiği geri getirmek için ürünü bozmadım: *kapıyı ötsün diye
    //    kusuru yaşatmak, kapının amacını tersine çevirir.*
    await _pump(
      tester,
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow('A section that declares zero (0)'),
          SizedBox(height: 10),
          Text('…and this body is never reached when the count is zero'),
        ],
      ),
    );

    expect(
      titledVoids(tester).where((TitledVoid v) => v.detector == 'D1 SAYILI'),
      isNotEmpty,
      reason: 'D1 ÖTMEDİ — sıfır ilan eden bir başlık çizildiği hâlde detektör '
          'sustu; aşağıdaki sayılar hiçbir şey ölçmez',
    );
  });

  testWidgets('POZİTİF KONTROL D2: gövdesiz başlık YAKALANIR',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);

    // ⚠️ **BU KONTROLÜN SINIRI, ADIYLA:** aşağıdaki ağaç bir ÜRÜN ekranı
    // değil, elle kurulmuş asgari bir vaka. Sebebi ölçüldü, tercih değil:
    // `HomeScreen`de gövdesiz başlık **YAPISAL OLARAK ÜRETİLEMİYOR** —
    // `_section` önce `_keys[s.id]`e bakıyor, tanımadığı id `_unknownSection`e
    // gidiyor ve orada gerekçeli bir `NamedGapCard` çiziliyor. Yani
    // `switch`in `_ => SizedBox.shrink()` dalı BUGÜN ULAŞILAMAZ.
    //
    // ⇒ Bu kontrol **yalnız detektörün çalıştığını** kanıtlar, ürün ağacına
    // bakıp baktığını DEĞİL. O ikinci yarıyı D1'in kontrolü kanıtlıyor
    // (gerçek `FamilyPage` üstünde ötüyor) — ve ikisi AYNI [titledVoids]
    // fonksiyonunu çağırıyor, iki kopya değil.
    //
    // ⇒ D2'nin koruduğu GERÇEK regresyon kanalı ayrıca ve yapısal olarak
    // kapılı: `_keys` ile `switch` alan eşitliği (aşağıdaki test).
    await _pump(
      tester,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          LissomEyebrow('A heading with nothing under it'),
          SizedBox(height: 10),
          SizedBox.shrink(),
        ],
      ),
    );

    expect(
      titledVoids(tester).where((TitledVoid v) => v.detector == 'D2 GÖVDESİZ'),
      isNotEmpty,
      reason: 'D2 ÖTMEDİ — gövdesiz bir başlık çizildiği hâlde detektör sustu; '
          'aşağıdaki "0 bulgu" sonuçları VAKUM-DOĞRU olurdu',
    );
  });

  // ═════════════════════════════════════════════════════════════════
  // D2'NİN GERÇEK REGRESYON KANALI — yapısal, ve ürün kodunun üstünde
  // ═════════════════════════════════════════════════════════════════

  test('HomeScreen: `_keys` alanı ile `switch` dalları AYNI olmalı', () {
    // Bugün gövdesiz başlık üretilemiyor çünkü `_keys` domaini `switch`in
    // ele aldığı küme ile TAM AYNI. Biri ötekine eklenirse (`_keys`'e yeni
    // id, `switch`e dal YOK) → `k != null` olur, `switch` `_` dalına düşer,
    // ve **başlıklı boşluk O AN ULAŞILABİLİR HÂLE GELİR.**
    //
    // ⭐ Kapı bir A kalemini doğruluyor: *"başlığı olup gövdesi olmayan bölüm
    // yoktur"*. Bir belge tazeliği kapısı DEĞİL.
    final String src = File('lib/app/home_screen.dart').readAsStringSync();

    final String keysBlock = src.split('static const Map<String, Key> _keys')[1].split('};')[0];
    final Set<String> keyIds = RegExp(r"'([a-z_]+)':")
        .allMatches(keysBlock)
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();

    final String switchBlock = src.split('switch (s.id) {')[1].split('},')[0];
    final Set<String> caseIds = RegExp(r"'([a-z_]+)'\s*=>")
        .allMatches(switchBlock)
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();

    // POZİTİF ÇAPA: ayrıştırma gerçekten bir şey buldu mu? Boş kümeler
    // birbirine EŞİTTİR ve bu test hiçbir şey ölçmeden yeşil yanardı.
    expect(keyIds, isNotEmpty, reason: '`_keys` ayrıştırılamadı — kapı kör');
    expect(caseIds, isNotEmpty, reason: '`switch` ayrıştırılamadı — kapı kör');

    expect(
      keyIds,
      caseIds,
      reason: '`_keys` ve `switch` ayrıştı. `_keys`te olup `switch`te olmayan '
          'her id, BAŞLIKLI BOŞLUK üretir: kullanıcı bölüm başlığını görür, '
          'altında hiçbir şey bulmaz. Fark: ${keyIds.difference(caseIds)} / '
          '${caseIds.difference(keyIds)}',
    );
  });

  // ═════════════════════════════════════════════════════════════════
  // KÖR NOKTA — beyanla değil SAYARAK
  // ═════════════════════════════════════════════════════════════════

  test('KÖR NOKTA ölçülür: sayısız + liste-kurucu başlık BUGÜN yok', () {
    // İki detektörün birlikte kaçırdığı biçim: sayı taşımayan bir başlık,
    // liste döndüren bir kurucunun içinde. Bunu BEYAN etmek yetmez — bugün
    // gerçekten sıfır olduğunu SAYIYORUM, ki yarın biri eklendiğinde bu
    // kapı kırmızıya dönsün ve kör nokta SESSİZCE büyümesin.
    final (List<String> uncounted, int scanned) =
        _uncountedEyebrowsInListBuilders();

    // POZİTİF ÇAPA: tarayıcı liste-kurucuların İÇİNDE gerçekten başlık gördü
    // mü? Görmediyse "0 kör nokta" sonucu VAKUM-DOĞRU olurdu — ve bu tam
    // olarak bu turda D1'in başıma getirdiği şeydi.
    expect(scanned, greaterThan(0),
        reason: 'tarayıcı hiçbir liste-kurucu başlığı görmedi — desen bozuk, '
            'sonuç ölçüm değil');

    final List<String> uncountedInListBuilders = uncounted;
    expect(
      uncountedInListBuilders,
      isEmpty,
      reason: 'Bu başlıklar İKİ DETEKTÖRDEN DE geçer — sayı taşımıyorlar '
          '(D1 göremez) ve liste döndüren bir kurucudalar (D2 göremez): '
          '$uncountedInListBuilders. Ya başlığa sayı ekle, ya bölümü kendi '
          'Column\'una al — yoksa A3 bu noktada KÖRDÜR',
    );
  });

  // ═════════════════════════════════════════════════════════════════
  // PENCERE 1 · BUGÜN — sevk edilen config, TAZE KURULUM
  // ═════════════════════════════════════════════════════════════════

  testWidgets('BUGÜN penceresi: taze kurulumda başlıklı boşluk YOK',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    // Taze kurulum = geçmiş BOŞ ve SAĞLIKLI. Bu bir senaryo değil, her yeni
    // kullanıcının gördüğü hâl.
    final AppFacts f =
        factsFromDisk(history: const SessionHistoryView.ok(<SessionRecord>[]));

    // POZİTİF ÇAPA: config gerçekten içerik taşıyor mu? Taşımıyorsa
    // aşağıdaki "0 bulgu" VAKUM-DOĞRU olurdu (L-297 dersi).
    expect(f.ia.homeSections, isNotEmpty, reason: 'home bölümü yoksa ölçüm yok');
    expect(f.ia.families, isNotEmpty, reason: 'aile yoksa ölçüm yok');

    final Map<String, List<TitledVoid>> byScreen = <String, List<TitledVoid>>{};
    int offers = 0; // ⓐ SUNAN
    int says = 0; // ⓑ SÖYLEYEN
    for (final MapEntry<String, Widget> s in _surfaces(f).entries) {
      await _pump(tester, s.value);
      byScreen[s.key] = await _sweep(tester);
      final (int a, int b) = _census(tester);
      offers += a;
      says += b;
    }

    _report('BUGÜN — sevk edilen config, taze kurulum', byScreen);

    // ═══ ORAN — PAYDASIYLA. Bir oran, paydası yazılmadan bir sayı değil
    // bir izlenimdir; o yüzden üç kova AYRI sayılıyor ve toplamları
    // yazılıyor. ⛔ `_census` yalnız BOŞ durumda çağrılıyor: dolu bir
    // ekranın güzel görünmesi A3 hakkında hiçbir şey söylemez.
    final int silent =
        byScreen.values.fold(0, (int n, List<TitledVoid> v) => n + v.length);
    final int total = offers + says + silent;
    // ignore: avoid_print
    print('═══ A3 KOVA SAYIMI — BUGÜN (taze kurulum, 12 yüzey) ═══\n'
        '  ⓐ SUNAN   (iş sunuyor)      : $offers\n'
        '  ⓑ SÖYLEYEN (nedenini söylüyor): $says\n'
        '  ⓒ SESSİZ  (KUSUR)           : $silent\n'
        '  ─────────────────────────────────────\n'
        '  payda                        : $total\n'
        '  SESSİZ ORAN                  : '
        '${total == 0 ? "ÖLÇÜLEMEDİ (payda 0)" : "${(100 * silent / total).toStringAsFixed(1)}%"}\n'
        '══════════════════════════════════════════\n');

    // POZİTİF ÇAPA: payda gerçekten doldu mu? Sıfır paydayla "%0 sessiz"
    // yazmak, hiçbir şey ölçmeden temiz rapor etmektir.
    expect(total, greaterThan(0),
        reason: 'kova sayımı boş — oran VAKUM-DOĞRU olurdu');

    // ARTEFAKT — ölçüm TESTİN KENDİSİ tarafından yazılır, elle değil.
    // Elle yazılsaydı bir gün koddan ayrışırdı ve ***bir sayı çapası,
    // denetlediği şey büyüdükçe sessizce yanlışlaşır*** (L-314).
    // ⛔ Tarih YOK: `Date` yazsaydım artefakt her koşuda değişir, `git diff`
    // gürültüye boğulur ve gerçek değişiklik görünmez olurdu.
    File('docs/a3-sessiz-oran.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(<String, Object>{
        'olcut': 'A3 — sessiz oran (payda GENİŞLETİLMİŞ)',
        'tanim': 'docs/A3-SESSIZ-ORAN-TANIMI.md (ÖNCEKİ commit)',
        'pencere': 'BUGÜN — sevk edilen config, taze kurulum',
        'yuzey_sayisi': byScreen.length,
        'yuzeyler': byScreen.keys.toList(),
        'kovalar': <String, int>{
          'a_sunan': offers,
          'b_soyleyen': says,
          'c_sessiz': silent,
        },
        'payda': total,
        'sessiz_oran_yuzde': total == 0 ? -1 : 100 * silent / total,
        'kor_nokta':
            'sayı taşımayan VE liste döndüren kurucudaki başlık — bugün 0, '
                'sayılarak doğrulanıyor',
      }),
    );

    final List<TitledVoid> all =
        byScreen.values.expand((List<TitledVoid> v) => v).toList();
    expect(all, isEmpty,
        reason: 'BAŞLIKLI BOŞLUK: kullanıcı bir vaat görüyor ve altında '
            'hiçbir şey bulmuyor → $all');
  });

  // ═════════════════════════════════════════════════════════════════
  // PENCERE 2 · YARIN — veri kaynakları boşaltılırsa
  // ═════════════════════════════════════════════════════════════════

  testWidgets('YARIN penceresi: veri boşalırsa başlıklı boşluk YOK',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts base = factsFromDisk();

    final Map<String, AppFacts> drained = <String, AppFacts>{
      // Config bir gün hiçbir testi okunabilir bırakmayabilir.
      'liveness BOŞ': AppFacts(
        ia: base.ia,
        battery: base.battery,
        liveness: const <TestLiveness>[],
        history: base.history,
      ),
      // Geçmiş katmanı AÇILAMAZSA — "veri yok" ile "okuyamadım" ayrı hâller.
      'geçmiş AÇILAMADI': AppFacts(
        ia: base.ia,
        battery: base.battery,
        liveness: base.liveness,
        history: const SessionHistoryView.unavailable('test: disk kapalı'),
      ),
      // 🔴 **BU VAKA İLK YAZIMDA YOKTU** ve YARIN penceresini eksik
      // bırakıyordu: `liveness` ve `history` boşaltılmış, ama **aile listesi
      // hiç boşaltılmamıştı.** Oysa `notBuilt` boşalması bu ürünün İLAN
      // EDİLMİŞ HEDEFİ — yol haritası bittiğinde olacak şey. Yani en
      // muhtemel gelecek, penceremin dışındaydı.
      // > *Bir "yarın" penceresi, ürünün gitmeyi VAAT ETTİĞİ yeri
      // > içermiyorsa, yarını değil yalnız arızayı ölçer.*
      'aileler HEPSİ inşa edilmiş': AppFacts(
        ia: LibraryIa(
          tabs: base.ia.tabs,
          homeSections: base.ia.homeSections,
          families: base.ia.built,
          whyNot: base.ia.whyNot,
          poseTiers: base.ia.poseTiers,
          navigation: base.ia.navigation,
        ),
        battery: base.battery,
        liveness: base.liveness,
        history: base.history,
      ),
    };

    final Map<String, List<TitledVoid>> byCase = <String, List<TitledVoid>>{};
    for (final MapEntry<String, AppFacts> c in drained.entries) {
      for (final MapEntry<String, Widget> s in _surfaces(c.value).entries) {
        await _pump(tester, s.value);
        final List<TitledVoid> hits = await _sweep(tester);
        if (hits.isNotEmpty) byCase['${c.key} → ${s.key}'] = hits;
      }
    }

    _report('YARIN — veri kaynakları boşaltıldı', byCase);

    expect(byCase, isEmpty,
        reason: 'Veri boşaldığında başlıklı boşluk ÜRETEN yüzey: $byCase — '
            'config bu ürünün ASIL değişim yüzeyi, yani bu latent değil '
            'bekleyen bir kusurdur');
  });
}

// ═══════════════════════════════════════════════════════════════════
// YARDIMCILAR
// ═══════════════════════════════════════════════════════════════════

/// Ölçülen yüzeyler. ⛔ `LiveCaptureScreen` **BOŞ kaynakla** kuruluyor —
/// hiç kare gelmeyen hâl onun gerçek "boş"udur.
///
/// 🔴 **`FamilyPage` PAYDAYA SONRADAN GİRDİ — ve onu POZİTİF KONTROL buldu.**
/// İlk yazımımda payda yalnız altı SEKME yüzeyiydi. D1'in pozitif kontrolü
/// `LibraryScreen`i boş `liveness` ile kurdu ve **ötmedi** — çünkü aradığı
/// başlık (`Measured by camera in this build (N)`) `LibraryScreen`de DEĞİL,
/// bir dokunuş ötedeki `FamilyPage`de yaşıyor. Yani paydam, ölçmek istediğim
/// kusurun BULUNDUĞU ekranı içermiyordu.
/// > ***Ölçüm aracının körlüğü, bulguya dönüşmeden önce PAYDAYLA yakalanır —***
/// > ve bu turda onu payda değil, **pozitif kontrol** yakaladı: paydam
/// > sessizce eksikti, kapı yeşil yanacaktı.
Map<String, Widget> _surfaces(AppFacts f) => <String, Widget>{
      'Home': HomeScreen(facts: f, onOpenLibrary: () {}),
      'Library': LibraryScreen(facts: f),
      'Progress': ProgressScreen(facts: f),
      'Profile': ProfileScreen(facts: f),
      'WhatLissomDoesntDo': WhatLissomDoesntDoScreen(
        items: f.ia.whyNot,
        excluded: f.battery.excluded,
        poseTiers: f.ia.poseTiers,
      ),
      'LiveCapture': LiveCaptureScreen(
        test: f.battery.tests.values.first,
        batteryVersion: f.battery.version,
        sourceOverride: FakePoseSource(const <PoseSourceEvent>[]),
      ),
      // Aile sayfaları ÖRNEK BAŞINA — kusurun birimi *ekran sınıfı* değil
      // *kullanıcının vardığı yer* (`reachable_but_empty_test.dart` §①
      // ile aynı birim; iki dosya aynı şeyi iki türlü saymamalı).
      for (final LibraryFamily fam in f.ia.families)
        'FamilyPage «${fam.title}»': FamilyPage(family: fam, facts: f),
    };

void _report(String window, Map<String, List<TitledVoid>> byKey) {
  // ignore: avoid_print
  print('\n═══ A3 BAŞLIKLI BOŞLUK — $window ═══');
  if (byKey.isEmpty) {
    // ignore: avoid_print
    print('  (hiçbir yüzeyde bulgu yok)');
  }
  byKey.forEach((String k, List<TitledVoid> v) {
    // ignore: avoid_print
    print('  ${v.isEmpty ? "✅" : "🔴"} $k : ${v.length}${v.isEmpty ? "" : "  $v"}');
  });
  // ignore: avoid_print
  print('══════════════════════════════════════════\n');
}

/// Kör noktayı SAYAR: sayı taşımayan **ve** liste döndüren bir kurucudaki
/// başlıklar. Kaynak taraması, çünkü soru *"böyle bir başlık YAZILDI mı"* —
/// çizim değil yapı sorusu.
(List<String>, int) _uncountedEyebrowsInListBuilders() {
  const List<String> files = <String>[
    'lib/app/home_screen.dart',
    'lib/app/library_screen.dart',
    'lib/app/progress_screen.dart',
    'lib/app/profile_screen.dart',
    'lib/app/what_lissom_doesnt_do.dart',
    'lib/app/surfaces.dart',
  ];
  final RegExp eyebrow = RegExp(r'LissomEyebrow\(');
  final RegExp listBuilder = RegExp(r'List<Widget>\s+_\w+\(');
  final List<String> out = <String>[];
  int scanned = 0;
  for (final String path in files) {
    final List<String> lines = File(path).readAsLinesSync();
    bool inListBuilder = false;
    int depth = 0;
    for (int i = 0; i < lines.length; i++) {
      final String ln = lines[i];
      if (listBuilder.hasMatch(ln)) {
        inListBuilder = true;
        depth = 0;
      }
      if (!inListBuilder) continue;
      depth += '{'.allMatches(ln).length - '}'.allMatches(ln).length;
      if (eyebrow.hasMatch(ln)) {
        scanned++;
        // Formatter argümanı alt satırlara kaydırabilir: çağrının parantezi
        // kapanana kadar olan aralık okunur, yalnız ilk satır değil.
        final StringBuffer call = StringBuffer(ln);
        int open = '('.allMatches(ln).length - ')'.allMatches(ln).length;
        for (int j = i + 1; open > 0 && j < lines.length && j <= i + 6; j++) {
          call.write(lines[j]);
          open += '('.allMatches(lines[j]).length -
              ')'.allMatches(lines[j]).length;
        }
        final String span = call.toString();
        // Sayı taşıyan başlık D1'in kapsamında. Taşımayan, VE liste
        // döndüren bir kurucuda olan, ikisinden de geçer.
        if (!_kCount.hasMatch(span) && !span.contains(r'${')) {
          out.add('$path:${i + 1}  ${ln.trim()}');
        }
      }
      if (depth < 0) inListBuilder = false;
    }
  }
  return (out, scanned);
}
