import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/lesson_media.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/local_owner_context.dart';
import 'package:motion_content/motion_content.dart';
import 'package:video_player/video_player.dart';

final class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);

  final Map<String, Uint8List> files;
  int reads = 0;
  int mediaReads = 0;

  @override
  Future<ByteData> load(String key) async {
    reads++;
    if (key.startsWith('content/media/')) mediaReads++;
    final bytes = files[key];
    if (bytes == null) throw FlutterError('Missing test asset $key');
    return ByteData.sublistView(bytes);
  }
}

final class _FakeController extends VideoPlayerController {
  _FakeController(super.dataSource) : super.asset();

  bool retired = false;
  bool failNativeMute = false;
  bool failNativePlay = false;
  bool failNativeDispose = false;
  int initializeCalls = 0;
  int muteCalls = 0;
  int playCalls = 0;
  int pauseCalls = 0;
  int disposeCalls = 0;
  Completer<void>? initializeGate;
  Completer<void>? initialMuteGate;
  Completer<void>? verifiedMuteGate;
  Completer<void>? prePlayMuteGate;
  Completer<void>? pauseGate;
  Completer<void>? playGate;
  Completer<void>? disposeGate;
  VoidCallback? onPlay;

  @override
  Future<void> initialize() async {
    initializeCalls++;
    await initializeGate?.future;
    value = VideoPlayerValue(
      duration: Duration(milliseconds: 1000),
      size: Size(16, 9),
      isInitialized: true,
      volume: value.volume,
    );
  }

  @override
  Future<void> setVolume(double volume) async {
    muteCalls++;
    if (muteCalls == 1) await initialMuteGate?.future;
    if (value.isInitialized && failNativeMute) {
      throw StateError('native mute failed');
    }
    if (muteCalls == 2) await verifiedMuteGate?.future;
    if (muteCalls >= 3) await prePlayMuteGate?.future;
    value = value.copyWith(volume: volume);
  }

  @override
  Future<void> play() async {
    playCalls++;
    if (value.volume != 0) throw StateError('unmuted playback');
    onPlay?.call();
    if (failNativePlay) throw StateError('native play failed');
    await playGate?.future;
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    value = value.copyWith(isPlaying: false);
    await pauseGate?.future;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await disposeGate?.future;
    if (failNativeDispose) throw StateError('native disposal failed');
    retired = true;
    await super.dispose();
  }
}

Uint8List _bytes(List<int> values) => Uint8List.fromList(values);
String _hex(String character) => List<String>.filled(64, character).join();
LessonMediaFile _file(String path, Uint8List bytes) => LessonMediaFile(
  path: path,
  bytes: bytes.length,
  sha256: computeSha256Hex(bytes),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final courseBytes = File('config/courses/hatha.v1.json').readAsBytesSync();
  final sourcePinBytes = File(
    'assets/motion_content/lissom_source_pins_v2k.json',
  ).readAsBytesSync();
  final course = HathaCourse.parse(utf8.decode(courseBytes));
  const stem =
      'lissom/h01--971eaed0/orientation--f791116136f8bfede536c98ccb67f5a941c020bed06482d973fe2a808e2e56b8--master-format-pending';
  const videoPath = 'content/media/$stem.mp4';
  const trPath = 'content/media/$stem.tr.vtt';
  const enPath = 'content/media/$stem.en.vtt';
  final video = _bytes(<int>[
    0,
    0,
    0,
    16,
    102,
    116,
    121,
    112,
    105,
    115,
    111,
    109,
    0,
    0,
    0,
    0,
  ]);
  final tr = _bytes(
    utf8.encode(
      'WEBVTT - Motion locale=tr\n\n00:00:00.000 --> 00:00:01.000\nBaşla\n',
    ),
  );
  final en = _bytes(
    utf8.encode(
      'WEBVTT - Motion locale=en\n\n00:00:00.000 --> 00:00:01.000\nStart\n',
    ),
  );

  _Bundle bundle() => _Bundle(<String, Uint8List>{
    'config/courses/hatha.v1.json': _bytes(courseBytes),
    'assets/motion_content/lissom_source_pins_v2k.json': _bytes(sourcePinBytes),
    videoPath: video,
    trPath: tr,
    enPath: en,
  });

  LessonMediaCandidate candidate({
    String app = 'lissom',
    String lessonId = 'h01',
    String assetId = 'lissom.h01.v3.demo',
    String? lessonSha,
    String? sourceSha,
    String productionIndexSha =
        'd887683c9a9b9bdb8d4ab7c51cdc5a5b4b4de6a918079e4cfd9cf543e9751e60',
    String sceneId = 'lissom:h01:orientation',
    String variantStem = stem,
    String specSha =
        'f791116136f8bfede536c98ccb67f5a941c020bed06482d973fe2a808e2e56b8',
    String cueSha =
        '7930eba55b1c6781022700432fdfb2f050f933f9506afac347bdd1838a5f7fd4',
    String idempotencyKey =
        'motion-media-v1:f791116136f8bfede536c98ccb67f5a941c020bed06482d973fe2a808e2e56b8',
    String productionState = 'PREPRODUCTION_UNGENERATED',
    String sourcePinSha =
        '0dd31549e0c897d4f1706842dee070603f3da9f71b61815b5d2fb1be6b74522b',
    String? mediaSha,
    LessonMediaFile? videoFile,
    Map<String, LessonMediaFile>? captionFiles,
    int durationMs = 1000,
  }) => LessonMediaCandidate(
    app: app,
    lessonId: lessonId,
    courseVersion: course.version,
    courseSourceSha256: sourceSha ?? computeSha256Hex(_bytes(courseBytes)),
    lessonCanonicalSha256:
        lessonSha ??
        '124809f6fb681ef4cee6792ae1b0a4969ea4a268d234fc710f120e5dd4094874',
    assetId: assetId,
    productionIndexSha256: productionIndexSha,
    sceneId: sceneId,
    variantStem: variantStem,
    productionSpecSha256: specSha,
    sourceCueSha256: cueSha,
    idempotencyKey: idempotencyKey,
    productionState: productionState,
    sourcePinSha256: sourcePinSha,
    durationMs: durationMs,
    video:
        videoFile ??
        LessonMediaFile(
          path: 'content/media/$variantStem.mp4',
          bytes: video.length,
          sha256: mediaSha ?? computeSha256Hex(video),
        ),
    captions:
        captionFiles ??
        <String, LessonMediaFile>{
          'tr': _file('content/media/$variantStem.tr.vtt', tr),
          'en': _file('content/media/$variantStem.en.vtt', en),
        },
  );

  test('v2k QA source catalog is packaged with the Flutter bundle', () async {
    final data = await rootBundle.load(
      'assets/motion_content/lissom_source_pins_v2k.json',
    );
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    expect(computeSha256Hex(bytes), lissomMediaSourceCatalogSha256);
  });

  test('same-name media under another root is rejected before reads', () async {
    final misplaced = <String, LessonMediaCandidate>{
      'video': candidate(videoFile: _file('other/$stem.mp4', video)),
      'caption': candidate(
        captionFiles: <String, LessonMediaFile>{
          'tr': _file('other/$stem.tr.vtt', tr),
          'en': _file(enPath, en),
        },
      ),
    };
    for (final entry in misplaced.entries) {
      final assets = bundle()
        ..files[entry.value.video.path] = video
        ..files[entry.value.captions['tr']!.path] = tr;
      final media =
          await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
            entry.value,
          ]).inspect(
            bundle: assets,
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
          );
      expect(media, isNull, reason: entry.key);
      expect(assets.reads, 0, reason: entry.key);
    }
  });

  test('caption metadata cannot change after candidate creation', () async {
    final supplied = <String, LessonMediaFile>{
      'tr': _file(trPath, tr),
      'en': _file(enPath, en),
    };
    final claim = candidate(captionFiles: supplied);
    supplied['tr'] = _file('other/$stem.tr.vtt', tr);
    expect(claim.captions['tr']!.path, trPath);
    expect(
      () => claim.captions['tr'] = _file('other/$stem.tr.vtt', tr),
      throwsUnsupportedError,
    );
    final assets = bundle()..files['other/$stem.tr.vtt'] = tr;
    final media =
        await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          claim,
        ]).inspect(
          bundle: assets,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        );
    expect(media, isNotNull);
    expect(media!.captionText, contains('Başla'));
    expect(assets.mediaReads, 3);
  });

  test(
    'shipping catalog stays empty and never reads packaged assets',
    () async {
      final assets = bundle();
      final result = await const LessonMediaCatalog.empty().inspect(
        bundle: assets,
        course: course,
        lessonId: 'h01',
        sceneId: 'lissom:h01:orientation',
        variantStem: stem,
        locale: 'tr',
      );
      expect(result, isNull);
      expect(assets.reads, 0);
    },
  );

  test(
    'synthetic media verifies course/video/both captions before playback',
    () async {
      final assets = bundle();
      final media =
          await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
            candidate(),
          ]).inspect(
            bundle: assets,
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
          );
      expect(media, isNotNull);
      expect(media!.captionText, contains('Başla'));
      expect(media.visible, isFalse);
      expect(media.releaseEligible, isFalse);
      expect(media.progressEffect, 0);
    },
  );

  test(
    'stale source, wrong media bytes, missing locale and unsafe path fail closed',
    () async {
      final stale = LessonMediaCatalog.syntheticForTesting(
        <LessonMediaCandidate>[candidate(sourceSha: _hex('0'))],
      );
      expect(
        await stale.inspect(
          bundle: bundle(),
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        ),
        isNull,
      );
      final altered = bundle()..files[videoPath] = _bytes(<int>[1, 2, 3]);
      final valid = LessonMediaCatalog.syntheticForTesting(
        <LessonMediaCandidate>[candidate()],
      );
      expect(
        await valid.inspect(
          bundle: altered,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        ),
        isNull,
      );
      expect(
        await valid.inspect(
          bundle: bundle(),
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'fr',
        ),
        isNull,
      );
      final badPath = candidate();
      final escaped =
          LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
            LessonMediaCandidate(
              app: badPath.app,
              lessonId: badPath.lessonId,
              courseVersion: badPath.courseVersion,
              courseSourceSha256: badPath.courseSourceSha256,
              lessonCanonicalSha256: badPath.lessonCanonicalSha256,
              assetId: badPath.assetId,
              productionIndexSha256: badPath.productionIndexSha256,
              sceneId: badPath.sceneId,
              variantStem: badPath.variantStem,
              productionSpecSha256: badPath.productionSpecSha256,
              sourceCueSha256: badPath.sourceCueSha256,
              idempotencyKey: badPath.idempotencyKey,
              productionState: badPath.productionState,
              sourcePinSha256: badPath.sourcePinSha256,
              durationMs: badPath.durationMs,
              video: _file('../content/media/$stem.mp4', video),
              captions: badPath.captions,
            ),
          ]);
      expect(
        await escaped.inspect(
          bundle: bundle(),
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        ),
        isNull,
      );
    },
  );

  test('v2k row identity and old manifest labels fail closed', () async {
    Future<InspectedLessonMedia?> inspectCandidate(LessonMediaCandidate c) =>
        LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          c,
        ]).inspect(
          bundle: bundle(),
          course: course,
          lessonId: c.lessonId,
          sceneId: c.sceneId,
          variantStem: c.variantStem,
          locale: 'tr',
        );
    final wrong = <LessonMediaCandidate>[
      candidate(app: 'gravita'),
      candidate(lessonId: 'h02'),
      candidate(assetId: 'lissom.h02.v3.demo'),
      candidate(lessonSha: _hex('0')),
      candidate(sceneId: 'lissom:h01:other'),
      candidate(variantStem: '$stem-other'),
      candidate(sourceSha: _hex('0')),
      candidate(specSha: _hex('0')),
      candidate(cueSha: _hex('0')),
      candidate(idempotencyKey: 'motion-media-v1:old'),
      candidate(productionState: 'GENERATED'),
      candidate(sourcePinSha: _hex('0')),
      candidate(
        productionIndexSha:
            'deb767cc1060cb475bf5664e0c662b44b0a0ad8318288b4e65faa3c472cb6324',
      ),
      candidate(
        productionIndexSha:
            '21008cbf5a58d01c3ef4a12c879f1b6da4e8d8ea5111f8340d53d35f9ec02c8b',
      ),
      candidate(
        specSha:
            'e0a78ba334c3885532565040555dca0f8f4e045fbfda4b4ef2072f1c22b31364',
        idempotencyKey:
            'motion-media-v1:e0a78ba334c3885532565040555dca0f8f4e045fbfda4b4ef2072f1c22b31364',
        sourcePinSha:
            '164abd44087a9e2d2e7864700751e15825d82affe36532289da16942fe9548c1',
      ),
      // Older scene specs, relabelled with a fresh v2k source pin, still miss
      // the exact current scene row.
      candidate(
        specSha:
            'f406a00ddf9f1a20fbfc33731f491ecf144cb04b7571e123db985c7f3ddb197d',
        idempotencyKey:
            'motion-media-v1:f406a00ddf9f1a20fbfc33731f491ecf144cb04b7571e123db985c7f3ddb197d',
        sourcePinSha:
            '147d35fa21e5ba5106e8f932a3c2ce3489d4186921e4bfcc1af5e4d55eb4ca0e',
      ),
      candidate(
        specSha:
            '253f4438b269271f0afb71bf9147db10d73c2c0306c8bffc3dcf3f2906379646',
        idempotencyKey:
            'motion-media-v1:253f4438b269271f0afb71bf9147db10d73c2c0306c8bffc3dcf3f2906379646',
        sourcePinSha:
            'd9af6af7dc141535077da717d844694dce6c6e62be1d403af0c778ef80950f67',
      ),
    ];
    for (final c in wrong) {
      expect(await inspectCandidate(c), isNull);
    }
  });

  test('forged QA source catalog is rejected before reading video', () async {
    final decoded =
        jsonDecode(utf8.decode(sourcePinBytes)) as Map<String, dynamic>;
    final lesson = (decoded['lessons'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((row) => row['lessonId'] == 'h01');
    final scene = (lesson['scenes'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((row) => row['sceneId'] == 'lissom:h01:orientation');
    (scene['variants'] as List).first['sourcePinSHA256'] = _hex('0');
    final assets = bundle()
      ..files['assets/motion_content/lissom_source_pins_v2k.json'] = _bytes(
        utf8.encode(jsonEncode(decoded)),
      );
    final result =
        await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          candidate(sourcePinSha: _hex('0')),
        ]).inspect(
          bundle: assets,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        );
    expect(result, isNull);
    expect(assets.mediaReads, 0);
    expect(
      computeSha256Hex(_bytes(sourcePinBytes)),
      lissomMediaSourceCatalogSha256,
    );
  });

  test('all eight h30 semantic HOLD variants reject before media read', () async {
    final decoded =
        jsonDecode(utf8.decode(sourcePinBytes)) as Map<String, dynamic>;
    final lesson = (decoded['lessons'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((row) => row['lessonId'] == 'h30');
    expect(lesson['membershipStatus'], 'HOLD_SOURCE_SEMANTIC_P2');
    var rejected = 0;
    for (final scene
        in (lesson['scenes'] as List).cast<Map<String, dynamic>>()) {
      for (final variant
          in (scene['variants'] as List).cast<Map<String, dynamic>>()) {
        final variantStem = variant['stem'] as String;
        LessonMediaFile file(String extension, Uint8List bytes) =>
            _file('content/media/$variantStem.$extension', bytes);
        final held = LessonMediaCandidate(
          app: 'lissom',
          lessonId: 'h30',
          courseVersion: course.version,
          courseSourceSha256: lesson['courseSourceSHA256'] as String,
          lessonCanonicalSha256: lesson['lessonCanonicalSHA256'] as String,
          assetId: lesson['assetId'] as String,
          productionIndexSha256:
              'd887683c9a9b9bdb8d4ab7c51cdc5a5b4b4de6a918079e4cfd9cf543e9751e60',
          sceneId: scene['sceneId'] as String,
          variantStem: variantStem,
          productionSpecSha256: scene['productionSpecSHA256'] as String,
          sourceCueSha256: scene['sourceCueSHA256'] as String,
          idempotencyKey: scene['idempotencyKey'] as String,
          productionState: scene['productionState'] as String,
          sourcePinSha256: variant['sourcePinSHA256'] as String,
          durationMs: 1000,
          video: file('mp4', video),
          captions: <String, LessonMediaFile>{
            'tr': file('tr.vtt', tr),
            'en': file('en.vtt', en),
          },
        );
        final assets = bundle();
        final result =
            await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
              held,
            ]).inspect(
              bundle: assets,
              course: course,
              lessonId: 'h30',
              sceneId: held.sceneId,
              variantStem: held.variantStem,
              locale: 'tr',
            );
        expect(result, isNull);
        expect(assets.mediaReads, 0);
        rejected++;
      }
    }
    expect(rejected, 8);
  });

  test('caption cues outside declared video duration fail closed', () async {
    final lateEn = _bytes(
      utf8.encode(
        'WEBVTT - Motion locale=en\n\n00:00:02.000 --> 00:00:03.000\nLate\n',
      ),
    );
    final assets = bundle()..files[enPath] = lateEn;
    final media =
        await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          candidate(
            captionFiles: <String, LessonMediaFile>{
              'tr': _file(trPath, tr),
              'en': _file(enPath, lateEn),
            },
          ),
        ]).inspect(
          bundle: assets,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        );
    expect(media, isNull);
  });

  test('a malformed second caption cue cannot be silently dropped', () async {
    final assets = bundle();
    final malformed = _bytes(
      utf8.encode(
        'WEBVTT - Motion locale=tr\n\n'
        '00:00:00.000 --> 00:00:00.400\nBaşla\n\n'
        '00:00:00.BAD --> 00:00:00.800\nDevam et\n',
      ),
    );
    assets.files[trPath] = malformed;
    final selected = candidate(
      captionFiles: <String, LessonMediaFile>{
        'tr': _file(trPath, malformed),
        'en': _file(enPath, en),
      },
    );
    final media =
        await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          selected,
        ]).inspect(
          bundle: assets,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        );
    expect(media, isNull);
  });

  test('an invalid unselected file cannot mask catalog budget', () async {
    final selected = candidate();
    const otherStem = 'lissom/h02/poison';
    final invalid = LessonMediaCandidate(
      app: selected.app,
      lessonId: 'h02',
      courseVersion: selected.courseVersion,
      courseSourceSha256: selected.courseSourceSha256,
      lessonCanonicalSha256: selected.lessonCanonicalSha256,
      assetId: selected.assetId,
      productionIndexSha256: selected.productionIndexSha256,
      sceneId: 'lissom:h02:poison',
      variantStem: otherStem,
      productionSpecSha256: selected.productionSpecSha256,
      sourceCueSha256: selected.sourceCueSha256,
      idempotencyKey: selected.idempotencyKey,
      productionState: selected.productionState,
      sourcePinSha256: selected.sourcePinSha256,
      durationMs: selected.durationMs,
      video: LessonMediaFile(
        path: 'content/media/$otherStem.mp4',
        bytes: -1,
        sha256: _hex('c'),
      ),
      captions: <String, LessonMediaFile>{
        'tr': LessonMediaFile(
          path: 'content/media/$otherStem.tr.vtt',
          bytes: 1,
          sha256: _hex('d'),
        ),
        'en': LessonMediaFile(
          path: 'content/media/$otherStem.en.vtt',
          bytes: 1,
          sha256: _hex('e'),
        ),
      },
    );
    final assets = bundle();
    final media =
        await LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[
          selected,
          invalid,
        ]).inspect(
          bundle: assets,
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
        );
    expect(media, isNull);
    expect(assets.reads, 0);
  });

  testWidgets('synthetic player closes on account change', (tester) async {
    final identity = ValueNotifier<String?>('one');
    final fake = _FakeController(videoPath);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonMediaSlot.syntheticForTesting(
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(
              <LessonMediaCandidate>[candidate()],
            ),
            bundle: bundle(),
            controllerFactory: (_) => fake,
            videoBuilder: (_) => const Text('synthetic player surface'),
            accountUserId: identity,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('synthetic player surface'), findsOneWidget);
    expect(fake.muteCalls, 2);
    expect(fake.value.volume, 0);
    expect(find.text('Oynat'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Paketli ders gösterimi',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
    await tester.pump();
    expect(fake.value.isPlaying, isTrue);
    expect(find.text('Duraklat'), findsOneWidget);
    identity.value = 'two';
    await tester.pumpAndSettle();
    expect(fake.retired, isTrue);
    expect(find.text('synthetic player surface'), findsNothing);
    identity.dispose();
  });

  for (final pendingStage in <String>[
    'initial mute', 'initialize', 'verified mute', 'pre-play mute', 'play', 'dispose',
  ]) {
    testWidgets('same-owner recovery drains pending $pendingStage before successor', (tester) async {
      resetLessonMediaNativeProcessForTesting();
      const userId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      final identity = ValueNotifier<String?>(userId);
      final owner = LissomLocalOwner(userId: userId, epoch: 1);
      final successor = LissomLocalOwner(userId: userId, epoch: 2);
      final first = _FakeController(videoPath);
      final second = _FakeController(videoPath);
      final gate = Completer<void>();
      switch (pendingStage) {
        case 'initial mute': first.initialMuteGate = gate;
        case 'initialize': first.initializeGate = gate;
        case 'verified mute': first.verifiedMuteGate = gate;
        case 'pre-play mute': first.prePlayMuteGate = gate;
        case 'play': first.playGate = gate;
        case 'dispose': first.disposeGate = gate;
      }
      final created = <_FakeController>[];
      final catalog = LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[candidate()]);
      final assets = bundle();
      Widget routes({bool withSuccessor = false}) => MaterialApp(
        home: Scaffold(
          body: Column(children: <Widget>[
            for (final entry in <(LissomLocalOwner, _FakeController)>[
              (owner, first), if (withSuccessor) (successor, second),
            ]) LissomOwnerContext(
              key: ObjectKey(entry.$1),
              owner: entry.$1,
              child: LessonMediaSlot.syntheticForTesting(
                key: ObjectKey(entry.$2),
                course: course, lessonId: 'h01', sceneId: 'lissom:h01:orientation',
                variantStem: stem, locale: 'tr', catalog: catalog, bundle: assets,
                accountUserId: identity,
                controllerFactory: (_) { created.add(entry.$2); return entry.$2; },
                videoBuilder: (_) => const Text('synthetic player surface'),
              ),
            ),
          ]),
        ),
      );
      Future<void>? draining;
      try {
        await tester.pumpWidget(routes());
        await tester.pumpAndSettle();
        VoidCallback? retainedPlay;
        if (pendingStage == 'pre-play mute' || pendingStage == 'play' || pendingStage == 'dispose') {
          retainedPlay = tester.widget<TextButton>(
            find.byKey(const Key('hatha.lesson.media.playPause')),
          ).onPressed;
        }
        if (pendingStage == 'pre-play mute' || pendingStage == 'play') {
          await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
          await tester.pump();
        }
        final muteCalls = first.muteCalls;
        final playCalls = first.playCalls;
        draining = owner.retireAndDrain();
        expect(owner.isActive, isFalse);
        expect(identical(draining, owner.retireAndDrain()), isTrue);
        retainedPlay?.call();
        expect(first.muteCalls, muteCalls, reason: 'Retirement closes admission before the next frame');
        expect(first.playCalls, playCalls);
        expect(identity.value, userId, reason: 'Recovery retirement needs no account-ID notification');
        var drained = false;
        unawaited(draining.then((_) => drained = true));
        await tester.pump();
        expect(drained, isFalse);
        expect(first.retired, isFalse);
        expect(find.text('synthetic player surface'), findsNothing);
        expect(first.pauseCalls, pendingStage == 'dispose' ? 1 : 0);
        expect(first.disposeCalls, pendingStage == 'dispose' ? 1 : 0);
        await tester.pumpWidget(routes(withSuccessor: true));
        await tester.pumpAndSettle();
        expect(created, <_FakeController>[first]);
        expect(second.initializeCalls, 0);
        gate.complete();
        await tester.pumpAndSettle();
        await draining;
        expect(first.pauseCalls, 1);
        expect(first.disposeCalls, 1);
        expect(first.retired, isTrue);
        expect(first.value.isPlaying, isFalse);
        expect(created, <_FakeController>[first, second]);
        expect(second.initializeCalls, 1);
        retainedPlay?.call();
        await owner.retireAndDrain();
        await tester.pump();
        expect(second.pauseCalls, 0, reason: 'Late retired-owner callbacks cannot mutate the successor');
        expect(second.disposeCalls, 0);
      } finally {
        if (!gate.isCompleted) gate.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await draining;
        await successor.retireAndDrain();
        identity.dispose();
        resetLessonMediaNativeProcessForTesting();
      }
    });
  }

  for (final closeTrigger in <String>['unmount', 'background']) {
    testWidgets('pending $closeTrigger resource close remains in owner drain', (tester) async {
      resetLessonMediaNativeProcessForTesting();
      final owner = LissomLocalOwner(userId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', epoch: 1);
      final fake = _FakeController(videoPath)..pauseGate = Completer<void>();
      final gate = fake.pauseGate!;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: LissomOwnerContext(
        owner: owner,
        child: LessonMediaSlot.syntheticForTesting(
          course: course, lessonId: 'h01', sceneId: 'lissom:h01:orientation',
          variantStem: stem, locale: 'tr',
          catalog: LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[candidate()]),
          bundle: bundle(), controllerFactory: (_) => fake,
          videoBuilder: (_) => const Text('synthetic player surface'),
        ),
      ))));
      await tester.pumpAndSettle();
      if (closeTrigger == 'unmount') {
        await tester.pumpWidget(const SizedBox.shrink());
      } else {
        final observer = tester.state(find.byType(LessonMediaSlot)) as WidgetsBindingObserver;
        observer.didChangeAppLifecycleState(AppLifecycleState.paused);
        await tester.pump();
      }
      final draining = owner.retireAndDrain();
      var drained = false;
      unawaited(draining.then((_) => drained = true));
      try {
        await tester.pump();
        expect(fake.pauseCalls, 1);
        expect(fake.disposeCalls, 0);
        expect(drained, isFalse, reason: 'Route close is still registered until its native Future settles');
        gate.complete();
        await tester.pumpAndSettle();
        await draining;
        expect(fake.pauseCalls, 1);
        expect(fake.disposeCalls, 1);
      } finally {
        if (!gate.isCompleted) gate.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await draining;
        resetLessonMediaNativeProcessForTesting();
      }
    });
  }

  testWidgets('background successor re-registers with the same owner', (tester) async {
    resetLessonMediaNativeProcessForTesting();
    final owner = LissomLocalOwner(userId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', epoch: 1);
    final first = _FakeController(videoPath);
    final second = _FakeController(videoPath);
    var created = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LissomOwnerContext(
      owner: owner,
      child: LessonMediaSlot.syntheticForTesting(
        course: course, lessonId: 'h01', sceneId: 'lissom:h01:orientation',
        variantStem: stem, locale: 'tr',
        catalog: LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[candidate()]),
        bundle: bundle(), controllerFactory: (_) => created++ == 0 ? first : second,
        videoBuilder: (_) => const Text('synthetic player surface'),
      ),
    ))));
    await tester.pumpAndSettle();
    final observer = tester.state(find.byType(LessonMediaSlot)) as WidgetsBindingObserver;
    observer.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(created, 2);
    final draining = owner.retireAndDrain();
    await tester.pumpAndSettle();
    await draining;
    expect(second.pauseCalls, 1);
    expect(second.disposeCalls, 1, reason: 'Reopened controller belongs to a fresh registered resource');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    resetLessonMediaNativeProcessForTesting();
  });

  for (final failureStage in <String>['dispose', 'play']) {
    testWidgets('failed native $failureStage remains a failing owner barrier and blocks successor', (tester) async {
      resetLessonMediaNativeProcessForTesting();
      const userId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      final owner = LissomLocalOwner(userId: userId, epoch: 1);
      final successor = LissomLocalOwner(userId: userId, epoch: 2);
      final gate = Completer<void>();
      final first = _FakeController(videoPath)
        ..disposeGate = gate
        ..failNativeDispose = failureStage == 'dispose'
        ..failNativePlay = failureStage == 'play';
      final second = _FakeController(videoPath);
      var created = 0;
      Widget route(LissomLocalOwner selected, _FakeController controller) => MaterialApp(
        home: Scaffold(body: LissomOwnerContext(
          key: ObjectKey(selected), owner: selected,
          child: LessonMediaSlot.syntheticForTesting(
            course: course, lessonId: 'h01', sceneId: 'lissom:h01:orientation',
            variantStem: stem, locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[candidate()]),
            bundle: bundle(), controllerFactory: (_) { created++; return controller; },
            videoBuilder: (_) => const Text('synthetic player surface'),
          ),
        )),
      );
      await tester.pumpWidget(route(owner, first));
      await tester.pumpAndSettle();
      if (failureStage == 'play') {
        await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
        await tester.pump();
        expect(first.playCalls, 1);
        expect(first.pauseCalls, 1);
        expect(first.disposeCalls, 1);
      }
      final draining = owner.retireAndDrain();
      var erased = false;
      final cleanup = draining.then((_) => erased = true);
      final failed = expectLater(cleanup, throwsA(isA<StateError>().having(
        (error) => error.message, 'message', contains('closure was not confirmed'),
      )));
      try {
        await tester.pump();
        expect(first.disposeCalls, 1);
        expect(first.retired, isFalse);
        expect(erased, isFalse);
        gate.complete();
        await tester.pumpAndSettle();
        await failed;
        expect(erased, isFalse, reason: 'Unconfirmed native closure cannot authorize file erasure');
        expect(identical(draining, owner.retireAndDrain()), isTrue);
        await expectLater(owner.retireAndDrain(), throwsA(isA<StateError>()));
        await tester.pumpWidget(route(successor, second));
        await tester.pumpAndSettle();
        expect(created, 1);
        expect(second.initializeCalls, 0);
        expect(first.disposeCalls, 1);
      } finally {
        if (!gate.isCompleted) gate.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await successor.retireAndDrain();
        resetLessonMediaNativeProcessForTesting();
      }
    });
  }

  testWidgets('retired inherited owner cannot create a player', (tester) async {
    resetLessonMediaNativeProcessForTesting();
    final owner = LissomLocalOwner(userId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', epoch: 1);
    await owner.retireAndDrain();
    var created = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LissomOwnerContext(
      owner: owner,
      child: LessonMediaSlot.syntheticForTesting(
        course: course, lessonId: 'h01', sceneId: 'lissom:h01:orientation',
        variantStem: stem, locale: 'tr',
        catalog: LessonMediaCatalog.syntheticForTesting(<LessonMediaCandidate>[candidate()]),
        bundle: bundle(), controllerFactory: (_) { created++; return _FakeController(videoPath); },
        videoBuilder: (_) => const Text('synthetic player surface'),
      ),
    ))));
    await tester.pumpAndSettle();
    expect(created, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    resetLessonMediaNativeProcessForTesting();
  });

  testWidgets('failed native mute keeps synthetic player hidden', (
    tester,
  ) async {
    final fake = _FakeController(videoPath)..failNativeMute = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonMediaSlot.syntheticForTesting(
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(
              <LessonMediaCandidate>[candidate()],
            ),
            bundle: bundle(),
            controllerFactory: (_) => fake,
            videoBuilder: (_) => const Text('synthetic player surface'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(fake.muteCalls, 2);
    expect(fake.retired, isTrue);
    expect(find.text('synthetic player surface'), findsNothing);
  });

  testWidgets('play waits for a fresh native mute after volume changes', (
    tester,
  ) async {
    final fake = _FakeController(videoPath);
    final gate = Completer<void>();
    fake.prePlayMuteGate = gate;
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonMediaSlot.syntheticForTesting(
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(
              <LessonMediaCandidate>[candidate()],
            ),
            bundle: bundle(),
            controllerFactory: (_) => fake,
            videoBuilder: (_) => const Text('synthetic player surface'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    fake.value = fake.value.copyWith(volume: 1);
    await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
    await tester.pump();
    expect(fake.muteCalls, 3);
    expect(fake.playCalls, 0);
    gate.complete();
    await tester.pumpAndSettle();
    expect(fake.playCalls, 1);
    expect(fake.value.volume, 0);
  });

  testWidgets('background return rechecks media and stays paused', (
    tester,
  ) async {
    final first = _FakeController(videoPath);
    final second = _FakeController(videoPath);
    var created = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonMediaSlot.syntheticForTesting(
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(
              <LessonMediaCandidate>[candidate()],
            ),
            bundle: bundle(),
            controllerFactory: (_) => created++ == 0 ? first : second,
            videoBuilder: (_) => const Text('synthetic player surface'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final observer =
        tester.state(find.byType(LessonMediaSlot)) as WidgetsBindingObserver;
    observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    expect(find.text('synthetic player surface'), findsNothing);
    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('synthetic player surface'), findsOneWidget);
    expect(created, 2);
    expect(second.value.isPlaying, isFalse);
  });

  testWidgets('new route waits for the prior native controller to retire', (
    tester,
  ) async {
    final first = _FakeController(videoPath);
    final second = _FakeController(videoPath);
    final gate = Completer<void>();
    first.pauseGate = gate;
    var created = 0;
    Widget route() => MaterialApp(
      home: Scaffold(
        body: LessonMediaSlot.syntheticForTesting(
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
          catalog: LessonMediaCatalog.syntheticForTesting(
            <LessonMediaCandidate>[candidate()],
          ),
          bundle: bundle(),
          controllerFactory: (_) => created++ == 0 ? first : second,
          videoBuilder: (_) => const Text('synthetic player surface'),
        ),
      ),
    );
    await tester.pumpWidget(route());
    await tester.pumpAndSettle();
    expect(created, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(route());
    await tester.pumpAndSettle();
    expect(created, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    expect(created, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(second.retired, isTrue);
  });

  for (final pendingStage in <String>[
    'delayed initialize',
    'pending native mute',
  ]) {
    testWidgets('$pendingStage unmount retires once and preserves next owner', (
      tester,
    ) async {
      resetLessonMediaNativeProcessForTesting();
      final first = _FakeController(videoPath);
      final second = _FakeController(videoPath);
      final third = _FakeController(videoPath);
      final gate = Completer<void>();
      if (pendingStage == 'delayed initialize') {
        first.initializeGate = gate;
      } else {
        first.verifiedMuteGate = gate;
      }
      final created = <_FakeController>[];
      final catalog = LessonMediaCatalog.syntheticForTesting(
        <LessonMediaCandidate>[candidate()],
      );
      final assets = bundle();
      Widget routes(List<_FakeController> controllers) => MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              for (final controller in controllers)
                LessonMediaSlot.syntheticForTesting(
                  key: ObjectKey(controller),
                  course: course,
                  lessonId: 'h01',
                  sceneId: 'lissom:h01:orientation',
                  variantStem: stem,
                  locale: 'tr',
                  catalog: catalog,
                  bundle: assets,
                  controllerFactory: (_) {
                    created.add(controller);
                    return controller;
                  },
                  videoBuilder: (_) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      );
      try {
        await tester.pumpWidget(routes(<_FakeController>[first]));
        await tester.pumpAndSettle();
        expect(created, <_FakeController>[first]);
        expect(first.initializeCalls, 1);
        expect(first.muteCalls, pendingStage == 'delayed initialize' ? 1 : 2);
        await tester.pumpWidget(routes(<_FakeController>[second]));
        await tester.pumpAndSettle();
        expect(created, <_FakeController>[first]);
        expect(first.pauseCalls, 0);
        expect(first.disposeCalls, 0);

        gate.complete();
        await tester.pumpAndSettle();
        expect(first.pauseCalls, 1);
        expect(first.disposeCalls, 1);
        expect(first.playCalls, 0);
        expect(first.value.isPlaying, isFalse);
        expect(created, <_FakeController>[first, second]);

        // The old route's late continuation cannot release the second route's
        // native slot. A third mounted widget must wait for its actual owner.
        await tester.pumpWidget(routes(<_FakeController>[second, third]));
        await tester.pumpAndSettle();
        expect(created, <_FakeController>[first, second]);
        expect(second.pauseCalls, 0);
        expect(second.disposeCalls, 0);
        expect(third.initializeCalls, 0);

        await tester.pumpWidget(routes(<_FakeController>[third]));
        await tester.pumpAndSettle();
        expect(second.pauseCalls, 1);
        expect(second.disposeCalls, 1);
        expect(created, <_FakeController>[first, second, third]);
        expect(third.initializeCalls, 1);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        expect(third.pauseCalls, 1);
        expect(third.disposeCalls, 1);
      } finally {
        if (!gate.isCompleted) gate.complete();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        resetLessonMediaNativeProcessForTesting();
      }
    });
  }

  testWidgets('synchronous account revocation waits for pending play', (
    tester,
  ) async {
    final identity = ValueNotifier<String?>('one');
    final first = _FakeController(videoPath);
    final gate = Completer<void>();
    first.playGate = gate;
    first.onPlay = () => identity.value = 'two';
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
      identity.dispose();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LessonMediaSlot.syntheticForTesting(
            course: course,
            lessonId: 'h01',
            sceneId: 'lissom:h01:orientation',
            variantStem: stem,
            locale: 'tr',
            catalog: LessonMediaCatalog.syntheticForTesting(
              <LessonMediaCandidate>[candidate()],
            ),
            bundle: bundle(),
            controllerFactory: (_) => first,
            videoBuilder: (_) => const Text('synthetic player surface'),
            accountUserId: identity,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
    await tester.pump();
    expect(first.retired, isFalse);
    gate.complete();
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    expect(first.value.isPlaying, isFalse);
    expect(find.text('synthetic player surface'), findsNothing);
  });

  testWidgets('pending play cannot outlive retirement into a new route', (
    tester,
  ) async {
    final first = _FakeController(videoPath);
    final second = _FakeController(videoPath);
    final gate = Completer<void>();
    first.playGate = gate;
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    var created = 0;
    Widget route() => MaterialApp(
      home: Scaffold(
        body: LessonMediaSlot.syntheticForTesting(
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
          catalog: LessonMediaCatalog.syntheticForTesting(
            <LessonMediaCandidate>[candidate()],
          ),
          bundle: bundle(),
          controllerFactory: (_) => created++ == 0 ? first : second,
          videoBuilder: (_) => const Text('synthetic player surface'),
        ),
      ),
    );
    await tester.pumpWidget(route());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(route());
    await tester.pump();
    expect(first.retired, isFalse);
    expect(created, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    expect(first.value.isPlaying, isFalse);
    expect(created, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('hung play quarantines the process after bounded retirement', (
    tester,
  ) async {
    final first = _FakeController(videoPath);
    final second = _FakeController(videoPath);
    final gate = Completer<void>();
    first.playGate = gate;
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    var created = 0;
    Widget route() => MaterialApp(
      home: Scaffold(
        body: LessonMediaSlot.syntheticForTesting(
          course: course,
          lessonId: 'h01',
          sceneId: 'lissom:h01:orientation',
          variantStem: stem,
          locale: 'tr',
          catalog: LessonMediaCatalog.syntheticForTesting(
            <LessonMediaCandidate>[candidate()],
          ),
          bundle: bundle(),
          controllerFactory: (_) => created++ == 0 ? first : second,
          videoBuilder: (_) => const Text('synthetic player surface'),
        ),
      ),
    );
    await tester.pumpWidget(route());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('hatha.lesson.media.playPause')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(route());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(first.retired, isTrue);
    expect(created, 1);
    gate.complete();
    await tester.pumpAndSettle();
    expect(created, 1);
    expect(find.text('synthetic player surface'), findsNothing);
  });

  testWidgets(
    'hung native pause still attempts disposal and blocks reopening',
    (tester) async {
      resetLessonMediaNativeProcessForTesting();
      final fake = _FakeController(videoPath);
      final gate = Completer<void>();
      fake.pauseGate = gate;
      addTearDown(() {
        if (!gate.isCompleted) gate.complete();
      });
      var created = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonMediaSlot.syntheticForTesting(
              course: course,
              lessonId: 'h01',
              sceneId: 'lissom:h01:orientation',
              variantStem: stem,
              locale: 'tr',
              catalog: LessonMediaCatalog.syntheticForTesting(
                <LessonMediaCandidate>[candidate()],
              ),
              bundle: bundle(),
              controllerFactory: (_) {
                created++;
                return fake;
              },
              videoBuilder: (_) => const Text('synthetic player surface'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final observer =
          tester.state(find.byType(LessonMediaSlot)) as WidgetsBindingObserver;
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();
      expect(fake.retired, isFalse);
      await tester.pump(const Duration(seconds: 3));
      expect(fake.retired, isTrue);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      gate.complete();
      await tester.pumpAndSettle();
      expect(created, 1);
      expect(find.text('synthetic player surface'), findsNothing);
    },
  );
}
