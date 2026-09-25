import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/locale_text.dart';

import 'support/facts_from_disk.dart';

void main() {
  testWidgets('Turkish copy covers real sided records and verdict limits', (
    WidgetTester tester,
  ) async {
    final AppFacts facts = factsFromDisk();
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (BuildContext c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(
      configText(context, facts.testNameFor('overhead_reach:right')),
      'Yukarı uzanma · sağ',
    );
    expect(
      configText(context, facts.testNameFor('overhead_reach:left')),
      'Yukarı uzanma · sol',
    );
    expect(
      configText(context, facts.testNameFor('unknown_test:right')),
      'unknown_test:right · right',
    );

    final family = facts.ia.families.firstWhere(
      (family) => family.id == 'assessment_battery',
    );
    final claims = family.honestyBox.measured;
    final authoredCopy = <String>[
      family.title,
      family.intro,
      for (final claim in claims) claim.claim,
      for (final line in family.honestyBox.notMeasured) line.claim,
      for (final test in facts.battery.tests.values) ...<String>[
        test.name,
        test.instruction,
      ],
    ];
    for (final source in authoredCopy) {
      expect(configText(context, source), isNot(source), reason: source);
    }
    final notes = claims
        .map(facts.verdictNoteFor)
        .whereType<String>()
        .toList(growable: false);
    expect(notes, isNotEmpty);
    for (final note in notes) {
      expect(configText(context, note), isNot(note));
    }
    expect(
      configText(
        context,
        'Of the 3 tests behind this line, 1 is compared against a reference '
        'range and 2 are reported without one — the second kind carries no '
        'verdict.',
      ),
      'Bu satırın dayandığı 3 testin 1 tanesi referans aralığıyla '
      'karşılaştırılır; 2 tanesi karşılaştırılmadan bildirilir. '
      'İkinci gruba ilişkin bir hüküm verilmez.',
    );
  });
}
