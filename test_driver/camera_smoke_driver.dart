import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Writes the numbers the device smoke reports (no images) to
/// $LISSOM_CAMERA_SMOKE_OUT.
Future<void> main() => integrationDriver(
  responseDataCallback: (Map<String, dynamic>? data) async {
    final String? out = Platform.environment['LISSOM_CAMERA_SMOKE_OUT'];
    if (out != null) {
      await File(
        out,
      ).writeAsString(const JsonEncoder.withIndent(' ').convert(data));
    }
  },
);
