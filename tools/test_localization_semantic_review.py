"""Stdlib regression controls only; fixtures are not real translation approval."""
from __future__ import annotations

import copy
import json
import re
import tempfile
import unittest
from pathlib import Path

import localization_semantic_review as gate


LOCALES = ("tr", "en", "es-419", "pt-BR", "de", "fr", "ja", "ar",
           "it", "ko", "id", "pl", "hi", "zh-Hans")
EXTRA_KEY = "Records: {count}. They remain on this device and are not synced to your account."
# Exact rejected historical payloads, used only as regression mutations.
OLD_AR_H41 = "اختر شكلي وقوف وشكلين جلوسًا أو منخفضين، وتوقف تنفس واحدًا وراحة."
OLD_KO_H52 = "고관절에서 접어 천천히 의자에 앉으세요. 앉은 뒤에만 손을 놓고 손목을 쉬게 하세요."


def fixture() -> tuple[dict, dict]:
    """Sparse 14-locale synthetic data; no app files or real attestations read."""
    anchors = dict(gate.REQUIRED_ANCHORS, placeholder_truncation_control=EXTRA_KEY)
    catalogs = {locale: {} for locale in LOCALES}
    attestation = {"schemaVersion": 1, "kind": gate.KIND,
                   "locales": list(LOCALES), "anchors": []}
    for anchor_id, key in anchors.items():
        row = {"id": anchor_id, "english_key": key,
               "source_sha256": gate.text_sha256(key),
               "source_refs": ["tests/synthetic-only#immutable-key",
                               "tests/synthetic-only#bounded-en-tr-display-clarification"],
               "targets": {}}
        for locale in LOCALES:
            value = key if locale == "en" else f"synthetic {locale}/{anchor_id}: {key}"
            # EN display text intentionally differs from the immutable key.
            if anchor_id == "progress_reading_list_ellipsis" and locale == "en":
                value = "Only the test name and date appear in this list; the reading appears on the test page."
            catalogs[locale][key] = value
            row["targets"][locale] = {
                "value_sha256": gate.text_sha256(value),
                "reviewer": "synthetic-fixture-reviewer",
                "review_ref": f"tests/synthetic-only#{anchor_id}/{locale}",
            }
        attestation["anchors"].append(row)
    return catalogs, attestation


class SemanticReviewControls(unittest.TestCase):
    def setUp(self) -> None:
        self.catalogs, self.review = fixture()

    def check(self) -> list[str]:
        return gate.validate_semantic_review(self.catalogs, self.review, locales=LOCALES)

    def row(self, anchor_id: str) -> dict:
        return next(row for row in self.review["anchors"] if row["id"] == anchor_id)

    def test_correct_sparse_fourteen_locale_fixture_passes(self):
        self.assertEqual(len(self.catalogs), 14)
        self.assertEqual(len(self.review["anchors"]), 6)
        self.assertEqual(self.check(), [])
        self.catalogs["it"]["Unreviewed noncritical key"] = "not this gate's scope"
        self.assertEqual(self.check(), [])

    def test_english_display_clarification_is_separate_from_source_key(self):
        row = self.row("progress_reading_list_ellipsis")
        self.assertNotEqual(self.catalogs["en"][row["english_key"]], row["english_key"])
        self.assertEqual(row["source_sha256"], gate.text_sha256(row["english_key"]))
        self.assertEqual(self.check(), [])
        self.catalogs["en"][row["english_key"]] = "The numeric reading is in this list."
        self.assertTrue(any("/en: target hash mismatch" in error for error in self.check()))

    def test_empty_or_wrong_attestation_never_passes(self):
        for invalid in (None, {}, [], {"anchors": []}, dict(self.review, anchors=[])):
            with self.subTest(invalid=invalid):
                self.assertTrue(gate.validate_semantic_review(self.catalogs, invalid, locales=LOCALES))

    def test_each_required_anchor_must_exist(self):
        original = copy.deepcopy(self.review)
        for anchor_id in gate.REQUIRED_ANCHORS:
            with self.subTest(anchor=anchor_id):
                self.review = copy.deepcopy(original)
                self.review["anchors"] = [row for row in self.review["anchors"] if row["id"] != anchor_id]
                self.assertTrue(any(f"missing required anchor {anchor_id}" in error for error in self.check()))

    def test_missing_catalog_locale_fails(self):
        for locale in LOCALES:
            with self.subTest(locale=locale):
                self.catalogs, self.review = fixture()
                del self.catalogs[locale]
                self.assertTrue(self.check())

    def test_missing_declared_locale_fails(self):
        self.review["locales"].remove("ar")
        self.assertTrue(any("declared locales" in error for error in self.check()))

    def test_missing_target_locale_fails(self):
        del self.row("h41_breathing_pause")["targets"]["ko"]
        self.assertTrue(any("exactly caller locales" in error for error in self.check()))

    def test_empty_or_duplicate_locale_policy_fails(self):
        for invalid in ((), "en", ("en", "en"), ("tr",), ("en", "")):
            with self.subTest(locales=invalid):
                self.assertTrue(gate.validate_semantic_review(self.catalogs, self.review, locales=invalid))
        self.review["locales"].append("ar")
        self.assertTrue(self.check())

    def test_duplicate_anchor_id_and_english_key_fail(self):
        duplicate = copy.deepcopy(self.row("h41_breathing_pause"))
        self.review["anchors"].append(duplicate)
        self.assertTrue(any("duplicate anchor id" in error for error in self.check()))
        duplicate["id"] = "different_id_same_key"
        self.assertTrue(any("duplicate English key" in error for error in self.check()))

    def test_nested_and_escaped_duplicate_json_keys_fail(self):
        with tempfile.TemporaryDirectory(prefix="lissom-semantic-gate-") as directory:
            path = Path(directory) / "review.json"
            for raw in ('{"anchors":[],"anchors":[]}',
                        '{"targets":{"ar":{},"\\u0061r":{}}}',
                        '{"targets":{"en":{"value_sha256":"x","value_sha256":"x"}}}'):
                with self.subTest(raw=raw):
                    path.write_text(raw, encoding="utf-8")
                    self.assertTrue(gate.semantic_review_errors(self.catalogs, path, locales=LOCALES))

    def test_wrong_source_hash_fails(self):
        self.row("h41_breathing_pause")["source_sha256"] = "0" * 64
        self.assertTrue(any("source hash mismatch" in error for error in self.check()))

    def test_immutable_required_key_cannot_be_renamed_and_rehashed(self):
        row = self.row("h41_breathing_pause")
        old, new = row["english_key"], "Changed source key"
        row["english_key"], row["source_sha256"] = new, gate.text_sha256(new)
        for locale in LOCALES:
            self.catalogs[locale][new] = self.catalogs[locale].pop(old)
        self.assertTrue(any("required English key changed" in error for error in self.check()))

    def test_missing_immutable_english_source_key_fails(self):
        del self.catalogs["en"][gate.REQUIRED_ANCHORS["h39_lower_seat"]]
        self.assertTrue(any("immutable English source key missing" in error for error in self.check()))

    def test_wrong_target_hash_fails(self):
        self.row("wall_both_palms")["targets"]["ja"]["value_sha256"] = "0" * 64
        self.assertTrue(any("/ja: target hash mismatch" in error for error in self.check()))

    def test_empty_or_plural_anchor_value_fails(self):
        key = gate.REQUIRED_ANCHORS["h39_lower_seat"]
        for value in ("", "  ", {"other": "not a flat string"}):
            with self.subTest(value=value):
                self.catalogs["fr"][key] = value
                self.assertTrue(any("nonempty flat string" in error for error in self.check()))

    def test_review_metadata_and_source_provenance_are_required(self):
        for field in ("reviewer", "review_ref"):
            for missing in ("", "UNRUN", None, "ROOT_TO_FILL:display", "TODO:review"):
                with self.subTest(field=field, value=missing):
                    self.catalogs, self.review = fixture()
                    self.row("h52_lower_seat")["targets"]["de"][field] = missing
                    self.assertTrue(self.check())
        self.catalogs, self.review = fixture()
        self.row("h52_lower_seat")["source_refs"] = []
        self.assertTrue(any("source_refs" in error for error in self.check()))

    def test_historical_unsafe_ar_payload_restore_is_rejected(self):
        key = gate.REQUIRED_ANCHORS["h41_breathing_pause"]
        self.catalogs["ar"][key] = OLD_AR_H41
        self.assertTrue(any("/ar: target hash mismatch" in error for error in self.check()))

    def test_historical_unsafe_ko_chair_payload_restore_is_rejected(self):
        key = gate.REQUIRED_ANCHORS["h52_lower_seat"]
        self.catalogs["ko"][key] = OLD_KO_H52
        self.assertTrue(any("/ko: target hash mismatch" in error for error in self.check()))

    def test_long_copy_truncation_fails_even_with_identical_placeholders(self):
        before = self.catalogs["id"][EXTRA_KEY]
        after = "Records: {count}."
        self.assertEqual(re.findall(r"\{\w+\}", before), re.findall(r"\{\w+\}", after))
        self.catalogs["id"][EXTRA_KEY] = after
        self.assertTrue(any("/id: target hash mismatch" in error for error in self.check()))

    def test_missing_file_fails_and_validation_never_rewrites_review(self):
        with tempfile.TemporaryDirectory(prefix="lissom-semantic-gate-") as directory:
            path = Path(directory) / "review.json"
            self.assertTrue(gate.semantic_review_errors(self.catalogs, path, locales=LOCALES))
            path.write_text(json.dumps(self.review, ensure_ascii=False), encoding="utf-8")
            before = path.read_bytes()
            self.assertEqual(gate.semantic_review_errors(self.catalogs, path, locales=LOCALES), [])
            self.assertEqual(path.read_bytes(), before)

    def test_hash_is_exact_utf8_not_trimmed_or_normalized(self):
        self.assertEqual(gate.text_sha256("abc"),
                         "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        self.assertNotEqual(gate.text_sha256("value"), gate.text_sha256(" value"))
        self.assertNotEqual(gate.text_sha256("é"), gate.text_sha256("e\u0301"))


if __name__ == "__main__":
    unittest.main()
