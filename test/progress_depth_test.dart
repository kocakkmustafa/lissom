/// **PROGRESS DERİNLİĞİ — bir OTURUM, on iki SATIR (L-324).**
///
/// `appendPreserved()` **test başına** bir `SessionRecord` yazar (kayıt birimi
/// TEST'tir — `assessment_history.dart` §1, ve o karar doğru: bir bloğun
/// testleri sınıf bakımından KARIŞIK). Ama `ProgressScreen` kayıtları **DÜZ**
/// çiziyor: tek oturumda 12 test ölçen kullanıcı, **aynı tarihi taşıyan 12
/// satır** görüyor ve hiçbir şey onların **tek bir oturum** olduğunu
/// söylemiyor.
///
/// > ***KAYIT BİRİMİ İLE GÖSTERİM BİRİMİ AYNI OLMAK ZORUNDA DEĞİLDİR — VE
/// > İKİSİNİ AYNI VARSAYMAK, DOĞRU KAYDEDİLMİŞ BİR ŞEYİ YANLIŞ GÖSTERİR.***
///
/// ⛔ Bu bir **şema** sorunu DEĞİL: `SessionRecord` doğru yazılıyor. Sorun
/// tamamen **sunum** katmanında ⇒ bekleyen çekirdek hükmünden bağımsız,
/// hattın yetkisinde.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// Tek oturumda ölçülmüş bir batarya — **aynı** `completedAt`.
List<SessionRecord> _oneSitting(Battery battery, DateTime at) => <SessionRecord>[
      for (final TestSpec t in battery.tests.values.take(6))
        recordOf(lessonId: t.id, lessonClass: 'scored', at: at),
    ];

/// Çizilmiş OTURUM başlıklarını sayar — anahtar ÖN EKİNDEN.
/// Her başlık kendi zaman damgasıyla anahtarlı (aynı `Key` iki widget'ta
/// olamaz), o yüzden sayım tek bir `byKey` ile yapılamaz.
int _sittingHeaders(WidgetTester tester) => find
    .byWidgetPredicate((Widget w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>)
            .value
            .startsWith(ProgressScreen.sittingKeyPrefix))
    .evaluate()
    .length;

void main() {
  testWidgets('BİR oturumun kayıtları TEK başlık altında toplanır',
      (WidgetTester tester) async {
    pinTallSurface(tester, height: 4000);
    final Battery battery = batteryFromDisk();
    final DateTime at = DateTime.utc(2026, 8, 10, 9, 30);

    final AppFacts f = factsFromDisk(
      history: SessionHistoryView.ok(_oneSitting(battery, at)),
    );

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Scaffold(body: ProgressScreen(facts: f)),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: kayıtlar gerçekten çizildi mi? Çizilmediyse aşağıdaki
    // hükümlerin hepsi VAKUM-DOĞRU olurdu.
    expect(find.byKey(ProgressScreen.ledgerKey), findsOneWidget,
        reason: 'defter hiç çizilmedi — bu test hiçbir şey ölçmez');

    // ⇒ ASIL İDDİA: aynı ana ait 6 kayıt, tarihi **6 kez** tekrarlamamalı.
    // Tekrar eden tarih, kullanıcıya altı ayrı oturum yapmış gibi görünür.
    // 🪤 **İKİ KEZ YANLIŞ SAYDIM, ikisi de sabotajda ortaya çıktı:**
    // ① önce `pumpAndSettle` anındaki `Text`leri sayıyordum — katlama altı
    //    satırlar kurulmamış olabilirdi ⇒ ekledigim kaydırma döngüsü **her
    //    turda aynı satırları yeniden saydı** (6 yerine 78).
    // ② ve aradığım dize YANLIŞTI: yüzey *"10 Aug 2026"* yazıyor, ben
    //    *"10 August 2026"* arıyordum ⇒ sabotaj altında bile **0** buldum.
    // ⇒ Yüzey `pinTallSurface(4000)` ile TEK ekrana sığıyor (ölçüldü: 6
    //    satırın altısı da çiziliyor), o yüzden kaydırma GEREKMİYOR —
    //    gerekmediği **ölçüldü**, varsayılmadı; ve aşağıdaki çapa bunu her
    //    koşumda yeniden doğruluyor.
    // > ***YANLIŞ DİZEYİ ARAYAN BİR TEST, ARADIĞININ YOKLUĞUNU DEĞİL KENDİ
    // > SORUSUNUN YANLIŞLIĞINI ÖLÇER — VE İKİSİ DE YEŞİL GÖRÜNÜR.***
    final int dateHits = tester
        .widgetList<Text>(find.byType(Text))
        .where((Text w) => (w.data ?? '').contains('10 Aug 2026'))
        .length;

    // POZİTİF ÇAPA: satırlar GERÇEKTEN çizildi mi? (kaydırma gerekmediğinin
    // kanıtı da bu — altı satırın adı ekranda.)
    expect(find.text('Overhead Reach').evaluate().length, greaterThan(0),
        reason: 'kayıt satırı çizilmedi — sayım hiçbir şey ölçmez');

    expect(dateHits, lessThan(6),
        reason: 'aynı oturumun her satırı tarihi TEKRARLIYOR ($dateHits '
            'kez) — kullanıcı altı ayrı oturum yapmış gibi görüyor. Kayıt '
            'birimi TEST, gösterim birimi OTURUM olmalı');

    // Ve oturumun kendisi ADIYLA görünmeli: kaç ölçüm içerdiği yazılı.
    expect(_sittingHeaders(tester), 1,
        reason: 'oturum başlığı yok — 6 satırın tek bir oturum olduğunu '
            'söyleyen hiçbir şey yok');
  });

  testWidgets('İKİ ayrı oturum AYRI başlıklar altında',
      (WidgetTester tester) async {
    pinTallSurface(tester, height: 4000);
    final Battery battery = batteryFromDisk();

    final AppFacts f = factsFromDisk(
      history: SessionHistoryView.ok(<SessionRecord>[
        ..._oneSitting(battery, DateTime.utc(2026, 8, 10, 9, 30)),
        ..._oneSitting(battery, DateTime.utc(2026, 8, 3, 18, 5)),
      ]),
    );

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Scaffold(body: ProgressScreen(facts: f)),
    ));
    await tester.pumpAndSettle();

    // İki ayrı gün ⇒ İKİ başlık. Bir tane olsaydı gruplama "hepsini tek
    // yığına at" olurdu ki bu da yanlış birim.
    expect(_sittingHeaders(tester), 2,
        reason: 'iki ayrı oturum tek başlık altında toplanmış ya da hiç '
            'gruplanmamış — ikisi de yanlış birim');
  });
}
