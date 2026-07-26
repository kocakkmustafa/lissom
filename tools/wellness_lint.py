#!/usr/bin/env python3
"""Wellness dil süzgeci — kullanıcıya görünen İngilizce metinlerin CI denetimi.

Neden: Lissom bir wellness ürünü. Tek bir aşırı ifade ("diagnoses", "treats
your pain", "clinically proven") ürünü tıbbi cihaz sınırına iter — FDA General
Wellness politikası ve Apple 1.4.1 buna bakar. Bu risk kod incelemesiyle değil,
otomatik taramayla yönetilir; insan gözü er geç bir satırı kaçırır.

Kaynak liste: docs/research/09-wellness-dil-suzgeci.md §4
Bağımlılık YOK — saf stdlib, herhangi bir python3 ile koşar.

Çalıştırma:
    python3 tools/wellness_lint.py            # config/ altındaki tüm metinleri tara
    python3 tools/wellness_lint.py --path X   # belirli bir dosya/klasör
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# --------------------------------------------------------------------------
# Yasaklı kalıplar
# --------------------------------------------------------------------------
# HARD: hiçbir bağlamda kabul edilemez — hastalık adı, regülatif iddia, tedavi
HARD = [
    r"\bcure[sd]?\b",
    r"\bprescrib\w*", r"\bprescription\b",
    r"\bFDA[- ](cleared|approved)\b",
    r"\bmedical[- ]grade\b",
    r"\bclinically (proven|validated)\b",
    r"\bimpingement\b", r"\brotator cuff tear\b", r"\bosteoarthritis\b",
    r"\bscoliosis\b", r"\bherniat\w*", r"\bdegenerat\w*",
    r"\bpathology\b", r"\bsyndrome\b", r"\bdisorder\b",
    r"\breplace[s]? (your )?(doctor|physical therapy|physiotherapy)\b",
    r"\bguaranteed\b", r"\bpermanently fix\b",
    r"\bblood (pressure|oxygen|glucose)\b", r"\bx-?ray\b",
    r"\bclinical threshold\b", r"\bdiagnostic threshold\b",
]

# SOFT: olumsuzlama içinde meşru olabilir ("does not diagnose", "not a medical
# device"). Olumsuzlanmamışsa ihlaldir.
SOFT = [
    r"\bdiagnos\w*",
    r"\btreat(s|ed|ment|ments)?\b",
    r"\bdisease\b",
    r"\bsymptom[s]?\b",
    r"\bmedical device\b",
]

#: SOFT kalıbın hemen öncesinde bunlardan biri varsa olumsuzlama sayılır.
#:
#: BİLİNEN SINIRLILIK (negatif testte ölçüldü): pencere 4 kelime. Olumsuzlama
#: ile yasaklı kelime arasına 5+ kelime girerse ihlal sanılır — ör. "We cannot
#: diagnose what is causing your symptoms" cümlesinde "symptoms" işaretlenir.
#: Pencereyi genişletmek gerçek ihlalleri kaçırma riskini büyütür, o yüzden
#: muhafazakâr bırakıldı: yanlış alarmı insan eler, kaçan ihlali kimse elemez.
NEGATION = re.compile(
    r"(not|never|cannot|can't|does not|doesn't|do not|don't|no|without|"
    r"isn't|is not|aren't|are not|nor|neither)\W+(\w+\W+){0,4}$",
    re.IGNORECASE,
)

#: Denetimden MUAF dosyalar — disclaimer metinleri, yasaklı kelimeyi
#: olumsuzlama içinde kullanmak zorundadır.
EXEMPT_FILES = {"disclaimers.en.json"}

#: JSON içinde kullanıcıya GÖRÜNEN alanlar. Diğer alanlar (açıklama, kaynak,
#: not) iç dokümandır ve taranmaz — yoksa her literatür atıfı false-positive olur.
USER_FACING_KEYS = {
    "instruction", "message", "text", "label", "title", "name",
    "criteria", "hint", "cta", "body",
}


def _walk_json(node: object, path: str = "") -> list[tuple[str, str]]:
    """JSON ağacından yalnız kullanıcıya görünen string alanları topla."""
    out: list[tuple[str, str]] = []
    if isinstance(node, dict):
        for k, v in node.items():
            child = f"{path}.{k}" if path else k
            if isinstance(v, str):
                if k in USER_FACING_KEYS:
                    out.append((child, v))
            else:
                out.extend(_walk_json(v, child))
    elif isinstance(node, list):
        for i, v in enumerate(node):
            child = f"{path}[{i}]"
            if isinstance(v, str):
                # Serbest string dizileri (levels gibi) kullanıcıya görünebilir.
                if path.rsplit(".", 1)[-1] in USER_FACING_KEYS | {"levels"}:
                    out.append((child, v))
            else:
                out.extend(_walk_json(v, child))
    return out


def _is_negated(text: str, start: int) -> bool:
    return bool(NEGATION.search(text[:start]))


def scan_text(where: str, text: str) -> list[str]:
    problems: list[str] = []
    for pat in HARD:
        for m in re.finditer(pat, text, re.IGNORECASE):
            problems.append(f"{where}: HARD  «{m.group(0)}»  — {text[:90]}…")
    for pat in SOFT:
        for m in re.finditer(pat, text, re.IGNORECASE):
            if not _is_negated(text, m.start()):
                problems.append(
                    f"{where}: SOFT  «{m.group(0)}» olumsuzlanmamış  — {text[:90]}…"
                )
    return problems


def scan_file(path: Path) -> list[str]:
    if path.name in EXEMPT_FILES:
        return []
    problems: list[str] = []
    if path.suffix == ".json":
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            return [f"{path.name}: JSON okunamadı — {exc}"]
        for key, value in _walk_json(data):
            problems += scan_text(f"{path.name} :: {key}", value)
    elif path.suffix in {".arb", ".md"}:
        for i, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            problems += scan_text(f"{path.name}:{i}", line)
    return problems


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--path", default=str(ROOT / "config"))
    args = ap.parse_args()

    target = Path(args.path)
    files = (
        sorted(p for p in target.rglob("*") if p.suffix in {".json", ".arb"})
        if target.is_dir()
        else [target]
    )

    all_problems: list[str] = []
    for f in files:
        all_problems += scan_file(f)

    print(f"Wellness dil süzgeci — {len(files)} dosya tarandı")
    print(f"Muaf: {', '.join(sorted(EXEMPT_FILES))}\n")

    # Hiç dosya taranmadıysa "temiz" DEME. Bulmayan bir denetim ile bozuk bir
    # denetim dışarıdan aynı görünür; CI'da yeşil yanan boş tarama, koruma
    # olduğu sanılan bir boşluktur (L-011 dersinin denetim tarafındaki hâli).
    if not files:
        print(f"⚠️  Taranacak dosya bulunamadı: {target}")
        print(f"    Beklenen uzantılar: .json · .arb")
        print("    Bu bir GEÇİŞ DEĞİL — yol yanlış olabilir.")
        return 2

    if not all_problems:
        print("✅ İhlal yok.")
        return 0

    print(f"❌ {len(all_problems)} olası ihlal:\n")
    for p in all_problems:
        print(f"  {p}")
    print(
        "\nGüvenli yeniden yazımlar: config/copy/disclaimers.en.json → safeAlternatives"
        "\nBağlamsal false-positive ise: USER_FACING_KEYS / EXEMPT_FILES gözden geçir."
    )
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
