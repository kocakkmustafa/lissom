/// Lissom giriş noktası — **measurementOnly** değerlendirme yüzeyi.
///
/// ⛔ **K8 + ADR-003 (bağlayıcı):** sayısal SKOR yok · karşılaştırma yok ·
/// MDC/klinik iddia yok. Gösterilen şey bir ÖLÇÜMDÜR, bir NOT değil —
/// "başlangıç noktan bu" anlatı sınıfı.
///
/// Kabuk yalnız KABLOLAMA (G-100): hiçbir hüküm burada yaşamaz, hepsi
/// `lissom_engine`'de ve versiyonlu config'te. Bu dosya hâlleri GÖSTERİR,
/// karar VERMEZ.
///
/// **Bilgi mimarisi (2026-08-07):** dört sekme — `home` · `library` ·
/// `progress` · `profile` — `config/ia/library.v1.json`'dan TÜRETİLİR.
/// Sekmelerden önce uygulama tek ekrandı ve tasarımın dört sekmesi kodda
/// karşılıksızdı; bu tur o boşluğu kapattı. Her sekmenin dürüst hâli
/// birinci-sınıf ekrandır: ölçülemeyen şey İSİMLİ gerekçeyle görünür,
/// vaat diliyle değil (M-F-186).
///
/// **Onboarding (2026-08-12, SIRA①):** `lib/`de onboarding SIFIR dosyaydı —
/// beş hattan dördünde en az bir ekran varken Lissom'da hiç yoktu (kod işi,
/// kurucu-manuel değil, koordinatör ölçümü). Giriş artık [OnboardingGate]:
/// tamamlanmamışsa [OnboardingFlow], tamamlanmışsa doğrudan [LissomShell].
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/lissom_theme.dart';
import 'app/onboarding_gate.dart';

/// L-348/LIS-P0-002: `google_fonts`un runtime ağ isteğini KAPATIR — iki
/// aile artık `assets/fonts/` altında bundle (`pubspec.yaml`, `tool/
/// fetch_fonts.sh`). Kapatılmadan önce ölçüldü: `PrivacyInfo.xcprivacy`nin
/// kendi yorumunda adıyla kayıtlı GERÇEK bir ağ davranışıydı (L-288),
/// icat edilmiş bir kusur değil.
void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const LissomApp());
}

class LissomApp extends StatelessWidget {
  const LissomApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lissom',
        theme: buildLissomTheme(),
        home: const OnboardingGate(),
      );
}
