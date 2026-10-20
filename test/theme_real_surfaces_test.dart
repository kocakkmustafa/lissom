// DRAFT ONLY: these definitions require applying the proposed app sources.
// No SDK invocation or PASS is claimed. Reuse real config fixture, no camera.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/appearance_settings_card.dart';
import 'package:lissom/app/lissom_appearance.dart';
import 'package:lissom/app/lissom_palette.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/lissom_localizations.dart';
import 'package:lissom/app/hatha_knowledge_diagrams.dart';
import 'package:lissom/app/shell.dart';

import 'support/contrast.dart';
import 'support/facts_from_disk.dart';
import 'support/theme_catalog_readiness.dart';
import 'lissom_appearance_test.dart' show MemoryAppearanceStore;

Widget themed(Widget body, Brightness brightness, {bool reduce = false}) =>
    MaterialApp(
      theme: buildLissomTheme(brightness: brightness),
      locale: const Locale('en'),
      localizationsDelegates: [
        LissomLocalizationsDelegate(bundle: ActualThemeCatalogBundle()),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: KeyedSubtree(
        key: themeCatalogAnchor,
        child: Scaffold(body: body),
      ),
    );

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('actual four-tab shell uses the $brightness palette', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final facts = factsFromDisk();
      await pumpThemeWidget(
        tester,
        themed(LissomShell(loader: () async => facts), brightness),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.byType(NavigationDestination),
        findsNWidgets(facts.ia.tabs.length),
      );
      final p = brightness == Brightness.dark
          ? LissomPalette.dark
          : LissomPalette.light;
      for (var i = 0; i < facts.ia.tabs.length; i++) {
        await tester.tap(find.byType(NavigationDestination).at(i));
        await tester.pump();
        final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(nav.backgroundColor, p.card);
        expect(nav.indicatorColor, p.selection);
        expect(
          find.byType(LissomCard),
          findsWidgets,
          reason: 'Positive anchor: an actual tab surface was built.',
        );
        final card = find.byType(LissomCard).first;
        final box = tester.widget<DecoratedBox>(
          find.descendant(of: card, matching: find.byType(DecoratedBox)).first,
        );
        final decoration = box.decoration as BoxDecoration;
        if (decoration.gradient == null) {
          expect(decoration.color, p.card);
        }
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets(
      'actual filled/disabled button labels retain $brightness contrast',
      (tester) async {
        await pumpThemeWidget(
          tester,
          themed(
            Column(
              children: [
                FilledButton(
                  key: const Key('enabled'),
                  onPressed: () {},
                  child: const Text('Enabled'),
                ),
                const FilledButton(
                  key: Key('disabled'),
                  onPressed: null,
                  child: Text('Disabled'),
                ),
              ],
            ),
            brightness,
          ),
        );
        for (final key in ['enabled', 'disabled']) {
          final button = find.byKey(Key(key));
          final material = tester.widget<Material>(
            find.descendant(of: button, matching: find.byType(Material)).first,
          );
          final text = find.descendant(of: button, matching: find.byType(Text));
          final widget = tester.widget<Text>(text);
          final effective = DefaultTextStyle.of(
            tester.element(text),
          ).style.merge(widget.style);
          expect(material.color, isNotNull);
          expect(effective.color, isNotNull);
          expect(
            contrastRatio(effective.color!, material.color!),
            greaterThanOrEqualTo(4.5),
          );
        }
      },
    );

    testWidgets(
      'actual input error/focus states use $brightness semantic pairs',
      (tester) async {
        final focus = FocusNode();
        addTearDown(focus.dispose);
        await pumpThemeWidget(
          tester,
          themed(
            TextField(
              key: const Key('actual-form'),
              focusNode: focus,
              decoration: const InputDecoration(
                labelText: 'Recall',
                errorText: 'Required',
              ),
            ),
            brightness,
          ),
        );
        focus.requestFocus();
        await tester.pump();
        final context = tester.element(find.byKey(const Key('actual-form')));
        final t = Theme.of(context);
        final p = LissomPalette.of(context);
        expect(t.inputDecorationTheme.errorStyle!.color, p.error);
        final border =
            t.inputDecorationTheme.focusedErrorBorder! as OutlineInputBorder;
        expect(
          contrastRatio(border.borderSide.color, p.card),
          greaterThanOrEqualTo(3),
        );
        expect(find.text('Required'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'actual appearance dialog reports $brightness write failure and can close',
      (tester) async {
        final store = MemoryAppearanceStore()
          ..writeError = StateError('internal-diagnostic-do-not-render');
        final c = LissomAppearanceController(store: store);
        addTearDown(c.dispose);
        await c.initialize();
        await pumpThemeWidget(
          tester,
          themed(AppearanceSettingsCard(controller: c), brightness),
        );
        await tester.tap(find.byKey(const Key('profile.appearance.choose')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('profile.appearance.dialog')),
          findsOneWidget,
        );
        await tester.tap(
          find.byKey(const Key('profile.appearance.option.dark')),
        );
        await tester.pump();
        expect(
          find.byKey(const Key('profile.appearance.writeFailure')),
          findsOneWidget,
        );
        expect(
          find.textContaining('internal-diagnostic-do-not-render'),
          findsNothing,
        );
        expect(c.mode, ThemeMode.system);
        await tester.tap(find.byKey(const Key('profile.appearance.close')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('profile.appearance.dialog')),
          findsNothing,
        );
      },
    );
  }

  testWidgets(
    'real knowledge painter repaints for brightness; chart meaning stays neutral',
    (tester) async {
      await pumpThemeWidget(
        tester,
        themed(const HathaKnowledgeDiagrams(lessonId: 'h54'), Brightness.light),
      );
      final light = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((w) => w.painter != null)
          .first
          .painter!;
      await pumpThemeWidget(
        tester,
        themed(const HathaKnowledgeDiagrams(lessonId: 'h54'), Brightness.dark),
      );
      final dark = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((w) => w.painter != null)
          .first
          .painter!;
      expect(dark.shouldRepaint(light), isTrue);
      // No improvement/clinical judgement, numeric gauge, or camera enablement
      // is introduced by theme. Existing safety/gauge tests remain required.
    },
  );

  testWidgets(
    'reduced loading has equivalent semantics without a rotating spinner',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      await pumpThemeWidget(
        tester,
        themed(
          const LissomLoadingIndicator(label: 'Loading…'),
          Brightness.dark,
          reduce: true,
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.bySemanticsLabel('Loading…'), findsOneWidget);
    },
  );

  testWidgets(
    'custom card keeps keyboard activation and a visible focus outline',
    (tester) async {
      var activated = 0;
      await pumpThemeWidget(
        tester,
        themed(
          LissomFocusFrame(
            child: InkWell(
              onTap: () => activated++,
              child: const LissomCard(child: Text('Open')),
            ),
          ),
          Brightness.dark,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final frames = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((w) => w.decoration is BoxDecoration)
          .map((w) => w.decoration as BoxDecoration)
          .where((d) => d.border != null);
      expect(frames, isNotEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(activated, 1);
    },
  );
}
