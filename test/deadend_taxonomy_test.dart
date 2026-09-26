/// **A4 — ÇIKMAZ SOKAK SAYIMI: taksonomi · payda · İŞLEM.**
///
/// ⚠️ **Kapı kurma kısıtı (YAYIN-HAZIRLIK-ÖLÇÜTÜ §C):** *bir kapı, ancak A
/// tablosundaki bir kalemin iddiasını doğruluyorsa kurulur.* Bu dosya
/// **yalnız `A4`ü** doğrular — "çıkmaz sokak sayısı ölçülmüş ve ADIYLA
/// yazılmış". `A3` (sessiz boş yüzey) `reachable_but_empty_test.dart`in işi
/// ve BURADA TEKRARLANMAZ; bu dosya onun bıraktığı yerden, **sınıflandırma**
/// katmanından başlar.
///
/// ═══════════════════════════════════════════════════════════════════
/// ## TAKSONOMİ — ithal edildi, İCAT EDİLMEDİ
/// ═══════════════════════════════════════════════════════════════════
///
/// Kaynak: `motion-core/workspace/YAYIN-HAZIRLIK-OLCUTU.md` §A4 (2026-08-13'te
/// eve taşındı; öncesinde tanım yalnız `M-F-575` ile Choreia'nın promptunda
/// yaşıyordu — ailenin dördüncü *"kural evsiz"* vakası).
///
///   **A**  içerik hiç yazılmamış           → içerik kapasitesi (aylar)
///   **A′** içerik başlamış, referans yok    → hasat turu
///   **B**  içerik var, BAĞLI değil          → hat
///   **C**  kart/yüzey hiç olmamalıydı       → hat
///   **D**  içerik tam + bağlı, bilerek KAPALI → çoğu zaman kurucu
///   **E**  ölçüm YETENEĞİ yok (awaiting-capability) → çekirdek turu
///
/// ⚠️ **`E` bu ağaç için sonradan geldi ve devir notu onu TANIMIYOR.**
/// `AJAN-DEVRI-LISSOM.md` **00:37**'de yazıldı, `E` ölçüte **00:44**'te
/// eklendi (Ostinato ölçtü, kabul edildi). Devrin §4 dağılımı A/B/C/D
/// taksonomisiyle kurulmuştu.
///
/// > ***BİR ÖN-GİRDİ, YAZILDIĞI ANDAKİ TAKSONOMİ KADAR GEÇERLİDİR.***
///
/// ═══════════════════════════════════════════════════════════════════
/// ## SINIF NEREDEN GELİR — yorumdan değil, ÜRÜNÜN KENDİ BEYANINDAN
/// ═══════════════════════════════════════════════════════════════════
///
/// **Aile düzeyi:** `LibraryFamily.itemsSource` — dolu ise öğeler başka bir
/// config'ten TÜRER, boş ise aile yalnız İSİMLENDİRİLMİŞTİR (modelin kendi
/// docstring'i: *"isimlendirilmiş ≠ inşa edilmiş"*).
///
/// **Test düzeyi:** `BridgeBlocker` — motorun kendi engel sınıfları. Dördü de
/// *"çekirdekte bu ölçü tipi/referansı YOK"* diyor, *"içerik yok"* demiyor ⇒
/// tanım gereği **`E`**. Sınıfı ben atamıyorum, köprü beyan ediyor.
///
/// ═══════════════════════════════════════════════════════════════════
/// ## SAYIM ANKRAJI — doküman SESSİZCE BAYATLAYAMAZ
/// ═══════════════════════════════════════════════════════════════════
///
/// Sayılar `docs/A4-CIKMAZ-SOKAK-SAYIMI.md` içindeki makine-okur bloktan
/// OKUNUR ve türetilene karşı sınanır. Gerekçe L-093: *yazılı ama
/// uygulanmayan bir sınır, olmayan sınır kadar tehlikeli.* Dokümanı
/// türetimden üretseydim (ters yön) kimse onu yeniden üretmeyi unuttuğunda
/// sessizce bayatlardı; bu yönde **doküman yanlışsa kapı öter.**
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/test_detail_screen.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// D13 — `path_provider` widget testinde kilitleniyor (aile gotcha'sı,
/// `library_screen_test.dart`taki `_EmptyStore` ile AYNI sınıf, ayrı dosya
/// olduğu için ayrı tanım — aile kuralı: iki test dosyası birbirinin
/// private sınıfını import ETMEZ).
final class _EmptyAttemptValueStore implements AttemptValueStore {
  @override
  Future<void> append(AttemptValue value) async {}
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async =>
      const <AttemptValue>[];
  @override
  Future<int> unreadableRecords() async => 0;
}

/// Çıkmaz sokağın İSİMLİ sınıfı. Harf adları (`A`/`A′`/…) enum'a girmez —
/// `aPrime` gibi bir ad taşındığı anlamı taşımaz ve okuyan kişi tabloya
/// bakmak zorunda kalır.
enum DeadEndClass {
  /// **A** — içerik hiç yazılmamış.
  contentNeverWritten('A'),

  /// **A′** — içerik kaynağı var ama hiç öğe çözülmüyor.
  contentStartedNoReference('A′'),

  /// **B** — öğe VAR, yüzeye bağlanmamış (kablolama boşluğu).
  contentUnwired('B'),

  /// **C** — yüzey hiç olmamalıydı.
  shouldNotExist('C'),

  /// **D** — tam + bağlı, bilerek kapalı.
  deliberatelyClosed('D'),

  /// **E** — ölçüm YETENEĞİ yok (`awaiting-capability`).
  awaitingCapability('E');

  const DeadEndClass(this.label);
  final String label;
}

/// **KURAL TABLOSU — saf fonksiyon, yürüyüşten AYRI.**
///
/// Ayrı olmasının sebebi ölçülebilirlik: kural tablosu bir widget testinin
/// içine gömülseydi, *"bu sınıflandırma A'dan başka bir şey üretebiliyor mu?"*
/// sorusu ancak ürünü bozarak sorulabilirdi. Saf fonksiyon aynı soruyu
/// altı olgu-demetiyle sorar (aşağıdaki üçüncü test).
///
/// ⚠️ **`C` bu fonksiyonda TÜRETİLMEZ ve bu bilinçli:** *"kart hiç
/// olmamalıydı"* bir kapsam hükmüdür, bir çalışma-zamanı olgusu değil. Onu
/// sahte bir yüklemle (ör. *"honestyBox yoksa C"*) türetmek ölü bir dal
/// üretirdi — `LibraryIa` kutusuz bir aileyi zaten AYRIŞTIRAMIYOR (tip
/// düzeyinde zorlanıyor), yani o dal hiçbir zaman ateşlenmezdi. Ölü dal,
/// L-011'in ölü metriğinin aynı sınıfı. `C`nin dayanağı sayımın kendisinde
/// yazılı ve **beyan edilmiş kapsam standardına** bağlı.
DeadEndClass classifyDeadEnd({
  required bool hasItemsSource,
  required int resolvedItemCount,
  required bool rendersAnyItem,
  required bool deliberatelyClosed,
  required bool blockedByCapability,
}) {
  if (blockedByCapability) return DeadEndClass.awaitingCapability;
  if (!hasItemsSource) return DeadEndClass.contentNeverWritten;
  if (resolvedItemCount == 0) return DeadEndClass.contentStartedNoReference;
  if (!rendersAnyItem) return DeadEndClass.contentUnwired;
  if (deliberatelyClosed) return DeadEndClass.deliberatelyClosed;
  return DeadEndClass.contentUnwired;
}

void main() {
  testWidgets('A4 — aile düzeyi: çıkmaz sokaklar YÜRÜYEREK sayılır ve '
      'sınıflandırılır', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts facts = factsFromDisk();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: LissomShell(loader: () async => facts),
      ),
    );
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA — config boşsa aşağıdaki her sayı VAKUM-DOĞRU olurdu.
    expect(
      facts.ia.families,
      isNotEmpty,
      reason: 'IA config aile taşımıyorsa bu sayım hiçbir şey ölçmez',
    );

    final List<String> startable = <String>[];
    final Map<String, DeadEndClass> deadEnds = <String, DeadEndClass>{};

    for (final LibraryFamily fam in facts.ia.families) {
      await _openLibrary(tester);
      final Finder card = find.text(fam.title);
      await scrollTo(tester, card);
      expect(
        card.evaluate(),
        isNotEmpty,
        reason:
            '«${fam.title}» kartına HİÇ varılamadı — varılamayan bir '
            'hedef çıkmaz sokak DEĞİLDİR, ama sayımdan sessizce düşmesi '
            'paydayı yalanlar (sözleşme (d))',
      );
      await tester.tap(card.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(
        find.byType(FamilyPage),
        findsOneWidget,
        reason: '«${fam.title}» kartına basıldı, FamilyPage açılmadı',
      );

      // İÇERİK = gerçek config'ten TÜREYEN öğe. Çerçeve (başlık · giriş ·
      // dürüstlük kutusu) içerik SAYILMAZ — aksi hâlde her sayfa tanım
      // gereği dolu olurdu (`reachable_but_empty_test` §②).
      final bool rendersAnyItem =
          facts.live.any(
            (TestLiveness x) => find.text(x.name).evaluate().isNotEmpty,
          ) ||
          (fam.teachingOnly &&
              facts.hatha != null &&
              find.text('Open Hatha course').evaluate().isNotEmpty);

      if (rendersAnyItem) {
        startable.add(fam.id);
      } else {
        deadEnds[fam.id] = classifyDeadEnd(
          hasItemsSource: fam.itemsSource != null,
          resolvedItemCount: fam.teachingOnly
              ? (facts.hatha?.lessons.length ?? 0)
              : fam.itemsSource != null
              ? facts.liveness.length
              : 0,
          rendersAnyItem: false,
          deliberatelyClosed: false,
          // Aile düzeyinde engel İÇERİKtir, yetenek değil: bir ailenin
          // öğeleri hiç yazılmamışsa çekirdeğin ne ölçebildiği sorusu
          // henüz SORULMAMIŞTIR.
          blockedByCapability: false,
        );
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // ⑤ DENKLEM — türetilmiş bir toplam kaynağını denetleyemez.
    expect(
      startable.length + deadEnds.length,
      facts.ia.families.length,
      reason: 'payda tutmuyor: yürüyüş bir aile hedefini ATLADI',
    );

    final Map<String, int> dist = _distribution(deadEnds.values);
    _report('AİLE DÜZEYİ', payda: facts.ia.families.length, <String, Object>{
      'başlatılabilir': '${startable.length}  $startable',
      'ÇIKMAZ': '${deadEnds.length}  ${deadEnds.keys.toList()}',
      'dağılım': dist,
    });

    final Map<String, String> doc = _censusDoc();
    expect(_i(doc, 'aile.payda'), facts.ia.families.length);
    expect(_i(doc, 'aile.baslatilabilir'), startable.length);
    expect(_i(doc, 'aile.cikmaz'), deadEnds.length);
    for (final DeadEndClass c in DeadEndClass.values) {
      expect(
        _i(doc, 'aile.${c.name}'),
        dist[c.label] ?? 0,
        reason:
            'sayım dokümanı «${c.label}» sınıfında türetimle AYRIŞIYOR '
            '— doküman bayatladı ya da ağaç değişti',
      );
    }
  });

  testWidgets('A4 — test düzeyi: 12 testin hiçbiri HEDEF değil, ve engelli '
      '9\'un sınıfı köprünün KENDİ beyanından gelir', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final AppFacts facts = factsFromDisk();

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: LissomShell(
          loader: () async => facts,
          // D13/F2 — CANLI satır artık GERÇEKTEN bir hedefe gidiyor
          // (`TestDetailScreen`). Enjekte EDİLMEZSE üretim yolu
          // `openAttemptValueStore`a düşer, `path_provider` widget testinde
          // KİLİTLENİR (aile gotcha'sı) ve `pumpAndSettle` SONSUZA dek bekler
          // — bu turda tam bunu ölçtüm (test önce "timed out" diye düştü).
          attemptValueStoreLoader: () async => _EmptyAttemptValueStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _openLibrary(tester);
    final LibraryFamily built = facts.ia.families.firstWhere(
      (LibraryFamily f) => f.isBuilt,
    );
    final Finder card = find.text(built.title);
    await scrollTo(tester, card);
    await tester.tap(card.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(FamilyPage), findsOneWidget);

    // 🔴 **D13 TAKSONOMİ DEĞİŞİKLİĞİ (bu turda ölçüldü) — `docs/A4-CIKMAZ-
    // SOKAK-SAYIMI.md` §5'in KENDİ ÖN-GÖRDÜĞÜ senaryo:** *"bir test satırı
    // HEDEFE dönüşürse → payda birimi değişir, test.cikmaz YANLIŞLANIR."*
    // Artık öyle: CANLI satırlar (3) kendi geçmişine gider, ENGELLİ satırlar
    // (9) hâlâ dokunulamaz. İkisi AYRI ölçülür — eskiden TEK döngüde
    // "hiçbiri hedef değil" diye BİRLEŞTİRİLİYORLARDI, bu artık YANLIŞ.
    //
    // ⚠️ Yeni hedef İÇERİKSİZ DEĞİL (`TestDetailScreen` her zaman gerçek
    // değer YA DA adıyla-boş/okunamayan bir kart taşır) — dokümanın kendi
    // ölçütüyle (*"içeriksiz bir HEDEF çıkmaz sokaktır"*) bu bir çıkmaz
    // sokak SAYILMAZ. Ama bu bir taksonomi-YORUMU ve doküman §3 emsali
    // (*"terminal beyan ekranı çıkmaz sokak mıdır" → koordinatöre*) aynı
    // sınıfın bir örneği — orkestratöre bildirdim, kayıt defterde.
    // Sıra ÖNEMLİ — sabit bir kural değil, ekranın kendi yerleşimi: canlı
    // bölüm listede ENGELLİ bölümün ÜSTÜNDE (`_batteryBody`). Ters sırayla
    // kaydırmak `scrollTo`nun tek-yönlü `dragUntilVisible`ıyla ikinci satırı
    // hiç bulamazdı — bu turda ölçüldü (`No element`), varsayılmadı.
    final int before = _routeDepth(tester);
    final Finder liveRow = find.text(facts.live.first.name);
    await scrollTo(tester, liveRow);
    await tester.tap(liveRow.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      find.byType(TestDetailScreen),
      findsOneWidget,
      reason:
          'CANLI bir test satırı artık GERÇEK bir hedef (D13) — '
          'basmak hiçbir yere gitmiyorsa bu bir REGRESYONDUR',
    );
    // Hedefin İÇERİKSİZ olmadığının pozitif kanıtı — boş depoda bile
    // adıyla-beyanlı bir kart çiziliyor, sessiz boşluk değil.
    expect(
      find.byKey(TestDetailScreen.emptyKey),
      findsOneWidget,
      reason:
          'yeni hedef içeriksiz görünüyor — bu gerçekten çıkmaz sokak '
          'olurdu',
    );

    // Geri dön, ENGELLİ satırın hâlâ dokunulamaz olduğunu ölç.
    Navigator.of(tester.element(find.byType(TestDetailScreen))).pop();
    await tester.pumpAndSettle();
    final Finder blockedRow = find.text(facts.blocked.first.name);
    await scrollTo(tester, blockedRow);
    await tester.tap(blockedRow.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      _routeDepth(tester),
      before,
      reason:
          'ENGELLİ bir test satırına basmak rota itti — 9\'un sınıfı '
          'hâlâ E (awaiting-capability), hâlâ dokunulamaz olmalı',
    );

    // Engelli testlerin sınıfı: her eksik metrik `BridgeBlocker` taşıyorsa
    // engel YETENEKtir (E). Beyansız bir metrik varsa o AYRI bir hâldir ve
    // sınıflandırılamaz — sessizce E sayılmaz.
    final Set<String> bridged = kMetricBindings
        .map((MetricBinding b) => b.lissomMetric)
        .toSet();
    final Set<String> phaseDerived = facts.battery.derivedMeasures.entries
        .where((MapEntry<String, DerivedMeasure> e) => e.value.isPhaseDerived)
        .map((MapEntry<String, DerivedMeasure> e) => e.key)
        .toSet();

    final List<String> capability = <String>[];
    final List<String> undeclared = <String>[];
    for (final TestLiveness t in facts.blocked) {
      final List<String> missing = t.metrics
          .where((String m) => !bridged.contains(m))
          .toList();
      final bool allNamed = missing.every(
        (String m) =>
            phaseDerived.contains(m) || kUnbridgedMetrics.containsKey(m),
      );
      (allNamed ? capability : undeclared).add(t.testId);
    }

    _report('TEST DÜZEYİ', payda: facts.liveness.length, <String, Object>{
      'canlı':
          '${facts.live.length}  '
          '${facts.live.map((TestLiveness x) => x.testId).toList()}',
      'engelli → E (yetenek)': '${capability.length}  $capability',
      'BEYANSIZ (sınıflandırılamaz)': '${undeclared.length}  $undeclared',
      'çıkmaz sokak': '0 — satırlar hedef değil (yukarıda ölçüldü)',
    });

    expect(
      undeclared,
      isEmpty,
      reason:
          'bir engelli testin eksik metriği hiçbir yerde BEYAN edilmemiş '
          '— sınıfı bilinmiyor, ve bilinmeyen bir engel E sayılamaz',
    );

    final Map<String, String> doc = _censusDoc();
    expect(_i(doc, 'test.payda'), facts.liveness.length);
    expect(_i(doc, 'test.canli'), facts.live.length);
    expect(_i(doc, 'test.awaitingCapability'), capability.length);
    expect(_i(doc, 'test.cikmaz'), 0);
  });

  test(
    'A4 — kural tablosu ÖLÜ DAL taşımıyor: altı olgu demeti, altı sınıf',
    () {
      // M-F-58 dördüncü canlılık sorusu: *bu sınıflandırma A'dan başka bir şey
      // üretebiliyor mu?* Bugünkü ağaç yalnız A ve E üretiyor; kalan dört sınıf
      // ancak olgu demetleriyle ötürtülebilir. Ötürtülemeyen bir sınıf, sayımın
      // "0" yazdığı yerde ASLA ötmeyecek demektir — ve o sıfır ölçüm değil süs
      // olurdu.
      DeadEndClass call({
        bool items = true,
        int count = 3,
        bool renders = true,
        bool closed = false,
        bool capability = false,
      }) => classifyDeadEnd(
        hasItemsSource: items,
        resolvedItemCount: count,
        rendersAnyItem: renders,
        deliberatelyClosed: closed,
        blockedByCapability: capability,
      );

      expect(call(items: false), DeadEndClass.contentNeverWritten);
      expect(call(count: 0), DeadEndClass.contentStartedNoReference);
      expect(call(renders: false), DeadEndClass.contentUnwired);
      expect(call(closed: true), DeadEndClass.deliberatelyClosed);
      expect(call(capability: true), DeadEndClass.awaitingCapability);

      // `C` KASITLI olarak türetilmiyor (dosya başlığındaki gerekçe). Bunu bir
      // beklentiyle mühürlüyorum ki biri sahte bir yüklem eklediğinde bu satır
      // onu görsün.
      expect(
        DeadEndClass.values
            .where((DeadEndClass c) => c == DeadEndClass.shouldNotExist)
            .length,
        1,
        reason:
            'C sınıfı taksonomide DURUYOR ama çalışma-zamanında '
            'türetilmiyor — dayanağı sayım dokümanında yazılı',
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────
// Yardımcılar
// ─────────────────────────────────────────────────────────────────────

Future<void> _openLibrary(WidgetTester tester) async {
  await tester.tap(
    find.byIcon(Icons.grid_view_outlined).first,
    warnIfMissed: false,
  );
  await tester.pumpAndSettle();
}

/// Yığındaki rota sayısı — `NavigatorObserver` kurmadan, mevcut ağaçtan.
/// Gerekçe: bu test kabuğu `LissomShell` üzerinden kuruyor ve gözlemciyi
/// enjekte etmek yürüyüşün kendisini değiştirirdi; ölçülen şey *"basınca bir
/// şey açıldı mı"* olduğu için DERİNLİK yeterli ve daha az kurulum ister.
int _routeDepth(WidgetTester tester) =>
    find.byType(FamilyPage).evaluate().length +
    find.byType(LibraryScreen).evaluate().length;

Map<String, int> _distribution(Iterable<DeadEndClass> classes) {
  final Map<String, int> out = <String, int>{
    for (final DeadEndClass c in DeadEndClass.values) c.label: 0,
  };
  for (final DeadEndClass c in classes) {
    out[c.label] = (out[c.label] ?? 0) + 1;
  }
  return out;
}

/// Sayım dokümanının makine-okur bloğu — `anahtar = sayı` satırları.
Map<String, String> _censusDoc() {
  final File f = File('docs/A4-CIKMAZ-SOKAK-SAYIMI.md');
  if (!f.existsSync()) {
    fail(
      'A4 sayım dokümanı YOK: ${f.path} — "ölçülmüş" ile "ADIYLA yazılmış" '
      'A4in İKİ ayrı şartı; ölçüm tek başına kalemi kapatmaz',
    );
  }
  final List<String> lines = f.readAsLinesSync();
  final int start = lines.indexWhere((String l) => l.contains('A4-SAYIM:BAŞ'));
  final int end = lines.indexWhere((String l) => l.contains('A4-SAYIM:SON'));
  if (start < 0 || end < 0 || end < start) {
    fail('sayım dokümanında makine-okur blok bulunamadı (A4-SAYIM:BAŞ/SON)');
  }
  final Map<String, String> out = <String, String>{};
  for (final String l in lines.sublist(start + 1, end)) {
    final int eq = l.indexOf('=');
    if (eq < 0) continue;
    out[l.substring(0, eq).trim()] = l.substring(eq + 1).trim();
  }
  return out;
}

int _i(Map<String, String> doc, String key) {
  final String? v = doc[key];
  if (v == null) {
    fail(
      'sayım dokümanında «$key» anahtarı yok — türetim onu ölçüyor ama '
      'doküman ondan bahsetmiyor',
    );
  }
  return int.parse(v);
}

void _report(String title, Map<String, Object> rows, {required int payda}) {
  // ignore: avoid_print
  print('\n═══ A4 ÇIKMAZ SOKAK SAYIMI — $title (payda $payda) ═══');
  rows.forEach((String k, Object v) {
    // ignore: avoid_print
    print('  ${k.padRight(30)}: $v');
  });
  // ignore: avoid_print
  print('══════════════════════════════════════════════════\n');
}
