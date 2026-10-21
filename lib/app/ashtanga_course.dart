import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kAshtangaCourseAssetPath =
    'config/courses/ashtanga-foundations.v1.json';
const String kAshtangaCourseId = 'lissom.ashtanga.foundations.beginner';
const String kAshtangaCourseSha256 =
    '889d9f22f4006c151ff3ae1a980dcc7b8b00076035a99bdb3f9154b990fb75b1';

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
