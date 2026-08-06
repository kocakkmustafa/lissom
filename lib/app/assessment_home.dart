/// Değerlendirme ana ekranı — **canlı-3 + engelli-9, İSİMLİ ve TÜRETİMLİ.**
///
/// Kapsam hükmü (M-F-272 / L-206): hangi testin canlı koşabildiği burada bir
/// SABİT değil, `deriveLiveness()` sonucudur. Köprü büyüdükçe canlı küme
/// kendiliğinden büyür; kimse listeyi güncellemeyi unutamaz.
///
/// ⛔ Vaat dili YOK (M-F-186): vaat, bilmediğimiz bir tarihi ima eder — ölçüm
/// yerine sayı uydurmakla aynı dürüstlük sınıfı. Engel metni NEDEN'i taşır.
///
/// **Görsel dil (2026-08-06 giydirme turu):** renk/tipografi/boşluk
/// `lissom_theme.dart`'tan, `claude.ai/design` panelinden BİREBİR. Bu ekranın
/// KENDİSİ mockup'ta yok (mockup dört-sekmeli bir IA çiziyor, bu app'te henüz
/// o sekmeler yok) — burada uygulanan şey mockup'ın palet/tipografi/kart
/// dili, mockup'ın SAYFA YAPISI değil. Bkz. oturum raporu §"çözülemeyenler".
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lissom_engine/lissom_engine.dart';

import 'lissom_theme.dart';
import 'summary_strings.dart';
import 'what_lissom_doesnt_do.dart';

/// Batarya config'ini paketten okur ve canlılığı TÜRETİR.
Future<List<TestLiveness>> loadLiveness() async {
  final String raw =
      await rootBundle.loadString('config/tests/lissom-assessment.v1.json');
  return deriveLiveness(Battery.parseJson(raw));
}

class AssessmentHomeScreen extends StatelessWidget {
  const AssessmentHomeScreen({super.key, this.livenessLoader});

  /// Testte enjekte edilebilir — `rootBundle` widget testinde kilitlenebiliyor
  /// (aile gotcha'sı), o yüzden yükleyici ÇAĞIRANA ait.
  final Future<List<TestLiveness>> Function()? livenessLoader;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lissom'),
        actions: <Widget>[
          // İkon+tooltip — AppBar'ın actions Row'u (bizim yazmadığımız,
          // dolayısıyla Expanded ile koruyamadığımız bir Row) uzun bir metin
          // etiketiyle dar cihazda/büyük yazı tipinde taşabilirdi (aile dersi,
          // Choreia — "gerçek metin fixture'dan uzundur, taşma ancak gerçek
          // metinle görünür"). Sabit genişlikli ikon bu sınıfı yapısal olarak
          // ORTADAN KALDIRIR.
          IconButton(
            tooltip: "What Lissom doesn't do",
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const WhatLissomDoesntDoScreen(),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: FutureBuilder<List<TestLiveness>>(
          future: (livenessLoader ?? loadLiveness)(),
          builder: (BuildContext c, AsyncSnapshot<List<TestLiveness>> s) {
            final List<Widget> head = <Widget>[
              // BEYAN YÜZEYİN TEPESİNDE (M-F-186 koşul 4) — aşağıda olsaydı
              // kaydırmayan kullanıcı hiç görmezdi.
              _HonestyBanner(theme: t),
              const SizedBox(height: 22),
            ];

            // ÇIKMAZ-SOKAK YASAĞI (M-F-267 desen 1): config okunamasa bile
            // ekran AÇILIR ve sebebi SÖYLER. Boş ekran / sessiz spinner yasak.
            if (s.hasError) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                children: <Widget>[
                  ...head,
                  LissomCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.error_outline, color: t.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("We couldn't read the test list",
                                  style: t.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text('${s.error}', style: t.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            if (!s.hasData) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                children: <Widget>[
                  ...head,
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }

            final List<TestLiveness> live =
                s.data!.where((TestLiveness x) => x.isLive).toList();
            final List<TestLiveness> blocked =
                s.data!.where((TestLiveness x) => !x.isLive).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
              children: <Widget>[
                ...head,
                LissomEyebrow('Measured by camera now (${live.length})'),
                const SizedBox(height: 10),
                for (final TestLiveness x in live)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TestRow(
                      icon: Icons.videocam_outlined,
                      iconColor: t.colorScheme.primary,
                      title: x.name,
                    ),
                  ),
                const SizedBox(height: 22),
                LissomEyebrow('Not measurable yet (${blocked.length})'),
                const SizedBox(height: 4),
                Text(
                  "Not blocked by a promised date — each one below names "
                  "its own reason, and the reason is what has to change.",
                  style: t.textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                for (final TestLiveness x in blocked)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TestRow(
                      icon: Icons.block_outlined,
                      iconColor: LissomColors.labelMuted,
                      title: x.name,
                      subtitle: x.blocker!,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HonestyBanner extends StatelessWidget {
  const _HonestyBanner({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => LissomCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[LissomColors.cream, LissomColors.peach],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LissomEyebrow(SummaryStrings.header,
                      color: LissomColors.roseDeepHover),
                  const SizedBox(height: 8),
                  Text(
                    'The numbers on this screen are movement measurements — '
                    'not a score, a diagnosis, or a comparison with anyone '
                    'else. They show your starting point.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: LissomColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _TestRow extends StatelessWidget {
  const _TestRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  /// Yalnız engelli satırlarda dolu — engel gerekçesi kullanıcı diliyle,
  /// gerçek metindir. Canlı satırda YOK: ham metrik id'si (`shoulder_flexion_
  /// left`) tasarımın hiçbir mockup'ında görünmeyen dahili sözlük — bu turda
  /// bir önceki taslakta sızmıştı, DESIGN-AHEAD-OF-CODE.md'de "kod > tasarım"
  /// bulgusu olarak kayıtlı, burada kapatıldı.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: t.textTheme.titleMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: t.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
