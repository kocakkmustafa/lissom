/// **progress** sekmesi — **karşılaştırma KAPALI hâliyle.**
///
/// Bu ekran "eksik" değil; **tasarlanmış bir hâl.** Nedeni ölçüldü, üç
/// katmanı var:
///
/// **1. Bu EKRANIN kaydında ÖLÇÜM DEĞERİ YOK — ve bu hâlâ kasıtlı.**
/// `SessionRecord` şeması (çekirdek, M-F-193) bilerek hiçbir skor/değer
/// alanı taşımıyor; çekirdeğin kendi gerekçesi: *"recording zeros before
/// the camera bridge would draw zeros on tomorrow's progress chart."*
/// ⚠️ **GÜNCELLEME (D13/F2, 2026-08-16): değer artık TAMAMEN kayıp değil —**
/// Lissom-sahipli bir yan defter (`attempt_values.jsonl`) onu ayrıca
/// tutuyor ve her testin KENDİ sayfasında (Library → bir test) HAM olarak
/// gösteriliyor. Bu ekranın DEFTERİ hâlâ değeri taşımıyor (çekirdek şeması
/// değişmedi, D13'ün kendi sınırı) — ama *"bir açı trendi çizmek imkânsız"*
/// artık YANLIŞ: çiziliyor, yalnız BURADA değil. Kart bunu adıyla söylüyor
/// (`readingKeptElsewhereKey`).
///
/// **2. Kıyas ön-koşulları KISMEN doğrulanabilir hâle geldi.** PRD §267 iki
/// ölçümün ancak aynı `modelVariant`, uyumlu config sürümü ve benzer
/// `calibrationProfile` altında kıyaslanabileceğini söylüyor.
/// `AttemptValue.provenance` artık `modelId`+`batteryVersion`i taşıyor
/// (`calibrationProfile` hâlâ boş, M-F-07 alanı) — ama bu ekran ve test
/// detay sayfası bu bilgiyi KIYAS için KULLANMIYOR, yalnız TAŞIYOR: bir
/// gün kıyas kurulursa dayanağı hazır, bugün kurulu değil.
///
/// **3. MDC eşiği YOK — değişmedi.** Bir değişimin ölçüm gürültüsünden
/// büyük olup olmadığını söyleyemediğimiz sürece `improved`/`worsened`
/// dili YASAK, hem burada hem test detay sayfasında. Bu iki ekranda o
/// kelimeler GEÇMEZ (`progress_screen_test.dart` + `test_detail_screen_
/// test.dart` tarar; `test/support/copy_gate.dart`'a `better than`/
/// `worse than` da eklendi, doküman iddia ediyordu liste karşılamıyordu).
///
/// Geriye kalan ve bu ekran için **gerçek** olan şey: neyin, ne zaman,
/// hangi rejimde kaydedildiği. Bu bir trend değil, bir DEFTER — ve defter
/// dürüsttür, artık *"değer başka yerde yaşıyor"* diyerek dürüst.
library;

import 'package:flutter/material.dart';
import 'package:motion_core/motion_core.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'app_facts.dart';
import 'hatha_course.dart';
import 'hatha_course_screen.dart';
import 'hatha_progress.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';
import 'session_history_view.dart';
import 'surfaces.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    required this.facts,
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  final bool measurementAvailable;

  static const Key comparisonNoticeKey = Key('progress.comparisonOff');

  /// **ÖLÇÜLEN SAYI ARTIK SAKLANIYOR — ama BU EKRANDA DEĞİL (D13/F2).**
  ///
  /// Eski ad `readingNotKeptKey`di ve L-316'nın bulduğu kaybı anlatıyordu:
  /// `AssessmentResult` `value`·`unit`·`bandLabel`·`provenance` taşıyordu,
  /// çekirdeğin `SessionRecord`unda dördünün de karşılığı yoktu, sayı bir
  /// daha hiçbir yerde yoktu. **Artık öyle değil** — `attempt_values.jsonl`
  /// onu tutuyor. Anahtarı yeniden adlandırdım: bir kart artık TERSİNİ
  /// söylerken eski adını taşımak, H-31'in kendi dersini (bayat isim =
  /// yanlış bilgi) bu dosyada tekrarlamak olurdu.
  ///
  /// Bu ekranın altyazısı *"what was measured, when, and under what
  /// conditions"* diyordu — hâlâ üçün ikisini karşılıyor (koşullar hâlâ
  /// saklanmıyor). Üçüncüsü (değer) artık kayıp değil, YÖNLENDİRİLİYOR.
  static const Key readingKeptElsewhereKey = Key(
    'progress.readingKeptElsewhere',
  );
  static const Key ledgerKey = Key('progress.ledger');

  /// Bir OTURUM başlığının anahtar ÖN EKİ (L-324). Her başlık kendi zaman
  /// damgasıyla anahtarlanır — **aynı `Key` iki widget'ta kullanılamaz**, ve
  /// testin "kaç oturum çizildi" sorusu ancak sayılabilir anahtarlarla
  /// cevaplanır.
  static const String sittingKeyPrefix = 'progress.sitting.';

  static Key sittingKeyFor(DateTime at) =>
      Key('$sittingKeyPrefix${at.toIso8601String()}');
  static const Key emptyKey = Key('progress.empty');

  /// **HEPSİ okunamadı** hâli (L-325). `emptyKey`den AYRI, çünkü ikisi
  /// **farklı olgular**: biri *"ölçmedin"*, öteki *"ölçtün ama okuyamıyoruz"*.
  /// Aynı kartı paylaşsalardı ayrım yüzeyde kaybolurdu — ve kaybolan tam
  /// olarak kullanıcının işiydi.
  static const Key unreadableAllKey = Key('progress.unreadableAll');
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
          CaptureUnavailableNote(measurementAvailable: measurementAvailable),
          // ⛔ Altyazı ÜÇ vaat ediyordu — *"what was measured, when, and under
          // what conditions"* — ve depo yalnız **birini** karşılıyordu:
          // koşullar hiç saklanmıyor, ölçülen sayı da saklanmıyor. Vaadi
          // kısaltmak, karşılığı olmayan yarısını kesmek demek; kesilen yarı
          // aşağıdaki kartta ADIYLA anlatılıyor, sessizce düşürülmüyor.
          SectionHeading(
            localeText(context, 'Your record', 'Ölçüm kaydın'),
            subtitle: localeText(
              context,
              'Which test you measured, and when.',
              'Hangi testi ne zaman ölçtüğün.',
            ),
          ),
          const SizedBox(height: 18),
          // ⭐ A3'ün ikinci kolu, geçmiş katmanında: iş sunamıyorsan NEDEN
          // sunmadığını söyle. Kıyas kartıyla aynı yerde ve aynı tonda —
          // envanter, özür değil.
          Padding(
            key: readingKeptElsewhereKey,
            padding: const EdgeInsets.only(bottom: 20),
            child: LissomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LissomEyebrow(
                    localeText(
                      context,
                      'The number lives on each test\'s own page',
                      'Ölçülen değer testin kendi sayfasında',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      'This list is shared with the other apps built on the '
                          'same measurement core, and that shared record still '
                          'has no place for the number itself — it can only tell '
                          'you that a test was measured, not what it came to.',
                      'Bu liste ortak ölçüm altyapısının kaydını gösterir. '
                          'Testin yapıldığını söyler; sayısal değeri burada '
                          'tutmaz.',
                    ),
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  // 🪤 **KENDİ EKLEDİĞİM TEKRARI KENDİM KALDIRDIM (L-322).**
                  // İlk yazımım *"…no place for a value **or for the
                  // conditions** a reading was taken under"* diyordu. Ama
                  // koşulları ALTTAKİ kıyas kartı zaten anlatıyor — üstelik
                  // **daha kesin**, üçünü adıyla sayarak (*"the same model, a
                  // compatible configuration and a similar camera setup"*).
                  // İki kart aynı eksikliği söylüyordu; bu, `L-320`'de
                  // düzelttiğim tekrar sınıfının **aynısı** ve yarısını bu
                  // gece BEN ürettim.
                  // > ***BİR TEKRARI DÜZELTİRKEN YENİSİNİ ÜRETMEK, KURALI
                  // > ÖĞRENMEDEN VAKAYI KAPATMAKTIR.***
                  // ⇒ Sınır: bu kart **DEĞERİ**, alttaki kart **KOŞULLARI**
                  // anlatır. Her eksikliğin tek sahibi var.
                  //
                  // D13/F2 — VAAT ARTIK TUTULABİLİR (L-316'nın kapanışı):
                  // sayı kayıp değil, Lissom-sahipli bir yan deftere yazılıp
                  // testin KENDİ sayfasında ham olarak gösteriliyor. Bu kart
                  // hâlâ dürüst: BU EKRANIN kendisi değeri taşımıyor
                  // (paylaşılan çekirdek şeması değişmedi) — ama artık
                  // "kayıp" demiyor, "başka yerde" diyor.
                  Text(
                    localeText(
                      context,
                      'The number is not lost, though: Lissom keeps it '
                          'separately, next to the test it belongs to. Open a '
                          'test from Library to see your last reading and '
                          'everything measured before it.',
                      'Değer kaybolmaz: Lissom onu ilgili testin sayfasında '
                          'ayrı tutar. Son ve önceki ölçümlerini görmek '
                          'için testi Kütüphane’den aç.',
                    ),
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

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
                  LissomEyebrow(
                    localeText(
                      context,
                      'No comparison is made here',
                      'Burada karşılaştırma yapılmaz',
                    ),
                    color: LissomColors.roseDeepHover,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      'Lissom does not draw a trend line for you, and it does '
                          'not tell you whether a measurement went up or down.',
                      'Lissom eğilim grafiği çizmez; ölçümün artıp '
                          'azaldığına dair hüküm vermez.',
                    ),
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  // D13/F2 — ÜÇÜN İKİSİ ARTIK KAYDEDİLİYOR (bkz. üstteki
                  // kart), ama bu KIYASI KURMUYOR: `AttemptValue.provenance`
                  // taşıyor, hiçbir yüzey onu KARŞILAŞTIRMAK için OKUMUYOR.
                  // Eski cümle ("does not record any of those three") artık
                  // yanlış — düzeltmemek H-31'in ders verdiği türden bir
                  // bayat iddia bırakırdı.
                  Text(
                    localeText(
                      context,
                      'Two measurements can only be set against each other when '
                          'they were taken with the same model, a compatible '
                          'configuration and a similar camera setup. Each reading\'s '
                          'model and configuration are recorded next to it now — '
                          'camera setup still is not — but nothing on this screen '
                          'or a test\'s own page compares any of that for you.',
                      'İki ölçüm ancak aynı model, uyumlu ayarlar ve benzer '
                          'kamera kurulumuyla alındığında karşılaştırılabilir. '
                          'Model ve yapılandırma kaydedilir, ancak kamera '
                          'kurulumu kaydedilmez. Bu ekran karşılaştırma yapmaz.',
                    ),
                    style: t.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      'We also have no figure for how much a reading can move '
                          'on its own between two sessions. Without it, calling a '
                          'change real would be a guess.',
                      'Ölçümün iki oturum arasında kendiliğinden ne kadar '
                          'değişebileceği de belirlenmedi. Bu olmadan bir '
                          'farka gerçek değişim diyemeyiz.',
                    ),
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          if (facts.hatha != null && facts.hathaProgress != null) ...<Widget>[
            _HathaProgressCard(
              course: facts.hatha!,
              progress: facts.hathaProgress!,
            ),
            const SizedBox(height: 18),
          ],

          if (facts.ashtanga != null && facts.hathaProgress != null) ...<Widget>[
            _HathaProgressCard(course: facts.ashtanga!, progress: facts.hathaProgress!),
            const SizedBox(height: 18),
          ],
          if (facts.yin != null && facts.hathaProgress != null) ...<Widget>[
            _HathaProgressCard(course: facts.yin!, progress: facts.hathaProgress!),
            const SizedBox(height: 18),
          ],
          if (facts.vinyasa != null && facts.hathaProgress != null) ...<Widget>[
            _HathaProgressCard(course: facts.vinyasa!, progress: facts.hathaProgress!),
            const SizedBox(height: 18),
          ],
          if (facts.chairOffice != null && facts.hathaProgress != null) ...<Widget>[
            _HathaProgressCard(
              course: facts.chairOffice!,
              progress: facts.hathaProgress!,
            ),
            const SizedBox(height: 18),
          ],

          if (!h.countsAreTrustworthy)
            NamedGapCard(
              key: unavailableKey,
              title: localeText(
                context,
                "Your history didn't open",
                'Geçmişin açılamadı',
              ),
              reason: localeText(
                context,
                'We are not going to show you a count, because an empty '
                    'list here would read as "you never measured" — and we do '
                    'not know that.',
                'Kayıtları okuyamadığımız için sayı göstermiyoruz. Boş liste hiç ölçüm yapmadığın anlamına gelmeyebilir.',
              ),
              detail: localizedHistoryFailureDetail(context, h.failure),
            )
          // 🔴 **BU METİN İKİ KEZ YALAN SÖYLÜYORDU — cihazda yürüyerek bulundu
          // (L-317), hiçbir test göremezdi.** Eski hâli:
          //   *"No session can be captured in this build, so there is nothing
          //    to list. When one can, every reading it produced appears here
          //    with its date and conditions."*
          //
          // ① *"No session can be captured in this build"* — **BAYAT.** A1
          //    kapandı (L-309): ölçüm uçtan uca koşuyor ve depoya YAZIYOR.
          //    Cümle kamera köprüsünden ÖNCE yazılmıştı ve köprü gelince
          //    kimse geri dönüp onu okumadı.
          // ② *"every reading … appears here with its date and conditions"* —
          //    bu ekranın ÜÇ KART YUKARISI *"the reading itself is not kept …
          //    no place for a value or for the conditions"* diyor.
          //    **Aynı ekran aynı şeyi hem vaat edip hem reddediyordu.**
          //
          // ⛔ İkisini de hiçbir kapı yakalayamazdı: her iki metin de ÇİZİLİYOR,
          // her iki testi de YEŞİL, ve hiçbir kapı bir ekrandaki İKİ CÜMLEYİ
          // birbirine karşı okumaz.
          // > ***BİR EKRANIN İÇ TUTARLILIĞI, PARÇALARININ TEK TEK
          // > DOĞRULUĞUNDAN ÇIKMAZ — ve onu ancak EKRANI YÜRÜYEN görür.***
          // 🔴 **OKUNAMAYAN GEÇMİŞ, BOŞ GEÇMİŞ DEĞİLDİR (C-280 / H-13, L-325).**
          // Bu kusuru KAZARA yaşadım: cihaza 6 kayıt enjekte ettim, hepsi şema
          // sürümü yüzünden okunamadı, ve ekran *"Nothing recorded on this
          // device"* dedi. Kullanıcının **6 kaydı vardı.**
          //
          // Yapısal sebep: `records=[] ∧ unreadable>0` ⇒ `partial` ⇒
          // `countsAreTrustworthy=true` ∧ `hasRecords=false` ⇒ boş-hâl dalı
          // kazanıyordu; taban uyarısı ise yalnız **kayıt VARKEN** çizilen
          // dalda duruyordu.
          // > ***BİR KAYBI YALNIZ "BİR ŞEY KALDIYSA" GÖSTEREN YÜZEY, HER ŞEYİ
          // > KAYBEDEN KULLANICIYA HİÇBİR ŞEY SÖYLEMEZ.***
          else if (!h.hasRecords && h.unreadable > 0)
            NamedGapCard(
              key: unreadableAllKey,
              title: localeText(
                context,
                'Your readings are here, but we cannot read them',
                'Ölçümlerin var, ancak okunamıyor',
              ),
              reason: localePlural(
                context,
                '{count} recorded readings could not be read by this version of Lissom. They are still on this phone — we are not going to tell you the list is empty when it is not.',
                '{count} kayıt bu Lissom sürümünde okunamadı. Kayıtlar hâlâ bu telefonda; listeyi boş saymıyoruz.',
                h.unreadable,
                englishOne: '{count} recorded reading could not be read by this version of Lissom. They are still on this phone — we are not going to tell you the list is empty when it is not.',
              ),
              detail: localeText(
                context,
                'This usually means the file was written by a different version. Nothing was deleted.',
                'Dosya başka bir sürümde yazılmış olabilir. Hiçbir kayıt silinmedi.',
              ),
            )
          else if (!h.hasRecords)
            NamedGapCard(
              key: emptyKey,
              title: localeText(
                context,
                'Nothing recorded on this device',
                'Bu cihazda kayıt yok',
              ),
              // ⛔ *"…anything here **yet**"* diye yazmıştım ve `wellness_lint`
              // reddetti: **`yet` bir VAATTİR** (M-F-186) — bilmediğimiz bir
              // tarihi ima eder. Kural zaten `library_screen.dart`ta yazılıydı
              // ve ben tam onu ihlal ederek DÜRÜSTLÜK metni yazdım.
              // > *Bir kuralı bilmek, onu yazarken uygulamak değildir —
              // > uygulayan şey KAPIDIR.*
              // Başlık zaten *"Nothing recorded on this device"* diyor;
              // gerekçe onu TEKRARLAMAZ, devam eder (cihazda görüldü: iki
              // cümle üst üste aynı şeyi söylüyordu).
              reason: localeText(
                context,
                'When you measure, the test and the date it was taken appear in this list.',
                'Ölçüm yaptığında test adı ve tarihi burada görünür.',
              ),
              detail: localeText(
                context,
                'The reading itself will not — see above for why.',
                'Sayısal değer testin kendi sayfasında gösterilir.',
              ),
            )
          else ...<Widget>[
            if (h.countsAreFloor) ...<Widget>[
              _floorBanner(context, t, h.unreadable),
              const SizedBox(height: 14),
            ],
            LissomEyebrow(
              localeTemplate(
                context,
                'Recorded readings ({count})',
                'Kayıtlı ölçümler ({count})',
                <String, Object>{'count': localizedInteger(context, h.records.length)},
              ),
            ),
            const SizedBox(height: 10),
            // 🔴 **KAYIT BİRİMİ ≠ GÖSTERİM BİRİMİ (L-324).**
            // `appendPreserved()` **test başına** bir kayıt yazar ve bu doğru
            // (bir bloğun testleri sınıf bakımından KARIŞIK —
            // `assessment_history.dart` §1). Ama liste DÜZ çizilince, tek
            // oturumda 12 test ölçen kullanıcı **aynı tarihi taşıyan 12
            // satır** görüyordu: hiçbir şey bunların **tek bir oturum**
            // olduğunu söylemiyordu, ve tarih 12 kez tekrarlandığı için
            // ekran *"on iki ayrı kez ölçtün"* diye okunuyordu.
            // > ***KAYIT BİRİMİ İLE GÖSTERİM BİRİMİ AYNI OLMAK ZORUNDA
            // > DEĞİLDİR — VE İKİSİNİ AYNI VARSAYMAK, DOĞRU KAYDEDİLMİŞ BİR
            // > ŞEYİ YANLIŞ GÖSTERİR.***
            // ⛔ Şemaya dokunulmadı: bu tamamen SUNUM katmanı.
            Column(
              key: ledgerKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _ledgerChildren(h.records),
            ),
          ],

          MeasurementLimitsFootnote(measurementAvailable: measurementAvailable),
        ],
      ),
    );
  }

  /// Kayıtları OTURUMA göre böler — sıra KORUNUR (depo zaten en yeniden
  /// eskiye veriyor; burada yeniden sıralamak, deponun sırasını sessizce
  /// ezmek olurdu).
  ///
  /// Birim `completedAt`in KENDİSİ: `appendPreserved()` tek bir oturumun tüm
  /// ölçümlerini **aynı** damgayla yazar. ⛔ Güne göre gruplamak YANLIŞ olurdu
  /// — aynı gün iki kez ölçen kullanıcının iki oturumu tek yığına düşerdi.
  List<MapEntry<DateTime, List<SessionRecord>>> _bySitting(
    List<SessionRecord> records,
  ) {
    final List<MapEntry<DateTime, List<SessionRecord>>> out =
        <MapEntry<DateTime, List<SessionRecord>>>[];
    for (final SessionRecord r in records) {
      if (out.isNotEmpty && out.last.key == r.completedAt) {
        out.last.value.add(r);
      } else {
        out.add(
          MapEntry<DateTime, List<SessionRecord>>(
            r.completedAt,
            <SessionRecord>[r],
          ),
        );
      }
    }
    return out;
  }

  List<Widget> _ledgerChildren(List<SessionRecord> records) {
    final List<Widget> out = <Widget>[];
    for (final MapEntry<DateTime, List<SessionRecord>> s in _bySitting(
      records,
    )) {
      out.add(
        Padding(
          key: sittingKeyFor(s.key),
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: _SittingHeader(at: s.key, count: s.value.length),
        ),
      );
      for (final SessionRecord r in s.value) {
        out.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LedgerRow(record: r, facts: facts),
          ),
        );
      }
      out.add(const SizedBox(height: 14));
    }
    return out;
  }

  /// Kayıp kayıt varsa sayı bir ALT SINIRDIR ve bu SÖYLENİR (M-F-228: 40/50
  /// bozukken "10 oturum" demek, kullanıcının yaptığı işi silmekti).
  static Widget _floorBanner(
    BuildContext context,
    ThemeData t,
    int unreadable,
  ) => LissomCard(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    child: Text(
      localePlural(
        context,
        '{count} stored records on this device could not be read. The list below is what we could read — a floor, not a total.',
        '{count} kayıt okunamadı. Aşağıdaki liste toplam değil, okunabilen kayıtlardır.',
        unreadable,
        englishOne: '{count} stored record on this device could not be read. The list below is what we could read — a floor, not a total.',
      ),
      style: t.textTheme.bodyMedium?.copyWith(
        color: LissomColors.roseDeepHover,
      ),
    ),
  );
}

class _HathaProgressCard extends StatelessWidget {
  const _HathaProgressCard({required this.course, required this.progress});

  final HathaCourse course;
  final HathaProgress progress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Set<String> practiced = progress.practicedIn(course);
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            localeText(
              context,
              course.id == 'lissom.chair-office.beginner'
                  ? 'Chair / office practice' : course.id == 'lissom.vinyasa.supported-standing.beginner' ? 'Vinyasa participation' : course.id == 'lissom.yin.supported.beginner' ? 'Yin participation' : course.isAshtanga ? 'Ashtanga participation' : 'Hatha practice',
              course.id == 'lissom.chair-office.beginner'
                  ? 'Sandalye / ofis çalışması' : course.id == 'lissom.vinyasa.supported-standing.beginner' ? 'Vinyasa katılımı' : course.id == 'lissom.yin.supported.beginner' ? 'Yin katılımı' : course.isAshtanga ? 'Ashtanga katılımı' : 'Hatha çalışması',
            ),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            localeTemplate(
              context,
              course.recordsParticipation
                  ? '{done}/{total} units with participation records · self-recorded; physical skill is not established.'
                  : '{done}/{total} lessons practised · self-recorded',
              course.recordsParticipation
                  ? '{done}/{total} birimde katılım kaydı · öz kayıt; fiziksel beceri gösterilmez.'
                  : '{done}/{total} ders çalışıldı · öz kayıt',
              <String, Object>{
                'done': localizedInteger(context, practiced.length),
                'total': localizedInteger(context, course.lessons.length),
              },
            ),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: IntrinsicColumnWidth(),
            },
            children: <TableRow>[
              for (final HathaModule module in course.modules)
                TableRow(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(hathaText(context, module.title)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '${localizedInteger(context, module.lessons.where((HathaLesson l) => practiced.contains(l.id)).length)}/${localizedInteger(context, module.lessons.length)}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (progress.unreadableRecords > 0) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              localePlural(
                context,
                '{count} practice records could not be read.',
                '{count} çalışma kaydı okunamadı.',
                progress.unreadableRecords,
                englishOne: '{count} practice record could not be read.',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Defter satırı — bir OLGU, bir hüküm değil.
///
/// Ölçülemeyen denemeler DÜŞÜRÜLMEZ: kullanıcı o işi gerçekten yaptı ve
/// sebebi isimli. Kaydetmemek, yarın yüzeyin "1 deneme" demesine yol açardı —
/// kullanıcı 1 yapmış ve o ölçülememişken. Sessizlik yalan söyler.
/// Bir OTURUMUN başlığı — tarih **bir kez**, ve kaç ölçüm içerdiği.
///
/// ⛔ Sayı `count`tan gelir, `plannedUnits` toplamından DEĞİL: kullanıcının
/// gerçekten aldığı ölçüm sayısı, uygulamanın planladığı sayı değil.
/// ⛔ Ve *"session"* kelimesi yüzeye çıkmıyor — dahili sözlük. Kullanıcı için
/// bu bir TARİH ve o tarihte kaç okuma alındığı.
class _SittingHeader extends StatelessWidget {
  const _SittingHeader({required this.at, required this.count});
  final DateTime at;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Text(
      localePlural(
        context,
        '{date} · {count} readings',
        '{date} · {count} ölçüm',
        count,
        englishOne: '{date} · {count} reading',
        arguments: <String, Object>{'date': localizedDate(context, at)},
      ),
      style: t.textTheme.titleSmall?.copyWith(
        color: LissomColors.bodySecondary,
      ),
    );
  }
}

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
          Text(
            configText(context, facts.testNameFor(record.lessonId)),
            style: t.textTheme.titleMedium,
          ),
          // ⛔ Tarih SATIRDAN kaldırıldı (L-324): oturum başlığı onu bir kez
          // söylüyor. Satırda tekrarlanınca tek oturum, tarihi 12 kez basan
          // 12 ayrı oturum gibi okunuyordu.
          const SizedBox(height: 8),
          Text(
            localeText(context, _regime(record), _regimeTr(record)),
            style: t.textTheme.bodyMedium,
          ),
          if (record.unmeasuredUnits > 0) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              localePlural(
                context,
                '{count} attempts could not be read{reason}',
                '{count} deneme okunamadı{reason}',
                record.unmeasuredUnits,
                englishOne: '{count} attempt could not be read{reason}',
                arguments: <String, Object>{
                  'reason': record.unmeasuredReason == null ? '' : ' · ${localeText(context, _reasonText(record.unmeasuredReason!), _reasonTextTr(record.unmeasuredReason!))}',
                },
              ),
              style: t.textTheme.bodySmall?.copyWith(
                color: LissomColors.bodySecondary,
              ),
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

  static String _regimeTr(SessionRecord r) => switch (r.lessonClass) {
    'scored' => 'Ölçüldü ve referans aralığıyla değerlendirildi.',
    'coached' =>
      'Ölçüldü; değer en düşük referans çizgisinin altında. Bu değer için aralık etiketi verilmez.',
    'qualitative' =>
      'Ölçüldü. Bu test sayısal aralık yerine açıklamalı düzeyler kullanır.',
    'measurementOnly' =>
      'Ölçüldü. Referans aralığı uygulanmadı; bu değer yorum içermez.',
    'notMeasured' => 'Denendi. Ölçüm alınamadı.',
    _ => 'Kaydedildi.',
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

  static String _reasonTextTr(String code) => switch (code) {
    'noAttemptDetected' => 'hareket algılanmadı',
    'setupTimedOut' => 'kurulum zamanında tamamlanmadı',
    'measurementTimedOut' => 'ölçüm zamanında tamamlanmadı',
    'aborted' => 'duruş denetimi denemeyi durdurdu',
    'trackingLost' => 'kamera takibi kaybetti',
    'lowConfidence' => 'ölçüm güvenilir bulunmadı',
    _ => 'neden kaydedilmedi',
  };

}
