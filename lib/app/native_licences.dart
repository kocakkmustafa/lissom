import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native libraries bundled through `motion_camera` are not Dart packages, so
/// Flutter's automatic licence collection does not see them. Their Apache-2.0
/// notices are registered here so the in-app licence page is complete.
///
/// iOS: MediaPipeTasksVision 0.10.21 (CocoaPods). Android: MediaPipe
/// tasks-vision 0.10.29 and AndroidX CameraX 1.5.3 (Gradle).
const List<String> kNativeLicensedPackages = <String>[
  'MediaPipe Tasks Vision',
  'AndroidX CameraX',
];

const String kApacheLicenceAsset = 'assets/licenses/apache-2.0.txt';

bool _registered = false;

/// Idempotent: the registry is process-wide and tests may call this twice.
void registerNativeLicences({AssetBundle? bundle}) {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    final String text = await (bundle ?? rootBundle).loadString(
      kApacheLicenceAsset,
    );
    yield LicenseEntryWithLineBreaks(kNativeLicensedPackages, text);
  });
}
