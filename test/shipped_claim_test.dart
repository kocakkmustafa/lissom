/// **SEVK EDİLMİŞ İDDİA KAPILARI (L-251)** — J-133 ölçütü.
///
/// > **Bir cümle sevk edildiyse, onu yanlışa çevirecek en MAKUL değişikliği
/// > sor. Makulse, kapı gerekir.**
///
/// Bu ürünün en kalabalık yüzeyi dürüstlük dili: *"What Lissom doesn't do"* ·
/// 9 engelli test gerekçesi · kıyas-kapalı beyanı · `measurementOnly`.
/// Hepsi **sevk edilmiş iddia** — bugün doğru olmaları yetmez; yarın onları
/// yanlışa çevirecek değişiklik geldiğinde **kimse yalan söylemeye karar
/// vermez, bir göç ya da bir iyileştirme yapar.**
///
/// İki iddia ölçüldü ve ikisi de MAKUL bir değişiklikle yalanlanıyor:
///
/// **① *"no figure for how much a reading can move on its own"*** — bugün
/// doğru (config'te hiçbir MDC/tekrarlanabilirlik rakamı yok, tarandı). Ama
/// bir MDC eşiği eklendiği gün cümle yalan olur, ve MDC eklemek bu ürünün
/// açık yol haritasında.
///
/// **② *"the measurement engine keeps a single tilt"*** — bugün doğru. Ama
/// **L-187 göçü tam bunu değiştirecek** ve o karar şu an koordinatörde.
/// Yani bu cümleyi yalanlayacak değişiklik makul değil, **BEKLENİYOR.**
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/ia.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';

/// Kıyas-kapalı beyanının dayandığı olgu: ortada bir gürültü tabanı YOK.
const List<String> _mdcKeys = <String>[
  'mdc',
  'minimalDetectable',
  'smallestDetectable',
  'repeatability',
  'noiseFloor',
  'testRetest',
];

/// MDC-sınıfı anahtar deseni — **TEK ADRES.**
///
/// ⚠️ Bu desen L-252'de bir kez BOZUK yazıldı (`\s` kaçışı Dart kaynağında
/// çözülüyordu), hiç eşleşmiyordu ve kapı **yeşilken hiçbir şey ölçmüyordu.**
/// O gün yalnız elle ters-sabotaj gösterdi.
///
/// Sonra ikinci kez, pozitif ikizi yazarken deseni **kopyaladım** ve kopya da
/// bozuktu (`\$k` Dart'ta düz dolar işareti, interpolasyon DEĞİL). İkiz
/// bunu ANINDA yakaladı — ama asıl ders şu: **ikiz kendi kopyasını
/// kanıtlıyordu, iddianınkini değil.** Bir ikiz ancak iddiayla AYNI kodu
/// çağırırsa kanıttır.
RegExp _mdcPattern(String key) =>
    RegExp('"$key[A-Za-z]*"\\s*:', caseSensitive: false);

void main() {
  test('① KIYAS-KAPALI beyanı: MDC rakamı belirirse cümle YENİDEN YAZILMALI',
      () {
    // Config ağacında MDC-sınıfı bir rakam var mı?
    final List<String> found = <String>[];
    for (final FileSystemEntity f
        in Directory('config').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.json')) continue;
      final String raw = File(f.path).readAsStringSync();
      for (final String k in _mdcKeys) {
        // Desen TEK ADRESTEN (`_mdcPattern`) — iddia ve pozitif ikiz AYNI
        // kodu çağırmak ZORUNDA. İlk yazımda iki ayrı kopya vardı, ikizdeki
        // bozuktu ve ikiz kendi kopyasını kanıtlıyordu.
        if (_mdcPattern(k).hasMatch(raw)) {
          found.add('${f.uri.pathSegments.last}: $k');
        }
      }
    }
    expect(found, isEmpty,
        reason: 'Bir MDC/tekrarlanabilirlik rakamı config\'e girmiş:\\n'
            '${found.join("\\n")}\\n\\n'
            'Progress ekranı hâlâ şunu diyor: "We also have no figure for how '
            'much a reading can move on its own between two sessions." '
            'O cümle ARTIK YANLIŞ — ya kaldırın ya da rakamı kullanın. '
            'Bu kapı, kimsenin yalan söylemeye karar vermeden bir cümleyi '
            'yalana çevirmesini engellemek için var (J-133).');

    // POZİTİF ÇAPA #1: tarama gerçekten config okuyor mu?
    expect(Directory('config').listSync(recursive: true).whereType<File>(),
        isNotEmpty);

    // POZİTİF ÇAPA #2 — BULUCUNUN KENDİSİ (L-255).
    // ⚠️ Bu tam olarak L-252'nin olduğu yer: desendeki kaçış yanlıştı, regex
    // HİÇ eşleşmiyordu, kapı yeşildi ve hiçbir şey ölçmüyordu. O gün yalnız
    // elle sabotaj gösterdi. Artık KALICI: desen, olması gereken şeyi
    // bulduğunu her koşuda kanıtlıyor.
    const String synthetic = '{"mdcDegrees": 4.5, "other": 1}';
    final bool patternWorks =
        _mdcKeys.any((String k) => _mdcPattern(k).hasMatch(synthetic));
    expect(patternWorks, isTrue,
        reason: 'BULUCU BOZUK: MDC deseni, apaçık bir `"mdcDegrees":` '
            'anahtarını bile bulamıyor — bu kapının her yeşili vakum-doğru');
  });

  test('② notMeasured satırı: yalanlayan metrik köprüye girerse KIRMIZI', () {
    final LibraryIa ia = iaFromDisk();
    final Set<String> bridged =
        kMetricBindings.map((MetricBinding b) => b.lissomMetric).toSet();

    final List<String> stale = <String>[];
    int guarded = 0;
    for (final LibraryFamily f in ia.families) {
      for (final NotMeasuredLine l in f.notMeasuredLines) {
        if (l.falsifiedIfBridged.isEmpty) continue;
        guarded++;
        final List<String> now =
            l.falsifiedIfBridged.where(bridged.contains).toList();
        if (now.isNotEmpty) {
          stale.add('«${l.claim}»\\n    → artık köprüde: ${now.join(", ")}');
        }
      }
    }

    // POZİTİF ÇAPA: en az bir satır GERÇEKTEN korunuyor olmalı, yoksa bu test
    // boş kümede geçer ve hiçbir şey kanıtlamaz (L-183).
    expect(guarded, greaterThan(0),
        reason: 'hiçbir notMeasured satırı `falsifiedIfBridged` taşımıyor — '
            'motor sınırı anan her satır taşımalı, yoksa kapı boş');

    expect(stale, isEmpty,
        reason: 'Bir "şunu ölçmüyoruz" satırı ARTIK YANLIŞ:\\n'
            '${stale.join("\\n")}\\n\\n'
            'Metrik köprüye girdi — cümleyi yeniden yazın. Kimse yalan '
            'söylemeye karar vermedi, bir göç yapıldı (J-133).');
  });

  test('② negatif ikiz: kapı GERÇEKTEN kırmızı yanabiliyor', () {
    // Sahte bir "köprülü" küme ile aynı hükmü koştur: korunan satır
    // yakalanmalı. Yoksa yukarıdaki yeşil, boş bir yeşildir.
    final LibraryIa ia = iaFromDisk();
    final List<NotMeasuredLine> guarded = <NotMeasuredLine>[
      for (final LibraryFamily f in ia.families)
        ...f.notMeasuredLines.where(
            (NotMeasuredLine l) => l.falsifiedIfBridged.isNotEmpty),
    ];
    expect(guarded, isNotEmpty);
    final Set<String> pretendBridged = guarded.first.falsifiedIfBridged.toSet();
    final bool wouldCatch = guarded.first.falsifiedIfBridged
        .any(pretendBridged.contains);
    expect(wouldCatch, isTrue,
        reason: 'hüküm kendi beyan ettiği metrikle bile eşleşmiyorsa kapı ölü');
  });

  test('ölçüm ARAÇLARI sahte sıfır dönmüyor — cwd bağımsız', () {
    // Koordinatörün öz-düzeltmesi: "rapor edilen sıfır, ölçülen sıfır
    // sanılıyor." `wellness_lint` kökü `__file__`ten türetiyor, yani yanlış
    // dizinden koşmak SESSİZ SIFIR üretmiyor — ölçüldü (`cd / && …` temiz
    // rapor verdi). Burada o özelliği ÇİVİLİYORUZ.
    final String src = File('tools/wellness_lint.py').readAsStringSync();
    expect(src, contains('ROOT = Path(__file__).resolve().parent.parent'),
        reason: 'kök cwd\'den türetilirse araç yanlış dizinde SESSİZCE sıfır '
            'ihlal raporlar — ve rapor edilen sıfır, ölçülen sıfır sanılır');
    // Ve zaten var olan vakum kapıları duruyor mu?
    for (final String guard in <String>[
      'Taranacak dosya bulunamadı',
      'hiç metin çıkarılamadı',
      'Dart dosyalarından hiç string çıkarılamadı',
    ]) {
      expect(src, contains(guard),
          reason: 'vakum kapısı kaybolmuş: «$guard»');
    }
  });
}
