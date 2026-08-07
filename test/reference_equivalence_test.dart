/// **HÜKÜM L-187'nin ŞARTI, ÇİVİLENMİŞ (L-254).**
///
/// Koordinatörün hükmü göçü onayladı — **ama bir şartla, ve şart hükmün
/// ayrılmaz parçası:**
///
/// > `kBridgeIsReferenceEquivalent` **ÖLÇÜMLE** `true` olur, **göç yapıldı
/// > diye değil.** Göç sonrası sapma yeniden ölçülür; hedefe düşmezse bayrak
/// > `false` KALIR ve göç yine de değerlidir (4 metrik açılır) ama **iddia
/// > derecesi değişmez.** Aksi hâlde *"göç yaptık, artık referans-eşdeğeriz"*
/// > denir ve bu **eşik icadıdır.**
///
/// Şartı bugün çiviliyorum, çünkü **göçü yapan oturum bu şartı okumayabilir**
/// — ve bayrağı `true` yapmak tek satırlık bir iş. Bu kapı o tek satırı
/// **ölçüm olmadan imkânsız** kılıyor.
///
/// ## Kapı ne YAPMIYOR — isimle
///
/// *"11,29° iyi mi, 3° iyi mi"* sorusuna **CEVAP VERMİYOR** ve veremez: o bir
/// eşik ve eşik icadı yasak. Kapının zorladığı şey, ölçümü yapanın **kendi
/// kabul ölçütünü artefaktta BEYAN etmesi** ve ölçülen sayının o ölçütü
/// gerçekten geçmesi. Ölçüt bu dosyada değil, ölçümün yanında yaşar —
/// gerekçesiyle birlikte.
///
/// Bugün bayrak `false` ve artefakt (`docs/L-031-UZAY-SAPMASI-OLCUMU.md`)
/// **medyan 11,29° · p95 37,47°** diyor; iddia derecesi de ona göre.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom_engine/lissom_engine.dart';

/// Ölçüm artefaktının taşıması ZORUNLU alanları — bayrak `true` olacaksa.
final List<(String, RegExp)> _required = <(String, RegExp)>[
  (
    'ölçülen medyan sapma',
    // "medyan ... 3,4°" gibi bir SAYI taşımalı; söz değil rakam.
    // (Türkçe ondalık virgül de kabul.)
  RegExp(r'medyan[^\n]*?\d+[,.]\d+\s*°', caseSensitive: false),
  ),
  (
    'ölçülen p95 sapma',
    RegExp(r'p95[^\n]*?\d+[,.]\d+\s*°', caseSensitive: false),
  ),
  (
    'KABUL ÖLÇÜTÜ — ölçümü yapanın beyanı, gerekçesiyle',
    RegExp(r'kabul ölçütü', caseSensitive: false),
  ),
  (
    'ölçümün KOŞTUĞU çıktı/komut (yeniden üretilebilirlik)',
    RegExp(r'l031_space_divergence|two_mode_report', caseSensitive: false),
  ),
];

File get _artifact => File('docs/L-031-UZAY-SAPMASI-OLCUMU.md');

void main() {
  test('BAYRAK ancak ÖLÇÜMLE `true` olur — göç yapıldı diye değil', () {
    // Pozitif çapa: artefakt gerçekten okunuyor mu? Yoksa aşağıdaki iddialar
    // boş dosyada trivially geçerdi (L-183).
    expect(_artifact.existsSync(), isTrue,
        reason: 'L-031 ölçüm artefaktı yok — bu kapı hiçbir şey ölçmüyor');
    final String doc = _artifact.readAsStringSync();
    expect(doc.length, greaterThan(500), reason: 'artefakt boş okundu');

    if (!kBridgeIsReferenceEquivalent) {
      // BUGÜNKÜ HÂL. Karşıt yön de sınanıyor: bayrak `false` iken artefakt
      // hâlâ bir sapma ÖLÇÜMÜ taşımalı — çünkü `false` da bir iddiadır ve
      // gerekçesiz bir "eşdeğer değiliz" ihtiyat beyanına dönerdi.
      expect(RegExp(r'\d+[,.]\d+\s*°').hasMatch(doc), isTrue,
          reason: '`false` da ÖLÇÜLMÜŞ bir olgu olmalı, ihtiyat beyanı değil');
      return;
    }

    // BAYRAK `true` YAPILMIŞ. Şart devrede.
    final List<String> missing = <String>[];
    for (final (String what, RegExp p) in _required) {
      if (!p.hasMatch(doc)) missing.add(what);
    }
    expect(missing, isEmpty,
        reason: '`kBridgeIsReferenceEquivalent` `true` yapılmış ama ölçüm '
            'artefaktı şunları TAŞIMIYOR:\n  - ${missing.join("\n  - ")}\n\n'
            'HÜKÜM L-187\'nin şartı: bayrak ÖLÇÜMLE true olur, göç yapıldı '
            'diye değil. Ölçüm yoksa bu bir EŞİK İCADIDIR — "göç yaptık, '
            'artık referans-eşdeğeriz" demek, ölçmediğini ölçmüş gibi '
            'göstermenin ta kendisi.');

    // Ve eski (göç ÖNCESİ) sayılar hâlâ tek ölçüm olarak duruyorsa, bayrak
    // onlara dayanarak çevrilmiş demektir.
    expect(doc.contains('11,29') && !doc.contains('kabul ölçütü'), isFalse,
        reason: 'bayrak true ama artefakt hâlâ yalnız GÖÇ ÖNCESİ ölçümü '
            'taşıyor — yeni bir ölçüm yapılmadan çevrilmiş');
  });

  test('bayrağın DEĞERİ tek kaynakta ve yüzeye SIZMIYOR', () {
    // Bayrak bir mühendislik olgusu; kullanıcı yüzeyinde karşılığı
    // "referans-derecesi sunulamaz" davranışıdır, bayrağın kendisi değil.
    for (final FileSystemEntity f
        in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      expect(File(f.path).readAsStringSync(),
          isNot(contains('kBridgeIsReferenceEquivalent')),
          reason: '${f.path}: mühendislik bayrağı kabuk katmanına sızmış — '
              'yüzey DAVRANIŞI taşır, bayrağı değil');
    }
  });
}
