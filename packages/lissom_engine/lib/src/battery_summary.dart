/// Batarya özeti — A5 ekranının VERİ modeli (UI-BRIEF §2.3).
///
/// Motorun ürettiği sonuçları kullanıcıya gösterilecek satırlara çevirir.
/// Var olma sebebi: bu çeviri UI katmanında yapılırsa her ekran kendi
/// "ölçüldü mü / skorlandı mı / neden yok" yorumunu kurar ve **ilk ayrışan
/// yorum sessizce yanlış bir yüzey üretir.** Statü-örgüsünün tek adresi
/// burası (M-F-186: `comingSoon` ölçümün YOKLUĞU · `measurementOnly` ölçüm
/// VAR, kıyas yok — ikisi asla karışmaz).
///
/// **Bu dosya hiçbir metin UYDURMAZ.** Kullanıcıya gidecek her cümle
/// config'ten gelir (`referenceStatus.statusBasis.userText`, `abortCode`
/// mesajları); motor yalnız hangi cümlenin gösterileceğini SEÇER. Uydurulan
/// bir metin, ölçmediğimiz bir şeyi iddia etmenin en kolay yoludur.
library;

import 'assessment_result.dart';
import 'battery.dart';

/// Bir satırın kullanıcıya nasıl sunulacağı — UI-BRIEF §2.4'ün dört katmanı
/// + statü-örgüsü.
enum SummaryPresentation {
  /// Değer + bant etiketi. Tam skorlanmış.
  scoredWithBand,

  /// Değer var, bant etiketi YOK (bandın altı). Koçlanan dil.
  valueBelowRange,

  /// Değer var, testin sayısal bandı yok (nitel/ordinal).
  valueNoBands,

  /// Değer var ama REFERANSA karşı kıyaslanmadı (measurementOnly).
  /// ⚠️ Bu "yakında" DEĞİL — ölçüm çalıştı (M-F-186).
  valueNotCompared,

  /// Ölçüm alınamadı; sebep isimli.
  notMeasuredWithReason,
}

/// A5'te bir test satırı.
final class SummaryRow {
  const SummaryRow({
    required this.testId,
    required this.testName,
    required this.presentation,
    required this.side,
    this.value,
    this.unit,
    this.bandLabel,
    this.userNote,
    this.reasonCode,
    this.promotionNote,
  });

  final String testId;
  final String testName;
  final SummaryPresentation presentation;
  final String side;
  final double? value;
  final String? unit;

  /// KASITLI null olabilir: bandın altında ya da bandı olmayan testte bant
  /// adı vermek, ölçmediğimiz bir sınıflandırmayı iddia etmek olurdu.
  final String? bandLabel;

  /// Kullanıcıya gösterilecek açıklama — CONFIG'ten, uydurulmadı.
  final String? userNote;

  /// `notMeasured` satırlarında sebebin makine adı (yüzey metnini UI
  /// kendi sözlüğünden verir; kod burada İSİMLİ taşınır).
  final String? reasonCode;

  /// `valueNotCompared` satırlarında: bunu ne açacak (promotionPath).
  final String? promotionNote;

  bool get hasValue => value != null;

  /// M-F-186: bu satır "yakında" olarak sunulabilir Mİ? ASLA.
  ///
  /// Ölçüm çalışan bir satır hiçbir koşulda comingSoon değildir. Bu getter
  /// bir kolaylık değil, bir BEYAN: UI tarafında "yakında" göstermek isteyen
  /// kod buradan izin alamaz.
  bool get mayShowAsComingSoon => false;
}

/// A5 ekranının tamamı — **TÜRÜN KENDİSİ bölümleri ayırır.**
///
/// Burada BİRLEŞİK bir satır listesi YOKTUR ve bu bir eksiklik değil, hükmün
/// kendisidir. Widget'ı yazarken gördüm ki tek bir `rows` listesi bir
/// BİRLEŞTİRME DAVETİDİR: yüzey onu tek döngüde gezip hepsini aynı görsel
/// grupta basabilir, ve o an `valueNotCompared` bir ölçüm KIYASLANMIŞ gibi
/// okunur — M-F-186'nın yasakladığı tam olarak bu. Kendi kuralımı kendime
/// uyguladım (§5.1: **alanı vermemek, "yapma" yazmaktan güçlüdür**) —
/// birleşik listeyi belgelemekle yetinmedim, KALDIRDIM. Choreia'nın
/// ProgressSummary tür-ayrımı emsali.
///
/// Beş liste, beş farklı DÜRÜSTLÜK İDDİASI (birleştirilemez oldukları için
/// ayrı):
///   [scored]      ölçüldü, bantla kıyaslandı
///   [belowRange]  ölçüldü, kıyaslandı, en alt çizginin altında (koçlanan)
///   [noBands]     ölçüldü, sayısal bant TASARIMLA yok (nitel/ordinal)
///   [notCompared] ölçüldü, referans HENÜZ yok (ölçülmüş gerekçe + terfi yolu)
///   [notMeasured] sayı yok, sebep isimli
///
/// [noBands] ile [notCompared] ayrımı özellikle önemli: ikisi de "ölçüm var,
/// hüküm yok" ama biri **tasarımla** öyle (asla bant almayacak), diğeri
/// **henüz** öyle (terfi yolu var). Tek bölümde birleştirmek bu ikisini
/// bulanıklaştırırdı.
final class BatterySummary {
  const BatterySummary({
    required this.scored,
    required this.belowRange,
    required this.noBands,
    required this.notCompared,
    required this.notMeasured,
  });

  final List<SummaryRow> scored;
  final List<SummaryRow> belowRange;
  final List<SummaryRow> noBands;
  final List<SummaryRow> notCompared;
  final List<SummaryRow> notMeasured;

  /// Sayılar TÜRETİLİR, yazılmaz (M-O-28) — kurucu bunu zorlar.
  int get measuredCount =>
      scored.length + belowRange.length + noBands.length + notCompared.length;
  int get notMeasuredCount => notMeasured.length;
  int get notComparedCount => notCompared.length;
  int get testCount => measuredCount + notMeasuredCount;

  /// Oturum sonuçlarından özet üretir.
  ///
  /// `results` genelde `AssessmentSession.preservedResults` — yani yalnız
  /// TAMAMLANMIŞ blokların ölçümleri (M-F-133/3: yarım blok kıyas kümesine
  /// giremez). Bataryada olup sonucu OLMAYAN test satır ÜRETMEZ: "hiç
  /// koşulmadı" ile "koşuldu ölçülemedi" farklı şeylerdir ve ikincisini
  /// birincisi gibi göstermek sebep uydurmak olurdu.
  static BatterySummary from({
    required Battery battery,
    required Map<String, AssessmentResult> results,
  }) {
    final Map<SummaryPresentation, List<SummaryRow>> byKind =
        <SummaryPresentation, List<SummaryRow>>{
      for (final SummaryPresentation p in SummaryPresentation.values)
        p: <SummaryRow>[],
    };
    for (final MapEntry<String, AssessmentResult> e in results.entries) {
      final TestSpec? t = battery.tests[e.key];
      if (t == null) {
        throw ArgumentError(
          'sonuç bataryada olmayan bir teste ait: ${e.key} — eşleşmeyen '
          'sonuç sessizce gösterilemez',
        );
      }
      final SummaryRow row = _row(t, e.value);
      byKind[row.presentation]!.add(row);
    }
    for (final List<SummaryRow> l in byKind.values) {
      l.sort((SummaryRow a, SummaryRow b) => a.testId.compareTo(b.testId));
    }
    return BatterySummary(
      scored: byKind[SummaryPresentation.scoredWithBand]!,
      belowRange: byKind[SummaryPresentation.valueBelowRange]!,
      noBands: byKind[SummaryPresentation.valueNoBands]!,
      notCompared: byKind[SummaryPresentation.valueNotCompared]!,
      notMeasured: byKind[SummaryPresentation.notMeasuredWithReason]!,
    );
  }

  static SummaryRow _row(TestSpec t, AssessmentResult r) {
    if (!r.isMeasured) {
      return SummaryRow(
        testId: t.id,
        testName: t.name,
        side: r.side,
        presentation: SummaryPresentation.notMeasuredWithReason,
        reasonCode: r.code.name,
      );
    }

    // Statü-örgüsü SIRASI önemli: `measurementOnly` bir ölçüm satırıdır ve
    // bant/bantsız ayrımının ÜSTÜNDE durur — çünkü kullanıcıya söylenecek
    // asıl şey "bu değer bir referansa karşı kıyaslanmadı"dır.
    final ReferenceStatus? rs = t.referenceStatus;
    if (r.isMeasurementOnly && rs != null) {
      return SummaryRow(
        testId: t.id,
        testName: t.name,
        side: r.side,
        presentation: SummaryPresentation.valueNotCompared,
        value: r.value,
        unit: r.unit,
        // Bant etiketi KASITLI taşınmıyor: referansa kıyaslanmamış bir
        // ölçüme bant adı vermek, tam da yapmadığımız kıyası iddia etmek
        // olurdu. Değer görünür, hüküm görünmez.
        userNote: rs.basisUserText,
        promotionNote: rs.unblockedBy,
      );
    }

    return switch (r.tier) {
      ResultTier.scored => SummaryRow(
          testId: t.id,
          testName: t.name,
          side: r.side,
          presentation: SummaryPresentation.scoredWithBand,
          value: r.value,
          unit: r.unit,
          bandLabel: r.bandLabel,
        ),
      ResultTier.measuredBelowRange => SummaryRow(
          testId: t.id,
          testName: t.name,
          side: r.side,
          presentation: SummaryPresentation.valueBelowRange,
          value: r.value,
          unit: r.unit,
          // §5.1 hükmü: hedef taban DOLUM-ÇUBUĞU olarak gösterilmez.
          // Burada taşınmıyor bile — UI'ın onu çubuk yapma fırsatı olmasın.
        ),
      ResultTier.measuredNoBands => SummaryRow(
          testId: t.id,
          testName: t.name,
          side: r.side,
          presentation: SummaryPresentation.valueNoBands,
          value: r.value,
          unit: r.unit,
        ),
      ResultTier.notMeasured => SummaryRow(
          testId: t.id,
          testName: t.name,
          side: r.side,
          presentation: SummaryPresentation.notMeasuredWithReason,
          reasonCode: r.code.name,
        ),
    };
  }
}
