/// **SEVK DİLİ KAPISI (L-257)** — koordinatörün "replik çeşitliliği" sorusunu
/// ölçerken çıkan asıl kusur.
///
/// ## Soru neydi, ölçüm ne buldu
///
/// Koordinatör JabLab'ın tekrar-eden-replik kusurunu sordu: *canlı
/// değerlendirici aynı cümleyi kaç kez basıyor?* Ölçtüm:
///
/// - `LiveEvaluator` durum metinlerini **kare başına** yayıyor (`continue`
///   `await for` içinde), varyant sayısı **1**.
/// - Ama `lib/` içinde `LiveEvaluator`a **hiçbir atıf yok** → bugün bir
///   kullanıcıya ulaşan tekrar sayısı **SIFIR.**
/// - Ve JabLab'ın hükmü buraya **olduğu gibi geçmiyor:** oradaki replikler
///   *söz edimi* (her ateşleme ayrı bir söyleyiş, altı kez = altı rahatsızlık);
///   buradakiler *durum etiketi* — süren bir durum TEK etiket olarak görünür.
///   Kare başına tekrar, durum yüzeyinde görünmez. "Varyant sayısı ateşlenme
///   sıklığıyla ölçeklensin" kuralını buraya kopyalamak, **ürün doğru
///   davranırken kırmızıya dönen fazla-geniş bir kapı** olurdu.
///
/// ## Ölçüm asıl kusuru buldu — ve o dil katmanındaydı
///
/// Motorun **5 kullanıcı-yüzü metni Türkçeydi**, kabuğun sevk edilen kopyası
/// ise **%100 İngilizce.** Kapılarım kelime tarıyordu (wellness yasakları,
/// vaat yasağı) ama **hiçbiri DİLE bakmıyordu.** Katman sorusu, kelime
/// sorusundan önce gelir.
///
/// ⚠️ Ölçümüm önce **dardı**: yalnız `live_evaluator.dart`a baktım, 2 buldum.
/// Katmanın tamamı (`packages/lissom_engine/lib`) 37 Türkçe metin taşıyordu;
/// 32'si `throw`/assert (**geliştirici-yüzü, doğru ve kalmalı**), 5'i
/// kullanıcı-yüzü. *Bir dosya, bir katman değildir.*
///
/// ## Eşik nereden geliyor — icat DEĞİL
///
/// *"Kullanıcı-yüzü metin İngilizce olmalı"* demiyorum; bu benim icadım
/// olurdu. Kural **kabuğun kendi sevk ettiği dile** bağlı: motor metinleri
/// `lib/`in sevk edilen kopyasıyla aynı dilde olmak zorunda. Ürün bir gün
/// Türkçeye geçerse kural kendiliğinden döner — kapı geleceğin doğru hâlini
/// yasaklamıyor (L-248).
///
/// **Ve referansa bağlı kuralın açığı, REFERANSI DÜŞÜRMEKTİR:** kabuğun
/// kullanıcı metinleri silinirse kural vakum-doğru olur. O yüzden referansın
/// kendisi de ölçülüyor.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Türkçe'ye özgü harfler — dil ayrımının **tek adresi** (L-256).
final RegExp _turkishMark = RegExp('[çğışöüÇĞİŞÖÜ]');

/// Yorumları at. **L-246'nın dersi:** yanlış birimde ölçmek, yanlış ölçmektir.
/// Bu depo Türkçe yorumluyor; yorumları saymak her dosyayı "Türkçe" gösterir.
String _stripComments(String src) => src
    .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '')
    .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');

/// **KULLANICI-YÜZÜ** metin çıkarıcı — iddia ve pozitif ikiz AYNI kodu çağırır.
///
/// Katman ayrımı burada yaşıyor: `userText` / `narrative` kullanıcıya gider;
/// `throw ...` geliştiriciye gider ve **Türkçe kalmalı.**
List<String> userFacingStrings(String source) {
  final String src = _stripComments(source);
  final List<String> out = <String>[];
  // Kullanıcı-yüzü konumun ARDINDAN gelen metin sabitleri. Hem `userText:`
  // atama biçimi hem `String get userText => '...'` ifade biçimi taranır —
  // ifade biçimi `wellness_lint`in görmediği formdu.
  for (final RegExpMatch m
      in RegExp(r'(userText|narrative)\s*(:|=>)([^;]*);').allMatches(src)) {
    for (final RegExpMatch s
        in RegExp(r"'([^'\\]*)'").allMatches(m.group(3)!)) {
      final String lit = s.group(1)!;
      if (RegExp('[A-Za-zÇĞİÖŞÜçğıöşü]').hasMatch(lit)) out.add(lit);
    }
  }
  return out;
}

Iterable<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart'));

void main() {
  test('POZİTİF İKİZ: çıkarıcı, olması GEREKEN metni buluyor mu?', () {
    // L-255/L-256: bu kapı bir YOKLUK ölçüyor ("Türkçe kullanıcı metni yok").
    // Bozuk bir çıkarıcı ile temiz bir depo birbirinden ayırt edilemez.
    const String synthetic = '''
      class X {
        String get userText => 'Kamera hazırlanıyor.';
        void y() { throw StateError('geliştirici mesajı Türkçe KALMALI'); }
      }
    ''';
    final List<String> found = userFacingStrings(synthetic);
    expect(found, contains('Kamera hazırlanıyor.'),
        reason: 'BULUCU BOZUK: çıkarıcı, apaçık bir `userText` sabitini bile '
            'bulamıyor — "Türkçe kullanıcı metni yok" iddiası vakum-doğru');
    expect(found.any((String s) => s.contains('geliştirici')), isFalse,
        reason: 'KAPI FAZLA GENİŞ: `throw` mesajını kullanıcı-yüzü saydı. '
            'Geliştirici mesajları Türkçe KALMALI — bu kapı onları '
            'kırmızıya döndürürse, doğru davranışı cezalandırır');

    // Ve yorum-atma gerçekten çalışıyor mu (L-246)?
    expect(userFacingStrings("/// userText => 'Kamera hazırlanıyor.';"),
        isEmpty,
        reason: 'yorumlar taranıyor — her dosya "Türkçe" görünür');
  });

  test('REFERANS ölçülür: kabuğun sevk ettiği kullanıcı dili', () {
    // Referansa bağlı bir kuralın açığı REFERANSI DÜŞÜRMEKTİR. Kabuğun
    // kullanıcı metinleri silinirse aşağıdaki hüküm vakum-doğru olurdu.
    final List<String> shell = <String>[
      for (final File f in _dartFiles('lib'))
        ...RegExp(r"Text\(\s*'([^'\\]{6,})'")
            .allMatches(_stripComments(f.readAsStringSync()))
            .map((RegExpMatch m) => m.group(1)!),
    ];
    expect(shell, isNotEmpty,
        reason: 'REFERANS DÜŞTÜ: kabukta hiç kullanıcı metni bulunamadı. '
            'Bu kapı kabuğun sevk ettiği dile bağlı — referans boşalırsa '
            'kural hiçbir şey ölçmez');

    final List<String> shellTurkish =
        shell.where(_turkishMark.hasMatch).toList();
    expect(shellTurkish, isEmpty,
        reason: 'Kabuk artık Türkçe kullanıcı metni taşıyor:\n'
            '  ${shellTurkish.take(5).join("\n  ")}\n\n'
            'Bu bir HATA değil, bir KARAR olabilir (ürün Türkçeye geçti). '
            'Öyleyse bu kapı ters çevrilmeli — ama SESSİZCE ikiye bölünmüş '
            'bir yüzeyle değil.');
  });

  test('MOTORUN kullanıcı-yüzü metinleri kabuğun diliyle AYNI', () {
    final Map<String, List<String>> offenders = <String, List<String>>{};
    int scanned = 0;
    for (final File f in _dartFiles('packages/lissom_engine/lib')) {
      final List<String> user = userFacingStrings(f.readAsStringSync());
      scanned += user.length;
      final List<String> bad = user.where(_turkishMark.hasMatch).toList();
      if (bad.isNotEmpty) offenders[f.uri.pathSegments.last] = bad;
    }

    // Pozitif çapa: motorda gerçekten kullanıcı-yüzü metin VAR mı? Yoksa
    // aşağıdaki yeşil, boş bir kümenin yeşilidir (L-183).
    expect(scanned, greaterThan(0),
        reason: 'motorda hiç kullanıcı-yüzü metin bulunamadı — çıkarıcı '
            'gerçek kaynağa bakmıyor olabilir');

    expect(offenders, isEmpty,
        reason: 'Motorun kullanıcı-yüzü metni kabuğun sevk dilinde DEĞİL:\n'
            '${offenders.entries.map((MapEntry<String, List<String>> e) =>
                "  ${e.key}: ${e.value.join(" · ")}").join("\n")}\n\n'
            'Bu metinler kameraya bağlandığı gün kullanıcıya ÇIKAR. '
            'Kapılarım kelime tarıyordu, DİLE bakan yoktu.');
  });
}
