#!/bin/bash
# A12 CİHAZ KOŞUM HATTI — ÖN UÇUŞ (L-313)
#
# ⛔ BU BİR KAPI DEĞİLDİR ve `all_gates.py`e EKLENMEZ.
#    Gerekçe (aile kuralı): *bir kapı kendi ürününün ilerlemesini
#    cezalandırıyorsa, ürünün düşmanıdır.* Bu betik, kurucu onayı
#    gerektiren iki adım yüzünden bugün NO-GO döner; tam-cümleye
#    girseydi 21 kapılık yeşili kalıcı kırmızıya çevirirdi.
#
# NE DOĞRULAR: **A12** — *"gerçek cihazda en az A1 akışı koştu"*.
#    Ölçüt C bölümü: bir kapı ancak A tablosundaki bir kalemin iddiasını
#    doğruluyorsa kurulur. Bu betik A12'nin İMZA DIŞINDAKİ her ön
#    koşulunu ölçer, ki onay geldiği an koşum DAKİKALAR sürsün.
#
# KULLANIM:
#    bash tools/a12_device_preflight.sh           # hızlı (derleme yok)
#    bash tools/a12_device_preflight.sh --build   # imzalı derlemeyi de dener
#    bash tools/a12_device_preflight.sh --self-test
#
# 🪤 KABUK TUZAKLARI (bu ailede gerçekten ısırdı, hepsi burada kaçınıldı):
#    · `timeout` bu makinede YOK — kullanılmadı
#    · çıkış kodu okunacaksa BORU YOK — `$?` her yerde borusuz okunur
#    · `2>/dev/null` hatayı yutar ⇒ "boşlukta sıfır" — yalnız değeri
#      OLMAYAN anahtar sorgularında, ve orada da sonuç AYRICA sınanır
#    · `grep -c` SATIR sayar, eşleşme değil

set -u

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
XCODE_PROFILES="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles"
LEGACY_PROFILES="$HOME/Library/MobileDevice/Provisioning Profiles"

PASS=0
FAIL=0
CONSENT=0

ok()      { echo "  ✅ $1"; PASS=$((PASS+1)); }
bad()     { echo "  ⛔ $1"; FAIL=$((FAIL+1)); }
consent() { echo "  🛑 $1"; CONSENT=$((CONSENT+1)); }
info()    { echo "     ↳ $1"; }

# ── ①  PROFİL DİZİNİ — bu ölçümün DOĞDUĞU hata ────────────────────────
#
# 🔴 L-313'ün bulgusu: devir notu ve koordinatör "makinede kurulu TEK
#    profil `com.yulalab.burunfarki`, `com.yulalab.lissom` YOK" dedi ve
#    A12'yi B1/B7'ye (kurucuya) yazdı. Ölçüm YANLIŞ DİZİNDEN yapılmıştı:
#    eski `~/Library/MobileDevice/…` okunmuştu, Xcode 26 profilleri
#    `~/Library/Developer/Xcode/UserData/…` altında tutuyor.
#    Gerçek: 1 değil **10** profil, ve `T5HZGYBWK8.*` joker'i
#    `com.yulalab.lissom`u KAPSIYOR.
#    ⇒ *yanlış yol = boşlukta sıfır* — bu hattın kendi kayıtlı tuzağı.
profile_dir_check() {
  echo "① PROFİL DİZİNİ"
  local xc=0 lg=0
  [ -d "$XCODE_PROFILES" ] && xc=$(ls -1 "$XCODE_PROFILES" | grep -c '\.mobileprovision$')
  [ -d "$LEGACY_PROFILES" ] && lg=$(ls -1 "$LEGACY_PROFILES" | grep -c '\.mobileprovision$')
  info "Xcode dizini : $xc profil   ($XCODE_PROFILES)"
  info "eski dizin   : $lg profil   ($LEGACY_PROFILES)"
  if [ "$xc" -gt 0 ]; then
    ok "profil kaynağı bulundu — ölçüm Xcode dizininden yapılıyor"
  else
    bad "Xcode profil dizini BOŞ — burada sıfır görmek, eski dizine bakmakla AYNI hata olurdu"
  fi
}

# ── ②  HEDEF KİMLİĞİ ──────────────────────────────────────────────────
bundle_check() {
  echo "② HEDEF KİMLİĞİ"
  BUNDLE=$(grep 'PRODUCT_BUNDLE_IDENTIFIER' "$APP_DIR/ios/Runner.xcodeproj/project.pbxproj" \
            | grep -v RunnerTests | head -1 | sed 's/.*= *//; s/;//; s/ //g')
  TEAM=$(grep 'DEVELOPMENT_TEAM' "$APP_DIR/ios/Runner.xcodeproj/project.pbxproj" \
            | head -1 | sed 's/.*= *//; s/;//; s/ //g')
  if [ -n "$BUNDLE" ] && [ -n "$TEAM" ]; then
    ok "bundle=$BUNDLE  team=$TEAM"
  else
    bad "bundle ya da team projeden okunamadı (bundle='$BUNDLE' team='$TEAM')"
  fi
}

# ── ③  CİHAZ ──────────────────────────────────────────────────────────
#
# ⚠️ `xctrace` bu cihazı "Devices Offline" altında listeliyor ve devir
#    notu bunu ENGEL sandı. `devicectl` ve `flutter devices` ölçtü:
#    cihaz **available (paired)** ve KABLOSUZ bağlı. İki araç, iki
#    kimlik uzayı — *bir aracın duvarı, sorunun duvarı değildir.*
device_check() {
  echo "③ CİHAZ"
  local out rc
  out=$(xcrun devicectl list devices 2>&1)
  rc=$?
  if [ $rc -ne 0 ]; then
    bad "devicectl çalışmadı (rc=$rc)"
    info "$(echo "$out" | head -3)"
    DEVICE_UDID=""
    return
  fi
  echo "$out" | grep -q 'available'
  if [ $? -eq 0 ]; then
    ok "eşleşmiş ve erişilebilir cihaz VAR"
    info "$(echo "$out" | grep 'available' | head -2)"
  else
    bad "eşleşmiş/erişilebilir cihaz YOK — telefon kilidi açık ve bağlı olmalı"
  fi

  DEVICE_UDID=$(flutter devices --machine 2>/dev/null \
    | python3 -c "import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
for x in d:
    if x.get('targetPlatform','').startswith('ios') and not x.get('emulator'):
        print(x.get('id','')); break" )
  if [ -n "$DEVICE_UDID" ]; then
    ok "gerçek iOS cihaz UDID'si okundu: $DEVICE_UDID"
  else
    bad "flutter gerçek bir iOS cihazı bildirmedi"
  fi
}

# ── ④  İMZA KİMLİĞİ ───────────────────────────────────────────────────
identity_check() {
  echo "④ İMZA KİMLİĞİ"
  local out n
  out=$(security find-identity -v -p codesigning)
  n=$(echo "$out" | grep -c 'Apple Development')
  if [ "$n" -gt 0 ]; then
    ok "Apple Development kimliği var ($n adet)"
    info "$(echo "$out" | grep 'Apple Development' | head -2 | sed 's/^ *//')"
  else
    bad "Apple Development kimliği YOK — cihaz (debug) koşusu imzalanamaz"
  fi
}

# ── ⑤  PROFİL ↔ BUNDLE ↔ CİHAZ — A12'nin GERÇEK engeli burada ────────
#
# 🔴 BULGU: joker profil `T5HZGYBWK8.*` bundle'ı KAPSIYOR ama
#    ProvisionedDevices listesinde YALNIZ 1 cihaz var ve o, bağlı
#    telefon DEĞİL. Bağlı telefon takıma KAYITLI (4 başka profilde
#    görünüyor) ⇒ eksik olan tek şey jokerin TAZELENMESİ.
profile_match_check() {
  echo "⑤ PROFİL ↔ BUNDLE ↔ CİHAZ"
  if [ ! -d "$XCODE_PROFILES" ]; then bad "profil dizini yok"; return; fi

  local covering="" device_ok="" registered=0
  for f in "$XCODE_PROFILES"/*.mobileprovision; do
    [ -e "$f" ] || continue
    local plist appid name
    plist=$(security cms -D -i "$f")
    appid=$(echo "$plist" | plutil -extract Entitlements.application-identifier raw -o - - 2>/dev/null)
    name=$(echo "$plist" | plutil -extract Name raw -o - - 2>/dev/null)

    # cihaz bu takıma KAYITLI mı? (herhangi bir profilde görünmesi yeter)
    if [ -n "${DEVICE_UDID:-}" ] && echo "$plist" | grep -q "$DEVICE_UDID"; then
      registered=$((registered+1))
    fi

    # bundle'ı kapsıyor mu? (tam eşleşme ya da joker)
    case "$BUNDLE" in
      "") ;;
      *) if [ "$appid" = "$TEAM.$BUNDLE" ] || [ "$appid" = "$TEAM.*" ]; then
           covering="$covering|$name"
           if [ -n "${DEVICE_UDID:-}" ] && echo "$plist" | grep -q "$DEVICE_UDID"; then
             device_ok="$name"
           fi
         fi ;;
    esac
  done

  if [ -n "$covering" ]; then
    ok "bundle'ı kapsayan profil VAR:$(echo "$covering" | tr '|' ' ')"
  else
    bad "bundle'ı kapsayan profil YOK"
  fi

  if [ "$registered" -gt 0 ]; then
    ok "cihaz bu takıma KAYITLI ($registered profilde görünüyor) — portal kaydı GEREKMİYOR"
  else
    bad "cihaz hiçbir profilde yok — portal cihaz kaydı gerekir (KURUCU)"
  fi

  if [ -n "$device_ok" ]; then
    ok "kapsayan profil bu cihazı da İÇERİYOR ($device_ok) — kurulum imzası HAZIR"
  else
    consent "kapsayan profil bu cihazı İÇERMİYOR ⇒ profil TAZELENMELİ"
    info "çare: xcodebuild … -allowProvisioningUpdates  (Apple Developer hesabına YAZAR — kurucu onayı)"
  fi
}

# ── ⑥  İMZALI DERLEME ─────────────────────────────────────────────────
build_check() {
  echo "⑥ İMZALI CİHAZ DERLEMESİ"
  if [ "${DO_BUILD:-0}" != "1" ]; then
    info "atlandı (--build ile çalıştır)"
    return
  fi
  local log="/tmp/lissom_a12_build.log" rc
  xcodebuild build -workspace "$APP_DIR/ios/Runner.xcworkspace" -scheme Runner \
    -configuration Debug -destination 'generic/platform=iOS' > "$log" 2>&1
  rc=$?
  if [ $rc -eq 0 ]; then
    ok "imzalı derleme GEÇTİ (rc=0) — log: $log"
  else
    bad "imzalı derleme DÜŞTÜ (rc=$rc) — log: $log"
    info "$(grep -m3 'error:' "$log")"
  fi
}

# ── ⑦  ONAY KAPILARI — hattın DOKUNMADIĞI iki adım ───────────────────
consent_gates() {
  echo "⑦ ONAY KAPILARI (hat kapatamaz — M-F-77)"
  consent "profil tazeleme: Apple Developer hesabına yazar"
  consent "kurulum: kurucunun KİŞİSEL telefonuna uygulama yükler"
}

self_test() {
  echo "══ ÖZ-TEST — betik YANLIŞ ÇIKABİLİYOR mu? ══"
  local fails=0
  # pozitif kontrol: var olmayan bir bundle hiçbir profille eşleşmemeli
  BUNDLE="com.yulalab.KESINLIKLE-YOK-$$"; TEAM="T5HZGYBWK8"; DEVICE_UDID="ZZZZ-YOK"
  local before=$FAIL
  profile_match_check > /dev/null
  if [ "$FAIL" -gt "$before" ]; then
    echo "  ✅ uydurma bundle + uydurma cihaz ⇒ betik ÖTTÜ (yanlış çıkabiliyor)"
  else
    echo "  ⛔ uydurma girdiye ÖTMEDİ — bu betik KOŞULSUZ DOĞRU, hiçbir şey ölçmüyor"
    fails=$((fails+1))
  fi
  # negatif kontrol: profil dizini gerçekten dolu mu (vakum koruması)
  local n=0
  [ -d "$XCODE_PROFILES" ] && n=$(ls -1 "$XCODE_PROFILES" | grep -c '\.mobileprovision$')
  if [ "$n" -gt 0 ]; then
    echo "  ✅ vakum koruması: profil dizini dolu ($n) — 'eşleşme yok' sonucu boş kümeden gelmiyor"
  else
    echo "  ⛔ profil dizini BOŞ — her sonuç vakum-doğru olurdu"
    fails=$((fails+1))
  fi
  echo "══ öz-test: $((2-fails))/2 ══"
  [ "$fails" -eq 0 ]
  exit $?
}

DO_BUILD=0
for a in "$@"; do
  case "$a" in
    --build) DO_BUILD=1 ;;
    --self-test) self_test ;;
  esac
done

echo "══════════════════════════════════════════════════════"
echo " A12 ÖN UÇUŞ — Lissom · $(date '+%Y-%m-%d %H:%M')"
echo "══════════════════════════════════════════════════════"
profile_dir_check
bundle_check
device_check
identity_check
profile_match_check
build_check
consent_gates
echo "══════════════════════════════════════════════════════"
echo " geçen: $PASS · düşen: $FAIL · onay bekleyen: $CONSENT"
if [ "$FAIL" -eq 0 ] && [ "$CONSENT" -eq 0 ]; then
  echo " HÜKÜM: GO — koşum başlatılabilir"
  exit 0
elif [ "$FAIL" -eq 0 ]; then
  echo " HÜKÜM: ONAY-BEKLER — teknik engel YOK, $CONSENT onay kapısı açık"
  exit 2
else
  echo " HÜKÜM: NO-GO — $FAIL teknik engel"
  exit 1
fi
