/// **CİHAZDA ÇÖKEN, TESTTE YEŞİL KALAN SINIF (L-272).**
///
/// Choreia'nın tuzağı: sahte bundle **dosya sistemini** okuyup `pubspec`'i
/// umursamıyordu → yüzey *"başlatılabilir"* dedi, basınca gerçek `rootBundle`
/// **patladı** (`Unable to load asset:` — dosya diskte var, `pubspec`'te
/// **beyansız**).
///
/// Aynı asimetri `AssetBundle.loadString`, `ContentBundleLoader` ve modelin
/// bundle→dosya hazırlamasında da vardır. Bu kapı literal yükleme yollarını,
/// içerik manifestinin doğruladığı yolları ve model pinini birlikte tarar;
/// diskten okuyan testin paketlenmemiş varlığı görmezden gelmesini önler.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/surfaces.dart';

/// `pubspec`'in `assets:` bloğu — **tek adres**.
List<String> declaredAssets() {
  final List<String> out = <String>[];
  bool inAssets = false;
  for (final String line in File('pubspec.yaml').readAsLinesSync()) {
    if (RegExp(r'^\s*assets:\s*$').hasMatch(line)) {
      inAssets = true;
      continue;
    }
    if (!inAssets) continue;
    final RegExpMatch? m = RegExp(r'^\s*-\s*(\S+)\s*$').firstMatch(line);
    if (m != null) {
      out.add(m.group(1)!);
    } else if (line.trim().isNotEmpty && !line.trimLeft().startsWith('#')) {
      break; // blok bitti
    }
  }
  return out;
}

/// Bundle'dan okunan literal yollar ve manifestteki içerik yolları.
List<String> runtimeAssetPaths() {
  final Set<String> paths = <String>{'assets/motion_content/manifest.json'};
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final String source = f.readAsStringSync();
    paths.addAll(
      RegExp(
        r"\.load(?:String)?\(\s*'([^']+)'",
      ).allMatches(source).map((RegExpMatch m) => m.group(1)!),
    );
    if (source.contains('rootBundle.load')) {
      paths.addAll(
        RegExp(
          r"const String kPoseModelAsset\s*=\s*'([^']+)'",
        ).allMatches(source).map((RegExpMatch m) => m.group(1)!),
      );
    }
  }
  final Object? manifest = jsonDecode(
    File('assets/motion_content/manifest.json').readAsStringSync(),
  );
  if (manifest is! Map || manifest['assets'] is! List) {
    throw const FormatException('Content manifest has no asset list');
  }
  for (final Object? entry in manifest['assets'] as List) {
    if (entry is! Map || entry['path'] is! String) {
      throw const FormatException('Content manifest has an invalid path');
    }
    paths.add(entry['path'] as String);
  }
  return paths.toList()..sort();
}

/// Kabukta bir kamera/capture yolu var mı — **tek adres**, `os_layer_test`in
/// yüklemiyle aynı desen (ikisi ayrışırsa iki kapı farklı dünyayı ölçer).
bool hasCapturePath() {
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final String src = File(
      f.path,
    ).readAsStringSync().replaceAll(RegExp(r'//[^\n]*'), ' ');
    if (RegExp(
      r'\bCameraController\b|\bmotion_camera\b|\bstartImageStream\b',
    ).hasMatch(src)) {
      return true;
    }
  }
  return false;
}

bool _covered(String path, List<String> declared) => declared.any(
  (String d) => d == path || (d.endsWith('/') && path.startsWith(d)),
);

void main() {
  test('POZİTİF İKİZ: iki çıkarıcı da GERÇEKTEN buluyor', () {
    // L-255: aşağıdaki iddia bir yokluk; boş listelerde vakum-doğru olur.
    expect(
      declaredAssets(),
      isNotEmpty,
      reason:
          'BULUCU BOZUK: pubspec\'te `assets:` bloğu okunamadı — '
          '"her yol beyanlı" iddiası hiçbir şey kanıtlamaz',
    );
    expect(
      runtimeAssetPaths(),
      contains('config/ia/library.v1.json'),
      reason: 'BULUCU BOZUK: AssetBundle.loadString yolu bulunamadı',
    );
    expect(
      runtimeAssetPaths(),
      contains('config/courses/hatha.v1.json'),
      reason: 'BULUCU BOZUK: manifestteki kurs yolu bulunamadı',
    );
    expect(
      runtimeAssetPaths(),
      contains('assets/models/pose_landmarker_full.v1.task'),
      reason: 'BULUCU BOZUK: model hazırlama yolu bulunamadı',
    );
    // Ve kapsam yüklemi çalışıyor mu?
    expect(_covered('config/ia/x.json', <String>['config/ia/']), isTrue);
    expect(_covered('config/copy/x.json', <String>['config/ia/']), isFalse);
  });

  test('bundle ile okunan HER yol pubspec\'te BEYANLI', () {
    final List<String> declared = declaredAssets();
    final List<String> missing = runtimeAssetPaths()
        .where((String p) => !_covered(p, declared))
        .toList();
    expect(
      missing,
      isEmpty,
      reason:
          'Bu yollar cihazda `Unable to load asset` ile ÇÖKER, ama '
          'testler YEŞİL kalır — çünkü testler diskten, cihaz bundle\'dan '
          'okuyor:\n  ${missing.join("\n  ")}\n\n'
          'pubspec `assets:` bloğuna ekleyin.',
    );
  });

  test('KAMERA İZNİ, CAPTURE YOLUNA BAĞLI — anahtar tek başına eklenmez', () {
    // ⚠️ Koordinatör *"NSCameraUsageDescription yok, tek başına yayın
    // engeli, birinci sıraya koy"* dedi. Ekledim ve **kendi kapım
    // reddetti** (`os_layer_test`, L-250):
    //
    // > *capture yolu yokken kamera izni beyan edilmiş — kullanılmayan bir
    // > yetenek beyanı, kullanıcıya olmayan bir şeyi anlatır*
    //
    // Kapı haklıydı. Bugün `lib/` içinde hiçbir capture yolu yok; izin metni
    // eklemek **olmayan bir yeteneği beyan etmek** olurdu — bu gece yedi
    // yüzeyde düzelttiğim sınıfın (L-262) ta kendisi. Ve iOS izin diyaloğu,
    // uygulamanın **dışına çıkan ilk cümlesidir**.
    //
    // Anahtar bağımsız bir engel DEĞİL, kameraya **bağlı**: `os_layer_test`
    // eşlemeyi iki yönde de tutuyor, yani kamerayı bağlayan commit anahtarı
    // eklemeden yeşil geçemez. Burada o KAPININ VARLIĞINI çiviliyorum —
    // eşleme silinirse ikisi birden sessizce ayrışır.
    final String gate = File('test/os_layer_test.dart').readAsStringSync();
    expect(
      gate,
      contains('NSCameraUsageDescription'),
      reason: 'OS katmanı kapısı izin anahtarını artık anmıyor',
    );
    expect(
      gate,
      contains('capture'),
      reason:
          'Eşleme kaybolmuş: kapı artık capture yolu ile izin metnini '
          'BİRLİKTE ölçmüyor. Kamerayı bağlayan commit, izin metnini '
          'eklemeden yeşil geçebilir hâle gelir — ve o build cihazda '
          'ANINDA çöker.',
    );
  });

  test('POZ MODELİ, CAPTURE YOLUNA BAĞLI — model yoksa kamera BAŞLAMAZ', () {
    // Koordinatör ölçümü (12:13) ve kendi kapımla doğrulandı:
    //   `.task` dosyası YOK · pubspec beyanı 0 · `tool/fetch_*` YOK ·
    //   `path_provider` bağımlılıkta ama YALNIZ geçmiş dosyası için.
    //
    // `motion_camera` modeli **kasıtlı taşımıyor**:
    //   "the plugin deliberately bundles no model (apps pin their own and
    //    ship it as an asset)"
    // ⚠️ Ve sözleşme `modelPath` için **MUTLAK DOSYA YOLU** istiyor, bundle
    // anahtarı DEĞİL → `pubspec`'e eklemek YETMEZ; bundle→dosya sistemi bir
    // **hazırlama adımı** gerekiyor.
    //
    // Bu, izin anahtarıyla AYNI eşleme: bugün capture yolu yok, o yüzden
    // model de gerekmiyor — ama kamerayı bağlayan commit modeli VE hazırlama
    // adımını getirmeden yeşil geçemez. Üç kardeş hat bunu çözmüş; bu bir
    // bilinmezlik değil, YAPILMAMIŞ İŞ.
    if (!hasCapturePath()) {
      // Simetrik yön: capture yokken 8 MB'lık bir model taşımak da gürültü.
      return;
    }
    final List<String> declared = declaredAssets();
    expect(
      declared.any((String d) => d.endsWith('.task') || d.endsWith('/')),
      isTrue,
      reason:
          'Kamera yolu var ama `pubspec` hiçbir `.task` modeli beyan '
          'etmiyor — kamera cihazda HİÇ BAŞLAMAZ.',
    );
    expect(
      Directory('.')
          .listSync(recursive: true)
          .whereType<File>()
          .any(
            (File f) => f.path.endsWith('.task') && !f.path.contains('/build/'),
          ),
      isTrue,
      reason:
          'Model dosyası depoda yok. `tool/fetch_pose_model.sh` gibi '
          'bir getirme adımı ve pin\'li bir model gerekiyor.',
    );
    final bool materializes = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .any((File f) {
          final String src = f.readAsStringSync();
          return src.contains('rootBundle.load') &&
              RegExp(
                r'getApplicationSupportDirectory|getTemporaryDirectory',
              ).hasMatch(src);
        });
    expect(
      materializes,
      isTrue,
      reason:
          'Model `pubspec`\'te beyanlı olabilir ama plugin MUTLAK YOL '
          'istiyor. Bundle→dosya sistemi hazırlama adımı (bundle\'dan oku, '
          'destek dizinine yaz, o yolu ver) YOK — kamera başlamaz.',
    );
  });

  test('İKİ KAYNAK TEK OLGU: limitsCopy config\'ten sapmamış', () {
    // `limitsCopy` config'ten ELLE taşınmış bir kopya (doc'u "BİREBİR"
    // diyor). İki kaynak ayrışır; kapı ayrışmayı tutuyor (L-256).
    final Map<String, dynamic> d =
        jsonDecode(File('config/copy/disclaimers.en.json').readAsStringSync())
            as Map<String, dynamic>;
    final String conf =
        ((d['disclaimers'] as Map<String, dynamic>)['measurementLimits']
                as Map<String, dynamic>)['text']
            as String;
    expect(
      conf.length,
      greaterThan(50),
      reason:
          'pozitif çapa: config metni okunamadı, karşılaştırma '
          'vakum-doğru olurdu',
    );
    expect(
      MeasurementLimitsFootnote.limitsCopy.trim(),
      conf.trim(),
      reason:
          'Yüzeydeki metin config\'ten SAPMIŞ. Doc "BİREBİR" diyor; '
          'iki kaynak tek olguyu taşıyorsa biri bayatlar.',
    );
  });
}
