import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'lissom_theme.dart';
import 'summary_strings.dart';

/// A5 batarya özetinin yapısı + görsel katmanı.
///
/// **Yapı SABİT, görsel katman EKLENDİ (2026-08-06 giydirme turu).** Statü-
/// örgüsü (M-F-186) bir üslup tercihi değil, neyin neyin YANINDA
/// görünebileceğine dair bir kısıt — bu dosyanın önceki turu bu kısıtları
/// [Key]'lerle çivilemişti; bu tur onları DEVRALIR, İCAT ETMEZ:
///
///   - Her [Key] AYNEN korunur (Choreia/JabLab widget-testi emsali).
///   - **Her satırın DIŞ widget'ı bizzat `Column(key: rowKey)`dur — üstüne
///     BAŞKA bir Column SARILMAZ.** `battery_summary_view_test.dart`'taki
///     `expectSectionHolds` bir bölümün altındaki TÜM `Column` tipini sayıp
///     satır adedine eşitliyor; kart/gölge gibi görsel sarmalayıcılar bu
///     yüzden `Padding`/`DecoratedBox` ile yapılır — yatay gruplama gerekirse
///     `Row`, DÜŞEY gruplama gerekirse asla ikinci bir `Column` değil.
///   - `belowRange` satırı hâlâ TAM 3 metin taşır, SIRAYLA (ad, değer, tire)
///     — hedef taban [SummaryRow] üstünde yok, dolum-çubuğu çizme İMKÂNI yok.
///   - `notMeasured` satırı hâlâ TAM 2 metin taşır, SIRAYLA (ad, sebep).
///   - Bant etiketi hâlâ SADECE `scored` satırında basılabilir.
///   - Bölüm SIRASI ve "boş bölüm basılmaz" davranışı DEĞİŞMEDİ.
///
/// Bant değerine göre RENK KODLAMA YOK (Low/Normal/Good aynı nötr pil) —
/// "düşük" bandı kırmızıya boyamak, sayısal-skor gösterge yasağının (§5.1 /
/// koordinatör maddesi ①) renk diline çevrilmiş hâli olurdu.
class BatterySummaryView extends StatelessWidget {
  const BatterySummaryView({required this.summary, super.key});

  static const Key headerKey = Key('summary.header');
  static const Key scoredSectionKey = Key('summary.scored');
  static const Key belowRangeSectionKey = Key('summary.belowRange');
  static const Key noBandsSectionKey = Key('summary.noBands');
  static const Key notComparedSectionKey = Key('summary.notCompared');
  static const Key notMeasuredSectionKey = Key('summary.notMeasured');

  final BatterySummary summary;

  static Key rowKey(String section, String testId) =>
      Key('summary.$section.$testId');

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          Padding(
            key: headerKey,
            padding: const EdgeInsets.only(bottom: 22),
            child: LissomEyebrow(SummaryStrings.header,
                color: LissomColors.roseDeepHover),
          ),
          if (summary.scored.isNotEmpty)
            _section(
              context,
              key: scoredSectionKey,
              title: SummaryStrings.scoredSection,
              subtitle: SummaryStrings.scoredSubtitle,
              children: summary.scored
                  .map((SummaryRow r) => _scoredRow(context, r))
                  .toList(growable: false),
            ),
          if (summary.belowRange.isNotEmpty)
            _section(
              context,
              key: belowRangeSectionKey,
              title: SummaryStrings.belowRangeSection,
              subtitle: SummaryStrings.belowRangeSubtitle,
              children: summary.belowRange
                  .map((SummaryRow r) =>
                      _valueOnlyRow(context, 'belowRange', r, coached: true))
                  .toList(growable: false),
            ),
          if (summary.noBands.isNotEmpty)
            _section(
              context,
              key: noBandsSectionKey,
              title: SummaryStrings.noBandsSection,
              subtitle: SummaryStrings.noBandsSubtitle,
              children: summary.noBands
                  .map((SummaryRow r) =>
                      _valueOnlyRow(context, 'noBands', r, coached: false))
                  .toList(growable: false),
            ),
          if (summary.notCompared.isNotEmpty)
            _section(
              context,
              key: notComparedSectionKey,
              title: SummaryStrings.notComparedSection,
              subtitle: SummaryStrings.notComparedSubtitle,
              children: summary.notCompared
                  .map((SummaryRow r) => _notComparedRow(context, r))
                  .toList(growable: false),
            ),
          if (summary.notMeasured.isNotEmpty)
            _section(
              context,
              key: notMeasuredSectionKey,
              title: SummaryStrings.notMeasuredSection,
              subtitle: SummaryStrings.notMeasuredSubtitle,
              children: summary.notMeasured
                  .map((SummaryRow r) => _notMeasuredRow(context, r))
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  /// Görsel sarmalayıcı — [content] KENDİSİ zaten anahtarlı `Column`dur, bu
  /// yalnız etrafına kart/gölge/boşluk ekler. Yeni bir `Column` YARATMAZ.
  static Widget _wrapCard(Widget content, {Gradient? gradient}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: LissomCard(gradient: gradient, child: content),
      );

  static Widget _pill(String text, ThemeData t) => DecoratedBox(
        decoration: BoxDecoration(
          color: LissomColors.canvas,
          borderRadius: BorderRadius.circular(LissomRadii.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(text, style: t.textTheme.titleSmall),
        ),
      );

  Widget _scoredRow(BuildContext context, SummaryRow r) {
    final ThemeData t = Theme.of(context);
    return _wrapCard(
      Column(
        key: rowKey('scored', r.testId),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName, style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(SummaryStrings.value(r.value!, r.unit),
                    style: t.textTheme.displaySmall),
              ),
              const SizedBox(width: 12),
              _pill(r.bandLabel ?? SummaryStrings.noJudgement, t),
            ],
          ),
        ],
      ),
    );
  }

  /// Değer var, hüküm yok: bandın altı ve tasarımla-bantsız satırların ortak
  /// gövdesi. **Hedef taban burada BASILAMAZ** — [SummaryRow] onu hiç
  /// taşımıyor (§5.1 hükmü alan düzeyinde uygulandı). Tire bilerek pil-DIŞI
  /// düz metin: bir pil "sınıflandırıldı" der, düz metin "sınıflandırma yok".
  ///
  /// SIRA SABİT: [ad, değer, tire] — belowRange sabotaj testi `texts[1]` ve
  /// `texts[2]`'yi İNDEKSE göre okuyor, görsel gruplamaya göre değil.
  Widget _valueOnlyRow(BuildContext context, String section, SummaryRow r,
      {required bool coached}) {
    final ThemeData t = Theme.of(context);
    return _wrapCard(
      Column(
        key: rowKey(section, r.testId),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName, style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(SummaryStrings.value(r.value!, r.unit),
              style: t.textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(SummaryStrings.noJudgement,
              style: t.textTheme.bodyMedium
                  ?.copyWith(color: LissomColors.bodySecondary)),
        ],
      ),
      gradient: coached
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[LissomColors.card, Color(0xFFFCF5F0)],
            )
          : null,
    );
  }

  /// Ölçüm ÇALIŞTI, kıyas yok. Gerekçe ve terfi yolu satırın KENDİSİNDE —
  /// ikisi de config'ten; bu widget onları üretmiyor, taşıyor.
  Widget _notComparedRow(BuildContext context, SummaryRow r) {
    final ThemeData t = Theme.of(context);
    return _wrapCard(
      Column(
        key: rowKey('notCompared', r.testId),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName, style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(SummaryStrings.value(r.value!, r.unit),
              style: t.textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(SummaryStrings.noJudgement,
              style: t.textTheme.bodyMedium
                  ?.copyWith(color: LissomColors.bodySecondary)),
          if (r.userNote != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(r.userNote!, style: t.textTheme.bodyMedium),
          ],
          if (r.promotionNote != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(r.promotionNote!,
                style: t.textTheme.bodySmall
                    ?.copyWith(color: LissomColors.roseDeepHover)),
          ],
        ],
      ),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[LissomColors.card, Color(0xFFF7F3F0)],
      ),
    );
  }

  /// Mockup deseni ("Layer 4 · not measured"): sebep, değerin normalde
  /// durduğu BAŞLIK konumunda oturur. SIRA SABİT: [ad, sebep].
  Widget _notMeasuredRow(BuildContext context, SummaryRow r) {
    final ThemeData t = Theme.of(context);
    return _wrapCard(
      Column(
        key: rowKey('notMeasured', r.testId),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName,
              style: t.textTheme.labelLarge
                  ?.copyWith(color: LissomColors.bodySecondary)),
          const SizedBox(height: 8),
          Text(SummaryStrings.reason(r.reasonCode ?? 'unknown'),
              style: t.textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required Key key,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    final ThemeData t = Theme.of(context);
    // KASITLI: `key` doğrudan bu Column'da — bir Padding'e SARILMAZ.
    // `battery_summary_view_test.dart`'taki sıra testi ListView'ın DİREKT
    // çocuk listesini okuyor; bir sarmalayıcı eklemek anahtarı bir seviye
    // gömer ve `indexOf` -1 döner (bu turda böyle kırılıp düzeltildi).
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: t.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: t.textTheme.bodyMedium),
        const SizedBox(height: 14),
        ...children,
        const SizedBox(height: 12),
      ],
    );
  }
}
