// DRAFT ONLY. Four real IO test definitions, Flutter/Dart execution UNRUN.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_appearance.dart';

void main() {
  late Directory directory;
  late File file;
  late FileAppearancePreferenceStore store;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('lissom-theme-synthetic-');
    file = File('${directory.path}/appearance.v1.json');
    store = FileAppearancePreferenceStore(file);
  });
  tearDown(() async { await directory.delete(recursive: true); });

  test('first installation is system without creating preference bytes', () async {
    expect(await store.read(), ThemeMode.system);
    expect(await file.exists(), isFalse);
  });

  test('every mode survives closing/reopening the store', () async {
    for (final mode in ThemeMode.values) {
      await store.write(mode);
      expect(await FileAppearancePreferenceStore(file).read(), mode);
      expect(await File('${file.path}.pending').exists(), isFalse);
    }
  });

  test('unsupported schema is rejected without silently deleting bytes', () async {
    const original = '{"schemaVersion":99,"mode":"dark"}';
    await file.writeAsString(original);
    await expectLater(store.read(), throwsFormatException);
    expect(await file.readAsString(), original);
  });

  test('invalid mode and malformed JSON cannot become a saved choice', () async {
    for (final original in <String>[
      '{"schemaVersion":1,"mode":"neon"}',
      '{"schemaVersion":1,"mode":null}',
      '{broken',
    ]) {
      await file.writeAsString(original);
      await expectLater(store.read(), throwsFormatException);
      expect(await file.readAsString(), original);
    }
  });
}
