#!/usr/bin/env python3
"""AĞA-ÇIKABİLEN BAĞIMLILIK KAYDI — Ostinato O-080 aktarımı (A3, 2026-08-11).

    Ağa çıkabilen HER bağımlılık KAYITLI olmak zorunda. Kayıtsız bir tanesi
    belirdiğinde bu kapı öter — kayıt bir MUAFİYET değil, bir KARAR NOKTASIDIR.

Ölçüm (`docs/A1-A5-AILE-DENETIMI-2026-08-11.md`, A3): `lib/app/profile_
screen.dart`, `progress_screen.dart`, `home_screen.dart` en az 6 yüzeyde
"on this phone"/"on this device" diyor; `pubspec.yaml` `google_fonts`
taşıyor (açılışta Google'ın font CDN'ine gidiyor, L-222); bu iddiaları
koruyan HİÇBİR kapı yoktu.

## Bu kapının ÖLÇMEDİĞİ — isimle (Ostinato'dan aktarılmayan kısım)

Ostinato'nun O-080'i İKİ parçalıydı: ① bu kayıt (pubspec taraması) ②
sevk edilen yüzeydeki "hiç yüklenmiyor" CÜMLESİNİ kaynak koddaki gerçek
yükleyici izleriyle (`http.post`, `Dio(`…) çapraz doğrulayan ikinci bir
kural. İkincisi buraya TAŞINMADI: Ostinato'nun `UPLOAD_CLAIM` regex'i
Lissom'un GERÇEK cümle biçimini ("stay on this phone", "on this device")
YAKALAMAZ (Ostinato'nunki "never leaves"/"nothing is uploaded" arıyor) —
regex'i körlemesine kopyalamak, aynen koordinatörün uyardığı "içindeki
sabit YEREL çıktı" tuzağının ta kendisi olurdu. Bu yarım bırakıldı, icat
edilmedi — isimli.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

#: Ağa çıkabilen ama kullanıcı verisi TAŞIMAYAN, KAYITLI bağımlılıklar.
#: Yeni bir tanesi eklendiğinde kapı öter — kayıt bir MUAFİYET değil, bir
#: KARAR NOKTASIDIR (Ostinato O-080'in birebir dili).
NETWORK_DEPS_RECORDED = {
    "google_fonts": "yazı tipi indirir (GET); kullanıcı verisi TAŞIMAZ — "
                     "gizlilik iddialarını yalanlamaz, ama L-222 açık "
                     "(çevrimdışı açılışta tipografi kaybı + üçüncü sunucu "
                     "bağlantısı — lisans/bağımlılık kararı koordinatörde)",
}

#: Ağa çıkabilen bağımlılık ailelerinin izleri (pubspec adlarında aranır).
#: Ostinato'dan alındı, BİR DÜZELTMEYLE: gerçek pub.dev paket adları çoğu
#: analitik SDK'sında `_flutter`/`_sdk` sonekiyle gelir (`posthog_flutter`,
#: `amplitude_flutter`, `mixpanel_flutter`, `appsflyer_sdk`, `adjust_sdk`) —
#: kaynak desende bu köklerin bir kısmı `\w*`siz, kaydı SESSİZCE atlardı. Bu
#: kapının kendi öz-testi bunu yakaladı (`dio` ile değil `posthog_flutter`
#: ile sabote edilince); genişletmek yalnız YAKALAMA alanını büyütür,
#: daraltmaz — güvenli yön.
NETWORK_DEP_HINTS = re.compile(
    r"^\s+(http\w*|dio\w*|firebase\w*|sentry\w*|posthog\w*|amplitude\w*|"
    r"mixpanel\w*|segment\w*|appsflyer\w*|adjust\w*|google_fonts|"
    r"supabase\w*|graphql\w*|web_socket\w*):",
    re.MULTILINE)


def _check(pubspec_text: str) -> list[str]:
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


def main() -> int:
    pubspec = ROOT / "pubspec.yaml"
    problems = _check(pubspec.read_text())

    # Öz-test — kapı KIRMIZI yanabiliyor (sabotaj): uydurma bir ağ paketi
    # kayıtsız bırakılırsa yakalanmalı. Gerçek dosyaya dokunmadan, aynı
    # regex'i sentetik girdi üzerinde koşturuyoruz.
    sabotaged = pubspec.read_text() + "\n  posthog_flutter: ^1.0.0\n"
    sabotage_problems = _check(sabotaged)
    if len(sabotage_problems) <= len(problems):
        print("❌ ÖZ-TEST BAŞARISIZ: kayıtsız `posthog_flutter` eklenince "
              "kapı ötmedi — regex ya da mantık bozuk")
        return 2

    print(f"Ağ-bağımlılığı kaydı — {len(NETWORK_DEPS_RECORDED)} kayıtlı, "
          f"öz-test geçti (sabotaj yakalandı)")
    if problems:
        print(f"\n❌ {len(problems)} sorun:")
        for p in problems:
            print(f"  {p}")
        return 1
    print("✅ pubspec.yaml'daki her ağ-yeteneği bağımlılık kayıtlı.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
