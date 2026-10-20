/// **home** sekmesi — IA config'in dört bölümü, hepsi DÜRÜST hâliyle.
///
/// Bölümlerin başlıkları ve sırası `config/ia/library.v1.json`'dan TÜRETİLİR;
/// bu dosya onları yeniden yazmaz. Her bölümün beslendiği kaynak (`source`)
/// dahili sözlüktür ve yüzeye ÇIKMAZ — görünen şey o kaynağın VAR OLUP
/// OLMADIĞININ sonucudur.
///
/// ## `retest_countdown` — hükmün varsaydığı artefakt YOK
///
/// §5.2 hükmü *"ana ekranda sakin kart: 'yeniden ölçüm: X gün'"* diyor. O X
/// bir SAYIDIR ve **hiçbir config'te tanımlı değil** — `lissom-assessment`,
/// `assessment-blocks`, `lissom-phases`, `library` dosyalarının hiçbirinde
/// yeniden-ölçüm aralığı yok (arandı, bulunamadı). Eşik icadı yasak olduğuna
/// göre (her eşik artefakttan türer) burada bir gün sayısı YAZILAMAZ.
///
/// Bu, hükmü ihlal etmiyor — hükmün RUHUNU uyguluyor: *"davet, geri sayım
/// değil."* Geri sayımın sayıya ihtiyacı var, davetin yok. Yüzey son ölçüm
/// TARİHİNİ (bir olgu) gösterir, bir vade GÖSTERMEZ, ve aralığın tanımsız
/// olduğunu söyler. **Artefakt gelirse kart bir vade kazanabilir; o karar
/// koordinatörde.**
///
/// ## Gecikme ASLA suçlanmaz
///
/// Bu ekranda "kaçırdın", "geciktin", "X gündür ölçmedin" YOKTUR. Ton
/// *"hazır olduğunda"*. Kullanıcının uzun süre ölçmemiş olması bir bilgi
/// değil bir yargıdır — ve yargı vermiyoruz.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'app_facts.dart';
import 'ashtanga_entry.dart';
import 'vinyasa_entry.dart';
import 'yin_entry.dart';
import 'attempt_values.dart';
import 'hatha_course.dart';
import 'hatha_course_screen.dart';
import 'ia.dart';
import 'lissom_theme.dart';
import 'lissom_palette.dart';
import 'locale_text.dart';
import 'live_capture_screen.dart';
import 'session_history_view.dart';
import 'surfaces.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.facts,
    required this.onOpenLibrary,
    this.onOpenHatha,
    this.onOpenChairOffice,
    this.onOpenVinyasa,
    this.onOpenYin,
    this.onOpenAshtanga,
    this.ageBand,
    this.onMeasurementDone,
    this.poseSourceLoader,
    this.sessionStoreLoader,
    this.attemptValueStoreLoader,
    this.beforeMeasurement,
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  /// Ölçüm ekranından DÖNÜLDÜĞÜNDE çağrılır — kabuk geçmişi yeniden okur.
  /// Olmazsa kullanıcı ölçüm yapar, kayıt diske girer, ve Home hâlâ
  /// *"Nothing recorded on this device"* der (L-287).
  final VoidCallback? onMeasurementDone;

  /// **A1 DİKİŞİ (L-309) — kamera kaynağı ÇAĞIRANA ait.**
  ///
  /// `LiveCaptureScreen.sourceOverride` bu ağaçta zaten vardı, ama YALNIZ
  /// ekranı doğrudan `pumpWidget`leyen testler ona ulaşabiliyordu. Home onu
  /// enjekte edemediği için ***taze kurulumdan sonuca kadar TEK bir yürüyüş
  /// yazılamıyordu***: zincir iki yarıma bölünmüştü ve `grep -rl
  /// "onboarding.continue"` ∩ `grep -rl "liveCapture.finish"` **BOŞTU.**
  ///
  /// ⚠️ **FABRİKA, örnek DEĞİL** — ve sebebi ölçülmüş: `FakePoseSource` bir
  /// akışı TÜKETİR; tek bir örnek paylaşılsaydı ikinci ölçüm sessizce
  /// olaysız açılır, yürüyüş *"kaynak kuru"* hâlini ürün kusuru sanardı.
  /// Ad da bu yüzden `…Loader`: bu ağaçta `…Loader` = fabrika
  /// (`LissomShell.loader` · `OnboardingGate.storeLoader`), `…Override` =
  /// örnek (`LiveCaptureScreen.sourceOverride`). **Yeni sözleşme değil,
  /// var olanın bir katman yukarısı.**
  final PoseSource Function()? poseSourceLoader;

  /// Ölçüm kaydının deposu — `LiveCaptureScreen.storeLoader`a AYNEN geçer.
  ///
  /// ⚠️ Ad `storeLoader` DEĞİL: bu ağaçta o ad **`OnboardingStore`** için
  /// kullanılıyor (`OnboardingGate.storeLoader`) ve iki ayrı depo aynı adı
  /// taşısaydı, bir katman yukarıda hangisinin geçtiği **okunarak
  /// ayırt edilemezdi.** İki depo, iki ad.
  final Future<SessionStore> Function()? sessionStoreLoader;
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;
  final Future<bool> Function(BuildContext)? beforeMeasurement;
  final bool measurementAvailable;

  /// Onboarding'de beyan edilen yaş bandı — ölçüm başlatılırken motora
  /// GEÇİRİLİR. Burada yorumlanmaz (G-100).
  final String? ageBand;

  static const Key todayKey = Key('home.today');
  static const Key retestKey = Key('home.retest_countdown');
  static const Key continueKey = Key('home.continue');
  static const Key quickStartKey = Key('home.quick_start');
  static const Key startMeasurementKey = Key('home.startMeasurement');
  static const Key hathaCourseKey = Key('home.hathaCourse');
  static const Key chairOfficeCourseKey = Key('home.chairOfficeCourse');

  /// Bölüm id'si → o bölümün gövdesi. Config'te TANIMSIZ bir bölüm gelirse
  /// sessizce atlanmaz: [_unknownSection] onu ADIYLA gösterir. Sessiz atlama,
  /// config'e eklenen bir bölümün hiç görünmemesine ve kimsenin fark
  /// etmemesine yol açardı (L-181 sınıfı: okuyucusu olmayan alan).
  static const Map<String, Key> _keys = <String, Key>{
    'today': todayKey,
    'retest_countdown': retestKey,
    'continue': continueKey,
    'quick_start': quickStartKey,
  };

  final AppFacts facts;
  final VoidCallback onOpenLibrary;
  final VoidCallback? onOpenHatha;
  final VoidCallback? onOpenChairOffice;
  final VoidCallback? onOpenVinyasa;
  final VoidCallback? onOpenYin;
  final VoidCallback? onOpenAshtanga;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LissomPalette.of(context).screenBackground,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          if (facts.hatha case final HathaCourse course) ...<Widget>[
            _courseCard(context, course),
            const SizedBox(height: 24),
          ],
          if (facts.ashtanga case final HathaCourse course) ...<Widget>[
            AshtangaEntry(
              key: const Key('home.ashtangaCourse'),
              course: course,
              participation:
                  facts.hathaProgress?.practicedIn(course).length ?? 0,
              onOpen: onOpenAshtanga ?? onOpenLibrary,
            ),
            const SizedBox(height: 18),
          ],
          if (facts.yin case final HathaCourse course) ...<Widget>[
            YinEntry(
              key: const Key('home.yinCourse'),
              course: course,
              onOpen: onOpenYin,
              onOpenFoundations: onOpenHatha,
            ),
            const SizedBox(height: 18),
          ],
          if (facts.vinyasa case final HathaCourse course) ...<Widget>[
            VinyasaEntry(
              key: const Key('home.vinyasaCourse'),
              course: course,
              onOpen: onOpenVinyasa,
              onOpenFoundations: onOpenHatha,
            ),
            const SizedBox(height: 18),
          ],
          if (facts.chairOffice case final HathaCourse course) ...<Widget>[
            _courseCard(context, course, chairOffice: true),
            const SizedBox(height: 24),
          ],
          // Cihaz-geçişi olgusu [DevicePassClaim]'den TÜRETİLİR (L-318) —
          // burada elle yazılsaydı A12 kapandığında güncellenmeyen üçüncü
          // kopya BU olurdu.
          DeclarationBanner(
            eyebrow: localeText(
              context,
              'Where Lissom is today',
              'Lissom’un bugünkü durumu',
            ),
            body: _releaseBody(context),
          ),
          const SizedBox(height: 24),
          for (final HomeSection s in facts.ia.homeSections) ...<Widget>[
            _section(context, s),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _courseCard(
    BuildContext context,
    HathaCourse course, {
    bool chairOffice = false,
  }) {
    final int practiced = facts.hathaProgress?.practicedIn(course).length ?? 0;
    return LissomCard(
      key: chairOffice ? chairOfficeCourseKey : hathaCourseKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(
            localeText(
              context,
              chairOffice ? 'YOUR SEATED PATH' : 'YOUR HATHA PATH',
              chairOffice ? 'OTURARAK ÇALIŞMA YOLUN' : 'HATHA YOLUN',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hathaText(context, course.title),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            localeTemplate(
              context,
              '{modules} modules · {lessons} lessons · {practised} practised',
              '{modules} modül · {lessons} ders · {practised} çalışıldı',
              <String, Object>{
                'modules': localizedInteger(context, course.modules.length),
                'lessons': localizedInteger(context, course.lessons.length),
                'practised': localizedInteger(context, practiced),
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            localeText(
              context,
              'Choose a lesson, explore its easier options, and record your practice. '
                  'Your pace is part of the path.',
              'Bir ders seç, kolay seçeneklerini keşfet ve çalışmanı kaydet. '
                  'Kendi hızın bu yolun bir parçası.',
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed:
                (chairOffice ? onOpenChairOffice : onOpenHatha) ??
                onOpenLibrary,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(
              localeText(
                context,
                chairOffice
                    ? (practiced == 0
                          ? 'Start chair / office path'
                          : 'Continue chair / office path')
                    : (practiced == 0
                          ? 'Start Hatha course'
                          : 'Continue Hatha course'),
                chairOffice
                    ? (practiced == 0
                          ? 'Sandalye / ofis yoluna başla'
                          : 'Sandalye / ofis yoluna devam et')
                    : (practiced == 0
                          ? 'Hatha kursuna başla'
                          : 'Hatha kursuna devam et'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _releaseBody(BuildContext context) => measurementAvailable
      ? localeText(
          context,
          'The measurement engine, the twelve-test battery, and a '
              'live capture screen are connected. '
              '${DevicePassClaim.notTried}: ${DevicePassClaim.stillNeeds} '
              '— what you can do today is start a measurement, or read '
              'exactly what each test measures and what it cannot.',
          'Ölçüm motoru, test listesi ve canlı kamera akışı bağlı. '
              'Gerçek cihazda izin, kare akışı, ışık ve kalibrasyon kabulü '
              'tamamlanmadı. Şimdi ölçümü başlatabilir veya her testin '
              'neyi ölçebildiğini inceleyebilirsin.',
        )
      : localeText(
          context,
          'Explore the movement-test catalogue. Camera assessments and '
              'subscriptions are not open in this release.',
          'Hareket testi kataloğunu incele. Kamera değerlendirmeleri ve '
              'abonelikler bu sürümde açık değil.',
        );

  Widget _section(BuildContext context, HomeSection s) {
    final Key? k = _keys[s.id];
    if (k == null) {
      return _unknownSection(context, s);
    }
    return Column(
      key: k,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LissomEyebrow(configText(context, s.title)),
        const SizedBox(height: 10),
        switch (s.id) {
          'today' => _today(context),
          'retest_countdown' => _retest(context),
          'continue' => _continue(context),
          'quick_start' => _quickStart(context),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  /// Config'e yeni bir bölüm eklenip koda karşılığı yazılmadıysa: SESSİZLİK
  /// YOK. Kullanıcı "burada bir şey olacaktı" bilgisini görür, biz de
  /// eksikliği yüzeyde yakalarız.
  Widget _unknownSection(BuildContext context, HomeSection s) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      LissomEyebrow(configText(context, s.title)),
      const SizedBox(height: 10),
      NamedGapCard(
        title: configText(context, s.title),
        reason: localeText(
          context,
          'This section is declared in the app layout but nothing '
              'in the app fills it.',
          'Bu bölüm uygulama düzeninde tanımlı, ancak içerik bağlı değil.',
        ),
      ),
    ],
  );

  /// `program_engine` — kodda YOK. Uydurulmuş bir "günün planı" göstermek,
  /// sahte veri yasağının doğrudan ihlali olurdu.
  Widget _today(BuildContext context) => NamedGapCard(
    title: localeText(
      context,
      'No routine is built for you',
      'Sana özel bir rutin bulunmuyor',
    ),
    reason: localeText(
      context,
      'A daily routine is meant to be built from your own '
          'measurements. The part of Lissom that builds it is not in this '
          'build, so there is nothing here that would be yours.',
      'Kişisel günlük rutin oluşturan bölüm bu sürümde bulunmuyor.',
    ),
    detail: localeText(
      context,
      'We would rather show you an empty section than a routine we '
          'made up.',
      'Sana ait olmayan bir program göstermiyoruz.',
    ),
  );

  /// **DAVET.** Geri sayım estetiği yok, vade yok, suçlama yok.
  Widget _retest(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final SessionHistoryView h = facts.history;

    // "Hiç yapmadın" ≠ "bilmiyorum". Depo açılmadıysa SAYI ve TARİH
    // GÖSTERİLMEZ — boş liste burada bir bilgi değil, bir bilgisizliktir.
    if (!h.countsAreTrustworthy) {
      return NamedGapCard(
        title: localeText(
          context,
          "We couldn't open your history",
          'Ölçüm geçmişi açılamadı',
        ),
        reason: localeText(
          context,
          'Your measurements may be on this device — we just could not '
              'read the file, so we are not going to tell you a date either way.',
          'Ölçümlerin cihazda olabilir, ancak kayıt okunamadı. Bu yüzden '
              'tarih gösteremiyoruz.',
        ),
        detail: localizedHistoryFailureDetail(context, h.failure),
      );
    }

    final SessionRecord? last = h.mostRecent;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // ⚠️ Eskiden *"Measure when you are ready"* yazıyordu ve bu bir
            // DAVETTİ — yapılamayan bir eyleme. §5.2 hükmü "davet, geri sayım
            // değil" diyor; davetin ön koşulu eylemin MÜMKÜN olması.
            // (L-242, yayın envanteri.)
            last == null
                ? localeText(
                    context,
                    'No measurement has been taken here',
                    'Bu cihazda ölçüm yapılmamış',
                  )
                : localeText(
                    context,
                    'Your last measurement on this device',
                    'Bu cihazdaki son ölçümün',
                  ),
            style: t.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            last == null
                ? localeText(
                    context,
                    'Nothing has been measured on this device.',
                    'Bu cihazda kayıtlı ölçüm yok.',
                  )
                : localeTemplate(
                    context,
                    'Last measurement on this device: {date}.',
                    'Bu cihazdaki son ölçüm: {date}.',
                    <String, Object>{
                      'date': localizedDate(context, last.completedAt),
                    },
                  ),
            style: t.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          // Vade YOK ve NEDENİ yazılı. Bir gün sayısı uydurmak, ölçmediğimiz
          // bir aralığı ölçmüş gibi göstermek olurdu.
          Text(
            localeText(
              context,
              'Lissom does not set a date for your next measurement. How long '
                  'two measurements need to be apart to mean anything is something '
                  'we have not established, so we are not going to schedule you.',
              'Lissom bir sonraki ölçüm için tarih belirlemez. İki ölçüm '
                  'arasında anlamlı kabul edilecek süre doğrulanmadığı için '
                  'sana bir takvim sunmaz.',
            ),
            style: t.textTheme.bodySmall,
          ),
          if (h.countsAreFloor) ...<Widget>[
            const SizedBox(height: 10),
            _floorNote(context, t, h.unreadable),
          ],
        ],
      ),
    );
  }

  Widget _continue(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final SessionHistoryView h = facts.history;

    if (!h.countsAreTrustworthy) {
      return NamedGapCard(
        title: localeText(context, 'Unknown', 'Bilinmiyor'),
        reason: localeText(
          context,
          'Your history did not open, so we cannot say whether anything '
              'is in progress.',
          'Geçmiş açılmadığı için devam eden bir ölçüm olup olmadığını '
              'söyleyemiyoruz.',
        ),
      );
    }
    final SessionRecord? last = h.mostRecent;
    if (last == null) {
      return NamedGapCard(
        title: localeText(
          context,
          'Nothing in progress',
          'Devam eden ölçüm yok',
        ),
        reason: localeText(
          context,
          'Nothing has been measured on this device.',
          'Bu cihazda kayıtlı ölçüm yok.',
        ),
      );
    }
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            configText(context, facts.testNameFor(last.lessonId)),
            style: t.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            '${localizedDate(context, last.completedAt)} · '
            '${configText(context, _recordClassText(last))}',
            style: t.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Bugün gerçekten ölçülebilen testler — TÜRETİLİR, elle yazılmaz.
  Widget _quickStart(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<TestLiveness> live = facts.live;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            live.isEmpty
                ? localeText(
                    context,
                    'The measurement engine can read none of the twelve tests',
                    'Ölçüm motoru listelenen testlerin hiçbirini okuyamıyor',
                  )
                : localeTemplate(
                    context,
                    'The measurement engine can read {live} of {total} tests',
                    'Ölçüm motoru {total} testin {live} tanesini okuyabiliyor',
                    <String, Object>{
                      'live': localizedInteger(context, live.length),
                      'total': localizedInteger(context, facts.liveness.length),
                    },
                  ),
            style: t.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final TestLiveness x in live)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '· ${configText(context, x.name)}',
                style: t.textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              if (measurementAvailable && live.isNotEmpty)
                FilledButton(
                  key: startMeasurementKey,
                  // Bu düğme GERÇEKTEN bir yere gidiyor (2026-08-12, kamera-
                  // kabuğu sevki): `LiveCaptureScreen` bağlandı, `facts.live`
                  // TÜRETİLMİŞ ilk canlı testi açar — uydurma bir seçim
                  // değil, motorun GERÇEKTEN okuyabildiği testlerin ilki.
                  // Rota BEKLENİYOR (`await`): dönüşte geçmiş yeniden okunur.
                  // `push`u beklemeden bırakmak, ölçüm kaydını diskte doğru
                  // ama yüzeyde GÖRÜNMEZ bırakırdı (L-287).
                  onPressed: () async {
                    final guard = beforeMeasurement;
                    if (guard != null && !await guard(context)) {
                      return;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LiveCaptureScreen(
                          test: facts.battery.tests[live.first.testId]!,
                          batteryVersion: facts.battery.version,
                          // L-330: kurulum tarifi config'te vardı, hiçbir
                          // yüzeye ulaşmıyordu — köprü burada kuruluyor.
                          cameraSetup: facts.battery.cameraSetup,
                          ageBand: ageBand,
                          // A1 dikişi: üretimde İKİSİ DE `null` ⇒ ekran
                          // kendi varsayılanlarını kurar (`CameraPoseSource`
                          // / `openSessionStore`). Enjeksiyon yalnız
                          // yürüyüşü mümkün kılar, davranışı değiştirmez.
                          sourceOverride: poseSourceLoader?.call(),
                          storeLoader: sessionStoreLoader,
                          attemptValueStoreLoader: attemptValueStoreLoader,
                        ),
                      ),
                    );
                    onMeasurementDone?.call();
                  },
                  child: Text(
                    localeText(context, 'Start a measurement', 'Ölçümü başlat'),
                  ),
                ),
              OutlinedButton(
                onPressed: onOpenLibrary,
                child: Text(
                  localeText(
                    context,
                    'See what each test measures',
                    'Testlerin neyi ölçtüğünü gör',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _floorNote(
    BuildContext context,
    ThemeData t,
    int unreadable,
  ) => Text(
    localePlural(
      context,
      '{count} stored records could not be read, so anything counted here is a floor, not a total.',
      '{count} kayıt okunamadı. Burada gösterilen sayı toplam değil, '
          'okunabilen en az kayıt sayısıdır.',
      unreadable,
      englishOne:
          '{count} stored record could not be read, so anything counted here is a floor, not a total.',
    ),
    style: t.textTheme.bodySmall?.copyWith(
      color: LissomPalette.of(context).accentText,
    ),
  );

  /// Kaydın SINIFI kullanıcı diliyle. `lessonClass` yazım anında damgalanır —
  /// sonradan TÜRETİLMEZ, çünkü sonradan hesaplanan bir sınıf geçmişi sessizce
  /// yeniden yorumlar (çekirdeğin kendi şartı).
  static String _recordClassText(SessionRecord r) => switch (r.lessonClass) {
    'scored' => 'measured and compared with a reference range',
    'coached' => 'measured, below the lowest reference line',
    'qualitative' => 'measured, this test has no numeric range by design',
    'measurementOnly' => 'measured, not compared with any reference',
    'notMeasured' => 'attempted, no reading could be taken',
    // Bilinmeyen sınıf UYDURULMAZ. Çekirdeğin en-az-yetki kuralı: şüphede
    // daha AZ iddia et.
    _ => 'recorded',
  };
}
