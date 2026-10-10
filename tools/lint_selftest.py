#!/usr/bin/env python3
"""Wellness süzgecinin kendisini sınar — CI kapısı.

Bulmayan bir denetim ile bozuk bir denetim dışarıdan aynı görünür: ikisi de
"ihlal yok" der. Bu betik bilinen ihlalleri süzgece verir ve yakalamasını bekler;
yakalamazsa denetim bozulmuş demektir ve CI kırılır.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

import wellness_lint

TOOLS = Path(__file__).resolve().parent
ROOT = TOOLS.parent

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
    "vaadin reddi (will not)": "We will not estimate a number we cannot measure.",
}


# Boundary counterexamples: safety language in the same field must never
# exempt an efficacy claim, a prescription, or an unqualified release date.
MUST_CATCH.update({
    "active creates outcome": "Lissom creates a symptom-free retest.",
    "passive delivered outcome": "A symptom-free retest is delivered by Lissom.",
    "passive promised outcome": "A symptom-free retest is promised by Lissom.",
    "cross-sentence will": "If symptom-free, rehearse once. Lissom will assess your technique.",
    "cross-semicolon will": "If symptom-free, rehearse once; Camera coaching will be available.",
    "cross-newline will": "If symptom-free, rehearse once.\nLissom will assess your technique.",
    "second outcome token": "If symptom-free, rehearse once with a symptom-free retest delivered by Lissom.",
    "symptom removal in safety vocabulary": "Lissom removes stop symptoms.",
    "symptom-free provision": "Lissom provides a symptom-free retest.",
    "symptom outcome": "Lissom reduces your symptoms.",
    "symptom-free promise": "Lissom guarantees a symptom-free retest.",
    "symptom-free advertising": "Enjoy a symptom-free future with Lissom.",
    "positive prescription": "Lissom prescribes a physical dose.",
    "negated medication prescription": "This is not a prescribed physical dose of insulin.",
    "release yet": "Camera coaching is not available yet.",
    "release will": "Lissom will assess your technique.",
    "warning plus diagnosis": "Stop for symptoms. Lissom diagnoses the cause.",
    "warning plus treatment": "Stop for symptoms; Lissom treats them.",
    "unsafe mixed negation": "No tissue change is promised; treatment is provided.",
})


MUST_PASS.update({
    "safety learning condition": "If symptom-free, rehearse once.",
    "named study condition": "When that study is run, the number will appear here.",
})


def _course_context_checks() -> tuple[int, list[str]]:
    """Read shipped fields, then challenge every one with appended claims.

    No copied course fixture, path exemption, or reviewed digest is added.
    This checks the same per-occurrence caller used by JSON, Dart and plist.
    """
    failures: list[str] = []
    count = 0
    attacks = (
        " A symptom-free retest is delivered by Lissom.",
        " A symptom-free retest is promised by Lissom.",
        " Lissom creates a symptom-free retest.",
        " Lissom will assess your technique.",
        " Camera coaching will be available.",
        " This cures pain.",
        " Lissom diagnoses the cause.",
        " Lissom treats your symptoms.",
        " Lissom reduces your symptoms.",
        " Lissom guarantees a symptom-free retest.",
        " Lissom prescribes a physical dose.",
        " Camera coaching is coming soon.",
        " Camera coaching is not available yet.",
    )
    fields = 0
    for name in ("chair-office.v1.json", "vinyasa-standing.v1.json", "yin-supported.v1.json"):
        course = json.loads((ROOT / "config/courses" / name).read_text(encoding="utf-8"))
        for field, text in wellness_lint._walk_json(course):
            fields += 1
            where = f"{name} :: {field}"
            count += 1
            if wellness_lint.scan_text(where, text):
                failures.append(f"COURSE CONTEXT FALSE ALARM: {where}")
            for attack in attacks:
                for separator in (".", ";", "\n"):
                    count += 1
                    if not wellness_lint.scan_text(where, text + separator + attack):
                        failures.append(f"COURSE CLAIM MISSED: {where}: {separator!r}: {attack}")
    if fields < 200:
        failures.append(f"COURSE CONTEXT READER EMPTY/INCOMPLETE: {fields} fields")
    return count, failures


# --------------------------------------------------------------------------
# TERS NEGATİF İKİZ (JabLab aktarımı)
# --------------------------------------------------------------------------
#: Şimdiye kadarki negatif ikizler *"düzeltme kaldırılırsa kırılır mı"* diye
#: soruyordu. **Ters ikiz, kapının kendisi FAZLA GENİŞLERSE kırılıyor.**
#:
#: Gerekçesi ölçülmüş: fazla geniş bir kapı bu depoda iki kez ödendi ve iki
#: kez de kapıyı geri daraltan şey bir ölçüm değil, İNSANIN FARK ETMESİYDİ —
#: `will not`u vaat sanması (L-246) ve `rose` deseninin `roseDeepHover`ı
#: eşlemesi (L-237). İkiz o refleksi mekanikleştiriyor.
#:
#: > **Her dar kapı, darlığını koruyan bir ikiz taşımalı.**
#:
#: ⚠️ **Cümleler KOPYALANMAZ, DEPODAN OKUNUR.** Kopyalanan bir cümle üründen
#: ayrışır ve ikiz artık var olmayan bir metni korur — bu dosyanın kendi
#: uyardığı ikiz-sınıfının ta kendisi olurdu.


def _live_sentences() -> dict[str, str]:
    """Fazla geniş bir kapının ÖLDÜRECEĞİ, üründe CANLI cümleler."""
    out: dict[str, str] = {}

    # ① Güvenlik notları — 21 egzersizde `pain` geçiyor. Biri bir gün
    #    "`pain` kelimesini tamamen yasaklayalım" derse, kullanıcının kendi
    #    sınırını anlatan dürüst uyarı ölür. Kapı çalışan bir dürüstlüğü
    #    kelimenin BİÇİMİ yüzünden kaybetmemeli.
    pool = json.loads(
        (ROOT / "config/content/exercise-pool.v1.json").read_text(encoding="utf-8"))
    notes = [e["safetyNote"] for e in pool["exercises"]
             if e.get("safetyNote") and "pain" in e["safetyNote"].lower()]
    if notes:
        out["güvenlik notu (pain)"] = notes[0]
        out["güvenlik notu (sharp pain)"] = notes[-1]

    # ② Ölçüm-sınırı beyanı — açık ihlal ⑱'in KAPANIŞI. İçinde koşullu bir
    #    `will` var; dar bir vaat kapısı bu cümleyi YANLIŞLIKLA yakalar ve
    #    ürünün en dürüst beyanını öldürür.
    surfaces = (ROOT / "lib/app/surfaces.dart").read_text(encoding="utf-8")
    for name in ("accuracyStatement", "limitsCopy"):
        m = re.search(rf"String {name} =\s*((?:\s*'(?:[^'\\]|\\.)*')+);", surfaces)
        if m:
            out[f"⑱ beyanı ({name})"] = "".join(
                re.findall(r"'((?:[^'\\]|\\.)*)'", m.group(1)))

    # ③ Canlı ölçüm-sınırı beyanı — kelime biçimi değişse de ürünün
    #    kamera ile nefes/meditasyon ölçmediğini söyleyen metin korunur.
    ia = json.loads((ROOT / "config/ia/library.v1.json").read_text(encoding="utf-8"))
    for item in ia["whyNotPage"]["items"]:
        if item["topic"] == "Breath or meditation measurement":
            out["kamera ölçümünün sınırı"] = item["reason"]
            break
    return out


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


def run_plist(usage_text: str) -> int:
    """OS katmanını DAVRANIŞLA sına (L-273).

    Dart tarafındaki kapı önce `wellness_lint.py` içinde
    `strings_from_plist` **kelimesini** arıyordu; fonksiyonu yeniden
    adlandırdığımda kapı **geçti**, çünkü çağrı yeri hâlâ o adı taşıyordu.
    *Kelimenin varlığı, çağrının çalıştığı değildir.* Burada linter gerçekten
    **koşturuluyor**.
    """
    with tempfile.TemporaryDirectory() as d:
        p = Path(d) / "Info.plist"
        p.write_text(
            '<?xml version="1.0"?><plist><dict>'
            "<key>NSCameraUsageDescription</key>"
            f"<string>{usage_text}</string>"
            "</dict></plist>",
            encoding="utf-8",
        )
        r = subprocess.run(
            [sys.executable, str(TOOLS / "wellness_lint.py"), "--path", str(p)],
            capture_output=True, text=True,
        )
        return r.returncode


def main() -> int:
    failures: list[str] = []

    # OS KATMANI — davranışsal (L-273).
    if run_plist("Coaching features are coming soon.") == 0:
        failures.append(
            "OS katmanı: izin metnindeki VAAT dili yakalanmadı — plist "
            "taraması ya kapalı ya bozuk"
        )
    if run_plist(
        "Lissom uses the camera to estimate how you move during a test."
    ) != 0:
        failures.append(
            "OS katmanı FAZLA GENİŞ: dürüst bir izin metni reddedildi"
        )

    for label, text in MUST_CATCH.items():
        code = run({"schemaVersion": 1, "id": "t", "tests": [{"instruction": text}]})
        if code == 0:
            failures.append(f"KAÇIRDI ({label}): {text}")

    for label, text in MUST_PASS.items():
        code = run({"schemaVersion": 1, "id": "t", "tests": [{"instruction": text}]})
        if code != 0:
            failures.append(f"YANLIŞ ALARM ({label}): {text}")

    # A reviewed warning is permitted only at its exact field with its exact
    # wording. A changed sentence or the same text in a different field must
    # pass through the ordinary medical-claim rules again.
    hatha = json.loads((ROOT / "config/courses/hatha.v1.json").read_text(encoding="utf-8"))
    reviewed_fields = ((4, 3, "adaptation"), (6, 5, "practice"),
                       (8, 0, "practice"), (8, 0, "selfCheck"),
                       (9, 1, "practice"))
    for module_index, lesson_index, field in reviewed_fields:
        where = (f"hatha.v1.json :: modules[{module_index}]."
                 f"lessons[{lesson_index}].{field}.en")
        text = hatha["modules"][module_index]["lessons"][lesson_index][field]["en"]
        if wellness_lint.scan_text(where, text):
            failures.append(f"İNCELEME KAYDI BAYAT: {where}")
        if not wellness_lint.scan_text(where, text + " This cures pain."):
            failures.append(f"DEĞİŞEN METİN KAÇTI: {where}")
        if not wellness_lint.scan_text(where + ".copy", text):
            failures.append(f"BAŞKA ALANA KOPYA KAÇTI: {where}")

    # The new Hatha schema must not pass by scanning zero translated fields.
    for field in ("objective", "steps", "selfCheck", "adaptation"):
        pair = {"en": "Clinically proven to cure your pain.", "tr": "Denetim örneği"}
        value = [pair] if field == "steps" else pair
        if run({"modules": [{"lessons": [{field: value}]}]}) == 0:
            failures.append(f"KAÇIRDI (iki dilli kurs): {field} alanı taranmıyor")
    if run({"title": {"en": "Choose a comfortable chair", "tr": "Rahat sandalye seç"}}) != 0:
        failures.append("YANLIŞ ALARM (iki dilli kurs): nötr yönerge reddedildi")

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

    # ---- TERS İKİZ: kapı fazla genişlerse bu cümleler ölür ----------------
    live = _live_sentences()
    if len(live) < 4:
        failures.append(
            f"TERS İKİZ BOŞ: depodan yalnız {len(live)} canlı cümle okunabildi "
            "— okuyucu bozulmuş, ikiz hiçbir şeyi korumuyor")
    for label, text in live.items():
        code = run({"schemaVersion": 1, "id": "t", "tests": [{"instruction": text}]})
        if code != 0:
            failures.append(
                f"KAPI FAZLA GENİŞ ({label}): üründe CANLI olan bu cümle "
                f"yakalandı — «{text[:70]}…»")

    course_count, course_failures = _course_context_checks()
    failures.extend(course_failures)

    total = course_count + len(MUST_CATCH) + len(MUST_PASS) + len(live) + 7 + 3 * len(reviewed_fields)
    print(f"Süzgeç öz-testi — {total} kontrol "
          f"({3 * len(reviewed_fields)} tam-metin/konum ikizi dahil)")
    if failures:
        print(f"\n❌ Süzgeç BOZUK — {len(failures)} vaka:")
        for f in failures:
            print(f"  {f}")
        return 1
    print("✅ Süzgeç bilinen ihlalleri yakalıyor, meşru metni geçiriyor.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
