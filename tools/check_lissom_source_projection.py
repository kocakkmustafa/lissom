#!/usr/bin/env python3
"""Check Lissom's app-owned, source-only v2l projection without workspace ops.

The two bundled JSON files identify preproduction source. They contain no
playable media or release decision. Keep the byte pins here independent of the
payload, and walk all input components from the opened app root without
following symlinks.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
from pathlib import Path


APP = Path(__file__).resolve().parent.parent
INPUTS = {
    "course": Path("config/courses/hatha.v1.json"),
    "slice": Path("assets/motion_content/lissom.source-slice.v1.json"),
    "projection": Path("assets/motion_content/lissom.source-projection.v1.json"),
}
COURSE_SHA256 = "be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c"
SLICE_SHA256 = "e2cfc724e7032d9a465e553af7227609c0f2c65414123a56af7139cdfa0694e8"
PROJECTION_SHA256 = "088b726a397b195a4bd531b747daf18eab5c5990a5766d5297d36a0eae3fc322"
CATALOG_SHA256 = "791bfea8e1479307794bcf8799cf703a7a840bcd3058c1a0d7fdf065d32d8594"
MANIFEST_SHA256 = "d887683c9a9b9bdb8d4ab7c51cdc5a5b4b4de6a918079e4cfd9cf543e9751e60"
PROOF_SHA256 = "dec615e14881b86b7676e1157f63b8bf6269026d856e59f2ee3a65d7f97e512a"
EXPECTED_BYTES = {"course": 270935, "slice": 307530, "projection": 264229}
HELD_SOURCE_PINS = frozenset({
    "321edb15073f00ad6d745d6437a1aa98695255b1848b3f1aee725bca3e43de92",
    "3fefba245a8ea5a687e906e7649cddd1c83150b8890decd7088f2c47a5abf347",
    "418df797aaaa633d6c50dab2c81ae476ade4248aec67624d7dbde6f233c264a9",
    "42f1222b86161c09b95e78a823fda6804ae516dcf3fc824d6e6dba4a80828d8f",
    "81b0e33c7092684afaf91b1b77ee98b57822754afd457e19f4df5c9781d54251",
    "c3bee8c5ad0ad01ea8a1d015696ae5fdc14fe38bd457da262c7bc6796a2e0eab",
    "dbde90be72f4ca53a2f9f13e07f96a6e69f634297bb553d2942aca72b8737363",
    "e5ed8c20626e06858f8444abbf7a01796f6e0e4bf2e22c2042cc83025d1dfa2c",
})
H30_HOLD = {
    "app": "lissom", "code": "LISSOM_H30_GAP500_YEI_REST_CREDIT",
    "gapId": "gap-500", "lessonId": "h30",
    "status": "HOLD_SOURCE_SEMANTIC_P2",
    "supportedSourceScope": "small_bridge_only", "targetId": "rest",
    "unsupportedSourceId": "lissom:yei_bridge_flow",
}
LIMITS = {"course": 2 * 1024 * 1024, "slice": 2 * 1024 * 1024,
          "projection": 2 * 1024 * 1024, "pubspec": 512 * 1024}
DIR_FLAGS = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC
FILE_FLAGS = os.O_RDONLY | os.O_NOFOLLOW | os.O_CLOEXEC


class ProjectionError(ValueError):
    """A local source identity, shape, or source-only boundary changed."""


def require(condition: bool, code: str) -> None:
    if not condition:
        raise ProjectionError(code)


def digest(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def canonical(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":"), allow_nan=False).encode("utf-8")


def _pairs(pairs: list[tuple[str, object]]) -> dict:
    value = {}
    for key, item in pairs:
        require(key not in value, "DUPLICATE_JSON_KEY")
        value[key] = item
    return value


def parse_json(raw: bytes, *, source_only: bool) -> dict:
    try:
        value = json.loads(raw.decode("utf-8"), object_pairs_hook=_pairs,
                           parse_constant=lambda _: (_ for _ in ()).throw(
                               ProjectionError("NONFINITE_JSON")))
        require(isinstance(value, dict), "JSON_OBJECT")
        if source_only:
            require(canonical(value) == raw, "NONCANONICAL_SOURCE_JSON")
        return value
    except ProjectionError:
        raise
    except (UnicodeError, ValueError, TypeError, RecursionError, OverflowError) as error:
        raise ProjectionError("INVALID_JSON") from error


def read_from_root(root_fd: int, relative: Path, limit: int) -> bytes:
    """Open every relative component by FD, never by a followed path."""
    parts = relative.parts
    require(parts and all(part not in ("", ".", "..") for part in parts),
            "INPUT_RELATIVE_PATH")
    parent_fd = os.dup(root_fd)
    try:
        for component in parts[:-1]:
            try:
                next_fd = os.open(component, DIR_FLAGS, dir_fd=parent_fd)
            except OSError as error:
                raise ProjectionError("INPUT_SYMLINK_OR_UNAVAILABLE") from error
            os.close(parent_fd)
            parent_fd = next_fd
        try:
            file_fd = os.open(parts[-1], FILE_FLAGS, dir_fd=parent_fd)
        except OSError as error:
            raise ProjectionError("INPUT_SYMLINK_OR_UNAVAILABLE") from error
        try:
            shape = os.fstat(file_fd)
            require(stat.S_ISREG(shape.st_mode) and 0 < shape.st_size <= limit,
                    "INPUT_SHAPE_OR_SIZE")
            chunks = []
            remaining = limit + 1
            while remaining:
                chunk = os.read(file_fd, min(remaining, 64 * 1024))
                if not chunk:
                    break
                chunks.append(chunk)
                remaining -= len(chunk)
            raw = b"".join(chunks)
            require(len(raw) == shape.st_size and len(raw) <= limit,
                    "INPUT_CHANGED_OR_OVERSIZE")
            return raw
        finally:
            os.close(file_fd)
    finally:
        os.close(parent_fd)


def exact_keys(value: object, keys: set[str], code: str) -> None:
    require(isinstance(value, dict) and set(value) == keys, code)


def validate_payloads(course: dict, source_slice: dict, projection: dict) -> tuple[int, int, int, int]:
    """Rebuild every row and its sceneOrder from the source slice and live course."""
    try:
        slice_keys = {"schemaVersion", "kind", "appId", "sourceCatalogSHA256",
                      "sourceManifestSHA256", "sourceProofSHA256",
                      "courseSourceSHA256", "lessons", "holds"}
        projection_keys = slice_keys - {"sourceProofSHA256", "lessons", "holds"} | {"rows"}
        exact_keys(source_slice, slice_keys, "SOURCE_ONLY_SLICE_SCHEMA")
        exact_keys(projection, projection_keys, "SOURCE_ONLY_PROJECTION_SCHEMA")
        for value, kind in ((source_slice, "MOTION_V2L_APP_SOURCE_SLICE_V1"),
                            (projection, "MOTION_V2L_APP_SOURCE_PROJECTION_V1")):
            require(value["schemaVersion"] == 1 and value["kind"] == kind and
                    value["appId"] == "lissom" and
                    value["sourceCatalogSHA256"] == CATALOG_SHA256 and
                    value["sourceManifestSHA256"] == MANIFEST_SHA256 and
                    value["courseSourceSHA256"] == COURSE_SHA256,
                    "SOURCE_IDENTITY")
        require(source_slice["sourceProofSHA256"] == PROOF_SHA256,
                "SOURCE_PROOF_IDENTITY")
        require(source_slice["holds"] == [H30_HOLD], "HOLD_RECORD")
        require(isinstance(source_slice["lessons"], list) and
                isinstance(projection["rows"], list), "SOURCE_ONLY_LISTS")

        course_lessons = [lesson for module in course["modules"]
                          for lesson in module["lessons"]]
        expected_ids = [f"h{number:02d}" for number in range(1, 61)]
        require([lesson["id"] for lesson in course_lessons] == expected_ids,
                "LIVE_COURSE_LESSONS")
        h30 = course_lessons[29]
        bridge_scope = course["sourceScopes"]["yei_bridge_flow"]
        require("yei_bridge_flow" in h30["sourceIds"] and
                "single-leg reset" in bridge_scope["doesNotSupport"]["en"] and
                "both feet on the mat before a small bridge" in
                " ".join(step["en"] for step in h30["steps"]),
                "HOLD_COURSE_SEMANTIC")

        rows = []
        seen_pins: set[str] = set()
        seen_scenes: set[str] = set()
        seen_stems: set[str] = set()
        held_pins: set[str] = set()
        scene_count = variant_count = 0
        lessons = source_slice["lessons"]
        require(len(lessons) == 60 and
                [lesson["lessonId"] for lesson in lessons] == expected_ids,
                "SOURCE_LESSON_COUNT_OR_ORDER")
        for lesson, live_lesson in zip(lessons, course_lessons, strict=True):
            exact_keys(lesson, {"app", "assetId", "courseSourceSHA256",
                                "lessonCanonicalSHA256", "lessonId",
                                "membershipStatus", "scenes"}, "SOURCE_ONLY_LESSON_SCHEMA")
            lesson_id = lesson["lessonId"]
            require(lesson["app"] == "lissom" and
                    lesson["courseSourceSHA256"] == COURSE_SHA256 and
                    lesson["assetId"] == f"lissom.{lesson_id}.v3.demo" and
                    isinstance(lesson["lessonCanonicalSHA256"], str),
                    "SOURCE_LESSON_IDENTITY")
            require(lesson["lessonCanonicalSHA256"] ==
                    digest(canonical(live_lesson)), "LESSON_CANONICAL_DRIFT")
            expected_membership = ("HOLD_SOURCE_SEMANTIC_P2" if lesson_id == "h30"
                                   else "SOURCE_PINNED_TEST_ONLY")
            require(lesson["membershipStatus"] == expected_membership,
                    "HOLD_MEMBERSHIP")
            require(isinstance(lesson["scenes"], list) and
                    len(lesson["scenes"]) == 8, "SOURCE_SCENE_COUNT")
            for order, scene in enumerate(lesson["scenes"]):
                exact_keys(scene, {"idempotencyKey", "productionSpecSHA256",
                                   "productionState", "sceneId", "sourceCueSHA256",
                                   "variants"}, "SOURCE_ONLY_SCENE_SCHEMA")
                scene_id = scene["sceneId"]
                require(isinstance(scene_id, str) and
                        scene_id.startswith(f"lissom:{lesson_id}:") and
                        scene_id not in seen_scenes, "SOURCE_SCENE_ID")
                seen_scenes.add(scene_id)
                scene_count += 1
                require(scene["productionState"] == "PREPRODUCTION_UNGENERATED"
                        and scene["idempotencyKey"] ==
                        f"motion-media-v1:{scene['productionSpecSHA256']}",
                        "SOURCE_ONLY_PREPRODUCTION")
                require(isinstance(scene["variants"], list) and
                        len(scene["variants"]) == 1, "SOURCE_VARIANT_COUNT")
                for variant in scene["variants"]:
                    exact_keys(variant, {"stem", "sourcePinSHA256"},
                               "SOURCE_ONLY_VARIANT_SCHEMA")
                    pin, stem = variant["sourcePinSHA256"], variant["stem"]
                    require(isinstance(pin, str) and isinstance(stem, str) and
                            pin not in seen_pins and stem not in seen_stems and
                            stem.startswith(f"lissom/{lesson_id}--"),
                            "SOURCE_VARIANT_ID")
                    seen_pins.add(pin)
                    seen_stems.add(stem)
                    variant_count += 1
                    identity = {
                        "manifestSHA256": MANIFEST_SHA256, "app": "lissom",
                        "courseSourceSHA256": COURSE_SHA256,
                        "lessonId": lesson_id,
                        "lessonCanonicalSHA256": lesson["lessonCanonicalSHA256"],
                        "assetId": lesson["assetId"], "sceneId": scene_id,
                        "variantStem": stem,
                        "productionSpecSHA256": scene["productionSpecSHA256"],
                        "sourceCueSHA256": scene["sourceCueSHA256"],
                        "idempotencyKey": scene["idempotencyKey"],
                        "productionState": scene["productionState"],
                    }
                    require(pin == digest(canonical(identity)),
                            "SOURCE_VARIANT_IDENTITY")
                    held = lesson_id == "h30"
                    if held:
                        held_pins.add(pin)
                    rows.append([
                        pin, lesson_id, lesson["assetId"], scene_id, order,
                        stem, lesson["lessonCanonicalSHA256"],
                        scene["productionSpecSHA256"], scene["sourceCueSHA256"],
                        scene["idempotencyKey"], held,
                    ])
        require((len(lessons), scene_count, variant_count, len(held_pins)) ==
                (60, 480, 480, 8), "SOURCE_COUNTS")
        require(held_pins == HELD_SOURCE_PINS, "HOLD_PIN_SET")
        require(projection["rows"] == sorted(rows, key=lambda row: row[0]),
                "ROWS_DRIFT")
        return 60, scene_count, variant_count, len(held_pins)
    except ProjectionError:
        raise
    except (KeyError, IndexError, TypeError, ValueError) as error:
        raise ProjectionError("SOURCE_ONLY_SCHEMA") from error


def check(app_root: Path = APP) -> tuple[int, int, int, int]:
    try:
        root_fd = os.open(app_root, DIR_FLAGS)
    except OSError as error:
        raise ProjectionError("INPUT_SYMLINK_APP_ROOT") from error
    try:
        raw = {name: read_from_root(root_fd, path, LIMITS[name])
               for name, path in INPUTS.items()}
        pubspec = read_from_root(root_fd, Path("pubspec.yaml"), LIMITS["pubspec"])
    finally:
        os.close(root_fd)
    try:
        pubspec_lines = pubspec.decode("utf-8").splitlines()
    except UnicodeError as error:
        raise ProjectionError("PUBSPEC_ENCODING") from error
    for path in (INPUTS["slice"], INPUTS["projection"]):
        line = f"    - {path.as_posix()}"
        require(pubspec_lines.count(line) == 1,
                "FLUTTER_ASSET_NOT_EXPLICIT")
    course = parse_json(raw["course"], source_only=False)
    source_slice = parse_json(raw["slice"], source_only=True)
    projection = parse_json(raw["projection"], source_only=True)
    result = validate_payloads(course, source_slice, projection)
    for name, expected in (("course", COURSE_SHA256), ("slice", SLICE_SHA256),
                           ("projection", PROJECTION_SHA256)):
        require(len(raw[name]) == EXPECTED_BYTES[name],
                f"{name.upper()}_BYTE_LENGTH_DRIFT")
        require(digest(raw[name]) == expected, f"{name.upper()}_BYTE_SHA_DRIFT")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="verify app-owned source assets (also the default)")
    parser.parse_args()
    try:
        lessons, scenes, variants, held = check()
    except ProjectionError as error:
        parser.exit(1, f"Lissom source projection: {error}\n")
    print(f"PASS Lissom source-only {lessons} lessons/{scenes} scenes/"
          f"{variants} variants/{held} semantic HOLD")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
