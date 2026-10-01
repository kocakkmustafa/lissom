/// App-owned first-course source identity. Matching it does not approve
/// demonstration media or a yoga form verdict.
abstract final class LissomSourceProjectionPin {
  static const appId = 'lissom';
  static const coursePath = 'config/courses/hatha.v1.json';
  static const slicePath = 'assets/motion_content/lissom.source-slice.v1.json';
  static const projectionPath =
      'assets/motion_content/lissom.source-projection.v1.json';

  static const courseSha256 =
      'be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c';
  static const sliceSha256 =
      'e2cfc724e7032d9a465e553af7227609c0f2c65414123a56af7139cdfa0694e8';
  static const projectionSha256 =
      '088b726a397b195a4bd531b747daf18eab5c5990a5766d5297d36a0eae3fc322';
  static const sourceCatalogSha256 =
      '791bfea8e1479307794bcf8799cf703a7a840bcd3058c1a0d7fdf065d32d8594';
  // Preproduction source manifest; eight h30 variants remain held.
  static const sourceManifestSha256 =
      'd887683c9a9b9bdb8d4ab7c51cdc5a5b4b4de6a918079e4cfd9cf543e9751e60';

  static const lessonCount = 60;
  static const sceneCount = 480;
  static const variantCount = 480;
  static const heldCount = 8;
}
