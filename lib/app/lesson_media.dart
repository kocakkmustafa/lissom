import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';
import 'package:video_player/video_player.dart';

import 'hatha_course.dart';
import 'flutter_bundle_content_asset_reader.dart';
import 'lissom_source_projection_pin.dart';
import 'local_owner.dart';
import 'local_owner_context.dart';

const String _courseAssetPath = LissomSourceProjectionPin.coursePath;
const String _productionIndexSha256 =
    LissomSourceProjectionPin.sourceManifestSha256;
const String lissomMediaSourceCatalogSha256 =
    '267e3109df1c4a01005967513ad7e7594e008e9983aedf4e95bcb20c7cbca67e';
const String _sourceCatalogPath =
    'assets/motion_content/lissom_source_pins_v2k.json';
const String _opsSourceCatalogSha256 =
    LissomSourceProjectionPin.sourceCatalogSha256;
const String _sourceProofSha256 =
    'dec615e14881b86b7676e1157f63b8bf6269026d856e59f2ee3a65d7f97e512a';
const String _courseSourceSha256 = LissomSourceProjectionPin.courseSha256;
const int _maxVideoBytes = 64 * 1024 * 1024;
const int _maxCaptionBytes = 1024 * 1024;
const int _maxMediaBytes = 512 * 1024 * 1024;
const Duration _nativeRetireDeadline = Duration(seconds: 2);
bool _nativePlaybackUnconfirmed = false;
Completer<void>? _nativeSlotOwner;

Future<Completer<void>?> _takeNativeSlot() async {
  while (!_nativePlaybackUnconfirmed) {
    final owner = _nativeSlotOwner;
    if (owner == null) {
      final slot = Completer<void>();
      _nativeSlotOwner = slot;
      return slot;
    }
    await owner.future;
  }
  return null;
}

void _releaseNativeSlot(Completer<void> owner) {
  if (!identical(_nativeSlotOwner, owner)) return;
  _nativeSlotOwner = null;
  owner.complete();
}

/// Models a fresh OS process between independent widget-test scenarios.
/// The production app never calls this test seam after an uncertain close.
@visibleForTesting
void resetLessonMediaNativeProcessForTesting() {
  if (_nativeSlotOwner != null) {
    throw StateError('Cannot reset an occupied native media slot');
  }
  _nativePlaybackUnconfirmed = false;
}

final RegExp _sha = RegExp(r'^[0-9a-f]{64}$');
final RegExp _cueTime = RegExp(
  r'^(\d{2,}):([0-5]\d):([0-5]\d)\.(\d{3}) --> (\d{2,}):([0-5]\d):([0-5]\d)\.(\d{3})$',
);

/// Describes one future, packaged MP4 and its bilingual WebVTT sidecars.
/// This is byte metadata, not an educator, rights, or release acceptance.
@immutable
final class LessonMediaFile {
  const LessonMediaFile({
    required this.path,
    required this.bytes,
    required this.sha256,
  });

  final String path;
  final int bytes;
  final String sha256;
}

@immutable
final class LessonMediaCandidate {
  LessonMediaCandidate({
    required this.app,
    required this.lessonId,
    required this.courseVersion,
    required this.courseSourceSha256,
    required this.lessonCanonicalSha256,
    required this.assetId,
    required this.productionIndexSha256,
    required this.sceneId,
    required this.variantStem,
    required this.productionSpecSha256,
    required this.sourceCueSha256,
    required this.idempotencyKey,
    required this.productionState,
    required this.sourcePinSha256,
    required this.durationMs,
    required this.video,
    required Map<String, LessonMediaFile> captions,
  }) : captions = Map<String, LessonMediaFile>.unmodifiable(captions);

  final String app;
  final String lessonId;
  final String courseVersion;
  final String courseSourceSha256;
  final String lessonCanonicalSha256;
  final String assetId;
  final String productionIndexSha256;
  final String sceneId;
  final String variantStem;
  final String productionSpecSha256;
  final String sourceCueSha256;
  final String idempotencyKey;
  final String productionState;
  final String sourcePinSha256;
  final int durationMs;
  final LessonMediaFile video;
  final Map<String, LessonMediaFile> captions;
}

@immutable
final class InspectedLessonMedia {
  const InspectedLessonMedia(this.candidate, this.captionText);

  final LessonMediaCandidate candidate;
  final String captionText;

  /// Inspection can never promote a staging candidate to a release asset.
  bool get visible => false;
  bool get releaseEligible => false;
  int get progressEffect => 0;
}

/// The production catalog is deliberately empty. Only widget tests can inject
/// candidates; a future release must generate its catalog from an independently
/// signed acceptance root and the complete packaged-asset inventory.
final class LessonMediaCatalog {
  const LessonMediaCatalog.empty()
    : _candidates = const <LessonMediaCandidate>[];

  @visibleForTesting
  LessonMediaCatalog.syntheticForTesting(List<LessonMediaCandidate> candidates)
    : _candidates = List<LessonMediaCandidate>.unmodifiable(candidates);

  final List<LessonMediaCandidate> _candidates;

  bool get isEmpty => _candidates.isEmpty;

  Future<InspectedLessonMedia?> inspect({
    required AssetBundle bundle,
    required HathaCourse course,
    required String lessonId,
    required String sceneId,
    required String variantStem,
    required String locale,
  }) async {
    if (kReleaseMode ||
        _candidates.isEmpty ||
        (locale != 'tr' && locale != 'en')) {
      return null;
    }
    final matches = _candidates.where(
      (c) =>
          c.lessonId == lessonId &&
          c.sceneId == sceneId &&
          c.variantStem == variantStem,
    );
    if (matches.length != 1 || !_catalogBudgetIsSafe()) return null;
    final c = matches.single;
    if (!course.lessons.any((lesson) => lesson.id == lessonId) ||
        c.courseVersion != course.version ||
        c.productionIndexSha256 != _productionIndexSha256 ||
        c.app != 'lissom' ||
        !_sha.hasMatch(c.lessonCanonicalSha256) ||
        !_sha.hasMatch(c.courseSourceSha256) ||
        !_sha.hasMatch(c.productionSpecSha256) ||
        !_sha.hasMatch(c.sourceCueSha256) ||
        !_sha.hasMatch(c.sourcePinSha256) ||
        !c.sceneId.startsWith('lissom:$lessonId:') ||
        c.sceneId.split(':').length != 3 ||
        c.sceneId.split(':').last.isEmpty ||
        c.variantStem.isEmpty ||
        c.durationMs <= 0 ||
        c.captions.keys.toSet().difference(const <String>{
          'tr',
          'en',
        }).isNotEmpty ||
        c.captions.length != 2 ||
        !_fileShape(
          c.video,
          'content/media/${c.variantStem}.mp4',
          _maxVideoBytes,
        )) {
      return null;
    }
    for (final entry in c.captions.entries) {
      if (!_fileShape(
        entry.value,
        'content/media/${c.variantStem}.${entry.key}.vtt',
        _maxCaptionBytes,
      )) {
        return null;
      }
    }
    try {
      final reader = FlutterBundleContentAssetReader(bundle: bundle);
      final source = await _pinnedSource(reader, c);
      if (source == null ||
          !_sourceMatches(c, source) ||
          _computedSourcePin(c) != source.sourcePinSha256) {
        return null;
      }
      final courseBytes = await reader.read(_courseAssetPath);
      if (computeSha256Hex(courseBytes) != c.courseSourceSha256 ||
          !_canonicalLessonMatches(
            courseBytes,
            c.lessonId,
            c.lessonCanonicalSha256,
          )) {
        return null;
      }
      final videoBytes = await reader.read(c.video.path);
      if (!_bytesMatch(videoBytes, c.video) ||
          videoBytes.length < 12 ||
          String.fromCharCodes(videoBytes.sublist(4, 8)) != 'ftyp') {
        return null;
      }
      String? selectedCaption;
      for (final entry in c.captions.entries) {
        final captionBytes = await reader.read(entry.value.path);
        if (!_bytesMatch(captionBytes, entry.value)) return null;
        final text = utf8.decode(captionBytes, allowMalformed: false);
        if (!text.startsWith('WEBVTT - Motion locale=${entry.key}\n') ||
            !text.contains(' --> ') ||
            !_captionTrackFitsDuration(text, entry.key, c.durationMs)) {
          return null;
        }
        if (entry.key == locale) selectedCaption = text;
      }
      if (selectedCaption == null) return null;
      return InspectedLessonMedia(c, selectedCaption);
    } on Object {
      // Missing or altered packaged bytes leave the written lesson available.
      return null;
    }
  }

  bool _catalogBudgetIsSafe() {
    var total = 0;
    final paths = <String>{};
    final keys = <String>{};
    for (final c in _candidates) {
      if (!keys.add('${c.lessonId}\u0000${c.sceneId}\u0000${c.variantStem}')) {
        return false;
      }
      if (!_fileShape(
            c.video,
            'content/media/${c.variantStem}.mp4',
            _maxVideoBytes,
          ) ||
          c.captions.length != 2 ||
          !c.captions.keys.toSet().containsAll(const <String>{'tr', 'en'})) {
        return false;
      }
      for (final caption in c.captions.entries) {
        if (!_fileShape(
          caption.value,
          'content/media/${c.variantStem}.${caption.key}.vtt',
          _maxCaptionBytes,
        )) {
          return false;
        }
      }
      for (final file in <LessonMediaFile>[c.video, ...c.captions.values]) {
        if (!paths.add(file.path) ||
            file.bytes <= 0 ||
            file.bytes > _maxMediaBytes - total) {
          return false;
        }
        total += file.bytes;
      }
    }
    return true;
  }
}

final class _SourcePin {
  const _SourcePin({
    required this.app,
    required this.assetId,
    required this.lessonId,
    required this.courseSourceSha256,
    required this.lessonCanonicalSha256,
    required this.sceneId,
    required this.variantStem,
    required this.productionSpecSha256,
    required this.sourceCueSha256,
    required this.idempotencyKey,
    required this.productionState,
    required this.sourcePinSha256,
  });

  final String app, assetId, lessonId, courseSourceSha256;
  final String lessonCanonicalSha256, sceneId, variantStem;
  final String productionSpecSha256, sourceCueSha256;
  final String idempotencyKey, productionState, sourcePinSha256;
}

bool _sourceMatches(LessonMediaCandidate c, _SourcePin pin) =>
    c.app == pin.app &&
    c.assetId == pin.assetId &&
    c.lessonId == pin.lessonId &&
    c.courseSourceSha256 == pin.courseSourceSha256 &&
    c.lessonCanonicalSha256 == pin.lessonCanonicalSha256 &&
    c.sceneId == pin.sceneId &&
    c.variantStem == pin.variantStem &&
    c.productionSpecSha256 == pin.productionSpecSha256 &&
    c.sourceCueSha256 == pin.sourceCueSha256 &&
    c.idempotencyKey == pin.idempotencyKey &&
    c.productionState == pin.productionState &&
    c.sourcePinSha256 == pin.sourcePinSha256 &&
    c.productionState == 'PREPRODUCTION_UNGENERATED' &&
    c.idempotencyKey == 'motion-media-v1:${c.productionSpecSha256}';

String _computedSourcePin(LessonMediaCandidate c) {
  // Dart insertion order is the ops canonical JSON key order.
  final identity = <String, String>{
    'app': c.app,
    'assetId': c.assetId,
    'courseSourceSHA256': c.courseSourceSha256,
    'idempotencyKey': c.idempotencyKey,
    'lessonCanonicalSHA256': c.lessonCanonicalSha256,
    'lessonId': c.lessonId,
    'manifestSHA256': c.productionIndexSha256,
    'productionSpecSHA256': c.productionSpecSha256,
    'productionState': c.productionState,
    'sceneId': c.sceneId,
    'sourceCueSHA256': c.sourceCueSha256,
    'variantStem': c.variantStem,
  };
  return computeSha256Hex(
    Uint8List.fromList(utf8.encode(jsonEncode(identity))),
  );
}

Future<_SourcePin?> _pinnedSource(
  FlutterBundleContentAssetReader reader,
  LessonMediaCandidate c,
) async {
  final bytes = await reader.read(_sourceCatalogPath);
  if (computeSha256Hex(bytes) != lissomMediaSourceCatalogSha256) return null;
  final value = jsonDecode(utf8.decode(bytes));
  if (value is! Map<String, dynamic> ||
      value['schemaVersion'] != 1 ||
      value['kind'] != 'LISSOM_V2K_SOURCE_PINS_QA_ONLY' ||
      value['sourceCatalogSHA256'] != _opsSourceCatalogSha256 ||
      value['sourceProofSHA256'] != _sourceProofSha256 ||
      value['manifestSHA256'] != _productionIndexSha256 ||
      value['courseSourceSHA256'] != _courseSourceSha256 ||
      value['visible'] != false ||
      value['releaseEligible'] != false ||
      value['progressEffect'] != 0 ||
      value['counts'] is! Map<String, dynamic> ||
      value['holds'] is! List ||
      value['lessons'] is! List) {
    return null;
  }
  final holds = value['holds'] as List;
  if (holds.length != 1 ||
      holds.single is! Map<String, dynamic> ||
      (holds.single as Map<String, dynamic>)['app'] != 'lissom' ||
      (holds.single as Map<String, dynamic>)['lessonId'] != 'h30' ||
      (holds.single as Map<String, dynamic>)['status'] !=
          'HOLD_SOURCE_SEMANTIC_P2') {
    return null;
  }
  final counts = value['counts'] as Map<String, dynamic>;
  if (counts['lessons'] != 60 ||
      counts['scenes'] != 480 ||
      counts['variants'] != 480 ||
      counts['semanticHeldScenes'] != 8 ||
      counts['semanticHeldVariants'] != 8 ||
      counts['generatedMedia'] != 0 ||
      counts['qualifiedMedia'] != 0) {
    return null;
  }
  final lessons = (value['lessons'] as List)
      .whereType<Map<String, dynamic>>()
      .where((row) => row['app'] == 'lissom' && row['lessonId'] == c.lessonId);
  if (lessons.length != 1) return null;
  final lesson = lessons.single;
  if (lesson['membershipStatus'] != 'SOURCE_PINNED_TEST_ONLY' ||
      lesson['scenes'] is! List) {
    return null;
  }
  final scenes = (lesson['scenes'] as List)
      .whereType<Map<String, dynamic>>()
      .where((row) => row['sceneId'] == c.sceneId);
  if (scenes.length != 1) return null;
  final scene = scenes.single;
  if (scene['productionState'] != 'PREPRODUCTION_UNGENERATED' ||
      scene['variants'] is! List) {
    return null;
  }
  final variants = (scene['variants'] as List)
      .whereType<Map<String, dynamic>>()
      .where((row) => row['stem'] == c.variantStem);
  if (variants.length != 1) return null;
  final variant = variants.single;
  return _SourcePin(
    app: lesson['app'] as String,
    assetId: lesson['assetId'] as String,
    lessonId: lesson['lessonId'] as String,
    courseSourceSha256: lesson['courseSourceSHA256'] as String,
    lessonCanonicalSha256: lesson['lessonCanonicalSHA256'] as String,
    sceneId: scene['sceneId'] as String,
    variantStem: variant['stem'] as String,
    productionSpecSha256: scene['productionSpecSHA256'] as String,
    sourceCueSha256: scene['sourceCueSHA256'] as String,
    idempotencyKey: scene['idempotencyKey'] as String,
    productionState: scene['productionState'] as String,
    sourcePinSha256: variant['sourcePinSHA256'] as String,
  );
}

bool _canonicalLessonMatches(
  Uint8List courseBytes,
  String lessonId,
  String sha,
) {
  final value = jsonDecode(utf8.decode(courseBytes));
  if (value is! Map<String, dynamic> || value['modules'] is! List) {
    return false;
  }
  final lessons = <Map<String, dynamic>>[];
  for (final module in value['modules'] as List) {
    if (module is! Map<String, dynamic> || module['lessons'] is! List) {
      return false;
    }
    for (final lesson in module['lessons'] as List) {
      if (lesson is Map<String, dynamic> && lesson['id'] == lessonId) {
        lessons.add(lesson);
      }
    }
  }
  return lessons.length == 1 &&
      computeSha256Hex(
            Uint8List.fromList(
              utf8.encode(canonicalJsonEncode(lessons.single)),
            ),
          ) ==
          sha;
}

bool _captionTrackFitsDuration(String text, String locale, int durationMs) {
  if (text.contains('\r') ||
      text.contains('\ufeff') ||
      text.contains('\u0000')) {
    return false;
  }
  final header = 'WEBVTT - Motion locale=$locale\n\n';
  if (!text.startsWith(header)) return false;
  final body = text.substring(header.length).replaceFirst(RegExp(r'\n+$'), '');
  if (body.isEmpty) return false;
  var previousEnd = 0;
  var count = 0;
  for (final block in body.split('\n\n')) {
    final lines = block.split('\n');
    if (lines.length < 2 || lines.any((line) => line.trim().isEmpty)) {
      return false;
    }
    final match = _cueTime.firstMatch(lines.first);
    if (match == null) return false;
    int milliseconds(int at) =>
        ((int.parse(match.group(at)!) * 60 + int.parse(match.group(at + 1)!)) *
                    60 +
                int.parse(match.group(at + 2)!)) *
            1000 +
        int.parse(match.group(at + 3)!);
    final start = milliseconds(1);
    final end = milliseconds(5);
    if (start < previousEnd || end <= start || end > durationMs) return false;
    for (final line in lines.skip(1)) {
      if (line.contains('<') ||
          line.contains('>') ||
          line.runes.any((rune) => rune < 32 && rune != 9)) {
        return false;
      }
    }
    previousEnd = end;
    count++;
  }
  final captions = WebVTTCaptionFile(text).captions;
  return captions.length == count &&
      captions.every(
        (caption) =>
            caption.end <= Duration(milliseconds: durationMs) &&
            caption.text.trim().isNotEmpty,
      );
}

bool _fileShape(LessonMediaFile file, String expectedPath, int maxBytes) {
  if (file.bytes <= 0 ||
      file.bytes > maxBytes ||
      !_sha.hasMatch(file.sha256) ||
      file.path != expectedPath) {
    return false;
  }
  try {
    PathPolicy.validate(file.path);
  } on Object {
    return false;
  }
  return true;
}

bool _bytesMatch(Uint8List bytes, LessonMediaFile file) =>
    bytes.length == file.bytes && computeSha256Hex(bytes) == file.sha256;

typedef LessonVideoControllerFactory =
    VideoPlayerController Function(InspectedLessonMedia media);

VideoPlayerController _defaultController(InspectedLessonMedia media) =>
    VideoPlayerController.asset(
      media.candidate.video.path,
      closedCaptionFile: Future<ClosedCaptionFile>.value(
        WebVTTCaptionFile(media.captionText),
      ),
    );

/// The normal course uses [LessonMediaSlot.empty]. The injected constructor
/// exercises the real offline player path in tests, without publishing any
/// staging candidate or changing progress/mastery state.
class LessonMediaSlot extends StatefulWidget {
  LessonMediaSlot.empty({
    required this.course,
    required this.lessonId,
    required this.locale,
    this.accountUserId,
    super.key,
  }) : catalog = const LessonMediaCatalog.empty(),
       bundle = rootBundle,
       sceneId = null,
       variantStem = null,
       syntheticPlayback = false,
       controllerFactory = _defaultController,
       videoBuilder = null;

  @visibleForTesting
  const LessonMediaSlot.syntheticForTesting({
    required this.course,
    required this.lessonId,
    required this.sceneId,
    required this.variantStem,
    required this.locale,
    required this.catalog,
    required this.bundle,
    required this.controllerFactory,
    this.videoBuilder,
    this.accountUserId,
    super.key,
  }) : syntheticPlayback = true;

  final HathaCourse course;
  final String lessonId;
  final String? sceneId;
  final String? variantStem;
  final String locale;
  final LessonMediaCatalog catalog;
  final AssetBundle bundle;
  final bool syntheticPlayback;
  final LessonVideoControllerFactory controllerFactory;
  final Widget Function(VideoPlayerController)? videoBuilder;
  final ValueListenable<String?>? accountUserId;

  @override
  State<LessonMediaSlot> createState() => _LessonMediaSlotState();
}

class _LessonMediaSlotState extends State<LessonMediaSlot>
    with WidgetsBindingObserver {
  int _epoch = 0;
  bool _closed = false;
  bool _accountRevoked = false;
  bool _backgrounded = false;
  bool _disposing = false;
  LissomLocalOwner? _owner;
  LissomResourceLease? _resource;
  VideoPlayerController? _controller;
  Completer<void>? _controllerSlot;
  final Expando<bool> _retirementQueued = Expando<bool>();
  Future<void> _retiring = Future<void>.value();
  Future<void>? _nativeCommand;
  bool _commandPending = false;

  bool get _ownerActive => _owner?.isActive ?? true;

  void _registerOwnerResource() {
    final owner = _owner;
    if (_resource == null && owner != null && owner.isActive) {
      _resource = owner.registerResource(_close);
    }
  }

  Future<void> _closeRegistered() {
    final resource = _resource;
    _resource = null;
    return resource?.close() ?? _close();
  }

  @override
  void initState() {
    super.initState();
    // Capture this State's lifetime once. A same-UUID recovery has a new owner.
    _owner = LissomOwnerContext.maybeOf(context);
    _registerOwnerResource();
    WidgetsBinding.instance.addObserver(this);
    widget.accountUserId?.addListener(_onAccount);
    _open();
  }

  @override
  void didUpdateWidget(covariant LessonMediaSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountUserId != widget.accountUserId) {
      oldWidget.accountUserId?.removeListener(_onAccount);
      widget.accountUserId?.addListener(_onAccount);
      _accountRevoked = true;
      unawaited(_closeRegistered());
    }
    if (oldWidget.lessonId != widget.lessonId ||
        oldWidget.course != widget.course ||
        oldWidget.sceneId != widget.sceneId ||
        oldWidget.variantStem != widget.variantStem ||
        oldWidget.locale != widget.locale ||
        oldWidget.catalog != widget.catalog ||
        oldWidget.bundle != widget.bundle) {
      unawaited(_closeRegistered());
      if (_ownerActive &&
          !_accountRevoked && !_backgrounded && !_nativePlaybackUnconfirmed) {
        _closed = false;
        _open();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _backgrounded = state != AppLifecycleState.resumed;
    if (_backgrounded) {
      unawaited(_closeRegistered());
    } else if (_ownerActive &&
        _closed && !_accountRevoked && !_nativePlaybackUnconfirmed) {
      _closed = false;
      _open();
    }
  }

  void _onAccount() {
    _accountRevoked = true;
    unawaited(_closeRegistered());
  }

  Future<void> _open() async {
    _registerOwnerResource();
    final sceneId = widget.sceneId;
    final variantStem = widget.variantStem;
    if (!_ownerActive ||
        !widget.syntheticPlayback ||
        widget.catalog.isEmpty ||
        _closed ||
        _backgrounded ||
        _accountRevoked ||
        _nativePlaybackUnconfirmed ||
        sceneId == null ||
        variantStem == null) {
      return;
    }
    final turn = ++_epoch;
    try {
      await _retiring;
    } on Object {
      return;
    }
    if (!_ownerActive ||
        !mounted ||
        _closed ||
        _backgrounded ||
        _nativePlaybackUnconfirmed ||
        turn != _epoch) {
      return;
    }
    final media = await widget.catalog.inspect(
      bundle: widget.bundle,
      course: widget.course,
      lessonId: widget.lessonId,
      sceneId: sceneId,
      variantStem: variantStem,
      locale: widget.locale,
    );
    if (!_ownerActive ||
        media == null ||
        !mounted ||
        _closed ||
        _nativePlaybackUnconfirmed ||
        turn != _epoch) {
      return;
    }
    final slot = await _takeNativeSlot();
    if (slot == null) return;
    if (!_ownerActive ||
        !mounted || _closed || _nativePlaybackUnconfirmed || turn != _epoch) {
      _releaseNativeSlot(slot);
      return;
    }
    VideoPlayerController? controller;
    try {
      controller = widget.controllerFactory(media);
      _controller = controller;
      _controllerSlot = slot;
      // video_player keeps a pre-initialization volume and reapplies it as
      // soon as native metadata arrives. Start the player muted as well.
      final initialMute = controller.setVolume(0);
      _nativeCommand = initialMute;
      try {
        await initialMute;
      } finally {
        if (identical(_nativeCommand, initialMute)) _nativeCommand = null;
      }
      if (!_ownerActive ||
          !mounted || _closed || _nativePlaybackUnconfirmed || turn != _epoch) {
        if (_controller == controller) {
          _controller = null;
          _controllerSlot = null;
          _queueRetire(controller, slot);
        }
        return;
      }
      final initialize = controller.initialize();
      _nativeCommand = initialize;
      try {
        await initialize;
      } finally {
        if (identical(_nativeCommand, initialize)) _nativeCommand = null;
      }
      if (!_ownerActive ||
          !mounted ||
          _closed ||
          _nativePlaybackUnconfirmed ||
          turn != _epoch ||
          controller.value.duration.inMilliseconds !=
              media.candidate.durationMs) {
        if (_controller == controller) {
          _controller = null;
          _controllerSlot = null;
          _queueRetire(controller, slot);
        }
        return;
      }
      // Await the native mute before exposing controls or allowing play.
      final verifiedMute = controller.setVolume(0);
      _nativeCommand = verifiedMute;
      try {
        await verifiedMute;
      } finally {
        if (identical(_nativeCommand, verifiedMute)) _nativeCommand = null;
      }
      if (!_ownerActive ||
          !mounted ||
          _closed ||
          _nativePlaybackUnconfirmed ||
          turn != _epoch ||
          controller.value.volume != 0) {
        if (_controller == controller) {
          _controller = null;
          _controllerSlot = null;
          _queueRetire(controller, slot);
        }
        return;
      }
      controller.addListener(_rebuild);
      setState(() {});
    } on Object {
      if (controller != null && _controller == controller) {
        _controller = null;
        _controllerSlot = null;
        _queueRetire(controller, slot);
      } else if (controller == null) {
        _releaseNativeSlot(slot);
      }
    }
  }

  void _rebuild() {
    if (mounted && _ownerActive && !_closed) setState(() {});
  }

  Future<void> _retire(VideoPlayerController controller) async {
    var unconfirmed = _nativePlaybackUnconfirmed;
    final pending = _nativeCommand;
    if (pending != null) {
      try {
        await pending.timeout(_nativeRetireDeadline);
      } on Object {
        // A late initialize/play/pause can otherwise run after the next route
        // receives the native player slot. Keep the process quarantined.
        unconfirmed = true;
      }
    }
    try {
      await controller.pause().timeout(_nativeRetireDeadline);
    } on Object {
      unconfirmed = true;
    }
    try {
      await controller.dispose().timeout(_nativeRetireDeadline);
    } on Object {
      unconfirmed = true;
    }
    // A timeout does not cancel the native operation. Keep this process closed
    // to another demo session until a fresh process can establish ownership.
    if (unconfirmed) {
      _nativePlaybackUnconfirmed = true;
      throw StateError('Native lesson media closure was not confirmed');
    }
  }

  Future<void> _close() {
    _epoch++;
    _closed = true;
    final old = _controller;
    final slot = _controllerSlot;
    _controller = null;
    _controllerSlot = null;
    if (old != null) {
      old.removeListener(_rebuild);
      _queueRetire(old, slot!);
    }
    if (mounted && !_disposing) setState(() {});
    return _retiring;
  }

  void _queueRetire(VideoPlayerController controller, Completer<void> slot) {
    if (_retirementQueued[controller] == true) return;
    _retirementQueued[controller] = true;
    _retiring = _retiring.then((_) async {
      try {
        await _retire(controller);
      } on Object {
        _nativePlaybackUnconfirmed = true;
        rethrow;
      } finally {
        _releaseNativeSlot(slot);
      }
    });
    // Route disposal observes errors; the owner still receives the failing
    // original Future and cannot mistake an uncertain native close for success.
    unawaited(_retiring.then<void>((_) {}, onError: (Object _, StackTrace __) {}));
  }

  @override
  void dispose() {
    _disposing = true;
    widget.accountUserId?.removeListener(_onAccount);
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_closeRegistered());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!_ownerActive ||
        controller == null ||
        !controller.value.isInitialized ||
        _closed ||
        _nativePlaybackUnconfirmed) {
      return const SizedBox.shrink();
    }
    final isTurkish = widget.locale == 'tr';
    return Semantics(
      label: isTurkish
          ? 'Paketli ders gösterimi'
          : 'Packaged lesson demonstration',
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                widget.videoBuilder?.call(controller) ??
                    VideoPlayer(controller),
                ClosedCaption(text: controller.value.caption.text),
              ],
            ),
          ),
          TextButton.icon(
            key: const Key('hatha.lesson.media.playPause'),
            onPressed: _commandPending
                ? null
                : () async {
                    if (!_ownerActive ||
                        _closed ||
                        _nativePlaybackUnconfirmed ||
                        !identical(_controller, controller)) {
                      return;
                    }
                    _commandPending = true;
                    setState(() {});
                    Future<void>? command;
                    try {
                      if (!controller.value.isPlaying) {
                        command = controller.setVolume(0);
                        _nativeCommand = command;
                        await command;
                        if (!_ownerActive ||
                            _closed ||
                            _nativePlaybackUnconfirmed ||
                            !identical(_controller, controller)) {
                          return;
                        }
                        if (controller.value.volume != 0) {
                          throw StateError(
                            'Native media mute was not confirmed',
                          );
                        }
                      }
                      command = controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                      _nativeCommand = command;
                      await command;
                    } on Object {
                      _nativePlaybackUnconfirmed = true;
                      unawaited(_closeRegistered());
                    } finally {
                      if (identical(_nativeCommand, command)) {
                        _nativeCommand = null;
                      }
                      _commandPending = false;
                      if (mounted && _ownerActive && !_closed) {
                        setState(() {});
                      }
                    }
                  },
            icon: Icon(
              controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            label: Text(
              isTurkish
                  ? (controller.value.isPlaying ? 'Duraklat' : 'Oynat')
                  : (controller.value.isPlaying ? 'Pause' : 'Play'),
            ),
          ),
        ],
      ),
    );
  }
}
