/// Canlı değerlendirme seansının HÂLLERİ — tipli, sessiz düşüş imkânsız.
///
/// Üç desen JabLab'dan geldi (M-F-267) ve üçü de aynı sınıfın panzehiri:
/// **bir hâl anlatılmazsa kullanıcı onu kendi uydurur.**
///
///   1. **ÇIKMAZ-SOKAK YASAĞI** — kamera kurulumu patlarsa ekran AÇILMAMAZLIK
///      EDEMEZ. Kurulum hatası seansın İÇİNE [SetupFailed] olarak akar; ekran
///      açılır ve ölçüm-yokluğunu BEYAN eder. "Dokun, hiçbir şey olmaz" yasak.
///
///   2. **İZİN-REDDİ KALICI/GEÇİCİ AYRIMI** — eylem değişir: geçicide "tekrar
///      dene" anlamlı, kalıcıda ANLAMSIZ (sistem bir daha sormaz) ve kullanıcı
///      ayarlara yönlendirilmeli. Tek bir `permissionDenied` hâli bu ikisini
///      birleştirir ve kalıcı redde "tekrar dene" gösterip kullanıcıyı
///      çıkmaza sokar — çıkmaz-sokak yasağının ta kendisi, bir katman içeride.
///
///   3. **"HİÇ BAŞLAMADI ≠ SIFIR"** — ölçüm hiç başlamamışken çıplak `0°`
///      göstermek YANLIŞ ANLATI: 0° bir ÖLÇÜMDÜR ("kolunu hiç kaldırmadın"),
///      yokluk ise ölçüm değildir ("henüz denemedin"). Bu, Lissom'un
///      `measurementOnly` doktrininin sayısal ikizi: değeri göstermeye
///      hakkımız var, olmayan değeri sıfır sanmaya hakkımız YOK.
///      Bkz. [LiveReading] — sayı `double?` ve yokluğun kendi anlatısı var.
///
/// **Tümü `sealed`:** yeni bir hâl eklendiğinde `switch` derleme hatası verir.
/// Yüzey katmanı bir hâli "unutamaz" — L-135'in ("sebebi isimle söyle")
/// tip-sistemi düzeyinde uygulanışı.
library;

/// Kamera izni reddedildiğinde reddin KALICILIĞI.
///
/// Ayrı bir tür, çünkü ikisi FARKLI EYLEM ister ve tek bayrak bunu silerdi.
enum PermissionDenialKind {
  /// Kullanıcı bu seferlik reddetti; sistem tekrar sorabilir.
  /// Eylem: "tekrar dene" ANLAMLI.
  transient,

  /// Kalıcı ret (iOS "Don't Allow" sonrası / Android "don't ask again").
  /// Eylem: "tekrar dene" ANLAMSIZ — sistem bir daha sormaz; ayarlara yönlendir.
  permanent,
}

/// Bir eklem-grubunun kadraj durumu.
///
/// L-201'in canlı yüzeydeki hâli: **"landmark bulundu ≠ geçerli ölçüm".**
/// Ölçüldü (`E3Eu0F73ROI`): tespit oranı %97,1 ama alt-vücut metriklerinde
/// VMR 0,002 — yani iskelet bulunuyor, alt vücut kullanılabilir DEĞİL.
/// Bu yüzden "kişi görünüyor" ile "bu testin istediği eklemler görünüyor"
/// ayrı sorulardır ve yüzeyde ayrı cümleler ister.
enum JointCoverage {
  /// Testin istediği eklemler güvenle görünüyor.
  covered,

  /// Kişi var ama testin istediği eklemler kadrajda değil (ör. alt-vücut
  /// testinde alt vücut kırpık). Eylem: "geri çekil" — "kamera bozuk" DEĞİL.
  outOfFrame,
}

/// Canlı bir ölçüm okuması — **sayı ve YOKLUĞU aynı tipte.**
///
/// [degrees] `null` ise bu "0°" DEĞİL: ölçüm henüz alınmadı ya da alınamadı.
/// [narrative] o yokluğun kendi cümlesi; boş olamaz (yokluk sessiz kalamaz).
final class LiveReading {
  const LiveReading.measured(this.degrees, {required this.metric})
      : narrative = null,
        assert(degrees != null, 'ölçülmüş okuma null derece taşıyamaz');

  /// Ölçüm HİÇ başlamadı ya da alınamadı — sayı yerine anlatı.
  const LiveReading.absent({required this.metric, required String this.narrative})
      : degrees = null;

  final String metric;

  /// Derece — `null` = ölçüm YOK. **`0` ile karıştırılamaz** (0 bir ölçümdür).
  final double? degrees;

  /// Yokluğun kullanıcı diliyle gerekçesi. Ölçüm varsa `null`.
  final String? narrative;

  bool get hasMeasurement => degrees != null;

  /// Yüzeyde gösterilecek metin — yokluk asla "0" olarak sızmaz.
  String get display => degrees == null ? narrative! : '${degrees!.round()}°';
}

/// Canlı seansın hâli. `sealed` — yeni hâl eklenince switch'ler kırılır.
sealed class LiveSessionState {
  const LiveSessionState();

  /// Bu hâlde ölçüm alınabilir mi? Yüzey bunu sormak yerine tipe bakabilir.
  bool get canMeasure => false;

  /// Kullanıcıya gösterilecek gerekçe — HİÇBİR hâlde boş değil.
  String get userText;
}

/// Kamera kuruluyor.
final class LiveIdle extends LiveSessionState {
  const LiveIdle();
  @override
  String get userText => 'Getting the camera ready.';
}

/// **ÇIKMAZ-SOKAK YASAĞININ TİPİ (desen 1).** Kurulum patladı — ama ekran
/// açılır ve bunu söyler; sessizce hiçbir şey olmaz DEĞİL.
final class SetupFailed extends LiveSessionState {
  const SetupFailed({required this.code, required this.userText});

  /// Makine-okur kod (`camera-open-failed` · `plugin-missing` …). Yüzey bunu
  /// yutmaz; bilinmeyen kod bile GÖSTERİLİR (battery_summary deseni).
  final String code;

  @override
  final String userText;
}

/// İzin reddedildi — **kalıcılık ayrımı taşır (desen 2).**
final class PermissionDenied extends LiveSessionState {
  const PermissionDenied({required this.kind, required this.userText});

  final PermissionDenialKind kind;

  /// "Tekrar dene" bu hâlde anlamlı mı? Kalıcı rette ANLAMSIZ — göstermek
  /// kullanıcıyı hiçbir yere varmayan bir düğmeye hapsederdi.
  bool get retryMakesSense => kind == PermissionDenialKind.transient;

  @override
  final String userText;
}

/// Kamera açık ama **kimse görünmüyor.**
///
/// Gravita deseni (M-F-266): bu bir ARIZA DEĞİL — çalışma-hâli içinde bir
/// bayrak. "Kamera bozuk" ile "kadraja gir" farkı silinmemeli, o yüzden
/// [SetupFailed]'den AYRI tip.
final class NoPersonDetected extends LiveSessionState {
  const NoPersonDetected();
  @override
  String get userText => 'No one is in frame. Step into the camera view.';
}

/// Kişi var ama testin istediği eklemler kadrajda değil.
///
/// L-201'in ürün yüzeyindeki karşılığı; [NoPersonDetected]'den ayrı çünkü
/// eylem farklı ("geri çekil" ≠ "kadraja gir").
final class JointsOutOfFrame extends LiveSessionState {
  const JointsOutOfFrame({required this.missingGroup});

  /// Hangi grup eksik (`lower-body` · `upper-body`) — isimli, "bir şeyler
  /// görünmüyor" değil.
  final String missingGroup;

  /// Cümle gruptan **TÜRETİLİR.**
  ///
  /// Önce iki alan aynı olguyu ayrı ayrı taşıyordu: `missingGroup` ve elle
  /// yazılmış bir `userText`. İki kaynak ayrışır — grup değişir, cümle kalır
  /// ve yüzey yanlış yeri gösterir. Üstelik elle yazılan cümle grubu hiç
  /// ANMIYORDU, yani M-F-186'nın "isimli gerekçe" hükmünü de karşılamıyordu.
  @override
  String get userText =>
      'The $missingGroup joints this measurement needs are out of frame.';
}

/// Ölçüm koşuyor. **Tek `canMeasure == true` hâli.**
final class Measuring extends LiveSessionState {
  const Measuring({required this.reading});

  /// O anki okuma — henüz ölçüm yoksa [LiveReading.absent] taşır ("hiç
  /// başlamadı ≠ sıfır", desen 3).
  final LiveReading reading;

  @override
  bool get canMeasure => true;

  @override
  String get userText => reading.hasMeasurement
      ? 'Measuring: ${reading.display}'
      : reading.narrative!;
}
