#!/usr/bin/env python3
"""Her testin triyajda ŞART KOŞACAĞI landmark kümesini metrik config'inden türetir.

Neden türetiliyor, elle yazılmıyor: elle yazılan kapsam listeleri bayatlar ve
bayat liste sessizce yanlış sonuç verir. Bu gece iki kez gerçekleşti — A9
sonda listesi metrik seti büyüyünce geride kaldı, ve triyaj sondası ayak
bileğini SABİT şart koştuğu için `overhead_reach` (bir OMUZ testi) adaylarının
8'de 7'si "alt vücut kadraj dışı" gerekçesiyle reddedildi (L-080).

Kural: bir test, YALNIZCA kendi metriklerinin dokunduğu landmark'ların kadrajda
olmasını şart koşar. Metriğe yeni bir nokta eklenirse küme kendiliğinden büyür.

Çıktı, triyaj profiline `perMovement` olarak yazılır ve `config_check.py`
türetilen ile yazılanın aynı olduğunu doğrular — böylece profil bayatlayamaz.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
METRICS = ROOT / "config/metrics/lissom-metrics.v1.json"
PROFILE = ROOT / "config/harvest/triage-profile.v1.json"
BATTERY = ROOT / "config/tests/lissom-assessment.v1.json"

#: BlazePose 33-nokta indeksleri (MediaPipe Pose Landmarker sözlüğü).
BLAZEPOSE = (
    "NOSE", "LEFT_EYE_INNER", "LEFT_EYE", "LEFT_EYE_OUTER", "RIGHT_EYE_INNER",
    "RIGHT_EYE", "RIGHT_EYE_OUTER", "LEFT_EAR", "RIGHT_EAR", "MOUTH_LEFT",
    "MOUTH_RIGHT", "LEFT_SHOULDER", "RIGHT_SHOULDER", "LEFT_ELBOW",
    "RIGHT_ELBOW", "LEFT_WRIST", "RIGHT_WRIST", "LEFT_PINKY", "RIGHT_PINKY",
    "LEFT_INDEX", "RIGHT_INDEX", "LEFT_THUMB", "RIGHT_THUMB", "LEFT_HIP",
    "RIGHT_HIP", "LEFT_KNEE", "RIGHT_KNEE", "LEFT_ANKLE", "RIGHT_ANKLE",
    "LEFT_HEEL", "RIGHT_HEEL", "LEFT_FOOT_INDEX", "RIGHT_FOOT_INDEX",
)
INDEX = {n: i for i, n in enumerate(BLAZEPOSE)}

#: Türev (sanal) landmark'lar gerçek noktalardan hesaplanır — ikisini de ister.
VIRTUAL = {
    "MID_HIP": ("LEFT_HIP", "RIGHT_HIP"),
    "MID_SHOULDER": ("LEFT_SHOULDER", "RIGHT_SHOULDER"),
    "MID_KNEE": ("LEFT_KNEE", "RIGHT_KNEE"),
    "MID_ANKLE": ("LEFT_ANKLE", "RIGHT_ANKLE"),
}

#: Üst-gövde sondası zaten burun+omuzları kontrol ediyor; onları tekrar
#: şart koşmak red gerekçesini bulanıklaştırır.
ALREADY_PROBED = {"NOSE", "LEFT_SHOULDER", "RIGHT_SHOULDER"}


def _expand(name: str) -> set[str]:
    """Sanal landmark'ı bileşenlerine, gerçeği kendine açar."""
    if name in VIRTUAL:
        return set(VIRTUAL[name])
    return {name}


def _metric_points(m: dict) -> set[str]:
    """Bir metriğin dokunduğu gerçek landmark adları (sanallar açılmış)."""
    names: set[str] = set()
    for key in ("points", "landmarks"):
        for n in m.get(key, []) or []:
            names |= _expand(str(n))
    for key in ("from", "to", "a", "b", "p"):
        if key in m:
            names |= _expand(str(m[key]))
    return names


def _mirror(name: str) -> str:
    if name.startswith("RIGHT_"):
        return name.replace("RIGHT_", "LEFT_", 1)
    if name.startswith("LEFT_"):
        return name.replace("LEFT_", "RIGHT_", 1)
    return name


def derive(metrics_doc: dict, battery_doc: dict) -> dict[str, list[int]]:
    """testId → triyajda görünür olması ŞART landmark indeksleri (sıralı).

    Otorite BATARYADIR, metrikteki `test` geri-işareti değil: bir metrik birden
    çok testte kullanılabilir ve geri-işaret yalnız ilkini gösterir. İlk sürüm
    bu yüzden 12 testin 9'unu üretmişti — `overhead_squat`,
    `single_leg_balance` ve `active_straight_leg_raise` sessizce dışarıda
    kalmıştı (paylaşılan metrik kullanıyorlar).
    """
    by_id = {m["id"]: m for m in metrics_doc["metrics"]}
    # Ayna metrikler config'te tek tanımla durur; karşı taraf türetilir.
    for m in list(metrics_doc["metrics"]):
        if m.get("mirror"):
            for suf, other in (("_right", "_left"), ("_left", "_right")):
                if m["id"].endswith(suf):
                    mid = m["id"][: -len(suf)] + other
                    by_id.setdefault(mid, {
                        **m, "id": mid,
                        "points": [_mirror(str(n)) for n in m.get("points", [])],
                        **{k: _mirror(str(m[k])) for k in ("from", "to", "a", "b", "p")
                           if k in m},
                    })

    out: dict[str, list[int]] = {}
    for test in battery_doc["tests"]:
        refs: list[str] = []
        for key in ("primaryMetric", "metrics", "guardMetrics"):
            v = test.get(key)
            if isinstance(v, str):
                refs.append(v)
            elif isinstance(v, list):
                refs.extend(str(x) for x in v)
        # `invalidation` kuralları da büyüklük adı taşır ve bir testin en kritik
        # adları YALNIZ burada geçebilir: `footTouchdown` guard listesinde yok,
        # oysa ayak inişi single_leg_balance denemesini bitiren şeyin ta kendisi.
        # Bu blok taranmazken beyan bağlanmamış kalıyordu.
        for rule in test.get("invalidation", []) or []:
            refs.extend(
                tok for tok in re.findall(r"[A-Za-z_][\w{}]*", str(rule.get("rule", "")))
                if tok not in ("and", "or", "not", "confidence")
            )
        names: set[str] = set()
        declared = battery_doc.get("derivedMeasures", {})
        for ref in refs:
            if ref in declared:
                # Geometrik değil ama kadraj İSTEYEBİLİR: `footTouchdown`
                # ayağı görmeden ayak inişini saptayamaz. Beyan zorunlu.
                d = declared[ref]
                if "requiredLandmarks" not in d:
                    raise KeyError(
                        f"{ref}: derivedMeasures kaydı `requiredLandmarks` "
                        "beyan etmeli (boş liste = kadraj istemiyor)"
                    )
                for n in d["requiredLandmarks"]:
                    names |= _expand(str(n))
                continue
            # perSide test tek tanımdan iki kez örneklenir; klip iki taraf için
            # de kullanılabilsin diye ikisi de kadrajda aranır. `{opposite}`
            # karşı tarafı gösterir (ASLR: kaldırılan bacak {side}, yerde
            # kalması gereken {opposite}).
            two_sided = "{side}" in ref or "{opposite}" in ref
            for side in ("right", "left") if two_sided else (None,):
                mid = ref
                if side:
                    other = "left" if side == "right" else "right"
                    mid = mid.replace("{side}", side).replace("{opposite}", other)
                m = by_id.get(mid)
                if m is None:
                    raise KeyError(
                        f"{test['id']}: bataryanın istediği metrik config'te yok — {mid}"
                    )
                names |= _metric_points(m)
        names -= ALREADY_PROBED
        missing = sorted(n for n in names if n not in INDEX)
        if missing:
            raise KeyError(f"{test['id']}: BlazePose sözlüğünde olmayan landmark {missing}")
        out[test["id"]] = sorted(INDEX[n] for n in names)
    return out


def main() -> int:
    metrics = json.loads(METRICS.read_text(encoding="utf-8"))
    battery = json.loads(BATTERY.read_text(encoding="utf-8"))
    derived = derive(metrics, battery)
    write = "--write" in sys.argv

    profile = json.loads(PROFILE.read_text(encoding="utf-8"))
    current = profile.get("perMovement")

    # M-F-45 politikası da TÜRETİLİR: batarya beyanı tek kaynak, profil onun
    # kopyası. Elle yazılsaydı ikisi ayrışır ve hasat yanlış politikayla koşardı.
    policy = {}
    for t in battery["tests"]:
        if "passiveExecutionPossible" not in t:
            raise KeyError(
                f"{t['id']}: `passiveExecutionPossible` beyan edilmemiş — "
                "M-F-45 varsayıma izin vermiyor (varsayılan sessizce "
                "fail-closed'u ya da tersini uygular)"
            )
        policy[t["id"]] = bool(t["passiveExecutionPossible"])

    # M-F-60/63: hareket-kimliği sözlüğü de bataryadan TÜRETİLİR. Profile elle
    # yazılsaydı ikisi ayrışır ve app kapısı bayat sinyal tüketirdi.
    identity = {t["id"]: t["identity"] for t in battery["tests"] if "identity" in t}

    # Beklenen yapı TEK yerde kurulur ve hem yazma hem kontrol onu kullanır.
    # İlk sürümde yazma sözlük üretiyor, kontrol liste bekliyordu; kontrol
    # kendi yazdığı dosyayı "bayat" sanıyordu. Doğrulayıcı ile ürettiği yapı
    # ayrışırsa kapı ölçmek istediği şeyi ölçmez.
    expected = {
        mv: ({"lower_body_ids": ids, "identity": identity[mv]}
             if mv in identity else ids)
        for mv, ids in derived.items()
    }

    if write:
        profile["perMovement"] = expected
        profile["movementRomPolicy"] = policy
        profile.setdefault("_notes", []).append(
            "perMovement TÜRETİLMİŞTİR (tools/triage_landmarks.py) — elle "
            "düzenlenmez. Her test yalnız kendi metriklerinin dokunduğu "
            "landmark'ların kadrajda olmasını şart koşar; sabit 'tam gövde' "
            "şartı bir OMUZ testinin adaylarını ayak bileği görünmüyor diye "
            "reddediyordu (L-080)."
        )
        PROFILE.write_text(
            json.dumps(profile, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
        print(f"✅ perMovement yazıldı — {len(expected)} test")
        return 0

    if profile.get("movementRomPolicy") != policy:
        print("❌ triyaj profilindeki romMode politikası BAYAT (batarya ile uyuşmuyor).")
        print("  Düzeltme:  python3 tools/triage_landmarks.py --write")
        return 1
    if current != expected:
        print("❌ triyaj profili BAYAT — metrik config'iyle uyuşmuyor.")
        for t in sorted(set(expected) | set(current or {})):
            if (current or {}).get(t) != expected.get(t):
                print(f"  {t}: profil={(current or {}).get(t)} türetilen={expected.get(t)}")
        print("\n  Düzeltme:  python3 tools/triage_landmarks.py --write")
        return 1
    print(f"✅ triyaj profili metrik config'iyle tutarlı — {len(derived)} test")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
