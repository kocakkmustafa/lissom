import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kYinCourseAssetPath = 'config/courses/yin-supported.v1.json';
const String kYinCourseSha256 =
    'ed346669025d106fcd255093adb89983925ddc46750d80730c7998f7cc2f5770';

/// App-owned text integrity only. Existing Hatha media/source receipts stay
/// unchanged; this course has no media, camera grade or physical acceptance.
Future<HathaCourse> loadVerifiedYinCourse(AssetBundle bundle) async {
  final data = await bundle.load(kYinCourseAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (computeSha256Hex(bytes) != kYinCourseSha256) {
    throw const FormatException('Yin course integrity mismatch');
  }
  final course = HathaCourse.parse(utf8.decode(bytes));
  if (course.id != 'lissom.yin.supported.beginner' ||
      course.version != '1.0.0') {
    throw const FormatException('Unsupported Yin course identity');
  }
  return course;
}
