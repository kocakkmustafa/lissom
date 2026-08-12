#!/usr/bin/env python3
"""Placeholder kaydı üreteci — koddaki `PLACEHOLDER(...)` işaretlerinden.

Neden üretilir, elle yazılmaz: elle tutulan bir liste bayatlar — biri bir
işareti silip listeyi güncellemeyi unutursa kayıt sessizce yalan söyler.
Bu script tek doğruluk kaynağı olan KODU tarar; `docs/design/
PLACEHOLDER-REGISTER.md` onun türevidir.

İşaret biçimi (Dart yorumu):
    // PLACEHOLDER(<kategori>): <ne eksik> — unblocked by: <ne bekliyor>

Kategoriler: asset · copy · data · flow

**KAPI, sadece liste değil** (aile standardı, Choreia emsali 2026-08-06):
`PLACEHOLDER(` yazılmış ama `unblocked by` ya da geçerli kategori taşımayan
bir işaret SESSİZCE atlanmaz — script `exit 1` ile PATLAR. Gevşek regex'in
sıkı regex'i eşleştirmemesi, "yakalanmadı" ile "yok" arasındaki farkı
sessizce yutan tam olarak L-183 sınıfı — biri "unblocked by:" yazmayı
unutursa kayıt biri eksik değil, KAPI KIRMIZI yanar.

Çalıştırma:
    python3 tools/gen_placeholder_register.py
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "design" / "PLACEHOLDER-REGISTER.md"

LOOSE = re.compile(r"PLACEHOLDER\(")
#: ⚠️ `binding` AYRI bir grup — ve bu, ölçülmüş bir tuzağın panzehiri.
#: Ostinato'nun aynı kapısı ilk hâlinde KÖRDÜ: deseninin `(.+?)`si
#: işaretçinin geri kalanını YUTUYORDU, yani *"anahtar sevk edilen kodda
#: var mı"* sorusu HİÇ SORULMUYORDU — kapı koşuyor, soru sorulmuyor.
#: Burada `unblocked` non-greedy ve bağ **son segment** olarak ayrı
#: yakalanıyor; `validate_placeholder_surface.py` bunu ADIYLA sınıyor.
STRICT = re.compile(
    r"PLACEHOLDER\((?P<category>asset|copy|data|flow)\):\s*"
    r"(?P<what>[^—]+?)\s*—\s*unblocked by:\s*(?P<unblocked>.+?)"
    r"(?:\s*—\s*(?P<binding>(?:user-surface|source-only):\s*.+?))?\s*$"
)

SCAN_DIRS = ("lib", "packages")


def find_markers() -> tuple[list[tuple[str, int, str, str, str]], list[tuple[str, int, str]]]:
    """Dönüş: (geçerli işaretler, BOZUK işaretler). Bozuk liste boş değilse
    çağıran taraf KAPIYI KIRMIZI yakmalı — üretilen dosyaya yazmak yetmez."""
    valid: list[tuple[str, int, str, str, str]] = []
    malformed: list[tuple[str, int, str]] = []
    for scan_dir in SCAN_DIRS:
        base = ROOT / scan_dir
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*.dart")):
            try:
                lines = path.read_text(encoding="utf-8").splitlines()
            except (UnicodeDecodeError, OSError):
                continue
            rel = str(path.relative_to(ROOT))
            for i, line in enumerate(lines, 1):
                if not LOOSE.search(line):
                    continue
                m = STRICT.search(line)
                if m:
                    valid.append((
                        rel, i,
                        m.group("category"),
                        m.group("what").strip(),
                        m.group("unblocked").strip(),
                        (m.group("binding") or "").strip(),
                    ))
                else:
                    malformed.append((rel, i, line.strip()))
    return valid, malformed


def render(markers: list[tuple[str, int, str, str, str, str]]) -> str:
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

    by_category: dict[str, list[tuple[str, int, str, str, str]]] = {}
    for rel, ln, cat, what, unblocked, binding in markers:
        by_category.setdefault(cat, []).append(
            (rel, ln, what, unblocked, binding))

    for cat in ("asset", "copy", "data", "flow"):
        items = by_category.get(cat, [])
        if not items:
            continue
        lines.append(f"## {cat} ({len(items)})")
        lines.append("")
        for rel, ln, what, unblocked, binding in items:
            lines.append(f"- `{rel}:{ln}` — {what}")
            lines.append(f"  - unblocked by: {unblocked}")
            lines.append(f"  - {binding or '⛔ BAĞ YOK'}")
        lines.append("")
    return "\n".join(lines) + "\n"


def main() -> int:
    valid, malformed = find_markers()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(render(valid), encoding="utf-8")
    print(f"{len(valid)} geçerli placeholder işareti bulundu → {OUT.relative_to(ROOT)}")

    if malformed:
        print(f"\n❌ {len(malformed)} BOZUK placeholder işareti — kayda GİRMEDİ:")
        for rel, ln, raw in malformed:
            print(f"    {rel}:{ln}: {raw}")
        print(
            "\n    Biçim: // PLACEHOLDER(asset|copy|data|flow): <ne eksik> — "
            "unblocked by: <ne bekliyor>"
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
