#!/usr/bin/env python3
"""Project the reviewed v2k source contract into Lissom's closed QA asset."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


APP = Path(__file__).resolve().parents[1]
ROOT = Path(__file__).resolve().parents[4]
OPS = ROOT / "ops/tools/motion_courses/contracts/v2k"
OUTPUT = APP / "assets/motion_content/lissom_source_pins_v2k.json"
EXPECTED = {
    "proof": "dec615e14881b86b7676e1157f63b8bf6269026d856e59f2ee3a65d7f97e512a",
    "manifest": "d887683c9a9b9bdb8d4ab7c51cdc5a5b4b4de6a918079e4cfd9cf543e9751e60",
    "catalog": "791bfea8e1479307794bcf8799cf703a7a840bcd3058c1a0d7fdf065d32d8594",
    "chain": "6705f8af3f3de94d43d76de2c3352070dcab482f768a2aa040384da702e9cf3b",
    "course": "be597ebcb4d9a3ae05410e2b33752b061bdc4ad1aea49896ae978733b7405a3c",
}


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def read_exact(path: Path, expected: str) -> dict:
    require(path.is_file() and not path.is_symlink(), f"unreadable: {path}")
    data = path.read_bytes()
    require(digest(data) == expected, f"SHA drift: {path}")
    return json.loads(data)


def canonical(value: object) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()


def project() -> bytes:
    proof = read_exact(OPS / "source-proof/SOURCE-PROOF-READBACK.json", EXPECTED["proof"])
    manifest = read_exact(OPS / "production-manifest.json", EXPECTED["manifest"])
    catalog = read_exact(OPS / "source_pins_v1/source-pins.json", EXPECTED["catalog"])
    chain = read_exact(OPS / "contract-chain-readback.json", EXPECTED["chain"])
    course_path = APP / "config/courses/hatha.v1.json"
    require(course_path.is_file() and not course_path.is_symlink(), "live course unavailable")
    require(digest(course_path.read_bytes()) == EXPECTED["course"], "live course drift")
    require(chain["pins"]["manifest"]["sha256"] == EXPECTED["manifest"]
            and chain["pins"]["sourcePins"]["sha256"] == EXPECTED["catalog"]
            and chain["pins"]["proof"]["sha256"] == EXPECTED["proof"], "chain input mismatch")
    require(proof["liveLissomCourseSHA256"] == EXPECTED["course"]
            and manifest["courseSourcePins"]["lissom"]["sha256"] == EXPECTED["course"]
            and catalog["courseSourcePins"]["lissom"]["sha256"] == EXPECTED["course"], "course input mismatch")
    require(catalog["manifestSHA256"] == EXPECTED["manifest"]
            and catalog["sourceProofSHA256"] == EXPECTED["proof"], "catalog input mismatch")
    require(manifest["counts"]["lessons"] == 263
            and manifest["counts"]["scenes"] == 2020
            and manifest["counts"]["filenameStems"] == 2456, "portfolio count drift")
    require(catalog["counts"]["semanticHeldScenes"] == 8
            and catalog["counts"]["equipmentHeldScenes"] == 1
            and catalog["counts"]["lessonsWithAnyHold"] == 2, "portfolio HOLD drift")
    require(catalog["approvedProductionTrustRoot"] is False
            and catalog["visible"] is False
            and catalog["releaseEligible"] is False
            and catalog["progressEffect"] == 0
            and catalog["counts"]["generatedMedia"] == 0
            and catalog["counts"]["qualifiedMedia"] == 0, "QA release gate drift")

    lessons = [row for row in catalog["lessons"] if row["app"] == "lissom"]
    require(len(lessons) == 60 and len({row["lessonId"] for row in lessons}) == 60,
            "Lissom lesson count or identity drift")
    scene_ids: set[str] = set()
    stems: set[str] = set()
    semantic_holds = 0
    for lesson in lessons:
        require(lesson["courseSourceSHA256"] == EXPECTED["course"], "lesson course drift")
        held = lesson["lessonId"] == "h30"
        require(lesson["membershipStatus"] ==
                ("HOLD_SOURCE_SEMANTIC_P2" if held else "SOURCE_PINNED_TEST_ONLY"),
                "lesson membership drift")
        for scene in lesson["scenes"]:
            require(scene_ids.isdisjoint([scene["sceneId"]]), "duplicate scene")
            scene_ids.add(scene["sceneId"])
            semantic_holds += held
            require(scene["productionState"] == "PREPRODUCTION_UNGENERATED", "scene state drift")
            for variant in scene["variants"]:
                stem = variant["stem"]
                require(stem not in stems, "duplicate variant stem")
                stems.add(stem)
                identity = {
                    "manifestSHA256": EXPECTED["manifest"],
                    "app": "lissom",
                    "courseSourceSHA256": EXPECTED["course"],
                    "lessonId": lesson["lessonId"],
                    "lessonCanonicalSHA256": lesson["lessonCanonicalSHA256"],
                    "assetId": lesson["assetId"],
                    "sceneId": scene["sceneId"],
                    "variantStem": stem,
                    "productionSpecSHA256": scene["productionSpecSHA256"],
                    "sourceCueSHA256": scene["sourceCueSHA256"],
                    "idempotencyKey": scene["idempotencyKey"],
                    "productionState": scene["productionState"],
                }
                require(variant["sourcePinSHA256"] == digest(canonical(identity)),
                        "variant source pin drift")
    require((len(scene_ids), len(stems), semantic_holds) == (480, 480, 8),
            "Lissom scene, variant or HOLD count drift")
    require(any(hold["app"] == "lissom" and hold["lessonId"] == "h30"
                and hold["status"] == "HOLD_SOURCE_SEMANTIC_P2" for hold in catalog["holds"]),
            "h30 HOLD receipt missing")
    holds = [hold for hold in catalog["holds"] if hold["app"] == "lissom"]
    require(len(holds) == 1, "Lissom HOLD count drift")
    output = {
        "counts": {"generatedMedia": 0, "lessons": 60, "qualifiedMedia": 0,
                   "scenes": 480, "semanticHeldScenes": 8,
                   "semanticHeldVariants": 8, "variants": 480},
        "courseSourceSHA256": EXPECTED["course"],
        "holds": holds,
        "kind": "LISSOM_V2K_SOURCE_PINS_QA_ONLY",
        "lessons": lessons,
        "manifestSHA256": EXPECTED["manifest"],
        "progressEffect": 0,
        "releaseEligible": False,
        "schemaVersion": 1,
        "sourceCatalogSHA256": EXPECTED["catalog"],
        "sourceProofSHA256": EXPECTED["proof"],
        "visible": False,
    }
    return canonical(output) + b"\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--write", action="store_true")
    mode.add_argument("--check", action="store_true")
    args = parser.parse_args()
    expected = project()
    if args.write:
        require(not OUTPUT.exists(), "output already exists")
        OUTPUT.write_bytes(expected)
    else:
        require(OUTPUT.is_file() and OUTPUT.read_bytes() == expected, "projection drift")
    print(f"PASS Lissom v2k QA 60 lessons/480 scenes/480 variants {digest(expected)}")


if __name__ == "__main__":
    main()
