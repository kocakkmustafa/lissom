"""Bounded source-reader regressions; not Dart, UI or translation tests."""
import unittest

import extract_ui_localization as ui


class SourceReaderTest(unittest.TestCase):
    def test_adjacent_unicode_and_escaped_literals(self):
        self.assertEqual(ui.expand(ui.tokenize("'Türkçe ' \"日本語\""), {}), ["Türkçe 日本語"])
        self.assertEqual(ui.expand(ui.tokenize(r"'It\'s \$known'"), {}), ["It's $known"])

    def test_static_reference_and_scoped_interpolation(self):
        constants = {"Device._pass": "a device pass", "Device.notTried": "Not tried"}
        self.assertEqual(ui.expand(ui.tokenize("'Needs $_pass'"), constants, "Device"), ["Needs a device pass"])
        self.assertEqual(ui.expand(ui.tokenize("'${Device.notTried}: ' 'still pending'"), constants), ["Not tried: still pending"])

    def test_unknown_runtime_interpolation_is_not_invented(self):
        with self.assertRaisesRegex(ValueError, "unresolved interpolation"):
            ui.expand(ui.tokenize("'Value $privateValue'"), {})

    def test_nested_conditional_literal_arms_keep_order(self):
        self.assertEqual(ui.expand(ui.tokenize("enabled ? 'A' : (other ? 'B' : 'C')"), {}), ["A", "B", "C"])

    def test_helpers_inside_string_interpolation_are_visible(self):
        source = "Text('${localeText(context, 'English', 'Türkçe')} suffix')"
        calls = [token.value for stream in ui.call_streams(ui.tokenize(source)) for token in stream]
        self.assertIn("localeText", calls)

    def test_finite_switches_do_not_treat_debug_string_as_copy(self):
        source = "String label(String side) => switch (side) { 'left' => 'Left', _ => 'Both', };"
        branches = ui.switch_values(ui.tokenize(source), "label")
        self.assertEqual(set(branches), {"'left'", "_"})
        self.assertEqual(ui.expand(branches["'left'"][0], {}), ["Left"])


if __name__ == "__main__":
    unittest.main()
