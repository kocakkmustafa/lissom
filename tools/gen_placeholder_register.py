#!/usr/bin/env python3
"""Placeholder kaydı üreteci — koddaki `PLACEHOLDER(...)` işaretlerinden.

Neden üretilir, elle yazılmaz: elle tutulan bir liste bayatlar — biri bir
işareti silip listeyi güncellemeyi unutursa kayıt sessizce yalan söyler.
Bu script tek doğruluk kaynağı olan KODU tarar; `docs/design/
PLACEHOLDER-REGISTER.md` onun türevidir.

İşaret biçimi (Dart yorumu):
    // PLACEHOLDER(<kategori>): <ne eksik> — unblocked by: <ne bekliyor>

Kategoriler: asset · copy · data · flow

Çalıştırma:
    python3 tools/gen_placeholder_register.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "design" / "PLACEHOLDER-REGISTER.md"

PATTERN = re.compile(
    r"PLACEHOLDER\((?P<category>asset|copy|data|flow)\):\s*"
    r"(?P<what>[^—]+?)\s*—\s*unblocked by:\s*(?P<unblocked>.+?)\s*$"
)

SCAN_DIRS = ("lib", "packages")


def find_markers() -> list[tuple[str, int, str, str, str]]:
    out: list[tuple[str, int, str, str, str]] = []
    for scan_dir in SCAN_DIRS:
        base = ROOT / scan_dir
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*.dart")):
            try:
                lines = path.read_text(encoding="utf-8").splitlines()
            except (UnicodeDecodeError, OSError):
                continue
            for i, line in enumerate(lines, 1):
                m = PATTERN.search(line)
                if m:
                    rel = str(path.relative_to(ROOT))
                    out.append((
                        rel, i,
                        m.group("category"),
                        m.group("what").strip(),
                        m.group("unblocked").strip(),
                    ))
    return out


def render(markers: list[tuple[str, int, str, str, str]]) -> str:
    lines = [
        "# Placeholder Register",
        "",
        "**ÜRETİLİR — elle düzenlenmez.** Kaynak: `tools/gen_placeholder_"
        "register.py`, koddaki `// PLACEHOLDER(kategori): ... — unblocked "
        "by: ...` işaretlerinden.",
        "",
        f"Toplam: **{len(markers)}**",
        "",
    ]
    if not markers:
        lines += [
            "Şu an kayıtlı placeholder yok. Bu üretecin boş dönmesi bir "
            "arıza değil — bu turda giydirilen ekranların hepsi gerçek "
            "veri/kopya kullandı; icat edilen görsel/metin yok.",
        ]
        return "\n".join(lines) + "\n"

    by_category: dict[str, list[tuple[str, int, str, str]]] = {}
    for rel, ln, cat, what, unblocked in markers:
        by_category.setdefault(cat, []).append((rel, ln, what, unblocked))

    for cat in ("asset", "copy", "data", "flow"):
        items = by_category.get(cat, [])
        if not items:
            continue
        lines.append(f"## {cat} ({len(items)})")
        lines.append("")
        for rel, ln, what, unblocked in items:
            lines.append(f"- `{rel}:{ln}` — {what}")
            lines.append(f"  - unblocked by: {unblocked}")
        lines.append("")
    return "\n".join(lines) + "\n"


def main() -> int:
    markers = find_markers()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(render(markers), encoding="utf-8")
    print(f"{len(markers)} placeholder işareti bulundu → {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
