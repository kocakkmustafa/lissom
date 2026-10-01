"""App-local, negative controls for the closed Lissom source projection."""

from __future__ import annotations

import copy
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import check_lissom_source_projection as source


class LissomSourceProjectionTest(unittest.TestCase):
    def setUp(self) -> None:
        self.raw = {
            name: (source.APP / path).read_bytes()
            for name, path in source.INPUTS.items()
        }
        self.course = json.loads(self.raw["course"])
        self.source_slice = json.loads(self.raw["slice"])
        self.projection = json.loads(self.raw["projection"])

    def test_live_app_check_is_closed_and_exact(self) -> None:
        result = source.check(source.APP)
        self.assertEqual(result, (60, 480, 480, 8))
        self.assertEqual(
            hashlib.sha256(self.raw["slice"]).hexdigest(), source.SLICE_SHA256
        )
        self.assertEqual(
            hashlib.sha256(self.raw["projection"]).hexdigest(),
            source.PROJECTION_SHA256,
        )

    def test_outside_same_byte_directory_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "app"
            outside = Path(temp) / "outside"
            root.mkdir()
            outside.mkdir()
            (root / "assets").mkdir()
            (outside / "motion_content").mkdir()
            (root / "config/courses").mkdir(parents=True)
            for name, path in source.INPUTS.items():
                if name == "course":
                    (root / path).write_bytes(self.raw[name])
                else:
                    (outside / "motion_content" / path.name).write_bytes(
                        self.raw[name]
                    )
            (root / "pubspec.yaml").write_bytes(
                (source.APP / "pubspec.yaml").read_bytes()
            )
            (root / "assets/motion_content").symlink_to(
                outside / "motion_content", target_is_directory=True
            )
            # A path-based reader accepts the byte-identical outside files.
            for name in ("slice", "projection"):
                self.assertEqual((root / source.INPUTS[name]).read_bytes(), self.raw[name])
            with mock.patch.object(
                source,
                "read_from_root",
                side_effect=lambda _fd, path, _limit: (root / path).read_bytes(),
            ):
                self.assertEqual(source.check(root), (60, 480, 480, 8))
            with self.assertRaisesRegex(source.ProjectionError, "INPUT_SYMLINK"):
                source.check(root)

    def test_outside_same_byte_file_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / "app"
            outside = Path(temp) / "outside"
            (root / "assets/motion_content").mkdir(parents=True)
            (root / "config/courses").mkdir(parents=True)
            outside.mkdir()
            (root / source.INPUTS["course"]).write_bytes(self.raw["course"])
            (root / source.INPUTS["slice"]).write_bytes(self.raw["slice"])
            (root / "pubspec.yaml").write_bytes(
                (source.APP / "pubspec.yaml").read_bytes()
            )
            outside_file = outside / source.INPUTS["projection"].name
            outside_file.write_bytes(self.raw["projection"])
            (root / source.INPUTS["projection"]).symlink_to(outside_file)
            self.assertEqual(
                (root / source.INPUTS["projection"]).read_bytes(),
                self.raw["projection"],
            )
            with self.assertRaisesRegex(source.ProjectionError, "INPUT_SYMLINK"):
                source.check(root)

    def test_h30_semantic_hold_cannot_be_cleared(self) -> None:
        altered = copy.deepcopy(self.source_slice)
        h30 = next(row for row in altered["lessons"] if row["lessonId"] == "h30")
        h30["membershipStatus"] = "SOURCE_PINNED_TEST_ONLY"
        with self.assertRaisesRegex(source.ProjectionError, "HOLD_MEMBERSHIP"):
            source.validate_payloads(self.course, altered, self.projection)

    def test_held_pin_cannot_be_marked_playable(self) -> None:
        altered = copy.deepcopy(self.projection)
        row = next(row for row in altered["rows"] if row[10] is True)
        row[10] = False
        with self.assertRaisesRegex(source.ProjectionError, "ROWS_DRIFT"):
            source.validate_payloads(self.course, self.source_slice, altered)

    def test_scene_order_is_rebuilt_from_slice(self) -> None:
        altered = copy.deepcopy(self.projection)
        altered["rows"][0][4] += 1
        with self.assertRaisesRegex(source.ProjectionError, "ROWS_DRIFT"):
            source.validate_payloads(self.course, self.source_slice, altered)

    def test_lesson_hash_is_rebuilt_from_live_course(self) -> None:
        altered = copy.deepcopy(self.course)
        altered["modules"][0]["lessons"][0]["title"]["en"] += " changed"
        with self.assertRaisesRegex(source.ProjectionError, "LESSON_CANONICAL_DRIFT"):
            source.validate_payloads(altered, self.source_slice, self.projection)

    def test_slice_cannot_add_playable_media_fields(self) -> None:
        altered = copy.deepcopy(self.source_slice)
        altered["lessons"][0]["scenes"][0]["variants"][0]["video"] = {
            "path": "content/media/fake.mp4"
        }
        with self.assertRaisesRegex(source.ProjectionError, "SOURCE_ONLY"):
            source.validate_payloads(self.course, altered, self.projection)


if __name__ == "__main__":
    unittest.main()
