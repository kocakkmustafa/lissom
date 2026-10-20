// DRAFT ONLY / UNRUN: preserve the actual summary's judgement boundaries.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/battery_summary_view.dart';
import 'package:lissom/app/lissom_palette.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/contrast.dart';
import 'support/facts_from_disk.dart';
import 'support/theme_catalog_readiness.dart';
import 'theme_real_surfaces_test.dart' show themed;

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'actual battery sections retain meaning and contrast in $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(390, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final summary = BatterySummary.from(
          battery: batteryFromDisk(),
          results: {
            'lateral_bend': AssessmentResult.measured(
              testId: 'lateral_bend',
              side: 'right',
              value: 10,
              unit: 'deg',
              provenance: const {'test': 'synthetic'},
              bandFloors: const {'low': 18, 'normal': 26},
            ),
            'overhead_reach': AssessmentResult.measured(
              testId: 'overhead_reach',
              side: 'right',
              value: 150,
              unit: 'deg',
              provenance: const {'test': 'synthetic'},
              lessonClass: 'measurementOnly',
            ),
            'deep_squat': AssessmentResult.notMeasured(
              testId: 'deep_squat',
              side: 'bilateral',
              code: ResultCode.trackingLost,
              provenance: const {'test': 'synthetic'},
            ),
          },
        );
        await pumpThemeWidget(
          tester,
          themed(BatterySummaryView(summary: summary), brightness),
        );
        expect(
          find.byKey(BatterySummaryView.belowRangeSectionKey),
          findsOneWidget,
        );
        expect(
          find.byKey(BatterySummaryView.notComparedSectionKey),
          findsOneWidget,
        );
        expect(
          find.byKey(BatterySummaryView.notMeasuredSectionKey),
          findsOneWidget,
        );
        final p = brightness == Brightness.dark
            ? LissomPalette.dark
            : LissomPalette.light;
        for (final entry in <String, (String, Color, int?)>{
          'belowRange': ('lateral_bend', p.cardWarmEnd, 3),
          'notCompared': ('overhead_reach', p.cardNeutralEnd, null),
          'notMeasured': ('deep_squat', p.card, 2),
        }.entries) {
          final row = find.byKey(
            BatterySummaryView.rowKey(entry.key, entry.value.$1),
          );
          expect(row, findsOneWidget);
          expect(
            tester.widget(row),
            isA<Column>(),
            reason: 'Semantic row shape stays unchanged.',
          );
          final texts = find.descendant(of: row, matching: find.byType(Text));
          if (entry.value.$3 != null) {
            expect(texts, findsNWidgets(entry.value.$3!));
          }
          for (final element in tester.elementList(texts)) {
            final text = element.widget as Text;
            final style = DefaultTextStyle.of(element).style.merge(text.style);
            expect(style.color, isNotNull);
            expect(
              contrastRatio(style.color!, entry.value.$2),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
