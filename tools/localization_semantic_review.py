"""Detect drift from manually reviewed critical-copy values; no certification.

This module does not assess translation meaning, medical safety or teaching.
Review data must be updated only after an actual independent review. There is
deliberately no generation/update/bless command. It imports no app checker.
Catalogs passed here must already have been read with duplicate-key rejection;
a dict cannot reveal duplicate keys discarded by a permissive JSON loader.
"""
from __future__ import annotations

import hashlib
import json
import re
from collections.abc import Mapping, Sequence
from pathlib import Path


REQUIRED_ANCHORS = {
    "h41_breathing_pause":
        "Choose two standing shapes, two seated/low shapes, one breathing pause and rest.",
    "h39_lower_seat":
        "Lower the seat before lifting either hand, then rest wrists without rolling onto them.",
    "h52_lower_seat":
        "Bend at the hips to lower the seat slowly; only after sitting down release hands and rest the wrists.",
    "wall_both_palms":
        "Keeping both palms in contact and knees soft, move the hips a little back and incline the trunk only a little. Elbows may straighten comfortably, never lock. This limited high wall variation is a preparation related to Downward Dog, not its floor form; no horizontal torso or head-below-hips target.",
    "progress_reading_list_ellipsis":
        "The reading itself will not — see above for why.",
}
KIND = "LISSOM_CRITICAL_COPY_REVIEW_V1"
_HASH = re.compile(r"[0-9a-f]{64}\Z")
_PENDING = {"todo", "pending", "unrun", "unknown", "replace", "tbd"}


def text_sha256(text: str) -> str:
    """Hash exact decoded text as UTF-8; never strip or normalize the value."""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def reject_duplicate_pairs(pairs: list[tuple[str, object]]) -> dict:
    result: dict = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON key: {key!r}")
        result[key] = value
    return result


def load_attestation(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"),
                      object_pairs_hook=reject_duplicate_pairs)


def _locale_list(value: object) -> list[str] | None:
    if not isinstance(value, Sequence) or isinstance(value, (str, bytes)):
        return None
    if not value or any(not isinstance(item, str) or not item.strip() for item in value):
        return None
    result = list(value)
    return result if len(result) == len(set(result)) else None


def _reference(value: object) -> bool:
    if not isinstance(value, str) or not value.strip():
        return False
    text = value.strip().lower()
    return text not in _PENDING and not text.startswith(
        ("todo:", "pending:", "unrun:", "replace:", "root_to_fill")
    )


def validate_semantic_review(
    catalogs: Mapping[str, Mapping[str, object]],
    attestation: object,
    *,
    locales: Sequence[str],
) -> list[str]:
    """Return drift/shape errors; an empty list only means the guards match.

    `catalogs` maps each caller-owned locale tag to its messages object. The
    caller owns the locale policy (14 tags for the current Lissom package).
    Only anchors are examined: this intentionally permits sparse unit fixtures
    and leaves full-catalog/source/placeholder/course integrity to the caller.
    """
    errors: list[str] = []
    expected = _locale_list(locales)
    if expected is None or "en" not in expected:
        return ["semantic review: caller locales must be unique, nonempty and include en"]
    if not isinstance(catalogs, Mapping):
        return ["semantic review: catalogs must map locales to messages"]
    if not isinstance(attestation, dict) or set(attestation) != {
        "schemaVersion", "kind", "locales", "anchors",
    }:
        return ["semantic review: missing or unexpected attestation fields"]
    if type(attestation["schemaVersion"]) is not int or attestation["schemaVersion"] != 1:
        errors.append("semantic review: unsupported schemaVersion")
    if attestation["kind"] != KIND:
        errors.append("semantic review: wrong kind")
    declared = _locale_list(attestation["locales"])
    if declared is None or set(declared) != set(expected):
        errors.append("semantic review: declared locales differ from caller locales")
    for locale in expected:
        if not isinstance(catalogs.get(locale), Mapping):
            errors.append(f"semantic review: missing messages for {locale}")
    anchors = attestation["anchors"]
    if not isinstance(anchors, list) or not anchors:
        return errors + ["semantic review: anchors must be a nonempty list"]
    seen_ids: set[str] = set()
    seen_keys: set[str] = set()
    for index, anchor in enumerate(anchors):
        label = f"semantic review anchor[{index}]"
        if not isinstance(anchor, dict) or set(anchor) != {
            "id", "english_key", "source_sha256", "source_refs", "targets",
        }:
            errors.append(f"{label}: missing or unexpected fields")
            continue
        anchor_id, key = anchor["id"], anchor["english_key"]
        if not isinstance(anchor_id, str) or not anchor_id.strip():
            errors.append(f"{label}: id must be nonempty")
            continue
        label = f"semantic review {anchor_id}"
        if anchor_id in seen_ids:
            errors.append(f"{label}: duplicate anchor id")
        seen_ids.add(anchor_id)
        if not isinstance(key, str) or not key.strip():
            errors.append(f"{label}: English key must be nonempty")
            continue
        if key in seen_keys:
            errors.append(f"{label}: duplicate English key")
        seen_keys.add(key)
        if anchor_id in REQUIRED_ANCHORS and key != REQUIRED_ANCHORS[anchor_id]:
            errors.append(f"{label}: required English key changed")
        try:
            source_hash = text_sha256(key)
        except UnicodeError:
            errors.append(f"{label}: English key is not valid UTF-8 text")
            continue
        if not isinstance(anchor["source_sha256"], str) or not _HASH.fullmatch(anchor["source_sha256"]):
            errors.append(f"{label}: source_sha256 must be lowercase SHA256")
        elif anchor["source_sha256"] != source_hash:
            errors.append(f"{label}: source hash mismatch; review required")
        source_refs = anchor["source_refs"]
        if not isinstance(source_refs, list) or not source_refs or not all(
            _reference(reference) for reference in source_refs
        ):
            errors.append(f"{label}: source_refs must identify key/display provenance")
        english = catalogs.get("en", {})
        if not isinstance(english, Mapping) or key not in english:
            errors.append(f"{label}: immutable English source key missing")
        # English display text may intentionally clarify an immutable key.
        # Like every other locale, it is bound by its separately reviewed hash.
        targets = anchor["targets"]
        if not isinstance(targets, dict) or set(targets) != set(expected):
            errors.append(f"{label}: targets must cover exactly caller locales")
            continue
        for locale in expected:
            target = targets[locale]
            where = f"{label}/{locale}"
            if not isinstance(target, dict) or set(target) != {"value_sha256", "reviewer", "review_ref"}:
                errors.append(f"{where}: missing or unexpected review fields")
                continue
            if not _reference(target["reviewer"]) or not _reference(target["review_ref"]):
                errors.append(f"{where}: reviewer and review_ref must identify completed review")
            expected_hash = target["value_sha256"]
            if not isinstance(expected_hash, str) or not _HASH.fullmatch(expected_hash):
                errors.append(f"{where}: value_sha256 must be lowercase SHA256")
                continue
            messages = catalogs.get(locale, {})
            value = messages.get(key) if isinstance(messages, Mapping) else None
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{where}: critical anchor must be a nonempty flat string")
                continue
            try:
                matches = text_sha256(value) == expected_hash
            except UnicodeError:
                matches = False
            if not matches:
                errors.append(f"{where}: target hash mismatch; independent review required")
    for anchor_id, key in REQUIRED_ANCHORS.items():
        if anchor_id not in seen_ids or key not in seen_keys:
            errors.append(f"semantic review: missing required anchor {anchor_id}")
    return errors


def semantic_review_errors(
    catalogs: Mapping[str, Mapping[str, object]],
    attestation_path: Path,
    *,
    locales: Sequence[str],
) -> list[str]:
    """Single-call adapter for check_content_localization.run(). Read only."""
    try:
        attestation = load_attestation(attestation_path)
    except (OSError, ValueError, UnicodeError) as error:
        return [f"semantic review: attestation unavailable/invalid: {error}"]
    return validate_semantic_review(catalogs, attestation, locales=locales)
