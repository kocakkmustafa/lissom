#!/usr/bin/env python3
""""CİHAZDA KALIR / YÜKLENMEZ" İDDİA KAPISI — Ostinato O-080 aktarımı (A3).

    Doğru bir iddianın korunmaması, gelecekteki bir yalandır.

Ölçüm (`docs/A1-A5-AILE-DENETIMI-2026-08-11.md`, A3 + koordinatörün 2.
sevkindeki O-080 reçetesi): `lib/app/profile_screen.dart`/`progress_screen
.dart`/`home_screen.dart` en az 6 yüzeyde "stay on this phone"/"on this
device"/"no account and no server" diyor; `pubspec.yaml` `google_fonts`
taşıyor (L-222); bu iddiaları koruyan HİÇBİR kapı yoktu.

## Dört kanal (koordinatörün reçetesi ①②③ + ④ değişim-dedektörü, 2026-08-12)

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
④ **değişim-dedektörü** — ②'nin İÇİNDEKİ yapısal delik (M-F-455,
   koordinatörün KENDİ ölçümü): `NETWORK_DEP_HINTS` bir RET-LİSTESİ,
   listede olmayan bir paket adı sessizce geçer. `pubspec.lock`taki HER
   paket `NETWORK_DEPS_RECORDED` ⊎ `NETWORK_DEPS_KNOWN_SAFE` bölmesine
   girmek ZORUNDA — `metric_coverage_test.dart`ın BÖLME desenininin AYNISI,
   ret-listesi yerine TAM KAPSAM.

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

# ── ④ değişim-dedektörü — ③'ün ta kendisinde bulunan yapısal delik ──────
#
# Aile bulgusu (motion-core DEFTER, M-F-455 — koordinatörün KENDİ ölçümü,
# kendi tahmininde unuttuğu): "ipucu listesi bir RET-LİSTESİDİR, listede
# olmayan paket sessizce geçer." `NETWORK_DEP_HINTS` yalnız BİLİNEN
# aile-öneklerini arıyor — adı `ably_flutter`, `grpc`, `pusher_client`,
# `retrofit` gibi bu listede OLMAYAN, ama gerçekten ağa çıkan bir paket
# hiçbir zaman eşleşmez ve sessizce geçer. Bu, ②'nin İÇİNDE bir "sessiz-
# geçiş" — ③'ün (vakum koruması) yakaladığı sınıftan AYRI: ③ İDDİANIN
# YOK OLMASINI yakalar, bu YENİ bağımlılığın SINIFLANDIRILMAMIŞ KALMASINI.
#
# Çözüm bir RET-LİSTESİ değil bir BÖLME: `pubspec.lock`taki HER paket ya
# `NETWORK_DEPS_RECORDED`da (ağa çıkabilir, gerekçeli) ya burada (ağa
# ÇIKAMAZ, gerekçeli) olmalı. Üçüncü hâl (ikisinde de YOK) KIRMIZI —
# `metric_coverage_test.dart`ın BÖLME desenininin AYNISI (gereken = A ⊎ B).
#
# **Dürüst sınır — isimle:** bu sınıflandırma her paketin KAYNAK KODUNU
# okuyarak DEĞİL, KATEGORİ+İTİBARLA yapıldı (Dart/Flutter SDK'sının kendi
# paketleri, ya da tek-amaçlı, I/O YÜZEYİ olmayan ekosistem paketleri —
# `http_parser` kaydının zaten kullandığı "pub.dev açıklaması" ilkesinin
# aynısı, TEK TEK 60 paket için tekrarlanmadı). Yeni bir paket eklendiğinde
# bu liste BÜYÜMEZ kendiliğinden — kapı kırmızı yanar, sınıflandırma ELLE
# yapılır. Kapsam: yalnız BUGÜN `pubspec.lock`ta olan 63 paket.
NETWORK_DEPS_KNOWN_SAFE = {
    # Flutter/Dart SDK'sının KENDİSİ — pub.dev'den inen bir "bağımlılık"
    # değil, SDK'nın parçası.
    "flutter": "Flutter SDK",
    "flutter_test": "Flutter SDK",
    "flutter_web_plugins": "Flutter SDK",
    "sky_engine": "Flutter SDK (Dart core kütüphaneleri SDK snapshot'ı)",
    # dart-lang/flutter ekibinin bakımındaki temel ekosistem paketleri —
    # saf hesaplama/veri-yapısı/test-altyapısı, bilinen I/O yüzeyi yok.
    "collection": "saf veri yapısı, I/O yok",
    "meta": "yalnız annotation, çalışma zamanı kodu yok",
    "path": "dosya yolu string işlemleri, I/O yok",
    "characters": "Unicode grapheme kümesi işlemleri, I/O yok",
    "clock": "saat soyutlaması (test için), I/O yok",
    "vector_math": "saf matematik (matris/vektör), I/O yok",
    "async": "Future/Stream yardımcıları, kendi başına I/O yapmaz",
    "boolean_selector": "test etiketi ayrıştırma, I/O yok",
    "matcher": "test-altyapısı (expect/matcher), I/O yok",
    "stack_trace": "hata izi biçimlendirme, I/O yok",
    "stream_channel": "Stream soyutlaması, kendi başına I/O yapmaz",
    "source_span": "kaynak-konum izleme (derleyici altyapısı), I/O yok",
    "string_scanner": "string ayrıştırma, I/O yok",
    "term_glyph": "terminal Unicode/ASCII glif seçimi, I/O yok",
    "test_api": "test-altyapısı sözleşmesi, I/O yok",
    "fake_async": "test için zaman simülasyonu, I/O yok",
    "typed_data": "ikili veri görünümleri, I/O yok",
    "pub_semver": "sürüm dizesi ayrıştırma, I/O yok",
    "yaml": "YAML ayrıştırma, kendi başına I/O yapmaz",
    "package_config": "paket çözümleme meta-verisi okuma (yerel dosya), ağ değil",
    "vm_service": "Dart VM hata-ayıklama protokolü, yerel/geliştirme aracı",
    "args": "komut satırı argüman ayrıştırma, I/O yok",
    "ffi": "native bellek/işlev arayüzü (C interop), ağ değil",
    "platform": "işletim sistemi/platform TESPİTİ, ağ değil",
    "plugin_platform_interface": "Flutter eklenti sözleşme soyutlaması, I/O yok",
    "web": "tarayıcı JS-interop bağlamaları (Lissom mobil hedefliyor, "
           "web platformu kullanılmıyor — kullanılsa bile ÇAĞIRAN kod "
           "sorumludur, kanal ① onu yakalar)",
    "code_assets": "derleme-zamanı native varlık meta-verisi, I/O yok",
    "hooks": "derleme-zamanı hook sözleşmesi, I/O yok",
    "record_use": "derleme-zamanı kullanım kaydı (tree-shaking), I/O yok",
    "xdg_directories": "Linux XDG dizin yolları, dosya sistemi — ağ değil",
    "logging": "yerel log FASADI, varsayılan sink yok (uzağa göndermez)",
    "material_color_utilities": "Material renk algoritmaları, saf hesaplama",
    "lints": "statik analiz kural paketi, dev-only, ÇALIŞMA ZAMANINDA hiç yok",
    "leak_tracker": "bellek-sızıntısı test aracı, dev-only, I/O yok",
    "leak_tracker_flutter_testing": "leak_tracker'ın Flutter eklentisi, dev-only",
    "leak_tracker_testing": "leak_tracker'ın test-altyapısı parçası, dev-only",
    "crypto": "SHA-256 hesaplama (reference_equivalence kanıt zinciri) — "
              "saf hesaplama, I/O yok",
    # path_provider ailesi — DOSYA SİSTEMİ yolu çözer, ağa çıkmaz.
    "path_provider": "yerel dizin yolu çözümü, dosya sistemi — ağ değil",
    "path_provider_android": "path_provider'ın Android platform eklentisi",
    "path_provider_foundation": "path_provider'ın iOS/macOS platform eklentisi",
    "path_provider_linux": "path_provider'ın Linux platform eklentisi",
    "path_provider_platform_interface": "path_provider sözleşme soyutlaması",
    "path_provider_windows": "path_provider'ın Windows platform eklentisi",
    # permission_handler ailesi — pubspec.yaml'ın KENDİ yorumu zaten
    # doğruluyor: "İzin API'sidir, ağa ÇIKMAZ."
    "permission_handler": "OS izin API'si, ağa çıkmaz (pubspec.yaml'da beyanlı)",
    "permission_handler_android": "permission_handler'ın Android eklentisi",
    "permission_handler_apple": "permission_handler'ın iOS/macOS eklentisi",
    "permission_handler_html": "permission_handler'ın web eklentisi",
    "permission_handler_platform_interface": "permission_handler sözleşmesi",
    "permission_handler_windows": "permission_handler'ın Windows eklentisi",
    # motion_core/motion_camera'nın native poz-modeli interop katmanı —
    # Java/ObjC KÖPRÜSÜ, ağ istemcisi değil.
    "jni": "Java native interop köprüsü (poz modeli), ağ değil",
    "jni_flutter": "jni paketinin Flutter eklentisi",
    "jni_util": "jni paketinin yardımcı kütüphanesi",
    "objective_c": "Objective-C native interop köprüsü, ağ değil",
    # lissom_engine/motion_core/motion_camera zaten AYRI sınıflandırılmış
    # (path/git bağımlılığı, `NETWORK_DEPS_RECORDED`da DEĞİL çünkü onlar
    # bu deponun/ailenin KENDİ paketleri — dış bağımlılık değil).
    "lissom_engine": "bu deponun kendi paketi, dış bağımlılık değil",
    "motion_core": "aile paketi, pinli — kendi başına A3 kapsamı DIŞINDA "
                   "(motion-core'un kendi A3'ü kendi deposunda)",
    "motion_camera": "aile paketi, pinli — motion_core ile aynı gerekçe",
}

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


#: `pubspec.lock`ın `packages:` blokundaki HER paket adı — `dependency:`
#: satırı olan ÜST-DÜZEY kayıtlar. `sdks:` bloku (dosyanın SONU, `  dart: "…"`
#: biçiminde, `dependency:` satırı YOK) bu desenle eşleşmez.
_LOCK_PACKAGE = re.compile(r'^  (\S+):\n    dependency:', re.MULTILINE)


def _lock_completeness_problems(
    lock_text: str,
    recorded: dict[str, str] = NETWORK_DEPS_RECORDED,
    safe: dict[str, str] = NETWORK_DEPS_KNOWN_SAFE,
) -> list[str]:
    """④ değişim-dedektörü: `pubspec.lock`taki HER paket ya kayıtlı-ağ ya
    bilinen-güvenli olmalı — üçüncü hâl (ikisinde de YOK) RET-LİSTESİ
    deliğinin ta kendisi (M-F-455).

    `recorded`/`safe` parametre — öz-testler gerçek modül sabitlerini
    MUTASYONA UĞRATMADAN sabotajlı yerel kopyalar geçirebilsin diye
    (bkz. öz-test grubu, çelişki vakası)."""
    problems: list[str] = []
    for m in _LOCK_PACKAGE.finditer(lock_text):
        pkg = m.group(1)
        in_recorded = pkg in recorded
        in_safe = pkg in safe
        if not in_recorded and not in_safe:
            problems.append(
                f"SINIFLANDIRILMAMIŞ paket: `{pkg}` — `pubspec.lock`ta var "
                f"ama ne `NETWORK_DEPS_RECORDED`da (ağa çıkar) ne "
                f"`NETWORK_DEPS_KNOWN_SAFE`de (çıkmaz) kayıtlı. "
                f"`NETWORK_DEP_HINTS` bir RET-LİSTESİ — bu paket adı hiçbir "
                f"aile-önekiyle eşleşmediği için ② sessizce geçmiş olabilir "
                f"(M-F-455). Karar: ağa çıkabiliyorsa `NETWORK_DEPS_RECORDED`a, "
                f"çıkamıyorsa `NETWORK_DEPS_KNOWN_SAFE`ye GEREKÇESİYLE ekle."
            )
        elif in_recorded and in_safe:
            problems.append(
                f"ÇELİŞKİLİ sınıflandırma: `{pkg}` HEM `NETWORK_DEPS_RECORDED` "
                f"HEM `NETWORK_DEPS_KNOWN_SAFE`de — ikisi birbirini dışlar, "
                f"biri yanlış ya da bayat."
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

    # ④ değişim-dedektörü — ②'nin RET-LİSTESİ deliğinin panzehiri (M-F-455).
    # `NETWORK_DEP_HINTS` yalnız adı BİLİNEN ailelerle eşleşen paketi görür;
    # bu bölme HER paketi görür, sınıflandırılmamışı isimle söyler.
    lock_completeness_problems: list[str] = []
    if lock.exists():
        lock_completeness_problems = _lock_completeness_problems(lock.read_text())
    problems += lock_completeness_problems

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
    # ④'ün asıl sınadığı sınıf: adı HİÇBİR `NETWORK_DEP_HINTS` önekiyle
    # eşleşmeyen ama sınıflandırılmamış bir paket (M-F-455'in tam tarifi —
    # `ably_flutter` KASITLI seçildi, bilinen hiçbir aile-önekine uymuyor).
    if not _lock_completeness_problems(
        "packages:\n  ably_flutter:\n    dependency: transitive\n"
        "    version: \"1.0.0\"\nsdks:\n  dart: \">=3.0.0\"\n"
    ):
        print("❌ ÖZ-TEST BAŞARISIZ (④): RET-LİSTESİ önekine UYMAYAN "
              "sınıflandırılmamış paket yakalanmadı — asıl delik açık kaldı")
        return 2
    # Çelişki vakası: `path` gerçekte yalnız KNOWN_SAFE'de — gerçek modül
    # sabitleri MUTASYONA UĞRATILMADAN, yerel bir sabotajlı kopya `recorded`
    # parametresiyle geçirilir (bkz. fonksiyon imzası).
    if not _lock_completeness_problems(
        "packages:\n  path:\n    dependency: transitive\n"
        "    version: \"1.0.0\"\nsdks:\n  dart: \">=3.0.0\"\n",
        recorded={**NETWORK_DEPS_RECORDED, "path": "SABOTAJ — çelişki testi"},
    ):
        print("❌ ÖZ-TEST BAŞARISIZ (④ — çelişki): hem RECORDED hem "
              "KNOWN_SAFE'de olan paket yakalanmadı")
        return 2

    print(f"Cihazda-kalır iddiası — {len(claims)} yüzey, {len(uploaders)} "
          f"yükleyici izi, {len(NETWORK_DEPS_RECORDED)} kayıtlı + "
          f"{len(NETWORK_DEPS_KNOWN_SAFE)} bilinen-güvenli bağımlılık "
          f"(yaml+lock taranmış), 7 öz-test geçti.")
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
