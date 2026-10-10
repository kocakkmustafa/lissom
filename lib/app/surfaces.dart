/// Dört sekmenin PAYLAŞTIĞI yüzey birimleri.
///
/// Tek adres olmalarının sebebi görsel tutarlılık DEĞİL, dürüstlük: aynı
/// beyanı üç ekranda üç farklı tonda yazmak, üçünden ikisinin sessizce
/// yumuşamasına yol açar. Beyan bir kez yazılır, üç yerde GÖSTERİLİR.
///
/// ⛔ Bu dosyada **hiçbir dolum/gauge biçimi yoktur ve olmayacaktır** —
/// `LinearProgressIndicator`, halka, yüzde kalbi, dolum çubuğu. §5.1 hükmü:
/// 50°'de neredeyse boş bir çubuk, grafikle söylenmiş bir "yetersizsin"
/// hükmüdür. `no_gauge_test.dart` bu dosyayı ve kardeşlerini TARAR.
library;

import 'package:flutter/material.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'ia.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';

/// Bölüm başlığı — serif başlık + sönük alt satır.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {this.subtitle, super.key});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(configText(context, title), style: t.textTheme.headlineSmall),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(configText(context, subtitle!), style: t.textTheme.bodyMedium),
        ],
      ],
    );
  }
}

/// **İSİMLİ BOŞLUK** — bir yüzeyin neden burada olmadığını söyleyen kart.
///
/// Bu widget'ın var olma sebebi M-F-186'nın uygulanabilir hâli olmasıdır:
/// engelli bir özellik GÖRÜNÜR kalır ama gerekçesiyle. Vaat dili taşımaz;
/// [reason] bir TARİH değil bir NEDEN söyler.
///
/// Ton kararı: özür değil envanter. "Üzgünüz, henüz yok" yerine "şu var, şu
/// yok, sebebi bu". Kullanıcıya acınmaz.
class NamedGapCard extends StatelessWidget {
  const NamedGapCard({
    required this.title,
    required this.reason,
    this.detail,
    super.key,
  });

  final String title;
  final String reason;

  /// İkinci satır — gerekirse. Sönük.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            configText(context, title),
            style: t.textTheme.labelLarge?.copyWith(
              color: LissomColors.bodySecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(configText(context, reason), style: t.textTheme.bodyMedium),
          if (detail != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              configText(context, detail!),
              style: t.textTheme.bodySmall?.copyWith(
                color: LissomColors.bodySecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Kutu tasarımının kuralı: "ölçülenler" ile "ölçülmeyenler" aynı biçimde
// dizilirse kutu bir özellik listesine benzer ve ikinci yarısı okunmaz.
// Ayrımı taşıyan şey ikon ve zemin — renk kodlaması (yeşil/kırmızı)
// KULLANILMIYOR: "ölçülmüyor" bir başarısızlık değil, bir sınırdır.

/// Bir iddianın dayandığı metrikler bugün gerçekten ölçülebiliyor mu?
///
/// Dönüş `null` = canlı. Dolu = İSİMLİ gerekçe — ve gerekçe **köprünün kendi
/// metnidir**, burada ikinci kez yazılmaz (iki metin ayrışır, biri bayatlar).
typedef ClaimLiveness = String? Function(HonestyClaim claim);

/// Canlı bir iddianın HÜKÜM sınırı — *"ölçtük"* ile *"değerlendirdik"*
/// arasındaki mesafe (L-233). `null` = söylenecek bir sınır yok.
typedef ClaimVerdictNote = String? Function(HonestyClaim claim);

/// Dürüstlük kutusu — **her aile sayfasında ZORUNLU** (IA config hükmü,
/// [LibraryIa] okuyucusunda tip düzeyinde zorlanıyor).
///
/// İki liste GÖRSEL OLARAK AYRI, ve **`measured` tarafı artık kendini
/// doğruluyor** (L-230): her iddia dayandığı metrikleri beyan eder, kabuk
/// onu köprüye karşı sınar, canlı olmayan iddia silinmez — İSİMLİ gerekçeyle
/// sönük gösterilir.
class HonestyBoxCard extends StatelessWidget {
  const HonestyBoxCard(
    this.box, {
    required this.liveness,
    required this.verdictNote,
    super.key,
  });

  static const Key measuredKey = Key('honesty.measured');
  static const Key notMeasuredKey = Key('honesty.notMeasured');

  final HonestyBox box;

  /// **Kutunun kendisini denetleyen fonksiyon.** L-230'un yüzey tarafı:
  /// iddia canlı değilse SİLİNMEZ (kapsamı saklamak olurdu) — sönük gösterilir
  /// ve nedeni yanına yazılır, tıpkı engelli testler gibi.
  final ClaimLiveness liveness;

  /// **Kutunun iki yarısını SİMETRİK yapan şey (L-233).** `notMeasured`
  /// tarafı zaten uzun ve gerekçeliydi; `measured` tarafı sınırsızdı. Canlı
  /// bir iddia artık ölçümün NE OLDUĞUNU da söylüyor: referansa kıyaslandı
  /// mı, yoksa hükümsüz bir okuma mı.
  final ClaimVerdictNote verdictNote;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(
            box.measured.isEmpty
                ? localeText(
                    context,
                    'Camera feedback limits',
                    'Kamera geri bildiriminin sınırları',
                  )
                : localeText(
                    context,
                    'Measurement engine coverage',
                    'Ölçüm motorunun kapsamı',
                  ),
            color: LissomColors.roseDeepHover,
          ),
          const SizedBox(height: 10),
          Column(
            key: measuredKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (box.measured.isEmpty)
                Text(
                  localeText(
                    context,
                    'This guided course does not grade posture with the camera.',
                    'Bu rehberli kurs, duruşu kamerayla puanlamaz.',
                  ),
                  style: t.textTheme.bodyMedium,
                ),
              for (final HonestyClaim c in box.measured)
                _claimRow(context, t, c, liveness(c), verdictNote(c)),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          LissomEyebrow(
            localeText(
              context,
              'Outside the measurement engine coverage',
              'Ölçüm motorunun kapsamı dışında',
            ),
          ),
          const SizedBox(height: 10),
          _list(
            context,
            t,
            notMeasuredKey,
            box.notMeasured.map((NotMeasuredLine l) => l.claim).toList(),
            Icons.remove_circle_outline,
            LissomColors.bodySecondary,
          ),
        ],
      ),
    );
  }

  /// Canlı iddia: kamera ikonu, normal metin. Canlı OLMAYAN: sönük ikon,
  /// sönük metin **ve altında gerekçe.** Görsel ayrım kasıtlı — ikisi aynı
  /// görünseydi kutu yine "hepsini ölçüyoruz" der gibi okunurdu.
  static Widget _claimRow(
    BuildContext context,
    ThemeData t,
    HonestyClaim c,
    String? blocker,
    String? verdict,
  ) {
    final bool live = blocker == null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              live ? Icons.videocam_outlined : Icons.videocam_off_outlined,
              size: 15,
              color: live ? t.colorScheme.primary : LissomColors.bodySecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  configText(context, c.claim),
                  style: live
                      ? t.textTheme.bodyMedium
                      : t.textTheme.bodyMedium?.copyWith(
                          color: LissomColors.bodySecondary,
                        ),
                ),
                if (live && verdict != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    configText(context, verdict),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: LissomColors.bodySecondary,
                    ),
                  ),
                ],
                if (!live) ...<Widget>[
                  const SizedBox(height: 3),
                  // ⚠️ Ayraç TİRE DEĞİL orta-nokta: engel metni ZATEN
                  // "<özne> — <gerekçe>" biçiminde geliyor, tire kullanmak
                  // ekranda "Not in this build — Hold time — this test is…"
                  // gibi ÇİFT TİRE üretiyordu ve cümle okunmuyordu.
                  // Simülatör ekranı yakaladı, test değil.
                  Text(
                    localeText(
                      context,
                      'Not in this build · $blocker',
                      'Bu sürümde yok · ${configText(context, blocker)}',
                    ),
                    style: t.textTheme.bodySmall?.copyWith(
                      color: LissomColors.bodySecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _list(
    BuildContext context,
    ThemeData t,
    Key key,
    List<String> items,
    IconData icon,
    Color color,
  ) => Column(
    key: key,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final String s in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  configText(context, s),
                  style: t.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// Ekranın tepesinde duran sıcak beyan kartı (mevcut `_HonestyBanner`ın
/// paylaşılan hâli). Beyan AŞAĞIDA olsaydı kaydırmayan kullanıcı hiç görmezdi
/// — M-F-186 koşul 4.
class DeclarationBanner extends StatelessWidget {
  const DeclarationBanner({
    required this.eyebrow,
    required this.body,
    super.key,
  });

  final String eyebrow;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return LissomCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[LissomColors.cream, LissomColors.peach],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ⚠️ Bu kartın zemini cream→peach gradyanı ve PEACH ucu koyu:
          // orada `roseDeepHover` 3,67:1 veriyor. Eyebrow'un fiilen cream
          // ucunda durduğunu varsayıp geçmek, KONUMA dayalı bir iddia olurdu
          // — kart yeniden düzenlenince sessizce yanlışlaşır. `ink` bu kartın
          // her noktasında geçiyor (7,89:1).
          LissomEyebrow(eyebrow, color: LissomColors.ink),
          const SizedBox(height: 8),
          Text(
            body,
            style: t.textTheme.bodyMedium?.copyWith(color: LissomColors.ink),
          ),
        ],
      ),
    );
  }
}

/// **Kamera turu bu derlemede bağlı DEĞİL — tek kaynak (L-242).**
///
/// Yayın envanteri (`docs/YAYIN-ENVANTERI-2026-08-07.md`) tek bir örüntü
/// buldu: **uygulamanın tamamı çalışan bir ölçüm döngüsünün şimdiki
/// zamanıyla konuşuyordu**, oysa kullanıcı hiçbir ölçüm yapamıyor. Bu gerçeği
/// yalnız Home'un tepesindeki beyan söylüyordu; Library'den ya da
/// Progress'ten başlayan kullanıcı onu hiç görmüyordu.
///
/// Yokluk sessiz değil, **konuşkan**dı: yedi yüzey var olmayan bir mekanizmayı
/// anlatıyordu. Sınıf *"beyan var üretici yok"*un TERSİ.
///
/// Boşluğu yedi yerde yeniden anlatmak, aynı hatayı yeni bir ikizle kapatmak
/// olurdu — metin bir kez yazılır, gerektiği her yerde GÖSTERİLİR.
/// **CİHAZ GEÇİŞİ (A12) — TEK GERÇEK KAYNAĞI (L-318).**
///
/// 🔴 **Neden var:** *"gerçek telefonda denenmedi"* iddiası bu ağaçta **ÜÇ ayrı
/// yerde elle yazılmıştı** — [CaptureUnavailableNote] (Home·Library·Progress),
/// `home_screen.dart`ın `DeclarationBanner`ı ve `live_capture_screen.dart`ın
/// `NamedGapCard`ı. Üçü de aynı olguyu, üç ayrı cümleyle.
///
/// Ve bu dosyanın KENDİ başlığı kuralı zaten yazıyordu:
///   > *"aynı beyanı üç ekranda üç farklı tonda yazmak, üçünden ikisinin
///   > sessizce yumuşamasına yol açar. **Beyan bir kez yazılır, üç yerde
///   > GÖSTERİLİR.**"*
/// Kural yazılıydı, bir yerde uygulanmıştı, ve **aynı iddia için iki kez
/// çiğnenmişti.**
///
/// ⚠️ **Bu, bu gece İKİ KEZ ödediğim kusurun ÖNCEDEN GÖRÜLEBİLİR üçüncüsü.**
/// A12 kapandığında (preflight hazır — `docs/A12-KOSUM-HATTI.md`) biri bu
/// cümlelerden birini ya da ikisini güncelleyip üçüncüsünü unutacaktı, ve
/// uygulama aynı anda *"cihazda doğrulandı"* ve *"gerçek telefonda denenmedi"*
/// diyecekti — `L-317`'nin birebir aynısı.
/// > ***AYNI OLGUYU İKİ YERE YAZMAK, ONLARI AYIRMANIN BİR YOLUNU AÇIK
/// > BIRAKMAKTIR — ve o yol er ya da geç kullanılır.***
///
/// ⇒ Olgu ([verified]) tek yerde; üç yüzey ondan TÜRETİR. A12 kapandığında
/// **tek bir sabit** değişir. `device_claim_single_source_test.dart` üçüncü bir
/// elle-yazımı yasaklıyor.
abstract final class DevicePassClaim {
  /// Cihazda gerçek bir koşum yapıldı mı? **A12'nin makine karşılığı.**
  /// ⛔ `true` yapmadan önce cihaz koşusu KANITLANMALI (ekran kaydı/cihaz logu).
  static const bool verified = false;

  /// Olgunun ÇEKİRDEĞİ — geri kalan her cümle bunlardan kurulur.
  static const String _pass = 'a device pass';

  static const String notTried = 'This has not been tried on a real phone';

  /// Geniş çerçeve (Home · paylaşılan not).
  static const String stillNeeds =
      'camera permission, frame quality, and calibration still need $_pass';

  /// Dar çerçeve (`LiveCaptureScreen`) — ardından dört kalem TEK TEK sayılır
  /// (koordinatör şartı, 2026-08-12). **Kapı dördüncü bir elle-yazımı
  /// yakaladığı için eklendi:** `detail` alanı hâlâ olguyu elle taşıyordu.
  /// *Bir kapının ilk koşumunda öttüğü şey, sayılmamış bir kopyadır.*
  static const String stillNeedsLead = 'Still needs $_pass';
}

class CaptureUnavailableNote extends StatelessWidget {
  const CaptureUnavailableNote({
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  final bool measurementAvailable;

  static const Key key_ = Key('note.captureUnavailable');

  /// Default release copy. Rendered availability follows the same capability
  /// as Home; device qualification remains separate and is not implied by it.
  static const String text =
      'Live camera measurements are closed in this release. '
      'Written courses work without a camera. '
      '${DevicePassClaim.notTried}: ${DevicePassClaim.stillNeeds}.';

  static String localizedAvailability(
    BuildContext context, {
    required bool measurementAvailable,
  }) => measurementAvailable
      ? localeText(
          context,
          'You can start a live camera measurement from Home for supported tests.',
          'Desteklenen testlerde Ana Sayfa’dan canlı kamera ölçümü başlatabilirsin.',
        )
      : localeText(
          context,
          'Live camera measurements are closed in this release.',
          'Bu sürümde canlı kamera ölçümleri kapalıdır.',
        );

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Padding(
      key: key_,
      padding: const EdgeInsets.only(bottom: 16),
      child: LissomCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                measurementAvailable
                    ? Icons.videocam_outlined
                    : Icons.videocam_off_outlined,
                size: 17,
                color: LissomColors.bodySecondary,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                '${localizedAvailability(context, measurementAvailable: measurementAvailable)} '
                '${localeText(context, 'Written courses work without a camera. '
                    '${DevicePassClaim.notTried}: ${DevicePassClaim.stillNeeds}.', 'Yazılı kurslar kamera olmadan çalışır. Gerçek cihazda kamera izni, kare '
                    'kalitesi ve kalibrasyon henüz doğrulanmadı.')}',
                style: t.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kalıcı ölçüm-sınırı beyanı — **küçük punto, her ölçüm yüzeyinin dibinde.**
///
/// Uyum denetimi maddesi ⑱'in kapanışı. İki parçası var ve ikisi de ÖLÇÜLMÜŞ
/// kaynaklıdır:
///
///   1. [limitsCopy] — `config/copy/disclaimers.en.json` → `measurementLimits`.
///      Uydurulmadı, TAŞINDI.
///   2. [accuracyStatement] — kameranın kendi doğruluk marjı. Burada bir sayı
///      YOK ve bu **bilerek**: kod tabanında böyle bir ölçüm hiç yapılmadı.
///      Tasarım mockup'ı "±5° typical error" yazıyordu; o rakamın hiçbir
///      dayanağı yok (tek ilgili ölçüm L-031 FARKLI bir sapma sınıfını
///      ölçüyor: Dart↔Python uzay ayrışması, medyan 11,29°). Bir doğruluk
///      marjı UYDURMAK, kesinlik taklidi yasağının (madde ⑫) tam ihlali
///      olurdu. Bu yüzden beyan, marjın **ölçülmediğini** söylüyor.
///
/// ⚠️ `disclaimers.scoreScreen` metni bilerek KULLANILMADI: "This score
/// reflects your movement pattern compared with your own history" diyor —
/// oysa Lissom skor VERMİYOR (K8) ve geçmişle KIYASLAMIYOR (Progress'in
/// tasarlanmış hâli). Doğru olmayan bir yasal metni "config'te yazıyor" diye
/// basmak, dürüstlük ihlalini config'e havale etmek olurdu. Bulgu
/// koordinatöre isimli gitti.
class MeasurementLimitsFootnote extends StatelessWidget {
  const MeasurementLimitsFootnote({
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  final bool measurementAvailable;

  static const Key key_ = Key('footnote.measurementLimits');

  /// `disclaimers.en.json` → `disclaimers.measurementLimits.text`, BİREBİR.
  static const String limitsCopy =
      'A single phone camera gives an approximate picture of how you move. '
      "Results depend on where the camera sits, the light in the room, and "
      "what you're wearing. Some joints can be estimated more confidently "
      'than others, and Lissom tells you when a reading was not reliable '
      'enough to score.';

  /// Ölçülmemiş olanı ÖLÇÜLMEMİŞ diye söyleyen cümle.
  static const String accuracyStatement =
      'We have not measured how far our own readings sit from a reference '
      'instrument, so we do not print a margin of error. When that study is '
      'run, the number will appear here.';

  static String localizedLimits(BuildContext context) => localeText(
    context,
    limitsCopy,
    'Tek bir telefon kamerası hareketinin yaklaşık bir görünümünü verir. '
    'Sonuçlar kameranın konumuna, ışığa ve kıyafetine bağlıdır. Bazı '
    'eklemler daha güvenilir okunabilir; Lissom yeterince güvenilir '
    'olmayan ölçümleri bildirir.',
  );

  static String localizedAccuracy(BuildContext context) => localeText(
    context,
    accuracyStatement,
    'Ölçümlerimizin referans bir cihazdan ne kadar saptığını henüz '
    'ölçmedik. Bu nedenle hata payı yazmıyoruz.',
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final TextStyle? small = t.textTheme.bodySmall?.copyWith(
      color: LissomColors.bodySecondary,
    );
    return Padding(
      key: key_,
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(),
          const SizedBox(height: 12),
          Text(
            '${localeText(context, 'These limits describe the measurement engine when a camera '
                'reading is taken.', 'Bu sınırlar, kamera ölçümü alındığında ölçüm motorunun '
                'davranışını açıklar.')} ${CaptureUnavailableNote.localizedAvailability(context, measurementAvailable: measurementAvailable)}',
            style: small,
          ),
          const SizedBox(height: 8),
          Text(localizedLimits(context), style: small),
          const SizedBox(height: 8),
          Text(localizedAccuracy(context), style: small),
        ],
      ),
    );
  }
}
