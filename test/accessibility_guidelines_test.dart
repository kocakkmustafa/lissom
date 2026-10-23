// Host accessibility smoke: Flutter's own screen-reader/tap-target
// guidelines over the four tabs, the course list of every bundled course and
// the first lesson of each 2026-10-21 extension module. This is a host proxy
// for VoiceOver/TalkBack; it is not a real-device screen-reader acceptance.
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/hatha_course.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/hatha_session_preparation.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

class _Store implements HathaProgressStore {
  _Store(this.records);
  final List<HathaPracticeRecord> records;

  @override
  Future<HathaProgress> read() async =>
      HathaProgress(records: List.unmodifiable(records), unreadableRecords: 0);

  @override
  Future<void> markPracticed(HathaCourse course, String lessonId) async {
    records.add(_record(course, lessonId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

HathaPracticeRecord _record(HathaCourse course, String lessonId) =>
    HathaPracticeRecord(
      lessonId: lessonId,
      courseId: course.id,
      courseVersion: course.version,
      practicedAt: DateTime.utc(2026, 10, 21, 12),
    );

HathaCourse _course(String name) =>
    HathaCourse.parse(File('config/courses/$name.v1.json').readAsStringSync());

Future<void> _pump(WidgetTester tester, Widget home, String language) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      home: home is Scaffold ? home : Scaffold(body: home),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  // Deterministic WCAG check on every platform: each rendered text colour
  // against its actual ancestor background (normal text >= 4.5, large >= 3.0).
  _expectRenderedTextContrast(tester);
  // The pixel-sampling guideline depends on the font rasteriser (Linux CI
  // 39942515908 sampled anti-aliased glyph edges), so it runs where the host
  // rasteriser is the reviewed one (macOS) in addition to the check above.
  if (Platform.isMacOS) {
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }
}

double _channel(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _ratio(Color a, Color b) {
  final double la = _luminance(a), lb = _luminance(b);
  final double hi = math.max(la, lb), lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

Color _over(Color top, Color bottom) {
  final double a = top.a;
  return Color.from(
    alpha: 1,
    red: top.r * a + bottom.r * (1 - a),
    green: top.g * a + bottom.g * (1 - a),
    blue: top.b * a + bottom.b * (1 - a),
  );
}

/// Background candidates behind [element]: translucent layers are composited
/// over the next opaque one; a gradient contributes every stop (worst case).
List<Color> _backgroundsBehind(Element element) {
  final List<List<Color>> layers = <List<Color>>[];
  bool opaque = false;
  void add(List<Color> colors) {
    if (colors.isEmpty || opaque) return;
    layers.add(colors);
    if (colors.every((Color c) => c.a >= 1)) opaque = true;
  }

  List<Color> decoration(Decoration? d) {
    if (d is BoxDecoration) {
      if (d.gradient != null) return d.gradient!.colors;
      if (d.color != null) return <Color>[d.color!];
    }
    return const <Color>[];
  }

  element.visitAncestorElements((Element e) {
    final Widget w = e.widget;
    if (w is ColoredBox) add(<Color>[w.color]);
    if (w is DecoratedBox) add(decoration(w.decoration));
    if (w is Material && w.type != MaterialType.transparency) {
      add(<Color>[w.color ?? Theme.of(e).canvasColor]);
    }
    if (w is Scaffold) {
      add(<Color>[w.backgroundColor ?? Theme.of(e).scaffoldBackgroundColor]);
    }
    return !opaque;
  });
  if (!opaque) add(<Color>[Theme.of(element).scaffoldBackgroundColor]);
  List<Color> result = layers.last;
  for (final List<Color> layer in layers.reversed.skip(1)) {
    result = <Color>[
      for (final Color top in layer)
        for (final Color bottom in result) _over(top, bottom),
    ];
  }
  return result;
}

void _expectRenderedTextContrast(WidgetTester tester) {
  final List<String> failures = <String>[];
  int checked = 0;
  for (final Element element in find.byType(RichText).evaluate()) {
    final RichText rich = element.widget as RichText;
    bool faded = false;
    element.visitAncestorElements((Element e) {
      if (e.widget is Opacity && (e.widget as Opacity).opacity < 1) {
        faded = true; // disabled/decorative, exempt under WCAG 1.4.3
      }
      return !faded;
    });
    if (faded) continue;
    final List<Color> backgrounds = _backgroundsBehind(element);
    void visit(InlineSpan span, TextStyle? inherited) {
      final TextStyle? style = inherited?.merge(span.style) ?? span.style;
      if (span is TextSpan) {
        final String text = span.text ?? '';
        final Color? color = style?.color;
        if (text.trim().isNotEmpty && color != null && color.a > 0) {
          final double size = style?.fontSize ?? 14;
          final bool bold = (style?.fontWeight?.value ?? 400) >= 700;
          final bool large = size >= 18 || (size >= 14 && bold);
          final double needed = large ? 3.0 : 4.5;
          for (final Color bg in backgrounds) {
            checked++;
            final double r = _ratio(_over(color, bg), bg);
            if (r < needed) {
              failures.add(
                '"${text.length > 40 ? text.substring(0, 40) : text}" '
                '${r.toStringAsFixed(2)} < $needed (size $size)',
              );
            }
          }
        }
        span.children?.forEach((InlineSpan c) => visit(c, style));
      }
    }

    visit(rich.text, null);
  }
  expect(checked, greaterThan(0), reason: 'no text colour was checked');
  expect(failures, isEmpty, reason: failures.join('\n'));
}

void main() {
  testWidgets('NEGATIVE TWIN: an unlabelled 10x10 tap target fails', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      ),
    );
    // Evaluate directly: an async guideline matcher cannot be wrapped in isNot.
    final Evaluation size = await androidTapTargetGuideline.evaluate(tester);
    final Evaluation label = await labeledTapTargetGuideline.evaluate(tester);
    expect(size.passed, isFalse, reason: size.reason);
    expect(label.passed, isFalse, reason: label.reason);
    expect(
      _ratio(_over(const Color(0xFF9A9297), Colors.white), Colors.white),
      lessThan(4.5),
      reason: 'the WCAG helper must reject a known low-contrast pair',
    );
    semantics.dispose();
  });

  testWidgets('NEGATIVE TWIN: rendered low-contrast text is rejected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text('faint', style: TextStyle(color: Color(0xFFBBBBBB))),
          ),
        ),
      ),
    );
    expect(
      () => _expectRenderedTextContrast(tester),
      throwsA(isA<TestFailure>()),
    );
  });

  for (final String language in const <String>['en', 'tr']) {
    testWidgets('four tabs meet screen-reader and tap-target '
        'guidelines ($language)', (WidgetTester tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      pinNarrowSurface(tester);
      final facts = factsFromDisk();
      for (final Widget screen in <Widget>[
        HomeScreen(facts: facts, onOpenLibrary: () {}),
        LibraryScreen(facts: facts),
        ProgressScreen(facts: facts),
        ProfileScreen(facts: facts),
      ]) {
        await _pump(tester, screen, language);
        await _expectGuidelines(tester);
      }
      semantics.dispose();
    });

    // Course list for every bundled course, then the first lesson of each new
    // extension module opened through "continue" (prerequisites recorded).
    for (final (String name, String lessonId) in const <(String, String)>[
      ('hatha', 'h01'),
      ('chair-office', 'c13'),
      ('vinyasa-standing', 'v11'),
      ('yin-supported', 'y09'),
      ('ashtanga-foundations', 'a15'),
    ]) {
      testWidgets('$name course list and $lessonId meet guidelines '
          '($language)', (WidgetTester tester) async {
        final SemanticsHandle semantics = tester.ensureSemantics();
        pinNarrowSurface(tester);
        final HathaCourse course = _course(name);
        final _Store store = _Store(<HathaPracticeRecord>[
          for (final HathaLesson lesson in course.lessons.takeWhile(
            (HathaLesson l) => l.id != lessonId,
          ))
            _record(course, lesson.id),
        ]);
        await _pump(
          tester,
          HathaCourseScreen(
            course: course,
            initialProgress: await store.read(),
            storeLoader: () async => store,
          ),
          language,
        );
        await _expectGuidelines(tester);
        await tester.tap(find.byKey(HathaCourseScreen.continueKey));
        await tester.pumpAndSettle();
        final HathaLessonScreen screen = tester.widget<HathaLessonScreen>(
          find.byType(HathaLessonScreen),
        );
        expect(screen.lesson.id, lessonId);
        if (HathaSessionPreparation.requiredFor(lessonId)) {
          expect(
            find.byKey(const Key('hatha.session.preparation')),
            findsOneWidget,
          );
        }
        await _expectGuidelines(tester);
        semantics.dispose();
      });
    }
  }
}
