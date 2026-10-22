import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/native_licences.dart';
import 'package:lissom/app/profile_screen.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'native MediaPipe/CameraX notices are registered once with Apache-2.0',
    () async {
      registerNativeLicences();
      registerNativeLicences(); // idempotent
      final List<LicenseEntry> native = <LicenseEntry>[
        await for (final LicenseEntry e in LicenseRegistry.licenses)
          if (e.packages.contains('MediaPipe Tasks Vision')) e,
      ];
      expect(native, hasLength(1));
      expect(native.single.packages, containsAll(kNativeLicensedPackages));
      final String text = native.single.paragraphs
          .map((LicenseParagraph p) => p.text)
          .join('\n');
      expect(text, contains('Apache License'));
      expect(text, contains('Version 2.0, January 2004'));
      expect(text, contains('END OF TERMS AND CONDITIONS'));
    },
  );

  for (final String language in const <String>['en', 'tr']) {
    testWidgets('profile opens the open-source licence page ($language)', (
      WidgetTester tester,
    ) async {
      pinTallSurface(tester, height: 6000);
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: buildLissomTheme(),
          home: Scaffold(body: ProfileScreen(facts: factsFromDisk())),
        ),
      );
      await tester.pumpAndSettle();
      final Finder entry = find.byKey(ProfileScreen.licencesEntryKey);
      expect(entry, findsOneWidget);
      expect(
        find.descendant(
          of: entry,
          matching: find.text(
            language == 'tr'
                ? 'Açık kaynak lisansları'
                : 'Open-source licences',
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
