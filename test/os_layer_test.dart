/// **İŞLETİM SİSTEMİ KATMANI (L-250)** — hiçbir kapının bakmadığı katman.
///
/// Koordinatörün sorusu: *"kapı yazarken ilk soru 'hangi kelimeler' değil,
/// 'hangi KATMANLAR'."* Ölçüldü — `wellness_lint` şu katmanlara bakıyor:
/// `config/**` · `lib/**` · `packages/lissom_engine/lib/**`. **Bakmadığı:**
/// `ios/Runner/Info.plist` ve Android manifest — oysa oradaki metinler
/// kullanıcıya **işletim sisteminin kendi diyaloğunda** gösterilir ve
/// uygulamanın dışına çıkan ilk cümledir.
///
/// ## Bulgu: `NSCameraUsageDescription` YOK
///
/// `motion_camera` bir bağımlılık, ürünün tüm önermesi kamerayla ölçüm — ama
/// izin metni **hiç yok.** iOS'ta izin isteyen bir uygulama bu anahtar
/// olmadan **anında çökerti verir.**
///
/// ⛔ **Metni ŞİMDİ EKLEMEDİM ve bu bilinçli.** Bugün hiçbir capture yolu yok
/// (L-242); kamera izni beyan etmek, **olmayan bir yeteneği beyan etmek**
/// olurdu — az önce yedi yüzeyde düzelttiğim sınıfın ta kendisi. Ve *"olmayan
/// bir sınırı beyan etmek gürültüdür"*in ikizi: **olmayan bir yeteneği beyan
/// etmek de gürültüdür.**
///
/// Onun yerine ikisi BİRBİRİNE BAĞLANDI: capture yolu doğduğu an izin metni
/// zorunlu olur. Bugün yeşil, yarın kendiliğinden kırmızı.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `lib/` içinde bir kamera-capture yolu var mı?
bool _hasCapturePath() {
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final String src = File(f.path)
        .readAsStringSync()
        .replaceAll(RegExp(r'//[^\n]*'), ' ');
    if (RegExp(r'\bCameraController\b|\bmotion_camera\b|\bstartImageStream\b')
        .hasMatch(src)) {
      return true;
    }
  }
  return false;
}

String _infoPlist() => File('ios/Runner/Info.plist').readAsStringSync();

void main() {
  test('KAMERA İZNİ: capture yolu ile izin metni BİRLİKTE yaşar', () {
    final bool capture = _hasCapturePath();
    final bool hasKey = _infoPlist().contains('NSCameraUsageDescription');

    if (capture) {
      expect(hasKey, isTrue,
          reason: 'lib/ içinde bir kamera yolu var ama '
              '`NSCameraUsageDescription` YOK — iOS izin isteyen uygulamayı '
              'bu anahtar olmadan ANINDA çökertir');
    } else {
      // Simetrik yön: capture yokken izin metni OLMAMALI. Olmayan bir
      // yeteneği beyan etmek de gürültüdür (L-249'un ikizi).
      expect(hasKey, isFalse,
          reason: 'capture yolu yokken kamera izni beyan edilmiş — '
              'kullanılmayan bir yetenek beyanı, kullanıcıya olmayan bir '
              'şeyi anlatır');
    }
  });

  test('İŞLETİM SİSTEMİ metinleri BİLİNİYOR — sessiz katman kalmıyor', () {
    // Pozitif çapa: plist gerçekten okundu mu?
    final String plist = _infoPlist();
    expect(plist, contains('CFBundleDisplayName'),
        reason: 'plist okunamadı — bu test hiçbir şey ölçmüyor');

    // Bugün OS katmanında kullanıcıya görünen TEK metin uygulama adı.
    // Yeni bir `*UsageDescription` eklendiğinde bu liste büyümeli ve o metin
    // `wellness_lint`ten geçmeli; aksi hâlde uygulamanın dışına çıkan ilk
    // cümle hiçbir denetimden geçmemiş olur.
    // POZİTİF İKİZ (L-255): desen, olması gereken şeyi buluyor mu? Bu bir
    // YOKLUK iddiası — bozuk bir desen ile doğru bir sonuç ayırt edilemez.
    final RegExp usagePattern = RegExp(r'<key>(NS\w*UsageDescription)</key>');
    expect(
        usagePattern.hasMatch('<key>NSCameraUsageDescription</key>'), isTrue,
        reason: 'BULUCU BOZUK: desen apaçık bir izin anahtarını bile '
            'bulamıyor — aşağıdaki "izin metni yok" iddiası vakum-doğru');

    final Iterable<RegExpMatch> usage = usagePattern.allMatches(plist);
    expect(usage.map((RegExpMatch m) => m.group(1)).toList(), isEmpty,
        reason: 'yeni bir izin metni eklendi — `wellness_lint`in OS katmanına '
            'da bakması gerekiyor (tools/wellness_lint.py `--path` ile '
            'plist taranabilir)');
  });
}
