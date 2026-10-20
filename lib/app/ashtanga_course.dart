import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kAshtangaCourseAssetPath =
    'config/courses/ashtanga-foundations.v1.json';
const String kAshtangaCourseId = 'lissom.ashtanga.foundations.beginner';
const String kAshtangaCourseSha256 =
    '913fe8864c0e71a77567e17a14983e334273c02158662413133a6755cafe8c07';

/// App-owned text integrity; no traditional-series, physical or media approval.
Future<HathaCourse> loadVerifiedAshtangaCourse(AssetBundle bundle) async {
  final data = await bundle.load(kAshtangaCourseAssetPath);
  final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  if (computeSha256Hex(bytes) != kAshtangaCourseSha256) {
    throw const FormatException('Ashtanga course integrity mismatch');
  }
  final course = HathaCourse.parse(utf8.decode(bytes));
  if (course.id != kAshtangaCourseId || course.version != '1.0.0') {
    throw const FormatException('Unsupported Ashtanga course identity');
  }
  return course;
}
