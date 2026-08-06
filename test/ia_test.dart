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

import 'support/facts_from_disk.dart';

Map<String, dynamic> _raw() => jsonDecode(
        File('config/ia/library.v1.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  test('gerçek config okunur ve altı aile de kutulu', () {
    final LibraryIa ia = iaFromDisk();
    expect(ia.families, hasLength(6));
    for (final LibraryFamily f in ia.families) {
      expect(f.honestyBox.measured, isNotEmpty, reason: f.id);
      expect(f.honestyBox.notMeasured, isNotEmpty, reason: f.id);
    }
  });

  test('KUTUSUZ aile REDDEDİLİR', () {
    final Map<String, dynamic> raw = _raw();
    (raw['families'] as List<dynamic>)[0] = <String, dynamic>{
      'id': 'x',
      'title': 'X',
      'status': 'coming_soon',
      'intro': 'y',
    };
    expect(() => LibraryIa.parseJson(jsonEncode(raw)),
        throwsA(isA<IaError>()));
  });

  test('BOŞ notMeasured REDDEDİLİR — kutu pazarlama kutusuna dönemez', () {
    final Map<String, dynamic> raw = _raw();
    final Map<String, dynamic> fam =
        (raw['families'] as List<dynamic>)[0] as Map<String, dynamic>;
    (fam['honestyBox'] as Map<String, dynamic>)['notMeasured'] = <String>[];
    expect(() => LibraryIa.parseJson(jsonEncode(raw)),
        throwsA(isA<IaError>()));
  });

  test('BİLİNMEYEN status sessizce yutulmaz', () {
    final Map<String, dynamic> raw = _raw();
    final Map<String, dynamic> fam =
        (raw['families'] as List<dynamic>)[0] as Map<String, dynamic>;
    fam['status'] = 'almost_there';
    expect(() => LibraryIa.parseJson(jsonEncode(raw)),
        throwsA(isA<IaError>()));
  });

  test('SÜRÜMSÜZ config REDDEDİLİR', () {
    final Map<String, dynamic> raw = _raw()..remove('version');
    expect(() => LibraryIa.parseJson(jsonEncode(raw)),
        throwsA(isA<IaError>()));
  });

  test('`coming_soon` DİZESİ kod tarafında hiçbir metne dönüşmez', () {
    // Config'in makine değeri `coming_soon`; enum adı BİLEREK `notBuilt`.
    // `FamilyStatus.comingSoon` diye bir sembol olsaydı, bir gün bir
    // `Text('${status.name}')` içine düşerdi (M-F-186 vaat dili).
    expect(FamilyStatus.values.map((FamilyStatus s) => s.name).toList(),
        isNot(contains('comingSoon')));
    final LibraryIa ia = iaFromDisk();
    for (final LibraryFamily f in ia.notBuilt) {
      expect(f.inventoryLine.toLowerCase(), isNot(contains('soon')));
      expect(f.inventoryLine.toLowerCase(), isNot(contains('coming')));
    }
  });

  group('batarya `excluded` bloğu — L-219, okuyucusu YOKTU', () {
    test('iki dışlama da gerekçesiyle okunur', () {
      final Battery b = batteryFromDisk();
      expect(b.excluded, hasLength(2));
      for (final ExcludedTest e in b.excluded) {
        expect(e.reason.trim(), isNotEmpty);
      }
      expect(b.excluded.map((ExcludedTest e) => e.id).toList(),
          contains('cervical_rotation'));
    });

    test('GEREKÇESİZ dışlama REDDEDİLİR', () {
      final Map<String, dynamic> raw = jsonDecode(
              File('config/tests/lissom-assessment.v1.json').readAsStringSync())
          as Map<String, dynamic>;
      (raw['excluded'] as List<dynamic>)[0] = <String, dynamic>{'id': 'z'};
      expect(() => Battery.parseJson(jsonEncode(raw)),
          throwsA(isA<BatteryError>()));
    });

    test('`whyNotTopic` BEYAN edilir, metin benzerliğinden tahmin EDİLMEZ', () {
      final Battery b = batteryFromDisk();
      final ExcludedTest hip = b.excluded
          .singleWhere((ExcludedTest e) => e.id == 'hip_internal_external_rotation');
      expect(hip.whyNotTopic, isNotNull);
      // Beyan edilen başlık GERÇEKTEN whyNot listesinde olmalı — aksi hâlde
      // birleştirme sessizce hiç olmaz ve kimse fark etmez.
      final LibraryIa ia = iaFromDisk();
      expect(ia.whyNot.map((WhyNotItem w) => w.topic).toList(),
          contains(hip.whyNotTopic));

      // Bağlanmamış olan (cervical_rotation) KENDİ satırını almalı.
      final ExcludedTest neck = b.excluded
          .singleWhere((ExcludedTest e) => e.id == 'cervical_rotation');
      expect(neck.whyNotTopic, isNull);
    });
  });
}
