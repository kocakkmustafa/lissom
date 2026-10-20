#!/usr/bin/env python3
"""Inventory source English/Turkish UI copy without executing Dart or Flutter.

This deliberately bounded Dart source reader resolves string literals, adjacent
literals, static string references/interpolation and conditional literal arms.
Unknown expressions are reported, never evaluated or silently called covered.
The source inventory is not translation, runtime, RTL or visual acceptance.
"""
from __future__ import annotations

import argparse
import collections
import dataclasses
import datetime
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLACEHOLDER = re.compile(r"\{([A-Za-z][A-Za-z0-9_]*)\}")
IDENTIFIER = re.compile(r"[A-Za-z_$][A-Za-z0-9_$]*")


@dataclasses.dataclass(frozen=True)
class Token:
    value: str
    start: int
    end: int
    kind: str = "symbol"


def _string_end(source: str, start: int) -> int:
    raw = source[start] == "r"
    quote_at = start + int(raw)
    quote = source[quote_at]
    delimiter = quote * (3 if source.startswith(quote * 3, quote_at) else 1)
    cursor = quote_at + len(delimiter)
    while cursor < len(source):
        if source.startswith(delimiter, cursor):
            return cursor + len(delimiter)
        if not raw and source[cursor] == "\\":
            cursor += 2
        elif not raw and source.startswith("${", cursor):
            cursor = _brace_end(source, cursor + 1) + 1
        else:
            cursor += 1
    raise ValueError(f"unterminated Dart string at offset {start}")


def _brace_end(source: str, start: int) -> int:
    depth, cursor = 1, start + 1
    while cursor < len(source):
        if source[cursor] in "\"'" or (
            source[cursor] == "r" and source[cursor + 1:cursor + 2] in ("'", '"')
        ):
            cursor = _string_end(source, cursor)
            continue
        if source.startswith("//", cursor):
            next_line = source.find("\n", cursor)
            cursor = len(source) if next_line == -1 else next_line + 1
            continue
        if source.startswith("/*", cursor):
            end = source.find("*/", cursor + 2)
            if end == -1:
                raise ValueError("unterminated Dart block comment")
            cursor = end + 2
            continue
        depth += (source[cursor] == "{") - (source[cursor] == "}")
        if depth == 0:
            return cursor
        cursor += 1
    raise ValueError("unterminated Dart interpolation")


def tokenize(source: str, offset: int = 0) -> list[Token]:
    result, cursor = [], 0
    while cursor < len(source):
        if source[cursor].isspace():
            cursor += 1
            continue
        if source.startswith("//", cursor):
            end = source.find("\n", cursor)
            cursor = len(source) if end == -1 else end + 1
            continue
        if source.startswith("/*", cursor):
            end = source.find("*/", cursor + 2)
            if end == -1:
                raise ValueError("unterminated Dart block comment")
            cursor = end + 2
            continue
        if source[cursor] in "\"'" or (
            source[cursor] == "r" and source[cursor + 1:cursor + 2] in ("'", '"')
        ):
            end = _string_end(source, cursor)
            result.append(Token(source[cursor:end], cursor + offset, end + offset, "string"))
            cursor = end
            continue
        match = IDENTIFIER.match(source, cursor)
        if match:
            end = match.end()
            result.append(Token(match.group(), cursor + offset, end + offset, "identifier"))
            cursor = end
            continue
        result.append(Token(source[cursor], cursor + offset, cursor + offset + 1))
        cursor += 1
    return result


def arguments(tokens: list[Token], opening: int) -> list[list[Token]]:
    result, start, depth = [], opening + 1, 0
    for index in range(start, len(tokens)):
        value = tokens[index].value
        if value in "([{":
            depth += 1
        elif value in ")]}":
            if value == ")" and depth == 0:
                if index > start:
                    result.append(tokens[start:index])
                return result
            depth -= 1
        elif value == "," and depth == 0:
            result.append(tokens[start:index])
            start = index + 1
    raise ValueError("unterminated Dart call")


def _ternary(tokens: list[Token]) -> tuple[list[Token], list[Token]] | None:
    depth, nested, question = 0, 0, None
    for index, token in enumerate(tokens):
        value = token.value
        if value in "([{":
            depth += 1
        elif value in ")]}":
            depth -= 1
        elif depth == 0 and value == "?":
            if question is None:
                question = index
            else:
                nested += 1
        elif depth == 0 and value == ":" and question is not None:
            if nested:
                nested -= 1
            else:
                return tokens[question + 1:index], tokens[index + 1:]
    return None


def decode_literal(value: str, constants: dict[str, str], scope: str = "") -> str:
    raw = value.startswith("r")
    literal = value[1:] if raw else value
    width = 3 if literal.startswith(("'''", '"""')) else 1
    body = literal[width:-width]
    if raw:
        return body
    # Python literal decoding preserves Unicode and the shared Dart escapes.
    # Protect interpolation expressions first: their embedded quotes are Dart.
    cursor, pieces, literal_start = 0, [], 0
    while cursor < len(body):
        if body[cursor] == "\\":
            cursor += 2
            continue
        if body[cursor] != "$":
            cursor += 1
            continue
        pieces.append(_unescape(body[literal_start:cursor]))
        if body.startswith("${", cursor):
            end = _brace_end(body, cursor + 1)
            expression = body[cursor + 2:end]
            variants = expand(tokenize(expression), constants, scope)
            if len(variants) != 1:
                raise ValueError("interpolation has multiple conditional values")
            pieces.append(variants[0])
            cursor = end + 1
        else:
            match = IDENTIFIER.match(body, cursor + 1)
            if match is None:
                raise ValueError("unresolved Dart interpolation")
            name = match.group()
            key = f"{scope}.{name}" if scope and f"{scope}.{name}" in constants else name
            if key not in constants:
                raise ValueError(f"unresolved interpolation: {name}")
            pieces.append(constants[key])
            cursor = match.end()
        literal_start = cursor
    pieces.append(_unescape(body[literal_start:]))
    return "".join(pieces)


def _unescape(body: str) -> str:
    pattern = re.compile(r"\\(u\{[0-9a-fA-F]+\}|u[0-9a-fA-F]{4}|x[0-9a-fA-F]{2}|.)", re.S)
    def replace(match: re.Match) -> str:
        value = match.group(1)
        if value.startswith("u{"):
            return chr(int(value[2:-1], 16))
        if value.startswith(("u", "x")):
            return chr(int(value[1:], 16))
        return {"n": "\n", "r": "\r", "t": "\t", "b": "\b", "f": "\f", "v": "\v"}.get(value, value)
    return pattern.sub(replace, body)


def expand(tokens: list[Token], constants: dict[str, str], scope: str = "") -> list[str]:
    while len(tokens) >= 2 and tokens[0].value == "(" and tokens[-1].value == ")":
        tokens = tokens[1:-1]
    conditional = _ternary(tokens)
    if conditional:
        return expand(conditional[0], constants, scope) + expand(conditional[1], constants, scope)
    if tokens and tokens[0].value == "switch":
        opening = next((i for i, token in enumerate(tokens) if token.value == "{"), None)
        if opening is not None:
            return [value for expression, _ in switch_branches(tokens, opening).values()
                    for value in expand(expression, constants, scope)]
    if tokens and all(token.kind == "string" for token in tokens):
        return ["".join(decode_literal(token.value, constants, scope) for token in tokens)]
    name = "".join(token.value for token in tokens)
    key = f"{scope}.{name}" if scope and f"{scope}.{name}" in constants else name
    if key in constants:
        return [constants[key]]
    raise ValueError(f"unresolved expression: {name[:100]}")


def _class_ranges(tokens: list[Token]) -> list[tuple[str, int, int]]:
    ranges = []
    for index, token in enumerate(tokens[:-1]):
        if token.value != "class":
            continue
        name = tokens[index + 1].value
        opening = next((n for n in range(index + 2, len(tokens)) if tokens[n].value == "{"), None)
        if opening is None:
            continue
        depth = 1
        for end in range(opening + 1, len(tokens)):
            depth += (tokens[end].value == "{") - (tokens[end].value == "}")
            if depth == 0:
                ranges.append((name, tokens[opening].start, tokens[end].end))
                break
    return ranges


def _scope_at(ranges: list[tuple[str, int, int]], position: int) -> str:
    return next((name for name, start, end in ranges if start <= position <= end), "")


def call_streams(tokens: list[Token]):
    """Inspect helper calls embedded in Dart string interpolation as well."""
    yield tokens
    for token in tokens:
        if token.kind != "string" or token.value.startswith("r"):
            continue
        width = 3 if token.value.startswith(("'''", '"""')) else 1
        body, cursor = token.value[width:-width], 0
        while cursor < len(body):
            if body[cursor] == "\\":
                cursor += 2
            elif body.startswith("${", cursor):
                end = _brace_end(body, cursor + 1)
                nested = tokenize(body[cursor + 2:end], token.start + width + cursor + 2)
                yield from call_streams(nested)
                cursor = end + 1
            else:
                cursor += 1


def inventory(root: Path = ROOT) -> dict:
    files = sorted((root / "lib").rglob("*.dart")) + sorted((root / "packages/lissom_engine/lib").rglob("*.dart"))
    sources = {str(path.relative_to(root)): path.read_text(encoding="utf-8") for path in files}
    token_sets = {name: tokenize(source) for name, source in sources.items()}
    ranges = {name: _class_ranges(tokens) for name, tokens in token_sets.items()}
    declarations, constants = [], {}
    for name, tokens in token_sets.items():
        for index in range(len(tokens) - 4):
            if [token.value for token in tokens[index:index + 2]] != ["const", "String"]:
                continue
            if tokens[index + 3].value != "=":
                continue
            end = next(n for n in range(index + 4, len(tokens)) if tokens[n].value == ";")
            scope = _scope_at(ranges[name], tokens[index].start)
            key = (scope + "." if scope else "") + tokens[index + 2].value
            declarations.append((key, tokens[index + 4:end], scope, name, tokens[index].start))
    for _ in range(len(declarations) + 1):
        changed = False
        for key, expression, scope, _, _ in declarations:
            if key in constants:
                continue
            try:
                variants = expand(expression, constants, scope)
                if len(variants) == 1:
                    constants[key], changed = variants[0], True
            except ValueError:
                pass
        if not changed:
            break

    rows, unresolved = [], []
    def add(en: str, tr: str | None, name: str, position: int, kind: str) -> None:
        rows.append({"english": en, "turkish": tr, "kind": kind, "file": name,
                     "line": sources[name].count("\n", 0, position) + 1})

    for name, outer_tokens in token_sets.items():
      for tokens in call_streams(outer_tokens):
        for index, token in enumerate(tokens[:-1]):
            if token.value not in {"localeText", "localeTemplate", "localePlural", "_text"} or tokens[index + 1].value != "(":
                continue
            args = arguments(tokens, index + 1)
            if len(args) < 3 or any(t.value == "BuildContext" for t in args[0]):
                continue
            scope = _scope_at(ranges[name], token.start)
            try:
                en = expand(args[1], constants, scope)
                tr = expand(args[2], constants, scope)
                if len(en) != len(tr):
                    raise ValueError("conditional English/Turkish arm count differs")
                for english, turkish in zip(en, tr):
                    add(english, turkish, name, token.start, token.value)
                if token.value == "localePlural":
                    for arg in args[4:]:
                        if len(arg) > 2 and [x.value for x in arg[:2]] == ["englishOne", ":"]:
                            for english in expand(arg[2:], constants, scope):
                                add(english, tr[0], name, token.start, "localePlural.one")
            except ValueError as error:
                unresolved.append({"file": name, "line": sources[name].count("\n", 0, token.start) + 1,
                    "function": token.value, "englishExpression": sources[name][args[1][0].start:args[1][-1].end],
                    "turkishExpression": sources[name][args[2][0].start:args[2][-1].end], "reason": str(error)})

    return _finish(root, sources, token_sets, ranges, constants, declarations, rows, unresolved)


def _finish(root: Path, sources: dict, token_sets: dict, ranges: dict, constants: dict,
            declarations: list, rows: list, unresolved: list) -> dict:
    # Exact map entries; values are adjacent literals in this curated file.
    name = "lib/app/locale_text.dart"
    tokens = token_sets[name]
    for map_name in ("_turkishConfigCopy", "_turkishBlockerParts"):
        start = next(i for i, token in enumerate(tokens) if token.value == map_name and tokens[i + 1].value == "=")
        opening = next(i for i in range(start, len(tokens)) if tokens[i].value == "{")
        depth, entry_start = 0, opening + 1
        for index in range(opening + 1, len(tokens)):
            value = tokens[index].value
            if value in "([{": depth += 1
            if value in ")]}":
                if value == "}" and depth == 0:
                    break
                depth -= 1
            if value != "," or depth != 0:
                continue
            entry = tokens[entry_start:index]
            entry_start = index + 1
            colon = next((i for i, token in enumerate(entry) if token.value == ":"), None)
            if colon is None:
                continue
            english = expand(entry[:colon], constants)[0]
            turkish = expand(entry[colon + 1:], constants)[0]
            rows.append({"english": english, "turkish": turkish, "kind": map_name,
                         "file": name, "line": sources[name].count("\n", 0, entry[0].start) + 1})

    # Include named summary furniture; the surface currently has no production
    # caller, so its source inventory must not imply shipping route coverage.
    for key, _, _, name, position in declarations:
        if key.startswith("SummaryStrings.") and key in constants:
            rows.append({"english": constants[key], "turkish": None, "kind": "summary_constant_unwired",
                "symbol": key, "file": name, "line": sources[name].count("\n", 0, position) + 1})

    # These existing paired functions map finite engine codes, never user text.
    for name, tokens in token_sets.items():
        for english_name, turkish_name in (
            ("_label", "_labelTr"), ("_regime", "_regimeTr"),
            ("_reasonText", "_reasonTextTr"), ("_resultReason", "_resultReasonTr"),
        ):
            en_branches = switch_values(tokens, english_name)
            tr_branches = switch_values(tokens, turkish_name)
            # The existing side label is capitalized from a finite side enum;
            # retain unknown side IDs instead of assuming a new translation.
            if (english_name == "_label" and not en_branches and tr_branches and
                "side[0].toUpperCase()" in sources[name]):
                for case, (expression, position) in tr_branches.items():
                    if case not in {"'right'", "'left'", "'bilateral'"}:
                        continue
                    side = expand(tokenize(case), constants)[0]
                    rows.append({"english": side[0].upper() + side[1:],
                        "turkish": expand(expression, constants)[0],
                        "kind": "derived_side_label", "file": name,
                        "line": sources[name].count("\n", 0, position) + 1})
            for case, (expression, position) in en_branches.items():
                if case not in tr_branches:
                    continue
                try:
                    english = expand(expression, constants)[0]
                    turkish = expand(tr_branches[case][0], constants)[0]
                    rows.append({"english": english, "turkish": turkish,
                        "kind": "paired_code_switch", "symbol": f"{english_name}:{case}",
                        "file": name, "line": sources[name].count("\n", 0, position) + 1})
                except ValueError as error:
                    unresolved.append({"file": name, "line": sources[name].count("\n", 0, position) + 1,
                        "function": english_name, "englishExpression": "".join(t.value for t in expression),
                        "turkishExpression": None, "reason": str(error)})

    for name, tokens in token_sets.items():
        for index, token in enumerate(tokens[:-1]):
            if (token.value == "get" and index + 3 < len(tokens) and
                [t.value for t in tokens[index + 1:index + 4]] == ["userText", "=", ">"]):
                end = next(i for i in range(index + 4, len(tokens)) if tokens[i].value == ";")
                try:
                    for english in expand(tokens[index + 4:end], constants, _scope_at(ranges[name], token.start)):
                        rows.append({"english": english, "turkish": None, "kind": "runtime_userText_getter",
                            "file": name, "line": sources[name].count("\n", 0, token.start) + 1})
                except ValueError as error:
                    unresolved.append({"file": name, "line": sources[name].count("\n", 0, token.start) + 1,
                        "function": "runtime_userText_getter", "englishExpression": sources[name][tokens[index + 4].start:tokens[end - 1].end],
                        "turkishExpression": None, "reason": str(error)})
            if token.value != "userText" or tokens[index + 1].value != ":":
                continue
            depth, end = 0, index + 2
            for end in range(index + 2, len(tokens)):
                value = tokens[end].value
                if value in "([{": depth += 1
                if value in ")]}":
                    if depth == 0: break
                    depth -= 1
                if value == "," and depth == 0: break
            try:
                for english in expand(tokens[index + 2:end], constants, _scope_at(ranges[name], token.start)):
                    rows.append({"english": english, "turkish": None, "kind": "runtime_userText",
                        "file": name, "line": sources[name].count("\n", 0, token.start) + 1})
            except ValueError as error:
                unresolved.append({"file": name, "line": sources[name].count("\n", 0, token.start) + 1,
                    "function": "runtime_userText", "englishExpression": sources[name][tokens[index + 2].start:tokens[end - 1].end],
                    "turkishExpression": None, "reason": str(error)})

    grouped = collections.defaultdict(list)
    for row in rows:
        grouped[row["english"]].append(row)
    entries, conflicts = [], []
    for english, occurrences in sorted(grouped.items()):
        translations = list(dict.fromkeys(row["turkish"] for row in occurrences if row["turkish"] is not None))
        entries.append({"english": english, "turkish": translations[0] if translations else None,
            "placeholders": dict(collections.Counter(PLACEHOLDER.findall(english))),
            "occurrences": [{key: value for key, value in row.items() if key not in {"english", "turkish"}} for row in occurrences]})
        if len(translations) > 1:
            conflicts.append({"english": english, "turkishVariants": translations})
    return {"schemaVersion": 1, "id": "lissom.ui-source-catalog", "generatedAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "head": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
        "method": "STATIC_SOURCE_INVENTORY_NOT_DART_OR_VISUAL_ACCEPTANCE",
        "sourceSha256": {name: hashlib.sha256(source.encode()).hexdigest() for name, source in sorted(sources.items())},
        "counts": {"sourceFiles": len(sources), "resolvedOccurrences": len(rows), "uniqueSourceKeys": len(entries),
            "unresolvedExpressions": len(unresolved), "turkishUnresolvedKeys": sum(entry["turkish"] is None for entry in entries), "conflicts": len(conflicts)},
        "entries": entries, "unresolved": unresolved, "conflicts": conflicts}


def switch_values(tokens: list[Token], function: str) -> dict:
    for index, token in enumerate(tokens[:-1]):
        if token.value != function or tokens[index + 1].value != "(":
            continue
        close, depth = index + 2, 0
        for close in range(index + 2, len(tokens)):
            value = tokens[close].value
            if value == "(": depth += 1
            if value == ")":
                if depth == 0: break
                depth -= 1
        if [t.value for t in tokens[close + 1:close + 4]] != ["=", ">", "switch"]:
            continue
        opening = next(i for i in range(close + 4, len(tokens)) if tokens[i].value == "{")
        return switch_branches(tokens, opening, token.start)
    return {}


def switch_branches(tokens: list[Token], opening: int, position: int = 0) -> dict:
    result, depth, start = {}, 0, opening + 1
    for cursor in range(start, len(tokens)):
        value = tokens[cursor].value
        if value in "([{": depth += 1
        if value in ")]}":
            if depth == 0: return result
            depth -= 1
        if value == "," and depth == 0:
            branch = tokens[start:cursor]
            start = cursor + 1
            arrow = next((i for i in range(len(branch) - 1)
                if [t.value for t in branch[i:i + 2]] == ["=", ">"]), None)
            if arrow is not None:
                pattern = "".join(t.value for t in branch[:arrow])
                result[pattern] = (branch[arrow + 2:], position)
    return result


def seed_catalogs(data: dict, root: Path = ROOT) -> dict:
    from check_content_localization import content_source
    messages = {"en": {}, "tr": {}}
    conflicts = []
    for row in content_source(root):
        en, tr = row["english"], row["turkish"]
        if en in messages["tr"] and messages["tr"][en] != tr:
            conflicts.append({"english": en, "kept": messages["tr"][en], "alternative": tr, "file": row["file"]})
        messages["en"][en] = en
        messages["tr"].setdefault(en, tr)
    fallback = []
    for row in data["entries"]:
        en, tr = row["english"], row["turkish"]
        messages["en"][en] = en
        if tr is not None:
            messages["tr"][en] = tr
        elif en not in messages["tr"]:
            messages["tr"][en] = en
            fallback.append(en)
    for locale in ("en", "tr"):
        path = root / "config/l10n" / f"{locale}.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"schemaVersion": 1, "id": f"lissom.l10n.{locale}",
            "locale": locale, "messages": dict(sorted(messages[locale].items()))}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {"enKeys": len(messages["en"]), "trKeys": len(messages["tr"]),
        "turkishSourceFallbackKeys": fallback, "contentTurkishSourceConflicts": conflicts}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--seed-catalogs", action="store_true")
    args = parser.parse_args()
    data = inventory()
    if args.seed_catalogs:
        data["seed"] = seed_catalogs(data)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"output": str(args.output), "counts": data["counts"], "seed": data.get("seed")}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
