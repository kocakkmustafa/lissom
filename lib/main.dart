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
        home: const MeasurementOnlyBanner(),
      );
}

/// Yüzeyin TEPESİNDEKİ beyan (M-F-186 koşul 4).
///
/// Aşağıya konulsaydı kaydırmayan kullanıcı hiç görmezdi — beyanın yeri
/// içeriğinin bir parçası.
class MeasurementOnlyBanner extends StatelessWidget {
  const MeasurementOnlyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lissom')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: t.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('ÖLÇÜM, NOT DEĞİL', style: t.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Burada gördüğünüz sayılar hareket açıklığı ÖLÇÜMÜdür — '
                    'puan, teşhis ya da başkalarıyla kıyas değil. '
                    'Başlangıç noktanızı gösterir.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kamera akışı ve canlı-3 yüzeyi bir sonraki adımda bu kabuğa
          // bağlanır; hâl tipleri `lissom_engine/live_session_state.dart`'ta
          // hazır (SetupFailed · PermissionDenied · NoPersonDetected ·
          // JointsOutOfFrame · Measuring).
          Card(
            child: ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Kamera akışı bağlanmadı'),
              subtitle: const Text(
                'Platform kabuğu bu turda kuruldu; PoseSource köprüsü ve '
                'cihaz-kanıtı beklemede.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
