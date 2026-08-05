/// Değerlendirme ana ekranı — **canlı-3 + engelli-9, İSİMLİ ve TÜRETİMLİ.**
///
/// Kapsam hükmü (M-F-272 / L-206): hangi testin canlı koşabildiği burada bir
/// SABİT değil, `deriveLiveness()` sonucudur. Köprü büyüdükçe canlı küme
/// kendiliğinden büyür; kimse listeyi güncellemeyi unutamaz.
///
/// ⛔ `comingSoon` / "yakında" dili YOK (M-F-186): vaat, bilmediğimiz bir
/// tarihi ima eder — ölçüm yerine sayı uydurmakla aynı dürüstlük sınıfı.
/// Engel metni NEDEN'i taşır: hangi kapı kapalı.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lissom_engine/lissom_engine.dart';

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
      appBar: AppBar(title: const Text('Lissom')),
      body: FutureBuilder<List<TestLiveness>>(
        future: (livenessLoader ?? loadLiveness)(),
        builder: (BuildContext c, AsyncSnapshot<List<TestLiveness>> s) {
          final List<Widget> head = <Widget>[
            // BEYAN YÜZEYİN TEPESİNDE (M-F-186 koşul 4) — aşağıda olsaydı
            // kaydırmayan kullanıcı hiç görmezdi.
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
          ];

          // ÇIKMAZ-SOKAK YASAĞI (M-F-267 desen 1): config okunamasa bile ekran
          // AÇILIR ve sebebi SÖYLER. Boş ekran / sessiz spinner yasak.
          if (s.hasError) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                ...head,
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text('Test listesi okunamadı'),
                    subtitle: Text('${s.error}'),
                  ),
                ),
              ],
            );
          }
          if (!s.hasData) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[...head, const LinearProgressIndicator()],
            );
          }

          final List<TestLiveness> live =
              s.data!.where((TestLiveness x) => x.isLive).toList();
          final List<TestLiveness> blocked =
              s.data!.where((TestLiveness x) => !x.isLive).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ...head,
              Text('Kamerayla ölçülebilen testler (${live.length})',
                  style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final TestLiveness x in live)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.videocam_outlined),
                    title: Text(x.testId),
                    subtitle: Text(x.metrics.join(' · ')),
                  ),
                ),
              const SizedBox(height: 20),
              Text('Şu an ölçülemeyen testler (${blocked.length})',
                  style: t.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Bunlar “yakında” değil: her birinin sebebi aşağıda yazılı. '
                'Sebep kalkmadan ölçüm gösterilmez.',
                style: t.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              for (final TestLiveness x in blocked)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.block_outlined),
                    title: Text(x.testId),
                    subtitle: Text(x.blocker!),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
