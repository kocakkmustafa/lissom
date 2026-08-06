/// Yüzey kopyası kapısı — **yasaklı dilin widget ağacında taranması.**
///
/// Bu kapı bir üslup denetimi değil: taradığı her kelime bir HÜKMÜN ihlalidir
/// ve her biri gerçek bir kusurdan doğdu.
///
///   - `yet` · `coming soon` · `soon` → M-F-186 vaat dili. **`yet` bu turda
///     canlı kodda bulundu**: `metric_bridge._blockerText` iki gerekçesinde de
///     "isn't in the measurement engine **yet**" diyordu ve eski vaat-dili
///     kapısı yalnız `comingSoon`/`yakında` arıyordu — yani kapı vardı, ölçtüğü
///     şey eksikti. (Aile dersi: bir sınırı olduğundan DAR yazmak da pahalı.)
///   - `improved` · `worsened` · `better than` · `worse than` → MDC eşiği yok;
///     bir değişimin gürültüden büyük olduğunu söyleyemiyoruz.
///   - `!` → tezahürat yasağı. Bu ürünün tonu sakin ve yetişkin.
///   - `keep going` · `well done` · `great job` → aynı yasak, kalıp hâliyle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// (kalıp, neden) — neden testin çıktısında görünür, yoksa kapının kırmızısı
/// "bir kelime yasak" der ve KİMSE nedenini hatırlamaz.
const List<(Pattern, String)> kBannedSurfaceCopy = <(Pattern, String)>[
  (
    r'\byet\b',
    'M-F-186 vaat dili: "yet" bilmediğimiz bir tarihi ima eder',
  ),
  (r'coming soon', 'M-F-186 vaat dili'),
  (r'comingsoon', 'M-F-186 vaat dili'),
  (r'\bsoon\b', 'M-F-186 vaat dili'),
  (r'\bimproved\b', 'MDC eşiği yok — değişim iddiası edilemez'),
  (r'\bworsened\b', 'MDC eşiği yok — değişim iddiası edilemez'),
  (r'!', 'tezahürat/ünlem yasağı — ton sakin ve yetişkin'),
  (r'keep going', 'tezahürat yasağı'),
  (r'well done', 'tezahürat yasağı'),
  (r'great job', 'tezahürat yasağı'),
];

/// Ağaçtaki HER `Text`i (offstage dahil) yasaklı kopyaya karşı tarar.
void expectNoBannedCopy(WidgetTester tester) {
  final Iterable<Text> texts =
      tester.widgetList<Text>(find.byType(Text, skipOffstage: false));
  expect(texts, isNotEmpty,
      reason: 'ağaçta hiç Text yok — kapı BOŞ tarama yapıyor, bu bir geçiş '
          'değil (L-183 vacuous-geçiş sınıfı)');
  for (final Text w in texts) {
    final String s = w.data ?? '';
    if (s.isEmpty) continue;
    for (final (Pattern p, String why) in kBannedSurfaceCopy) {
      expect(RegExp(p as String, caseSensitive: false).hasMatch(s), isFalse,
          reason: 'yasaklı yüzey kopyası ($why) — «$s»');
    }
  }
}
