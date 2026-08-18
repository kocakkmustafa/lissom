/// **POZ MODELİNİ DOSYA SİSTEMİNE ÇIKARMA (L-274).**
///
/// `motion_camera` modeli **kasıtlı taşımıyor** ve sözleşmesi açık:
///
/// > *"[modelPath] is an absolute filesystem path to the `.task` model asset —
/// > the plugin deliberately bundles no model (apps pin their own and ship it
/// > as an asset)."*
///
/// **Bu yüzden `pubspec`'e eklemek YETMEZ.** Bundle içindeki varlık bir
/// **dosya yolu değil**, bir anahtar; native taraf `File(path)` açmaya
/// çalışır ve bulamaz. Arada bir **hazırlama adımı** gerekiyor: bundle'dan
/// oku → destek dizinine yaz → **mutlak yolu** ver.
///
/// ## Neden bu dosya bugün ÖLÜ KOD DEĞİL
///
/// Kabuk henüz kamerayı çağırmıyor, yani bu fonksiyonun ürün içinde çağıranı
/// yok. Ama **testi var ve test onu gerçekten koşturuyor** — yani kamera
/// geldiğinde bu adım **zaten kanıtlanmış** olacak, canlıda hata ayıklanacak
/// bir bilinmez değil.
///
/// *Beyanın varlığı tetiğinin varlığı değildir* — burada tetik testtir, ve
/// bu bilinçli.
///
/// ## Neden dizin sağlayıcı ENJEKTE ediliyor
///
/// `getApplicationSupportDirectory()` bir platform kanalıdır ve widget
/// testinde yoktur. Sağlayıcıyı dışarıdan almak, adımın **gerçek dosya
/// sistemiyle** sınanmasını mümkün kılıyor (kabuğun `loader`ıyla aynı desen).
library;

import 'dart:io';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

/// Pin'li model varlığı. **Sürüm adı dosyada** — `latest` YASAK (M-L-01:
/// `latest` ile `/1/` aynı boyutta FARKLI hash veriyor ve fark gözden kaçar).
const String kPoseModelAsset = 'assets/models/pose_landmarker_full.v1.task';

/// Modelin **kimliği** — her ölçüm zarfının provenance'ına damgalanır, yani
/// bir model değişimi bir oturumu sessizce yeniden yorumlayamaz.
const String kPoseModelId = 'pose_landmarker_full.v1';

/// Bundle'daki modeli dosya sistemine çıkarır ve **mutlak yolunu** döndürür.
///
/// Zaten doğru boyutta bir kopya varsa **yeniden yazmaz**: 9,4 MB'ı her
/// açılışta diske yazmak, ilk ölçümü geciktirir.
Future<String> materializePoseModel({
  Future<Directory> Function()? supportDir,
  AssetLoader? loader,
}) async {
  final Directory dir = await (supportDir ?? getApplicationSupportDirectory)();
  final File out = File('${dir.path}/$kPoseModelId.task');

  final ByteData data =
      await (loader ?? rootBundle.load)(kPoseModelAsset);
  final int expected = data.lengthInBytes;

  if (out.existsSync() && out.lengthSync() == expected) return out.path;

  await out.parent.create(recursive: true);
  await out.writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, expected),
    flush: true,
  );
  return out.path;
}

/// Test enjeksiyonu için — `rootBundle.load` imzası.
typedef AssetLoader = Future<ByteData> Function(String key);
