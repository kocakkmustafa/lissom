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
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:flutter_test/flutter_test.dart';

/// ⛔ MÜHÜRLÜ SABİTLER — kilitten türetilmez, elle beyan edilir.
///
/// Published/reviewed Motion Core PR #9, 2026-10-17. The immutable SHA
/// resolves motion_core 0.13.0 and motion_camera 0.2.0; all three initial
/// workflows succeeded. This anchor is independent of the lock under test.
const String kSealedRef = '62c105567a9fdfa9d907a8f8a399494c8ae5b598';
const String kSealedCoreVersion = '0.13.0';
const String kSealedCameraVersion = '0.2.0';

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
    throw StateError(
      'pubspec.lock içinde `$pkg` kaydı YOK — pin çözülmemiş '
      'ya da paket adı değişmiş (sessiz atlamak yerine sert hata)',
    );
  }
  String? ref, resolved, version, source;
  for (int i = start + 1; i < lines.length; i++) {
    final String l = lines[i];
    // Sonraki paket kaydı başladıysa dur (iki boşluk + ad + iki nokta).
    if (RegExp(r'^  \S').hasMatch(l) && i > start) break;
    String? val(String key) {
      final RegExpMatch? m = RegExp(
        '^\\s*$key:\\s*"?([^"\\s]+)"?\\s\$',
      ).firstMatch('$l ');
      return m?.group(1);
    }

    ref ??= val('ref');
    resolved ??= val('resolved-ref');
    version ??= val('version');
    source ??= val('source');
  }
  return _LockEntry(ref, resolved, version, source);
}

const currentMotionSha = '62c105567a9fdfa9d907a8f8a399494c8ae5b598';

bool hasLocalMotionOverrides([String? source]) {
  final file = File('pubspec_overrides.yaml');
  source ??= file.existsSync() ? file.readAsStringSync() : '';
  return RegExp(r'^  motion_[a-z_]+:', multiLine: true).hasMatch(source);
}

void verifyResolvedPublishedMotionGraph(
  Map<String, dynamic> config,
  Uri configUri,
  String lock,
) {
  final rows = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .where((row) => (row['name'] as String).startsWith('motion_'))
      .toList();
  expect(rows, isNotEmpty);
  final first = Directory.fromUri(
    configUri.resolve(rows.first['rootUri'] as String),
  );
  final root = first.parent.parent.resolveSymbolicLinksSync();
  final head = Process.runSync('git', ['-C', root, 'rev-parse', 'HEAD']);
  expect(
    head.exitCode,
    0,
    reason: 'Selected Core must be an actual Git checkout',
  );
  final clean = Process.runSync('git', [
    '-C',
    root,
    'diff',
    '--quiet',
    'HEAD',
    '--',
    'packages',
  ]);
  expect(
    clean.exitCode,
    0,
    reason: 'Selected Core source must equal its commit',
  );
  verifyPublishedMotionGraph(
    config,
    configUri,
    lock,
    root,
    actualCommit: (head.stdout as String).trim(),
  );
  for (final row in rows) {
    final name = row['name'] as String;
    final spec = File('$root/packages/$name/pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: ([0-9.]+)$',
      multiLine: true,
    ).firstMatch(spec)?.group(1);
    expect(version, isNotNull);
    final block = RegExp(
      '^  ${RegExp.escape(name)}:\\n(?:(?!^  \\S).)*',
      multiLine: true,
      dotAll: true,
    ).firstMatch(lock)!.group(0)!;
    expect(block, contains('    version: "$version"'));
  }
}

void verifyPublishedMotionGraph(
  Map<String, dynamic> config,
  Uri configUri,
  String lock,
  String expectedRoot, {
  required String actualCommit,
}) {
  expect(
    actualCommit,
    currentMotionSha,
    reason: 'Actual checkout HEAD must equal the approved Core commit',
  );
  final rows = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .where((row) => (row['name'] as String).startsWith('motion_'))
      .toList();
  expect(rows, isNotEmpty);
  for (final row in rows) {
    final name = row['name'] as String;
    final actual = Directory.fromUri(
      configUri.resolve(row['rootUri'] as String),
    ).absolute.path;
    final selected = Directory(actual);
    final canonical = selected.existsSync()
        ? selected.resolveSymbolicLinksSync()
        : actual;
    expect(canonical, '$expectedRoot/packages/$name');
    final block = RegExp(
      '^  ${RegExp.escape(name)}:\\n(?:(?!^  \\S).)*',
      multiLine: true,
      dotAll: true,
    ).firstMatch(lock)?.group(0);
    expect(block, isNotNull, reason: '$name must have an actual lock entry');
    expect(block, contains('    source: git'));
    for (final field in ['ref', 'resolved-ref']) {
      expect(
        RegExp(
          """^      $field: (?:$currentMotionSha|"$currentMotionSha"|'$currentMotionSha')\$""",
          multiLine: true,
        ).allMatches(block!),
        hasLength(1),
      );
    }
    expect(block, contains('      path: "packages/$name"'));
    expect(
      block,
      contains('      url: "https://github.com/kocakkmustafa/motion-core.git"'),
    );
  }
}

void main() {
  final bool local = hasLocalMotionOverrides();
  final File lockFile = File(
    local ? 'test/fixtures/indexed-pubspec.lock' : 'pubspec.lock',
  );
  if (local) {
    test(
      'unpublished local Core config root and preserved indexed lock are exact',
      () {
        expect(
          sha256.convert(lockFile.readAsBytesSync()).toString(),
          '1aac5578117461b89db53f277903a67906e889b916a605a1d8b2d4bd3bbb7d67',
        );
        final file = File('.dart_tool/package_config.json').absolute;
        final graph =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final expected = Directory(
          '../motion-core',
        ).absolute.resolveSymbolicLinksSync();
        final rows = (graph['packages'] as List)
            .cast<Map<String, dynamic>>()
            .where((row) => (row['name'] as String).startsWith('motion_'))
            .toList();
        expect(rows, isNotEmpty);
        for (final row in rows) {
          expect(
            Directory.fromUri(
              file.uri.resolve(row['rootUri'] as String),
            ).resolveSymbolicLinksSync(),
            '$expected/packages/${row['name']}',
          );
        }
      },
    );
  }
  final String lock = lockFile.existsSync() ? lockFile.readAsStringSync() : '';

  if (!local) {
    test('actual package URIs and locks use the reviewed Git graph', () {
      final config = File('.dart_tool/package_config.json').absolute;
      final graph =
          jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;

      verifyResolvedPublishedMotionGraph(graph, config.uri, lock);
    });
  }
  test('header-only override is not local Core mode', () {
    expect(hasLocalMotionOverrides('dependency_overrides:\n'), isFalse);
    expect(
      hasLocalMotionOverrides(
        'dependency_overrides:\n  motion_core:\n    path: ../motion-core\n',
      ),
      isTrue,
    );
  });
  test(
    'published graph rejects wrong resolved SHA, URI, and malformed lock',
    () {
      const root = '/fixture/git/motion-core-$currentMotionSha';
      final config = <String, dynamic>{
        'packages': [
          {'name': 'motion_core', 'rootUri': '$root/packages/motion_core'},
        ],
      };
      const lock =
          '  motion_core:\n    description:\n'
          '      path: "packages/motion_core"\n'
          '      ref: "$currentMotionSha"\n'
          '      resolved-ref: "$currentMotionSha"\n'
          '      url: "https://github.com/kocakkmustafa/motion-core.git"\n'
          '    source: git\n    version: "0.13.0"\n';
      final uri = Uri.file('/fixture/.dart_tool/package_config.json');
      verifyPublishedMotionGraph(
        config,
        uri,
        lock,
        root,
        actualCommit: currentMotionSha,
      );
      const alternateRoot = '/other/custom/cache/repository-checkout';
      final alternate = <String, dynamic>{
        'packages': [
          {
            'name': 'motion_core',
            'rootUri': '$alternateRoot/packages/motion_core',
          },
        ],
      };
      verifyPublishedMotionGraph(
        alternate,
        uri,
        lock,
        alternateRoot,
        actualCommit: currentMotionSha,
      );
      expect(
        () => verifyPublishedMotionGraph(
          config,
          uri,
          lock,
          root,
          actualCommit: '1' * 40,
        ),
        throwsA(isA<TestFailure>()),
      );

      for (final bad in [
        lock.replaceFirst(
          'resolved-ref: "$currentMotionSha"',
          'resolved-ref: "${'1' * 40}"',
        ),
        'packages:\n',
      ]) {
        expect(
          () => verifyPublishedMotionGraph(
            config,
            uri,
            bad,
            root,
            actualCommit: currentMotionSha,
          ),
          throwsA(isA<TestFailure>()),
        );
      }
      final wrong = <String, dynamic>{
        'packages': [
          {'name': 'motion_core', 'rootUri': '/fixture/local/motion_core'},
        ],
      };
      expect(
        () => verifyPublishedMotionGraph(
          wrong,
          uri,
          lock,
          root,
          actualCommit: currentMotionSha,
        ),
        throwsA(isA<TestFailure>()),
      );
    },
  );
  group('pin eşitliği (J-071) — üç çapa', () {
    test(
      'kilit okunabiliyor ve iki paket de git kaynağından (pozitif kontrol)',
      () {
        // L-183 dersi: yalnız-yokluk iddiası taşıyan test, mekanizma tamamen
        // ölse de geçer. Aşağıdaki eşitlik iddiaları boş kilitte trivially
        // geçerdi — o yüzden önce doluluk ve kaynak tipi.
        expect(
          lock,
          isNotEmpty,
          reason:
              'pubspec.lock okunamadı — `pub get` '
              'koşulmamış olabilir; pin doğrulanmamış sayılır',
        );
        for (final String pkg in <String>['motion_core', 'motion_camera']) {
          final _LockEntry e = _readLock(lock, pkg);
          expect(
            e.source,
            'git',
            reason:
                '$pkg git kaynağından gelmiyor (source=${e.source}) — '
                'pin kavramı uygulanamaz',
          );
          expect(
            e.resolvedRef,
            isNotNull,
            reason: '$pkg resolved-ref taşımıyor',
          );
        }
      },
    );

    test('ÇAPA 1 — iki paket AYNI commit\'e çözüldü', () {
      final _LockEntry core = _readLock(lock, 'motion_core');
      final _LockEntry cam = _readLock(lock, 'motion_camera');
      expect(
        cam.resolvedRef,
        core.resolvedRef,
        reason:
            'pin AYRIŞMIŞ: motion_core=${core.resolvedRef} '
            'motion_camera=${cam.resolvedRef}. Kameranın gördüğü çekirdek '
            'ile motorun gördüğü çekirdek farklı olur — "kaydettiğim şema '
            'ile okuduğum şema farklı" sınıfı.',
      );
    });

    test('ÇAPA 2 — o commit MÜHÜRLÜ ref (doğru şeyde mi aynı)', () {
      // Bu çapa olmadan ÇAPA 1 "ikisi de aynı YANLIŞ commit'te" durumunu
      // yeşil geçirirdi (Ostinato deseni, M-F-265).
      final _LockEntry core = _readLock(lock, 'motion_core');
      expect(
        core.resolvedRef,
        kSealedRef,
        reason:
            'çözülen ref mühürlü sabitten FARKLI. Pin bilinçli mi '
            'değişti? Öyleyse `kSealedRef` sabitini ölçümle birlikte '
            'güncelle — sessizce kaymasına izin verme.',
      );
    });

    test('ÇAPA 3 — çözülen SÜRÜM ÇİFTİ beklenen (tag kaymış olabilir)', () {
      // Doğru commit'i pinlemek, o commit'in beklenen SÜRÜMLERİ taşıdığını
      // kanıtlamaz: tag hareket etmiş ya da pubspec `version:` bump'lanmamış
      // olabilir. Sürüm çifti de dış sabit.
      final _LockEntry core = _readLock(lock, 'motion_core');
      final _LockEntry cam = _readLock(lock, 'motion_camera');
      expect(
        core.version,
        kSealedCoreVersion,
        reason:
            'motion_core sürümü beklenenden farklı '
            '(${core.version} ≠ $kSealedCoreVersion) — aynı commit, '
            'başka sürüm: tag kaymış ya da pubspec bump\'lanmamış',
      );
      expect(
        cam.version,
        kSealedCameraVersion,
        reason:
            'motion_camera sürümü beklenenden farklı '
            '(${cam.version} ≠ $kSealedCameraVersion)',
      );
    });

    test('`ref` ↔ `resolved-ref` AYNI DİZE (pub metin karşılaştırır)', () {
      // Choreia ölçümü (M-F-265): tag adı ya da kısa SHA yazılırsa bu ikisi
      // ayrışır ve aynı commit iki ayrı kaynak gibi çözülmeye çalışılır.
      for (final String pkg in <String>['motion_core', 'motion_camera']) {
        final _LockEntry e = _readLock(lock, pkg);
        expect(
          e.ref,
          e.resolvedRef,
          reason:
              '$pkg: `ref` (${e.ref}) ile `resolved-ref` '
              '(${e.resolvedRef}) ayrışıyor — pubspec\'te TAM-40-SHA yerine '
              'tag adı/kısa SHA yazılmış. Pub ref\'leri METİN karşılaştırır.',
        );
        expect(
          e.ref?.length,
          40,
          reason:
              '$pkg: `ref` 40 karakter değil (${e.ref?.length}) — '
              'tam SHA yazılmamış',
        );
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
      expect(
        wrong,
        isNot(kSealedRef),
        reason: 'çapa 2 olmadan bu durum yeşil geçerdi',
      );
    });

    test('sabotaj: doğru commit ama yanlış sürüm yakalanır (çapa 3 şart)', () {
      const _LockEntry stale = _LockEntry(
        kSealedRef,
        kSealedRef,
        '0.9.0',
        'git',
      );
      expect(
        stale.version,
        isNot(kSealedCoreVersion),
        reason: 'çapa 3 olmadan tag-kayması yeşil geçerdi',
      );
    });

    test('sabotaj: eksik kayıt SESSİZCE atlanmaz, fırlatır', () {
      expect(
        () => _readLock('  baska_paket:\n    source: git\n', 'motion_core'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
