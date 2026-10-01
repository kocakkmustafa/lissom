import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_source_projection_pin.dart';

Future<Uint8List> _assetBytes(String path) async {
  final data = await rootBundle.load(path);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Flutter bundle carries the exact source-only Lissom inputs', () async {
    final courseBytes = await _assetBytes(LissomSourceProjectionPin.coursePath);
    final sliceBytes = await _assetBytes(LissomSourceProjectionPin.slicePath);
    final projectionBytes = await _assetBytes(
      LissomSourceProjectionPin.projectionPath,
    );
    expect(sliceBytes.length, 307530);
    expect(projectionBytes.length, 264229);
    expect(
      sha256.convert(courseBytes).toString(),
      LissomSourceProjectionPin.courseSha256,
    );
    expect(
      sha256.convert(sliceBytes).toString(),
      LissomSourceProjectionPin.sliceSha256,
    );
    expect(
      sha256.convert(projectionBytes).toString(),
      LissomSourceProjectionPin.projectionSha256,
    );

    final course = jsonDecode(utf8.decode(courseBytes)) as Map<String, dynamic>;
    final slice = jsonDecode(utf8.decode(sliceBytes)) as Map<String, dynamic>;
    final projection =
        jsonDecode(utf8.decode(projectionBytes)) as Map<String, dynamic>;
    expect(slice['appId'], LissomSourceProjectionPin.appId);
    expect(projection['appId'], LissomSourceProjectionPin.appId);
    expect(
      (course['modules'] as List<dynamic>)
          .expand(
            (module) =>
                (module as Map<String, dynamic>)['lessons'] as List<dynamic>,
          )
          .length,
      LissomSourceProjectionPin.lessonCount,
    );
    expect(slice['courseSourceSHA256'], LissomSourceProjectionPin.courseSha256);
    expect(projection['courseSourceSHA256'], slice['courseSourceSHA256']);
    expect(
      projection['sourceCatalogSHA256'],
      LissomSourceProjectionPin.sourceCatalogSha256,
    );
    expect(
      projection['sourceManifestSHA256'],
      LissomSourceProjectionPin.sourceManifestSha256,
    );
    expect(
      (slice['lessons'] as List<dynamic>).length,
      LissomSourceProjectionPin.lessonCount,
    );
    final rows = projection['rows'] as List<dynamic>;
    expect(rows.length, LissomSourceProjectionPin.variantCount);
    expect(
      rows.map((row) => (row as List<dynamic>)[1]).toSet().length,
      LissomSourceProjectionPin.lessonCount,
    );
    expect(
      rows.map((row) => (row as List<dynamic>)[3]).toSet().length,
      LissomSourceProjectionPin.sceneCount,
    );
    final heldRows = rows
        .where((row) => (row as List<dynamic>)[10] == true)
        .toList();
    expect(heldRows.length, LissomSourceProjectionPin.heldCount);
    expect(heldRows.map((row) => (row as List<dynamic>)[1]).toSet(), {'h30'});
  });
}
