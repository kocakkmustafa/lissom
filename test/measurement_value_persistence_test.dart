/// **ÖLÇÜLEN DEĞER KALICI DEĞİL — ve yüzey bunu SÖYLEMİYOR (L-316).**
///
/// ═══════════════════════════════════════════════════════════════════
/// ## BULGU — iddia değil, bu dosyanın ÖLÇTÜĞÜ şey
/// ═══════════════════════════════════════════════════════════════════
///
/// Lissom bir eklem açısını ölçer, sonucu **bir kez** gösterir, ve
/// **saklamaz.** `AssessmentResult` şunları taşır:
///
///     value · unit · bandLabel · provenance
///
/// `recordFor()` (`assessment_history.dart`) onu çekirdeğin `SessionRecord`una
/// çevirir ve **dördünün de karşılığı yoktur** — çevrilmez, DÜŞER.
///
/// Bu bir kusur RAPORU değil, çekirdeğin **kasıtlı** kararı; gerekçesi kendi
/// başlığında yazılı (`session_store.dart`):
///
///   > *"there is deliberately NO verdict/score field — recording zeros
///   > before the camera bridge would draw zeros on tomorrow's progress
///   > chart."*
///
/// ⚠️ **VE O GEREKÇENİN ÖN KOŞULU ARTIK GEÇERSİZ.** Cümle *"kamera köprüsü
/// YOKKEN"* diyor. Lissom'da kamera köprüsü **VAR** (A1 kapandı, L-309): ölçüm
/// uçtan uca koşuyor, gerçek bir açı üretiyor ve depoya yazıyor. Yani sıfır
/// yazma riski geçti; geriye yalnız **kaybın kendisi** kaldı.
/// > ***BİR KARARIN GEREKÇESİ BİR ÖN KOŞULA DAYANIYORSA, O ÖN KOŞUL
/// > DEĞİŞTİĞİNDE KARAR SESSİZCE GEREKÇESİZ KALIR — ve kimse fark etmez,
/// > çünkü karar hâlâ orada durur.***
///
/// ⛔ Çözüm bu turda YAPILMADI ve yapılamaz: `SessionRecord` **çekirdek**
/// şemasıdır (`motion_core`, pin `f13bdc9`) ve beş Motion app'ini birden
/// bağlar. Tek taraflı değiştirmek aile kuralını çiğnerdi (H-4②'nin emsali).
/// Bu dosya **kaybı ÖLÇER ve yüzeyin ne vaat ettiğini denetler.**
///
/// ═══════════════════════════════════════════════════════════════════
/// ## NEDEN A3 KAPISI BUNU YAKALAYAMADI — ayrı bir kusur SINIFI
/// ═══════════════════════════════════════════════════════════════════
///
/// Bu gece kurduğum A3 detektörleri (`a3_silent_surface_test.dart`) **yapısal
/// olarak BOŞ** bölümleri bulur: başlık var, gövde yok. Buradaki kusur başka
/// bir sınıf: bölüm **DOLU**, ama *"under what conditions"* diyen bir başlığın
/// altında koşullar HİÇ YOK.
/// > ***BİR BAŞLIK, ALTI BOŞ OLDUĞUNDA DEĞİL, ALTI YANLIŞ ŞEYLE DOLU
/// > OLDUĞUNDA DA YALAN SÖYLER — ve ikincisini hiçbir boşluk detektörü
/// > göremez, çünkü ölçtüğü şey VARLIK, KARŞILIK değil.***
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/assessment_history.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  test('ÖLÇÜM: `recordFor` değeri·birimi·bandı·kaynağı DÜŞÜRÜR', () {
    final Battery battery = batteryFromDisk();
    final TestSpec test = battery.tests['overhead_reach']!;

    // GERÇEK ölçüm sonucu — motorun kendi kurucusundan, elle kurulmuş bir
    // sahte değil. `AssessmentResult.measured` bandları da sınıflandırıyor.
    final AssessmentResult result = AssessmentResult.measured(
      testId: test.id,
      side: 'right',
      value: 147.5,
      unit: 'deg',
      provenance: const <String, String>{
        'model': 'pose_landmarker_full',
        'batteryVersion': 'v1',
      },
      bandFloors: const <String, double>{'u40': 150},
      attemptMicros: 2400000,
    );

    // POZİTİF ÇAPA: sonuç GERÇEKTEN değer taşıyor mu? Taşımasaydı aşağıdaki
    // "düşüyor" hükmü VAKUM-DOĞRU olurdu — kaybı değil yokluğu ölçerdim.
    expect(result.value, 147.5, reason: 'sonuçta değer yoksa kayıp ölçülemez');
    expect(result.unit, 'deg');
    expect(result.provenance, isNotEmpty);

    final SessionRecord record = recordFor(
      test: test,
      result: result,
      completedAt: DateTime.utc(2026, 8, 14, 10),
    );

    // ⇒ KAYIP: kaydın JSON'unda değerin HİÇBİR izi yok. Alan adı değil,
    // **147.5 sayısının kendisi** aranıyor — bir alan adı değişse bile
    // kayıp/kalıcılık gerçeği değişmez.
    final String json = record.toJson().toString();
    expect(json.contains('147'), isFalse,
        reason: 'ölçülen değer kayda girmiş görünüyor — bu testin dayandığı '
            'kayıp artık geçerli değil, BULGU YENİDEN ÖLÇÜLMELİ');
    expect(json.contains('deg'), isFalse, reason: 'birim de düşmeliydi');
    expect(json.contains('pose_landmarker'), isFalse,
        reason: 'kaynak (provenance) da düşmeliydi');

    // Kaydın TAŞIDIĞI şey: hangi test, ne zaman, hangi sınıf, ne kadar süre.
    // Yani *"ölçtün"* — *"ne ölçtün"* DEĞİL.
    expect(record.lessonId, 'overhead_reach:right');
    expect(record.lessonClass, 'coached'); // 147.5 < 150 taban
    expect(record.unitsCompleted, 1);
  });

  testWidgets('YÜZEY: "Your record" ekranı ölçülen SAYIYI gösteremez',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);

    // Kullanıcı gerçekten ölçtü: 147,5° — ve kayıt depoya böyle girdi.
    final Battery battery = batteryFromDisk();
    final SessionRecord stored = recordFor(
      test: battery.tests['overhead_reach']!,
      result: AssessmentResult.measured(
        testId: 'overhead_reach',
        side: 'right',
        value: 147.5,
        unit: 'deg',
        provenance: const <String, String>{'model': 'pose_landmarker_full'},
        bandFloors: const <String, double>{'u40': 150},
        attemptMicros: 2400000,
      ),
      completedAt: DateTime.utc(2026, 8, 14, 10),
    );

    final AppFacts f = factsFromDisk(
      history: SessionHistoryView.ok(<SessionRecord>[stored]),
    );

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Scaffold(body: ProgressScreen(facts: f)),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: kayıt gerçekten çizildi mi? Çizilmediyse "sayı yok"
    // hükmü ekranın boş olmasından gelirdi, kayıptan değil.
    //
    // 🪤 Ve KAYDIRMA şart: bu turda eklediğim "reading is not kept" kartı
    // satırı katlamanın ALTINA itti. `ListView` çocukları tembel kurar —
    // kaydırmayan bir arama satırı bulamaz ve **çapa yanlış sebeple** kırmızı
    // yanar. (Aynı kaza L-297'de ölçülmüştü; kartı ekleyen tur onu geri
    // getirdi — *bir yüzeye içerik eklemek, o yüzeydeki her arama testinin
    // erişim varsayımını değiştirir.*)
    final Finder row = find.text('Overhead Reach · right');
    await scrollTo(tester, row);
    expect(row, findsOneWidget,
        reason: 'kayıt satırı çizilmedi — aşağıdaki hüküm VAKUM-DOĞRU olurdu');

    // ⇒ Ekranda 147 diye bir şey YOK, ve olamaz: veri depoda hiç değil.
    expect(
      find.textContaining('147'),
      findsNothing,
      reason: 'değer ekranda görünüyorsa depolanıyor demektir — bu testin '
          'dayandığı kayıp geçersiz, bulgu yeniden ölçülmeli',
    );
  });

  testWidgets('YÜZEY: kaybın kendisi kullanıcıya SÖYLENİYOR',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts f = factsFromDisk();

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: Scaffold(body: ProgressScreen(facts: f)),
    ));
    await tester.pumpAndSettle();

    // ⭐ A3'ün ikinci kolu: *"ya iş sunar ya NEDEN sunmadığını söyler."*
    // Ölçülen sayı saklanmıyorsa, bunu kullanıcıya söylemek zorundayız —
    // sessizce kaybetmek, ölçtüğünü sandığı şeyi yok saymaktır.
    expect(find.byKey(ProgressScreen.readingNotKeptKey), findsOneWidget,
        reason: 'ölçülen değerin saklanmadığı kullanıcıya SÖYLENMİYOR');
  });
}
