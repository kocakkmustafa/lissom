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

    def test_staged_v8m_output_is_exact_and_keeps_all_lesson_ids(self):
        rendered = hatha.render().encode("utf-8")
        self.assertEqual(len(rendered), hatha.CORRECTED_PUBLISHED_LENGTH)
        self.assertEqual(hashlib.sha256(rendered).hexdigest(),
                         hatha.CORRECTED_PUBLISHED_SHA256)
        self.assertEqual(hashlib.sha256(hatha.render_v8l().encode()).hexdigest(),
                         hatha.SCOPED_PUBLISHED_SHA256)
        course = json.loads(rendered)
        ids = [lesson["id"] for mod in course["modules"] for lesson in mod["lessons"]]
        self.assertEqual(ids, [f"h{number:02d}" for number in range(1, 61)])

    def test_revised_lessons_keep_safety_and_teaching_scope_explicit(self):
        course = json.loads(hatha.render())
        self.assertEqual(course["version"], "1.0.1")
        lessons = {item["id"]: item for mod in course["modules"]
                   for item in mod["lessons"]}
        self.assertIn("aol_triangle", lessons["h09"]["sourceIds"])
        self.assertIn("variation", lessons["h09"]["title"]["en"])
        self.assertIn("skip wall and legs-on-chair supine options",
                      lessons["h28"]["adaptation"]["en"])
        self.assertIn("legs-on-chair as another supine option",
                      lessons["h28"]["mediaBrief"]["en"])
        self.assertIn("h40 single-leg recap",
                      lessons["h51"]["mediaBrief"]["en"])

    def test_exact_movement_sources_are_credited_only_to_reviewed_lessons(self):
        expected = {
            "h09": {
                "yi_chair_triangle": "https://yogainternational.com/article/view/trikonasana-to-sidebend-or-not/",
            },
            "h28": {
                "yj_wall_chair_rest": "https://www.yogajournal.com/poses/anatomy/legs/let-go/?scope=anon",
                "yi_wall_side_exit": "https://yogainternational.com/article/view/yoga-for-tight-hamstrings/",
            },
            "h51": {
                "yj_locust_components": "https://www.yogajournal.com/poses/4-ways-to-modify-locust-pose/",
                "yj_locust_combined": "https://www.yogajournal.com/practice/5-minute-yoga-for-strength/",
            },
        }
        course = json.loads(hatha.render())
        lessons = {item["id"]: item for module in course["modules"]
                   for item in module["lessons"]}
        credited = {source_id for lesson_sources in expected.values()
                    for source_id in lesson_sources}
        attribution = json.loads((hatha.ROOT / "tools/hatha_source_attribution.v1.json")
                                 .read_text(encoding="utf-8"))
        self.assertEqual(set(attribution["sources"]), credited)
        for lesson_id, sources in expected.items():
            for source_id, url in sources.items():
                self.assertEqual(course["sources"].get(source_id), url)
                self.assertEqual(attribution["sources"][source_id]["url"], url)
                self.assertTrue(attribution["sources"][source_id]["locator"])
                self.assertTrue(attribution["sources"][source_id]["supports"])
                self.assertTrue(attribution["sources"][source_id]["doesNotSupport"])
                self.assertEqual(
                    attribution["sources"][source_id]["accessMode"],
                    "direct_original_publisher_page_opened",
                )
                self.assertRegex(attribution["sources"][source_id]["readbackHtmlSha256"],
                                 r"^[0-9a-f]{64}$")
                self.assertIn(source_id, lessons[lesson_id]["sourceIds"])
            self.assertEqual(lessons[lesson_id]["evidenceMode"], "self_report")
        for lesson_id, lesson in lessons.items():
            if lesson_id not in expected:
                self.assertTrue(credited.isdisjoint(lesson["sourceIds"]), lesson_id)

        clarifications = attribution["existingSourceClarifications"]
        self.assertEqual(set(clarifications), {"yj_slow_morning"})
        h30_source = clarifications["yj_slow_morning"]
        self.assertEqual(h30_source["url"], course["sources"]["yj_slow_morning"])
        self.assertIn("yj_slow_morning", lessons["h30"]["sourceIds"])
        self.assertEqual(h30_source["accessMode"],
                         "direct_original_publisher_page_opened")
        self.assertRegex(h30_source["readbackHtmlSha256"], r"^[0-9a-f]{64}$")
        self.assertIn("Bridge before Knee to Chest", h30_source["doesNotSupport"])

    def test_v8k_sources_have_two_exact_lesson_scopes_and_no_variant_leak(self):
        course = json.loads(hatha.render())
        lessons = {item["id"]: item for module in course["modules"]
                   for item in module["lessons"]}
        expected = {
            "h08": "umich_standing_turn",
            "h52": "ace_bent_knee_reverse_table",
        }
        self.assertEqual(course["version"], "1.0.1")
        self.assertEqual(set(course["sourceScopes"]), set(expected.values()) | {
            "yi_chair_triangle", "yj_wall_chair_rest", "yi_wall_side_exit",
            "nhs_pregnancy", "acog", "yj_locust_components",
            "yj_locust_combined", "yei_bridge_flow", "cc_wall_legs",
        })
        for lesson_id, source_id in expected.items():
            self.assertIn(source_id, lessons[lesson_id]["sourceIds"])
            self.assertEqual(set(course["sourceScopes"][source_id]),
                             {"supports", "doesNotSupport"})
        for lesson_id, lesson in lessons.items():
            if lesson_id not in expected:
                self.assertTrue(set(expected.values()).isdisjoint(
                    lesson["sourceIds"]), lesson_id)
        self.assertNotIn("artofliving_standing_spinal_twist",
                         lessons["h08"]["sourceIds"])

    def test_v8k_overlay_rejects_unreviewed_tie(self):
        overlay = copy.deepcopy(hatha.load_overlay(hatha.SOURCE_OVERLAY))
        overlay["lessonSourceAdds"]["h07"] = ["umich_standing_turn"]
        with mock.patch.object(hatha, "load_overlay", side_effect=[
                hatha.load_overlay(), overlay]):
            with self.assertRaisesRegex(ValueError, "only h08 and h52"):
                hatha.render()

    def test_h30_teaches_optional_single_leg_reset_before_bridge(self):
        course = json.loads(hatha.render())
        h30 = next(lesson for module in course["modules"]
                   for lesson in module["lessons"] if lesson["id"] == "h30")
        english = " ".join(step["en"] for step in h30["steps"])
        turkish = " ".join(step["tr"] for step in h30["steps"])
        for cue in ("choose the supine route", "one bent knee",
                    "foot fully to the mat", "both feet on the mat before a small bridge"):
            self.assertIn(cue, english)
        for cue in ("sırtüstü yolu seçtiysen", "bükülü dizi",
                    "ayağı tamamen mata indir", "küçük köprüden önce iki ayağı"):
            self.assertIn(cue, turkish.lower())
        self.assertIn("skip the supine branch", h30["adaptation"]["en"])
        self.assertIn("fully seated", h30["adaptation"]["en"])
        self.assertIn("full foot landing", h30["mediaBrief"]["en"])
        self.assertIn("chair", h30["mediaBrief"]["en"])
        self.assertIn("yj_slow_morning", h30["sourceIds"])
        self.assertIn("nhs_pregnancy", h30["sourceIds"])
        self.assertEqual(h30["evidenceMode"], "self_report")

    def test_v8m_changes_only_h28_copy_and_scopes_wall_inversion(self):
        previous = json.loads(hatha.render_v8l())
        corrected_bytes = hatha.render().encode("utf-8")
        corrected = json.loads(corrected_bytes)
        overlay = hatha.load_overlay(hatha.CORRECTED_SOURCE_OVERLAY)
        self.assertEqual(len(corrected_bytes), hatha.CORRECTED_PUBLISHED_LENGTH)
        self.assertEqual(hashlib.sha256(corrected_bytes).hexdigest(),
                         hatha.CORRECTED_PUBLISHED_SHA256)
        old_lessons = {lesson["id"]: lesson for module in previous["modules"]
                       for lesson in module["lessons"]}
        new_lessons = {lesson["id"]: lesson for module in corrected["modules"]
                       for lesson in module["lessons"]}
        self.assertEqual(old_lessons.keys(), new_lessons.keys())
        for lesson_id in old_lessons.keys() - {"h28"}:
            self.assertEqual(new_lessons[lesson_id], old_lessons[lesson_id])
        old_h28, new_h28 = old_lessons["h28"], new_lessons["h28"]
        self.assertEqual({key for key in old_h28 if old_h28[key] != new_h28[key]},
                         {"objective", "practice", "selfCheck", "adaptation", "sourceIds"})
        for field, changes in overlay["lessonTextEdits"]["h28"].items():
            for lang, edit in changes.items():
                self.assertEqual(new_h28[field][lang],
                                 old_h28[field][lang].replace(edit["from"],
                                                              edit["to"]))
        for lang in ("en", "tr"):
            self.assertNotIn(overlay["lessonTextEdits"]["h28"]["objective"]
                             [lang]["from"], new_h28["objective"][lang])
            self.assertNotIn(overlay["lessonTextEdits"]["h28"]["practice"]
                             [lang]["from"], new_h28["practice"][lang])
            self.assertNotIn(overlay["lessonTextEdits"]["h28"]["selfCheck"]
                             [lang]["from"], new_h28["selfCheck"][lang])
        self.assertIn("for a chair, side-lying or seated rest",
                      new_h28["selfCheck"]["en"])
        self.assertIn("sandalye, yan yatış veya oturma dinlenmesinde",
                      new_h28["selfCheck"]["tr"])
        self.assertIn("Skip the wall inversion with glaucoma or unmanaged high blood pressure",
                      new_h28["adaptation"]["en"])
        self.assertIn("do not try it without clinician guidance",
                      new_h28["adaptation"]["en"])
        for condition in ("congestive heart failure", "kidney failure",
                          "liver failure/cirrhosis"):
            self.assertIn(condition, new_h28["adaptation"]["en"])
        self.assertIn("Glokom veya kontrol altına alınmamış yüksek tansiyonda",
                      new_h28["adaptation"]["tr"])
        self.assertIn("hekim görüşü olmadan deneme",
                      new_h28["adaptation"]["tr"])
        self.assertEqual(new_h28["sourceIds"],
                         old_h28["sourceIds"] + ["cc_wall_legs"])
        self.assertEqual(set(corrected["sources"]) - set(previous["sources"]),
                         {"cc_wall_legs"})
        self.assertEqual(set(corrected["sourceScopes"]) -
                         set(previous["sourceScopes"]), {"cc_wall_legs"})
        scope = corrected["sourceScopes"]["cc_wall_legs"]
        self.assertIn("inversion", scope["supports"]["en"])
        self.assertIn("ters duruş", scope["supports"]["tr"])
        self.assertIn("glaucoma", scope["supports"]["en"])
        self.assertIn("Glokom", scope["supports"]["tr"])
        self.assertIn("unmanaged high blood pressure", scope["supports"]["en"])
        self.assertIn("excessive fluid retention", scope["supports"]["en"])
        self.assertIn("hekim görüşünü", scope["supports"]["tr"])
        self.assertIn("pregnancy", scope["doesNotSupport"]["en"])
        self.assertIn("personal suitability", scope["doesNotSupport"]["en"])
        self.assertIn("yan", scope["doesNotSupport"]["tr"])
        self.assertEqual(new_h28["evidenceMode"], "self_report")

    def test_v8m_rejects_moved_citation_and_unmatched_wording(self):
        original_load = hatha.load_overlay

        def changed_render(change):
            overlay = copy.deepcopy(original_load(hatha.CORRECTED_SOURCE_OVERLAY))
            change(overlay)

            def load(path=hatha.OVERLAY):
                return overlay if path == hatha.CORRECTED_SOURCE_OVERLAY else original_load(path)

            with mock.patch.object(hatha, "load_overlay", side_effect=load):
                return hatha.render()

        with self.assertRaisesRegex(ValueError, "only on h28"):
            changed_render(lambda overlay: overlay["lessonSourceAdds"].update(
                {"h28": [], "h27": ["cc_wall_legs"]}))
        with self.assertRaisesRegex(ValueError, "does not match the frozen lesson"):
            changed_render(lambda overlay: overlay["lessonTextEdits"]["h28"]
                           ["selfCheck"]["en"].update({"from": "unmatched text"}))
        with self.assertRaisesRegex(ValueError, "must scope"):
            changed_render(lambda overlay: overlay["sourceScopes"]
                           ["cc_wall_legs"].pop("doesNotSupport"))

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
            path.write_bytes(hatha.render().encode("utf-8") + b" ")
            with self.assertRaisesRegex(ValueError, "JSON differs"):
                hatha.check_output(path)

    def test_live_publication_gate_rejects_exact_stale_v8l(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "hatha.v1.json"
            path.write_bytes(hatha.render_v8l().encode("utf-8"))
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

    def test_live_write_rejects_stale_course_without_mutation(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "hatha.v1.json"
            old_bytes = hatha.render_v8l().encode("utf-8")
            path.write_bytes(old_bytes)
            with mock.patch.object(hatha, "OUTPUT", path):
                with self.assertRaisesRegex(ValueError, "coordinated cutover"):
                    hatha.main(["--write"])
            self.assertEqual(path.read_bytes(), old_bytes)

    def test_write_to_workspace_scratch_produces_exact_staged_bytes(self):
        scratch = hatha.ROOT.parents[2] / "scratch"
        created_scratch = not scratch.exists()
        scratch.mkdir(parents=True, exist_ok=True)
        try:
            with tempfile.TemporaryDirectory(dir=scratch) as directory:
                path = Path(directory) / "hatha.v1.json"
                hatha.main(["--write", "--output", str(path)])
                self.assertEqual(path.read_bytes(), hatha.render().encode("utf-8"))
        finally:
            if created_scratch:
                scratch.rmdir()

    def test_staged_output_is_restricted_to_workspace_scratch(self):
        workspace = hatha.ROOT.parents[2]
        expected = workspace / "scratch/2026-09-30-lissom-h28-v8m-staging/hatha.v1.json"
        self.assertEqual(hatha.staged_output(Path(
            "scratch/2026-09-30-lissom-h28-v8m-staging/hatha.v1.json")), expected)
        for path in (Path("ventures/lissom/app/config/courses/hatha.v1.json"),
                     Path("scratch/../ventures/lissom/app/config/courses/hatha.v1.json")):
            with self.assertRaisesRegex(ValueError, "workspace scratch"):
                hatha.staged_output(path)


def load_tests(loader, tests, pattern):
    # Keep the existing CI's exact filename entry point responsible for the
    # optional staging feature too. Broad discovery loads that file directly.
    if pattern in (None, "test_build_hatha_course.py"):
        tests.addTests(loader.loadTestsFromName("test_hatha_editorial_stage"))
    return tests


if __name__ == "__main__":
    unittest.main()
