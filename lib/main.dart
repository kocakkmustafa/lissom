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
library;

import 'package:flutter/material.dart';

import 'app/lissom_theme.dart';
import 'app/shell.dart';

void main() => runApp(const LissomApp());

class LissomApp extends StatelessWidget {
  const LissomApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lissom',
        theme: buildLissomTheme(),
        home: const LissomShell(),
      );
}
