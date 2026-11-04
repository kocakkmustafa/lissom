import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/camera/camera_catalog_copy.dart';

void main() {
  test('every catalog name and correction has a literal copy pair', () {
    final Map<String, dynamic> c =
        jsonDecode(File('config/yoga/camera-poses.v1.json').readAsStringSync())
            as Map<String, dynamic>;
    final Set<String> keys = <String>{
      for (final dynamic p in c['poses'] as List<dynamic>) ...<String>[
        ((p as Map<String, dynamic>)['name'] as Map<String, dynamic>)['en']
            as String,
        for (final dynamic x in p['corrections'] as List<dynamic>)
          ((x as Map<String, dynamic>)['say'] as Map<String, dynamic>)['en']
              as String,
      ],
    };
    expect(kCameraCatalogCopyKeys, keys);
  });
}
