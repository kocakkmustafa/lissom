/// **library** sekmesi — §5.4 hükmü: TAM GENİŞLİK, KATMANLI.
///
/// Üç kısıt bu dosyanın YAPISINI belirliyor, üslubunu değil:
///
///   1. **Aktif dalga birinci sınıf.** `assessment_battery` tam kart, kendi
///      sayısıyla, en üstte.
///   2. **İnşa edilmemiş aileler görsel olarak AYRI ve KOMPAKT bir bölümde**,
///      her biri dürüst tek satırlık durumla. Eşit-ağırlık listeleme YASAK —
///      altı aileyi aynı kartla dizmek sahte doluluk üretir.
///   3. **Ayrı yol-haritası sayfası YASAK.** Genişlik BURADA görünür; bir
///      "yakında gelecekler" sayfasına sürülmez.
///
/// Aile sayfaları (`FamilyPage`) IA config'in *"her öğe kendi sayfası"*
/// direktifinin karşılığıdır ve bir yol haritası değildir: her biri o ailenin
/// ZORUNLU dürüstlük kutusunu taşır. Kutu okuyucuda tip düzeyinde zorlanıyor
/// (`LibraryIa._honesty`), yani kutusuz bir aile sayfası ÜRETİLEMEZ.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'app_facts.dart';
import 'ia.dart';
import 'lissom_theme.dart';
import 'surfaces.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({required this.facts, super.key});

  static const Key builtSectionKey = Key('library.built');
  static const Key notBuiltSectionKey = Key('library.notBuilt');

  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<LibraryFamily> built = facts.ia.built;
    final List<LibraryFamily> pending = facts.ia.notBuilt;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          Column(
            key: builtSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionHeading(
                'In this build',
                subtitle: 'What Lissom can actually do on your phone today.',
              ),
              const SizedBox(height: 14),
              for (final LibraryFamily f in built)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BuiltFamilyCard(family: f, facts: facts),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Column(
            key: notBuiltSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Bölüm başlığı SAYIYI taşır: genişlik saklanmıyor, ama
              // birinci-sınıf yerleşim de verilmiyor.
              LissomEyebrow('Planned, not in this build (${pending.length})'),
              const SizedBox(height: 6),
              Text(
                'These are named so you can see the whole shape of Lissom. '
                'None of them has content in the app you are holding, and we '
                'are not going to guess when they will.',
                style: t.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final LibraryFamily f in pending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PendingFamilyRow(family: f, facts: facts),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Birinci-sınıf yerleşim: tam kart, gerçek sayı, gerçek giriş.
class _BuiltFamilyCard extends StatelessWidget {
  const _BuiltFamilyCard({required this.family, required this.facts});
  final LibraryFamily family;
  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final int live = facts.live.length;
    final int total = facts.liveness.length;
    return InkWell(
      borderRadius: BorderRadius.circular(LissomRadii.card),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FamilyPage(family: family, facts: facts),
        ),
      ),
      child: LissomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(family.title, style: t.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(family.intro, style: t.textTheme.bodyMedium),
            const SizedBox(height: 12),
            // Sayı TÜRETİLİR (köprüden), yazılmaz. "12 test" demek yeterli
            // olmazdı: 12'sinden 3'ü ölçülebiliyor ve fark kullanıcının
            // görmesi gereken şeyin ta kendisi.
            Text(
              '$total tests · $live measurable by camera in this build',
              style: t.textTheme.bodySmall
                  ?.copyWith(color: LissomColors.roseDeepHover),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kompakt satır: ad + dürüst tek satır durum. Kart YOK, gölge YOK —
/// birinci-sınıf yerleşimle karışmasın.
class _PendingFamilyRow extends StatelessWidget {
  const _PendingFamilyRow({required this.family, required this.facts});
  final LibraryFamily family;
  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(LissomRadii.inner),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FamilyPage(family: family, facts: facts),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: LissomColors.hairline),
          borderRadius: BorderRadius.circular(LissomRadii.inner),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(family.title, style: t.textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(family.inventoryLine, style: t.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: LissomColors.labelMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bir ailenin sayfası — **dürüstlük kutusu ZORUNLU** (opsiyonel değil).
class FamilyPage extends StatelessWidget {
  const FamilyPage({required this.family, required this.facts, super.key});

  static const Key honestyKey = Key('family.honestyBox');
  static const Key liveListKey = Key('family.liveTests');
  static const Key blockedListKey = Key('family.blockedTests');
  static const Key namedChildrenKey = Key('family.namedChildren');

  final LibraryFamily family;
  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: <Widget>[
            Text(family.title, style: t.textTheme.headlineLarge),
            const SizedBox(height: 10),
            Text(family.intro, style: t.textTheme.bodyMedium),
            const SizedBox(height: 22),
            if (family.isBuilt) ..._batteryBody(context) else ..._namedBody(context),
            const SizedBox(height: 8),
            Padding(
              key: honestyKey,
              padding: const EdgeInsets.only(top: 8),
              child: HonestyBoxCard(family.honestyBox,
                  liveness: facts.blockerForClaim),
            ),
            const MeasurementLimitsFootnote(),
          ],
        ),
      ),
    );
  }

  /// İnşa edilmiş aile: gerçek testler, canlı/engelli ayrımıyla — TÜRETİLİR.
  List<Widget> _batteryBody(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<TestLiveness> live = facts.live;
    final List<TestLiveness> blocked = facts.blocked;
    return <Widget>[
      LissomEyebrow('Measured by camera in this build (${live.length})'),
      const SizedBox(height: 10),
      Column(
        key: liveListKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final TestLiveness x in live)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TestRow(
                icon: Icons.videocam_outlined,
                iconColor: t.colorScheme.primary,
                title: x.name,
              ),
            ),
        ],
      ),
      const SizedBox(height: 22),
      // ⛔ "Not measurable YET" DEĞİL — `yet` bir vaattir (M-F-186) ve
      // engelin kalkacağı bir tarih ima eder. Başlık artık yalnız OLGUYU
      // söylüyor; gerekçe her satırın kendisinde.
      LissomEyebrow('Not measured by camera (${blocked.length})'),
      const SizedBox(height: 4),
      Text(
        'Each one below names the reason it cannot be read, and the reason is '
        'what would have to change.',
        style: t.textTheme.bodySmall,
      ),
      const SizedBox(height: 10),
      Column(
        key: blockedListKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
      ),
    ];
  }

  /// İnşa edilmemiş aile: **kurs listesi GÖSTERİLMEZ** (IA config notu). Ne
  /// olduğu ADLARIYLA görünür — isimlendirilmiş ≠ inşa edilmiş, ve satır
  /// bunu söyler. Sahte kart, sahte süre, sahte seviye YOK.
  List<Widget> _namedBody(BuildContext context) {
    final ThemeData t = Theme.of(context);
    if (family.children.isEmpty) {
      return <Widget>[
        NamedGapCard(
          title: family.title,
          reason: family.inventoryLine,
        ),
      ];
    }
    return <Widget>[
      LissomEyebrow('Named in the plan (${family.children.length})'),
      const SizedBox(height: 4),
      Text(
        'Names, not content. Nothing below exists in the app you are holding.',
        style: t.textTheme.bodySmall,
      ),
      const SizedBox(height: 10),
      Column(
        key: namedChildrenKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final FamilyChild c in family.children)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle_outlined,
                        size: 9, color: LissomColors.labelMuted),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                      child: Text(c.title, style: t.textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    ];
  }
}

/// Test satırı — canlı satırda altyazı YOK (ham metrik-id dahili sözlüktür ve
/// bir kez yüzeye sızmıştı), engelli satırda gerekçe VAR.
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
