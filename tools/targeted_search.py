#!/usr/bin/env python3
"""Hedefli aday araması — ÖN-ELEME HASATTAN ÖNCE (Choreia probe_candidates deseni).

Neden bu sırayla: indirme + çıkarım pahalı; triyaj-uyumsuz bir adayı indirip
sonra reddetmek boşa iş. Metadata ucuz. Bu betik YALNIZ metadata okur
(indirme YOK) ve adayı üç ölçütle süzer:

  1. TRİYAJ-UYUMLULUK — süre ≥90s (triyaj kuralı) · dikey format DEĞİL.
     Bunlar zaten bilinen ret gerekçeleri (L-170: beş kaynağın beşi bu
     eksenlerden reddedilmişti); önce sormak, sonra indirmemek demek.
  2. BAĞIMSIZ EĞİTMEN — kütüphanede zaten olan kanal ATLANIR (M-F-32:
     sayım birimi EĞİTMEN, video değil).
  3. ELEYİCİ metin işaretleri — `harvest_prescreen` (yalnız eleyici;
     L-166: görüş metinden ÖNGÖRÜLEMEZ, o yüzden seçici değil).

⚠️ Bu betik "uygun" DEMEZ. Kamera görüşü ve duruş yalnız landmark'tan
ölçülür (L-162/L-166); metadata en fazla açıkça yanlış olanı düşürür.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from harvest_prescreen import SEARCH_TERMS, score_text  # noqa: E402

LIB = Path.home() / "motion-harvest/lissom"
MIN_DURATION_S = 90


def known() -> tuple[set[str], set[str]]:
    vids, channels = set(), set()
    for m in (LIB / "manifests").glob("*.json"):
        d = json.loads(m.read_text(encoding="utf-8"))
        vids.add(d.get("video_id") or m.stem)
        if d.get("channel"):
            channels.add(d["channel"].strip().lower())
    return vids, channels


def search(term: str, n: int) -> list[dict]:
    fmt = "%(id)s\t%(channel)s\t%(duration)s\t%(title)s"
    try:
        out = subprocess.run(
            ["yt-dlp", "--flat-playlist", "--print", fmt, f"ytsearch{n}:{term}"],
            capture_output=True, text=True, timeout=180)
    except (subprocess.TimeoutExpired, FileNotFoundError) as e:
        print(f"ARAMA BAŞARISIZ ({term}): {e}", file=sys.stderr)
        return []
    rows = []
    for line in out.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) < 4:
            continue
        vid, ch, dur, title = parts[0], parts[1], parts[2], "\t".join(parts[3:])
        rows.append({"vid": vid, "channel": ch, "duration": dur, "title": title})
    return rows


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--movement", required=True, choices=sorted(SEARCH_TERMS))
    ap.add_argument("--per-term", type=int, default=10)
    args = ap.parse_args()

    known_vids, known_channels = known()
    terms = SEARCH_TERMS[args.movement]["core"]

    seen: set[str] = set()
    kept: list[dict] = []
    dropped: dict[str, int] = {}

    def drop(reason: str) -> None:
        dropped[reason] = dropped.get(reason, 0) + 1

    for t in terms:
        for c in search(t, args.per_term):
            if c["vid"] in seen:
                continue
            seen.add(c["vid"])
            if c["vid"] in known_vids:
                drop("kütüphanede zaten var")
                continue
            if (c["channel"] or "").strip().lower() in known_channels:
                drop("kanal zaten kullanıldı (bağımsız eğitmen değil)")
                continue
            try:
                dur = float(c["duration"])
            except (TypeError, ValueError):
                drop("süre bilinmiyor")
                continue
            if dur < MIN_DURATION_S:
                drop(f"süre <{MIN_DURATION_S}s (triyaj reddi kesin)")
                continue
            sc = score_text(c["title"])
            if sc["eliminated"]:
                drop("metin eleyici: " + ", ".join(sc["eliminationReasons"][:2]))
                continue
            kept.append({**c, "durationS": dur, "foundBy": t})

    print(json.dumps({
        "movement": args.movement,
        "termsRun": len(terms),
        "uniqueSeen": len(seen),
        "kept": len(kept),
        "droppedByReason": dropped,
        "candidates": kept,
        "note": "ÖN-ELEME yalnız açıkça yanlışı düşürür; kamera görüşü ve "
                "duruş hükmü landmark ölçümündedir (identity_review.py).",
    }, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
