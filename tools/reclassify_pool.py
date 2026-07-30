#!/usr/bin/env python3
"""Havuzu güncel rig'le YENİDEN SINIFLANDIR — bayat/eksik uygunluğu tazeler.

Neden gerekli (M-F-137/M-F-138 ikizi): `rom_mode` sözlüğü büyüdükçe eski
manifestlerin uygunluğu ESKİ cevapla donmuş kalır. İki yönlü zarar:

  * bayat VARLIK — kaynak artık uygun DEĞİL ama manifest "uygun" diyor
    (M-F-138'in JabLab'da bulduğu yön);
  * bayat YOKLUK — kaynak artık uygun AMA manifestte alan hiç yok, ve
    aşağı-akış fail-closed olduğu için `unattested` sayıp DIŞLIYOR.
    Lissom'da ÖLÇÜLDÜ: `GaP20t6ZOfU` c561204 rig'iyle `active` çıkıyor,
    manifestinde `reference_eligible` alanı YOK, kanonik CLI onu
    `unattested` diye kapıda bırakıyordu — yani havuz gerçekte olduğundan
    KÜÇÜK görünüyordu.

Bu betik yalnız SINIFLANDIRMAYI tazeler: indirme YOK, çıkarım YOK (makine
çakışması yok, hasat sırası beklemez). Yazdığı her alanın yanına
`romModeClassifiedBy` (rig sha) + zaman damgası koyar ki bir dahaki
tazelemede "bu ne zaman, hangi sözlükle söylendi" SORULABİLİR olsun.

⚠️ Fixture provenance'ı AYRICA tazelenmelidir: manifest güncellenince
daha önce KESİLMİŞ pencereler hâlâ eski snapshot'ı taşır. `--recut-hint`
hangi fixture'ların yeniden kesilmesi gerektiğini listeler.

Kullanım:
    python3 tools/reclassify_pool.py --rig <worktree>/tools/harvest_rig --dry-run
    python3 tools/reclassify_pool.py --rig <...> --sha c561204 --write
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

LIB = Path.home() / "motion-harvest/lissom"
MANIFESTS = LIB / "manifests"

#: ⚠️ İKİ transkript deposu var ve NEREDEYSE AYRIK (ölçüldü: `subs/` 27 kimlik
#: `.en.vtt`, `transcripts/` 20 kimlik `.transcript.json`, kesişim 1). İki
#: farklı çekim mekanizması iki farklı yere yazmış.
#:
#: Bu betik ilk yazımında YALNIZ `subs/`u okuyordu (L-184). Sonuç: 19 videonun
#: metni hiç görülmedi ve sınıflandırma `unknown`a fail-closed oldu —
#: gerekçesine "TRANSKRİPT YOK" yazarak. **11 manifestte o gerekçe FİİLEN
#: YANLIŞTI**: transkript dosyası duruyordu, betik yanlış klasöre bakıyordu.
#: Fail-closed olmak doğruydu; YANLIŞ BİR ÖNCÜLLE fail-closed olmak değil —
#: ve kayda geçen sahte gerekçe, hatayı arayan bir sonraki kişiyi de
#: yanıltıyordu.
TRANSCRIPT_DIRS = (LIB / "subs", LIB / "transcripts")


def _transcript(vid: str) -> str:
    """Bir videonun metni — TÜM depolardan birleşik.

    JSON transkriptler zaman-damgalı segment listesi; regex aileleri düz metin
    beklediği için `json.dumps` yeterli (alan adları kalıp eşleşmesini
    bozmuyor, ölçüldü). VTT'ler zaten düz metin.
    """
    out: list[str] = []
    for d in TRANSCRIPT_DIRS:
        if not d.exists():
            continue
        for p in d.glob(f"{vid}*"):
            try:
                out.append(p.read_text(errors="ignore"))
            except OSError:
                pass
    return "\n".join(out)


def _transcript_files(vid: str) -> list[Path]:
    """Bu kimliğe ait metin dosyaları — "yok" demeden ÖNCE sorulur."""
    return [p for d in TRANSCRIPT_DIRS if d.exists() for p in d.glob(f"{vid}*")]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rig", required=True, help="harvest_rig dizini (pinli worktree)")
    ap.add_argument("--sha", default="unknown", help="rig commit sha (kayda geçer)")
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    sys.path.insert(0, args.rig)
    import rom_mode  # noqa: PLC0415

    changed: list[dict] = []
    recut: list[str] = []
    #: YANLIŞ ÖNCÜLLE fail-closed olan manifestler (L-184 panzehiri): gerekçe
    #: "transkript yok" derken dosya duruyorsa, bu bir okuma hatasıdır ve
    #: SESSİZ kalmamalı. Kapı, kendi öncülünü sorguluyor.
    false_premise: list[str] = []
    now = datetime.now(timezone.utc).isoformat(timespec="seconds")

    for p in sorted(MANIFESTS.glob("*.json")):
        m = json.loads(p.read_text(encoding="utf-8"))
        vid = m.get("video_id") or p.stem
        text = _transcript(vid)
        files = _transcript_files(vid)
        if files and not text.strip():
            false_premise.append(
                f"{vid}: {len(files)} metin dosyası VAR ama okunan metin BOŞ "
                f"({', '.join(f.name for f in files[:3])})"
            )
        old_reason = (m.get("romModeClassifiedBy") or {}).get("reason", "")
        if files and ("TRANSKRİPT YOK" in old_reason or
                      "TRANSKRIPT YOK" in old_reason):
            false_premise.append(
                f"{vid}: ESKİ gerekçe 'TRANSKRİPT YOK' diyor ama dosya VAR "
                f"({files[0].parent.name}/) — yanlış öncülle fail-closed"
            )
        v = rom_mode.classify(
            title=m.get("title", ""),
            description=m.get("description", ""),
            transcript=text,
        )
        old_mode = m.get("rom_mode")
        old_elig = m.get("reference_eligible")
        # Uygunluk = rig'in kendi kuralı: passive referansa GİREMEZ.
        # `unknown` için karar hareket-sınıfına bağlı (M-F-45
        # passiveExecutionPossible) — bu betik o politikayı ÜSTLENMEZ,
        # yalnız modu tazeler ve eligible'ı yalnız ACTIVE için True yazar.
        new_elig = True if v.mode == "active" else (
            False if v.mode == "passive" else old_elig)
        if old_mode == v.mode and old_elig == new_elig:
            continue
        changed.append({
            "vid": vid, "channel": m.get("channel"),
            "mode": f"{old_mode} -> {v.mode}",
            "eligible": f"{old_elig} -> {new_elig}",
            "reason": v.reason[:90],
        })
        if (LIB / "landmarks" / f"{vid}.full.json").exists():
            recut.append(vid)
        if args.write:
            m["rom_mode"] = v.mode
            if new_elig is not None:
                m["reference_eligible"] = new_elig
            m["romModeClassifiedBy"] = {"rigSha": args.sha, "at": now,
                                        "reason": v.reason}
            p.write_text(json.dumps(m, ensure_ascii=False, indent=2) + "\n",
                         encoding="utf-8")

    print(json.dumps({
        "manifests": len(list(MANIFESTS.glob("*.json"))),
        "transcriptStores": {d.name: len(list(d.glob("*"))) if d.exists() else 0
                             for d in TRANSCRIPT_DIRS},
        "falsePremise": false_premise,
        "changed": len(changed),
        "written": args.write,
        "rigSha": args.sha,
        "changes": changed,
        "recutNeeded": recut,
        "recutNote": "bu fixture'ların KESİLMİŞ pencereleri eski uygunluk "
                     "snapshot'ını taşıyor — yeniden kesilmeli (M-F-138)",
    }, ensure_ascii=False, indent=1))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
