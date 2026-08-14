/// **LIBRARY DERİNLİĞİ — yapabildiğin testler sana en AZ şeyi söylüyordu (L-328).**
///
/// Cihazda görüldü: `FamilyPage`de **engelli** 9 testin her biri kendi
/// gerekçesini taşıyor (*"Shin angle — the engine reads a limb against the line
/// of your torso…"*), ama **canlı** 3 test yalnız **ad + ikon**.
///
/// Aile tanıtımı ise şunu vaat ediyor:
///   > *"Each one measures a specific area and tells you what it could and
///   > could not see."*
/// ⇒ Vaat, **yapamadığın** testler için tutuluyor; **yapabildiklerin** için hiç.
///
/// > ***DÜRÜSTLÜK MAKİNESİ YALNIZ BAŞARISIZLIKTA ATEŞLENİYORSA, KULLANICI
/// > ÜRÜNÜ EN ÇOK KULLANDIĞI YERDE EN AZ ŞEY ÖĞRENİR.***
///
/// Ve içerik **zaten yazılmış**: `TestSpec.instruction` config'te dolu
/// (*"Stand side-on to the camera…"*), `battery.dart` onu **ayrıştırıyor**, ve
/// `lib/` altında **hiçbir okuyucusu yok** — `L-178`'in sınıfı: *okuyucusu
/// olmayan config alanı.* Uydurmaya gerek yok, göstermeye gerek var.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  testWidgets('CANLI test satırı NE ÖLÇTÜĞÜNÜ söylüyor', (WidgetTester t) async {
    pinTallSurface(t, height: 6000);
    final AppFacts f = factsFromDisk();
    final LibraryFamily built =
        f.ia.families.firstWhere((LibraryFamily x) => x.isBuilt);

    await t.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Scaffold(body: FamilyPage(family: built, facts: f)),
    ));
    await t.pumpAndSettle();

    // POZİTİF ÇAPA: canlı test GERÇEKTEN var mı? Yoksa hüküm vakum-doğru olur.
    expect(f.live, isNotEmpty, reason: 'canlı test yok — bu tur ölçmez');
    final TestSpec spec = f.battery.tests[f.live.first.testId]!;
    expect(spec.instruction, isNotEmpty,
        reason: 'config talimat taşımıyor — gösterilecek içerik yok demektir');

    // ⇒ Talimatın İLK cümlesi yüzeyde görünmeli.
    final String head = spec.instruction.split('.').first;
    expect(find.textContaining(head), findsWidgets,
        reason: 'canlı test yalnız AD gösteriyor; ne ölçtüğü/nasıl yapıldığı '
            'config\'te YAZILI ama hiçbir yüzeyde yok (L-178 sınıfı) — ve '
            'aile tanıtımı bunu VAAT EDİYOR');
  });
}
