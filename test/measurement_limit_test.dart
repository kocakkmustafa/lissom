/// **ÖLÇÜM-SINIRI BEYANI — KAPIDA (L-263).**
///
/// Gecenin açık ihlali ⑱ şuydu: tasarım mockup'ı **"±5° typical error"**
/// yazıyordu ve **o rakam hiç ölçülmemişti.** Kapanış, sayıyı **isimli bir
/// yoklukla** değiştirmekti:
///
/// > *"We have not measured how far our own readings sit from a reference
/// > instrument, so we do not print a margin of error."*
///
/// **Cümle sevk edildi; şimdi onu yanlışa çevirecek en makul değişikliği
/// soruyorum (J-133).** Cevap açık: **birinin bir gün oraya bir sayı
/// yazması.** Kimse yalan söylemeye karar vermez — bir tasarım turu, bir
/// "mockup'a uyduralım" kararı yeter. O an cümle yalan olur.
///
/// ## İki kapı, iki ayrı şeyi ölçüyor
///
/// 1. **ERİŞİLEBİLİRLİK** — beyan kabuktan görülebiliyor mu? Sessizce
///    kaldırılırsa, ürün marjı olmadığını söylemeyi bırakmış olur.
/// 2. **İCAT YASAĞI** — ortada bir doğruluk ÖLÇÜMÜ yokken hiçbir yüzeyde
///    marj rakamı belirmemeli.
///
/// ## Eşik icat DEĞİL — L-254'ün şartıyla aynı biçim
///
/// *"Marj yazmak yasak"* demiyorum; bu bir gün yapılacak ölçümü yasaklardı.
/// Kural **referansa bağlı**: bir marj rakamı, `docs/ACCURACY-*.md` adıyla
/// beyan edilmiş, **medyan · p95 · kabul ölçütü** taşıyan bir çalışma varsa
/// meşrudur. Ölçüm gelirse kapı kendiliğinden serbest bırakır (L-248).
///
/// ## Bu kapının ÖLÇMEDİĞİ — isimle
///
/// Beyanın **hangi ekranlarda** duracağını ölçmüyor. Bugünkü yerleşim bir
/// tasarım kararı (dipnot ölçüm yüzeylerinin dibine ait; sınır sayfası kendini
/// tekrar etmez — *caveat enflasyonu*), ve **bugünkü yerleşimi çivilemek**
/// tam olarak L-261'in kusuru olurdu: doğru bir yeniden düzenleme kırmızı
/// yanardı. Kapı yalnız **hiç görünmez olmasını** engelliyor.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/surfaces.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Marj-rakamı biçimleri — **tek adres** (L-256).
final RegExp _marginFigure = RegExp(
    r'(±|\+/-|plus or minus)\s*\d+([.,]\d+)?\s*(°|deg|degree)|'
    r'\btypical error\b|\bmargin of error of\b',
    caseSensitive: false);

/// Bir belge, doğruluk ÇALIŞMASI mı? — **saf yüklem, tek adres** (L-256).
///
/// ⚠️ İlk hâli `docs/` altında *"reference instrument"* + medyan + p95
/// **kelimelerinin birlikteliğini** arıyordu ve **kendi rapor belgeme**
/// takıldı: o belge çalışmanın **yokluğunu** anlatıyor, varlığını değil.
/// Kapı bu yüzden *"çalışma var, beyanı güncelle"* diyordu — yani gecenin
/// tam da düzelttiğim kusurunu, ters yönden, **kapının kendisi** üretti.
///
/// Düzeltme: **rastlantısal metin eşleşmesi yeterli değil.** Bir doğruluk
/// çalışması ① adıyla beyan edilir (`ACCURACY-*.md`) ② medyan ve p95 taşır
/// ③ **kabul ölçütünü** yazar — L-254'ün şartıyla aynı biçim.
bool isAccuracyStudy(String fileName, String content) {
  if (!RegExp(r'^ACCURACY-.*\.md$').hasMatch(fileName)) return false;
  final String s = content.toLowerCase();
  return RegExp(r'\b(medyan|median)\b').hasMatch(s) &&
      s.contains('p95') &&
      RegExp(r'kabul ölçütü|acceptance criterion').hasMatch(s);
}

bool hasAccuracyStudy() {
  final Directory d = Directory('docs');
  if (!d.existsSync()) return false;
  // Ad ÖNCE bakılır: içeriği okumak pahalı ve `.DS_Store` gibi ikili
  // dosyalarda UTF-8 çözümü PATLIYOR — kapı, taradığı dizinin çöpüne
  // takılıp ölçüm yapamaz hâle geliyordu.
  return d.listSync(recursive: true).whereType<File>().any((File f) {
    final String name = f.uri.pathSegments.last;
    if (!RegExp(r'^ACCURACY-.*\.md$').hasMatch(name)) return false;
    return isAccuracyStudy(name, f.readAsStringSync());
  });
}

/// **GELİŞTİRİCİ-YÜZÜ** config anahtarları — kullanıcı bunları GÖRMEZ.
///
/// ⚠️ Kapı ilk yazımda tüm config metinlerini taradı ve `_notes` içindeki
/// mühendislik kayıtlarını yakaladı: *"ham 3D acı ROM uçlarında **±5,7°**
/// sistematik hata verir"* ve *"gravityYaw ile hip_flexion **±30°** yaw'da
/// kayıyordu"*. Birincisi geliştiriciye yazılmış bir ÖLÇÜM kaydı, ikincisi
/// bir marj değil bir KOŞUL.
///
/// Yasak **kullanıcıya marj vaat etmek**; mühendislik defterini susturmak
/// değil. L-257'nin katman ayrımının aynısı: aynı kelime, farklı katmanda
/// farklı şey.
const Set<String> kDeveloperKeys = <String>{
  '_notes', 'basis', 'source', 'note', 'rationale', 'provenance',
};

/// Config'in **kullanıcı-yüzü** metinleri — geliştirici anahtarları HARİÇ.
Iterable<String> _strings(Object? n, [String key = '']) sync* {
  if (kDeveloperKeys.contains(key)) return;
  if (n is String) {
    yield n;
  } else if (n is Map<String, dynamic>) {
    for (final MapEntry<String, dynamic> e in n.entries) {
      yield* _strings(e.value, e.key);
    }
  } else if (n is List) {
    for (final Object? v in n) {
      yield* _strings(v, key);
    }
  }
}

void main() {
  test('POZİTİF İKİZ: marj deseni ve artefakt-bulucu ÇALIŞIYOR', () {
    // L-255: iki iddia da YOKLUK ölçüyor.
    for (final String bad in <String>[
      'Readings carry a ±5° typical error.',
      'We report a margin of error of 3 degrees.',
    ]) {
      expect(_marginFigure.hasMatch(bad), isTrue,
          reason: 'BULUCU BOZUK: «$bad» apaçık bir marj rakamı ve desen onu '
              'bulamıyor — icat yasağının her yeşili vakum-doğru');
    }

    // ⭐ TERS İKİZ — kapının DARLIĞI (L-248). Bu cümleler MEŞRU ve KALMALI.
    for (final String ok in <String>[
      MeasurementLimitsFootnote.accuracyStatement,
      'Measured 42° on the left and 38° on the right.',
      'Below the lowest reference line by 4 degrees.',
    ]) {
      expect(_marginFigure.hasMatch(ok), isFalse,
          reason: 'KAPI FAZLA GENİŞ: «${ok.substring(0, 40)}…» bir marj '
              'İDDİASI değil. Ölçülmüş bir DEĞERİ derece cinsinden yazmak '
              'meşrudur — yasak olan, ölçülmemiş bir HATA PAYI uydurmak.');
    }
  });

  test('POZİTİF İKİZ: artefakt YÜKLEMİ, gerçek bir çalışmayı tanıyor', () {
    const String study = '''
# Doğruluk çalışması
Medyan sapma 2,4°, p95 6,1°.
Kabul ölçütü: p95 < 8° — gerekçe: bant genişliğinin yarısı.
''';
    expect(isAccuracyStudy('ACCURACY-2026-09.md', study), isTrue,
        reason: 'BULUCU BOZUK: apaçık bir doğruluk çalışmasını tanımıyor — '
            'o hâlde "çalışma yok" dalı sonsuza kadar seçilir ve kapı '
            'ölçümden SONRA da eski beyanı korur');

    // ⭐ TERS İKİZ: yokluğu ANLATAN bir belge, çalışma SAYILMAZ. Kapı ilk
    // yazımda tam buna takıldı (L-263).
    expect(
        isAccuracyStudy('KOORDINATOR-CEVAPLARI-2026-08-07.md',
            'reference instrument … medyan 11,29° … p95 37,47° … kabul ölçütü'),
        isFalse,
        reason: 'KAPI FAZLA GENİŞ: çalışmanın YOKLUĞUNU anlatan bir raporu '
            'çalışma sandı. Bir belgeden bahsetmek, o belgenin varlığı '
            'değildir.');
    // ⭐ TERS İKİZ: mühendislik defteri SUSTURULMAZ. `_notes` içindeki
    // "±5,7° sistematik hata" geliştiriciye yazılmış bir ölçüm kaydıdır ve
    // kalmalıdır — kapı onu yakalarsa doğru davranışı cezalandırır (L-263).
    expect(
        _strings(<String, dynamic>{
          '_notes': <String>['ham 3D ROM uçlarında ±5.7° sistematik hata'],
          'reason': 'A phone camera cannot see breathing.',
        }).toList(),
        <String>['A phone camera cannot see breathing.'],
        reason: 'KAPI FAZLA GENİŞ: geliştirici notunu kullanıcı metni saydı');

    expect(isAccuracyStudy('ACCURACY-taslak.md', 'medyan 2° p95 5°'), isFalse,
        reason: 'kabul ölçütü YAZILMAMIŞ bir ölçüm, eşiği okuyucuya '
            'bırakır — L-254 şartıyla aynı: ölçüt ölçümün yanında yaşar');
  });

  test('İCAT YASAĞI: doğruluk ölçümü yokken marj rakamı YAZILAMAZ', () {
    final List<String> hits = <String>[];
    for (final FileSystemEntity f
        in Directory('config').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      hits.addAll(_strings(jsonDecode(File(f.path).readAsStringSync()))
          .where(_marginFigure.hasMatch));
    }
    for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String src = File(f.path)
          .readAsStringSync()
          .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '')
          .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');
      hits.addAll(RegExp(r"'([^'\\]{4,})'")
          .allMatches(src)
          .map((RegExpMatch m) => m.group(1)!)
          .where(_marginFigure.hasMatch));
    }

    if (hasAccuracyStudy()) {
      // Ölçüm geldi: rakam artık MEŞRU olabilir. Ama beyan da güncellenmiş
      // olmalı — "ölçmedik" cümlesi ölçüldükten sonra YALANDIR.
      expect(MeasurementLimitsFootnote.accuracyStatement,
          isNot(contains('have not measured')),
          reason: 'Doğruluk çalışması artefaktı VAR ama beyan hâlâ '
              '"ölçmedik" diyor. Ölçüldükten sonra o cümle yalandır.');
      return;
    }
    expect(hits, isEmpty,
        reason: 'Ortada HİÇBİR doğruluk ölçümü yokken bir marj rakamı '
            'yazılmış:\n  ${hits.join("\n  ")}\n\n'
            'Sevk edilen beyan şunu diyor: "We have not measured how far our '
            'own readings sit from a reference instrument." O cümle ARTIK '
            'YANLIŞ. Bu, madde ⑱\'in geri gelmesidir — tasarım mockup\'ındaki '
            '"±5° typical error" tam olarak böyle doğmuştu.');
  });

  testWidgets('ERİŞİLEBİLİRLİK: beyan kabuktan GÖRÜLEBİLİYOR', (
    WidgetTester tester,
  ) async {
    // Sessizce kaldırılırsa, ürün "marjımız yok" demeyi BIRAKMIŞ olur —
    // ve sessizlik, dürüstlüğün yokluğuyla aynı şeye benzer (L-253).
    pinTallSurface(tester, height: 6000);
    final AppFacts facts = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();

    int seen = 0;
    for (int i = 0; i < facts.ia.tabs.length; i++) {
      await tester.tap(find.byType(NavigationDestination).at(i));
      await tester.pumpAndSettle();
      seen += find
          .textContaining('we do not print a margin of error')
          .evaluate()
          .length;
    }
    expect(seen, greaterThan(0),
        reason: 'Ölçüm-sınırı beyanı HİÇBİR sekmede görünmüyor. Hangi '
            'ekranda duracağı bir tasarım kararı ve bu kapı ona karışmıyor '
            '— ama hiç görünmemesi, ürünün marjı olmadığını söylemeyi '
            'bırakması demektir.');
  });
}
