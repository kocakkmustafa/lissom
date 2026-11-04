import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

import 'side_figure.dart';

/// Per-frame cost of features + coach on this machine. The phone number is
/// measured on device (docs/camera/CIHAZ-SMOKE.tr.md); this keeps a host
/// regression guard well below one 30 fps frame (33 ms).
void main() {
  test('features + coach cost per frame', () {
    final CameraPoseCatalog cat = CameraPoseCatalog.parse(
      File('../../config/yoga/camera-poses.v1.json').readAsStringSync(),
    );
    final CameraCoach coach = CameraCoach(
      catalog: cat,
      pose: cat.pose('mountain')!,
    );
    const int n = 3000;
    final Stopwatch sw = Stopwatch()..start();
    for (int i = 0; i < n; i++) {
      final int t = i * 33333;
      coach.add(sideFigure(tUs: t, trunkLeanDeg: (i % 20) - 10), kPortrait, t);
    }
    sw.stop();
    final double usPerFrame = sw.elapsedMicroseconds / n;
    // ignore: avoid_print
    print('camera coach host cost: ${usPerFrame.toStringAsFixed(1)} us/frame');
    expect(usPerFrame, lessThan(2000));
  });
}
