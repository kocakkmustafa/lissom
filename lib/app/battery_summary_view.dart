import 'package:flutter/widgets.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'summary_strings.dart';

/// A5 batarya özetinin **YAPISI** — görsel tasarımı KASITLI olarak yok.
///
/// Bu widget ne için var
/// --------------------
/// Statü-örgüsü (M-F-186) bir üslup tercihi değil, **neyin neyin YANINDA
/// görünebileceğine dair bir kısıt**: kıyaslanmış bir ölçümle kıyaslanmamış bir
/// ölçüm aynı görsel grupta duramaz · bandın altındaki değer bir dolum-çubuğuna
/// dönüşemez (§5.1) · çalışan bir ölçüm "yakında" diye etiketlenemez ·
/// ölçülemeyen her satır sebebini İSİMLE taşır. Bu kısıtların görsel geçişten
/// ÖNCE test edilmiş kodda yaşaması gerekiyor, ki tasarım oturumu onları
/// YENİDEN KEŞFETMEK zorunda kalmasın — devralsın. (JabLab/Choreia emsali:
/// yapı-düzeyi widget testleri gerçek bir dürüstlük kusuru yakalamıştı.)
///
/// Bu widget ne DEĞİL
/// ------------------
/// Bitmiş ekran değil. Renk, tipografi, boşluk, ikon ve yerleşim
/// claude.ai/design geçişine ait. **Tasarım üslubu değiştirir ve yapıyı
/// DEVRALIR — icat etmez.** Bu dosyanın arkasında görsel doğrulama da yok: bu
/// oturumun cihazı/emülatörü/kamerası yok, dolayısıyla kanıtlanan şey YAPI'dır,
/// testle; nasıl göründüğü hakkında hiçbir şey iddia edilmiyor.
///
/// Boş bölümler BASILMAZ — ve bu Choreia'dan bilinçli bir sapma. Orada boş
/// "Evaluated" bölümü sebebiyle birlikte basılır, çünkü boşluğu ÜRÜNÜN bir
/// eksikliğidir ve saklanması kullanıcıyı suçlar. Burada boş bir "starting
/// point" bölümü ürün hakkında değil, kullanıcı hakkında iyi haberdir
/// (kimse bandın altında kalmadı) — onu basmak gürültü olurdu. Ölçüm
/// durumundan doğan boşluklar (`notCompared`) zaten satır düzeyinde
/// gerekçesini taşıyor.
///
/// Her bölüm ve her satır bir [Key] taşır: bir test hangi metnin HANGİ BÖLÜMDE
/// göründüğünü iddia edebilsin. Yalnız "metin bir yerde var" diyen bir test,
/// iki bölüm BİRLEŞTİRİLSE bile geçerdi — [BatterySummary] tür-ayrımının
/// önlemek için var olduğu kusurun tam kendisi.
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
    return ListView(
      children: <Widget>[
        // Yüzey ne olduğunu kendi söylüyor (koordinatör koşulu (d)). Tepede,
        // çünkü bir satırın altına düşen beyan o satıra ait bir dipnot gibi
        // okunur — oysa bu, ekranın tamamı hakkındaki iddia.
        const Text(SummaryStrings.header, key: headerKey),
        // Sıra ANLAMLI: kıyaslanmış ölçümler önce, ölçülemeyenler en sonda.
        // `notCompared` bilinçli olarak `notMeasured`'dan ÖNCE — o bir ölçüm
        // satırıdır ve eksiklikler bölgesine sürüklenmesi tam olarak
        // M-F-186'nın yasakladığı karışma olurdu.
        if (summary.scored.isNotEmpty)
          _section(
            key: scoredSectionKey,
            title: SummaryStrings.scoredSection,
            subtitle: SummaryStrings.scoredSubtitle,
            children: summary.scored
                .map((SummaryRow r) => _scoredRow(r))
                .toList(growable: false),
          ),
        if (summary.belowRange.isNotEmpty)
          _section(
            key: belowRangeSectionKey,
            title: SummaryStrings.belowRangeSection,
            subtitle: SummaryStrings.belowRangeSubtitle,
            children: summary.belowRange
                .map((SummaryRow r) => _valueOnlyRow('belowRange', r))
                .toList(growable: false),
          ),
        if (summary.noBands.isNotEmpty)
          _section(
            key: noBandsSectionKey,
            title: SummaryStrings.noBandsSection,
            subtitle: SummaryStrings.noBandsSubtitle,
            children: summary.noBands
                .map((SummaryRow r) => _valueOnlyRow('noBands', r))
                .toList(growable: false),
          ),
        if (summary.notCompared.isNotEmpty)
          _section(
            key: notComparedSectionKey,
            title: SummaryStrings.notComparedSection,
            subtitle: SummaryStrings.notComparedSubtitle,
            children: summary.notCompared
                .map(_notComparedRow)
                .toList(growable: false),
          ),
        if (summary.notMeasured.isNotEmpty)
          _section(
            key: notMeasuredSectionKey,
            title: SummaryStrings.notMeasuredSection,
            subtitle: SummaryStrings.notMeasuredSubtitle,
            children:
                summary.notMeasured.map(_notMeasuredRow).toList(growable: false),
          ),
      ],
    );
  }

  Widget _scoredRow(SummaryRow r) => Column(
        key: rowKey('scored', r.testId),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName),
          Text(SummaryStrings.value(r.value!, r.unit)),
          // Bant etiketi YALNIZ burada basılabilir, çünkü yalnız bu satırda
          // gerçekten bir kıyas yapıldı.
          Text(r.bandLabel ?? SummaryStrings.noJudgement),
        ],
      );

  /// Değer var, hüküm yok: bandın altı ve tasarımla-bantsız satırların ortak
  /// gövdesi. **Hedef taban burada BASILAMAZ** — [SummaryRow] onu hiç
  /// taşımıyor (§5.1 hükmü alan düzeyinde uygulandı), yani bu widget'ın
  /// dolum-çubuğu çizme İMKÂNI yok. Yasak yorumda değil, tipte.
  Widget _valueOnlyRow(String section, SummaryRow r) => Column(
        key: rowKey(section, r.testId),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName),
          Text(SummaryStrings.value(r.value!, r.unit)),
          const Text(SummaryStrings.noJudgement),
        ],
      );

  /// Ölçüm ÇALIŞTI, kıyas yok. Gerekçe ve terfi yolu satırın KENDİSİNDE —
  /// ikisi de config'ten (koordinatör koşulları (a) ve (b)); bu widget onları
  /// üretmiyor, taşıyor.
  Widget _notComparedRow(SummaryRow r) => Column(
        key: rowKey('notCompared', r.testId),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName),
          Text(SummaryStrings.value(r.value!, r.unit)),
          const Text(SummaryStrings.noJudgement),
          if (r.userNote != null) Text(r.userNote!),
          if (r.promotionNote != null) Text(r.promotionNote!),
        ],
      );

  Widget _notMeasuredRow(SummaryRow r) => Column(
        key: rowKey('notMeasured', r.testId),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(r.testName),
          // Sayı YOK — ve yerine tahmin de yok (PRD §5.2: boş bırakılır, ama
          // sebebi yazılır).
          Text(SummaryStrings.reason(r.reasonCode ?? 'unknown')),
        ],
      );

  Widget _section({
    required Key key,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) =>
      Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Text(title), Text(subtitle), ...children],
      );
}
