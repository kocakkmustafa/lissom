/// IA okuyucusu kapısı — **dürüstlük kutusu tip düzeyinde ZORUNLU.**
///
/// IA config'in kendi notu "Bu kutu opsiyonel değil" diyor. Bir NOT hiçbir
/// şeyi engellemez; bu testler notun uygulanabilir hâlidir: kutusuz ya da
/// yarım kutulu bir aile config'e girerse okuyucu ADIYLA reddeder, yani
/// kutusuz bir aile sayfası hiç ÜRETİLEMEZ.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'package:lissom/app/app_facts.dart';

import 'support/facts_from_disk.dart';

Map<String, dynamic> _raw() =>
    jsonDecode(File('config/ia/library.v1.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('gerçek config okunur ve HER aile kutulu', () {
    final LibraryIa ia = iaFromDisk();
    // Sayı DEĞİL kural (L-239): okuyucu hiçbir aileyi düşürmüyor. "6 aile"
    // yazmak, yedinci aile eklendiğinde ürün DOĞRU büyürken kırmızı yanardı.
    expect(ia.families.length, (_raw()['families'] as List<dynamic>).length);
    expect(ia.families, isNotEmpty, reason: 'pozitif çapa');
    for (final LibraryFamily f in ia.families) {
      if (f.teachingOnly) {
        expect(
          f.honestyBox.measured,
          isEmpty,
          reason: '${f.id}: rehberli kurs ölçüm iddiası kurmamalı',
        );
        expect(f.itemsSource, isNotNull);
      } else {
        expect(f.honestyBox.measured, isNotEmpty, reason: f.id);
      }
      expect(f.honestyBox.notMeasured, isNotEmpty, reason: f.id);
    }
  });

  group('L-230 — dürüstlük kutusu KENDİNİ doğrular', () {
    test('inşa edilmiş ailenin HER iddiası dayanak taşır', () {
      final LibraryFamily b = iaFromDisk().built.singleWhere(
        (LibraryFamily f) => f.id == 'assessment_battery',
      );
      expect(b.honestyBox.measured, isNotEmpty, reason: 'pozitif kontrol');
      for (final HonestyClaim c in b.honestyBox.measured) {
        expect(
          c.requires,
          isNotEmpty,
          reason: 'dayanaksız iddia: «${c.claim}»',
        );
      }
    });

    test('DAYANAKSIZ iddia inşa edilmiş ailede REDDEDİLİR', () {
      final Map<String, dynamic> raw = _raw();
      final Map<String, dynamic> fam =
          (raw['families'] as List<dynamic>)[0] as Map<String, dynamic>;
      // Düz metne geri dönmek = kanıtı düşürmek.
      (fam['honestyBox'] as Map<String, dynamic>)['measured'] = <String>[
        'We measure everything',
      ];
      expect(
        () => LibraryIa.parseJson(jsonEncode(raw)),
        throwsA(isA<IaError>()),
      );
    });

    test('her `requires` jetonu GERÇEK bir metrik/büyüklük olmalı', () {
      // Yazım hatası bir jetonu sessizce "canlı değil" yapardı ve iddia
      // gerekçesiz sönerdi — sahte bir alçakgönüllülük.
      final Battery b = batteryFromDisk();
      final Set<String> known = <String>{
        ...kMetricBindings.map((MetricBinding x) => x.lissomMetric),
        ...kUnbridgedMetrics.keys,
        ...b.derivedMeasures.keys,
      };
      for (final LibraryFamily f in iaFromDisk().families) {
        for (final HonestyClaim c in f.honestyBox.measured) {
          for (final String tok in c.requires) {
            expect(
              known,
              contains(tok),
              reason: '${f.id}: «$tok» hiçbir metrik/büyüklük değil',
            );
          }
        }
      }
    });

    test('İDDİA ↔ YETENEK: canlı olmayan iddialar İSİMLİ (bugün 2/4)', () {
      final AppFacts f = factsFromDisk();
      final LibraryFamily b = f.ia.built.singleWhere(
        (LibraryFamily x) => x.id == 'assessment_battery',
      );
      final List<HonestyClaim> dead = b.honestyBox.measured
          .where((HonestyClaim c) => f.blockerForClaim(c) != null)
          .toList();
      final List<HonestyClaim> live = b.honestyBox.measured
          .where((HonestyClaim c) => f.blockerForClaim(c) == null)
          .toList();

      // ⚠️ **SAYI DEĞİL KURAL (L-239).** Eski hâli `live hasLength(2)` ·
      // `dead hasLength(2)` diyordu; `trunk_lean` köprüye girdiği an ikisi de
      // kırmızı yanardı — ürün İLERLEDİĞİ için. Ölçülen artık DENKLİK: bir
      // iddia canlıdır ⟺ dayandığı metriklerin hepsi köprüde.
      final Set<String> bridged = kMetricBindings
          .map((MetricBinding b) => b.lissomMetric)
          .toSet();
      for (final HonestyClaim c in b.honestyBox.measured) {
        final bool shouldBeLive = c.requires.every(bridged.contains);
        expect(
          f.blockerForClaim(c) == null,
          shouldBeLive,
          reason: '«${c.claim}» canlılığı köprüyle uyuşmuyor',
        );
      }
      // Pozitif çapa: kural boş kümede de doğru. En az bir iddia olmalı, ve
      // sönük olan varsa gerekçesi İSİMLİ olmalı.
      expect(b.honestyBox.measured, isNotEmpty);
      for (final HonestyClaim c in dead) {
        expect(
          f.blockerForClaim(c)!.trim(),
          isNotEmpty,
          reason: 'gerekçesiz sönük iddia = sahte alçakgönüllülük',
        );
      }
      // Bugün ikisi de dolu; köprü tamamlanınca `dead` boşalır ve bu satır
      // ZAFERLE silinir — ama o güne kadar türetimin iki yönü de sınanıyor.
      expect(live.isNotEmpty || dead.isNotEmpty, isTrue);
    });

    test('L-233 — CANLI iddia HÜKÜM SINIRINI cümlenin içinde taşır', () {
      final AppFacts f = factsFromDisk();
      final LibraryFamily b = f.ia.built.singleWhere(
        (LibraryFamily x) => x.id == 'assessment_battery',
      );
      final List<HonestyClaim> live = b.honestyBox.measured
          .where((HonestyClaim c) => f.blockerForClaim(c) == null)
          .toList();
      expect(live, isNotEmpty, reason: 'pozitif kontrol');

      for (final HonestyClaim c in live) {
        final String? note = f.verdictNoteFor(c);
        expect(
          note,
          isNotNull,
          reason:
              'canlı iddia sınırsız kaldı: «${c.claim}» — J-113 sınıfı '
              '(bir yeteneği olduğundan GENİŞ yazmak)',
        );
        // Ölçüldü: omuz+diz `measurementOnly`, kalça bantlı → KARIŞIK sınıf.
        // Bunu tek bir "ölçüyoruz" cümlesine sıkıştırmak, kullanıcının
        // ALEYHİNE bir fazla-iddiadır.
        // ⚠️ SAYI DEĞİL KURAL (L-239): "karışık sınıf" bugünün hâli. Köprü
        // büyüyünce iddia tamamen bantlı ya da tamamen referanssız olabilir —
        // o zaman "carries no verdict" beklemek ürün ilerlerken kırmızı
        // yanardı. Ölçülen: not, iddianın GERÇEK sınıf dağılımını anlatmalı.
        final bool mixed = note!.contains('Of the');
        final bool allBanded = note.contains('age-banded reference range.');
        final bool noneBanded = note.contains('not a verdict');
        expect(
          mixed || allBanded || noneBanded,
          isTrue,
          reason: 'hüküm notu üç sınıftan hiçbirini anlatmıyor: «$note»',
        );
      }

      // ⛔ Ölü iddiaya hüküm notu ASILMAZ — ölçülmeyen şeyin hükmü de yoktur.
      for (final HonestyClaim c in b.honestyBox.measured.where(
        (HonestyClaim c) => f.blockerForClaim(c) != null,
      )) {
        expect(f.verdictNoteFor(c), isNull);
      }
    });

    test('hüküm notu TÜRETİLİR — terfi olsa cümle kendiliğinden değişir', () {
      // Karşıt yön: yalnız-bantlı bir metrik kümesi "no verdict" DEMEMELİ.
      // Tek yön sınanırsa, her zaman aynı cümleyi basan bir kod da geçerdi.
      final AppFacts f = factsFromDisk();
      const HonestyClaim onlyBanded = HonestyClaim(
        claim: 'x',
        requires: <String>['hip_flexion_right'],
      );
      final String? note = f.verdictNoteFor(onlyBanded);
      expect(note, 'Compared against an age-banded reference range.');
      expect(note, isNot(contains('no verdict')));
    });

    test(
      '"frontal plane" iddiası ARTIK YOK — hiçbir metrik için doğru değildi',
      () {
        final LibraryFamily b = iaFromDisk().built.singleWhere(
          (LibraryFamily f) => f.id == 'assessment_battery',
        );
        for (final HonestyClaim c in b.honestyBox.measured) {
          expect(
            c.claim.toLowerCase(),
            isNot(contains('frontal plane')),
            reason: 'köprü uzayı isotropic; düzlem ayrımı çekirdekte YOK',
          );
        }
        // ...ve yokluğu bir SESSİZLİK değil: notMeasured tarafında İSİMLİ.
        expect(
          b.honestyBox.notMeasured
              .map((NotMeasuredLine l) => l.claim)
              .join(' ')
              .toLowerCase(),
          contains('frontal plane'),
        );
      },
    );
  });

  test('KUTUSUZ aile REDDEDİLİR', () {
    final Map<String, dynamic> raw = _raw();
    (raw['families'] as List<dynamic>)[0] = <String, dynamic>{
      'id': 'x',
      'title': 'X',
      'status': 'coming_soon',
      'intro': 'y',
    };
    expect(() => LibraryIa.parseJson(jsonEncode(raw)), throwsA(isA<IaError>()));
  });

  test('BOŞ notMeasured REDDEDİLİR — kutu pazarlama kutusuna dönemez', () {
    final Map<String, dynamic> raw = _raw();
    final Map<String, dynamic> fam =
        (raw['families'] as List<dynamic>)[0] as Map<String, dynamic>;
    (fam['honestyBox'] as Map<String, dynamic>)['notMeasured'] = <String>[];
    expect(() => LibraryIa.parseJson(jsonEncode(raw)), throwsA(isA<IaError>()));
  });

  test('BİLİNMEYEN status sessizce yutulmaz', () {
    final Map<String, dynamic> raw = _raw();
    final Map<String, dynamic> fam =
        (raw['families'] as List<dynamic>)[0] as Map<String, dynamic>;
    fam['status'] = 'almost_there';
    expect(() => LibraryIa.parseJson(jsonEncode(raw)), throwsA(isA<IaError>()));
  });

  test('SÜRÜMSÜZ config REDDEDİLİR', () {
    final Map<String, dynamic> raw = _raw()..remove('version');
    expect(() => LibraryIa.parseJson(jsonEncode(raw)), throwsA(isA<IaError>()));
  });

  test('`coming_soon` DİZESİ kod tarafında hiçbir metne dönüşmez', () {
    // Config'in makine değeri `coming_soon`; enum adı BİLEREK `notBuilt`.
    // `FamilyStatus.comingSoon` diye bir sembol olsaydı, bir gün bir
    // `Text('${status.name}')` içine düşerdi (M-F-186 vaat dili).
    expect(
      FamilyStatus.values.map((FamilyStatus s) => s.name).toList(),
      isNot(contains('comingSoon')),
    );
    final LibraryIa ia = iaFromDisk();
    for (final LibraryFamily f in ia.notBuilt) {
      expect(f.inventoryLine.toLowerCase(), isNot(contains('soon')));
      expect(f.inventoryLine.toLowerCase(), isNot(contains('coming')));
    }
  });

  group('batarya `excluded` bloğu — L-219, okuyucusu YOKTU', () {
    test('iki dışlama da gerekçesiyle okunur', () {
      final Battery b = batteryFromDisk();
      // Sayı DEĞİL kural: okuyucu hiçbir dışlamayı düşürmüyor (L-239).
      final Map<String, dynamic> rawB =
          jsonDecode(
                File(
                  'config/tests/lissom-assessment.v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(b.excluded.length, (rawB['excluded'] as List<dynamic>).length);
      expect(b.excluded, isNotEmpty, reason: 'pozitif çapa');
      for (final ExcludedTest e in b.excluded) {
        expect(e.reason.trim(), isNotEmpty);
      }
      expect(
        b.excluded.map((ExcludedTest e) => e.id).toList(),
        contains('cervical_rotation'),
      );
    });

    test('GEREKÇESİZ dışlama REDDEDİLİR', () {
      final Map<String, dynamic> raw =
          jsonDecode(
                File(
                  'config/tests/lissom-assessment.v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      (raw['excluded'] as List<dynamic>)[0] = <String, dynamic>{'id': 'z'};
      expect(
        () => Battery.parseJson(jsonEncode(raw)),
        throwsA(isA<BatteryError>()),
      );
    });

    test('`whyNotTopic` BEYAN edilir, metin benzerliğinden tahmin EDİLMEZ', () {
      final Battery b = batteryFromDisk();
      final ExcludedTest hip = b.excluded.singleWhere(
        (ExcludedTest e) => e.id == 'hip_internal_external_rotation',
      );
      expect(hip.whyNotTopic, isNotNull);
      // Beyan edilen başlık GERÇEKTEN whyNot listesinde olmalı — aksi hâlde
      // birleştirme sessizce hiç olmaz ve kimse fark etmez.
      final LibraryIa ia = iaFromDisk();
      expect(
        ia.whyNot.map((WhyNotItem w) => w.topic).toList(),
        contains(hip.whyNotTopic),
      );

      // Bağlanmamış olan (cervical_rotation) KENDİ satırını almalı.
      final ExcludedTest neck = b.excluded.singleWhere(
        (ExcludedTest e) => e.id == 'cervical_rotation',
      );
      expect(neck.whyNotTopic, isNull);
    });
  });
}
