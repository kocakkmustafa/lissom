// Actual startup against disk bytes; isolated test-owned scope only.
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/yin_course.dart';

final class _DiskBundle extends CachingAssetBundle {
  _DiskBundle({this.missingYin = false, this.tamperYin = false});
  final bool missingYin;
  final bool tamperYin;
  final requested = <String>[];
  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    if (key == kYinCourseAssetPath && missingYin) {
      throw StateError('Missing actual Yin asset');
    }
    final bytes = File(key).readAsBytesSync();
    if (key == kYinCourseAssetPath && tamperYin) {
      bytes[bytes.length - 1] = 32; // Valid JSON, wrong integrity identity.
    }
    final padded = Uint8List(bytes.length + 8)
      ..setRange(4, bytes.length + 4, bytes);
    return ByteData.view(padded.buffer, 4, bytes.length);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late LissomOwnerRegistry registry;
  const fixtureOwner = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  setUp(() async {
    root = await Directory.systemTemp.createTemp('lissom-yin-facts-');
    registry = LissomOwnerRegistry(canonicalSupportDirectory: root);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => root.path);
  });
  tearDown(() async {
    registry.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'), null);
    await root.delete(recursive: true); // Only this test's own temporary root.
  });
  test('actual AppFacts startup loads all five exact course assets', () async {
    final bundle = _DiskBundle();
    final facts = await AppFacts.load(
      scope: registry.openScope(fixtureOwner), bundle: bundle);
    expect(facts.hatha!.id, 'lissom.hatha.foundations');
    expect(facts.chairOffice!.id, 'lissom.chair-office.beginner');
    expect(facts.vinyasa!.id, 'lissom.vinyasa.supported-standing.beginner');
    expect(facts.yin!.id, 'lissom.yin.supported.beginner');
    expect(facts.ashtanga!.id, 'lissom.ashtanga.foundations.beginner');
    expect(facts.yin!.lessons.map((lesson) => lesson.id).toList(),
      List.generate(12, (index) => 'y${(index + 1).toString().padLeft(2, '0')}'));
    expect(bundle.requested, contains(kYinCourseAssetPath));
    expect(facts.hathaProgress!.records, isEmpty);
  });
  test('actual AppFacts startup rejects missing Yin', () async {
    await expectLater(AppFacts.load(scope: registry.openScope(fixtureOwner),
      bundle: _DiskBundle(missingYin: true)), throwsStateError);
  });
  test('actual AppFacts startup rejects changed Yin bytes', () async {
    await expectLater(AppFacts.load(scope: registry.openScope(fixtureOwner),
      bundle: _DiskBundle(tamperYin: true)), throwsFormatException);
  });
}
