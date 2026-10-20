// DRAFT / SDK UNRUN. Real postmount readiness; detached parsing is insufficient.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_localizations.dart';

const themeCatalogAnchor = Key('theme.catalog.mounted.body');

final class ActualThemeCatalogBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(File(key).readAsBytesSync());
}

Future<bool> waitForActiveThemeCatalog(
  WidgetTester tester, {
  required Finder anchor,
  required String tag,
  Iterable<String> requiredKeys = const <String>['Profile'],
  LissomLocalizations? expected,
  Duration deadline = const Duration(seconds: 10),
}) async {
  final ready = await tester.runAsync(() async {
    final elapsed = Stopwatch()..start();
    while (elapsed.elapsed < deadline) {
      // AssetBundle >50 KiB isolate work and framework delegates must both get
      // real-clock time after mounting; fake-clock settling is not that proof.
      await tester.pump();
      final elements = anchor.evaluate();
      if (elements.length == 1) {
        final context = elements.single;
        final active = LissomLocalizations.maybeOf(context);
        if (active != null &&
            active.catalogAvailable &&
            active.tag == tag &&
            canonicalLocaleTag(Localizations.localeOf(context)) == tag &&
            requiredKeys.every(
              (key) =>
                  active.lookup(key) != null &&
                  (expected == null ||
                      active.lookup(key) == expected.lookup(key)),
            )) {
          return true;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return false;
  });
  return ready == true;
}

Future<void> pumpThemeWidget(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  expect(
    await waitForActiveThemeCatalog(
      tester,
      anchor: find.byKey(themeCatalogAnchor),
      tag: 'en',
    ),
    isTrue,
    reason: 'The actual mounted English delegate and body must be ready.',
  );
}
