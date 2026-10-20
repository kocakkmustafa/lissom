#!/usr/bin/env python3
"""English-pattern catalog controls; no medical or translated-copy acceptance.

The 16 reviewed English fields and 33 reviewed translated matches are read
from shipped sources, never rewritten.
Temporary catalogs exercise exact identity/path/hash/word admission and attacks.
This suite uses Python stdlib only; it does not invoke Flutter, SDKs or a network.
"""
from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import wellness_lint as lint


ATTACKS = (
    "A symptom-free retest is delivered by Lissom.",
    "A symptom-free retest is promised by Lissom.",
    "Lissom creates a symptom-free retest.",
    "Lissom will assess your technique.",
    "Camera coaching will be available.",
    "This cures pain.",
    "Lissom diagnoses the cause.",
    "Lissom treats your symptoms.",
    "Lissom reduces your symptoms.",
    "Lissom guarantees a symptom-free retest.",
    "Lissom prescribes a physical dose.",
    "Camera coaching is coming soon.",
    "Camera coaching is not available yet.",
)
PLURAL_FORMS = ("zero", "one", "two", "few", "many", "other")
LOCALES = ("tr", "en", "es-419", "pt-BR", "de", "fr", "ja", "ar")


class WellnessCatalogControls(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app_root = lint.ROOT
        cls.fields = []
        for (where, digest), words in lint._REVIEWED_COPY.items():
            filename, field = where.split(" :: ", 1)
            course = json.loads((cls.app_root / "config/courses" / filename).read_text(encoding="utf-8"))
            texts = dict(lint._walk_json(course))
            if field not in texts:
                raise AssertionError(f"Reviewed field is not scanned: {where}")
            text = texts[field]
            if hashlib.sha256(text.encode("utf-8")).hexdigest() != digest:
                raise AssertionError(f"Reviewed field changed; review is required: {where}")
            cls.fields.append((where, text, words))
        cls.translation_fields = []
        for locale, source_digest, text_digest, leaf, word in sorted(lint._REVIEWED_TRANSLATION_WORDS):
            catalog = json.loads((cls.app_root / "config/l10n" / f"{locale}.json").read_text(encoding="utf-8"))
            sources = [source for source in catalog["messages"]
                       if hashlib.sha256(source.encode("utf-8")).hexdigest() == source_digest]
            if len(sources) != 1:
                raise AssertionError(f"Reviewed English source changed: {locale} {source_digest}")
            source = sources[0]
            text = catalog["messages"][source]
            if (leaf != "text" or not isinstance(text, str)
                    or hashlib.sha256(text.encode("utf-8")).hexdigest() != text_digest):
                raise AssertionError(f"Reviewed translation changed: {locale} {source_digest}")
            cls.translation_fields.append((locale, source, text, word))

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="lissom-wellness-catalog-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.root_patch = patch.object(lint, "ROOT", self.root)
        self.root_patch.start()
        self.addCleanup(self.root_patch.stop)

    def scan_catalog(self, messages, locale="en", *, relative=None, overrides=None):
        catalog = {"schemaVersion": 1, "id": f"lissom.l10n.{locale}",
                   "locale": locale, "messages": messages}
        catalog.update(overrides or {})
        path = self.root / (relative or f"config/l10n/{locale}.json")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(catalog, ensure_ascii=False), encoding="utf-8")
        return lint.scan_file(path)

    def test_exact_sixteen_shipped_fields_and_only_their_reviewed_words_pass(self):
        self.assertEqual(len(lint.REVIEWED_HATHA_COPY), 5)
        self.assertEqual(len(lint.REVIEWED_CONTEXT_COPY), 11)
        self.assertEqual(len(self.fields), 16)
        for where, text, words in self.fields:
            with self.subTest(where=where):
                self.assertEqual(lint.scan_text(where, text), [])
                for word in words:
                    self.assertTrue(lint._reviewed_word(where, text, word))
                self.assertFalse(lint._reviewed_word(where, text, "cures"))
                self.assertTrue(lint.scan_text(where + ".copy", text))

    def test_new_user_facing_fields_cannot_be_blind_spots(self):
        for field in ("answerKey", "supports", "doesNotSupport"):
            for value in ("Lissom cures pain.",
                          {"en": "Lissom cures pain.", "tr": "Denetim örneği"},
                          ["Lissom cures pain."]):
                with self.subTest(field=field, value=value):
                    rows = lint._walk_json({"nested": {field: value}})
                    self.assertEqual(len(rows), 1)
                    self.assertTrue(lint.scan_text(rows[0][0], rows[0][1]))

    def test_all_approved_catalogs_admit_exact_source_and_translated_aliases(self):
        for locale in LOCALES:
            for where, text, _ in self.fields:
                with self.subTest(locale=locale, where=where):
                    # These are English-byte fixtures, not locale translations.
                    problems, scanned = self.scan_catalog({text: "Neutral text", "Neutral fallback": text}, locale)
                    self.assertEqual(problems, [])
                    self.assertEqual(scanned, 4)

    def test_every_plural_leaf_is_scanned_and_exact_alias_is_bounded(self):
        for where, text, _ in self.fields:
            for form in PLURAL_FORMS:
                with self.subTest(where=where, form=form):
                    problems, scanned = self.scan_catalog({"Neutral fallback": {form: text}})
                    self.assertEqual(problems, [])
                    self.assertEqual(scanned, 2)
                    problems, _ = self.scan_catalog({"Neutral fallback": {form: text + " This cures pain."}})
                    self.assertTrue(problems)
            problems, _ = self.scan_catalog({"Neutral fallback": {"unexpected": text}})
            self.assertTrue(problems, where)

    def test_any_byte_change_revokes_each_review_in_sources_and_catalogs(self):
        for where, text, _ in self.fields:
            changed = text + " "
            with self.subTest(where=where):
                self.assertTrue(lint.scan_text(where, changed))
                self.assertTrue(self.scan_catalog({changed: "Neutral text"})[0])
                self.assertTrue(self.scan_catalog({"Neutral fallback": changed})[0])

    def test_appended_claims_never_borrow_source_or_catalog_review(self):
        for where, text, _ in self.fields:
            for attack in ATTACKS:
                for separator in (".", ";", "\n"):
                    changed = text + separator + " " + attack
                    with self.subTest(where=where, attack=attack, separator=separator):
                        self.assertTrue(lint.scan_text(where, changed))
                        self.assertTrue(self.scan_catalog({changed: "Neutral text"})[0])
                        self.assertTrue(self.scan_catalog({"Neutral fallback": changed})[0])

    def test_catalog_review_requires_exact_app_path_and_identity(self):
        invalid_metadata = (
            {"id": "lissom.l10n.fr"}, {"locale": "fr"},
            {"schemaVersion": True}, {"schemaVersion": 2},
            {"extra": "unexpected"},
        )
        for where, text, _ in self.fields:
            for metadata in invalid_metadata:
                with self.subTest(where=where, metadata=metadata):
                    self.assertTrue(self.scan_catalog({text: "Neutral text"}, overrides=metadata)[0])
            for relative in ("config/copy/en.json", "other/config/l10n/en.json", "en.json"):
                with self.subTest(where=where, relative=relative):
                    self.assertTrue(self.scan_catalog({text: "Neutral text"}, relative=relative)[0])
            self.assertTrue(self.scan_catalog({text: "Neutral text"}, locale="it")[0])

    def test_catalog_identity_cannot_turn_nested_fields_into_aliases(self):
        for where, text, _ in self.fields:
            # Catalog traversal is root-only; a nested messages-shaped object
            # is ordinary user-facing copy and cannot borrow a source review.
            data = {"nested": {"id": "lissom.l10n.en", "messages": {"text": text}}}
            path = self.root / "config/l10n/en.json"
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps(data), encoding="utf-8")
            problems, scanned = lint.scan_file(path)
            self.assertTrue(problems, where)
            self.assertEqual(scanned, 1)

    def test_same_basename_outside_canonical_course_path_does_not_borrow_review(self):
        for where, text, _ in self.fields:
            filename, field = where.split(" :: ", 1)
            self.assertNotEqual(lint._json_location(self.root / "other" / filename), filename)
            self.assertTrue(lint.scan_text(f"other/{filename} :: {field}", text))
        # A real copied Hatha file keeps its basename and field names, but its
        # directory must still revoke the old five review records.
        source = self.app_root / "config/courses/hatha.v1.json"
        copied = self.root / "other/hatha.v1.json"
        copied.parent.mkdir(parents=True, exist_ok=True)
        copied.write_bytes(source.read_bytes())
        self.assertTrue(lint.scan_file(copied)[0])

    def test_fallback_value_plural_and_unreviewed_words_still_report_claims(self):
        messages = {"Safe fallback": "Lissom cures pain.",
                    "Lissom treats your pain.": "Texte neutre.",
                    "{count} readings": {"one": "{count} reading",
                                         "other": "Lissom diagnoses your symptoms. {count}"}}
        problems, scanned = self.scan_catalog(messages, locale="fr")
        self.assertEqual(scanned, 7)
        self.assertEqual(len(problems), 4)
        self.assertTrue(any(".source:" in problem for problem in problems))
        self.assertTrue(any(".text:" in problem for problem in problems))
        self.assertTrue(any(".other:" in problem for problem in problems))

    def test_shipped_source_and_english_turkish_catalogs_have_no_english_pattern_violation(self):
        with patch.object(lint, "ROOT", self.app_root):
            for relative in sorted(lint._REVIEWED_COURSE_PATHS) + ["config/l10n/en.json", "config/l10n/tr.json"]:
                with self.subTest(relative=relative):
                    problems, scanned = lint.scan_file(self.app_root / relative)
                    self.assertGreater(scanned, 0)
                    self.assertEqual(problems, [])

    def test_exact_thirty_three_translation_matches_pass_only_with_catalog_context(self):
        self.assertEqual(len(self.translation_fields), 33)
        for locale, source, text, word in self.translation_fields:
            with self.subTest(locale=locale, source=source, word=word):
                problems, scanned = self.scan_catalog({source: text}, locale)
                self.assertEqual(problems, [])
                self.assertEqual(scanned, 2)
                where = f"config/l10n/{locale}.json :: messages[0].text"
                self.assertTrue(lint._reviewed_word(where, text, word,
                                                   catalog_alias=True, catalog_source=source))
                self.assertFalse(lint._reviewed_word(where, text, word + "x",
                                                    catalog_alias=True, catalog_source=source))
                self.assertTrue(lint.scan_text(where, text))
                self.assertTrue(lint.scan_text(where, text, catalog_source=source))
                self.assertTrue(lint.scan_text(where, text, catalog_alias=True))
                # English keys, rather than mutable catalog indices, bind review.
                self.assertEqual(self.scan_catalog({"Neutral preceding key": "Neutral preceding value",
                                                    source: text}, locale)[0], [])

    def test_translation_review_cannot_move_to_a_different_source_locale_path_or_leaf(self):
        for locale, source, text, word in self.translation_fields:
            with self.subTest(locale=locale, source=source, word=word):
                self.assertTrue(self.scan_catalog({source + " ": text}, locale)[0])
                self.assertTrue(self.scan_catalog({source: text}, locale="en")[0])
                self.assertTrue(self.scan_catalog({source: text}, locale,
                                                  relative=f"other/{locale}.json")[0])
                self.assertTrue(self.scan_catalog({source: text}, locale,
                                                  overrides={"id": "lissom.l10n.en"})[0])
                self.assertTrue(self.scan_catalog({text: "Neutral translation"}, locale)[0])
                for form in PLURAL_FORMS + ("unexpected",):
                    self.assertTrue(self.scan_catalog({source: {form: text}}, locale)[0])

    def test_one_byte_translation_or_source_change_revokes_translation_review(self):
        for locale, source, text, word in self.translation_fields:
            with self.subTest(locale=locale, source=source, word=word):
                self.assertTrue(self.scan_catalog({source: text + " "}, locale)[0])
                self.assertTrue(self.scan_catalog({source + " ": text}, locale)[0])

    def test_each_appended_english_claim_fails_in_reviewed_translation_and_source(self):
        for locale, source, text, word in self.translation_fields:
            for attack in ATTACKS:
                for separator in (".", ";", "\n"):
                    suffix = separator + " " + attack
                    with self.subTest(locale=locale, source=source, word=word,
                                      attack=attack, separator=separator):
                        self.assertTrue(self.scan_catalog({source: text + suffix}, locale)[0])
                        problems, _ = self.scan_catalog({source + suffix: text}, locale)
                        self.assertTrue(problems)
                        self.assertTrue(any(".source:" in problem for problem in problems))

    def test_translation_review_artifact_is_strict_and_fails_closed(self):
        actual = json.loads((self.app_root / "tools/wellness_translation_reviews.v1.json").read_text(encoding="utf-8"))
        row = actual["reviews"][0]
        invalid = (
            dict(actual, schemaVersion=True), dict(actual, id="other"), dict(actual, reviews=[]),
            dict(actual, reviews=[dict(row, locale="it")]),
            dict(actual, reviews=[dict(row, sourceEnglishSha256="0")]),
            dict(actual, reviews=[dict(row, translationSha256="*")]),
            dict(actual, reviews=[dict(row, leaf="other")]),
            dict(actual, reviews=[dict(row, matchedWord="")]),
            dict(actual, reviews=[dict(row, matchedWord=" Symptom")]),
            dict(actual, reviews=[dict(row, matchedWord=False)]),
            dict(actual, reviews=[dict(row, extra="unexpected")]),
            dict(actual, reviews=[row, row]),
        )
        path = self.root / "reviews.json"
        for document in invalid:
            with self.subTest(document=document):
                path.write_text(json.dumps(document), encoding="utf-8")
                with self.assertRaises(ValueError):
                    lint._load_translation_reviews(path)
        with self.assertRaises(FileNotFoundError):
            lint._load_translation_reviews(self.root / "missing.json")
        path.write_text("{", encoding="utf-8")
        with self.assertRaises(json.JSONDecodeError):
            lint._load_translation_reviews(path)

    def test_all_shipped_catalogs_have_no_remaining_english_pattern_violation(self):
        # Static English-pattern coverage only: passing translated values is
        # not human, medical, linguistic, teaching, rendering or RTL acceptance.
        with patch.object(lint, "ROOT", self.app_root):
            for locale in LOCALES:
                with self.subTest(locale=locale):
                    problems, scanned = lint.scan_file(self.app_root / "config/l10n" / f"{locale}.json")
                    self.assertGreaterEqual(scanned, 1685)
                    self.assertEqual(problems, [])


if __name__ == "__main__":
    unittest.main()
