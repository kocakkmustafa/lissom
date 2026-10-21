#!/usr/bin/env python3
"""Negative controls for locale/content admission, without Flutter or SDK use."""
from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import check_content_localization as check
import wellness_lint


class ContentLocalizationControls(unittest.TestCase):
    def test_actual_reader_inventory_has_non_vacuous_expected_scope(self):
        rows = check.content_source()
        self.assertEqual(len(rows), 1615)
        self.assertEqual(len({row["english"] for row in rows}), 1391)
        self.assertEqual(sum(row["displayed"] for row in rows), 1495)
        self.assertEqual(len({row["file"] for row in rows}), 7)

    def test_duplicate_json_key_is_rejected_even_if_values_match(self):
        for raw in ['{"messages":{"Learn":"A","Learn":"A"}}',
                    '{"messages":{"Learn":"A","Lea\\u0072n":"B"}}']:
            with self.subTest(raw=raw):
                with self.assertRaises(ValueError):
                    json.loads(raw, object_pairs_hook=check.reject_duplicate_pairs)

    def test_missing_added_and_repeated_placeholders_are_rejected(self):
        for translated in ["{done} completed", "{done}/{total} {new}", "{done}/{total}/{total}"]:
            with self.subTest(translated=translated):
                self.assertTrue(check.message_errors("{done}/{total}", translated))
        self.assertEqual(check.message_errors("{done}/{total}", "{total} のうち {done}"), [])

    def test_each_plural_branch_has_placeholder_parity(self):
        self.assertEqual(check.message_errors("{count} lessons", {
            "one": "{count} lesson", "other": "{count} lessons",
        }), [])
        self.assertTrue(check.message_errors("{count} lessons", {"one": "one", "other": "{count} lessons"}))
        self.assertTrue(check.message_errors("{count} lessons", {"one": "{count} lesson"}))
        self.assertTrue(check.message_errors("{count} lessons", {"other": "{count} lessons", "unknown": "x"}))

    def test_nfc_bidi_empty_replacement_and_control_corruption_are_rejected(self):
        for translated in ["e\u0301", "text\u202e", "\u2066text\u2069", " ", "bad\ufffd", "bad\x00"]:
            with self.subTest(translated=translated):
                self.assertTrue(check.text_errors(translated))
        self.assertEqual(check.text_errors("Yoga · يوغا · ヨガ · leçon"), [])

    def test_catalog_identity_and_shape_are_strict(self):
        valid = {"schemaVersion": 1, "id": "lissom.l10n.fr", "locale": "fr", "messages": {"Hatha": "Hatha"}}
        self.assertEqual(check.validate_catalog(valid, "fr")[1], [])
        for changed in [dict(valid, locale="en"), dict(valid, schemaVersion=True),
                        dict(valid, messages={}), dict(valid, extra="unexpected")]:
            with self.subTest(changed=changed):
                self.assertTrue(check.validate_catalog(changed, "fr")[1])

    def test_only_actual_config_fragments_may_have_outer_spaces(self):
        valid = {'schemaVersion': 1, 'id': 'lissom.l10n.tr', 'locale': 'tr',
                 'messages': {' and ': ' ve '}}
        self.assertEqual(check.validate_catalog(valid, 'tr')[1], [])
        invalid = dict(valid, messages={' Hatha ': 'Hatha'})
        self.assertTrue(check.validate_catalog(invalid, 'tr')[1])

    def test_catalog_absence_fails_instead_of_reporting_translation_acceptance(self):
        with tempfile.TemporaryDirectory(prefix="lissom-l10n-control-") as directory:
            result = check.run(Path(directory))
        self.assertTrue(result["errors"])
        self.assertEqual(len(result["catalogs"]), 14)
        self.assertTrue(all(len(catalog["missingContentKeys"]) == 1391 for catalog in result["catalogs"].values()))

    def test_semantic_review_is_called_with_all_locales_and_errors_propagate(self):
        with tempfile.TemporaryDirectory(prefix="lissom-semantic-hook-") as directory:
            with patch.object(check, "semantic_review_errors", return_value=["critical-copy-drift"]) as review:
                result = check.run(Path(directory))
            review.assert_called_once()
            catalogs, path = review.call_args.args
            self.assertEqual(tuple(catalogs), check.LOCALES)
            self.assertEqual(len(catalogs), 14)
            self.assertEqual(path, check.ROOT / "tools/data/localization_semantic_review.v1.json")
            self.assertEqual(review.call_args.kwargs, {"locales": check.LOCALES})
            self.assertIn("critical-copy-drift", result["errors"])
        with patch.object(check, "semantic_review_errors") as review:
            inventory = check.run(Path("unused"), inventory_only=True)
        review.assert_not_called()
        self.assertEqual(inventory["mode"], "INVENTORY_ONLY_NO_TRANSLATION_ACCEPTANCE")

    def test_catalog_copy_gate_reads_fallback_translation_and_every_plural_form(self):
        catalog = {'id': 'lissom.l10n.fr', 'messages': {
            'Safe fallback': 'Lissom cures pain.',
            'Lissom treats your pain.': 'Texte neutre.',
            '{count} readings': {'one': '{count} reading',
                                 'other': 'Lissom diagnoses your symptoms. {count}'},
        }}
        rows = wellness_lint._walk_json(catalog)
        self.assertEqual(len(rows), 7)
        violations = [(where, text) for where, text in rows
                      if wellness_lint.scan_text(where, text)]
        self.assertEqual(len(violations), 3)
        self.assertTrue(any(where.endswith('.other') for where, _ in violations))

    def test_inventory_only_preserves_course_pins_without_translation_claim(self):
        result = check.run(Path("unused"), inventory_only=True)
        self.assertEqual(result["errors"], [])
        self.assertTrue(all(pin["unchanged"] for pin in result["coursePins"].values()))
        self.assertEqual(result["mode"], "INVENTORY_ONLY_NO_TRANSLATION_ACCEPTANCE")
        self.assertEqual(result["turkishContextCollisions"], [{
            "english": "Standing foundations", "turkishVariants": ["Ayakta temel duruşlar", "Ayakta temeller"],
        }])


if __name__ == "__main__":
    unittest.main()
