#!/usr/bin/env python3
"""Install the founder-approved 2026-10-16 artwork into native icon slots.

The source stays square and opaque. iOS and Android apply their own launcher
masks; pre-rounding a store asset would clip the dancer twice.
"""

import argparse
from pathlib import Path

from PIL import Image, PngImagePlugin


ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "docs/design/icon/approved-2026-10-16/master.png"
IOS_ASSETS = ROOT / "ios/Runner/Assets.xcassets"
ANDROID_RES = ROOT / "android/app/src/main/res"

ICON_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}

ANDROID_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--include-launch-images", action="store_true",
                        help="Also regenerate separate splash artwork (opt-in)")
    args = parser.parse_args()
    with Image.open(SOURCE) as source:
        if source.size != (1254, 1254) or source.mode != "RGB":
            raise ValueError("Approved icon must be a 1254px square RGB image")
        master = source.copy()
        pnginfo = PngImagePlugin.PngInfo()
        pnginfo.add(b"sRGB", b"\x00")

        icon_dir = IOS_ASSETS / "AppIcon.appiconset"
        for filename, pixels in ICON_SIZES.items():
            master.resize((pixels, pixels), Image.Resampling.LANCZOS).save(
                icon_dir / filename, pnginfo=pnginfo
            )

        for folder, pixels in ANDROID_SIZES.items():
            master.resize((pixels, pixels), Image.Resampling.LANCZOS).save(
                ANDROID_RES / folder / "ic_launcher.png", pnginfo=pnginfo
            )

        if not args.include_launch_images:
            return

        launch_dir = IOS_ASSETS / "LaunchImage.imageset"
        for filename, scale in (
            ("LaunchImage.png", 1),
            ("LaunchImage@2x.png", 2),
            ("LaunchImage@3x.png", 3),
        ):
            pixels = 150 * scale
            master.resize((pixels, pixels), Image.Resampling.LANCZOS).save(
                launch_dir / filename
            )


if __name__ == "__main__":
    main()
