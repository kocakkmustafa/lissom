// DRAFT ONLY / SDK UNRUN. Real RadioGroup + actual settings dialog semantics.
import 'dart:async';
import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/appearance_settings_card.dart';
import 'package:lissom/app/lissom_appearance.dart';

import 'lissom_appearance_test.dart' show MemoryAppearanceStore;
import 'theme_real_surfaces_test.dart' show themed;
import 'support/theme_catalog_readiness.dart';

bool _focusInside(Key key) {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) {
    return false;
  }
  var found = context.widget.key == key;
  context.visitAncestorElements((element) {
    found = found || element.widget.key == key;
    return !found;
  });
  return found;
}

void main() {
  testWidgets(
    'arrow key selects through group, pending write disables real radios',
    (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);
      final store = MemoryAppearanceStore()..pendingWrite = Completer<void>();
      final c = LissomAppearanceController(store: store);
      addTearDown(c.dispose);
      await c.initialize();
      await pumpThemeWidget(
        tester,
        themed(AppearanceSettingsCard(controller: c), Brightness.dark),
      );
      await tester.tap(find.byKey(const Key('profile.appearance.choose')));
      await tester.pumpAndSettle();
      expect(find.byType(RadioGroup<ThemeMode>), findsOneWidget);
      const systemKey = Key('profile.appearance.option.system');
      for (var i = 0; i < 12 && !_focusInside(systemKey); i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(
        _focusInside(systemKey),
        isTrue,
        reason: 'The actual selected radio must receive keyboard focus.',
      );
      // RadioListTile merges its Radio semantics; inspect the exported data.
      final selectedBefore = tester
          .getSemantics(find.byKey(systemKey))
          .getSemanticsData();
      expect(
        selectedBefore.flagsCollection.isChecked == CheckedState.isTrue,
        isTrue,
      );
      expect(selectedBefore.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(c.isSaving, isTrue);
      expect(store.writes, 1);
      expect(
        c.mode,
        ThemeMode.system,
        reason: 'A pending write cannot look saved.',
      );
      for (final mode in ThemeMode.values) {
        final tile = find.byKey(Key('profile.appearance.option.${mode.name}'));
        expect(tester.widget<RadioListTile<ThemeMode>>(tile).enabled, isFalse);
        expect(
          tester.getSemantics(tile).getSemanticsData().flagsCollection.isEnabled ==
              Tristate.isTrue,
          isFalse,
        );
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(
        store.writes,
        1,
        reason: 'Disabled appearance is not a no-op callback disguise.',
      );
      await tester.tap(find.byKey(const Key('profile.appearance.close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profile.appearance.dialog')), findsNothing);
      store.pendingWrite!.complete();
      await tester.pump();
      expect(c.mode, ThemeMode.light);
    },
  );
}
