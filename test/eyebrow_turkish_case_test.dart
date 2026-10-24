import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';

void main() {
  test('Turkish eyebrow capitals keep the dotted İ (LIS-01 smoke)', () {
    expect(
      lissomUpperCase('Senin hakkında', const Locale('tr')),
      'SENİN HAKKINDA',
    );
    expect(
      lissomUpperCase('Ölçümün gösterebildikleri', const Locale('tr')),
      'ÖLÇÜMÜN GÖSTEREBİLDİKLERİ',
    );
    expect(
      lissomUpperCase('5 adımın 1. adımı', const Locale('tr')),
      '5 ADIMIN 1. ADIMI',
    );
  });

  test('other locales keep the default capitals', () {
    expect(lissomUpperCase('limits', const Locale('en')), 'LIMITS');
    expect(lissomUpperCase('limites', const Locale('fr')), 'LIMITES');
    expect(lissomUpperCase('limits', null), 'LIMITS');
  });
}
