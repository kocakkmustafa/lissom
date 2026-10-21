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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_palette.dart';
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
  // ⚠️ Bu ikisi kapıya SONRADAN eklendi (L-236): `battery_summary_view` içinde
  // HAM `Color(0x…)` olarak gömülüydüler ve kapı onları hiç ölçmedi. Geçtiler
  // (5,56 / 5,43) — ama bu ŞANStı, kapı değildi.
  ('kart gradyanı sıcak uç', LissomColors.cardWarmEnd),
  ('kart gradyanı nötr uç', LissomColors.cardNeutralEnd),
];

/// Metin/ikon rengi olarak kullanılan token'lar — **ön plan** tarafı.
const List<(String, Color)> _foregrounds = <(String, Color)>[
  ('ink', LissomColors.ink),
  ('bodySecondary', LissomColors.bodySecondary),
  ('roseDeepHover', LissomColors.roseDeepHover),
];

/// Ne zemin ne ön plan — dolgu/süs. **Metin olarak KULLANILMAZ**, o yüzden
/// metin eşiği yok. Kova bir MUAFİYET değil bir SINIFLANDIRMA: aşağıdaki
/// kaynak taraması bu sınıflandırmanın doğru kaldığını sınıyor.
const List<String> _decorativeTokens = <String>[
  'rose', 'mist', 'mistDeep', 'labelMuted', 'metaMono',
];

/// Dolgu/çizgi/ikon olarak meşru — metin eşiğine tabi değil.
const List<String> _fillTokens = <String>['roseDeep', 'hairline'];

/// **Beyaz metin TAŞIYAN dolgular.** Kova bir muafiyet değil, bir SÖZLEŞME:
/// buraya konan her token, beyazla **4,5:1**'i geçmek ZORUNDA.
///
/// `_fillTokens`a koymak yanlış olurdu — o kova *"metin eşiğine tabi değil"*
/// diyor, oysa bunlar tam olarak tabi. Yanlış kova, sessiz bir muafiyettir.
const List<(String, Color)> _whiteTextFills = <(String, Color)>[
  ('fillForWhiteText', LissomColors.fillForWhiteText),
];

/// Beyan kartı (cream→peach) **genel listede DEĞİL** ve bu bir muafiyet değil
/// bir OLGU: peach ucunda hiçbir gövde/vurgu tonu 4.5'e çıkmıyor (ölçüldü —
/// `bodySecondary` bile 3,76). O kart bu yüzden metnini `ink` ile çiziyor ve
/// aşağıdaki test bunu YAPISAL olarak sınıyor: "peach'te ink kullanılıyor mu"
/// sorusu, "her stil peach'te geçsin mi" sorusundan farklı ve doğrudur —
/// ikincisi hiç render edilmeyen bir kombinasyonu ölçerdi.
const Color _bannerDarkEnd = LissomColors.peach;

// Runtime palette inventory and semantic pairs supplement the legacy light gate.
Map<String, Color> _runtimeTokens(LissomPalette p) => <String, Color>{
  'canvas': p.canvas,
  'card': p.card,
  'cardWarmEnd': p.cardWarmEnd,
  'cardNeutralEnd': p.cardNeutralEnd,
  'screenStart': p.screenStart,
  'screenMiddle': p.screenMiddle,
  'screenEnd': p.screenEnd,
  'textPrimary': p.textPrimary,
  'textSecondary': p.textSecondary,
  'accentText': p.accentText,
  'brandSeed': p.brandSeed,
  'primaryFill': p.primaryFill,
  'primaryHover': p.primaryHover,
  'primaryPressed': p.primaryPressed,
  'onPrimary': p.onPrimary,
  'secondary': p.secondary,
  'secondaryContainer': p.secondaryContainer,
  'onSecondaryContainer': p.onSecondaryContainer,
  'bannerStart': p.bannerStart,
  'bannerEnd': p.bannerEnd,
  'onBanner': p.onBanner,
  'outline': p.outline,
  'divider': p.divider,
  'focusRing': p.focusRing,
  'disabledSurface': p.disabledSurface,
  'disabledForeground': p.disabledForeground,
  'error': p.error,
  'errorContainer': p.errorContainer,
  'onErrorContainer': p.onErrorContainer,
  'markerFill': p.markerFill,
  'onMarker': p.onMarker,
  'selection': p.selection,
  'onSelection': p.onSelection,
  'shadow': p.shadow,
  'onError': p.onError,
};
const _runtimeBackgrounds = <String>[
  'canvas', 'card', 'cardWarmEnd', 'cardNeutralEnd',
  'screenStart', 'screenMiddle', 'screenEnd',
];
final _runtimeTextPairs = <(String, String)>[
  for (final fg in <String>['textPrimary', 'textSecondary', 'accentText'])
    for (final bg in _runtimeBackgrounds) (fg, bg),
  for (final bg in <String>[
    'primaryFill', 'primaryHover', 'primaryPressed', 'secondary',
  ]) ('onPrimary', bg),
  ('onSecondaryContainer', 'secondaryContainer'),
  ('onBanner', 'bannerStart'), ('onBanner', 'bannerEnd'),
  ('disabledForeground', 'disabledSurface'), ('onError', 'error'),
  ('onErrorContainer', 'errorContainer'), ('onMarker', 'markerFill'),
  ('onSelection', 'selection'),
  for (final bg in _runtimeBackgrounds) ('error', bg),
];
final _rawColor = RegExp(r'\bColor\s*\(\s*0x[0-9A-Fa-f]{8}\s*\)');

// Return only source outside the fully inventoried light/dark definitions.
String _outsideRuntimePaletteDefinitions(String source) {
  final declared = RegExp(r'\bfinal\s+Color\s+(\w+)\s*;')
      .allMatches(source).map((m) => m.group(1)!).toSet();
  final classified = <String>{
    ..._runtimeTextPairs.expand((p) => <String>[p.$1, p.$2]),
    'outline', 'focusRing', 'brandSeed', 'divider', 'shadow',
  };
  expect(declared.length, greaterThan(8), reason: 'runtime palette source read');
  expect(declared.difference(classified), isEmpty,
      reason: 'runtime token has no contrast or decorative role');
  expect(classified.difference(declared), isEmpty,
      reason: 'runtime role has no palette field');
  for (final p in <LissomPalette>[LissomPalette.light, LissomPalette.dark]) {
    expect(_runtimeTokens(p).keys.toSet(), declared);
  }
  final blocks = RegExp(
    r'\bstatic\s+const\s+LissomPalette\s+(light|dark)\s*=\s*LissomPalette\(([\s\S]*?)\n\s*\);',
  ).allMatches(source).toList();
  expect(blocks, hasLength(2));
  expect(blocks.map((m) => m.group(1)).toSet(), <String>{'light', 'dark'});
  for (final block in blocks) {
    final entries = RegExp(
      r'\b(\w+)\s*:\s*Color\s*\(\s*0x[0-9A-Fa-f]{8}\s*\)',
    ).allMatches(block.group(2)!).toList();
    expect(entries, hasLength(declared.length));
    expect(entries.map((m) => m.group(1)!).toSet(), declared);
  }
  var residue = source;
  for (final block in blocks.reversed) {
    residue = residue.replaceRange(block.start, block.end, '');
  }
  return residue;
}

void main() {
  test('runtime light/dark palette roles preserve AA contrast', () {
    final residue = _outsideRuntimePaletteDefinitions(
      File('lib/app/lissom_palette.dart').readAsStringSync(),
    );
    expect(_rawColor.hasMatch(residue), isFalse,
        reason: 'raw color outside inventoried palette definitions');
    for (final (mode, palette) in <(String, LissomPalette)>[
      ('light', LissomPalette.light), ('dark', LissomPalette.dark),
    ]) {
      final colors = _runtimeTokens(palette);
      for (final (fg, bg) in _runtimeTextPairs) {
        expect(contrastRatio(colors[fg]!, colors[bg]!),
            greaterThanOrEqualTo(Wcag.normalText),
            reason: '$mode $fg/$bg: normal-text threshold remains 4.5');
      }
      for (final fg in <String>['outline', 'focusRing']) {
        for (final bg in _runtimeBackgrounds) {
          expect(contrastRatio(colors[fg]!, colors[bg]!),
              greaterThanOrEqualTo(Wcag.nonText),
              reason: '$mode $fg/$bg non-text contrast');
        }
      }
    }
  });


  test('BEYAZ METİN TAŞIYAN dolgular WCAG AA geçer — sınıf, örnek değil', () {
    // J-151/L-264: kusuru bulduğun yerde düzeltmek, sınıfı düzeltmek değil.
    // Birincil butonun dolgusu beyazla 3,66:1'di (13,5px normal metin için
    // eşik 4,5) ve sekme turu açılır açılmaz yakaladı. Bu kapı ÖRNEĞİ değil
    // SINIFI tutuyor: beyaz metin taşıyan her dolgu buradan geçer.
    expect(_whiteTextFills, isNotEmpty, reason: 'pozitif çapa: kova boş');
    for (final (String name, Color fill) in _whiteTextFills) {
      final double r = contrastRatio(const Color(0xFFFFFFFF), fill);
      expect(r, greaterThanOrEqualTo(4.5),
          reason: '$name beyaz metinle ${r.toStringAsFixed(2)}:1 veriyor. '
              'Eşik 4,5 — İCAT DEĞİL, WCAG 2.2 AA normal metin. Dolguyu '
              'koyulaştırın ya da o yüzeyde beyaz metin kullanmayın.');
    }
  });

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

  test('BÜTÜNLÜK: paletteki HER token bir kovada — kapı kendi eksiğini görür',
      () {
    // ⚠️ **L-236, JabLab J-116 aktarımı: "örüntüyü değil örneği düzeltmek."**
    //
    // Bu kapının zemin listesi ELLE yazılmıştı ve iki kart-gradyanı ucunu
    // hiç içermiyordu — onlar `battery_summary_view` içinde ham `Color(0x…)`
    // olarak gömülüydü. Kapı yeşil yanıyordu çünkü BAKMADIĞI bir yer vardı.
    //
    // Çözüm listeyi uzatmak DEĞİL (aynı hata yarın yeni bir token'la döner):
    // palet KAYNAKTAN okunuyor ve her token üç kovadan birine girmek ZORUNDA.
    // Yeni bir renk eklenip kovalanmazsa bu test kırmızı yanar — yani kapı
    // artık kendi eksikliğini görebiliyor.
    final String src =
        File('lib/app/lissom_theme.dart').readAsStringSync();
    final Set<String> declared = RegExp(r'static const Color (\w+)')
        .allMatches(src)
        .map((RegExpMatch m) => m.group(1)!)
        .toSet();
    expect(declared.length, greaterThan(8), reason: 'pozitif kontrol: palet '
        'kaynaktan okundu (${declared.length} token)');

    // Kovalar listelerden TÜRETİLİR — elle yazılmış ikinci bir küme, kapının
    // düzeltmeye çalıştığı hatanın aynısını üretirdi.
    final Set<String> bucketed = <String>{
      'card', 'canvas', 'cream', 'peach', 'cardWarmEnd', 'cardNeutralEnd',
      ..._foregrounds.map(((String, Color) e) => e.$1),
      ..._decorativeTokens,
      ..._whiteTextFills.map(((String, Color) t) => t.$1),
      ..._fillTokens,
    };
    expect(declared.difference(bucketed), isEmpty,
        reason: 'KOVASIZ token — kontrast kapısı onu hiç ölçmez:\n'
            '${declared.difference(bucketed).join(", ")}');
    expect(bucketed.difference(declared), isEmpty,
        reason: 'kovada olup palette OLMAYAN token (yeniden adlandırılmış ya '
            'da silinmiş — yetim kova girdisi):\n'
            '${bucketed.difference(declared).join(", ")}');

    // Süs kovası bir SINIFLANDIRMA: oradaki token metin olarak kullanılırsa
    // kapı susar. O yüzden kaynağı da tarıyoruz.
    //
    // ⚠️ SINIR EŞLEŞMESİ ŞART — ilk yazımım sınırsız `contains` ile
    // arıyordu ve `rose` deseni `roseDeepHover`u da eşliyordu: kapı KENDİ
    // testinde yanlış-pozitif üretti, ve bunu ancak koşunca gördüm.
    // Tanımlayıcı eşleşmesi harf sınırı ister.
    final String uses = Directory('lib/app')
        .listSync()
        .whereType<File>()
        .map((File f) => f.readAsStringSync())
        .join('\n');
    // POZİTİF İKİZ (L-255): desen GERÇEKTEN eşleşiyor mu? Bu bir YOKLUK
    // iddiası — bozuk bir desenle de sonsuza kadar geçer.
    // The product now uses ThemeExtension colors. Preserve a real-source
    // anchor and explicit positive/negative controls for the legacy guard.
    expect(RegExp(
      r'\bcolor\s*:\s*(?:p|LissomPalette\.(?:of|fromTheme)\([^)]*\))\s*\.\s*textSecondary(?![A-Za-z0-9_])',
    ).hasMatch(uses), isTrue, reason: 'actual runtime secondary text use exists');
    final legacyProbe = RegExp(r'color:\s*LissomColors\.rose(?![A-Za-z0-9_])');
    expect(legacyProbe.hasMatch('color: LissomColors.rose'), isTrue);
    expect(legacyProbe.hasMatch('color: LissomColors.roseDeepHover'), isFalse);

    // The runtime brand seed is not a foreground color. Divider and shadow
    // keep their legitimate non-text color uses.
    final runtimeSeedAsColor = RegExp(
      r'\bcolor\s*:\s*(?:p|LissomPalette\.(?:of|fromTheme)\([^)]*\))\s*\.\s*brandSeed(?![A-Za-z0-9_])',
    );
    expect(runtimeSeedAsColor.hasMatch(
        'color: LissomPalette.of(context).brandSeed'), isTrue);
    expect(runtimeSeedAsColor.hasMatch('color: p.brandSeed'), isTrue);
    expect(runtimeSeedAsColor.hasMatch('seedColor: p.brandSeed'), isFalse);
    expect(runtimeSeedAsColor.hasMatch('color: p.brandSeedExtra'), isFalse);
    expect(runtimeSeedAsColor.hasMatch(uses), isFalse,
        reason: 'runtime brand seed must not replace a readable foreground');

    for (final String token in _decorativeTokens) {
      final RegExp asColor =
          RegExp('color:\\s*LissomColors\\.$token(?![A-Za-z0-9_])');
      expect(asColor.hasMatch(uses), isFalse,
          reason: '$token METİN rengi olarak kullanılmış — süs kovasında '
              'olmasının anlamı "metin eşiği yok" idi');
    }
  });

  test('HAM RENK YASAĞI: her renk kovalı paletten geçer', () {
    // ⚠️ Bu, bütünlük kapısının ÖN KOŞULU ve bugüne kadar yalnız ELLE
    // doğrulanmıştı (L-247). Palet bütünlüğü "her token bir kovada" diyor —
    // ama bir yüzey `Color(0xFF…)` yazarsa o renk hiçbir kovada DEĞİLDİR ve
    // kapı onu hiç görmez. Nitekim iki kart-gradyanı ucu tam böyle gizlenmişti
    // (L-236). Elle kontrol bir kapı değildir.
    expect(_rawColor.hasMatch('Color(0xFFFFFFFF)'), isTrue);
    expect(_rawColor.hasMatch('Color ( 0xFFFFFFFF )'), isTrue);
    expect(_rawColor.hasMatch('Colorful(0xFFFFFFFF)'), isFalse);
    final List<String> raw = <String>[];
    for (final FileSystemEntity f in Directory('lib/app').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('lissom_theme.dart')) continue; // paletin evi
      String src = File(f.path)
          .readAsStringSync()
          .replaceAll(RegExp(r'//[^\n]*'), ' ');
      if (f.path.endsWith('lissom_palette.dart')) {
        src = _outsideRuntimePaletteDefinitions(src);
      }
      for (final RegExpMatch m in _rawColor.allMatches(src)) {
        raw.add('${f.uri.pathSegments.last}: ${m.group(0)}');
      }
    }
    expect(raw, isEmpty,
        reason: 'ham renk kovasız kalır ve kontrast kapısı onu HİÇ ölçmez — '
            'palete token olarak ekleyin:\n${raw.join("\n")}');
  });

  test('HİYERARŞİ ÜST SINIRI: okunurluk uğruna ayrım feda edilmemiş', () {
    // Kontrastı yükseltmenin ucuz yolu HER ŞEYİ koyulaştırmaktır — o da
    // birincil ↔ ikincil ayrımını yok eder. Bu üründe o ayrım bir MESAJ
    // taşıyor: "bu bir hüküm değil, bir ölçüm."
    //
    // Alt sınır okunurluk (diğer testler), ÜST sınır hiyerarşi (bu test).
    final double primary =
        contrastRatio(LissomColors.ink, LissomColors.card);
    final double secondary =
        contrastRatio(LissomColors.bodySecondary, LissomColors.card);
    expect(secondary, greaterThanOrEqualTo(Wcag.normalText),
        reason: 'alt sınır: ikincil metin okunmalı');
    expect(primary / secondary, greaterThan(2.0),
        reason: 'üst sınır: birincil ile ikincil arasında en az 2× ayrım '
            'olmalı — yoksa okunurluk uğruna hiyerarşi feda edilmiş demektir '
            '(ölçülen: ${(primary / secondary).toStringAsFixed(2)}×)');
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
