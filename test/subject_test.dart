/// **ÖZNE KAPISI (L-266)** — J-154 aktarımı.
///
/// JabLab bir başlık ölçtü: **`SET UP ONCE`**. İş **her seans** tekrarlanıyordu;
/// bir kez olan tek şey **ekranın gösterilmesiydi**.
///
/// > ***Başlık, EKRANIN davranışını anlatıyordu; KULLANICININ işini değil.
/// > Ve kullanıcı ikincisini okur.***
///
/// Zincir: *sözcük* → *cümle* → *çerçeve* → **özne**. Ortak kök: **doğruluk,
/// okunduğu yerden ölçülür.**
///
/// ## Bende bulunan: kart kendi içinde çelişiyordu
///
/// `retest_countdown` kartının **gövdesi** doğruydu:
/// *"Lissom does not set a date for your next measurement… we are not going
/// to schedule you."*
///
/// **Başlığı** ise config'ten geliyordu ve şunu diyordu: **"Next
/// re-assessment"** — yani *bir sonraki VAR ve PLANLI*. Başlık **sistemin
/// yuvasını** (ana ekranda bir bölüm var), gövde **kullanıcının gerçeğini**
/// anlatıyordu. **Kullanıcı önce başlığı okur**, ve orada bir yükümlülük
/// görüyordu — brief'in yasakladığı şeyin ta kendisi.
///
/// İkisi de tek başına yalan değildi; **birlikte** yanlış okunuyorlardı.
///
/// ## Ne ölçülüyor — ve ne ÖLÇÜLEMİYOR
///
/// *"Bu başlık kullanıcı öznesiyle mi yazılmış?"* semantik bir yargıdır ve
/// ölçütü yok (L-265'in kör noktasıyla aynı sınıf). Kapı **mekanik vekiller**
/// tutuyor:
///
///   1. **Makine id'si yüzeye SIZMIYOR** — `ankle_dorsiflexion` gibi bir
///      dize hiçbir kullanıcı metninde geçemez.
///   2. **Yükümlülük dili yok** — takvim/vade/gecikme sözcükleri yasak.
///
/// ## 🕳️ KÖR NOKTA — jargon vekili TÜRETİLEMEDİ
///
/// İlk kapı *"kullanıcıya görünen ad, id'nin baş-harfli hâli olamaz"* diyordu
/// ve **`deep_squat → "Deep Squat"`i sızıntı saydı** — oysa *"deep squat"*
/// düz İngilizce. Ölçtüğüm şey yanlıştı: **id-eşitliği ≠ jargon.**
///
/// Sonra jargon sözlüğünü config'in **kendi iki sözlüğünden** türetmeyi
/// denedim (metrik id'lerinde geçip insan metinlerinde geçmeyen sözcükler).
/// **Türetme kendini yiyor:** insan sözlüğünü adlardan hesaplarsam, eklenen
/// her ad kendi sözcüklerini meşrulaştırır ve kapı hiçbir şey yakalayamaz.
///
/// *"Bu ad vücut dilinde mi, motorun dilinde mi?"* semantik bir yargı ve
/// ölçütü yok — L-265'in kör noktasıyla **aynı sınıf**. Kapı kurmuyorum.
///
/// **Bugünkü ÖLÇÜM (kapı değil, olgu):** 12 testin 12'si vücut dilinde —
/// `ankle_dorsiflexion` → *"Ankle Mobility"* · `thoracic_rotation` →
/// *"Seated Torso Rotation"* · `hamstring_reach` → *"Standing Forward
/// Reach"*. Ve 11 engelli metriğin `subject`'i de öyle (*"Shin angle"*,
/// *"Knee height"*). ⚠️ Bu bir olgu, bir garanti değil.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ham makine id'si (alt çizgili) bir metinde geçiyor mu? **Tek adres.**
///
/// Bu, jargon sorununun **kesin** olarak ölçülebilen dar parçası: `squat`
/// tartışılır ama `deep_squat` tartışılmaz — o dize kullanıcı metninde
/// hiçbir gerekçeyle bulunamaz.
bool leaksMachineId(String id, String text) =>
    id.contains('_') && text.toLowerCase().contains(id.toLowerCase());

/// Kullanıcıya **yükümlülük** okutan sözcükler.
///
/// ⚠️ Dar tutuldu. *"due"* tek başına yasak DEĞİL (*"due to"* meşru);
/// yasak olan **takvim/vade** anlamı. Ve *"schedule"* olumsuz hâlde meşru —
/// kartın kendi gövdesi *"we are not going to schedule you"* diyor ve bu
/// cümle **korunmak zorunda** (ters ikiz).
final RegExp _obligation = RegExp(
    r"\b(overdue|you're due|you are due|days? late|behind schedule|"
    r"next re-?assessment|scheduled for)\b",
    caseSensitive: false);

Iterable<(String, String)> _homeSections() sync* {
  final Map<String, dynamic> ia = jsonDecode(
      File('config/ia/library.v1.json').readAsStringSync())
      as Map<String, dynamic>;
  final Object? home = ia['home'];
  final List<dynamic> sections =
      home is Map<String, dynamic> ? home['sections'] as List<dynamic> : [];
  for (final dynamic s in sections) {
    final Map<String, dynamic> m = s as Map<String, dynamic>;
    yield (m['id'] as String, m['title'] as String);
  }
}

void main() {
  test('POZİTİF İKİZ: iki bulucu da GERÇEKTEN çalışıyor', () {
    // L-255: iki iddia da yokluk ölçüyor.
    expect(leaksMachineId('ankle_dorsiflexion', 'Run ankle_dorsiflexion now'),
        isTrue,
        reason: 'BULUCU BOZUK: apaçık bir ham id sızıntısını yakalayamıyor');
    expect(_obligation.hasMatch('Next re-assessment'), isTrue,
        reason: 'BULUCU BOZUK: yükümlülük deseni, TAM OLARAK bulduğum '
            'ihlali yakalayamıyor');

    // ⭐ TERS İKİZLER — kapının DARLIĞI (L-248).
    expect(leaksMachineId('deep_squat', 'Deep Squat'), isFalse,
        reason: 'KAPI FAZLA GENİŞ: «Deep Squat» düz İngilizce ve bir '
            'sızıntı DEĞİL. Kapının ilk hâli tam olarak bunu yakaladı — '
            'id-eşitliği jargon demek değildir.');
    expect(
        _obligation.hasMatch(
            'Lissom does not set a date for your next measurement, so we are '
            'not going to schedule you.'),
        isFalse,
        reason: 'KAPI FAZLA GENİŞ: kartın KENDİ dürüst gövdesini yükümlülük '
            'saydı. O cümle korunmak ZORUNDA — bir kapı onu öldürüyorsa '
            'kapı yanlıştır.');
  });

  test('HAM MAKİNE ID\'si hiçbir kullanıcı metninde geçmiyor', () {
    final Map<String, dynamic> t = jsonDecode(
        File('config/tests/lissom-assessment.v1.json').readAsStringSync())
        as Map<String, dynamic>;
    final List<dynamic> tests = t['tests'] as List<dynamic>;
    expect(tests, isNotEmpty, reason: 'pozitif çapa: testler okundu');

    final List<String> ids = <String>[
      for (final dynamic x in tests) (x as Map<String, dynamic>)['id'] as String,
    ];
    final List<String> leaks = <String>[];
    for (final dynamic x in tests) {
      final Map<String, dynamic> m = x as Map<String, dynamic>;
      for (final String field in <String>['name', 'instruction']) {
        final String text = (m[field] as String?) ?? '';
        for (final String id in ids) {
          if (leaksMachineId(id, text)) leaks.add('${m['id']}.$field → «$id»');
        }
      }
    }
    expect(leaks, isEmpty,
        reason: 'Ham makine id\'si kullanıcı metnine sızmış:\n'
            '  ${leaks.join("\n  ")}\n\n'
            'Metrik/test id\'leri MOTORUN dili; kullanıcı KENDİ VÜCUDUNUN '
            'dilini okur.');
  });

  test('ANA EKRAN başlıkları kullanıcıya YÜKÜMLÜLÜK okutmuyor', () {
    final List<(String, String)> sections = _homeSections().toList();
    expect(sections, isNotEmpty, reason: 'pozitif çapa: bölümler okundu');

    final List<String> bad = <String>[
      for (final (String id, String title) in sections)
        if (_obligation.hasMatch(title)) '$id → «$title»',
    ];
    expect(bad, isEmpty,
        reason: 'Bir ana ekran başlığı takvim/vade dili taşıyor:\n'
            '  ${bad.join("\n  ")}\n\n'
            'Bu kart bir DAVET, geri sayım değil. Başlık SİSTEMİN yuvasını '
            'anlatırsa (bir sonraki değerlendirme var ve planlı), kullanıcı '
            'bir YÜKÜMLÜLÜK okur — kartın gövdesi "we are not going to '
            'schedule you" dese bile. Kullanıcı önce başlığı okur.');
  });
}
