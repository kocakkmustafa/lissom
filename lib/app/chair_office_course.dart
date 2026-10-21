import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kChairOfficeCourseAssetPath = 'config/courses/chair-office.v1.json';
const String kChairOfficeCourseSha256 = '2663ec6308a65f6e4131cf474ca2ae594bbf34bdff7e4d3c484ad1dcf6e97853';

/// App-owned text integrity only. Existing Hatha media/source receipts stay
/// unchanged; this course has no media, camera grade or physical acceptance.
Future<HathaCourse> loadVerifiedChairOfficeCourse(AssetBundle bundle) async {
  final data = await bundle.load(kChairOfficeCourseAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (computeSha256Hex(bytes) != kChairOfficeCourseSha256) {
    throw const FormatException('Chair/office course integrity mismatch');
  }
  final course = HathaCourse.parse(utf8.decode(bytes));
  if (course.id != 'lissom.chair-office.beginner' || course.version != '1.0.0') {
    throw const FormatException('Unsupported chair/office course identity');
  }
  return course;
}
