/// **progress** sekmesi — **karşılaştırma KAPALI hâliyle.**
///
/// Bu ekran "eksik" değil; **tasarlanmış bir hâl.** Nedeni ölçüldü, üç
/// katmanı var ve üçü de yapısaldır:
///
/// **1. Geçmiş kaydında ÖLÇÜM DEĞERİ YOK — ve bu kasıtlı.** `SessionRecord`
/// şeması (çekirdek, M-F-193) bilerek hiçbir skor/değer alanı taşımıyor;
/// çekirdeğin kendi gerekçesi: *"recording zeros before the camera bridge
/// would draw zeros on tomorrow's progress chart."* Yani bir açı trendi
/// çizmek bugün **veri yokluğundan değil, ŞEMA KARARINDAN** imkânsız. Bir
/// trend çizgisi çizmek için önce uydurulmuş bir değer gerekirdi.
///
/// **2. Kıyas ön-koşulları DOĞRULANAMIYOR.** PRD §267 iki ölçümün ancak aynı
/// `modelVariant`, uyumlu config sürümü ve benzer `calibrationProfile`
/// altında kıyaslanabileceğini söylüyor. `SessionRecord` bu üç alanın
/// HİÇBİRİNİ taşımıyor (çekirdeğin notu: attempt-düzeyi köken bilgisi
/// ADR-005 gereği bilerek dışarıda). Yani kıyasın yapılabilir olduğunu
/// **kontrol edemiyoruz** — ve kontrol edemediğimiz bir koşulu varsaymak,
/// kıyası sessizce yapmak olurdu.
///
/// **3. MDC eşiği YOK.** Bir değişimin ölçüm gürültüsünden büyük olup
/// olmadığını söyleyemediğimiz sürece `improved`/`worsened` dili YASAK. Bu
/// ekranda o iki kelime GEÇMEZ (`progress_screen_test.dart` tarar).
///
/// Geriye kalan ve **gerçek** olan şey: neyin, ne zaman, hangi rejimde
/// kaydedildiği. Bu bir trend değil, bir DEFTER — ve defter dürüsttür.
library;

import 'package:flutter/material.dart';
import 'package:motion_core/motion_core.dart';

import 'app_facts.dart';
import 'lissom_theme.dart';
import 'session_history_view.dart';
import 'surfaces.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({required this.facts, super.key});

  static const Key comparisonNoticeKey = Key('progress.comparisonOff');

  /// **ÖLÇÜLEN SAYI SAKLANMIYOR — ve bu söyleniyor (L-316).**
  ///
  /// Ölçüldü: `AssessmentResult` `value`·`unit`·`bandLabel`·`provenance`
  /// taşıyor; çekirdeğin `SessionRecord`unda dördünün de karşılığı YOK, yani
  /// çeviri sırasında **düşüyorlar**. Kullanıcı 147,5° ölçüyor, sonucu bir kez
  /// görüyor, ve o sayı bir daha hiçbir yerde yok.
  ///
  /// Bu ekranın altyazısı *"what was measured, when, and under what
  /// conditions"* diyordu — **üç vaatten yalnız biri karşılanıyordu.**
  /// Sessizce bırakmak, kullanıcının sakladığını sandığı şeyi yok saymaktı.
  static const Key readingNotKeptKey = Key('progress.readingNotKept');
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
          const CaptureUnavailableNote(),
          // ⛔ Altyazı ÜÇ vaat ediyordu — *"what was measured, when, and under
          // what conditions"* — ve depo yalnız **birini** karşılıyordu:
          // koşullar hiç saklanmıyor, ölçülen sayı da saklanmıyor. Vaadi
          // kısaltmak, karşılığı olmayan yarısını kesmek demek; kesilen yarı
          // aşağıdaki kartta ADIYLA anlatılıyor, sessizce düşürülmüyor.
          const SectionHeading(
            'Your record',
            subtitle: 'Which test you measured, and when.',
          ),
          const SizedBox(height: 18),

          // ⭐ A3'ün ikinci kolu, geçmiş katmanında: iş sunamıyorsan NEDEN
          // sunmadığını söyle. Kıyas kartıyla aynı yerde ve aynı tonda —
          // envanter, özür değil.
          Padding(
            key: readingNotKeptKey,
            padding: const EdgeInsets.only(bottom: 20),
            child: LissomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LissomEyebrow('The reading itself is not kept',
                      color: LissomColors.roseDeepHover),
                  const SizedBox(height: 8),
                  Text(
                    'When you measure, Lissom shows you the number once. It '
                    'is not written down, so this list can tell you that a '
                    'test was measured — not what it came to.',
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
                  Text(
                    'What a session stores is shared with the other apps '
                    'built on the same measurement core, and that shared '
                    'record has no place for the number itself. We would '
                    'rather tell you it is gone than let this page look like '
                    'a history of your numbers.',
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
                  LissomEyebrow('No comparison is made here',
                      color: LissomColors.roseDeepHover),
                  const SizedBox(height: 8),
                  Text(
                    'Lissom does not draw a trend line for you, and it does '
                    'not tell you whether a measurement went up or down.',
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Two measurements can only be set against each other when '
                    'they were taken with the same model, a compatible '
                    'configuration and a similar camera setup. What we store '
                    'about a past session does not record any of those three, '
                    'so we cannot check that they hold — and we are not going '
                    'to compare on the assumption that they did.',
                    style: t.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We also have no figure for how much a reading can move '
                    'on its own between two sessions. Without it, calling a '
                    'change real would be a guess.',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          if (!h.countsAreTrustworthy)
            NamedGapCard(
              key: unavailableKey,
              title: "Your history didn't open",
              reason: 'We are not going to show you a count, because an empty '
                  'list here would read as "you never measured" — and we do '
                  'not know that.',
              detail: h.failure,
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
              title: 'Your readings are here, but we cannot read them',
              reason: '${h.unreadable} recorded reading'
                  '${h.unreadable == 1 ? '' : 's'} could not be read by this '
                  'version of Lissom. They are still on this phone — we are '
                  'not going to tell you the list is empty when it is not.',
              detail: 'This usually means the file was written by a different '
                  'version. Nothing was deleted.',
            )
          else if (!h.hasRecords)
            const NamedGapCard(
              key: emptyKey,
              title: 'Nothing recorded on this device',
              // ⛔ *"…anything here **yet**"* diye yazmıştım ve `wellness_lint`
              // reddetti: **`yet` bir VAATTİR** (M-F-186) — bilmediğimiz bir
              // tarihi ima eder. Kural zaten `library_screen.dart`ta yazılıydı
              // ve ben tam onu ihlal ederek DÜRÜSTLÜK metni yazdım.
              // > *Bir kuralı bilmek, onu yazarken uygulamak değildir —
              // > uygulayan şey KAPIDIR.*
              // Başlık zaten *"Nothing recorded on this device"* diyor;
              // gerekçe onu TEKRARLAMAZ, devam eder (cihazda görüldü: iki
              // cümle üst üste aynı şeyi söylüyordu).
              reason: 'When you measure, the test and the date it was taken '
                  'appear in this list.',
              detail: 'The reading itself will not — see above for why.',
            )
          else ...<Widget>[
            if (h.countsAreFloor) ...<Widget>[
              _floorBanner(t, h.unreadable),
              const SizedBox(height: 14),
            ],
            LissomEyebrow('Recorded readings (${h.records.length})'),
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

          const MeasurementLimitsFootnote(),
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
      List<SessionRecord> records) {
    final List<MapEntry<DateTime, List<SessionRecord>>> out =
        <MapEntry<DateTime, List<SessionRecord>>>[];
    for (final SessionRecord r in records) {
      if (out.isNotEmpty && out.last.key == r.completedAt) {
        out.last.value.add(r);
      } else {
        out.add(MapEntry<DateTime, List<SessionRecord>>(
            r.completedAt, <SessionRecord>[r]));
      }
    }
    return out;
  }

  List<Widget> _ledgerChildren(List<SessionRecord> records) {
    final List<Widget> out = <Widget>[];
    for (final MapEntry<DateTime, List<SessionRecord>> s
        in _bySitting(records)) {
      out.add(Padding(
        key: sittingKeyFor(s.key),
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: _SittingHeader(at: s.key, count: s.value.length),
      ));
      for (final SessionRecord r in s.value) {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _LedgerRow(record: r, facts: facts),
        ));
      }
      out.add(const SizedBox(height: 14));
    }
    return out;
  }

  /// Kayıp kayıt varsa sayı bir ALT SINIRDIR ve bu SÖYLENİR (M-F-228: 40/50
  /// bozukken "10 oturum" demek, kullanıcının yaptığı işi silmekti).
  static Widget _floorBanner(ThemeData t, int unreadable) => LissomCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Text(
          '$unreadable stored record${unreadable == 1 ? '' : 's'} on this '
          // ⚠️ Burada eskiden "treat it as a floor" yazıyordu ve genişletilmiş
          // wellness süzgeci ilk koşuşunda yakaladı. Masum anlamda kullanılmış
          // olsa da `treat` mağaza incelemesinin taradığı kelimelerden biri —
          // bir wellness ürününde onu hiç kullanmamak en ucuz seçenek.
          'device could not be read. The list below is what we could read — '
          'a floor, not a total.',
          style: t.textTheme.bodyMedium
              ?.copyWith(color: LissomColors.roseDeepHover),
        ),
      );
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
  const _SittingHeader({required this.at, required this.count, super.key});
  final DateTime at;
  final int count;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Text(
      '${_LedgerRow._dateOf(at)} · $count reading${count == 1 ? '' : 's'}',
      style: t.textTheme.titleSmall?.copyWith(color: LissomColors.bodySecondary),
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
          Text(facts.testNameFor(record.lessonId),
              style: t.textTheme.titleMedium),
          // ⛔ Tarih SATIRDAN kaldırıldı (L-324): oturum başlığı onu bir kez
          // söylüyor. Satırda tekrarlanınca tek oturum, tarihi 12 kez basan
          // 12 ayrı oturum gibi okunuyordu.
          const SizedBox(height: 8),
          Text(_regime(record), style: t.textTheme.bodyMedium),
          if (record.unmeasuredUnits > 0) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              '${record.unmeasuredUnits} attempt'
              '${record.unmeasuredUnits == 1 ? '' : 's'} could not be read'
              '${record.unmeasuredReason == null ? '' : ' · '
                  '${_reasonText(record.unmeasuredReason!)}'}',
              style:
                  t.textTheme.bodySmall?.copyWith(color: LissomColors.bodySecondary),
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

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _dateOf(DateTime d) {
    final DateTime l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }
}
