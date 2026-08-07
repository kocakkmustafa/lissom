/// **SESSİZLİĞİ DEĞİL DÜRÜSTLÜĞÜ KORUYAN KAPI (L-253)** — JabLab aktarımı.
///
/// > *Bir dürüstlük kapısı, koruduğu cümlenin **SİLİNMESİNİ** de geçerli
/// > sayarsa, dürüstlüğü değil **sessizliği** korur.*
///
/// **Ölçtüm ve delik gerçekti.** İki sabotaj koştum:
///
/// - **Kaba:** whyNot 5→1, notMeasured 4→1 → 4 test yandı. Ama hepsi
///   **tesadüfen**: silinen belirli metinlere (`frontal plane`,
///   `whyNotTopic`, `falsifiedIfBridged`) adıyla dokunan testlerdi.
/// - **Sinsi:** yalnız testlerin ADIYLA anmadığı kalemleri sildim (whyNot
///   5→2, notMeasured 4→2) → **yalnız 1 test yandı.** Yani 3 sınır ve 2
///   limit sessizce kaldırılabiliyordu.
///
/// Kapılarım **içeriği** denetliyordu, **varlığı** değil.
///
/// ## Kural — sayı DEĞİL, KAYNAK→YÜZEY tamlığı
///
/// Bir alt sınır ("en az 4 kalem") koymak L-239'un tuzağı olurdu. Ölçülen
/// kural şu: **hâlâ DOĞRU olan her beyan edilmiş sınır, yüzeyde görünmek
/// zorunda.** Kaynak hâlâ söylüyorsa yüzey de söylemeli.
///
/// Ve ikinci yön, `falsifiedIfBridged`in eksik yarısı (L-251'in tersi):
/// metrik hâlâ köprüsüzken satır SİLİNİRSE, sessizce *"artık bunu
/// ölçüyoruz"* iddia edilmiş olur.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  test('HER ENGEL SINIFI dürüstlük kutusunda ADLANDIRILIR', () {
    // Bu kural bir İÇERİK boşluğu buldu: 7 metrik `coreLacksMeasureKind`
    // sınıfındaydı (mesafe/yükseklik) ve kutu o sınıftan HİÇ bahsetmiyordu.
    // Kullanıcı test-başına gerekçeleri görüyordu ama ailenin ÖZETİ boşluğu
    // atlıyordu — özet, sessiz kalarak eksik anlatıyordu.
    final AppFacts f = factsFromDisk();
    final LibraryFamily battery = f.ia.built
        .singleWhere((LibraryFamily x) => x.id == 'assessment_battery');

    final Set<String> guarded = <String>{
      for (final NotMeasuredLine l in battery.honestyBox.notMeasured)
        ...l.falsifiedIfBridged,
    };

    final Map<BridgeBlocker, List<String>> byClass =
        <BridgeBlocker, List<String>>{};
    kUnbridgedMetrics.forEach((String m, UnbridgedMetric u) {
      byClass.putIfAbsent(u.blocker, () => <String>[]).add(m);
    });
    expect(byClass, isNotEmpty, reason: 'pozitif çapa: engel sınıfları okundu');

    final List<String> unnamed = <String>[];
    for (final MapEntry<BridgeBlocker, List<String>> e in byClass.entries) {
      if (!e.value.any(guarded.contains)) {
        unnamed.add('${e.key.name} (${e.value.length} metrik: '
            '${e.value.take(3).join(", ")}…)');
      }
    }
    expect(unnamed, isEmpty,
        reason: 'Bir engel SINIFI dürüstlük kutusunda hiç adlandırılmamış — '
            'kullanıcı test-başına gerekçeyi görse bile ÖZET onu atlıyor:\n'
            '${unnamed.join("\n")}');
  });

  test('KÖPRÜSÜZ metriğin sınır satırı SİLİNEMEZ (L-251\'in eksik yarısı)', () {
    // L-251: metrik köprüye girerse satır YALAN olur → kırmızı.
    // Buradaki ters yön: metrik hâlâ köprüsüzken satır SİLİNİRSE, sessizce
    // "artık bunu ölçüyoruz" iddia edilmiş olur.
    final AppFacts f = factsFromDisk();
    final Set<String> bridged =
        kMetricBindings.map((MetricBinding b) => b.lissomMetric).toSet();
    final LibraryFamily battery = f.ia.built
        .singleWhere((LibraryFamily x) => x.id == 'assessment_battery');
    final Set<String> guarded = <String>{
      for (final NotMeasuredLine l in battery.honestyBox.notMeasured)
        ...l.falsifiedIfBridged,
    };

    // Beyan edilmiş her koruma, metrik köprüsüz kaldığı sürece DURMALI.
    for (final String m in guarded) {
      expect(bridged.contains(m), isFalse,
          reason: '$m köprüye girmiş ama sınır satırı hâlâ duruyor (L-251)');
    }
    expect(guarded, isNotEmpty,
        reason: 'hiçbir sınır satırı koruma taşımıyor — kutu sessizce '
            'boşaltılabilir');
  });

  testWidgets('KAYNAK→YÜZEY: her ölçülmüş dışlama ekranda GÖRÜNÜR', (
    WidgetTester tester,
  ) async {
    // Kaynak (batarya config'i) hâlâ "bu testi çıkardık" diyorsa, yüzey de
    // demek ZORUNDA. Yüzeyden silmek = sessizleşmek.
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

    expect(f.battery.excluded, isNotEmpty, reason: 'pozitif çapa');
    for (final ExcludedTest e in f.battery.excluded) {
      // Ya kendi satırında ya da bağlı olduğu ürün sınırının altında.
      expect(find.textContaining(e.reason.split('.').first), findsWidgets,
          reason: '${e.id} kaynakta dışlanmış ama YÜZEYDE YOK — sessizce '
              'düşürülmüş');
    }
    for (final PoseTier t in f.ia.poseTiers.where(
        (PoseTier t) => t.reason != null)) {
      expect(find.textContaining(t.reason!.split('(').first.trim()),
          findsWidgets,
          reason: 'tier ${t.tier} gerekçesi yüzeyde yok');
    }
    for (final WhyNotItem w in f.ia.whyNot) {
      expect(find.textContaining(w.topic), findsOneWidget,
          reason: '«${w.topic}» kaynakta var, yüzeyde YOK');
    }
  });

  testWidgets('KAYNAK→YÜZEY: her ENGELLİ testin gerekçesi ekranda GÖRÜNÜR', (
    WidgetTester tester,
  ) async {
    pinTallSurface(tester, height: 6000);
    final AppFacts f = factsFromDisk();
    final LibraryFamily battery = f.ia.built
        .singleWhere((LibraryFamily x) => x.id == 'assessment_battery');
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: FamilyPage(family: battery, facts: f),
    ));
    await tester.pumpAndSettle();

    expect(f.blocked, isNotEmpty, reason: 'pozitif çapa');
    for (final TestLiveness x in f.blocked) {
      expect(find.text(x.name), findsOneWidget,
          reason: '${x.testId} engelli ama adı yüzeyde yok');
      expect(find.text(x.blocker!), findsWidgets,
          reason: '${x.testId} gerekçesi yüzeyde yok — engel İSİMSİZ kaldı');
    }
    // Ve dürüstlük kutusunun HER satırı.
    for (final NotMeasuredLine l in battery.honestyBox.notMeasured) {
      expect(find.text(l.claim), findsOneWidget,
          reason: 'sınır satırı kaynakta var, yüzeyde YOK: «${l.claim}»');
    }
    expect(find.byKey(HonestyBoxCard.notMeasuredKey), findsOneWidget);
  });
}
