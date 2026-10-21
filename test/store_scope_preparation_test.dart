import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> readObject(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, dynamic>();

void main() {
  final assets =
      Directory('config/courses')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('both store drafts bind every bundled course and current bytes', () {
    expect(assets, hasLength(5));
    for (final path in [
      'docs/store/listing.json',
      'docs/store/listing.tr-TR.json',
    ]) {
      final listing = readObject(path);
      final scope = (listing[r'$courseCatalogPreparationCurrent'] as Map)
          .cast<String, dynamic>();
      final rows = (scope['courses'] as List).cast<Map<String, dynamic>>();
      expect(
        rows.map((row) => row['asset']).toSet(),
        assets.map((file) => file.path).toSet(),
      );
      var lessons = 0;
      for (final file in assets) {
        final course = readObject(file.path);
        final modules = course['modules'] as List;
        final count = modules.fold<int>(
          0,
          (total, module) => total + (module['lessons'] as List).length,
        );
        lessons += count;
        final row = rows.singleWhere((row) => row['asset'] == file.path);
        expect(row['id'], course['id']);
        expect(row['version'], course['version']);
        expect(
          row['sha256'],
          sha256.convert(file.readAsBytesSync()).toString(),
        );
        expect(row['lessonCount'], count);
        expect(row['moduleCount'], modules.length);
      }
      expect(scope['courseCount'], assets.length);
      expect(scope['lessonCount'], lessons);
      expect(lessons, 120);
      expect(scope['mediaIncluded'], isFalse);
      expect(scope['cameraAssessmentAvailable'], isFalse);
      expect(scope['physicalDeviceAccepted'], isFalse);
      expect(scope['providerListingUpdated'], isFalse);
    }
  });

  test(
    'privacy draft covers the same five local journals without cloud claims',
    () {
      final privacy = readObject('docs/store/privacy-draft.json');
      expect(
        (privacy['courseAssets'] as List).toSet(),
        assets.map((file) => file.path).toSet(),
      );
      final local = privacy['localOnly'] as Map;
      final progress = local['courseProgress'] as Map;
      expect(progress['journal'], 'hatha_progress.jsonl');
      expect(progress['courseIdentityFields'], ['courseId', 'courseVersion']);
      expect(progress['guestAccountScoped'], isTrue);
      expect(progress['serverSynced'], isFalse);
      final source = File('lib/app/hatha_progress.dart').readAsStringSync();
      expect(source, contains('r.courseId == course.id'));
      expect(source, contains('r.courseVersion == course.version'));
      expect(local['cameraAndLandmarks'], isTrue);
    },
  );

  test(
    'privacy draft preserves all six declared types, tracking off and draft',
    () {
      final privacy = readObject('docs/store/privacy-draft.json');
      final manifest = File(
        privacy['appleManifestSource'] as String,
      ).readAsStringSync();
      final types = RegExp(
        r'<key>NSPrivacyCollectedDataType</key>\s*<string>NSPrivacyCollectedDataType(\w+)</string>',
      ).allMatches(manifest).map((match) => match.group(1)).toSet();
      expect((privacy['appleCollectedTypes'] as List).toSet(), types);
      expect(types, hasLength(6));
      expect(privacy['purpose'], 'AppFunctionality');
      expect(privacy['linked'], isTrue);
      expect(privacy['tracking'], isFalse);
      expect(privacy['draftOnly'], isTrue);
      expect(privacy['formsPublished'], isFalse);
      expect(
        (privacy['monetization'] as Map).values.every(
          (value) => value == false,
        ),
        isTrue,
      );
      expect(
        (privacy['accountDeletion'] as Map)['sharedAcrossFiveMotionApps'],
        isTrue,
      );
    },
  );
}
