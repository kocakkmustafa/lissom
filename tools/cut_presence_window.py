#!/usr/bin/env python3
"""Bir fixture'i presence_isolator penceresine kes — windowRule provenance'ı yaz.

Tek-seferlik: presence_isolator henüz motion-core main'e merge edilmedi,
bu yüzden worktree yolundan import ediyor. Merge sonrası bu bir Lissom
aracına (tools/cut_presence_window.py) dönüşmeli — bugünkü amaç ilk
referans denemesi için VERİ üretmek.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, "/Users/mustafakaankocak/motion-core-worktrees/presence-isolator/tools/harvest_rig")
import presence_isolator as pi  # noqa: E402

PRESENCE_ISOLATOR_SHA = "8c3c6e0"  # presence_isolator main merge'i


def cut(fixture_path: str, profile_path: str, movement: str, out_path: str) -> dict:
    spec = pi.presence_from_profile(profile_path, movement)
    triplets = pi._resolve_triplets(spec)

    doc = json.loads(Path(fixture_path).read_text(encoding="utf-8"))
    fps = doc.get("recordingMeta", {}).get("fps")
    frames_raw = [f.get("lm") if f.get("detected") is not False else None
                  for f in doc["frames"]]
    windows = pi.find_presence_windows(
        frames_raw, fps=float(fps), driver_triplets=triplets, op=spec["op"],
        threshold_deg=float(spec["thresholdDeg"]), min_hold_s=float(spec["minHoldS"]),
    )
    frames_before = len(doc["frames"])
    if not windows:
        return {"fixture": fixture_path, "cut": False, "reason": "pencere bulunamadı",
                "frames_before": frames_before}
    w = windows[0]  # en uzun tutuş (find_presence_windows zaten böyle sıralıyor)

    doc["frames"] = doc["frames"][w.start_frame:w.end_frame]
    prov = doc.setdefault("provenance", {})
    prov["windowRule"] = (
        f"presence_isolator@{PRESENCE_ISOLATOR_SHA} "
        f"driver={spec['proximal']}->{spec['joint']}->{spec['distal']} "
        f"op={spec['op']} thresholdDeg={spec['thresholdDeg']} minHoldS={spec['minHoldS']}"
    )
    prov["windowSourceFrames"] = [w.start_frame, w.end_frame]
    # ---- M-F-138: BAYAT-UYGUNLUK KORUMASI -------------------------------
    # Kesici, kaynağın provenance'ını olduğu gibi kopyalar — `referenceEligible`
    # ve `romMode` dahil. Bu bir SNAPSHOT'tır: kaynağın uygunluğu sonradan
    # değişirse (rom_mode sözlüğü genişledi, üçüncü boşluk kapandı) bu pencere
    # ESKİ değerle aşağı-akış kapısından geçer. JabLab'da gerçek vaka.
    #
    # Ortak yardımcı gelene dek (JabLab yazıyor) burada YAPTIĞIMIZ: snapshot'ı
    # SİLMİYORUZ (aşağı-akış onu bekliyor) ama TÜRETİLDİĞİ KAYNAĞI ve zamanı
    # isimle yazıyoruz, böylece tazelik SORULABİLİR hâle gelir. Sorulamayan
    # bir snapshot, bayat olduğunu asla söylemez.
    # M-F-138 UYGULAMASI (çekirdek 94b4ae9 ile aynı ilke): uygunluk KARAR
    # ANINDA KAYNAKTAN çözülür, fixture'ın snapshot'ından okunmaz.
    # ÖLÇÜLDÜ: `GaP20t6ZOfU.full.json` romMode hattından ÖNCE çıkarılmış, yani
    # provenance'ında `referenceEligible` alanı HİÇ YOK. Manifest c561204
    # rig'iyle `active`e döndü ama fixture bunu bilmiyordu; kanonik CLI onu
    # fail-closed `unattested` sayıp kapıda bıraktı — havuz gerçekte
    # olduğundan KÜÇÜK görünüyordu. Bayat YOKLUK, bayat VARLIK kadar zararlı.
    manifest = (Path.home() / "motion-harvest/lissom/manifests"
                / f"{Path(fixture_path).stem.replace('.full', '')}.json")
    resolved: dict = {}
    if manifest.exists():
        mm = json.loads(manifest.read_text(encoding="utf-8"))
        for src_key, dst_key in (("rom_mode", "romMode"),
                                 ("reference_eligible", "referenceEligible")):
            if mm.get(src_key) is not None:
                prov[dst_key] = mm[src_key]
                resolved[dst_key] = mm[src_key]
        resolved["fromManifest"] = manifest.name
        resolved["classifiedBy"] = mm.get("romModeClassifiedBy")

    prov["derivedFrom"] = {
        "eligibilityResolvedAtCut": resolved or "manifest yok — çözülemedi",
        "sourceFixture": str(Path(fixture_path).name),
        "sourceVideoId": Path(fixture_path).stem.replace(".full", ""),
        "eligibilitySnapshot": {
            "referenceEligible": prov.get("referenceEligible"),
            "romMode": prov.get("romMode"),
        },
        "snapshotWarning": (
            "M-F-138: bu alanlar KESİM ANINDA kopyalandı. Kaynağın manifesti "
            "sonradan değişmiş olabilir — tüketici tazeliği kaynaktan "
            "doğrulamalı, bu pencereye güvenmemeli."
        ),
    }
    prov["windowHoldSeconds"] = w.hold_seconds
    prov["windowPeakValue"] = w.peak_value
    prov["windowCoverage"] = w.coverage
    Path(out_path).write_text(json.dumps(doc, ensure_ascii=False), encoding="utf-8")
    return {
        "fixture": fixture_path, "cut": True, "out": out_path,
        "frames_before": frames_before,
        "frames_after": len(doc["frames"]), "hold_s": w.hold_seconds,
        "peak": w.peak_value, "coverage": w.coverage,
    }


if __name__ == "__main__":
    fixture, profile, movement, out = sys.argv[1:5]
    result = cut(fixture, profile, movement, out)
    print(json.dumps(result, ensure_ascii=False, indent=1))
