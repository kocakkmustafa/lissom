/// Lissom giriş noktası — **measurementOnly** değerlendirme yüzeyi.
///
/// ⛔ **K8 + ADR-003 (bağlayıcı):** sayısal SKOR yok · karşılaştırma yok ·
/// MDC/klinik iddia yok. Gösterilen şey bir ÖLÇÜMDÜR, bir NOT değil —
/// "başlangıç noktan bu" anlatı sınıfı.
///
/// Kabuk yalnız KABLOLAMA (G-100): hiçbir hüküm burada yaşamaz, hepsi
/// `lissom_engine`'de. Bu dosya hâlleri GÖSTERİR, karar VERMEZ.
///
/// **Kapsam hükmü (M-F-272 / L-206):** bataryanın 12 testinden 3'ü canlı
/// koşabilir (`overhead_reach` · `deep_squat` · `active_straight_leg_raise`);
/// kalan 9'un metrik köprüsü yok ve bu **isimli engelle** görünür.
/// `comingSoon`/vaat dili KULLANILMAZ (M-F-186): "yakında" bir söz verir, oysa
/// engelin ne zaman kalkacağı bilinmiyor — bilmediğimiz bir tarihi ima etmek,
/// ölçüm yerine sayı uydurmakla aynı dürüstlük sınıfı.
library;

import 'package:flutter/material.dart';

import 'app/assessment_home.dart';

void main() => runApp(const LissomApp());

class LissomApp extends StatelessWidget {
  const LissomApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lissom',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A7D6E)),
          useMaterial3: true,
        ),
        home: const AssessmentHomeScreen(),
      );
}
