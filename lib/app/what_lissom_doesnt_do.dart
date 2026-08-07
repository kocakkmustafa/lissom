/// "What Lissom doesn't do" — bir özellik değil, bir duruş (design brief §2).
///
/// **Bu tur: elle yazılmış liste SİLİNDİ, sayfa TÜRETİLDİ.**
///
/// Önceki hâlde beş sınır Dart'ta sabit bir `List<_Boundary>` olarak
/// duruyordu — oysa aynı beş kalem `config/ia/library.v1.json` →
/// `whyNotPage.items` içinde de vardı, **farklı kelimelerle.** İki kopya,
/// tek gerçek: config değişince Dart bayatlar ve kimse fark etmez (L-178/
/// L-181'in aynı sınıfı). Artık tek kaynak config.
///
/// **İkinci katman, bu turda AÇILDI:** bataryanın `excluded` bloğu iki testi
/// ÖLÇÜLMÜŞ gerekçeyle dışarıda bırakıyor ve o bloğun hiç okuyucusu yoktu
/// (L-219) — `cervical_rotation` kullanıcının hiçbir zaman göremediği bir
/// karardı. Şimdi:
///
///   - Ürün sınırı ile ölçülmüş dışlama AYNI ŞEYSE (`whyNotTopic` BEYAN
///     eder), ikisi tek kalemde birleşir: sınır üstte, ölçüm altında.
///   - Eşleşmeyen dışlama KENDİ satırını alır. Sessizce kaybolmaz.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'ia.dart';
import 'lissom_theme.dart';

class WhatLissomDoesntDoScreen extends StatelessWidget {
  const WhatLissomDoesntDoScreen({
    required this.items,
    required this.excluded,
    required this.poseTiers,
    super.key,
  });

  static const Key boundariesKey = Key('whyNot.boundaries');
  static const Key excludedKey = Key('whyNot.excludedTests');
  static const Key tiersKey = Key('whyNot.poseTiers');

  /// Poz kütüphanesinin koçluk katmanları — **gerekçeleriyle (L-240).**
  /// Bu blok config'te iki yıldır duruyordu ve okuyucusu yoktu; sonucu:
  /// tier 3'ün gerekçesi (*"pose models silently swap limb labels on
  /// inverted bodies with high confidence"* — aile bulgusu M-019) hiçbir
  /// yüzeyde YOKTU. Yoga kutusu yalnız "avatar only" diyordu: olgu vardı,
  /// **sebep yoktu** — oysa bu ürünün duruşu sebebin kendisi.
  final List<PoseTier> poseTiers;

  final List<WhyNotItem> items;

  /// Bataryadan İSİMLİ gerekçeyle çıkarılmış testler.
  final List<ExcludedTest> excluded;

  /// Ürün sınırına BAĞLANMIŞ dışlamalar — kalemin altında ölçüm satırı olur.
  Map<String, ExcludedTest> get _linked => <String, ExcludedTest>{
        for (final ExcludedTest e in excluded)
          if (e.whyNotTopic != null) e.whyNotTopic!: e,
      };

  /// Hiçbir ürün sınırına bağlanmamış dışlamalar — kendi bölümlerini alırlar.
  List<ExcludedTest> get _unlinked => excluded
      .where((ExcludedTest e) => e.whyNotTopic == null)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Map<String, ExcludedTest> linked = _linked;
    final List<ExcludedTest> loose = _unlinked;

    return Scaffold(
      // Başlıksız — bu sayfa Profile sekmesinin İÇİNDE yaşıyor ve kendi serif
      // başlığıyla tanıtılıyor; AppBar'a ikinci bir başlık koymak aynı adı iki
      // kez söylerdi.
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: <Widget>[
            Text("What Lissom doesn't do", style: t.textTheme.headlineLarge),
            const SizedBox(height: 10),
            Text(
              'We would rather be clear about the edges of the product than '
              'let you find them mid-session. This is not a list of things '
              'we ran out of time for — every line below is a decision.',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Column(
              key: boundariesKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final WhyNotItem b in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _BoundaryCard(
                      title: b.topic,
                      reason: b.reason,
                      measured: linked[b.topic]?.reason,
                    ),
                  ),
              ],
            ),
            if (loose.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              LissomEyebrow('Tests we took out of the battery (${loose.length})'),
              const SizedBox(height: 4),
              Text(
                'These were considered for the twelve-test battery and left '
                'out. The reason is the measurement, not the effort.',
                style: t.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Column(
                key: excludedKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final ExcludedTest e in loose)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _BoundaryCard(
                        title: _humanise(e.id),
                        reason: e.reason,
                      ),
                    ),
                ],
              ),
            ],
            if (poseTiers.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              LissomEyebrow('How much of a pose can be scored'),
              const SizedBox(height: 4),
              Text(
                'Not every position is equally readable by one camera. These '
                'are the three levels, and what puts a pose in each.',
                style: t.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Column(
                key: tiersKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final PoseTier tier in poseTiers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _BoundaryCard(
                        title: tier.scope,
                        reason: _tierLine(tier),
                        measured: tier.reason,
                      ),
                    ),
                ],
              ),
            ],
            // ⚠️ `MeasurementLimitsFootnote` BİLEREK YOK (L-249). O dipnot
            // ÖLÇÜM yüzeylerinin dibine ait; bu sayfanın KENDİSİ zaten sınır
            // sayfası. Aynı beyanı burada tekrarlamak, gerçek sınırların
            // ağırlığını düşüren caveat enflasyonu olurdu:
            // **her şeye caveat eklenirse hiçbiri okunmaz.**
          ],
        ),
      ),
    );
  }

  /// Katmanın ne yaptığı — makine değerleri (`full` · `guided` ·
  /// `avatar_demo_only` · `loose`) yüzeye SIZMAZ, cümleye çevrilir.
  static String _tierLine(PoseTier tier) => switch (tier.coaching) {
        'full' => 'Coached pose by pose, and set against a reference range.',
        'guided' =>
          'Guided, but scored loosely — we say less because we can see less.',
        'avatar_demo_only' =>
          'Shown by the avatar only. Nothing here is scored.',
        _ => 'Coaching level not declared.',
      };

  /// `cervical_rotation` → `Cervical rotation`. Ham id yüzeye SIZMAZ (bu
  /// ailenin ölçülmüş kusuru: dahili metrik sözlüğü bir kez kullanıcı
  /// altyazısına düşmüştü). Dışlanan testin `TestSpec.name`'i YOKTUR —
  /// bataryada olmadığı için — o yüzden ad id'den TÜRETİLİR, uydurulmaz.
  static String _humanise(String id) {
    final String spaced = id.replaceAll('_', ' ');
    return spaced.isEmpty
        ? id
        : '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}

class _BoundaryCard extends StatelessWidget {
  const _BoundaryCard({
    required this.title,
    required this.reason,
    this.measured,
  });

  final String title;
  final String reason;

  /// Ölçülmüş dışlama gerekçesi — varsa. Sönük ve İKİNCİL: ürün sınırı ne
  /// yapmadığımızı söyler, bu satır onu neyin ölçtüğünü söyler.
  final String? measured;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: t.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(reason, style: t.textTheme.bodyMedium),
          if (measured != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(measured!,
                style: t.textTheme.bodySmall
                    ?.copyWith(color: LissomColors.bodySecondary)),
          ],
        ],
      ),
    );
  }
}
