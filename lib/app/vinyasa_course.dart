import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kVinyasaCourseAssetPath = 'config/courses/vinyasa-standing.v1.json';
const String kVinyasaCourseSha256 = '815b7a2c7205c0b5e5c32ce096c79ad112d98ca78196184b1ced1414e6953191';

/// App-owned text integrity only. Existing Hatha media/source receipts stay
/// unchanged; this course has no media, camera grade or physical acceptance.
Future<HathaCourse> loadVerifiedVinyasaCourse(AssetBundle bundle) async {
  final data = await bundle.load(kVinyasaCourseAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (computeSha256Hex(bytes) != kVinyasaCourseSha256) {
    throw const FormatException('Vinyasa course integrity mismatch');
  }
  final course = HathaCourse.parse(utf8.decode(bytes));
  if (course.id != 'lissom.vinyasa.supported-standing.beginner' || course.version != '1.0.0') {
    throw const FormatException('Unsupported Vinyasa course identity');
  }
  return course;
}
