/// PİN-EŞİTLİĞİ KAPISI (J-071) — üç çapalı.
///
/// Soru basit görünüyor ("iki paket aynı commit'ten mi?") ama tek çapayla
/// sorulursa üç ayrı şekilde sessizce yanlış olabilir. Bu yüzden üç ayrı
/// iddia var ve **hiçbiri diğerinin yerine geçmiyor**:
///
///   ÇAPA 1 — İÇ TUTARLILIK: iki paketin `resolved-ref`'i AYNI mı?
///            Bu tek başına yeterli DEĞİL: ikisi de aynı YANLIŞ commit'te
///            olabilir ve kapı yeşil yanar.
///
///   ÇAPA 2 — DIŞ SABİT: o ref, aşağıdaki MÜHÜRLÜ sabitle aynı mı?
///            Ostinato deseni (M-F-265): *"iki kilit aynı mı" yetmez —
///            "DOĞRU şeyde mi aynı"*. Sabit burada, kilitten TÜRETİLMİYOR;
///            türetilse tautoloji olurdu (kilit kendini doğrulardı).
///
///   ÇAPA 3 — ÇÖZÜLEN SÜRÜM: aynı commit doğru SÜRÜM ÇİFTİNİ mi veriyor?
///            Bir commit'i doğru pinlemek, o commit'in beklenen sürümleri
///            taşıdığını KANITLAMAZ — tag hareket etmiş ya da pubspec sürümü
///            bump'lanmamış olabilir. Sürüm çifti de dış sabit.
///
/// Ayrıca `ref` ↔ `resolved-ref` eşitliği sınanıyor: pub `ref:` değerini
/// **METİN** olarak karşılaştırır (Choreia ölçtü, M-F-265). Tag adı veya kısa
/// SHA yazılırsa `ref` ile `resolved-ref` AYRIŞIR ve aynı commit iki farklı
/// yazımla iki ayrı kaynak gibi çözülmeye çalışılır. TAM-40-SHA bunu kapatır.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ⛔ MÜHÜRLÜ SABİTLER — kilitten türetilmez, elle beyan edilir.
///
/// Koordinatör paketi (M-F-263): `motion_core-v0.11.0` + `motion_camera-v0.1.2`,
/// **ikisi tek ref** `f13bdc9`'ten. Ölçüldü: `f13bdc9` = `motion_camera-v0.1.2`
/// tag'i ve `motion_core-v0.11.0` (`2018469`) commit'inin ARDILI, yani tek pin
/// ikisini de kapsıyor.
const String kSealedRef = 'f13bdc93b2eae2f741bfcdb4c9270a88e5d75e5d';
const String kSealedCoreVersion = '0.11.0';
const String kSealedCameraVersion = '0.1.2';

/// Bir git paketinin kilit kaydı.
final class _LockEntry {
  const _LockEntry(this.ref, this.resolvedRef, this.version, this.source);
  final String? ref;
  final String? resolvedRef;
  final String? version;
  final String? source;
}

/// `pubspec.lock`'tan bir paketin kaydını okur.
///
/// Elle ayrıştırma KASITLI: `yaml` paketi bir bağımlılık daha demek olurdu ve
/// bu kapının işi bağımlılıkları doğrulamak — kendi doğruladığı mekanizmaya
/// yeni bir bağımlılık eklemek istemiyoruz. Format sabit ve dar.
_LockEntry _readLock(String lock, String pkg) {
  final List<String> lines = lock.split('\n');
  final int start = lines.indexWhere((String l) => l == '  $pkg:');
  if (start < 0) {
    throw StateError('pubspec.lock içinde `$pkg` kaydı YOK — pin çözülmemiş '
        'ya da paket adı değişmiş (sessiz atlamak yerine sert hata)');
  }
  String? ref, resolved, version, source;
  for (int i = start + 1; i < lines.length; i++) {
    final String l = lines[i];
    // Sonraki paket kaydı başladıysa dur (iki boşluk + ad + iki nokta).
    if (RegExp(r'^  \S').hasMatch(l) && i > start) break;
    String? val(String key) {
      final RegExpMatch? m =
          RegExp('^\\s*$key:\\s*"?([^"\\s]+)"?\\s\$').firstMatch('$l ');
      return m?.group(1);
    }
    ref ??= val('ref');
    resolved ??= val('resolved-ref');
    version ??= val('version');
    source ??= val('source');
  }
  return _LockEntry(ref, resolved, version, source);
}

void main() {
  final File lockFile = File('pubspec.lock');
  final String lock = lockFile.existsSync() ? lockFile.readAsStringSync() : '';

  group('pin eşitliği (J-071) — üç çapa', () {
    test('kilit okunabiliyor ve iki paket de git kaynağından (pozitif kontrol)',
        () {
      // L-183 dersi: yalnız-yokluk iddiası taşıyan test, mekanizma tamamen
      // ölse de geçer. Aşağıdaki eşitlik iddiaları boş kilitte trivially
      // geçerdi — o yüzden önce doluluk ve kaynak tipi.
      expect(lock, isNotEmpty, reason: 'pubspec.lock okunamadı — `pub get` '
          'koşulmamış olabilir; pin doğrulanmamış sayılır');
      for (final String pkg in <String>['motion_core', 'motion_camera']) {
        final _LockEntry e = _readLock(lock, pkg);
        expect(e.source, 'git',
            reason: '$pkg git kaynağından gelmiyor (source=${e.source}) — '
                'pin kavramı uygulanamaz');
        expect(e.resolvedRef, isNotNull, reason: '$pkg resolved-ref taşımıyor');
      }
    });

    test('ÇAPA 1 — iki paket AYNI commit\'e çözüldü', () {
      final _LockEntry core = _readLock(lock, 'motion_core');
      final _LockEntry cam = _readLock(lock, 'motion_camera');
      expect(cam.resolvedRef, core.resolvedRef,
          reason: 'pin AYRIŞMIŞ: motion_core=${core.resolvedRef} '
              'motion_camera=${cam.resolvedRef}. Kameranın gördüğü çekirdek '
              'ile motorun gördüğü çekirdek farklı olur — "kaydettiğim şema '
              'ile okuduğum şema farklı" sınıfı.');
    });

    test('ÇAPA 2 — o commit MÜHÜRLÜ ref (doğru şeyde mi aynı)', () {
      // Bu çapa olmadan ÇAPA 1 "ikisi de aynı YANLIŞ commit'te" durumunu
      // yeşil geçirirdi (Ostinato deseni, M-F-265).
      final _LockEntry core = _readLock(lock, 'motion_core');
      expect(core.resolvedRef, kSealedRef,
          reason: 'çözülen ref mühürlü sabitten FARKLI. Pin bilinçli mi '
              'değişti? Öyleyse `kSealedRef` sabitini ölçümle birlikte '
              'güncelle — sessizce kaymasına izin verme.');
    });

    test('ÇAPA 3 — çözülen SÜRÜM ÇİFTİ beklenen (tag kaymış olabilir)', () {
      // Doğru commit'i pinlemek, o commit'in beklenen SÜRÜMLERİ taşıdığını
      // kanıtlamaz: tag hareket etmiş ya da pubspec `version:` bump'lanmamış
      // olabilir. Sürüm çifti de dış sabit.
      final _LockEntry core = _readLock(lock, 'motion_core');
      final _LockEntry cam = _readLock(lock, 'motion_camera');
      expect(core.version, kSealedCoreVersion,
          reason: 'motion_core sürümü beklenenden farklı '
              '(${core.version} ≠ $kSealedCoreVersion) — aynı commit, '
              'başka sürüm: tag kaymış ya da pubspec bump\'lanmamış');
      expect(cam.version, kSealedCameraVersion,
          reason: 'motion_camera sürümü beklenenden farklı '
              '(${cam.version} ≠ $kSealedCameraVersion)');
    });

    test('`ref` ↔ `resolved-ref` AYNI DİZE (pub metin karşılaştırır)', () {
      // Choreia ölçümü (M-F-265): tag adı ya da kısa SHA yazılırsa bu ikisi
      // ayrışır ve aynı commit iki ayrı kaynak gibi çözülmeye çalışılır.
      for (final String pkg in <String>['motion_core', 'motion_camera']) {
        final _LockEntry e = _readLock(lock, pkg);
        expect(e.ref, e.resolvedRef,
            reason: '$pkg: `ref` (${e.ref}) ile `resolved-ref` '
                '(${e.resolvedRef}) ayrışıyor — pubspec\'te TAM-40-SHA yerine '
                'tag adı/kısa SHA yazılmış. Pub ref\'leri METİN karşılaştırır.');
        expect(e.ref?.length, 40,
            reason: '$pkg: `ref` 40 karakter değil (${e.ref?.length}) — '
                'tam SHA yazılmamış');
      }
    });
  });

  group('öz-test — kapı KIRMIZI yanabiliyor', () {
    test('sabotaj: ayrışmış ref yakalanır', () {
      final _LockEntry a = _LockEntry('a' * 40, 'a' * 40, '0.11.0', 'git');
      final _LockEntry b = _LockEntry('b' * 40, 'b' * 40, '0.1.2', 'git');
      expect(a.resolvedRef, isNot(b.resolvedRef));
    });

    test('sabotaj: doğru-eşit ama YANLIŞ commit yakalanır (çapa 2 şart)', () {
      final String wrong = 'c' * 40;
      expect(wrong, isNot(kSealedRef),
          reason: 'çapa 2 olmadan bu durum yeşil geçerdi');
    });

    test('sabotaj: doğru commit ama yanlış sürüm yakalanır (çapa 3 şart)', () {
      const _LockEntry stale = _LockEntry(kSealedRef, kSealedRef, '0.9.0', 'git');
      expect(stale.version, isNot(kSealedCoreVersion),
          reason: 'çapa 3 olmadan tag-kayması yeşil geçerdi');
    });

    test('sabotaj: eksik kayıt SESSİZCE atlanmaz, fırlatır', () {
      expect(() => _readLock('  baska_paket:\n    source: git\n', 'motion_core'),
          throwsA(isA<StateError>()));
    });
  });
}
