/// Bilgi mimarisi okuyucusu — `config/ia/library.v1.json`.
///
/// **Neden bir okuyucu, elle yazılmış bir sabit DEĞİL:** sekmeler, aileler ve
/// dürüstlük kutuları config'te ZATEN var. Onları Dart'a kopyalamak, ailenin
/// "türetimli listeler elle yazılmaz" kuralının doğrudan ihlali olurdu ve
/// `reps`/`aggregation` ailesinin (L-178/L-181) tuzağını tekrarlardı: config
/// değişir, kod bayatlar, kimse fark etmez.
///
/// **Okuyucu KATI** (`Battery.parseJson` emsali): beklemediğini sessizce
/// yutmaz. Özellikle iki kural yapısal olarak zorlanır —
///
///   1. **Her ailenin `honestyBox`'ı ZORUNLU.** Config'in kendi notu böyle
///      diyor ("Bu kutu opsiyonel değil"), ama bir NOT hiçbir şeyi zorlamaz.
///      Burada zorlanıyor: kutusuz bir aile config'e girerse okuyucu ADIYLA
///      reddeder — yani dürüstlük kutusu olmayan bir aile ekranı ÜRETİLEMEZ.
///   2. **`honestyBox.notMeasured` boş olamaz.** "Neler ölçülmez" boş bir
///      liste, kutuyu bir dürüstlük beyanından bir pazarlama kutusuna çevirir.
///
/// ⛔ **`status` bir MAKİNE değeridir, kullanıcı metni DEĞİL.** Config'te
/// `coming_soon` yazıyor; bu dize yüzeye ASLA çıkmaz (M-F-186: vaat dili
/// yasak). Yüzey, ailenin ne olduğunu ve NEYİN eksik olduğunu söyler — ne
/// zaman geleceğini değil. [FamilyStatus] bu ayrımı tip düzeyinde tutar.
library;

import 'dart:convert';

final class IaError implements Exception {
  IaError(this.path, this.message);
  final String path;
  final String message;
  @override
  String toString() => 'IaError($path: $message)';
}

/// Bir ailenin durumu — **makine değeri.** Yüzeye çıkan metin bu enum'dan
/// değil, ailenin kendi içeriğinden türer.
enum FamilyStatus {
  /// Bu ailenin içeriği bu derlemede ÇALIŞIR.
  inProgress,

  /// İçerik bu derlemede YOK. (Config'in `coming_soon` değeri — ismi bilerek
  /// farklı: `comingSoon` diye bir Dart sembolü bırakmak, o dizenin bir gün
  /// bir `Text()` içine düşmesini kolaylaştırırdı.)
  notBuilt,

  /// Sayfa var ve gezilebilir (ör. `whyNotPage`).
  available;

  static FamilyStatus parse(String path, String raw) => switch (raw) {
        'in_progress' => FamilyStatus.inProgress,
        'coming_soon' => FamilyStatus.notBuilt,
        'available' => FamilyStatus.available,
        _ => throw IaError(path, 'bilinmeyen status: $raw'),
      };
}

/// Ne ölçülür / ne ölçülmez. **İkisi de zorunlu ve ikisi de boş olamaz.**
final class HonestyBox {
  const HonestyBox({required this.measured, required this.notMeasured});
  final List<String> measured;
  final List<String> notMeasured;
}

final class FamilyChild {
  const FamilyChild({
    required this.id,
    required this.title,
    required this.status,
    this.deepLink,
  });
  final String id;
  final String title;
  final FamilyStatus status;

  /// Kardeş app'e köprü (`jablab` · `choreia` · `gravita`). Bugün hiçbir
  /// yüzey bunu TIKLANABİLİR yapmıyor — köprü kodu yok. Alan yine de okunur
  /// ki beyan kayıtsız kalmasın (`configFrameRef` emsali: bilgi taşıyan
  /// alana okuyucu verilir, süs olarak bırakılmaz).
  final String? deepLink;
}

final class LibraryFamily {
  const LibraryFamily({
    required this.id,
    required this.title,
    required this.status,
    required this.intro,
    required this.children,
    required this.honestyBox,
    required this.itemsSource,
  });

  final String id;
  final String title;
  final FamilyStatus status;
  final String intro;
  final List<FamilyChild> children;
  final HonestyBox honestyBox;

  /// Dolu ise ailenin öğeleri BAŞKA bir config'ten türer (batarya deseni).
  /// Boş ise ailenin öğeleri yalnız [children] olarak İSİMLENDİRİLMİŞTİR —
  /// isimlendirilmiş ≠ inşa edilmiş.
  final String? itemsSource;

  bool get isBuilt => status == FamilyStatus.inProgress;

  /// **Dürüst tek satırlık durum (§5.4).** Sayı config'ten TÜRETİLİR: kaç yol
  /// İSİMLENDİRİLMİŞ. "Yakında N kurs" demez — *"N yol isimlendirildi, hiçbiri
  /// bu derlemede yok"* der. İkisi arasındaki fark, vaat ile envanterin farkı.
  ///
  /// Çocuğu olmayan aile için sayı UYDURULMAZ; o zaman satır yalnız yokluğu
  /// söyler.
  String get inventoryLine {
    if (isBuilt) {
      return itemsSource != null
          ? 'Runs in this build.'
          : 'Runs in this build.';
    }
    if (children.isEmpty) {
      return 'Named, not in this build — no sessions are bundled with the app.';
    }
    final int n = children.length;
    return '$n named · none in this build.';
  }
}

final class HomeSection {
  const HomeSection({
    required this.id,
    required this.title,
    required this.source,
  });
  final String id;
  final String title;

  /// Bölümün beslendiği kaynak (`program_engine` · `assessment_cycle` ·
  /// `last_session` · `shortcuts`). **Bu ad yüzeye ÇIKMAZ** — dahili sözlük
  /// (ham metrik-id sızıntısının aynı sınıfı). Yüzey, kaynağın var olup
  /// olmadığının SONUCUNU gösterir.
  final String source;
}

final class WhyNotItem {
  const WhyNotItem({required this.topic, required this.reason});
  final String topic;
  final String reason;
}

final class LibraryIa {
  const LibraryIa({
    required this.tabs,
    required this.homeSections,
    required this.families,
    required this.whyNot,
  });

  final List<String> tabs;
  final List<HomeSection> homeSections;
  final List<LibraryFamily> families;
  final List<WhyNotItem> whyNot;

  List<LibraryFamily> get built =>
      families.where((LibraryFamily f) => f.isBuilt).toList(growable: false);
  List<LibraryFamily> get notBuilt =>
      families.where((LibraryFamily f) => !f.isBuilt).toList(growable: false);

  static LibraryIa parseJson(String source) =>
      _parse(jsonDecode(source) as Object?);

  static LibraryIa _parse(Object? decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw IaError('<root>', 'nesne olmalı');
    }
    if (decoded['version'] is! String) {
      throw IaError('version',
          'sürüm beyan edilmemiş — sürümsüz config izlenemez (Battery emsali)');
    }

    final Object? rawTabs = decoded['tabs'];
    if (rawTabs is! List || rawTabs.isEmpty) {
      throw IaError('tabs', 'boş olmayan liste olmalı');
    }
    final List<String> tabs = <String>[
      for (final Object? t in rawTabs)
        t is String ? t : throw IaError('tabs', 'her sekme dize olmalı'),
    ];

    final Object? home = decoded['home'];
    if (home is! Map<String, dynamic>) throw IaError('home', 'nesne olmalı');
    final Object? rawSections = home['sections'];
    if (rawSections is! List || rawSections.isEmpty) {
      throw IaError('home.sections', 'boş olmayan liste olmalı');
    }
    final List<HomeSection> sections = <HomeSection>[];
    for (int i = 0; i < rawSections.length; i++) {
      final Object? s = rawSections[i];
      if (s is! Map<String, dynamic>) {
        throw IaError('home.sections[$i]', 'nesne olmalı');
      }
      sections.add(HomeSection(
        id: _str(s['id'], 'home.sections[$i].id'),
        title: _str(s['title'], 'home.sections[$i].title'),
        source: _str(s['source'], 'home.sections[$i].source'),
      ));
    }

    final Object? rawFamilies = decoded['families'];
    if (rawFamilies is! List || rawFamilies.isEmpty) {
      throw IaError('families', 'boş olmayan liste olmalı');
    }
    final List<LibraryFamily> families = <LibraryFamily>[];
    for (int i = 0; i < rawFamilies.length; i++) {
      families.add(_family(rawFamilies[i], 'families[$i]'));
    }

    final Object? why = decoded['whyNotPage'];
    if (why is! Map<String, dynamic>) {
      throw IaError('whyNotPage', 'nesne olmalı');
    }
    final Object? rawItems = why['items'];
    if (rawItems is! List || rawItems.isEmpty) {
      throw IaError('whyNotPage.items', 'boş olmayan liste olmalı');
    }
    final List<WhyNotItem> whyNot = <WhyNotItem>[];
    for (int i = 0; i < rawItems.length; i++) {
      final Object? it = rawItems[i];
      if (it is! Map<String, dynamic>) {
        throw IaError('whyNotPage.items[$i]', 'nesne olmalı');
      }
      whyNot.add(WhyNotItem(
        topic: _str(it['topic'], 'whyNotPage.items[$i].topic'),
        reason: _str(it['reason'], 'whyNotPage.items[$i].reason'),
      ));
    }

    return LibraryIa(
      tabs: tabs,
      homeSections: sections,
      families: families,
      whyNot: whyNot,
    );
  }

  static LibraryFamily _family(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) throw IaError(path, 'nesne olmalı');

    final List<FamilyChild> children = <FamilyChild>[];
    final Object? rawChildren = raw['children'];
    if (rawChildren != null) {
      if (rawChildren is! List) throw IaError('$path.children', 'liste olmalı');
      for (int i = 0; i < rawChildren.length; i++) {
        final Object? c = rawChildren[i];
        if (c is! Map<String, dynamic>) {
          throw IaError('$path.children[$i]', 'nesne olmalı');
        }
        children.add(FamilyChild(
          id: _str(c['id'], '$path.children[$i].id'),
          title: _str(c['title'], '$path.children[$i].title'),
          status: FamilyStatus.parse('$path.children[$i].status',
              _str(c['status'], '$path.children[$i].status')),
          deepLink: c['deepLink'] as String?,
        ));
      }
    }

    return LibraryFamily(
      id: _str(raw['id'], '$path.id'),
      title: _str(raw['title'], '$path.title'),
      status: FamilyStatus.parse('$path.status', _str(raw['status'], '$path.status')),
      intro: _str(raw['intro'], '$path.intro'),
      children: children,
      honestyBox: _honesty(raw['honestyBox'], '$path.honestyBox'),
      itemsSource: raw['itemsSource'] as String?,
    );
  }

  /// ZORUNLU — ve iki listesi de boş OLAMAZ.
  ///
  /// Bu, config notunun ("opsiyonel değil") tek uygulanabilir hâli. Bir NOT
  /// hiçbir şeyi engellemez; bir `throw` engeller. Dürüstlük kutusu olmayan
  /// bir aile, tanımı gereği ekrana çıkamaz.
  static HonestyBox _honesty(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      throw IaError(path,
          'ZORUNLU — dürüstlük kutusu olmayan aile yüzeye çıkamaz (IA config '
          'notu: "Bu kutu opsiyonel değil")');
    }
    final List<String> measured = _strList(raw['measured'], '$path.measured');
    final List<String> notMeasured =
        _strList(raw['notMeasured'], '$path.notMeasured');
    if (notMeasured.isEmpty) {
      throw IaError('$path.notMeasured',
          'boş olamaz — "neler ölçülmez" boş bir liste, dürüstlük kutusunu '
          'pazarlama kutusuna çevirir');
    }
    if (measured.isEmpty) {
      throw IaError('$path.measured', 'boş olamaz');
    }
    return HonestyBox(measured: measured, notMeasured: notMeasured);
  }

  static List<String> _strList(Object? raw, String path) {
    if (raw is! List) throw IaError(path, 'liste olmalı');
    return <String>[
      for (int i = 0; i < raw.length; i++)
        raw[i] is String
            ? raw[i] as String
            : throw IaError('$path[$i]', 'dize olmalı'),
    ];
  }

  static String _str(Object? raw, String path) =>
      raw is String && raw.trim().isNotEmpty
          ? raw
          : throw IaError(path, 'boş olmayan dize zorunlu');
}
