"""Exact-byte and negative controls for the authored Hatha course build."""

import copy
import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import build_hatha_course as hatha


class HathaCourseBuildTest(unittest.TestCase):
    def test_authored_base_is_pinned(self):
        base = hatha.render_base().encode("utf-8")
        self.assertEqual(len(base), hatha.BASELINE_LENGTH)
        self.assertEqual(hashlib.sha256(base).hexdigest(), hatha.BASELINE_SHA256)

    def test_published_output_is_exact_and_keeps_all_lesson_ids(self):
        rendered = hatha.render().encode("utf-8")
        self.assertEqual(rendered, hatha.OUTPUT.read_bytes())
        self.assertEqual(len(rendered), hatha.PUBLISHED_LENGTH)
        self.assertEqual(hashlib.sha256(rendered).hexdigest(), hatha.PUBLISHED_SHA256)
        course = json.loads(rendered)
        ids = [lesson["id"] for mod in course["modules"] for lesson in mod["lessons"]]
        self.assertEqual(ids, [f"h{number:02d}" for number in range(1, 61)])

    def test_changed_authored_base_is_rejected_before_overlay(self):
        with mock.patch.object(hatha, "render_base", return_value=hatha.render_base() + " "):
            with self.assertRaisesRegex(ValueError, "authored base changed"):
                hatha.render()

    def test_unknown_overlay_field_is_rejected(self):
        overlay = copy.deepcopy(hatha.load_overlay())
        overlay["lessons"]["h01"]["adaptationReplace"] = {"en": "x", "tr": "y"}
        with mock.patch.object(hatha, "load_overlay", return_value=overlay):
            with self.assertRaisesRegex(ValueError, "overlay fields changed for h01"):
                hatha.render()

    def test_missing_lesson_overlay_is_rejected(self):
        overlay = copy.deepcopy(hatha.load_overlay())
        del overlay["lessons"]["h60"]
        with mock.patch.object(hatha, "load_overlay", return_value=overlay):
            with self.assertRaisesRegex(ValueError, "cover the 60 lesson IDs"):
                hatha.render()

    def test_step_edit_outside_three_reviewed_positions_is_rejected(self):
        overlay = copy.deepcopy(hatha.load_overlay())
        overlay["lessons"]["h11"]["stepsReplace"]["2"] = {
            "en": "unreviewed step", "tr": "incelenmemiş adım"}
        with mock.patch.object(hatha, "load_overlay", return_value=overlay):
            with self.assertRaisesRegex(ValueError, "step targets changed for h11"):
                hatha.render()

    def test_tampered_allowed_text_is_rejected_by_final_hash(self):
        overlay = copy.deepcopy(hatha.load_overlay())
        overlay["lessons"]["h01"]["practiceAppend"]["en"] += "!"
        with mock.patch.object(hatha, "load_overlay", return_value=overlay):
            with self.assertRaisesRegex(ValueError, "published course changed"):
                hatha.render()

    def test_duplicate_overlay_json_key_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "duplicate.json"
            path.write_text('{"same":1,"same":2}', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "duplicate overlay key"):
                hatha.load_overlay(path)

    def test_check_rejects_changed_published_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "hatha.v1.json"
            path.write_bytes(hatha.OUTPUT.read_bytes() + b" ")
            with self.assertRaisesRegex(ValueError, "JSON differs"):
                hatha.check_output(path)

    def test_write_requires_valid_overlay_before_replacing_output(self):
        overlay = copy.deepcopy(hatha.load_overlay())
        overlay["lessons"]["h01"]["practiceAppend"]["en"] += "!"
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "hatha.v1.json"
            path.write_bytes(b"keep existing file")
            with (mock.patch.object(hatha, "OUTPUT", path),
                  mock.patch.object(hatha, "load_overlay", return_value=overlay)):
                with self.assertRaisesRegex(ValueError, "published course changed"):
                    hatha.main(["--write"])
            self.assertEqual(path.read_bytes(), b"keep existing file")

    def test_write_produces_exact_published_bytes(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "hatha.v1.json"
            with mock.patch.object(hatha, "OUTPUT", path):
                hatha.main(["--write"])
            self.assertEqual(path.read_bytes(), hatha.OUTPUT.read_bytes())


if __name__ == "__main__":
    unittest.main()
