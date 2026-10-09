import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kYinCourseAssetPath = 'config/courses/yin-supported.v1.json';
const String kYinCourseSha256 = '3b5455c6f5b3f459e64e7f3f586f37193dd9b0a8c72b548d621f091b36b570e6';

/// App-owned text integrity only. Existing Hatha media/source receipts stay
/// unchanged; this course has no media, camera grade or physical acceptance.
Future<HathaCourse> loadVerifiedYinCourse(AssetBundle bundle) async {
  final data = await bundle.load(kYinCourseAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (computeSha256Hex(bytes) != kYinCourseSha256) {
    throw const FormatException('Yin course integrity mismatch');
  }
  final course = HathaCourse.parse(utf8.decode(bytes));
  if (course.id != 'lissom.yin.supported.beginner' || course.version != '1.0.0') {
    throw const FormatException('Unsupported Yin course identity');
  }
  return course;
}
