#!/usr/bin/env python3
"""Hasat ÖN-ELEMESİ — L-162'nin ölçülmüş uygunluk ölçütlerini arama tarafına taşır.

Neden: L-162 iki BAĞIMSIZ eksende ölçtü ki kaynaklar aynı şeyi göstermiyor —
DURUŞ (`trunk_lean`) ve KAMERA GÖRÜŞÜ (`shoulder_line_foreshortening`).
İkisi birlikte uygulandığında 6 kaynağın 1'i, 4 kaynağın 1'i geçti; minSources=3
yapısal olarak sağlanamadı. Ölçüt HASATTAN SONRA uygulanınca iş çoktan
yapılmış olur (indirme + çıkarım). Bu betik ölçütü ARAMA/ÖN-ELEME tarafına
taşır: hangi terimler doğru malzemeyi getirir, hangi metin işaretleri yanlış
malzemeyi ÖNCEDEN eler.

⚠️⚠️ **ÖLÇÜLDÜ: METİN ÖN-ELEMESİ KAMERA GÖRÜŞÜNÜ ÖNGÖREMEZ — L-166.**
Bu betiğin ilk sürümü "görüş" eksenini metinden skorluyordu. L-162'nin
hüküm verdiği 6 gerçek kaynakta sınandı ve ÇÖKTÜ: **6 kaynağın 0'ı** metninde
kamera görüşünden söz ediyor (`side view`/`front view`/`sagittal` — hiçbiri,
438-4916 karakterlik açıklamalarda). Dahası filtre, L-162'nin İKİ ÖLÇÜTÜ DE
GEÇEN TEK kaynağını (`X2u_vGL0qJU`) "ELE" diye işaretledi ve duruş-kusurlu
iki kaynağı "denemeye değer" saydı — yani kullanılabilir tek kaynağı ÇÖPE
ATACAKTI.

Sonuç, tasarıma işlendi:
  * **Görüş ekseni metinden SKORLANMAZ** (sinyal yok — sıfır-sinyalli bir
    eksene skor vermek, ölçmediğim bir şeyi iddia etmek olurdu). Görüş
    yalnız landmark'tan ÖLÇÜLÜR (`identity_review.py` · M-F-49/L-116).
  * **Arama TERİMLERİ yine değerli, ama farklı bir mekanizmayla:** terim,
    aynı adayları süzmez — HANGİ adayların geldiğini değiştirir. Kendini
    "side view" diye tanıtan videoyu arama getirir; getirmediğini metin
    filtresi kurtaramaz.
  * **Yalnız NEGATİF işaretler metinde sinyal taşıyor** (yer/pasif/format
    ifadeleri gerçekten yazılıyor) — bu yüzden betik artık yalnız ELEYİCİ
    olarak konuşur, seçici olarak DEĞİL.

Gerçek hüküm hâlâ landmark ölçümüdür. L-142'nin dersi burada bir kez daha
ölçüldü: ön-filtre hasattan DAHA ZAYIF olabilir — ve bu kez ölçüm onu
"zayıf" değil, o eksende YOK gösterdi.

⚠️ M-F-138 (bayat-uygunluk) DAYANIKLILIĞI: bu betik uygunluk KARARI
SAKLAMAZ. Yalnız o anki metinden bir skor türetir ve skoru çağıran tarafa
verir. Kalıcı bir `eligible: true` yazmadığı için, rom_mode sözlüğü
değiştiğinde (M-F-139 notu: üçüncü boşluk JabLab'da) bayat bir karar
taşımaz — yeniden koşulur, yeni cevabı verir.

Kullanım:
    python3 tools/harvest_prescreen.py --terms overhead_reach
    python3 tools/harvest_prescreen.py --score '{"title": "...", "description": "..."}'
"""

from __future__ import annotations

import argparse
import json
import re
import sys

# --------------------------------------------------------------------------
# ARAMA TERİMLERİ — L-162'nin iki eksenini arama diline çevirir.
# --------------------------------------------------------------------------
#: Her testin ihtiyacı olan KAMERA GÖRÜŞÜ ve VÜCUT KONUMU, terim olarak.
#: Kaynak: `config/tests/lissom-assessment.v1.json` talimat metinleri
#: (ölçülen: 6 test "stand side-on", 3 "stand facing", 1 oturarak, 2 yerde)
#: + L-162'nin ölçtüğü başarısızlık deseni (kaynaklar önden çekilmiş).
SEARCH_TERMS: dict[str, dict[str, list[str]]] = {
    "overhead_reach": {
        "core": [
            "shoulder flexion range of motion test side view",
            "overhead reach assessment side profile",
            "shoulder mobility test standing side view",
            "arm raise overhead range of motion self test",
        ],
        # L-162'nin iki kusurunu ADRESLEYEN terimler.
        "view": ["side view", "side profile", "lateral view", "sagittal"],
        "posture": ["standing", "upright"],
    },
    "deep_squat": {
        "core": [
            "deep squat assessment side view",
            "bodyweight squat depth test side profile",
            "squat mobility screen standing side view",
        ],
        "view": ["side view", "side profile", "lateral view"],
        "posture": ["standing", "full body"],
    },
}

# --------------------------------------------------------------------------
# METİN İŞARETLERİ — ön-eleme skoru
# --------------------------------------------------------------------------
#: BİLGİLENDİRİCİ işaretler — SKOR ÜRETMEZ (L-166).
#:
#: Bunlar raporda görünür ama hükme katılmaz. Sebep ölçüm: 6 gerçek kaynağın
#: 0'ı görüş ifadesi taşıyordu, 1'i duruş ifadesi taşıyordu. Sıfıra yakın
#: sinyalli bir eksenden skor üretmek, filtreye sahte bir seçicilik verir —
#: ve ölçüldü ki o sahte seçicilik kullanılabilir TEK kaynağı eliyordu.
INFORMATIONAL = {
    "view": [
        r"\bside[- ]view\b", r"\bside[- ]profile\b", r"\bfrom the side\b",
        r"\blateral view\b", r"\bsagittal\b", r"\bprofile view\b",
    ],
    "posture": [
        r"\bstanding\b", r"\bstand (?:up|tall|upright)\b", r"\bupright\b",
        r"\bfull[- ]body\b",
    ],
    "solo": [
        r"\bself[- ](?:test|assess\w*|screen)\b", r"\bat home\b",
        r"\bhow to (?:test|check) your own\b",
    ],
}

#: NEGATİF: L-162'nin ölçtüğü yanlış malzemeyi haber veren ifadeler.
#: Her biri GEREKÇELİ — "sezgiyle eklenmiş" terim yok.
NEGATIVE = {
    # L-162 eksen 1: yatay gövde (Fraser Wilson 79°, Strength Side 76°).
    "floor_or_bent": [
        (r"\b(?:on (?:the|your) )?(?:floor|mat|ground)\b", "yer malzemesi"),
        (r"\bquadruped\b|\ball fours\b|\bfour[- ]point\b", "dört ayak duruşu"),
        (r"\bthread the needle\b|\bchild'?s pose\b|\bdownward dog\b",
         "yoga yer pozu"),
        (r"\bl[iy]ing\b|\bsupine\b|\bprone\b", "yatar konum"),
        (r"\bbent over\b|\bhinged?\b(?! test)", "öne eğilmiş gövde"),
    ],
    # L-162 eksen 2: önden çekim (foreshortening 0,5-0,6 = ~41-51° yaw).
    "wrong_view": [
        (r"\bfront view\b|\bfacing the camera\b|\bfrontal\b", "önden çekim"),
        (r"\bmirror\b", "ayna — kamera açısı belirsiz"),
    ],
    # M-F-43 ailesi: pasif/dirençli icra + klinisyen-üretimli aralık.
    "passive": [
        (r"\bpassive\b", "pasif ROM"),
        (r"\btherapist\b|\bclinician\b|\bexaminer\b", "klinisyen icrası"),
        (r"\bmanual resistance\b|\bresisted\b", "dirençli icra"),
        (r"\bI(?:'ll| will) (?:move|lift|take) your\b", "başkası hareket ettiriyor"),
    ],
    # Ölçüme uygun olmayan format.
    "format": [
        (r"\bslow motion\b", "yavaş çekim — zaman ekseni bozulur"),
        (r"\bcompilation\b|\btop \d+\b", "derleme"),
        (r"\banimation\b|\b3d model\b", "animasyon, gerçek insan değil"),
    ],
}

#: Çoklu-kişi işaretleri — **BAYRAK, ELEYİCİ DEĞİL** (kasıtlı).
#:
#: Tek-kişi malzemesi isteriz (izleme belirsizliği: hangi iskelet?), ama bir
#: grup dersi videosu İÇİNDE tek-kişi gösterim segmenti bulunabilir ve
#: `presence_isolator` onu kesebilir. Elemek, kurtarılabilir malzemeyi
#: atmak olurdu; bayrak, insan gözünün önceliğini düşürür. Bu ayrım
#: `eliminated` hükmüne KATILMAZ ve testle sabitlenmiştir.
MULTI_PERSON = [
    (r"\bpartner\b|\bwith a friend\b", "iki kişi"),
    (r"\bclass\b|\bgroup\b", "grup dersi"),
]


def score_text(title: str, description: str = "", subtitles: str = "") -> dict:
    """Metinden ön-eleme skoru — KARAR DEĞİL, öncelik sırası.

    L-142 dersi gömülü: hangi alanların okunduğu SONUCU DEĞİŞTİRİR
    (arama ön-filtresi başlık+altyazı bakıp `active` demişti, hasat
    başlık+AÇIKLAMA ile `passive` buldu). Bu yüzden okunan alanlar
    çıktıda İSİMLE raporlanır — hangi kanıtla konuştuğu görünür kalsın.
    """
    fields = {"title": title, "description": description, "subtitles": subtitles}
    read = [k for k, v in fields.items() if v]
    blob = " ".join(v.lower() for v in fields.values() if v)

    # Bilgilendirici işaretler: raporlanır, HÜKME KATILMAZ (L-166).
    seen: dict[str, list[str]] = {}
    for kind, pats in INFORMATIONAL.items():
        found = [p for p in pats if re.search(p, blob)]
        if found:
            seen[kind] = found

    blocks: list[dict[str, str]] = []
    for kind, pats in NEGATIVE.items():
        for pat, why in pats:
            if re.search(pat, blob):
                blocks.append({"kind": kind, "reason": why, "pattern": pat})
    multi = [{"reason": why, "pattern": p} for p, why in MULTI_PERSON
             if re.search(p, blob)]

    # SADECE ELEYİCİ. Pozitif skor YOK (L-166: ölçüldü, sinyal yok).
    # "Engel yoksa geçer" — yani filtre adayı SEÇMEZ, yalnız açıkça
    # yanlış olanı DÜŞÜRÜR. Bu, kullanılabilir tek kaynağı elemekten
    # kaçınmanın tek dürüst yolu.
    return {
        "fieldsRead": read,
        "informationalSignals": seen,
        "blockers": blocks,
        "multiPerson": multi,
        # Tek hüküm: açık bir eleme gerekçesi var mı?
        "eliminated": bool(blocks),
        "eliminationReasons": [b["reason"] for b in blocks],
        "note": "YALNIZ ELEYİCİ — aday SEÇMEZ. Kamera görüşü metinden "
                "öngörülemez (L-166: 6/6 kaynakta sinyal yok); görüş ve duruş "
                "hükmü landmark ölçümündedir (identity_review.py).",
    }


def terms_for(movement: str) -> dict:
    spec = SEARCH_TERMS.get(movement)
    if spec is None:
        raise SystemExit(
            f"terim seti yok: {movement} (tanımlı: {', '.join(SEARCH_TERMS)})")
    # Çapraz çarpım DEĞİL: çekirdek terimler zaten görüş ifadesini taşıyor.
    # Ek olarak görüş+duruş terimleri birleştirilmiş varyantlar üretilir.
    combos = [f"{c}" for c in spec["core"]]
    combos += [f"{spec['core'][0]} {v}" for v in spec["view"][:2]]
    return {
        "movement": movement,
        "queries": combos,
        "requireInText": {"view": spec["view"], "posture": spec["posture"]},
        "rationale": "L-162: duruş (trunk_lean) + kamera görüşü "
                     "(foreshortening) iki BAĞIMSIZ eksende eledi; terimler "
                     "bu iki ekseni arama tarafına taşır",
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--terms", help="hareket adı için arama terimleri üret")
    ap.add_argument("--score", help="JSON {title, description, subtitles}")
    args = ap.parse_args()

    if args.terms:
        print(json.dumps(terms_for(args.terms), ensure_ascii=False, indent=1))
        return 0
    if args.score:
        payload = json.loads(args.score)
        print(json.dumps(
            score_text(payload.get("title", ""), payload.get("description", ""),
                       payload.get("subtitles", "")),
            ensure_ascii=False, indent=1))
        return 0
    ap.print_help()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
