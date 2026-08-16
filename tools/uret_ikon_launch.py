#!/usr/bin/env python3
"""Lissom AppIcon + LaunchImage üretici — L-341 (2026-08-17)

GEREKÇE (YAYIN-YOLU-LISSOM.md §3.1-2, tuzak §6): aile ortak bir görsel
dilbilgisi paylaşıyor — düğüm(eklem)+kapsül(kemik) glifi, kendi marka
renginde dolgu üstünde beyaz (Gravita/Ostinato ikonlarında ÖLÇÜLDÜ, kopya
DEĞİL taşındı — biçim/poz kardeşlerden AYRI). Lissom'un kendi ürünü BİR
EKLEM AÇISI ölçüyor (attempt_values.jsonl, TestDetailScreen) — glif bunu
DOĞRUDAN temsil ediyor: iki kemik segmenti TEK bir eklemde (apex) birleşip
BİR AÇI oluşturuyor. Kardeşlerin poz/simetrisinden farklı: asimetrik apex,
kendi kompozisyonu — kopya değil.

Renk: LissomColors.roseDeep (#B0748F) — `ikon_ayirt_kapisi.py` aile
kapısından GEÇTİ (dört kardeşe karşı da ΔH/ΔL/ΔC'den biri ayırıyor, canlı
ölçüldü 2026-08-17). İkon: roseDeep dolgu + beyaz glif (Gravita/Ostinato
emsali: doygun marka rengi zemin). Launch image: TERSİ — Lissom'un kendi
teması AÇIK (Gravita'nın light-cream emsaliyle AYNI yön, kopyası değil):
canvas (#F3EDE9) zemin storyboard'da, roseDeep glif PNG'de (şeffaf zemin
üstünde) — ikon/launch glif AYNI poz, tutarlı kimlik.

4x supersample + LANCZOS downsample: PIL'in ham çizimi anti-alias'sız,
1024'te doğrudan çizilirse kenarlar tırtıklı çıkar.
"""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "ios/Runner/Assets.xcassets"

ROSE_DEEP = (0xB0, 0x74, 0x8F)
WHITE = (0xFF, 0xFF, 0xFF)
SS = 4  # supersample katsayısı

# Glif noktaları 1024 taban ızgarasında — apex eklem, iki kemik iki uç
# düğüme gidiyor. Asimetrik: sol-üst düğüm uzak/yüksek, sağ düğüm yakın/orta.
APEX = (460, 760)
LEFT = (280, 300)
RIGHT = (760, 460)
BONE_W = 78
APEX_R = 100
END_R = 85


def _capsule(draw, p1, p2, width, fill):
    width = round(width)
    draw.line([p1, p2], fill=fill, width=width)
    r = width / 2
    for p in (p1, p2):
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


def _draw_glyph(draw, scale, fill):
    """scale: '1024 taban birimi' -> hedef-piksel çarpanı (supersample DAHİL)."""
    def s(pt):
        return (pt[0] * scale, pt[1] * scale)

    apex, left, right = s(APEX), s(LEFT), s(RIGHT)
    bone_w, apex_r, end_r = BONE_W * scale, APEX_R * scale, END_R * scale
    _capsule(draw, apex, left, bone_w, fill)
    _capsule(draw, apex, right, bone_w, fill)
    for p, r in ((left, end_r), (right, end_r), (apex, apex_r)):
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


def make_icon_master() -> Image.Image:
    """1024x1024, ALPHA YOK (Apple ios-marketing kanalı şeffaflık kabul
    etmiyor) — roseDeep dolgu + beyaz glif."""
    big = Image.new("RGB", (1024 * SS, 1024 * SS), ROSE_DEEP)
    _draw_glyph(ImageDraw.Draw(big), SS, WHITE)
    return big.resize((1024, 1024), Image.LANCZOS)


def make_launch_glyph(point_size: int, scale: int) -> Image.Image:
    """Şeffaf zemin üstünde roseDeep glif, 1024-taban glifin point_size*scale
    kutusuna orantılı küçültülmüş hâli."""
    px = point_size * scale
    ratio = px / 1024
    big = Image.new("RGBA", (px * SS, px * SS), (0, 0, 0, 0))
    _draw_glyph(ImageDraw.Draw(big), ratio * SS, ROSE_DEEP)
    return big.resize((px, px), Image.LANCZOS)


ICON_SIZES = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def main():
    icon_dir = ASSETS / "AppIcon.appiconset"
    master = make_icon_master()
    for filename, px in ICON_SIZES.items():
        img = master if px == 1024 else master.resize((px, px), Image.LANCZOS)
        img.save(icon_dir / filename)
        print(f"  ikon {filename}: {px}x{px}")

    launch_dir = ASSETS / "LaunchImage.imageset"
    for filename, scale in (("LaunchImage.png", 1), ("LaunchImage@2x.png", 2),
                             ("LaunchImage@3x.png", 3)):
        img = make_launch_glyph(150, scale)
        img.save(launch_dir / filename)
        print(f"  launch {filename}: {150 * scale}x{150 * scale}")


if __name__ == "__main__":
    main()
