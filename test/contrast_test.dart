/// **Kontrast kapısı (L-234).** Bu depoda daha önce HİÇ kontrast ölçülmemişti.
///
/// Ölçüm neyi buldu (düzeltmeden önce):
///
/// | yüzey | oran | eşik |
/// |---|---|---|
/// | ölçüm-sınırı beyanı (gradyan üstünde) | **2.01** | 4.5 |
/// | hüküm sınırı + engel gerekçesi | **2.57** | 4.5 |
/// | sönük iddia metni · eyebrow | **2.94** | 4.5 |
/// | `videocam_off` / `block` ikonu | **2.94** | 3.0 |
/// | `roseDeep` metin olarak | **3.58** | 4.5 |
///
/// En acısı sonuncudan değil ilkinden geliyordu: **açık ihlal ⑱'in kapanışı
/// olan beyan, uygulamanın en okunmaz metniydi.** Oradaydı, doğruydu ve
/// 2,01:1'di. *"Görünmeyen bir dürüst hâl, susmakla aynı şeydir."*
///
/// ## Düzeltme neden palet DEĞİŞTİRMEDİ
///
/// Ölçüldü: 12,5px metni 4.5'e çıkarmak, `metaMono`yu da `labelMuted`i de
/// **~#6C626B**'ye taşıyor — yani `bodySecondary`'ye (#6B6069). Üç token TEK
/// renge çöküyor. Yani "WCAG-uyumlu sönük" bu palette *body rengiyle aynı
/// şey*; sönüklüğü luminansla taşıyan hiyerarşi bu zeminle mümkün değil.
///
/// Palet İCAT ETMEK yerine **doğru token seçildi**: anlam taşıyan her metin ve
/// ikon `bodySecondary` kullanıyor, okunmaz iki token yalnız tanımda kalıyor.
/// Bunu yapabilmemin sebebi ölçülmüş: **anlam renge bağlı değil** — canlı/ölü
/// ayrımını ikon (`videocam_off`) ve açık sözcük (*"Not in this build ·"*)
/// taşıyor (WCAG 1.4.1). Sönüklük estetikti; estetik de-emphasis okunmazlığa
/// dönüştüğünde bir kusurdur.
///
/// **Koordinatöre giden kısım:** dört-katman ayrımının görsel yükü artık
/// yalnız ikon+sözcükte. Tasarım dili için daha koyu bir "muted" ton isteniyorsa
/// o bir tasarım yönü kararı.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/surfaces.dart';

import 'support/contrast.dart';

/// Ekranın gradyan zemini üç durak taşıyor; **en koyu durak en zor zemindir**
/// ve metin orada da okunmalı. Yalnız kart zemininde ölçmek, gerçek en-kötü
/// hâli atlardı — kart DIŞINDA çizilen dipnot tam olarak orada yaşıyor.
const List<(String, Color)> _backgrounds = <(String, Color)>[
  ('kart', LissomColors.card),
  ('gradyan-baş', Color(0xFFFBF3EE)),
  ('gradyan-orta', Color(0xFFF5E8E4)),
  ('gradyan-son (EN KOYU)', Color(0xFFEEDDE7)),
  ('canvas', LissomColors.canvas),
];

/// Beyan kartı (cream→peach) **genel listede DEĞİL** ve bu bir muafiyet değil
/// bir OLGU: peach ucunda hiçbir gövde/vurgu tonu 4.5'e çıkmıyor (ölçüldü —
/// `bodySecondary` bile 3,76). O kart bu yüzden metnini `ink` ile çiziyor ve
/// aşağıdaki test bunu YAPISAL olarak sınıyor: "peach'te ink kullanılıyor mu"
/// sorusu, "her stil peach'te geçsin mi" sorusundan farklı ve doğrudur —
/// ikincisi hiç render edilmeyen bir kombinasyonu ölçerdi.
const Color _bannerDarkEnd = LissomColors.peach;

void main() {
  // ⚠️ Aile gotcha'sının ÜÇÜNCÜ yüzü: `buildLissomTheme()` `google_fonts`
  // çağırıyor, o da `ServicesBinding.instance` istiyor. Temayı `main()`in
  // TEPESİNDE (binding kurulmadan) kurmak "Binding has not yet been
  // initialized" ile patlıyor — ve hata mesajı yazı tipinden bahsettiği için
  // kolayca "font sorunu" sanılıyor. Sorun sıralama.
  // ⚠️ Aile gotcha'sının ÜÇÜNCÜ yüzü, ve en sinsi olanı: `buildLissomTheme()`
  // `google_fonts` çağırıyor. `main()`in gövdesinde (test DIŞINDA) kurmak
  // dosyayı YÜKLENİRKEN patlatıyor ve hata "font yüklenemedi" dediği için
  // kolayca bir yazı-tipi sorunu sanılıyor — oysa sorun SIRALAMA: binding
  // yalnız bir test gövdesinin içinde hazır. O yüzden tema `testWidgets`
  // içinde kuruluyor.
  testWidgets('anlam taşıyan HER metin rengi WCAG eşiğini geçer',
      (WidgetTester tester) async {
    final ThemeData theme = buildLissomTheme();
    final Map<String, TextStyle?> used = <String, TextStyle?>{
      'bodyLarge': theme.textTheme.bodyLarge,
      'bodyMedium (gövde)': theme.textTheme.bodyMedium,
      'bodySmall (gerekçe/dipnot)': theme.textTheme.bodySmall,
      'titleMedium': theme.textTheme.titleMedium,
      'titleSmall': theme.textTheme.titleSmall,
      'labelLarge (eyebrow)': theme.textTheme.labelLarge,
      'labelSmall': theme.textTheme.labelSmall,
      'headlineSmall': theme.textTheme.headlineSmall,
      'headlineLarge': theme.textTheme.headlineLarge,
    };
    expect(used.values.every((TextStyle? s) => s != null), isTrue,
        reason: 'pozitif kontrol: tema stilleri okundu');

    final List<String> fails = <String>[];
    for (final MapEntry<String, TextStyle?> e in used.entries) {
      final TextStyle s = e.value!;
      final double th = Wcag.forText(
          s.fontSize ?? 14, s.fontWeight ?? FontWeight.w400);
      for (final (String bgName, Color bg) in _backgrounds) {
        final ContrastPair p = ContrastPair(
            where: '${e.key} @ $bgName', fg: s.color!, bg: bg, threshold: th);
        if (!p.passes) fails.add(p.report);
      }
    }
    expect(fails, isEmpty,
        reason: 'okunmayan metin rengi — "görünmeyen bir dürüst hâl, '
            'susmakla aynı şeydir":\n${fails.join("\n")}');
  });

  test('ANLAM TAŞIYAN ikonlar metin-dışı eşiği (3.0) geçer', () {
    // `videocam_off` (iddia canlı değil) · `block` (test ölçülemiyor) ·
    // `remove_circle_outline` (ölçülmeyenler) · `chevron_right` (gezinme) —
    // dördü de DURUM taşıyor, süs değil. JabLab'ın vakası tam buydu.
    final List<String> fails = <String>[];
    for (final (String bgName, Color bg) in _backgrounds) {
      final ContrastPair p = ContrastPair(
          where: 'durum ikonu @ $bgName',
          fg: LissomColors.bodySecondary,
          bg: bg,
          threshold: Wcag.nonText);
      if (!p.passes) fails.add(p.report);
    }
    expect(fails, isEmpty, reason: fails.join('\n'));
  });

  test('birincil renk METİN olarak kullanılmaz — vurgu tonu kullanılır', () {
    // Ölçüldü: `roseDeep` #B0748F kart üstünde 3.58 → normal metin eşiğini
    // GEÇMİYOR. `roseDeepHover` #8E5A73 ise 5.33. İkisi de palette zaten var;
    // eksik olan hangisinin METİN olduğuydu.
    expect(contrastRatio(LissomColors.roseDeep, LissomColors.card),
        lessThan(Wcag.normalText),
        reason: 'bu iddia bir OLGU: roseDeep metin için yetersiz. Bir gün '
            'geçerse palet değişmiş demektir ve bu test onu haber verir');
    for (final (String bgName, Color bg) in _backgrounds) {
      expect(contrastRatio(LissomColors.roseDeepHover, bg),
          greaterThanOrEqualTo(Wcag.normalText),
          reason: 'vurgu METNİ okunmuyor @ $bgName');
    }
  });

  test('KAPI KIRMIZI YANABİLİYOR — sabotaj', () {
    // Yeşil bir kapı, kırmızı yanabildiğini göstermedikçe hiçbir şey
    // kanıtlamaz. Eski (düzeltilmeden önceki) renkler hâlâ eşiğin altında
    // kalmalı; kalmıyorsa ölçüm bozulmuş demektir.
    const Color oldMetaMono = Color(0xFFA79DA5);
    const Color oldLabelMuted = Color(0xFF9C929B);
    expect(contrastRatio(oldMetaMono, const Color(0xFFEEDDE7)),
        lessThan(2.1),
        reason: 'ölçüm hattı bozulmuş — eski dipnot rengi 2.01 vermeliydi');
    expect(contrastRatio(oldLabelMuted, LissomColors.card),
        lessThan(Wcag.normalText));
  });

  testWidgets('BEYAN KARTI metnini `ink` ile çizer — peach ucu için TEK geçen',
      (WidgetTester tester) async {
    // Yapısal iddia, konumsal değil: "eyebrow cream ucunda durur" demek
    // kartın düzeni değişince sessizce yanlışlaşırdı.
    expect(contrastRatio(LissomColors.ink, _bannerDarkEnd),
        greaterThanOrEqualTo(Wcag.normalText),
        reason: 'ink peach ucunda da geçmeli — geçmezse kartın zemini '
            'değişmiş demektir');
    expect(contrastRatio(LissomColors.bodySecondary, _bannerDarkEnd),
        lessThan(Wcag.normalText),
        reason: 'bu bir OLGU: peach ucu gövde tonu için fazla koyu. Bir gün '
            'geçerse zemin açılmış demektir ve bu satır haber verir');

    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: const Scaffold(
        body: DeclarationBanner(eyebrow: 'E', body: 'B'),
      ),
    ));
    await tester.pump();
    for (final Text w in tester.widgetList<Text>(find.byType(Text))) {
      final Color? c = w.style?.color;
      expect(c, LissomColors.ink,
          reason: 'beyan kartında `ink` dışında bir renk: $c — peach ucunda '
              'okunmaz');
    }
  });

  test('alfa ZEMİNE bindirilir — saydam rengin kendi parlaklığı ölçülmez', () {
    // Yöntem kuralı: yarı saydam bir rengin kendi parlaklığını ölçmek,
    // ekranda hiç var olmayan bir pikseli ölçmektir.
    const Color half = Color(0x80000000); // %50 siyah
    const Color white = Color(0xFFFFFFFF);
    expect(over(half, white).r, closeTo(0.5, 0.01));
    // Bindirmeseydik siyah/beyaz = 21:1 çıkardı; gerçek piksel ~%50 gri.
    expect(contrastRatio(half, white), lessThan(6.0));
    expect(contrastRatio(half, white), greaterThan(3.0));
  });
}
