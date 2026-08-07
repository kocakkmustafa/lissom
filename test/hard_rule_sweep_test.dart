/// **SERT KURAL SÜPÜRMESİ (L-259)** — koordinatörün J-143 aktarımı.
///
/// > *"kural var" ile "kural ZORLANIYOR" ayrı şeylerdir.*
///
/// ⛔ listemin **on kalemi** tarandı. Taksonomi, kapısı olmayanı tek kutuya
/// koymamak için: **① meşru hâli var · ② kural kendi ölçütünü geçemiyor ·
/// ③ yanlışlayacak referans yok (imkânsız).** Üçü karışırsa, **hangisinin bir
/// gün bağlanabileceği kaybolur.**
///
/// | ⛔ Kural | Kapı | Not |
/// |---|---|---|
/// | gauge/dolum göstergesi | `visual_ban_test` | **5/5 yüzey** (L-258'de 1/5'ti) |
/// | tezahürat/ünlem | `copy_gate` + `screen_evidence_test` | metin katmanı |
/// | `improved`/`worsened` | `copy_gate` + `progress_screen_test` | metin katmanı |
/// | tıbbi dil | `wellness_lint.py` | 8 no-arg kapıdan biri |
/// | eşit-ağırlık listeleme | `library_screen_test` + `ia_test` | yapı katmanı |
/// | kıyas kapalı (MDC) | `shipped_claim_test` | config katmanı |
/// | streak/rozet | `home_screen_test` | metin + yapı |
/// | bant etiketi < banttan | `battery_summary_view_test` | ⚠️ aşağıya bak |
/// | **mood takibi** | **BU DOSYA** | kapısı yoktu |
/// | **ayrı yol-haritası sayfası** | **BU DOSYA** | kapısı yoktu |
///
/// ## ⚠️ «Bandın altındaki değere bant etiketi verilmez» — kapı UYUYOR
///
/// Kural **kapıda**, ama kapının sınadığı `BatterySummaryView` kabuktan
/// **erişilemiyor** (L-225: `lib/` içinde tek atıf kendi dosyası). Yani kapı
/// yeşil ve **doğru**, fakat bugün **hiçbir kullanıcının göremediği** bir
/// yüzeyi koruyor.
///
/// Bu, "kapı yok" DEĞİL — **öznesi uyuyan bir kapı.** Ve kapıyı erişilebilir
/// ekranlara kopyalamak **yanlış** olurdu: onlar bant etiketi hiç basmıyor,
/// yani kopya kapı **vakum-doğru** olurdu (tam da bu gecenin kusuru). Doğru
/// kayıt: *özne uyandığı gün kapı zaten yerinde.* Erişilebilirlik kararı
/// koordinatörde (L-225).
///
/// ## Sınıf ③ örneği — mekanikleştirilemez olan
///
/// *"geri sayım estetiği yok"* bir **algı** hükmü: `retest_countdown`ın
/// DAVET olarak okunup okunmadığını yanlışlayacak bir referans yok. Metin
/// tarafı (`copy_gate`) rakam-geri-sayımı yakalar; **estetiği** yakalayamaz.
/// Bunu kapısız bırakıyorum ve **③ olarak adlandırıyorum** — ② ile
/// karıştırılırsa, bir gün bağlanabileceği sanılır.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Ruh-hâli **TAKİBİ** — **tek adres** (L-256).
///
/// ⚠️ İlk yazımda desen `feeling`i düz yasakladı ve **dürüst bir güvenlik
/// notunu öldürdü**: *"We're sorry you're feeling discomfort… please speak to
/// a doctor"*. Koordinatörün ters-ikiz uyarısının **birebir** hâli:
/// *bir kelimeyi yasaklamak, o kelimeyi doğru kullanan cümleyi de öldürür.*
///
/// Yasak **kelime** değil, **edim**: ruh hâlini SORMAK veya KAYDETMEK.
/// Kullanıcının hissettiğine bir cümlede DEĞİNMEK — özellikle ağrı/rahatsızlık
/// güvenlik notunda — meşrudur ve kalmalıdır.
final RegExp _moodWords = RegExp(
    r'(how (are|do) you feel|how (is|was) your (mood|day)|your mood|'
    r'rate your (day|mood)|log your (mood|feeling)|'
    r'mood (score|entry|log|tracking|check))',
    caseSensitive: false);

void main() {
  test('POZİTİF İKİZ: mood deseni, olması gereken cümleyi buluyor', () {
    // L-255: aşağıdaki iddia bir YOKLUK. Bozuk desenle de sonsuza dek yeşil.
    expect(_moodWords.hasMatch('How is your mood today?'), isTrue,
        reason: 'BULUCU BOZUK: desen apaçık bir mood cümlesini bulamıyor');
    expect(_moodWords.hasMatch('This measurement moved 4 degrees.'), isFalse,
        reason: 'KAPI FAZLA GENİŞ: sıradan ölçüm cümlesini mood sandı');

    // ⭐ TERS NEGATİF İKİZ — kapının DARLIĞINI koruyan dal (L-248).
    // Bu cümle SEVK EDİLMİŞ ve DOĞRU. Kapı bir gün genişletilirse burada
    // patlar; yoksa dürüst bir güvenlik notu sessizce yasaklanır.
    const String shippedSafetyNote =
        "We're sorry you're feeling discomfort. Lissom cannot assess what is "
        'causing pain and cannot give medical advice.';
    expect(_moodWords.hasMatch(shippedSafetyNote), isFalse,
        reason: 'KAPI FAZLA GENİŞ: sevk edilmiş AĞRI GÜVENLİK NOTUNU mood '
            'takibi saydı. Yasak kelime değil EDİM: ruh hâlini sormak/'
            'kaydetmek. Kullanıcının hissettiğine değinen dürüst bir '
            'güvenlik cümlesi meşrudur — ve bir kapı onu öldürüyorsa, '
            'kapı yanlıştır.');
  });

  test('⛔ MOOD TAKİBİ YOK — config ve kabuk yüzeyinde', () {
    // Sınıf ①: meşru hâli VAR (bir gün ürün duygu-durum sorabilir), o yüzden
    // kural bir KARAR; kapı o kararın sessizce dönmesini engelliyor.
    final List<String> hits = <String>[];
    for (final FileSystemEntity f
        in Directory('config').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      final String raw = File(f.path).readAsStringSync();
      if (_moodWords.hasMatch(raw)) {
        hits.add(f.uri.pathSegments.last);
      }
    }
    // Pozitif çapa: config gerçekten okundu mu (L-183)?
    expect(Directory('config').listSync(recursive: true).whereType<File>(),
        isNotEmpty);
    expect(hits, isEmpty,
        reason: 'Ruh-hâli takibi ürüne girmiş: ${hits.join(", ")}. '
            'Bu bir HATA olmayabilir — ama bir KARAR, ve sessizce '
            'alınmamalı. Lissom ölçtüğünü söyler; nasıl hissettiğini '
            'sormaz.');
  });

  testWidgets('⛔ AYRI YOL-HARİTASI SAYFASI YOK — kurulmamışlar Library İÇİNDE',
      (WidgetTester tester) async {
    // Sınıf ①: meşru hâli var (bir yol haritası sayfası kurulabilir), ve
    // yasak tam olarak ONU engelliyor: kurulmamış aileler kendi sayfasına
    // taşınırsa, "yakında" vaadinin sayfa hâli olur (M-F-186).
    pinTallSurface(tester, height: 5000);
    final AppFacts facts = factsFromDisk();

    // ① Kurulmamış aileler için AYRI SEKME yok — sekme kabuğun rotası.
    final List<LibraryFamily> notBuilt = facts.ia.families
        .where((LibraryFamily f) => f.status == FamilyStatus.notBuilt)
        .toList();
    expect(notBuilt, isNotEmpty, reason: 'pozitif çapa: kurulmamış aile var');
    for (final String tab in facts.ia.tabs) {
      expect(RegExp(r'roadmap|upcoming|soon|planned', caseSensitive: false)
              .hasMatch(tab),
          isFalse,
          reason: '«$tab» sekmesi bir yol-haritası destinasyonu. Kurulmamış '
              'aileler kendi sekmesine taşınırsa, aktif dalga ile eşit '
              'ağırlık kazanır — §5.4 hükmünün tam tersi.');
    }

    // ② Ve kurulmamış aile adları LibraryScreen ALT AĞACINDA görünüyor —
    //    yani ayrı bir yüzeye taşınmamışlar.
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();
    await tester.tap(
        find.byType(NavigationDestination).at(facts.ia.tabs.indexOf('library')));
    await tester.pumpAndSettle();

    expect(find.byType(LibraryScreen), findsOneWidget,
        reason: 'Library açılmadı — aşağıdaki iddia başka ekranı ölçüyor');
    for (final LibraryFamily f in notBuilt) {
      expect(
          find.descendant(
              of: find.byType(LibraryScreen), matching: find.text(f.title)),
          findsOneWidget,
          reason: '«${f.title}» Library içinde görünmüyor. Kurulmamış aileler '
              'ya burada KOMPAKT bir bölümde durur ya da hiç durmaz — '
              'ayrı bir yol-haritası sayfası YASAK.');
    }
  });
}
