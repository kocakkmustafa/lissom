#!/usr/bin/env python3
""""CİHAZDA KALIR / YÜKLENMEZ" İDDİA KAPISI — Ostinato O-080 aktarımı (A3).

    Doğru bir iddianın korunmaması, gelecekteki bir yalandır.

Ölçüm (`docs/A1-A5-AILE-DENETIMI-2026-08-11.md`, A3 + koordinatörün 2.
sevkindeki O-080 reçetesi): `lib/app/profile_screen.dart`/`progress_screen
.dart`/`home_screen.dart` en az 6 yüzeyde "stay on this phone"/"on this
device"/"no account and no server" diyor; `pubspec.yaml` `google_fonts`
taşıyor (L-222); bu iddiaları koruyan HİÇBİR kapı yoktu.

## Üç kanal (koordinatörün reçetesi, ①②③)

① **kod izi** — sevk edilen `lib/` kaynağı bir yükleyici çağrısı
   (`http.post`, `Dio(`, `WebSocket`, `.upload(`…) taşıyor mu? İddia da
   varsa bu bir ÇELİŞKİ — kapı öter.
② **bağımlılık kaydı** — pubspec'teki ağa-çıkabilen HER bağımlılık
   `NETWORK_DEPS_RECORDED`da adıyla VE gerekçesiyle. Kayıt bir MUAFİYET
   DEĞİL, bir KARAR NOKTASIdır — "ağa çıkan = kötü" YANLIŞ kural olurdu
   (O-057: gürültüye boğulur, susturulur); `google_fonts` bir GET yapar,
   kullanıcı verisi taşımaz, iddiayı YALANLAMAZ.
③ **vakum koruması** — iddia HİÇBİR yüzeyde bulunamıyorsa bu da KIRMIZI:
   ya bilerek kaldırıldı (kapı da emekli edilmeli) ya tarama kırık.
   Sessiz "geçti" hiçbir zaman doğru değildir.

## Ostinato'dan AYNEN alınan vs. Lissom için TÜRETİLEN (koordinatörün ②
şartı: "biçimi al, sabitleri kopyalama")

- `NETWORK_DEP_HINTS` (paket-ailesi izleri) — AYNEN, projeye özgü değil.
- `UPLOADER_TRACES` (yükleyici API izleri) — AYNEN, Dart/Flutter'ın kendi
  stack'i, projeye özgü değil.
- `NETWORK_DEPS_RECORDED` — Ostinato'nunki KOPYALANMADI, Lissom'un kendi
  `google_fonts` gerekçesiyle SIFIRDAN yazıldı.
- `UPLOAD_CLAIM` — **kopyalanmadı, TÜRETİLDİ.** Ostinato'nunki "never
  leaves"/"nothing is uploaded" arar; Lissom'un GERÇEK sevk edilen metni
  bunların HİÇBİRİNİ kullanmıyor ("stay on this phone", "no account and
  no server", "nowhere for your data to go") — Ostinato'nun regex'i
  körlemesine kopyalansaydı Lissom'da SIFIR eşleşme verir, kapı VAKUM-
  DOĞRU olurdu (③'ün tam yakalaması gereken hâl).
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# ── ② bağımlılık kaydı ──────────────────────────────────────────────────
NETWORK_DEPS_RECORDED = {
    "google_fonts": "yazı tipi indirir (GET); kullanıcı verisi TAŞIMAZ — "
                     "gizlilik iddialarını yalanlamaz, ama L-222 açık "
                     "(çevrimdışı açılışta tipografi kaybı + üçüncü sunucu "
                     "bağlantısı — lisans/bağımlılık kararı koordinatörde)",
    # Aile bulgusu (Gravita, 2026-08-12): beş hattın da pubspec.lock'unda
    # http vardı, hiçbirinin yaml'ında yok — Ostinato'nun kapısı (ve bu
    # kapının ilk sürümü) yalnız yaml taradığı için görmüyordu. Ölçüldü:
    # `http` TRANSITIVE (`google_fonts`'un kendi runtime-fetch yolunun
    # istemcisi) — L-222 ile AYNI kök, yeni bir kanal değil.
    "http": "TRANSITIVE (google_fonts'un runtime yazı tipi GET'i için "
            "istemci) — pubspec.yaml'da doğrudan YOK, yalnız .lock'ta. "
            "L-222 ile aynı kök: kullanıcı verisi taşımaz.",
    "http_parser": "TRANSITIVE, `http` paketinin kendi bağımlılığı — "
                    "yalnız HTTP mesaj biçimini PARSE eder (pub.dev "
                    "açıklaması: \"parsing and serializing HTTP formats\"), "
                    "kendi başına ağa ÇIKMAZ. Kayıt ADIYLA, riski YOK "
                    "diye SESSİZCE elenmedi.",
}

NETWORK_DEP_HINTS = re.compile(
    r"^\s+(http\w*|dio\w*|firebase\w*|sentry\w*|posthog\w*|amplitude\w*|"
    r"mixpanel\w*|segment\w*|appsflyer\w*|adjust\w*|google_fonts|"
    r"supabase\w*|graphql\w*|web_socket\w*):",
    re.MULTILINE)

# ── ① kod izi ────────────────────────────────────────────────────────────
#: Kullanıcı verisini DIŞARI taşıyan kod yolları. Ostinato'dan AYNEN —
#: Dart/Flutter'ın kendi ağ API'leri, projeye özgü değil.
UPLOADER_TRACES = re.compile(
    r"\bhttp\.post\b|\bhttp\.put\b|\bDio\(|\bHttpClient\(|\bWebSocket\b|"
    r"MultipartRequest|\.upload\(")

# ── ③ vakum koruması ─────────────────────────────────────────────────────
#: Lissom'un GERÇEK sevk edilen cümlelerinden TÜRETİLDİ (grep, kopya değil):
#: "stay on this phone" (profile_screen.dart ×2) · "no account and no
#: server ... nowhere for your data to go" (profile_screen.dart) · "on
#: this device" (home_screen.dart ×4, progress_screen.dart ×1) · "never
#: leaves this device" (onboarding_flow.dart, kamera-kabuğu sevki
#: 2026-08-12 — O3'ün gerçek izin metni).
UPLOAD_CLAIM = re.compile(
    r"stays?\s+on\s+this\s+(?:phone|device)|"
    r"never\s+leaves\s+this\s+(?:phone|device)|"
    r"no\s+account\s+and\s+no\s+server|"
    r"nowhere\s+for\s+your\s+data\s+to\s+go|"
    r"on\s+this\s+(?:phone|device)",
    re.IGNORECASE)


def _pubspec_problems(pubspec_text: str) -> list[str]:
    problems: list[str] = []
    for m in NETWORK_DEP_HINTS.finditer(pubspec_text):
        dep = m.group(1)
        if dep not in NETWORK_DEPS_RECORDED:
            problems.append(
                f"kayıtsız ağ-bağımlılığı: `{dep}` — pubspec.yaml'da bulundu "
                f"ama `NETWORK_DEPS_RECORDED`a GEREKÇESİYLE yazılmamış. "
                f"Bu bir hata DEĞİL — bir KARAR NOKTASI: bağımlılık "
                f"kullanıcı verisi taşıyabilir mi? Taşımıyorsa gerekçeyle "
                f"kaydet, taşıyorsa gizlilik iddialarını gözden geçir."
            )
    return problems


def _claim_sites(lib_root: Path) -> list[tuple[Path, int, str]]:
    """`UPLOAD_CLAIM` eşleşen her (dosya, satır, metin) — TÜRETİLİR."""
    sites: list[tuple[Path, int, str]] = []
    for f in sorted(lib_root.rglob("*.dart")):
        text = f.read_text(encoding="utf-8")
        for i, line in enumerate(text.splitlines(), start=1):
            if UPLOAD_CLAIM.search(line):
                sites.append((f, i, line.strip()))
    return sites


def _uploader_sites(lib_root: Path) -> list[tuple[Path, int, str]]:
    sites: list[tuple[Path, int, str]] = []
    for f in sorted(lib_root.rglob("*.dart")):
        text = f.read_text(encoding="utf-8")
        for i, line in enumerate(text.splitlines(), start=1):
            if UPLOADER_TRACES.search(line):
                sites.append((f, i, line.strip()))
    return sites


def main() -> int:
    pubspec = ROOT / "pubspec.yaml"
    lock = ROOT / "pubspec.lock"
    lib_root = ROOT / "lib"
    problems: list[str] = []

    # ② bağımlılık kaydı — YALNIZ yaml TARAMAK YETMEZ (Gravita bulgusu,
    # 2026-08-12): transitive bağımlılıklar (`http`) yaml'da hiç görünmez,
    # yalnız .lock'ta yaşar. İkisi de taranır — biri diğerini İKAME ETMEZ.
    problems += _pubspec_problems(pubspec.read_text())
    if lock.exists():
        problems += _pubspec_problems(lock.read_text())
    problems = sorted(set(problems))  # yaml+lock aynı paketi iki kez bulabilir

    # ① kod izi — iddia VARKEN yükleyici izi de varsa çelişki
    claims = _claim_sites(lib_root)
    uploaders = _uploader_sites(lib_root)
    if claims and uploaders:
        problems.append(
            f"ÇELİŞKİ: {len(claims)} yüzey cihazda-kalır iddiası taşıyor "
            f"AMA kaynakta {len(uploaders)} yükleyici izi bulundu: " +
            "; ".join(f"{f.relative_to(ROOT)}:{i}" for f, i, _ in uploaders[:3])
        )

    # ③ vakum koruması — iddia HİÇ bulunamıyorsa bu da kırmızı
    if not claims:
        problems.append(
            "VAKUM: `UPLOAD_CLAIM` `lib/`de SIFIR eşleşme buldu. Ya iddia "
            "bilerek kaldırıldı (bu kapı da emekli edilmeli) ya tarama "
            "kırık (regex Lissom'un güncel cümlesini kaçırıyor olabilir). "
            "Sessiz 'geçti' burada YANLIŞ olurdu."
        )

    # Öz-testler — kapı KIRMIZI yanabiliyor (sabotaj), dördü de ayrı ayrı.
    if _pubspec_problems(pubspec.read_text() + "\n  posthog_flutter: ^1.0.0\n") \
            <= _pubspec_problems(pubspec.read_text()):
        print("❌ ÖZ-TEST BAŞARISIZ (②): kayıtsız `posthog_flutter` "
              "eklenince kapı ötmedi")
        return 2
    # Gravita bulgusunun kendisi: yalnız .lock'ta yaşayan (yaml'da HİÇ
    # olmayan) transitive bir bağımlılık — bu SATIR olmasaydı Ostinato'nun
    # kapısı sende de aynı delikle geçerdi.
    if not _pubspec_problems(
        "dependencies:\n"
        "  flutter:\n"
        "    sdk: flutter\n"
        "  dio:\n"
        "    dependency: transitive\n"
    ):
        print("❌ ÖZ-TEST BAŞARISIZ (② — Gravita sınıfı): yalnız .lock'ta "
              "yaşayan transitive bağımlılık kaçırıldı")
        return 2
    if not UPLOADER_TRACES.search("await Dio().post(url, data: payload);"):
        print("❌ ÖZ-TEST BAŞARISIZ (①): bilinen bir yükleyici izi "
              "(`Dio(`) yakalanmadı")
        return 2
    if UPLOAD_CLAIM.search("This screen shows your workout history."):
        print("❌ ÖZ-TEST BAŞARISIZ (③ ikizi — YANLIŞ-POZİTİF): iddia "
              "taşımayan sıradan bir cümle yanlışlıkla eşleşti")
        return 2
    if not UPLOAD_CLAIM.search("Everything stays on this phone."):
        print("❌ ÖZ-TEST BAŞARISIZ (③): bilinen bir iddia cümlesi "
              "TÜRETİLEN regex'le eşleşmedi")
        return 2

    print(f"Cihazda-kalır iddiası — {len(claims)} yüzey, {len(uploaders)} "
          f"yükleyici izi, {len(NETWORK_DEPS_RECORDED)} kayıtlı bağımlılık "
          f"(yaml+lock taranmış), 5 öz-test geçti.")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ İddia korunuyor: yükleyici izi yok, bağımlılıklar kayıtlı, "
          "vakum değil.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
