import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_release_policy.dart';

/// LIS-P1-15: while the camera trial is closed, the app manifest must not
/// declare the Android CAMERA permission or camera uses-feature lines, and it
/// must carry the removal directive (camera libraries re-add CAMERA to the
/// merged manifest). Opening `LISSOM_CAMERA_TRIAL` in a store build updates
/// this test together with `docs/camera/ANDROID-KAMERA-IZNI.tr.md`.
void main() {
  final manifest = File(
    'android/app/src/main/AndroidManifest.xml',
  ).readAsStringSync().replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

  test('camera trial flag is closed by default', () {
    expect(lissomCameraCoachingTrialOpen, isFalse);
  });

  test('closed camera build removes CAMERA from the merged manifest', () {
    expect(lissomCameraCoachingTrialOpen, isFalse);
    expect(
      manifest,
      contains('xmlns:tools="http://schemas.android.com/tools"'),
    );
    final cameraTags = RegExp(r'<uses-permission\b[^>]*>')
        .allMatches(manifest)
        .map((m) => m.group(0)!)
        .where((t) => t.contains('android.permission.CAMERA'))
        .toList();
    expect(cameraTags, hasLength(1), reason: 'removal directive must exist');
    expect(cameraTags.single, contains('tools:node="remove"'));
  });

  test('closed camera build declares no camera uses-feature', () {
    expect(manifest, isNot(contains('android.hardware.camera')));
  });
}
