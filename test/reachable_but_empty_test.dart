/// **"VARILABİLİR AMA BOŞ" ORANI — ölçüm (L-297).**
///
/// Choreia ölçtü: gezilebilirlik sayısı **KATI 3 / GEVŞEK 5** ama **34
/// stilin 33'ü ÇIKMAZ SOKAK** — kartına gidilir, sayfası açılır, **ders
/// yoktur.** Ailenin 08-07 hükmü *"üç app gezilemez"*di; ölçüm
/// ***"geziliyor ama gidilen yerde bir şey yok"*** diyor. **Aynı kusur
/// değil:** biri **ROTA** açar, öteki **İÇERİK** ister.
///
/// ═══════════════════════════════════════════════════════════════════
/// ## TANIM — ÖNCE yazıldı, ÖLÇÜMDEN sonra DEĞİŞTİRİLMEDİ
/// ═══════════════════════════════════════════════════════════════════
///
/// ⛔ Koordinatör kısıtı: *"tanım ölçümden sonra yazılırsa, tanım sayıyı
/// takip eder"* (Goodhart). Bu blok, sayı görülmeden yazıldı ve sayıya
/// göre gevşetilmedi.
///
/// ⛔ Ve Choreia'nın modeli (`library.cards × offers(runnableSteps) ×
/// canStart`) **KOPYALANMADI** — onun içerik birimi *ders*, benimki
/// *ölçüm testi*. Karşılığı aşağıda kendi ağacımdan türetildi.
///
/// **① VARILABİLİR HEDEF** — kabuktan başlayıp **yalnız boyanmış bir
/// kontrole basarak** ulaşılan her ayrı ekran örneği. Aile sayfaları
/// **örnek başına** sayılır (altı aile kartı = altı hedef), çünkü kusurun
/// birimi *ekran sınıfı* değil *kullanıcının vardığı yer*.
///
/// **② İÇERİĞİ VAR** — hedef, **gerçek config'ten türetilmiş en az bir
/// ÖĞE** sunuyor (bu hatta: motorun okuyabildiği testler). Başlık, giriş
/// metni ve dürüstlük kutusu **çerçevedir, içerik değildir** — aksi hâlde
/// her ekran tanım gereği "dolu" olurdu ve ölçü hiçbir şey ölçmezdi.
///
/// **③ BOŞ** = varılabilir ∧ ¬içeriği var.
///
/// **④ VE BOŞ İKİYE AYRILIR — bu hattın kendi ayrımı, ve kusur yalnız
/// ikincisidir:**
///   - **BOŞ-BEYANLI**: sayfa neden boş olduğunu ADIYLA söylüyor
///     (`honestyBox` + envanter satırı). *Tasarlanmış dürüst hâl.*
///   - **BOŞ-SESSİZ**: kullanıcı varıyor, hiçbir şey bulmuyor, **ve
///     hiçbir şey nedenini söylemiyor.** ⛔ **Kusur budur.**
///
/// > ***"Boş" tek başına bir kusur değildir; kusur, boşluğun SESSİZ
/// > olmasıdır.*** (Bu ayrım bugün `⑤ önizleme` vakasında ölçüldü:
/// > JabLab'ın yokluğu BEYANLI, benimki SESSİZDİ — aynı yokluk, iki
/// > ayrı sınıf.)
///
/// **⑤ DDENKLEM DENETLENİR:** `varılabilir = içeriği-var + boş-beyanlı +
/// boş-sessiz`. Türetilmiş bir toplam kaynağını denetleyemez, o yüzden
/// üç küme AYRI sayılıp toplamları varılabilir sayısına karşı sınanır.
///
/// ⚠️ **Envanter YÜRÜYEREK üretilir** (boyanmış kartlara basılarak),
/// koddan desenle DEĞİL — *bir rota tablosu kodun ANLATIMI, yürüyüş ise
/// GERÇEĞİ* (bu vardiyada üç kez ödendi).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  testWidgets('VARILABİLİR AMA BOŞ — oran, yürüyerek ölçülür',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts facts = factsFromDisk();

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: config gerçekten aile taşıyor mu? Taşımıyorsa
    // aşağıdaki "0 boş" sonucu VAKUM-DOĞRU olurdu.
    expect(facts.ia.families, isNotEmpty,
        reason: 'IA config aile taşımıyorsa bu tur hiçbir şey ölçmez');

    final List<String> withContent = <String>[];
    final List<String> emptyDeclared = <String>[];
    final List<String> emptySilent = <String>[];

    for (final LibraryFamily fam in facts.ia.families) {
      // Library sekmesine dön ve KARTA BAS — kod okuyarak değil.
      await _openLibrary(tester, facts);
      final Finder card = find.text(fam.title);
      // 🪤 KAYDIRMA ŞART: ilk yazımım kaydırmıyordu ve altı aileden
      // YALNIZ BİRİNE ulaştı — kalan beşi katlamanın altındaydı. Denklem
      // denetimi (1 ≠ 6) bunu yakaladı; **o olmasaydı "0 boş-sessiz" diye
      // SAHTE TEMİZ rapor edecektim.** Ekranda görünmeyen bir kartı
      // "ulaşılamaz" saymak, ölçüm aracının körlüğünü bulguya çevirir.
      await scrollTo(tester, card);
      if (card.evaluate().isEmpty) {
        // Kartı HİÇ çizilmeyen aile: varılabilir DEĞİL, sayıma girmez —
        // ve bu ayrı bir bulgudur, aşağıdaki denklem onu yakalar.
        continue;
      }
      await tester.tap(card.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(FamilyPage), findsOneWidget,
          reason: '«${fam.title}» kartına basıldı ama FamilyPage açılmadı '
              '— yürüyüş kırık, sayı okunamaz');

      // İÇERİK = gerçek config'ten türetilmiş ÖĞE. Bu hatta: motorun
      // okuyabildiği testlerin adları. Çerçeve (başlık/giriş/dürüstlük
      // kutusu) İÇERİK SAYILMAZ.
      final bool hasItems = facts.live
          .any((TestLiveness x) => find.text(x.name).evaluate().isNotEmpty);
      final bool declares =
          find.byKey(FamilyPage.honestyKey).evaluate().isNotEmpty;

      if (hasItems) {
        withContent.add(fam.title);
      } else if (declares) {
        emptyDeclared.add(fam.title);
      } else {
        emptySilent.add(fam.title);
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    final int reachable =
        withContent.length + emptyDeclared.length + emptySilent.length;

    // ignore: avoid_print
    print('\n═══ VARILABİLİR AMA BOŞ — Lissom (yürüyerek) ═══');
    // ignore: avoid_print
    print('  varılabilir aile hedefi : $reachable / ${facts.ia.families.length}');
    // ignore: avoid_print
    print('  içeriği VAR             : ${withContent.length}  ${withContent}');
    // ignore: avoid_print
    print('  BOŞ-BEYANLI (dürüst hâl): ${emptyDeclared.length}  ${emptyDeclared}');
    // ignore: avoid_print
    print('  BOŞ-SESSİZ  (KUSUR)     : ${emptySilent.length}  ${emptySilent}');
    // ignore: avoid_print
    print('═══════════════════════════════════════════════\n');

    // ⑤ DENKLEM DENETLENİR — türetilmiş toplam kaynağını denetleyemez.
    expect(reachable, facts.ia.families.length,
        reason: 'her aile kartı varılabilir olmalıydı; sayı tutmuyorsa '
            'yürüyüş bir hedefi ATLADI ve oran yanlış');

    // KUSUR EŞİĞİ: boş-SESSİZ sıfır olmalı. (Boş-beyanlı bir kusur
    // DEĞİL — tasarlanmış dürüst hâl, §④.)
    expect(emptySilent, isEmpty,
        reason: 'varılabilir ama BOŞ ve nedenini SÖYLEMEYEN sayfa: '
            '$emptySilent — kullanıcı bir yere gidiyor, hiçbir şey '
            'bulmuyor, ve hiçbir şey nedenini söylemiyor');
  });
}

Future<void> _openLibrary(WidgetTester tester, AppFacts facts) async {
  final int i = facts.ia.tabs.indexOf('library');
  await tester.tap(find.byIcon(Icons.grid_view_outlined).first,
      warnIfMissed: false);
  await tester.pumpAndSettle();
  expect(i, greaterThanOrEqualTo(0),
      reason: 'library sekmesi config\'te yok — yürüyüş başlayamaz');
}
