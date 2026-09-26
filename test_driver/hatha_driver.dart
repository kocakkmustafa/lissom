import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final String? output = Platform.environment['MOTION_COURSE_EVIDENCE_DIR'];
  if (output == null ||
      !Directory(output).absolute.path.contains('/scratch/')) {
    throw ArgumentError(
      'Set MOTION_COURSE_EVIDENCE_DIR to a scratch directory',
    );
  }
  final Directory target = await Directory(output).create(recursive: true);
  final List<Map<String, Object>> captures = <Map<String, Object>>[];
  await integrationDriver(
    onScreenshot:
        (String name, List<int> bytes, [Map<String, Object?>? args]) async {
          if (!RegExp(r'^hatha-[a-z-]+$').hasMatch(name) || bytes.isEmpty) {
            return false;
          }
          await File(
            '${target.path}/$name.png',
          ).writeAsBytes(bytes, flush: true);
          captures.add(<String, Object>{
            'file': '$name.png',
            'bytes': bytes.length,
            'sha256': sha256.convert(bytes).toString(),
          });
          return true;
        },
    responseDataCallback: (Map<String, dynamic>? data) => writeResponseData(
      <String, dynamic>{
        ...?data,
        // The PNG is saved once; duplicating every byte in indented JSON
        // inflated four screenshots into a 60 MB receipt.
        'screenshots': captures,
      },
      destinationDirectory: target.path,
      testOutputFilename: 'native-course-response',
    ),
  );
}
