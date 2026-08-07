#!/usr/bin/env python3
"""TEK KOMUT, TAM CÜMLE (L-260) — JabLab J-145 aktarımı.

    Bir kapının yeşili, o kapının KAPSADIĞI kadar geçerlidir.
    İki süitli bir depoda "testler yeşil" cümlesi EKSİK bir cümledir.

JabLab koordinatöre kırk kez "N/N yeşil" yazdı; o app süitiydi ve motor süiti
J-104'ten beri kırmızıydı. Üç gerçek kusur oradaydı.

Bu depoda ÜÇ koşum var ve tek tek çağrılıyorlardı:
  ① app Dart süiti          ② paket Dart süitleri     ③ tools/ python kapıları

Bu betik üçünü de koşar ve **tek bir birleşik hüküm** basar. Kısmi bir sayı
raporlamak artık ekstra iş gerektiriyor; tam cümle varsayılan.

## Süitler ELLE YAZILMAZ — dosya sisteminden TÜRETİLİR

JabLab'ın en ince tespiti: *kusuru kapıya bağlarken, kusuru üreten TANIMI da
mühürlemişsin.* Elle yazılmış bir süit listesi, üçüncü paket eklendiği gün
sessizce eksik kalırdı — yani bu betiğin kendisi JabLab'ın kusurunu üretirdi.
`packages/*/pubspec.yaml` taranır: yeni paket kendiliğinden kapsama girer.

## Bu betiğin ÖLÇMEDİĞİ — isimle

- **Argüman isteyen python araçları** (9 adet): fixture/veri girdisi olmadan
  koşamazlar. Bunlar *kapı* değil *araç*; sayılmaları yanıltıcı olurdu.
- **`fixture_check.py`**: argümansız koşar ama KIRMIZI — paylaşımlı rig
  (`motion-core/lib/tools/fixture_pipeline`) kanonik `anatomical_mode()`
  taşımıyor (M-F-280: o ağaç 122 commit geride). **L-187 göçünü bloke eden
  ağacın aynısı.** Bu kırmızı ürünün değil, rig'in; bilinen ve isimli.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Argümansız koşamayan ARAÇLAR (kapı değil) + bilinen rig kırmızısı.
NOT_GATES = {
    "harvest_prescreen.py", "landmark_quality.py", "reclassify_pool.py",
    "targeted_search.py", "cut_presence_window.py", "identity_review.py",
    "l031_space_divergence.py", "two_mode_report.py", "vmr_baseline.py",
}
KNOWN_RED = {
    "fixture_check.py": "paylaşımlı rig anatomical_mode() taşımıyor (M-F-280)",
}


def _run(cmd: list[str], cwd: Path) -> tuple[bool, str]:
    p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    tail = (p.stdout + p.stderr).strip().splitlines()
    return p.returncode == 0, tail[-1][:90] if tail else ""


def main() -> int:
    lines: list[str] = []
    ok = True

    # ① + ② Dart süitleri — TÜRETİLİR, elle yazılmaz.
    suites = [("app", ROOT)] + [
        (p.parent.name, p.parent)
        for p in sorted(ROOT.glob("packages/*/pubspec.yaml"))
    ]
    if len(suites) < 2:
        print("VAKUM: paket süiti bulunamadı — bu betik hiçbir şey ölçmüyor")
        return 2
    for name, path in suites:
        good, tail = _run(["flutter", "test"], path)
        ok &= good
        lines.append(f"  {'✅' if good else '🔴'} dart:{name:<16} {tail}")

    # ③ python kapıları — argüman isteyenler AYRI sayılır, gizlenmez.
    gates = sorted(
        f for f in ROOT.glob("tools/*.py")
        if f.name not in NOT_GATES and f.name != Path(__file__).name
    )
    if not gates:
        print("VAKUM: python kapısı bulunamadı")
        return 2
    green, red = 0, []
    for g in gates:
        good, tail = _run([sys.executable, str(g)], ROOT)
        if good:
            green += 1
        elif g.name in KNOWN_RED:
            red.append(f"{g.name} (BİLİNEN: {KNOWN_RED[g.name]})")
        else:
            red.append(f"{g.name} — {tail}")
            ok = False
    lines.append(f"  {'✅' if not [r for r in red if 'BİLİNEN' not in r] else '🔴'}"
                 f" python{'':<12} {green}/{len(gates)} yeşil")
    for r in red:
        lines.append(f"       ↳ {r}")
    lines.append(f"       ↳ {len(NOT_GATES)} araç argüman ister — kapı DEĞİL, "
                 f"sayılmadı")

    print("═" * 62)
    print("TAM CÜMLE — üç koşumun HEPSİ (L-260)")
    print("═" * 62)
    print("\n".join(lines))
    print("═" * 62)
    print("HÜKÜM:", "TÜMÜ YEŞİL" if ok else "EKSİK VEYA KIRMIZI")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
