/// **HAZIRLAMA ADIMI, KAMERA GELMEDEN KANITLANIR (L-274).**
///
/// Choreia'nın tuzağı: sahte bundle **diski** okuyordu, kullanıcının elinde
/// **paket** var → yüzey *"başlatılabilir"* dedi, gerçek `rootBundle`
/// **patladı**. Aynı asimetri burada da olurdu: model `pubspec`'te beyanlı
/// olsa bile plugin **mutlak dosya yolu** istiyor.
///
/// Bu test **gerçek dosya sistemine yazıyor** — yani kamera bağlandığında bu
/// adım hata ayıklanacak bir bilinmez değil, **ölçülmüş bir olgu**.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/pose_model.dart';

void main() {
  test('MODEL DEPODA ve pin\'li SHA ile aynı boyutta', () {
    final File f = File(kPoseModelAsset);
    expect(f.existsSync(), isTrue,
        reason: 'Model yok. `tool/fetch_pose_model.sh` çalıştırın — dosya '
            'git\'te tutulmuyor (9,4 MB), pin URL+SHA olarak yaşıyor.');
    // Aile pin'inin ölçülmüş boyutu. Boyut TEK BAŞINA yeterli değil (M-L-01:
    // `latest` ile `/1/` AYNI boyutta farklı hash) — SHA doğrulaması
    // `fetch_pose_model.sh`'de, bir BUILD kapısı olarak yaşıyor. Burada
    // ölçülen şey "model yerinde mi".
    expect(f.lengthSync(), 9398198,
        reason: 'Model boyutu pin\'den farklı — yanlış varyant ya da yarım '
            'indirme. `tool/fetch_pose_model.sh` SHA\'yı doğrular.');
  });

  test('HAZIRLAMA: bundle → dosya sistemi, MUTLAK yol döner', () async {
    final Directory tmp =
        await Directory.systemTemp.createTemp('lissom_model_test');
    addTearDown(() => tmp.deleteSync(recursive: true));

    // Bundle'ı taklit et: gerçek model baytlarını ver.
    final Uint8List bytes = File(kPoseModelAsset).readAsBytesSync();
    int loads = 0;
    Future<ByteData> fakeLoad(String key) async {
      expect(key, kPoseModelAsset,
          reason: 'yanlış varlık anahtarı istendi');
      loads++;
      return ByteData.view(bytes.buffer);
    }

    final String path = await materializePoseModel(
      supportDir: () async => tmp,
      loader: fakeLoad,
    );

    expect(File(path).isAbsolute, isTrue,
        reason: 'Plugin MUTLAK yol istiyor — göreli bir yol native tarafta '
            'açılamaz ve kamera hiç başlamaz');
    expect(File(path).existsSync(), isTrue);
    expect(File(path).lengthSync(), bytes.length,
        reason: 'yarım yazılmış model — native taraf bozuk model yükler');
    expect(loads, 1);

    // İKİNCİ çağrı yeniden YAZMAZ: 9,4 MB'ı her açılışta diske yazmak ilk
    // ölçümü geciktirir. (N'inci kez ekseni: N=1 doğru olan N=2'de de doğru
    // olmalı, ve burada N=2'nin DAVRANIŞI farklı.)
    final String again = await materializePoseModel(
      supportDir: () async => tmp,
      loader: fakeLoad,
    );
    expect(again, path);
    expect(loads, 2, reason: 'bundle yine okundu (boyut karşılaştırması için)');
    expect(File(path).lengthSync(), bytes.length);
  });

  test('YARIM dosya varsa YENİDEN yazılır — sessiz bozuk model YOK', () async {
    final Directory tmp =
        await Directory.systemTemp.createTemp('lissom_model_partial');
    addTearDown(() => tmp.deleteSync(recursive: true));
    final Uint8List bytes = File(kPoseModelAsset).readAsBytesSync();

    // Önceki açılışta yarıda kalmış bir yazma bırak.
    File('${tmp.path}/$kPoseModelId.task').writeAsBytesSync(bytes.sublist(0, 100));

    final String path = await materializePoseModel(
      supportDir: () async => tmp,
      loader: (String k) async => ByteData.view(bytes.buffer),
    );
    expect(File(path).lengthSync(), bytes.length,
        reason: 'Yarım kalmış model OLDUĞU GİBİ bırakılmış. Native taraf onu '
            'yükler ve arıza ölçüm hattında, hazırlama adımından UZAKTA '
            'görünür — teşhisi en zor kusur biçimi.');
  });
}
