/// **progress** sekmesi — **karşılaştırma KAPALI hâliyle.**
///
/// Bu ekran "eksik" değil; **tasarlanmış bir hâl.** Nedeni ölçüldü, üç
/// katmanı var ve üçü de yapısaldır:
///
/// **1. Geçmiş kaydında ÖLÇÜM DEĞERİ YOK — ve bu kasıtlı.** `SessionRecord`
/// şeması (çekirdek, M-F-193) bilerek hiçbir skor/değer alanı taşımıyor;
/// çekirdeğin kendi gerekçesi: *"recording zeros before the camera bridge
/// would draw zeros on tomorrow's progress chart."* Yani bir açı trendi
/// çizmek bugün **veri yokluğundan değil, ŞEMA KARARINDAN** imkânsız. Bir
/// trend çizgisi çizmek için önce uydurulmuş bir değer gerekirdi.
///
/// **2. Kıyas ön-koşulları DOĞRULANAMIYOR.** PRD §267 iki ölçümün ancak aynı
/// `modelVariant`, uyumlu config sürümü ve benzer `calibrationProfile`
/// altında kıyaslanabileceğini söylüyor. `SessionRecord` bu üç alanın
/// HİÇBİRİNİ taşımıyor (çekirdeğin notu: attempt-düzeyi köken bilgisi
/// ADR-005 gereği bilerek dışarıda). Yani kıyasın yapılabilir olduğunu
/// **kontrol edemiyoruz** — ve kontrol edemediğimiz bir koşulu varsaymak,
/// kıyası sessizce yapmak olurdu.
///
/// **3. MDC eşiği YOK.** Bir değişimin ölçüm gürültüsünden büyük olup
/// olmadığını söyleyemediğimiz sürece `improved`/`worsened` dili YASAK. Bu
/// ekranda o iki kelime GEÇMEZ (`progress_screen_test.dart` tarar).
///
/// Geriye kalan ve **gerçek** olan şey: neyin, ne zaman, hangi rejimde
/// kaydedildiği. Bu bir trend değil, bir DEFTER — ve defter dürüsttür.
library;

import 'package:flutter/material.dart';
import 'package:motion_core/motion_core.dart';

import 'app_facts.dart';
import 'lissom_theme.dart';
import 'session_history_view.dart';
import 'surfaces.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({required this.facts, super.key});

  static const Key comparisonNoticeKey = Key('progress.comparisonOff');
  static const Key ledgerKey = Key('progress.ledger');
  static const Key emptyKey = Key('progress.empty');
  static const Key unavailableKey = Key('progress.unavailable');

  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final SessionHistoryView h = facts.history;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          const CaptureUnavailableNote(),
          const SectionHeading(
            'Your record',
            subtitle: 'What was measured, when, and under what conditions.',
          ),
          const SizedBox(height: 18),

          // KIYAS KAPALI — ve sebebi ekranın TEPESİNDE, aşağıda değil.
          // Aşağıda olsaydı, kaydırmayan kullanıcı listeyi bir ilerleme
          // grafiği sanardı.
          Padding(
            key: comparisonNoticeKey,
            padding: const EdgeInsets.only(bottom: 20),
            child: LissomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LissomEyebrow('No comparison is made here',
                      color: LissomColors.roseDeepHover),
                  const SizedBox(height: 8),
                  Text(
                    'Lissom does not draw a trend line for you, and it does '
                    'not tell you whether a measurement went up or down.',
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Two measurements can only be set against each other when '
                    'they were taken with the same model, a compatible '
                    'configuration and a similar camera setup. What we store '
                    'about a past session does not record any of those three, '
                    'so we cannot check that they hold — and we are not going '
                    'to compare on the assumption that they did.',
                    style: t.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We also have no figure for how much a reading can move '
                    'on its own between two sessions. Without it, calling a '
                    'change real would be a guess.',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          if (!h.countsAreTrustworthy)
            NamedGapCard(
              key: unavailableKey,
              title: "Your history didn't open",
              reason: 'We are not going to show you a count, because an empty '
                  'list here would read as "you never measured" — and we do '
                  'not know that.',
              detail: h.failure,
            )
          else if (!h.hasRecords)
            const NamedGapCard(
              key: emptyKey,
              title: 'Nothing recorded on this device',
              reason: 'No session can be captured in this build, so there is '
                  'nothing to list. When one can, every reading it produced '
                  'appears here with its date and conditions.',
            )
          else ...<Widget>[
            if (h.countsAreFloor) ...<Widget>[
              _floorBanner(t, h.unreadable),
              const SizedBox(height: 14),
            ],
            LissomEyebrow('Recorded readings (${h.records.length})'),
            const SizedBox(height: 10),
            Column(
              key: ledgerKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final SessionRecord r in h.records)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LedgerRow(record: r, facts: facts),
                  ),
              ],
            ),
          ],

          const MeasurementLimitsFootnote(),
        ],
      ),
    );
  }

  /// Kayıp kayıt varsa sayı bir ALT SINIRDIR ve bu SÖYLENİR (M-F-228: 40/50
  /// bozukken "10 oturum" demek, kullanıcının yaptığı işi silmekti).
  static Widget _floorBanner(ThemeData t, int unreadable) => LissomCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Text(
          '$unreadable stored record${unreadable == 1 ? '' : 's'} on this '
          // ⚠️ Burada eskiden "treat it as a floor" yazıyordu ve genişletilmiş
          // wellness süzgeci ilk koşuşunda yakaladı. Masum anlamda kullanılmış
          // olsa da `treat` mağaza incelemesinin taradığı kelimelerden biri —
          // bir wellness ürününde onu hiç kullanmamak en ucuz seçenek.
          'device could not be read. The list below is what we could read — '
          'a floor, not a total.',
          style: t.textTheme.bodyMedium
              ?.copyWith(color: LissomColors.roseDeepHover),
        ),
      );
}

/// Defter satırı — bir OLGU, bir hüküm değil.
///
/// Ölçülemeyen denemeler DÜŞÜRÜLMEZ: kullanıcı o işi gerçekten yaptı ve
/// sebebi isimli. Kaydetmemek, yarın yüzeyin "1 deneme" demesine yol açardı —
/// kullanıcı 1 yapmış ve o ölçülememişken. Sessizlik yalan söyler.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.record, required this.facts});
  final SessionRecord record;
  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(facts.testNameFor(record.lessonId),
              style: t.textTheme.titleMedium),
          const SizedBox(height: 5),
          Text(_dateOf(record.completedAt), style: t.textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(_regime(record), style: t.textTheme.bodyMedium),
          if (record.unmeasuredUnits > 0) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              '${record.unmeasuredUnits} attempt'
              '${record.unmeasuredUnits == 1 ? '' : 's'} could not be read'
              '${record.unmeasuredReason == null ? '' : ' · '
                  '${_reasonText(record.unmeasuredReason!)}'}',
              style:
                  t.textTheme.bodySmall?.copyWith(color: LissomColors.bodySecondary),
            ),
          ],
        ],
      ),
    );
  }

  /// Kaydın YAZIM ANINDAKİ rejimi. Sonradan türetilmez — sonradan hesaplanan
  /// bir sınıf, terfi öncesi alınmış ölçümleri geriye dönük "skorlanmış"
  /// gösterirdi.
  static String _regime(SessionRecord r) => switch (r.lessonClass) {
        'scored' => 'Measured, and set against a reference range.',
        'coached' =>
          'Measured, and below the lowest reference line. No band label is '
              'given to a value under the lowest band.',
        'qualitative' =>
          'Measured. This test has no numeric range by design — it uses '
              'described levels.',
        'measurementOnly' =>
          'Measured. No reference range was applied, so this reading carries '
              'no judgement.',
        'notMeasured' => 'Attempted. No reading could be taken.',
        _ => 'Recorded.',
      };

  /// Motorun `ResultCode` adları KULLANICI diline çevrilir — ham kod yüzeye
  /// SIZMAZ (çekirdek sözleşmesi: ham `detail`/hata kodu yüzeye çıkmaz).
  static String _reasonText(String code) => switch (code) {
        'noAttemptDetected' => 'no movement was detected',
        'setupTimedOut' => 'the setup did not settle in time',
        'measurementTimedOut' => 'the reading did not settle in time',
        'aborted' => 'the attempt was stopped by a form check',
        'trackingLost' => 'the camera lost track of you',
        'lowConfidence' => 'the reading was not confident enough to keep',
        _ => 'the reason was not recorded',
      };

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _dateOf(DateTime d) {
    final DateTime l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }
}
