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

/// Dürüstlük kutusundaki TEK bir "şunu ölçüyoruz" iddiası — **ve dayanağı.**
///
/// **Neden düz metin DEĞİL (L-230, Ostinato O-040 aktarımı):** iddialar
/// prozayken kimse onları yetenekle karşılaştırmıyordu, ve ölçüldüğünde üç
/// iddianın **ikisi kabukta canlı değildi**:
///
///   - *"…sagittal and frontal planes (… trunk, shank)"* — `trunk_lean` ve
///     `tibia_inclination` köprülü DEĞİL; üstelik köprü uzayı `isotropic`
///     (görüntü düzlemi) olduğu için **"frontal plane" hiçbir metrik için
///     doğru değildi.**
///   - *"Hold duration and gross balance"* — `hold_duration` faz-türevi ve
///     köprü kapsamı dışında (L-220).
///
/// Yani **dürüstlük kutusu, uygulamanın en az dürüst yüzeyiydi.** Bir iddia
/// listesi, kendisini doğrulayan bir mekanizma olmadan bir pazarlama
/// listesinden ayırt edilemez.
///
/// Artık her iddia dayandığı metrikleri BEYAN eder ([requires]) ve kabuk onu
/// köprüye karşı doğrular: canlı olmayan iddia SİLİNMEZ (kapsamı saklamak
/// olurdu) — **isimli gerekçeyle sönük gösterilir**, tıpkı engelli testler
/// gibi. Gerekçe de köprünün KENDİ metninden gelir, ikinci kez yazılmaz.
final class HonestyClaim {
  const HonestyClaim({required this.claim, required this.requires});

  /// Kullanıcının okuduğu cümle.
  final String claim;

  /// İddianın dayandığı metrik id'leri. **İnşa edilmiş ailede boş olamaz** —
  /// dayanaksız bir "şunu ölçüyoruz" cümlesi, doğrulanamaz bir iddiadır.
  /// İnşa edilmemiş ailede boştur: orada zaten hiçbir şey canlı değil ve
  /// bunu aile düzeyindeki durum satırı söylüyor.
  final List<String> requires;

  bool get isCheckable => requires.isNotEmpty;
}

/// Bir "şunu ölçmüyoruz" satırı — ve varsa, onu YALANLAYACAK koşul.
final class NotMeasuredLine {
  const NotMeasuredLine({
    required this.claim,
    required this.falsifiedIfBridged,
  });

  final String claim;

  /// Bu satırı yalanlayacak metrikler. Biri köprüye girdiği an cümle YANLIŞ
  /// olur ve yeniden yazılmalıdır. Boş = satır bir ÜRÜN DURUŞU (klinik iddia
  /// yok, doğrulama çalışması yapılmadı) ve köprüyle ilgisi yok.
  final List<String> falsifiedIfBridged;
}

/// Ne ölçülür / ne ölçülmez. **İkisi de zorunlu ve ikisi de boş olamaz.**
final class HonestyBox {
  const HonestyBox({required this.measured, required this.notMeasured});

  /// Kanıt taşıyan iddialar.
  final List<HonestyClaim> measured;

  /// Sınırlar. Metin, ama **motor sınırı anan satır kanıt TAŞIR** (L-251).
  ///
  /// İlk tasarımda burası düz metindi ve gerekçem şuydu: *"bir şeyi
  /// ölçmediğimizi söylemek, ölçtüğümüzü söylemekle aynı ispat yükünü
  /// taşımaz."* Doğruydu ama EKSİKTİ (J-133 ölçütü):
  ///
  /// > **Bir cümle sevk edildiyse, onu yanlışa çevirecek en MAKUL
  /// > değişikliği sor. Makulse, kapı gerekir.**
  ///
  /// *"the measurement engine keeps a single tilt"* bugün doğru — ve
  /// **L-187 göçü tam onu değiştirecek.** O gün cümle yalan olur, ve kimse
  /// yalan söylemeye karar vermez: bir göç yapar. [NotMeasuredLine
  /// .falsifiedIfBridged] o metrikleri BEYAN eder; kapı biri köprüye girdiği
  /// an kırmızı yanar.
  final List<NotMeasuredLine> notMeasured;
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
    this.teachingOnly = false,
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

  /// Built guided course with no camera measurement claim.
  final bool teachingOnly;

  bool get isBuilt => status == FamilyStatus.inProgress;

  /// Sınır satırları — kanıt alanlarıyla birlikte.
  List<NotMeasuredLine> get notMeasuredLines => honestyBox.notMeasured;

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

/// Poz kütüphanesinin KOÇLUK KATMANI — ve neden o katmanda olduğu.
///
/// **Bu blok da okuyucusuz duruyordu (L-240)** ve bedeli ölçüldü: tier 3'ün
/// gerekçesi — *"pose models silently swap limb labels on inverted bodies
/// with high confidence"* (aile bulgusu M-019) — **hiçbir yüzeyde yoktu.**
/// Yoga ailesinin dürüstlük kutusu yalnız *"Inversions are demonstrated by
/// the avatar only"* diyordu: OLGU vardı, GEREKÇE yoktu. Oysa bu ailenin
/// tüm duruşu gerekçenin kendisi.
///
/// ⚠️ Sınıfın acı tarafı: bu okuyucuyu, "okuyucusuz config alanı" sınıfını
/// (L-219 `excluded` · L-220 `derivedMeasures`) kapatırken YAZDIM ve aynı
/// dosyada aynı sınıfı ürettim. Bir kusur sınıfını teşhis etmek, onu aynı
/// commit'te üretmene engel değil.
final class PoseTier {
  const PoseTier({
    required this.tier,
    required this.scope,
    required this.coaching,
    required this.scoredLabel,
    required this.reason,
  });

  final int tier;
  final String scope;

  /// `full` · `guided` · `avatar_demo_only` — MAKİNE değeri, yüzeye çıkmaz.
  final String coaching;

  /// `true` · `loose` · `false` — config bunu karışık tipte yazıyor, o yüzden
  /// dize olarak taşınıyor ve yüzey kendi cümlesini kurar.
  final String scoredLabel;

  /// **Tam skorlanmayan her katman için ZORUNLU.** Gerekçesiz bir sınır,
  /// açıklanmamış bir eksikliktir.
  final String? reason;

  bool get isFullyScored => scoredLabel == 'true';
}

/// Bilgi mimarisinin gezinme KURALLARI — beyan edilmiş, ölçülebilir kısıtlar.
///
/// **Okuyucusu yoktu (L-240) ve iki kural SESSİZCE karşılanmıyordu:**
/// [searchRequired] ve [allCoursesIndexRequired] ikisi de `true`, ikisi de
/// üründe YOK. Bir kural okunmuyorsa ihlal edilip edilmediği de bilinmez.
final class NavigationRules {
  const NavigationRules({
    required this.maxTapsHomeToActiveCourse,
    required this.maxTapsLibraryToAnyCourse,
    required this.searchRequired,
    required this.allCoursesIndexRequired,
  });

  final int maxTapsHomeToActiveCourse;
  final int maxTapsLibraryToAnyCourse;
  final bool searchRequired;
  final bool allCoursesIndexRequired;
}

/// Bir sınırın **SINIFI** — hangi tür kısıt olduğu.
///
/// **Neden zorunlu (L-265):** sayfanın girişi *"Some things we deliberately
/// left out"* diyordu ve **beş kalemin üçü kasıtlı karar DEĞİLDİ** —
/// yapamadığımız şeylerdi. Yapamamayı ilke gibi göstermek, JabLab'ın
/// hatasının **aynadaki** hâli: onlar kararı teknik kısıt gibi anlatıyordu,
/// biz teknik kısıtı karar gibi.
///
/// > ***Teknik kısıt örtük bir VAAT taşır ("daha iyi teknoloji çözer");
/// > kasıtlı karar taşımaz.***
///
/// Ve bu kusur **cümle düzeyinde görünmüyordu** — hiçbir cümle yalan
/// söylemeden sayfa yanlış okunuyordu. O yüzden düzeltme de **yapısal**:
/// her satır sınıfını kendisi söylüyor.
enum LimitKind {
  /// Kameranın/donanımın yapamadığı. **Teknoloji değişirse değişebilir.**
  capability,

  /// Ölçebiliyoruz ama güvenilir ayıramıyoruz — karışma, kalibrasyon, referans
  /// eksikliği. **Bizim ölçüm boşluğumuz.**
  measurement,

  /// **Mükemmel ölçümle de vermeyeceğimiz hüküm.** Veri sorunu değil, YETKİ.
  judgement;

  /// Kullanıcının okuyacağı hâl — makine adı yüzeye SIZMAZ (G-100).
  String get userText => switch (this) {
    LimitKind.capability =>
      'A limit of what a phone camera can do. Better hardware could '
          'change this.',
    LimitKind.measurement =>
      'A limit of what we can measure apart from everything else.',
    LimitKind.judgement =>
      'A choice. We would keep it even with perfect measurement.',
  };
}

/// Sınıf adını çözer — bilinmeyen bir ad SESSİZCE varsayılana düşmez.
LimitKind _limitKind(String name, int index) {
  for (final LimitKind k in LimitKind.values) {
    if (k.name == name) return k;
  }
  final String valid = LimitKind.values.map((LimitKind k) => k.name).join(', ');
  throw StateError(
    'whyNotPage.items[$index].kind bilinmiyor: "$name" — geçerli: $valid',
  );
}

final class WhyNotItem {
  const WhyNotItem({
    required this.topic,
    required this.reason,
    required this.kind,
  });
  final String topic;
  final String reason;

  /// Hangi SINIFTAN bir sınır. Okuyucu bunu zorunlu tutuyor: sınıfsız bir
  /// satır, okuyucunun kendi varsayımına bırakılmış demektir.
  final LimitKind kind;
}

final class LibraryIa {
  const LibraryIa({
    required this.tabs,
    required this.homeSections,
    required this.families,
    required this.whyNot,
    required this.poseTiers,
    required this.navigation,
  });

  final List<String> tabs;
  final List<HomeSection> homeSections;
  final List<LibraryFamily> families;
  final List<WhyNotItem> whyNot;

  /// Poz kütüphanesinin koçluk katmanları — gerekçeleriyle.
  final List<PoseTier> poseTiers;

  /// Beyan edilmiş gezinme kısıtları.
  final NavigationRules navigation;

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
      throw IaError(
        'version',
        'sürüm beyan edilmemiş — sürümsüz config izlenemez (Battery emsali)',
      );
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
      sections.add(
        HomeSection(
          id: _str(s['id'], 'home.sections[$i].id'),
          title: _str(s['title'], 'home.sections[$i].title'),
          source: _str(s['source'], 'home.sections[$i].source'),
        ),
      );
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
      whyNot.add(
        WhyNotItem(
          topic: _str(it['topic'], 'whyNotPage.items[$i].topic'),
          reason: _str(it['reason'], 'whyNotPage.items[$i].reason'),
          // Sınıf ZORUNLU: sınıfsız bir sınır satırı, okuyucunun kendi
          // varsayımına bırakılır — ve varsayılan varsayım "teknoloji çözer"
          // olur (L-265).
          kind: _limitKind(_str(it['kind'], 'whyNotPage.items[$i].kind'), i),
        ),
      );
    }

    return LibraryIa(
      tabs: tabs,
      homeSections: sections,
      families: families,
      whyNot: whyNot,
      poseTiers: _tiers(decoded['poseLibraryTiers']),
      navigation: _navigation(decoded['navigationRules']),
    );
  }

  static List<PoseTier> _tiers(Object? raw) {
    if (raw == null) return const <PoseTier>[];
    if (raw is! List) throw IaError('poseLibraryTiers', 'liste olmalı');
    final List<PoseTier> out = <PoseTier>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? e = raw[i];
      if (e is! Map<String, dynamic>) {
        throw IaError('poseLibraryTiers[$i]', 'nesne olmalı');
      }
      final String scored = '${e['scored']}';
      final String? reason = e['reason'] as String?;
      // Tam skorlanmayan katman GEREKÇESİZ olamaz: bu ürünün tüm duruşu
      // "neyi ölçmediğimizi SEBEBİYLE söylemek".
      if (scored != 'true' && (reason == null || reason.trim().isEmpty)) {
        throw IaError(
          'poseLibraryTiers[$i].reason',
          'tam skorlanmayan katman için ZORUNLU — gerekçesiz sınır, '
              'açıklanmamış bir eksikliktir',
        );
      }
      out.add(
        PoseTier(
          tier: (e['tier'] as num).toInt(),
          scope: _str(e['scope'], 'poseLibraryTiers[$i].scope'),
          coaching: _str(e['coaching'], 'poseLibraryTiers[$i].coaching'),
          scoredLabel: scored,
          reason: reason,
        ),
      );
    }
    return out;
  }

  static NavigationRules _navigation(Object? raw) {
    if (raw is! Map<String, dynamic>) {
      throw IaError('navigationRules', 'nesne olmalı');
    }
    int req(String k) {
      final Object? v = raw[k];
      if (v is! num) throw IaError('navigationRules.$k', 'sayı zorunlu');
      return v.toInt();
    }

    bool flag(String k) {
      final Object? v = raw[k];
      if (v is! bool) throw IaError('navigationRules.$k', 'bool zorunlu');
      return v;
    }

    return NavigationRules(
      maxTapsHomeToActiveCourse: req('maxTapsHomeToActiveCourse'),
      maxTapsLibraryToAnyCourse: req('maxTapsLibraryToAnyCourse'),
      searchRequired: flag('librarySearchRequired'),
      allCoursesIndexRequired: flag('allCoursesIndexRequired'),
    );
  }

  static LibraryFamily _family(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) throw IaError(path, 'nesne olmalı');
    final bool teachingOnly = raw['teachingOnly'] == true;
    if (raw.containsKey('teachingOnly') && raw['teachingOnly'] is! bool) {
      throw IaError('$path.teachingOnly', 'bool olmalı');
    }
    if (teachingOnly &&
        (raw['itemsSource'] is! String ||
            (raw['itemsSource'] as String).isEmpty)) {
      throw IaError(
        '$path.itemsSource',
        'teachingOnly için kurs kaynağı zorunlu',
      );
    }

    final List<FamilyChild> children = <FamilyChild>[];
    final Object? rawChildren = raw['children'];
    if (rawChildren != null) {
      if (rawChildren is! List) throw IaError('$path.children', 'liste olmalı');
      for (int i = 0; i < rawChildren.length; i++) {
        final Object? c = rawChildren[i];
        if (c is! Map<String, dynamic>) {
          throw IaError('$path.children[$i]', 'nesne olmalı');
        }
        children.add(
          FamilyChild(
            id: _str(c['id'], '$path.children[$i].id'),
            title: _str(c['title'], '$path.children[$i].title'),
            status: FamilyStatus.parse(
              '$path.children[$i].status',
              _str(c['status'], '$path.children[$i].status'),
            ),
            deepLink: c['deepLink'] as String?,
          ),
        );
      }
    }

    return LibraryFamily(
      id: _str(raw['id'], '$path.id'),
      title: _str(raw['title'], '$path.title'),
      status: FamilyStatus.parse(
        '$path.status',
        _str(raw['status'], '$path.status'),
      ),
      intro: _str(raw['intro'], '$path.intro'),
      children: children,
      honestyBox: _honesty(
        raw['honestyBox'],
        '$path.honestyBox',
        requireEvidence:
            FamilyStatus.parse(
                  '$path.status',
                  _str(raw['status'], '$path.status'),
                ) ==
                FamilyStatus.inProgress &&
            !teachingOnly,
        allowNoMeasurement: teachingOnly,
      ),
      itemsSource: raw['itemsSource'] as String?,
      teachingOnly: teachingOnly,
    );
  }

  /// ZORUNLU — ve iki listesi de boş OLAMAZ.
  ///
  /// Bu, config notunun ("opsiyonel değil") tek uygulanabilir hâli. Bir NOT
  /// hiçbir şeyi engellemez; bir `throw` engeller. Dürüstlük kutusu olmayan
  /// bir aile, tanımı gereği ekrana çıkamaz.
  /// [requireEvidence] — inşa edilmiş ailede her iddia `requires` TAŞIMAK
  /// ZORUNDA. Bu, L-230'un yapısal panzehiri: kanıtsız bir "şunu ölçüyoruz"
  /// cümlesi config'e giremez, dolayısıyla doğrulanamayan bir iddia yüzeye
  /// ÇIKAMAZ.
  static HonestyBox _honesty(
    Object? raw,
    String path, {
    required bool requireEvidence,
    bool allowNoMeasurement = false,
  }) {
    if (raw is! Map<String, dynamic>) {
      throw IaError(
        path,
        'ZORUNLU — dürüstlük kutusu olmayan aile yüzeye çıkamaz (IA config '
        'notu: "Bu kutu opsiyonel değil")',
      );
    }
    final List<HonestyClaim> measured = _claims(
      raw['measured'],
      '$path.measured',
      requireEvidence,
      allowEmpty: allowNoMeasurement,
    );
    final List<NotMeasuredLine> notMeasured = _notMeasured(
      raw['notMeasured'],
      '$path.notMeasured',
    );
    if (notMeasured.isEmpty) {
      throw IaError(
        '$path.notMeasured',
        'boş olamaz — "neler ölçülmez" boş bir liste, dürüstlük kutusunu '
            'pazarlama kutusuna çevirir',
      );
    }
    if (measured.isEmpty && !allowNoMeasurement) {
      throw IaError('$path.measured', 'boş olamaz');
    }
    return HonestyBox(measured: measured, notMeasured: notMeasured);
  }

  /// İki biçimi de okur ve KATI davranır:
  ///   - düz dize (yalnız inşa EDİLMEMİŞ ailede meşru — orada hiçbir şey
  ///     canlı değil ve bunu aile durumu söylüyor)
  ///   - `{claim, requires}` nesnesi (inşa edilmiş ailede ZORUNLU)
  static List<HonestyClaim> _claims(
    Object? raw,
    String path,
    bool requireEvidence, {
    bool allowEmpty = false,
  }) {
    if (raw is! List) throw IaError(path, 'liste olmalı');
    if (raw.isEmpty && !allowEmpty) throw IaError(path, 'boş olamaz');
    final List<HonestyClaim> out = <HonestyClaim>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? e = raw[i];
      if (e is String) {
        if (requireEvidence) {
          throw IaError(
            '$path[$i]',
            'inşa edilmiş ailede düz metin iddia YASAK — her iddia '
                '`requires` ile dayanağını beyan etmeli (L-230: kanıtsız iddia '
                'doğrulanamaz, doğrulanamayan iddia pazarlamadır)',
          );
        }
        out.add(HonestyClaim(claim: e, requires: const <String>[]));
        continue;
      }
      if (e is! Map<String, dynamic>) {
        throw IaError('$path[$i]', 'dize ya da nesne olmalı');
      }
      final List<String> requires = _strList(
        e['requires'],
        '$path[$i].requires',
      );
      if (requireEvidence && requires.isEmpty) {
        throw IaError(
          '$path[$i].requires',
          'boş olamaz — dayanaksız iddia yüzeye çıkamaz',
        );
      }
      out.add(
        HonestyClaim(
          claim: _str(e['claim'], '$path[$i].claim'),
          requires: requires,
        ),
      );
    }
    return out;
  }

  /// Düz dize ya da `{claim, falsifiedIfBridged}` nesnesi.
  static List<NotMeasuredLine> _notMeasured(Object? raw, String path) {
    if (raw is! List) throw IaError(path, 'liste olmalı');
    final List<NotMeasuredLine> out = <NotMeasuredLine>[];
    for (int i = 0; i < raw.length; i++) {
      final Object? e = raw[i];
      if (e is String) {
        out.add(
          NotMeasuredLine(claim: e, falsifiedIfBridged: const <String>[]),
        );
        continue;
      }
      if (e is! Map<String, dynamic>) {
        throw IaError('$path[$i]', 'dize ya da nesne olmalı');
      }
      out.add(
        NotMeasuredLine(
          claim: _str(e['claim'], '$path[$i].claim'),
          falsifiedIfBridged: _strList(
            e['falsifiedIfBridged'] ?? <String>[],
            '$path[$i].falsifiedIfBridged',
          ),
        ),
      );
    }
    return out;
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
