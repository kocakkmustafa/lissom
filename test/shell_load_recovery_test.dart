import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  testWidgets(
    'a failed facts load can retry without exposing raw exception data',
    (tester) async {
      pinNarrowSurface(tester);
      final pending = Completer<AppFacts>();
      int loads = 0;
      Future<AppFacts> loader() {
        loads++;
        if (loads == 1)
          return Future<AppFacts>.error(StateError('PRIVATE_PATH_MARKER'));
        return pending.future;
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: LissomShell(loader: loader),
        ),
      );
      await tester.pumpAndSettle();
      expect(loads, 1);
      expect(find.byKey(const Key('shell.loadFailure')), findsOneWidget);
      expect(find.textContaining('PRIVATE_PATH_MARKER'), findsNothing);
      await tester.tap(find.byKey(const Key('shell.retryLoad')));
      await tester.pump();
      expect(loads, 2);
      expect(find.byKey(const Key('shell.retryLoad')), findsNothing);
      pending.complete(factsFromDisk());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byKey(const Key('shell.loadFailure')), findsNothing);
      expect(loads, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
