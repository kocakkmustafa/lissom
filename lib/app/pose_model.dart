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
/// CameraPoseSource üretimde bu hazırlama adımını çağırır. Bundle ve disk
/// önbelleği aynı pinli hash ile doğrulanmadan native kameraya yol verilmez.
/// Bu byte doğrulaması yoga tanıma veya fiziksel doğruluk kabulü değildir.
///
/// ## Neden dizin sağlayıcı ENJEKTE ediliyor
///
/// `getApplicationSupportDirectory()` bir platform kanalıdır ve widget
/// testinde yoktur. Sağlayıcıyı dışarıdan almak, adımın **gerçek dosya
/// sistemiyle** sınanmasını mümkün kılıyor (kabuğun `loader`ıyla aynı desen).
library;

import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

/// Pin'li model varlığı. **Sürüm adı dosyada** — `latest` YASAK (M-L-01:
/// `latest` ile `/1/` aynı boyutta FARKLI hash veriyor ve fark gözden kaçar).
const String kPoseModelAsset = 'assets/models/pose_landmarker_full.v1.task';

/// Modelin **kimliği** — her ölçüm zarfının provenance'ına damgalanır, yani
/// bir model değişimi bir oturumu sessizce yeniden yorumlayamaz.
const String kPoseModelId = 'pose_landmarker_full.v1';

/// Same immutable byte identity as tool/fetch_pose_model.sh.
const String kPoseModelSha256 =
    '5134a3aad27a58b93da0088d431f366da362b44e3ccfbe3462b3827a839011b1';

/// Bundle'daki modeli dosya sistemine çıkarır ve **mutlak yolunu** döndürür.
///
/// Bundle ve önbellek pinli SHA-256 ile doğrulanır. Yalnız boyut eşliği
/// yeterli değildir; bozuk önbellek doğrulanmış bundle ile atomik değiştirilir.
Future<String> materializePoseModel({
  Future<Directory> Function()? supportDir,
  AssetLoader? loader,
}) async {
  final Directory dir = await (supportDir ?? getApplicationSupportDirectory)();
  final File out = File('${dir.path}/$kPoseModelId.task');

  final ByteData data = await (loader ?? rootBundle.load)(kPoseModelAsset);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (sha256.convert(bytes).toString() != kPoseModelSha256) {
    throw StateError('Bundled pose model does not match the pinned SHA-256');
  }

  final type = await FileSystemEntity.type(out.path, followLinks: false);
  if (type != FileSystemEntityType.notFound &&
      type != FileSystemEntityType.file) {
    throw FileSystemException(
      'Pose model cache is not a regular file',
      out.path,
    );
  }
  if (type == FileSystemEntityType.file &&
      await out.length() == bytes.length &&
      (await sha256.bind(out.openRead()).first).toString() ==
          kPoseModelSha256) {
    return out.path;
  }

  await out.parent.create(recursive: true);
  final staging = await out.parent.createTemp('lissom-pose-');
  try {
    final staged = File('${staging.path}/model.task');
    await staged.writeAsBytes(bytes, flush: true);
    if ((await sha256.bind(staged.openRead()).first).toString() !=
        kPoseModelSha256) {
      throw StateError('Written pose model does not match the pinned SHA-256');
    }
    await staged.rename(out.path);
  } finally {
    await staging.delete(recursive: true);
  }
  return out.path;
}

/// Test enjeksiyonu için — `rootBundle.load` imzası.
typedef AssetLoader = Future<ByteData> Function(String key);
