/// L-031 ölçümünün Dart yarısı: canlı yolun kare-kare açı çıktısını döker.
///
/// Tek başına bir iddia taşımaz — çıktısı `tools/l031_space_divergence.py`
/// tarafından normatif Python yorumlayıcısıyla EŞLEŞTİRİLEREK kıyaslanır.
/// İki yarının ayrı durması kasıtlı: referans Python'dır (çekirdek doktrini
/// "when the two disagree, this package is right by definition"), dolayısıyla
/// karşılaştırmayı Dart tarafına yazmak hakemi taraflardan biri yapmak olurdu.
///
/// Kullanım:
///   dart run tool/dump_angles.dart <çıktı.json> [fixtureId ...]
///
/// `raw` (ham anizotropik) ve `iso` (`toIsotropic` sonrası) AYNI dosyada
/// döner ki J-028 düzeltmesinin kendi etkisi de ölçülebilsin.
library;

import 'dart:convert';
import 'dart:io';

import 'package:motion_core/motion_core.dart';

/// Ölçülen Lissom metriği → çekirdek JointSpec id.
///
/// Yalnız `angle3` köprüleri: diğer ölçü tipleri Dart çekirdeğinde YOK
/// (bkz. `kUnbridgedMetrics`), yani kıyaslanacak bir Dart sayısı da yok.
const Map<String, String> kProbe = <String, String>{
  'shoulder_flexion_right': 'right_shoulder',
  'shoulder_flexion_left': 'left_shoulder',
  'knee_flexion_right': 'right_knee',
  'knee_flexion_left': 'left_knee',
  'hip_flexion_right': 'right_hip',
  'hip_flexion_left': 'left_hip',
  'elbow_extension_right': 'right_elbow',
  'elbow_extension_left': 'left_elbow',
};

const List<String> kDefaultFixtures = <String>[
  'X2u_vGL0qJU',
  '-wwRNGArTI0',
  '0Ttn3z_rVBk',
];

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('kullanım: dart run tool/dump_angles.dart '
        '<çıktı.json> [fixtureId ...]');
    exit(64);
  }
  final String home = Platform.environment['HOME'] ?? '';
  final Directory lib = Directory('$home/motion-harvest/lissom/landmarks');
  final List<String> ids =
      args.length > 1 ? args.sublist(1) : kDefaultFixtures;

  final Map<String, dynamic> out = <String, dynamic>{};
  int skipped = 0;
  for (final String id in ids) {
    final File f = File('${lib.path}/$id.full.json');
    if (!f.existsSync()) {
      stderr.writeln('ATLANDI (dosya yok): $id');
      skipped++;
      continue;
    }
    final Fixture fx = Fixture.decode(f.readAsStringSync());
    final FrameSize? size = fx.recordingMeta.frameSize;
    if (size == null) {
      // Uydurma en-boy oranı KOYULMAZ (M-F-30): yanlış oran, düzeltmemiş
      // olmaktan kötüdür çünkü "düzeltildi" görünür.
      stderr.writeln('ATLANDI (resolution yok): $id');
      skipped++;
      continue;
    }
    final Map<String, Map<String, List<double?>>> byMode =
        <String, Map<String, List<double?>>>{};
    for (final String mode in <String>['raw', 'iso']) {
      final JointAngleExtractor ex =
          JointAngleExtractor(specs: StandardJoints.fullBody);
      final PoseNormalizer norm = PoseNormalizer();
      final Map<String, List<double?>> vals = <String, List<double?>>{
        for (final String m in kProbe.keys) m: <double?>[],
      };
      for (final PoseFrame fr in fx.frames) {
        final PoseFrame use = mode == 'iso' ? fr.toIsotropic(size) : fr;
        final JointAngleVector v = ex.extract(norm.normalize(use));
        for (final MapEntry<String, String> e in kProbe.entries) {
          vals[e.key]!.add(v.degreesById(e.value));
        }
      }
      byMode[mode] = vals;
    }
    out[id] = <String, dynamic>{
      'resolution': '${size.width}x${size.height}',
      'aspect': size.aspect,
      'frames': fx.frames.length,
      'raw': byMode['raw'],
      'iso': byMode['iso'],
    };
    stdout.writeln('$id: ${fx.frames.length} kare, '
        '${size.width}x${size.height}');
  }
  if (out.isEmpty) {
    stderr.writeln('HİÇ fixture okunamadı — ölçüm yapılmadı, boş rapor '
        'yazılmıyor (sessiz yeşil yasak)');
    exit(1);
  }
  File(args.first).writeAsStringSync(jsonEncode(out));
  stdout.writeln('yazıldı: ${args.first} '
      '(${out.length} fixture, $skipped atlandı)');
}
