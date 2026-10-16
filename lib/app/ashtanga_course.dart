import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:motion_content/motion_content.dart';

import 'hatha_course.dart';

const String kAshtangaCourseAssetPath =
    'config/courses/ashtanga-foundations.v1.json';
const String kAshtangaCourseId = 'lissom.ashtanga.foundations.beginner';
const String kAshtangaCourseSha256 =
    'dd5004b1760ea460e2ead4d16790239ffb9fbad45407d9ff4cd8fcf08a2b1bf7';

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
