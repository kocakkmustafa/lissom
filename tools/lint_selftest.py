#!/usr/bin/env python3
"""Wellness süzgecinin kendisini sınar — CI kapısı.

Bulmayan bir denetim ile bozuk bir denetim dışarıdan aynı görünür: ikisi de
"ihlal yok" der. Bu betik bilinen ihlalleri süzgece verir ve yakalamasını bekler;
yakalamazsa denetim bozulmuş demektir ve CI kırılır.
"""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
from pathlib import Path

TOOLS = Path(__file__).resolve().parent

#: Yakalanması ZORUNLU örnekler — her biri gerçek bir red gerekçesi.
MUST_CATCH = {
    "hastalık adı": "This test diagnoses your shoulder impingement syndrome.",
    "tedavi iddiası": "Clinically proven to cure your back pain permanently.",
    "klinik eşik": "Your ROM is below the clinical threshold of 90 degrees.",
    "doktor ikamesi": "This can replace physical therapy for most people.",
}

#: YakalanmaMAsı gereken örnekler — meşru olumsuzlamalar.
MUST_PASS = {
    "olumsuzlama": "Lissom is not a medical device and does not diagnose any condition.",
    "nötr yönerge": "Raise your arm slowly overhead and hold for two seconds.",
}


def run(payload: dict) -> int:
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "case.json"
        p.write_text(json.dumps(payload), encoding="utf-8")
        r = subprocess.run(
            [sys.executable, str(TOOLS / "wellness_lint.py"), "--path", str(p)],
            capture_output=True, text=True,
        )
        return r.returncode


def run_in_content_dir(payload: dict) -> int:
    """İçerik dizini gibi görünen bir yolda koştur — sessiz-tarama korumasını sınar."""
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "config" / "content" / "case.json"
        p.parent.mkdir(parents=True)
        p.write_text(json.dumps(payload), encoding="utf-8")
        r = subprocess.run(
            [sys.executable, str(TOOLS / "wellness_lint.py"), "--path", str(p)],
            capture_output=True, text=True,
        )
        return r.returncode


def main() -> int:
    failures: list[str] = []

    for label, text in MUST_CATCH.items():
        code = run({"schemaVersion": 1, "id": "t", "tests": [{"instruction": text}]})
        if code == 0:
            failures.append(f"KAÇIRDI ({label}): {text}")

    for label, text in MUST_PASS.items():
        code = run({"schemaVersion": 1, "id": "t", "tests": [{"instruction": text}]})
        if code != 0:
            failures.append(f"YANLIŞ ALARM ({label}): {text}")

    # İçerik şemasının alanları taranıyor mu? (egzersiz havuzu alan adları)
    code = run({"schemaVersion": 1, "id": "t",
                "exercises": [{"safetyNote": "Stop if this treats your sciatica."}]})
    if code == 0:
        failures.append("KAÇIRDI (içerik şeması): safetyNote alanı taranmıyor")

    # Regresyon: tanınmayan alan adlarıyla dolu bir içerik dosyası SESSİZCE
    # geçmemeli. Egzersiz havuzu ilk yazıldığında tam bu oldu — 72 hareketlik
    # dosyadan 0 metin çıkarıldı ve süzgeç yeşil yandı.
    code = run_in_content_dir({"schemaVersion": 1, "id": "t",
                               "exercises": [{"someUnknownField": "text nobody scans"}]})
    if code == 0:
        failures.append(
            "SESSİZ GEÇİŞ: içerik dosyasından hiç metin çıkmadığı hâlde süzgeç geçti")

    total = len(MUST_CATCH) + len(MUST_PASS) + 2
    print(f"Süzgeç öz-testi — {total} vaka "
          f"({len(MUST_CATCH)+1} yakalanmalı, {len(MUST_PASS)} geçmeli, 1 sessiz-tarama)")
    if failures:
        print(f"\n❌ Süzgeç BOZUK — {len(failures)} vaka:")
        for f in failures:
            print(f"  {f}")
        return 1
    print("✅ Süzgeç bilinen ihlalleri yakalıyor, meşru metni geçiriyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
