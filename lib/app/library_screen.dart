/// **library** sekmesi — §5.4 hükmü: TAM GENİŞLİK, KATMANLI.
///
/// Üç kısıt bu dosyanın YAPISINI belirliyor, üslubunu değil:
///
///   1. **Aktif dalga birinci sınıf.** `assessment_battery` tam kart, kendi
///      sayısıyla, en üstte.
///   2. **İnşa edilmemiş aileler görsel olarak AYRI ve KOMPAKT bir bölümde**,
///      her biri dürüst tek satırlık durumla. Eşit-ağırlık listeleme YASAK —
///      altı aileyi aynı kartla dizmek sahte doluluk üretir.
///   3. **Ayrı yol-haritası sayfası YASAK.** Genişlik BURADA görünür; bir
///      "yakında gelecekler" sayfasına sürülmez.
///
/// Aile sayfaları (`FamilyPage`) IA config'in *"her öğe kendi sayfası"*
/// direktifinin karşılığıdır ve bir yol haritası değildir: her biri o ailenin
/// ZORUNLU dürüstlük kutusunu taşır. Kutu okuyucuda tip düzeyinde zorlanıyor
/// (`LibraryIa._honesty`), yani kutusuz bir aile sayfası ÜRETİLEMEZ.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'app_facts.dart';
import 'attempt_values.dart';
import 'hatha_course.dart';
import 'hatha_course_screen.dart';
import 'hatha_progress.dart';
import 'ia.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';
import 'surfaces.dart';
import 'test_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    required this.facts,
    this.attemptValueStoreLoader,
    this.hathaStoreLoader,
    this.onCourseDone,
    super.key,
  });

  /// `LiveCaptureScreen.attemptValueStoreLoader`la AYNI enjeksiyon
  /// sözleşmesi (D13) — testte enjekte edilir, üretimde `null` ⇒
  /// `openAttemptValueStore`.
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;
  final Future<HathaProgressStore> Function()? hathaStoreLoader;
  final VoidCallback? onCourseDone;

  static const Key builtSectionKey = Key('library.built');
  static const Key notBuiltSectionKey = Key('library.notBuilt');

  /// Yol haritası bittiğinde çizilen satır — A3'ün başlıklı-boşluk yasağı
  /// (L-315). Anahtarsız bir dal testten görünmez.
  static const Key nothingPendingKey = Key('library.nothingPending');

  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<LibraryFamily> built = facts.ia.built;
    final List<LibraryFamily> pending = facts.ia.notBuilt;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          // ⚠️ Beyan bölümün DIŞINDA: içine koymak onu bir "aile kartı"
          // yapardı ve eşit-ağırlık kapısı (kart sayısı = aile sayısı)
          // yanlış sayardı. Kapı bunu anında yakaladı.
          const CaptureUnavailableNote(),
          Column(
            key: builtSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SectionHeading(
                localeText(context, 'In this build', 'Bu sürümde'),
                // ⚠️ Eskiden "What Lissom can actually do on your phone
                // today" yazıyordu — Home'un beyanıyla DOĞRUDAN çelişiyordu
                // (L-242). Batarya telefonda çalıştırılamıyor.
                subtitle: localeText(
                  context,
                  'Written courses and measurement engine coverage. '
                      'Live camera measurements are closed in this release.',
                  'Yazılı kurslar ve ölçüm motorunun kapsamı. '
                      'Bu sürümde canlı kamera ölçümleri kapalıdır.',
                ),
              ),
              const SizedBox(height: 14),
              for (final LibraryFamily f in built)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BuiltFamilyCard(
                    family: f,
                    facts: facts,
                    attemptValueStoreLoader: attemptValueStoreLoader,
                    hathaStoreLoader: hathaStoreLoader,
                    onCourseDone: onCourseDone,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Column(
            key: notBuiltSectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ⓑ **BAŞLIKLI BOŞLUK YOK (A3, L-315).** `pending` boşalırsa
              // eski kod *"Planned, not in this build (0)"* başlığını ve
              // altındaki *"These are named so you can see…"* paragrafını
              // çiziyordu — **hiçbir ad olmadan.** Paragraf var olmayan bir
              // listeyi tarif ediyordu; sessiz değil, YANLIŞ.
              //
              // ⚠️ Ve bu, arızada değil **hedefte** olan bir hâl: yol
              // haritası bittiğinde `pending` boşalır. `blocked` boşluğuyla
              // AYNI biçimde kapatıldı — iki özdeş durum iki farklı tonla
              // yazılsaydı ürünün sesi çatallanırdı.
              if (pending.isEmpty)
                Text(
                  localeText(
                    context,
                    'Everything named in the plan is built and in this app.',
                    'Planda adı geçen her bölüm bu uygulamada mevcut.',
                  ),
                  key: nothingPendingKey,
                  style: t.textTheme.bodyMedium,
                )
              else ...<Widget>[
                // Bölüm başlığı SAYIYI taşır: genişlik saklanmıyor, ama
                // birinci-sınıf yerleşim de verilmiyor.
                LissomEyebrow(
                  localeText(
                    context,
                    'Planned, not in this build (${pending.length})',
                    'Bu sürümde bulunmayan bölümler (${pending.length})',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localeText(
                    context,
                    'These are named so you can see the whole shape of Lissom. '
                        'None of them has content in the app you are holding, and we '
                        'are not going to guess when they will.',
                    'Bu başlıklar Lissom’un planlanan kapsamını gösterir. '
                        'Henüz içerik barındırmazlar; bir yayın tarihi belirtilmez.',
                  ),
                  style: t.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final LibraryFamily f in pending)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PendingFamilyRow(family: f, facts: facts),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Birinci-sınıf yerleşim: tam kart, gerçek sayı, gerçek giriş.
class _BuiltFamilyCard extends StatelessWidget {
  const _BuiltFamilyCard({
    required this.family,
    required this.facts,
    this.attemptValueStoreLoader,
    this.hathaStoreLoader,
    this.onCourseDone,
  });
  final LibraryFamily family;
  final AppFacts facts;
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;
  final Future<HathaProgressStore> Function()? hathaStoreLoader;
  final VoidCallback? onCourseDone;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final int live = facts.live.length;
    final int total = facts.liveness.length;
    return InkWell(
      borderRadius: BorderRadius.circular(LissomRadii.card),
      onTap: () async {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => FamilyPage(
              family: family,
              facts: facts,
              attemptValueStoreLoader: attemptValueStoreLoader,
              hathaStoreLoader: hathaStoreLoader,
            ),
          ),
        );
        onCourseDone?.call();
      },
      child: LissomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              configText(context, family.title),
              style: t.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              configText(context, family.intro),
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            // Sayı TÜRETİLİR (köprüden), yazılmaz. "12 test" demek yeterli
            // olmazdı: 12'sinden 3'ü ölçülebiliyor ve fark kullanıcının
            // görmesi gereken şeyin ta kendisi.
            Text(
              family.teachingOnly
                  ? facts.hatha == null
                        ? localeText(
                            context,
                            'Course data unavailable',
                            'Kurs verisi açılamadı',
                          )
                        : localeText(
                            context,
                            '${facts.hatha!.modules.length} modules · '
                                '${facts.hatha!.lessons.length} Hatha lessons'
                                '${facts.chairOffice == null ? '' : ' · ${facts.chairOffice!.lessons.length} chair / office lessons'}'
                                '${facts.vinyasa == null ? '' : ' · ${facts.vinyasa!.lessons.length} Vinyasa lessons'}'
                                '${facts.yin == null ? '' : ' · ${facts.yin!.lessons.length} Yin lessons'}',
                            '${facts.hatha!.modules.length} modül · '
                                '${facts.hatha!.lessons.length} Hatha dersi'
                                '${facts.chairOffice == null ? '' : ' · ${facts.chairOffice!.lessons.length} sandalye / ofis dersi'}'
                                '${facts.vinyasa == null ? '' : ' · ${facts.vinyasa!.lessons.length} Vinyasa dersi'}'
                                '${facts.yin == null ? '' : ' · ${facts.yin!.lessons.length} Yin dersi'}',
                          )
                  : localeText(
                      context,
                      '$total tests · $live camera measurement paths in the engine '
                          '· camera closed in this release',
                      '$total test · motorda $live kamera ölçüm yolu '
                          '· bu sürümde kamera kapalı',
                    ),
              style: t.textTheme.bodySmall?.copyWith(
                color: LissomColors.roseDeepHover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kompakt satır: ad + dürüst tek satır durum. Kart YOK, gölge YOK —
/// birinci-sınıf yerleşimle karışmasın.
class _PendingFamilyRow extends StatelessWidget {
  const _PendingFamilyRow({required this.family, required this.facts});
  final LibraryFamily family;
  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(LissomRadii.inner),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => FamilyPage(family: family, facts: facts),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: LissomColors.hairline),
          borderRadius: BorderRadius.circular(LissomRadii.inner),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      configText(context, family.title),
                      style: t.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      configText(context, family.inventoryLine),
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: LissomColors.bodySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bir ailenin sayfası — **dürüstlük kutusu ZORUNLU** (opsiyonel değil).
class FamilyPage extends StatelessWidget {
  const FamilyPage({
    required this.family,
    required this.facts,
    this.attemptValueStoreLoader,
    this.hathaStoreLoader,
    super.key,
  });

  static const Key honestyKey = Key('family.honestyBox');
  static const Key liveListKey = Key('family.liveTests');
  static const Key blockedListKey = Key('family.blockedTests');

  /// İki listenin BOŞ hâlleri — A3'ün başlıklı-boşluk yasağı (L-315).
  /// Anahtarlı, çünkü *anahtarsız bir dal testten görünmez* ve görünmeyen
  /// bir dalın çizildiği kanıtlanamaz.
  static const Key noLiveTestsKey = Key('family.noLiveTests');
  static const Key noBlockedTestsKey = Key('family.noBlockedTests');
  static const Key namedChildrenKey = Key('family.namedChildren');

  final LibraryFamily family;
  final AppFacts facts;
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;
  final Future<HathaProgressStore> Function()? hathaStoreLoader;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: <Widget>[
            Text(
              configText(context, family.title),
              style: t.textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            const CaptureUnavailableNote(),
            Text(
              configText(context, family.intro),
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
            if (family.isBuilt)
              ...family.teachingOnly
                  ? _hathaBody(context)
                  : _batteryBody(context)
            else
              ..._namedBody(context),
            const SizedBox(height: 8),
            Padding(
              key: honestyKey,
              padding: const EdgeInsets.only(top: 8),
              child: HonestyBoxCard(
                family.honestyBox,
                liveness: facts.blockerForClaim,
                verdictNote: facts.verdictNoteFor,
              ),
            ),
            const MeasurementLimitsFootnote(),
          ],
        ),
      ),
    );
  }

  List<Widget> _hathaBody(BuildContext context) {
    final HathaCourse? course = facts.hatha;
    if (course == null) {
      return <Widget>[
        NamedGapCard(
          title: localeText(
            context,
            'Course cannot be opened',
            'Kurs açılamıyor',
          ),
          reason: localeText(
            context,
            'The lesson asset was not loaded.',
            'Ders dosyası yüklenmedi.',
          ),
        ),
      ];
    }
    return <Widget>[
      LissomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              hathaText(context, course.title),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              localeText(
                context,
                '${course.modules.length} modules · ${course.lessons.length} lessons',
                '${course.modules.length} modül · ${course.lessons.length} ders',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: hathaStoreLoader == null
                  ? null
                  : () async {
                      final HathaProgressStore store =
                          await hathaStoreLoader!();
                      final HathaProgress progress = await store.read();
                      if (!context.mounted) return;
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => HathaCourseScreen(
                            course: course,
                            initialProgress: progress,
                            storeLoader: hathaStoreLoader!,
                          ),
                        ),
                      );
                    },
              child: Text(
                localeText(context, 'Open Hatha course', 'Hatha kursunu aç'),
              ),
            ),
          ],
        ),
      ),
      if (facts.chairOffice case final HathaCourse chair) ...<Widget>[
        const SizedBox(height: 16),
        LissomCard(
          key: const Key('library.chairOfficeCourse'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(hathaText(context, chair.title),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(hathaText(context, chair.intro)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: hathaStoreLoader == null
                    ? null
                    : () async {
                        final store = await hathaStoreLoader!();
                        final progress = await store.read();
                        if (!context.mounted) return;
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => HathaCourseScreen(
                              course: chair,
                              initialProgress: progress,
                              storeLoader: hathaStoreLoader!,
                            ),
                          ),
                        );
                      },
                child: Text(localeText(
                  context, 'Open chair / office path',
                  'Sandalye / ofis yolunu aç',
                )),
              ),
            ],
          ),
        ),
      ],
      if (facts.vinyasa case final HathaCourse chair) ...<Widget>[
        const SizedBox(height: 16),
        LissomCard(
          key: const Key('library.vinyasaCourse'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(hathaText(context, chair.title),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(hathaText(context, chair.intro)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: hathaStoreLoader == null
                    ? null
                    : () async {
                        final store = await hathaStoreLoader!();
                        final progress = await store.read();
                        if (!context.mounted) return;
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => HathaCourseScreen(
                              course: chair,
                              initialProgress: progress,
                              storeLoader: hathaStoreLoader!,
                            ),
                          ),
                        );
                      },
                child: Text(localeText(
                  context, 'Open supported standing Vinyasa',
                  'Destekli ayakta Vinyasa yolunu aç',
                )),
              ),
            ],
          ),
        ),
      ],
      if (facts.yin case final HathaCourse chair) ...<Widget>[
        const SizedBox(height: 16),
        LissomCard(
          key: const Key('library.yinCourse'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(hathaText(context, chair.title),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(hathaText(context, chair.intro)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: hathaStoreLoader == null
                    ? null
                    : () async {
                        final store = await hathaStoreLoader!();
                        final progress = await store.read();
                        if (!context.mounted) return;
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => HathaCourseScreen(
                              course: chair,
                              initialProgress: progress,
                              storeLoader: hathaStoreLoader!,
                            ),
                          ),
                        );
                      },
                child: Text(localeText(
                  context, 'Open supported Yin',
                  'Destekli Yin yolunu aç',
                )),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
      Text(
        localeText(
          context,
          'The beginner Ashtanga course remains pending. Written courses do not establish physical mastery.',
          'Başlangıç Ashtanga kursu bekliyor. Yazılı kurslar fiziksel ustalık göstermez.',
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  /// İnşa edilmiş aile: gerçek testler, canlı/engelli ayrımıyla — TÜRETİLİR.
  List<Widget> _batteryBody(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<TestLiveness> live = facts.live;
    final List<TestLiveness> blocked = facts.blocked;
    final String liveHeading = localeText(
      context,
      'Camera measurement paths in the engine',
      'Motordaki kamera ölçüm yolları',
    );
    final String blockedHeading = localeText(
      context,
      'No camera measurement path in the engine',
      'Motorda kamera ölçüm yolu olmayanlar',
    );
    return <Widget>[
      // ⓑ **BAŞLIKLI BOŞLUK YOK (A3, L-315).** `live` boşalırsa eski kod
      // *"Measured by camera in this build (0)"* başlığını çizip altına
      // HİÇBİR ŞEY koymuyordu: kullanıcı sıfır ilan eden bir vaat görüp
      // karşılığını bulamıyordu. Sayı sıfırsa başlık değil GEREKÇE çizilir.
      if (live.isEmpty)
        NamedGapCard(
          key: noLiveTestsKey,
          title: localeText(
            context,
            'No test in this battery has a camera measurement path in the engine',
            'Bu listedeki hiçbir test için motorda kamera ölçüm yolu yok',
          ),
          reason: localeText(
            context,
            'Every test here needs a measurement the engine cannot '
                'produce in this build. Live camera measurements are '
                'closed in this release.',
            'Bu testler ölçüm motorunun üretemediği değerlere ihtiyaç '
                'duyuyor. Bu sürümde kamera ile sonuç verilemiyor.',
          ),
        )
      else ...<Widget>[
        LissomEyebrow('$liveHeading (${live.length})'),
        const SizedBox(height: 10),
        Column(
          key: liveListKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 🔴 **YAPABİLDİĞİN TEST SANA EN AZ ŞEYİ SÖYLÜYORDU (L-328).**
            // Engelli 9 test kendi gerekçesini taşıyordu; **canlı** 3 test
            // yalnız ad + ikon. Oysa ailenin tanıtımı *"each one measures a
            // specific area and tells you what it could and could not see"*
            // diyor ⇒ vaat **yapamadığın** testler için tutuluyor,
            // **yapabildiklerin** için hiç.
            // > ***DÜRÜSTLÜK MAKİNESİ YALNIZ BAŞARISIZLIKTA ATEŞLENİYORSA,
            // > KULLANICI ÜRÜNÜ EN ÇOK KULLANDIĞI YERDE EN AZ ŞEY ÖĞRENİR.***
            //
            // ⭐ İçerik UYDURULMADI: `TestSpec.instruction` config'te zaten
            // yazılı ve `battery.dart` onu ayrıştırıyordu — ama `lib/` altında
            // **hiçbir okuyucusu yoktu** (`L-178` sınıfı: okuyucusu olmayan
            // config alanı). *Yazılmış içeriği göstermek, yeni içerik yazmak
            // değildir.*
            // ⛔ Boş talimat `null`a düşer: boş bir alt satır çizmek, bu
            // gecenin başlıklı-boşluk sınıfını (A3) geri getirirdi.
            for (final TestLiveness x in live)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TestRow(
                  icon: Icons.videocam_outlined,
                  iconColor: t.colorScheme.primary,
                  title: x.name,
                  subtitle: _instructionFor(x.testId),
                  // D13/F2 — bu testin GEÇMİŞİNE gider (SON DEĞER + trend).
                  // `facts.battery.tests[x.testId]` her zaman VAR: `live`
                  // zaten bataryadan türetilir (`facts.live`), yabancı bir
                  // testId üretemez.
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => TestDetailScreen(
                        test: facts.battery.tests[x.testId]!,
                        attemptValueStoreLoader: attemptValueStoreLoader,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: 22),
      // ⛔ "Not measurable YET" DEĞİL — `yet` bir vaattir (M-F-186) ve
      // engelin kalkacağı bir tarih ima eder. Başlık artık yalnız OLGUYU
      // söylüyor; gerekçe her satırın kendisinde.
      //
      // 🔴 **ASİMETRİ KASITLI (A3, L-315).** Üstteki boş hâl bir GEREKÇE
      // çizer, buradaki bir OLGU — çünkü iki boşluk aynı şey değil:
      // *"hiçbir şey ölçülemiyor"* kullanıcının BİLMESİ GEREKEN bir eksiklik,
      // *"hiçbir şey engelli değil"* ise bir eksikliğin YOKLUĞU. İkincisini
      // "(0)" başlığıyla ilan etmek, üstelik altında *"her biri sebebini
      // söylüyor"* diyen bir cümleyle, olmayan bir listeyi VAAT ederdi.
      // ⇒ Cümle TÜRETİLİR (`blocked` boşsa her test canlıdır), uydurulmaz.
      if (blocked.isEmpty)
        Text(
          localeText(
            context,
            'Every test in this battery has a camera measurement path in the '
                'engine. Live camera measurements are closed in this release.',
            'Bu listedeki her test için motorda kamera ölçüm yolu vardır. '
                'Bu sürümde canlı kamera ölçümleri kapalıdır.',
          ),
          key: noBlockedTestsKey,
          style: t.textTheme.bodyMedium,
        )
      else ...<Widget>[
        LissomEyebrow('$blockedHeading (${blocked.length})'),
        const SizedBox(height: 4),
        Text(
          localeText(
            context,
            'Each one below names the reason it cannot be read, and the reason '
                'is what would have to change.',
            'Her testin neden ölçülemediği kendi satırında açıklanır.',
          ),
          style: t.textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        Column(
          key: blockedListKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final TestLiveness x in blocked)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TestRow(
                  icon: Icons.block_outlined,
                  iconColor: LissomColors.bodySecondary,
                  title: x.name,
                  subtitle: x.blocker!,
                ),
              ),
          ],
        ),
      ],
    ];
  }

  /// Testin talimatı — YOKSA `null`, boş dize DEĞİL.
  ///
  /// `battery.dart` eksik alanı `''`e düşürüyor (`?? ''`); boş dizeyi alt
  /// satır olarak çizmek, bu gecenin **başlıklı boşluk** sınıfını (A3) geri
  /// getirirdi: ad altında karşılıksız bir boşluk.
  String? _instructionFor(String testId) {
    final String? s = facts.battery.tests[testId]?.instruction;
    return (s == null || s.trim().isEmpty) ? null : s;
  }

  /// İnşa edilmemiş aile: **kurs listesi GÖSTERİLMEZ** (IA config notu). Ne
  /// olduğu ADLARIYLA görünür — isimlendirilmiş ≠ inşa edilmiş, ve satır
  /// bunu söyler. Sahte kart, sahte süre, sahte seviye YOK.
  List<Widget> _namedBody(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final String namedHeading = localeText(
      context,
      'Named in the plan',
      'Planda adı geçenler',
    );
    if (family.children.isEmpty) {
      return <Widget>[
        NamedGapCard(
          title: configText(context, family.title),
          reason: configText(context, family.inventoryLine),
        ),
      ];
    }
    return <Widget>[
      LissomEyebrow('$namedHeading (${family.children.length})'),
      const SizedBox(height: 4),
      Text(
        localeText(
          context,
          'Names, not content. Nothing below exists in the app you are holding.',
          'Bunlar yalnız adlardan oluşur; bu sürümde içerikleri bulunmaz.',
        ),
        style: t.textTheme.bodySmall,
      ),
      const SizedBox(height: 10),
      Column(
        key: namedChildrenKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final FamilyChild c in family.children)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.circle_outlined,
                      size: 9,
                      color: LissomColors.bodySecondary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      configText(context, c.title),
                      style: t.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ];
  }
}

/// Test satırı — canlı satırda altyazı YOK (ham metrik-id dahili sözlüktür ve
/// bir kez yüzeye sızmıştı), engelli satırda gerekçe VAR.
///
/// [onTap] yalnız CANLI testlerde dolu (D13/F2) — engelli bir teste dokunmak
/// "geçmişini gör" diye bir yere GÖTÜRMEZ, çünkü hiç ölçülememiş bir testin
/// geçmişi yoktur; boş bir sayfaya yönlendirmek A3'ün başlıklı-boşluk
/// yasağını sayfa düzeyinde çiğnerdi.
class _TestRow extends StatelessWidget {
  const _TestRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(configText(context, title), style: t.textTheme.titleMedium),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  configText(context, subtitle!),
                  style: t.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          const Padding(
            padding: EdgeInsets.only(top: 2, left: 6),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: LissomColors.bodySecondary,
            ),
          ),
      ],
    );
    return onTap == null
        ? LissomCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: row,
          )
        : InkWell(
            borderRadius: BorderRadius.circular(LissomRadii.card),
            onTap: onTap,
            child: LissomCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: row,
            ),
          );
  }
}
