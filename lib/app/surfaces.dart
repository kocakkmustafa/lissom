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

import 'ia.dart';
import 'lissom_theme.dart';

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
        Text(title, style: t.textTheme.headlineSmall),
        if (subtitle != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(subtitle!, style: t.textTheme.bodyMedium),
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
          Text(title,
              style: t.textTheme.labelLarge
                  ?.copyWith(color: LissomColors.bodySecondary)),
          const SizedBox(height: 8),
          Text(reason, style: t.textTheme.bodyMedium),
          if (detail != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(detail!,
                style: t.textTheme.bodySmall
                    ?.copyWith(color: LissomColors.bodySecondary)),
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
  const HonestyBoxCard(this.box,
      {required this.liveness, required this.verdictNote, super.key});

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
          LissomEyebrow('What this measures',
              color: LissomColors.roseDeepHover),
          const SizedBox(height: 10),
          Column(
            key: measuredKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final HonestyClaim c in box.measured)
                _claimRow(t, c, liveness(c), verdictNote(c)),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          LissomEyebrow('What it does not measure'),
          const SizedBox(height: 10),
          _list(t, notMeasuredKey, box.notMeasured, Icons.remove_circle_outline,
              LissomColors.bodySecondary),
        ],
      ),
    );
  }

  /// Canlı iddia: kamera ikonu, normal metin. Canlı OLMAYAN: sönük ikon,
  /// sönük metin **ve altında gerekçe.** Görsel ayrım kasıtlı — ikisi aynı
  /// görünseydi kutu yine "hepsini ölçüyoruz" der gibi okunurdu.
  static Widget _claimRow(
      ThemeData t, HonestyClaim c, String? blocker, String? verdict) {
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
                Text(c.claim,
                    style: live
                        ? t.textTheme.bodyMedium
                        : t.textTheme.bodyMedium
                            ?.copyWith(color: LissomColors.bodySecondary)),
                if (live && verdict != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(verdict,
                      style: t.textTheme.bodySmall
                          ?.copyWith(color: LissomColors.bodySecondary)),
                ],
                if (!live) ...<Widget>[
                  const SizedBox(height: 3),
                  // ⚠️ Ayraç TİRE DEĞİL orta-nokta: engel metni ZATEN
                  // "<özne> — <gerekçe>" biçiminde geliyor, tire kullanmak
                  // ekranda "Not in this build — Hold time — this test is…"
                  // gibi ÇİFT TİRE üretiyordu ve cümle okunmuyordu.
                  // Simülatör ekranı yakaladı, test değil.
                  Text('Not in this build · $blocker',
                      style: t.textTheme.bodySmall
                          ?.copyWith(color: LissomColors.bodySecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _list(
    ThemeData t,
    Key key,
    List<String> items,
    IconData icon,
    Color color,
  ) =>
      Column(
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
                  Expanded(child: Text(s, style: t.textTheme.bodyMedium)),
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
          Text(body,
              style: t.textTheme.bodyMedium?.copyWith(color: LissomColors.ink)),
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
class CaptureUnavailableNote extends StatelessWidget {
  const CaptureUnavailableNote({super.key});

  static const Key key_ = Key('note.captureUnavailable');

  static const String text =
      'No session can be captured in this build: the camera run is not wired '
      'to any screen. Everything below describes what the measurement engine '
      'can and cannot read — not something you can start today.';

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
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.videocam_off_outlined,
                  size: 17, color: LissomColors.bodySecondary),
            ),
            const SizedBox(width: 11),
            Expanded(child: Text(text, style: t.textTheme.bodyMedium)),
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
  const MeasurementLimitsFootnote({super.key});

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

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final TextStyle? small =
        t.textTheme.bodySmall?.copyWith(color: LissomColors.bodySecondary);
    return Padding(
      key: key_,
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(),
          const SizedBox(height: 12),
          Text(limitsCopy, style: small),
          const SizedBox(height: 8),
          Text(accuracyStatement, style: small),
        ],
      ),
    );
  }
}
