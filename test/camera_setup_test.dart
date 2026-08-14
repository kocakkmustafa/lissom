/// **KURULUM TARİFİ YÜZEYE ULAŞIYOR (L-330 · H-24 ②).**
///
/// `config/tests/lissom-assessment.v1.json` → `globalCameraSetup` mesafe,
/// yükseklik, kadraj kuralı ve yaw toleransını taşıyordu — ve **ayrıştırıcısı
/// bile yoktu**, yani kullanıcı telefonu nereye koyacağını hiç öğrenmiyordu,
/// ama ölçüm sonradan *"kadraj yüzünden okunamadı"* diyebiliyordu.
/// > ***BİR ÜRÜN, BAŞARISIZLIĞIN SEBEBİNİ SONRADAN SÖYLEYEBİLİYORSA, ONU
/// > ÖNCEDEN DE SÖYLEYEBİLİR.***
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/facts_from_disk.dart';

void main() {
  test('GERÇEK config: kurulum bloğu ayrıştırılıyor', () {
    final Battery b = batteryFromDisk();

    // POZİTİF ÇAPA: config bloğu GERÇEKTEN taşıyor mu? Taşımasaydı `null`
    // dönerdi ve "ayrıştırma çalışıyor" hükmü vakum-doğru olurdu.
    expect(b.cameraSetup, isNotNull,
        reason: 'gerçek config globalCameraSetup taşımıyor — bu tur ölçmez');
    expect(b.cameraSetup!.distanceCm, <int>[180, 200]);
    expect(b.cameraSetup!.heightCm, <int>[90, 110]);
    expect(b.cameraSetup!.framingRule, contains('in frame'));
    expect(b.cameraSetup!.yawToleranceDeg, 10);
  });

  test('BLOK YOKSA null — boş kart çizilmesin diye', () {
    final Battery b = Battery.parseJson('''
{"id":"t","version":"1","tests":[]}
''');
    expect(b.cameraSetup, isNull,
        reason: 'blok yokken boş bir "Before you start" kartı çizilirdi — '
            'bu gecenin A3 başlıklı-boşluk sınıfı');
  });

  test('BOZUK aralık DÜŞÜRÜLÜR — uydurma tamamlama YOK', () {
    // Tek elemanlı ve ters aralıklar: "180 ile 180 arası" diye bir tarif
    // yoktur, ve eksik aralığı tamamlamak uydurmaktır.
    for (final String bad in <String>['[180]', '[200,180]', '["a","b"]']) {
      final Battery b = Battery.parseJson('''
{"id":"t","version":"1","tests":[],
 "globalCameraSetup":{"distanceCm":$bad,"framingRule":"Keep in frame."}}
''');
      expect(b.cameraSetup?.distanceCm, isNull,
          reason: 'bozuk aralık ($bad) kabul edildi — yüzeyde uydurma bir '
              'mesafe tarifi görünürdü');
      // Ama SAĞLAM alan korunur: bir alanın bozukluğu ötekini düşürmez
      // (L-326'nın dersi, bu katmanda).
      expect(b.cameraSetup?.framingRule, 'Keep in frame.');
    }
  });
}
