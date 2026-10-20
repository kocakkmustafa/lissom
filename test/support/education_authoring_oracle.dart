import 'dart:convert';
import 'dart:io';

// Frozen author-reviewed parsed and displayed content oracles. Do not regenerate
// from app assets or localization helpers at test runtime: that hides aliases.
final Map<String, dynamic> _educationOracle =
    jsonDecode(
          File(
            'test/fixtures/education_authoring_v1_expected.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

String authoredEducationText(
  String courseId,
  String lessonId,
  String locale,
  String field,
) => _educationText('courses', courseId, lessonId, locale, field);

String displayedEducationText(
  String courseId,
  String lessonId,
  String locale,
  String field,
) => _educationText('displayedCourses', courseId, lessonId, locale, field);

String _educationText(
  String collection,
  String courseId,
  String lessonId,
  String locale,
  String field,
) {
  final courses = _educationOracle[collection] as Map<String, dynamic>;
  final lessons = courses[courseId] as Map<String, dynamic>;
  final languages = lessons[lessonId] as Map<String, dynamic>;
  final values = languages[locale] as Map<String, dynamic>;
  return values[field] as String;
}
