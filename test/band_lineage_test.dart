/// BANT KÖKEN KAPISI (`L-348`, `LIS-P0-001`).
///
/// ## Neden bu dosya var
/// Store listing'in *"the band reflects your own past sessions, not a
/// clinical threshold"* cümlesi bu turda ÖLÇÜLDÜ ve YANLIŞ ÇIKTI:
/// `config/tests/lissom-assessment.v1.json`'daki 12 testin `scoring.source`u
/// hiçbiri kullanıcı geçmişinden söz etmiyor — hepsi yaş-bantlı literatür/
/// kohort (PMC7549223, AAOS/Kendall, Bohannon 2006) ya da beyan edilmiş
/// mühendislik-tahmini. `AssessmentResult.measured()` (`lissom_engine`)
/// `bandLabel`i yalnız statik `bandFloors`e karşı hesaplıyor; geçmiş oturuma
/// hiç bakmıyor. Aynı `description`in birkaç cümle sonrasında *"does not
/// draw a trend line or say a result is better or worse than a past one"*
/// demesi bu yüzden İÇ ÇELİŞKİydi — ikisi aynı anda doğru olamaz.
///
/// Bu kapı İKİ ayrı ekseni korur, ikisi de aynı köke (`scoring.source`)
/// bakıyor ama farklı sınıfta yalan üretiyor:
///
/// ① **İDDİA EKSENİ** — hiçbir kullanıcı-yüzeyi metni bandın kullanıcının
///    kendi geçmişinden geldiğini bir daha SESSİZCE iddia etmesin.
/// ② **TUTARLILIK EKSENİ** — kendi `scoring.source`u "UNVALIDATED" / "must
///    be recalibrated" diyen bir test, `referenceStatus.measurementOnly`
///    ile bastırılmadan kullanıcıya gösterilmesin. `overhead_squat` ve
///    `hamstring_reach` bunu ÖLÇÜLDÜĞÜNDE ihlal ediyordu — kendi kaynağı
///    "recalibrate edilmeden gösterilmemeli" derken gösteriliyorlardı.
///    Bu turda ikisine de `overhead_reach`/`deep_squat` ile AYNI desende
///    `referenceStatus` eklendi; bu kapı o düzeltmeyi ÇİVİLİYOR, gelecekte
///    benzer bir test eklenirse aynı deliği otomatik yakalar.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';
import 'support/listing_json.dart';

/// Bandın kullanıcının kendi geçmiş oturumlarından geldiğini iddia eden
/// kalıplar. Genişçe yazıldı (tek bir cümle değil, sınıf) — L-348'in KENDİSİ
/// başka bir söz dizimiyle geri gelirse de yakalasın.
final RegExp _ownHistoryBandClaim = RegExp(
  r'\b(your own (past|prior|previous) (session|result|score)s?|'
  r'own past sessions?|'
  r'based on your (own )?(history|past)|'
  r'compared (to|with) your (own )?(past|previous|prior))\b',
  caseSensitive: false,
);

/// `scoring.source`taki "bu kaynağa güvenme" BEYANI — yalnız kelimenin
/// KENDİSİ, `UNVALIDATED`. Bu depoda ALL-CAPS bir kelime kasıtlı bir
/// yapısal işarettir (bkz. `SABOTAJ`/`VAKUM`/`POZİTİF ÇAPA` deseni); iki
/// testin kaynağı (`overhead_squat`, `hamstring_reach`) bunu tam bu şekilde,
/// cümlenin BAŞINDA taşıyor.
///
/// 🪤 İlk yazımda desen `must be recalibrated|engineering starting point`i
/// de kapsıyordu ve `active_straight_leg_raise`i de yakaladı — o testin
/// kaynağı GERÇEK bir literatür referansına dayanıyor ("Straight-leg-raise
/// literature puts normal hamstring length at roughly 80-85 deg…") ve
/// kendi metninde "gösterilmeden önce yeniden kalibre edilmeli" gibi bir
/// yasak TAŞIMIYOR — yalnız yöntemini "an engineering starting point"
/// diye tarif ediyor (`lateral_bend`in "extrapolated, not measured"
/// itirafıyla aynı sınıf, `overhead_squat`in "MUST be recalibrated…
/// before any user-facing number is shown" YASAĞIYLA DEĞİL). Bu üçüncü
/// bir gerçek kusur DEĞİLDİ — kapımın kendi aşırı-genişliğiydi (L-338
/// emsali: "yasak-vaat listem kendi cümlemi ısırdı"). Desen daraltıldı;
/// `active_straight_leg_raise` BİLEREK dışarıda bırakıldı, unutulmadı.
final RegExp _selfDeclaredUnvalidated = RegExp(r'\bUNVALIDATED\b');

void main() {
  group('① iddia ekseni — kullanıcı yüzeyi bandı "own history" olarak satmıyor', () {
    test('listing.json kullanıcı metninde own-history iddiası YOK', () {
      final Map<String, dynamic> listing = readListing();
      final List<String> hits = <String>[
        for (final String s in userStrings(listing))
          if (_ownHistoryBandClaim.hasMatch(s)) '"$s"',
      ];
      expect(hits, isEmpty,
          reason: 'BANT KAYNAĞI YANLIŞ İDDİA EDİLİYOR (L-348 emsali): '
              '${hits.join(" · ")}\n\n'
              'config/tests/lissom-assessment.v1.json\'daki 12 testin '
              'scoring.source\'u hiçbiri kullanıcı geçmişinden gelmiyor — '
              'hepsi yaş-bantlı literatür/kohort ya da mühendislik-tahmini. '
              'Bu iddia aynı description\'ın "does not draw a trend line or '
              'say a result is better or worse than a past one" cümlesiyle '
              'de çelişir.');
    });

    test('SABOTAJ — desen gerçekten ateşliyor mu', () {
      const String sabotaged =
          'When a test shows a band, the band reflects your own past '
          'sessions, not a clinical threshold.';
      expect(_ownHistoryBandClaim.hasMatch(sabotaged), isTrue,
          reason: 'BULUCU BOZUK: kaldırılan orijinal cümleyi bile '
              'yakalayamıyor — bu kapının her yeşili vakum-doğru olabilir');
    });
  });

  group('② tutarlılık ekseni — kendi kaynağı "UNVALIDATED" diyen test measurementOnly ile bastırılıyor', () {
    test('battery: her öz-beyanlı-doğrulanmamış test referenceStatus taşıyor', () {
      final Battery battery = batteryFromDisk();
      final List<String> violations = <String>[
        for (final TestSpec t in battery.tests.values)
          if (_selfDeclaredUnvalidated.hasMatch(t.scoring.source) &&
              t.referenceStatus?.isMeasurementOnly != true)
            '${t.id}: scoring.source kendi "UNVALIDATED/must be '
                'recalibrated/engineering starting point" beyanını taşıyor '
                'ama referenceStatus.measurementOnly YOK — kendi kaynağının '
                'yasakladığı bant kullanıcıya gösteriliyor',
      ];
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('POZİTİF ÇAPA — bugün en az bir öz-beyanlı-doğrulanmamış test var', () {
      // Boş kümede geçen bir kapı hiçbir şey kanıtlamaz (L-183 sınıfı).
      final Battery battery = batteryFromDisk();
      final List<TestSpec> selfDeclared = battery.tests.values
          .where((TestSpec t) => _selfDeclaredUnvalidated.hasMatch(t.scoring.source))
          .toList(growable: false);
      expect(selfDeclared.length, equals(2),
          reason: 'beklenen TAM 2 (overhead_squat, hamstring_reach) — sayı '
              'değiştiyse (yeni test eklendi/kaynak metni değişti) adıyla '
              'yeniden ölçülmeli, sessizce büyümemeli/küçülmemeli. '
              '3\'e çıkarsa muhtemelen `active_straight_leg_raise` sınıfı '
              'bir yanlış-pozitif — önce ONU incele (yukarıdaki 🪤 notu).');
      for (final TestSpec t in selfDeclared) {
        expect(t.referenceStatus?.isMeasurementOnly, isTrue,
            reason: '${t.id} öz-beyanlı-doğrulanmamış ama measurementOnly '
                'değil — L-348 düzeltmesi bu test için eksik/bozulmuş');
      }
    });

    test('SABOTAJ — desen gerçekten ateşliyor mu', () {
      const String sabotagedSource =
          'UNVALIDATED — no normative dataset was found. Bands are an '
          'engineering starting point.';
      expect(_selfDeclaredUnvalidated.hasMatch(sabotagedSource), isTrue,
          reason: 'BULUCU BOZUK: overhead_squat/hamstring_reach\'in gerçek '
              'kaynak metnini bile yakalayamıyor');
      const String cleanSource =
          'PMC7549223 (n=2404, age/sex banded active ROM). Bands derived '
          'from cohort means, NOT clinical cutoffs.';
      expect(_selfDeclaredUnvalidated.hasMatch(cleanSource), isFalse,
          reason: 'YANLIŞ POZİTİF: gerçek-kohort kaynaklı bir testi de '
              'öz-beyanlı-doğrulanmamış sınıfına sokuyor');
    });
  });
}
