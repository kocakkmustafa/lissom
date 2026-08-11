/// O3↔KAMERA KAPISI — koordinatör şartı, kamera-kabuğu sevkinden ÖNCE
/// kuruldu (2026-08-12).
///
/// `os_layer_test.dart`'ın "capture yolu ile izin metni BİRLİKTE yaşar"
/// deseninin İKİZİ. Bugün O3 (`OnboardingFlow`) `CaptureUnavailableNote`
/// ile "No session can be captured in this build" diyor — **DOĞRU, bugün**
/// (kamera kabuğu `lib/`e hiç bağlı değil). `CameraPoseSource` bağlandığı
/// an bu cümle **YALANA döner**: istenecek gerçek bir izin OLACAK, ve
/// cümle hâlâ "hiçbir seans yakalanamaz" diyecek.
///
/// > *Bugün doğru olan bir dürüstlük metni, bir sonraki commit'le yalana
/// > dönebilir — ve yalanı yapacak olan o commit'i yazandır.*
///
/// Bu kapı kamera koduna dokunmadan ÖNCE kuruluyor ki koruyacağı ihlali
/// önceden yakalasın (koordinatörün "önce kapıyı kur, sonra bağla" hükmü).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `os_layer_test.dart`/`ship_blocker_test.dart` ile AYNI desen — bu
/// dosyalar arasında paylaşılan bir test/support modülü YOK (aile
/// konvansiyonu: her test dosyası kendi tarayıcısını taşır), o yüzden
/// burada da yerel.
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

String _onboardingFlowSource() =>
    File('lib/app/onboarding_flow.dart').readAsStringSync();

void main() {
  test(
      'capture yolu VARKEN O3 "bu build\'de yakalanamaz" metnini TAŞIMAZ '
      '(ve tersi)', () {
    final bool capture = _hasCapturePath();
    final bool showsUnavailable =
        _onboardingFlowSource().contains('CaptureUnavailableNote');

    if (capture) {
      expect(showsUnavailable, isFalse,
          reason: 'lib/ içinde bir kamera yolu var ama O3 hâlâ '
              '`CaptureUnavailableNote` ile "No session can be captured in '
              'this build" diyor — bu, DOĞRU bir cümlenin YALANA döndüğü '
              'an ve isimli bir kapı olmadan SESSİZCE geçerdi (koordinatör '
              'şartı, 2026-08-12). Kamerayı bağlayan commit O3\'ü de '
              'AYNI commit\'te güncellemeli — gerçek bir izin adımı, '
              '"video cihazdan çıkmaz" gerekçesiyle.');
    } else {
      expect(showsUnavailable, isTrue,
          reason: 'capture yolu yokken O3 doğru şeyi (kamera henüz yok) '
              'söylemeli — bu dalın gevşetilmesi, olmayan bir izin akışını '
              'beyan etmek olurdu (L-249 sınıfı — "olmayan bir yeteneği '
              'beyan etmek de gürültüdür")');
    }
  });
}
