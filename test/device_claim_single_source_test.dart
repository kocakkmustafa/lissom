/// **CİHAZ-GEÇİŞİ İDDİASI TEK KAYNAKTAN (L-318).**
///
/// ═══════════════════════════════════════════════════════════════════
/// ## NEDEN — bu gece iki kez ödenen kusurun ÖNCEDEN GÖRÜLEN üçüncüsü
/// ═══════════════════════════════════════════════════════════════════
///
/// Bu vardiyada aynı sınıftan **iki** kusur bulundu, ikisi de *"ön koşul
/// değişti, cümle yerinde kaldı"*:
///   · `L-316` — çekirdeğin *"before the camera bridge"* gerekçesi (köprü geldi)
///   · `L-317` — Progress'in *"no session can be captured in this build"*ı
///
/// Üçüncüsü **henüz olmadı ama yeri belli**: *"gerçek telefonda denenmedi"*
/// iddiası üç ayrı yerde ELLE yazılmıştı. A12 kapandığında (preflight hazır)
/// biri ikisini güncelleyip üçüncüsünü unutacaktı ve uygulama aynı anda
/// *"cihazda doğrulandı"* ve *"denenmedi"* diyecekti.
///
/// > ***AYNI OLGUYU İKİ YERE YAZMAK, ONLARI AYIRMANIN BİR YOLUNU AÇIK
/// > BIRAKMAKTIR — ve o yol er ya da geç kullanılır.***
///
/// ⭐ Kapının doğruladığı **A kalemi**: *"uygulama cihazda doğrulanma
/// durumu hakkında kendi kendiyle çelişmez."* Bir belge-tazeliği kapısı
/// DEĞİL; kullanıcı-yüzeyi iddiası.
///
/// ⛔ **Ne YASAKLAMIYOR:** farklı ÇERÇEVE. `LiveCaptureScreen` dört kalemi tek
/// tek sayıyor, Home daha geniş bir banner yazıyor — *farklı sunum meşru,
/// farklı OLGU değil.* Kapı yalnız olgunun ikinci kez ELLE yazılmasını
/// engelliyor.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/surfaces.dart';

/// Olgunun elle yazılmış hâlini arayan desenler. `DevicePassClaim`ten
/// TÜRETEN kod bu desenleri içermez — çünkü sabiti REFERANS ALIR.
const List<String> _handWritten = <String>[
  'on a real phone',
  'need a device pass',
  'needs a device pass',
];

/// Olgunun sahibi. Yalnız burada elle yazılabilir.
const String _owner = 'lib/app/surfaces.dart';

void main() {
  test('cihaz-geçişi olgusu `lib/` içinde YALNIZ tek yerde elle yazılır', () {
    final Map<String, List<String>> offenders = <String, List<String>>{};
    int scanned = 0;

    for (final FileSystemEntity e
        in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (e.path == _owner) continue;

      final List<String> lines = e.readAsLinesSync();
      for (int i = 0; i < lines.length; i++) {
        final String ln = lines[i];
        final String trimmed = ln.trimLeft();
        // 🪤 YORUM SAYILMAZ. Bu gece kendi sabotaj-doğrulamam bir YORUMLA
        // eşleşti ve bir an "geri alma tutmadı" sandım (L-317). Bu dosyanın
        // KENDİ başlığı da iddiayı alıntılıyor — dışlanmasaydı kapı kendi
        // belgesini ihlal sayardı.
        if (trimmed.startsWith('//')) continue;
        scanned++;
        for (final String pat in _handWritten) {
          if (ln.contains(pat)) {
            (offenders[e.path] ??= <String>[]).add('${i + 1}: ${ln.trim()}');
          }
        }
      }
    }

    // POZİTİF ÇAPA: tarayıcı gerçekten kod okudu mu? Yol yanlışsa ya da
    // desen bozuksa "0 ihlal" VAKUM-DOĞRU olurdu — bu gece üç kez tam bunu
    // yaşadım.
    expect(scanned, greaterThan(500),
        reason: 'tarayıcı `lib/` altında yeterli satır görmedi — sonuç ölçüm '
            'değil (yol ya da desen bozuk)');

    expect(
      offenders,
      isEmpty,
      reason: 'Cihaz-geçişi olgusu ikinci kez ELLE yazılmış. A12 kapandığında '
          'bu kopya güncellenmeyecek ve uygulama kendi kendiyle çelişecek '
          '(L-317 birebir tekrarı). `DevicePassClaim.notTried` / '
          '`.stillNeeds` sabitlerinden TÜRET: $offenders',
    );
  });

  test('POZİTİF KONTROL: desen gerçekten elle-yazımı yakalıyor', () {
    // Kapının kendisi çalışıyor mu? Sabotajı KAYNAĞA yazmak yerine deseni
    // doğrudan sınıyorum — ürünü bozmadan, ama deseni beyan etmeden.
    const String fake =
        "  reason: 'It has not been tried on a real phone.',";
    expect(_handWritten.any(fake.contains), isTrue,
        reason: 'desen elle yazılmış bir iddiayı YAKALAMIYOR — kapı kör');

    const String derived =
        "  reason: '\${DevicePassClaim.notTried}.',";
    expect(_handWritten.any(derived.contains), isFalse,
        reason: 'desen TÜRETEN kodu da suçluyor — kapı meşru kullanımı '
            'engelliyorsa hat onu kapatır ve koruma tamamen kaybolur');
  });

  testWidgets('ÜÇ YÜZEY de AYNI olguyu söylüyor — çizilmiş ağaçta',
      (WidgetTester tester) async {
    // Kaynak taraması *"ikinci kez yazılmadı"*yı kanıtlar; bu test
    // *"gerçekten aynı şeyi söylüyorlar"*ı kanıtlar. İkisi ayrı iddia.
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: CaptureUnavailableNote()),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining(DevicePassClaim.notTried), findsOneWidget,
        reason: 'paylaşılan not artık olguyu taşımıyor — türetme kopmuş');

    // A12 hâlâ açık: sabit `false` olmalı. Cihaz koşusu kanıtlanınca bu
    // satır TEK BAŞINA değişir ve üç yüzey birden düzelir.
    expect(DevicePassClaim.verified, isFalse,
        reason: 'A12 kapandıysa bu sabit ve üç yüzeyin metni birlikte '
            'güncellenmeli — kanıt olmadan `true` YAZILMAZ');
  });
}
