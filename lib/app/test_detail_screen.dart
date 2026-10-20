/// Test detay sayfası — **SON DEĞER + trend** (D13/F2, `L-316`'nın çözümü,
/// `L-337`nin okuma yarısı).
///
/// **HAM DEĞER gösterilir, "gelişme" iddiası KURULMAZ.** Orkestratör hükmü
/// bağlayıcı: gerçek bir MDC (minimal-algılanabilir-fark) verisi yok — bir
/// trendi *"iyileşme"* diye adlandırmak, ölçmediğimiz bir şeyi iddia etmek
/// olurdu (`D12`, dar ve dürüst). Bu yüzden liste yalnız TARİH + DEĞER
/// taşır; art arda iki değer arasında ok, yüzde, "+5°" gibi hiçbir
/// KARŞILAŞTIRMA dili YOK.
///
/// Her iki taraf AYRI kart — `assessment_history.dart`ın kendi dersi
/// (`historyKeyFor`): sol/sağ ROM gerçekten farklıdır, tek seride
/// birleştirmek asimetriyi gizler. Bir tarafın hiç kaydı yoksa bu SESSİZCE
/// atlanmaz — "0 okuma" adıyla söylenir (A3: iş sunulmuyorsa NEDEN
/// sunulmadığı söylenir).
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'assessment_history.dart';
import 'attempt_values.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';
import 'surfaces.dart';

class TestDetailScreen extends StatefulWidget {
  const TestDetailScreen({
    required this.test,
    this.attemptValueStoreLoader,
    super.key,
  });

  final TestSpec test;

  /// `LiveCaptureScreen.attemptValueStoreLoader`la AYNI enjeksiyon
  /// sözleşmesi — testte enjekte edilir, üretimde `null` ⇒
  /// `openAttemptValueStore`.
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;

  static const Key unavailableKey = Key('testDetail.unavailable');
  static const Key emptyKey = Key('testDetail.empty');

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

/// Depoyu üç hâlli okur — `SessionHistoryView`in KENDİSİ değil (o `motion_core`
/// tipleriyle kurulu), ama AYNI üç-hâl sözleşmesi: `ok`/`unavailable`, ve
/// `ok` içinde her taraf kendi sayısını taşır (`unreadable` toplamı ayrı).
final class _History {
  const _History._(this.bySide, this.unreadable, this.failure);
  const _History.ok(Map<String, List<AttemptValue>> bySide, int unreadable)
    : this._(bySide, unreadable, null);
  const _History.unavailable(String failure)
    : this._(const <String, List<AttemptValue>>{}, 0, failure);

  final Map<String, List<AttemptValue>> bySide;
  final int unreadable;
  final String? failure;
  bool get available => failure == null;
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  List<String> get _sides => widget.test.perSide
      ? const <String>['right', 'left']
      : const <String>['bilateral'];

  late final Future<_History> _history = _load();

  Future<_History> _load() async {
    try {
      final AttemptValueStore store =
          await (widget.attemptValueStoreLoader ?? openAttemptValueStore)();
      final Map<String, List<AttemptValue>> bySide =
          <String, List<AttemptValue>>{};
      for (final String side in _sides) {
        bySide[side] = await store.forLesson(historyKeyFor(widget.test, side));
      }
      return _History.ok(bySide, await store.unreadableRecords());
    } on Object catch (e) {
      // ÇIKMAZ SOKAK YASAĞI (M-F-267): depo açılamazsa sayfa ÇÖKMEZ, ama
      // "0 okuma" da DEMEZ — o "hiç ölçmedin" ile "okuyamıyoruz"u karıştırır.
      return _History.unavailable('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(configText(context, widget.test.name))),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: SafeArea(
          child: FutureBuilder<_History>(
            future: _history,
            builder: (BuildContext context, AsyncSnapshot<_History> snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final _History h = snap.data!;
              final bool anyData = h.bySide.values.any(
                (List<AttemptValue> v) => v.isNotEmpty,
              );
              return ListView(
                padding: const EdgeInsets.all(22),
                children: <Widget>[
                  if (!h.available)
                    NamedGapCard(
                      key: TestDetailScreen.unavailableKey,
                      title: localeText(
                        context,
                        "This test's history didn't open",
                        'Test geçmişi açılamadı',
                      ),
                      reason: localeText(
                        context,
                        'We are not going to show you a count, because an empty list here would read as "you never measured this" — and we do not know that.',
                        'Kayıtlar okunamadığı için sayı göstermiyoruz; boş liste bu testi hiç ölçmediğin anlamına gelmeyebilir.',
                      ),
                      detail: localizedHistoryFailureDetail(context, h.failure),
                    )
                  else if (!anyData)
                    NamedGapCard(
                      key: TestDetailScreen.emptyKey,
                      title: localeText(
                        context,
                        'No readings recorded for this test',
                        'Bu test için kayıt yok',
                      ),
                      reason: localeTemplate(
                        context,
                        'When you measure {test}, the value and date appear here.',
                        '{test} ölçüldüğünde değer ve tarih burada görünür.',
                        <String, Object>{'test': configText(context, widget.test.name)},
                      ),
                    )
                  else ...<Widget>[
                    if (h.unreadable > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          localePlural(
                            context,
                            '{count} recorded readings on this device could not be read by this version of Lissom. They are still on this phone.',
                            '{count} kayıt bu sürümde okunamadı. Kayıtlar hâlâ bu telefonda.',
                            h.unreadable,
                            englishOne: '{count} recorded reading on this device could not be read by this version of Lissom. They are still on this phone.',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    for (final String side in _sides)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: _SideHistory(
                          side: side,
                          showSideLabel: widget.test.perSide,
                          values: h.bySide[side] ?? const <AttemptValue>[],
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SideHistory extends StatelessWidget {
  const _SideHistory({
    required this.side,
    required this.showSideLabel,
    required this.values,
  });

  final String side;
  final bool showSideLabel;

  /// YENİDEN ESKİYE — `AttemptValueStore.forLesson`ın kendi sözleşmesi.
  final List<AttemptValue> values;

  static String _label(String side) => switch (side) {
    'right' => 'Right',
    'left' => 'Left',
    'bilateral' => 'Bilateral',
    _ => side.isEmpty ? side : '${side[0].toUpperCase()}${side.substring(1)}',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    if (values.isEmpty) {
      // Bu tarafın SIFIR kaydı — sessizce atlanmaz, adıyla söylenir (A3).
      return NamedGapCard(
        // ⛔ "yet" YASAK (M-F-186) — bilmediğimiz bir tarihi ima eder.
        // `wellness_lint.py` bunu bu satırda GERÇEKTEN yakaladı (ölçüldü,
        // varsayılmadı): ilk yazımım üç yerde "yet" kullanmıştı.
        title: showSideLabel
            ? localeTemplate(
                context,
                '{side} — no readings',
                '{side} — ölçüm yok',
                <String, Object>{'side': localeText(context, _label(side), _labelTr(side))},
              )
            : localeText(context, 'No readings', 'Ölçüm yok'),
        reason: localeText(
          context,
          'Nothing measured on this side of this test so far on this device.',
          'Bu testin bu tarafında bu cihazda ölçüm kaydı yok.',
        ),
      );
    }
    final AttemptValue last = values.first;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (showSideLabel) ...<Widget>[
            LissomEyebrow(localeText(context, _label(side), _labelTr(side))),
            const SizedBox(height: 8),
          ],
          Text(
            '${localizedDecimal(context, last.value, fractionDigits: last.value == last.value.roundToDouble() ? 0 : 1)}${last.unit}',
            style: t.textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            localeTemplate(
              context,
              'Last measured {date}',
              'Son ölçüm {date}',
              <String, Object>{'date': localizedDate(context, last.completedAt)},
            ),
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          // H-24 ASİMETRİSİ — kendi ölçtüm, VARSAYMADIM (orkestratör
          // hükmü): boş/okunamayan hâller kendini tam açıklıyordu, DOLU
          // hâl sıfır cümle taşıyordu — dürüstlük makinesi yalnız
          // başarısızlıkta ateşleniyordu (H-24, tam bu sınıf). Bu satır
          // asimetriyi kapatır: ürünün en çok kullanılacağı hâl de kendi
          // sınırını söyler.
          Text(
            localeText(
              context,
              'Shown as measured — not compared or judged against each other.',
              'Ölçüldüğü gibi gösterilir; değerler karşılaştırılmaz veya yorumlanmaz.',
            ),
            style: t.textTheme.bodySmall?.copyWith(
              color: LissomColors.bodySecondary,
            ),
          ),
          if (values.length > 1) ...<Widget>[
            const SizedBox(height: 16),
            LissomEyebrow(
              localeTemplate(
                context,
                'Every reading ({count})',
                'Tüm ölçümler ({count})',
                <String, Object>{'count': localizedInteger(context, values.length)},
              ),
            ),
            const SizedBox(height: 8),
            // ⛔ HAM DEĞER — art arda iki satır arasında karşılaştırma dili
            // (ok, yüzde, "+N") KASITLI olarak YOK. Gerçek bir MDC verisi
            // yokken bir farkı "gelişme" diye adlandırmak, ölçmediğimiz bir
            // şeyi iddia etmek olurdu (orkestratör hükmü, D12).
            for (final AttemptValue v in values)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 4,
                  children: <Widget>[
                    Text(
                      localizedDate(context, v.completedAt),
                      style: t.textTheme.bodyMedium,
                    ),
                    Text(
                      '${localizedDecimal(context, v.value, fractionDigits: v.value == v.value.roundToDouble() ? 0 : 1)}${v.unit}',
                      style: t.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _labelTr(String side) => switch (side) {
    'right' => 'Sağ',
    'left' => 'Sol',
    'bilateral' => 'İki taraf',
    _ => side,
  };

}
