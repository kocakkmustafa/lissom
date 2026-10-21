#!/usr/bin/env python3
"""Validate app-owned locale catalogs against existing written course readers.

This source/content check does not run Flutter or certify translation, teaching,
RTL rendering, assistive technology or physical acceptance. Course JSON bytes
remain bound to their existing independent integrity manifests.
"""
from __future__ import annotations

import argparse
import ast
import collections
import functools
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path

from localization_semantic_review import semantic_review_errors

ROOT = Path(__file__).resolve().parent.parent
LOCALES = ("tr", "en", "es-419", "pt-BR", "de", "fr", "ja", "ar",
           "it", "ko", "id", "pl", "hi", "zh-Hans")
PLURAL_CATEGORIES = frozenset({"zero", "one", "two", "few", "many", "other"})
PLACEHOLDER = re.compile(r"\{([A-Za-z_][A-Za-z_0-9]*)\}")
LITERAL = re.compile(r'''(?:"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')''', re.S)
BIDI_CONTROLS = frozenset("\u061c\u200e\u200f\u202a\u202b\u202c\u202d\u202e\u2066\u2067\u2068\u2069")
COURSE_PINS = {
    "ashtanga-foundations.v1.json": "889d9f22f4006c151ff3ae1a980dcc7b8b00076035a99bdb3f9154b990fb75b1",
    "chair-office.v1.json": "2663ec6308a65f6e4131cf474ca2ae594bbf34bdff7e4d3c484ad1dcf6e97853",
    "hatha.v1.json": "be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c",
    "vinyasa-standing.v1.json": "64690c084e0b906c0974c9bf70ba7507572a8fcf2b225fe5438bb7c38f05f582",
    "yin-supported.v1.json": "647e5c88c1e61720bcd93a6170ca978ba623f296594733fd4d495fbfc1813a66",
}


@functools.lru_cache(maxsize=1)
def ui_source() -> dict:
    # The extractor reads shipped sources, not a private workspace report.
    # Bounded config fragments deliberately include surrounding spaces.
    import extract_ui_localization
    return extract_ui_localization.inventory(ROOT)


def reject_duplicate_pairs(pairs: list[tuple[str, object]]) -> dict:
    result: dict = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key!r}")
        result[key] = value
    return result


def read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=reject_duplicate_pairs)


def _arguments(source: str, open_at: int) -> list[str]:
    start, cursor, depth, result = open_at + 1, open_at + 1, 0, []
    while cursor < len(source):
        if source[cursor] in "\"'":
            match = LITERAL.match(source, cursor)
            if match is None:
                raise ValueError("unterminated Dart content literal")
            cursor = match.end()
            continue
        char = source[cursor]
        if char in "([{":
            depth += 1
        elif char in ")]}":
            if char == ")" and depth == 0:
                last = source[start:cursor].strip()
                if last:
                    result.append(last)
                return result
            depth -= 1
        elif char == "," and depth == 0:
            result.append(source[start:cursor].strip())
            start = cursor + 1
        cursor += 1
    raise ValueError("unterminated Dart content call")


def _literal(expression: str) -> str:
    tokens = list(LITERAL.finditer(expression))
    if not tokens or LITERAL.sub("", expression).strip():
        raise ValueError(f"unsupported content literal expression: {expression}")
    return "".join(ast.literal_eval(token.group()) for token in tokens)


def content_source(root: Path = ROOT) -> list[dict]:
    """Read the exact static data consumed by course, recall and diagram readers."""
    rows: list[dict] = []

    def add(path: str, field: str, en: str, tr: str, displayed: bool = True) -> None:
        rows.append({"file": path, "field": field, "english": en.strip(),
                     "turkish": tr.strip(), "displayed": displayed})

    for path in sorted((root / "config/courses").glob("*.json")):
        data = read_json(path)
        relative = str(path.relative_to(root))

        def walk(node: object, field: str = "$") -> None:
            if isinstance(node, dict):
                if set(node) == {"en", "tr"}:
                    if not all(isinstance(text, str) and text.strip() for text in node.values()):
                        raise ValueError(f"{relative}:{field} requires nonempty EN/TR")
                    add(relative, field, node["en"], node["tr"], not field.endswith(".mediaBrief"))
                else:
                    for key, value in node.items():
                        walk(value, field + "." + key)
            elif isinstance(node, list):
                for index, value in enumerate(node):
                    walk(value, f"{field}[{index}]")

        walk(data)

    path = root / "lib/app/study_review_content.dart"
    source = path.read_text(encoding="utf-8")
    for index, match in enumerate(re.finditer(r"\bStudyText\(", source)):
        args = _arguments(source, match.end() - 1)
        if len(args) == 2 and not args[0].startswith("this."):
            add(str(path.relative_to(root)), f"StudyText[{index}]", _literal(args[0]), _literal(args[1]))

    path = root / "lib/app/hatha_knowledge_diagrams.dart"
    source = path.read_text(encoding="utf-8")
    for index, match in enumerate(re.finditer(r"\b_Panel\(", source)):
        args = _arguments(source, match.end() - 1)
        if len(args) != 5 or args[0].startswith("this."):
            continue
        add(str(path.relative_to(root)), f"_Panel[{index}].title", _literal(args[1]), _literal(args[2]))
        en = [ast.literal_eval(item.group()) for item in LITERAL.finditer(args[3])]
        tr = [ast.literal_eval(item.group()) for item in LITERAL.finditer(args[4])]
        if len(en) != len(tr):
            raise ValueError(f"{path.name}: panel label parity")
        for label, (english, turkish) in enumerate(zip(en, tr)):
            add(str(path.relative_to(root)), f"_Panel[{index}].label[{label}]", english, turkish)
    return rows


def text_errors(text: str) -> list[str]:
    problems = []
    if not text.strip():
        problems.append("empty text")
    if text != unicodedata.normalize("NFC", text):
        problems.append("text is not NFC")
    if any(char in BIDI_CONTROLS for char in text):
        problems.append("embedded bidi control character")
    if any(char == "\ufffd" or (ord(char) < 32 and char not in "\t\n\r") for char in text):
        problems.append("replacement or prohibited control character")
    return problems


def message_errors(key: str, value: object) -> list[str]:
    expected = collections.Counter(PLACEHOLDER.findall(key))
    if isinstance(value, str):
        variants = [("text", value)]
    elif isinstance(value, dict) and value and set(value) <= PLURAL_CATEGORIES and "other" in value:
        variants = list(value.items())
    else:
        return ["message must be a string or CLDR category object including other"]
    problems = []
    for category, text in variants:
        if not isinstance(text, str):
            problems.append(f"{category}: value must be a string")
            continue
        problems.extend(f"{category}: {problem}" for problem in text_errors(text))
        actual = collections.Counter(PLACEHOLDER.findall(text))
        if actual != expected:
            problems.append(f"{category}: placeholder multiplicity mismatch: {dict(actual)} != {dict(expected)}")
    return problems


def validate_catalog(data: object, locale: str) -> tuple[dict[str, object], list[str]]:
    if not isinstance(data, dict):
        return {}, ["catalog root must be an object"]
    problems = []
    if set(data) != {"schemaVersion", "id", "locale", "messages"}:
        problems.append("unexpected or missing catalog fields")
    if type(data.get("schemaVersion")) is not int or data["schemaVersion"] != 1:
        problems.append("schemaVersion must be 1")
    if data.get("id") != f"lissom.l10n.{locale}" or data.get("locale") != locale:
        problems.append("catalog locale/id identity mismatch")
    messages = data.get("messages")
    if not isinstance(messages, dict) or not messages:
        return {}, problems + ["messages must be a nonempty object"]
    for key, value in messages.items():
        if not isinstance(key, str):
            problems.append("message key must be a string")
            continue
        problems.extend(f"key {key!r}: {problem}" for problem in text_errors(key))
        if key != key.strip() and key not in {
            row['english'] for row in ui_source()['entries']
            if row['english'] != row['english'].strip()
        }:
            problems.append(f"key {key!r}: unexpected outer whitespace")
        problems.extend(f"message {key!r}: {problem}" for problem in message_errors(key, value))
    return messages, problems


def run(catalog_dir: Path, source_catalog: Path | None = None, inventory_only: bool = False) -> dict:
    rows = content_source()
    keys = {row["english"] for row in rows}
    ui = ui_source()
    ui_keys = {row['english'] for row in ui['entries']}
    required_keys = keys | ui_keys
    problems: list[str] = []
    pins = {}
    for name, expected in COURSE_PINS.items():
        path = ROOT / "config/courses" / name
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        pins[name] = {"sha256": actual, "unchanged": actual == expected}
        if actual != expected:
            problems.append(f"course integrity changed: {name}")
    if source_catalog is not None:
        source = read_json(source_catalog)
        expected = {row["english"] for row in source["entries"]}
        if expected != keys:
            problems.append("frozen source catalog differs from current reader content")
    conflicts = []
    for key in sorted(keys):
        variants = sorted({row["turkish"] for row in rows if row["english"] == key})
        if len(variants) > 1:
            conflicts.append({"english": key, "turkishVariants": variants})
    result = {"kind": "LISSOM_CONTENT_LOCALIZATION_CHECK_V1", "frames": len(rows),
              "contentKeys": len(keys), "displayedFrames": sum(row["displayed"] for row in rows),
              "coursePins": pins, "turkishContextCollisions": conflicts,
              "uiKeys": len(ui_keys), "requiredKeys": len(required_keys),
              "unresolvedUiExpressions": ui['unresolved'],
              "catalogs": {}, "errors": problems,
              "acceptanceLimit": "Source/catalog contract only; translation meaning, visual/RTL/AT, Flutter and physical teaching acceptance are not tested."}
    if inventory_only:
        result["mode"] = "INVENTORY_ONLY_NO_TRANSLATION_ACCEPTANCE"
        return result
    loaded = {}
    for locale in LOCALES:
        path = catalog_dir / f"{locale}.json"
        try:
            data = read_json(path)
            messages, errors = validate_catalog(data, locale)
        except (OSError, ValueError, UnicodeError) as error:
            messages, errors = {}, [str(error)]
        loaded[locale] = messages
        missing_content = sorted(keys - messages.keys())
        missing_ui = sorted(ui_keys - messages.keys())
        # Catalogs also carry UI/config keys; these are reported, not rejected.
        non_content = sorted(messages.keys() - keys)
        unchanged = sorted(key for key in keys & messages.keys() if messages[key] == key)
        result["catalogs"][locale] = {"path": str(path), "messages": len(messages),
            "missingContentKeys": missing_content, "missingUiKeys": missing_ui,
            "nonContentKeys": non_content,
            "unchangedEnglishContentKeys": unchanged, "errors": errors}
        problems.extend(f"{locale}: {error}" for error in errors)
        if missing_content:
            problems.append(f"{locale}: missing {len(missing_content)} written-content keys")
        if missing_ui:
            problems.append(f"{locale}: missing {len(missing_ui)} UI/config keys")
        unexpected = sorted(messages.keys() - required_keys)
        result['catalogs'][locale]['unexpectedSourceKeys'] = unexpected
        if unexpected:
            problems.append(f"{locale}: {len(unexpected)} stale or unknown source keys")
    baseline = set(loaded.get("en", {}))
    for locale, messages in loaded.items():
        missing, extra = sorted(baseline - messages.keys()), sorted(messages.keys() - baseline)
        result["catalogs"][locale].update({"missingVsEnglish": missing, "extraVsEnglish": extra})
        if missing or extra:
            problems.append(f"{locale}: catalog key parity mismatch ({len(missing)} missing, {len(extra)} extra)")
    problems.extend(semantic_review_errors(
        loaded, ROOT / "tools/data/localization_semantic_review.v1.json",
        locales=LOCALES,
    ))
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog-dir", type=Path, default=ROOT / "config/l10n")
    parser.add_argument("--source-catalog", type=Path)
    parser.add_argument("--inventory-only", action="store_true")
    parser.add_argument("--json-output", type=Path)
    args = parser.parse_args()
    try:
        result = run(args.catalog_dir, args.source_catalog, args.inventory_only)
    except (OSError, ValueError, UnicodeError, KeyError, TypeError) as error:
        result = {"kind": "LISSOM_CONTENT_LOCALIZATION_CHECK_V1", "errors": [str(error)]}
    if args.json_output:
        args.json_output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Content localization: {result.get('frames', 0)} frames / {result.get('contentKeys', 0)} unique EN keys")
    for locale, detail in result.get("catalogs", {}).items():
        print(f"  {locale}: {detail['messages']} messages; {len(detail['missingContentKeys'])} missing content; "
              f"{len(detail['unchangedEnglishContentKeys'])} source-equal keys (not proof of translation)")
    for error in result["errors"]:
        print(f"ERROR: {error}", file=sys.stderr)
    print("Source/catalog contract only; Flutter/translation meaning/RTL/AT/teaching acceptance UNRUN.")
    return 1 if result["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
