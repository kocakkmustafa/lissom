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
  // ⚠️ D13/F2 sırasında ölçüldü: modül dokümanı bu ikisini de "banned" diye
  // ANIYORDU ama `kBannedSurfaceCopy`de HİÇ YOKTU — doküman iddia ediyor,
  // liste karşılamıyordu (`H-24`nin belge/kod ikizi). Test detay sayfası
  // (`test_detail_screen.dart`) tam bu iki kalıbın riskli olduğu yerde
  // yazıldığı için şimdi kapandı.
  (r'\bbetter than\b', 'MDC eşiği yok — değişim iddiası edilemez'),
  (r'\bworse than\b', 'MDC eşiği yok — değişim iddiası edilemez'),
  (r'!', 'tezahürat/ünlem yasağı — ton sakin ve yetişkin'),
  (r'keep going', 'tezahürat yasağı'),
  (r'well done', 'tezahürat yasağı'),
  (r'great job', 'tezahürat yasağı'),
  // Dahili defter atfı — `(L-006)` · `(M-F-71)` · `(J-064)`. Kullanıcı için
  // anlamsız bir şifre, ham metrik-id sızıntısıyla AYNI sınıf. Bu kalıbı
  // buraya koymanın sebebi bir varsayım değil: `(L-006)` config'in
  // `excluded[].reason` metninin sonunda duruyordu ve SİMÜLATÖR EKRANINDA
  // "What Lissom doesn't do" sayfasında görüldü (L-223). Testlerin hiçbiri
  // görmedi — metnin VARLIĞINI sınıyorlardı, İÇERİĞİNİ değil.
  (
    r'\((?:L|G|J|O|M-F|M-[A-Z])-\d{2,3}\)',
    'dahili defter atfı yüzeye sızdı — kayıt config alanında kalır, metinde değil',
  ),
];

/// **TERS NEGATİF İKİZ (L-248).** Kapı FAZLA GENİŞLERSE ölecek cümleleri
/// sınar — ve o cümleler **çağırandan gelir, buraya KOPYALANMAZ.**
///
/// Bugüne kadarki ikizler *"düzeltme kaldırılırsa kırılır mı"* diye soruyordu;
/// bu ikiz **kapının kendisi genişlerse** kırılır. Gerekçesi ölçülmüş: fazla
/// geniş kapı bu depoda iki kez ödendi (L-237 `rose`→`roseDeepHover`,
/// L-246 `will not`) ve iki kez de kapıyı geri daraltan şey bir ölçüm değil
/// **insanın fark etmesiydi**. İkiz o refleksi mekanikleştirir.
///
/// > **Her dar kapı, darlığını koruyan bir ikiz taşımalı.**
///
/// ⚠️ **Cümleler parametre, sabit DEĞİL.** Buraya kopyalansalardı üründen
/// ayrışırlar ve ikiz artık var olmayan bir metni korurdu — bu dosyanın
/// yasakladığı ikiz-sınıfının ta kendisi. Çağıran onları config'ten ve
/// köprüden TÜRETİR.
///
/// Risk somut: defter-atfı deseni bir gün *"parantez içi her şey"*e
/// genişlerse **gerçek gerekçelerin yarısı ölür** — bu ürünün en dürüst
/// cümleleri parantez içinde açıklama taşıyor.
void expectGateStaysNarrow(Iterable<String> liveSentences) {
  final List<String> all = liveSentences.toList(growable: false);
  expect(all.length, greaterThanOrEqualTo(3),
      reason: 'TERS İKİZ BOŞ: çağıran yeterli canlı cümle veremedi — ikiz '
          'hiçbir şeyi korumuyor (L-183)');
  for (final String s in all) {
    for (final (Pattern p, String why) in kBannedSurfaceCopy) {
      expect(RegExp(p as String, caseSensitive: false).hasMatch(s), isFalse,
          reason: 'KAPI FAZLA GENİŞ ($why): üründe CANLI olan bu cümle '
              'yakalandı — «$s»');
    }
  }
}

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
