#!/usr/bin/env python3
"""Config dosyalarının geçerliliği ve sürüm beyanı — CI kapısı.

Sürümsüz bir config sessizce yorumlanır ve sürüm uyumsuzluğu fark edilmeden
davranış değiştirir. Yorumlayıcı bu durumda patlamalı, tahmin etmemeli.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "config"


def main() -> int:
    files = sorted(CONFIG.rglob("*.json"))
    if not files:
        print(f"⚠️  config/ altında JSON bulunamadı: {CONFIG}")
        return 2

    problems: list[str] = []
    for f in files:
        rel = f.relative_to(ROOT)
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            problems.append(f"{rel}: geçersiz JSON — satır {exc.lineno}: {exc.msg}")
            continue
        if not isinstance(data, dict):
            problems.append(f"{rel}: kök nesne olmalı")
            continue
        if "schemaVersion" not in data:
            problems.append(f"{rel}: `schemaVersion` beyan edilmemiş")
        if "id" not in data:
            problems.append(f"{rel}: `id` beyan edilmemiş")

    print(f"Config denetimi — {len(files)} dosya")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ Hepsi geçerli ve sürümlü.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
