/// Onboarding kalıcılığı — ilk-açılış tetiği + profil (SIRA①, 2026-08-12).
///
/// **Bulgu (koordinatör, 3. sevk):** `lib/`de onboarding SIFIR dosyaydı —
/// beş hattın dördünde (Choreia 1 · JabLab 2 · Ostinato 2) en az bir ekran
/// varken Lissom'da hiç yoktu. Kurucu-manuel bir kalem değil, kod işi.
///
/// `ageBand` değerleri `packages/lissom_engine/lib/src/battery.dart`'ın
/// `ScoringSpec.bandFloorsByAge` anahtarlarıyla BİREBİR AYNI (`u40` ·
/// `40-59` · `60plus`) — config'te gerçekten var olan üç bant, uydurulmuş
/// bir liste değil (bkz. `config/tests/lissom-assessment.v1.json`).
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_account_bridge.dart';

/// Onboarding'in KULLANICIYA SUNDUĞU yaş bantları — **tek adres**
/// (`kImplementedTabs` / `kCountableScreens` deseni).
///
/// Bu liste config'in `ageBands`ıyla ve HER testin `scoring.bands`
/// anahtarlarıyla `test/age_band_wiring_test.dart` tarafından mühürlenir.
/// Mühür bir YAZIM karşılaştırması değil, DAVRANIŞ kapısıdır: her bant için
/// gerçek config üstünde `ScoringSpec.floorsFor(bant)` çağrılır ve
/// FIRLATMAMASI gerekir — çünkü `floorsFor` bilinmeyen bantta
/// `BatteryError` fırlatır ve bu, ölçüm ekranında bir çıkmaz sokak olurdu.
const List<String> kOfferedAgeBands = <String>['u40', '40-59', '60plus'];

/// Toplanan profil — `completed == false` iken diğer alanlar anlamsızdır
/// (akış yarım kaldı demektir, kayıtlı olsalar bile TAMAMLANMIŞ sayılmaz).
final class OnboardingProfile {
  const OnboardingProfile({
    required this.completed,
    this.ageBand,
    this.gender,
    this.painNotes,
  });

  const OnboardingProfile.notStarted() : this(completed: false);

  final bool completed;

  /// `u40` · `40-59` · `60plus` — ZORUNLU alan tamamlanmışsa. `null` iken
  /// motor `ScoringSpec.floorsFor(null)` ile EN MUHAFAZAKÂR bandı seçer
  /// (mevcut davranış, burada değiştirilmiyor — yalnız artık kullanıcı
  /// isterse gerçek bandını beyan edebiliyor).
  final String? ageBand;

  /// ⛔ **ONBOARDING BUNU ARTIK TOPLAMIYOR** (L-281, 2026-08-12) — girdi
  /// ekrandan KALDIRILDI, bu akış alana asla değer koymaz.
  ///
  /// Alan şemada duruyor ki **daha eski bir build'in yazdığı profil hâlâ
  /// ayrıştırılabilsin** (`fromJson` toleransı); yeni yazma yolu yok.
  /// Geri gelme koşulu ZAMAN değil: bunu **OKUYAN** üretim kodu doğduğunda.
  final String? gender;

  /// ⛔ Aynı hüküm — ve burada zarar daha keskindi: *"Anything Lissom should
  /// know about"* ipucu, kullanıcının sakatlığını yazıp **ölçümde dikkate
  /// alınacağını ummasına** yol açardı; hiçbir kural/guard onu okumuyordu.
  final String? painNotes;

  /// 🔴 **ALAN BAŞINA TOLERANSLI — eskiden `as` CAST'leriydi (L-326).**
  ///
  /// Ölçüldü: `{"completed": "true"}` **geçerli JSON**, ama `as bool?` bir
  /// `TypeError` fırlatıyordu — ve `read()` yalnız `FormatException`
  /// yakaladığı için hata **kaçıyor**, profil okuma **çöküyordu.** Bu, bir
  /// şema değişikliğinin (alan tipi değişmesi / yeniden adlandırma) üreteceği
  /// birebir bozulma biçimi — `L-325`'in `v` alanı vakasının kardeşi.
  /// > ***BİR "BOZUK DOSYA" KORUMASI, YALNIZ KENDİ HAYAL ETTİĞİ BOZULMA
  /// > BİÇİMİNİ YAKALAR — VE DOSYALAR HAYAL EDİLMEMİŞ BİÇİMLERDE BOZULUR.***
  ///
  /// ⭐ Ve tolerans **alan başına**, dosya başına DEĞİL: bozuk bir `gender`,
  /// okunabilir bir `ageBand`ı düşürmez. `L-325`'in dersinin bu katmandaki
  /// karşılığı — *okunamayan, okunabileni geçersiz kılmaz.*
  factory OnboardingProfile.fromJson(Map<String, dynamic> j) =>
      OnboardingProfile(
        completed: j['completed'] is bool ? j['completed'] as bool : false,
        ageBand: _str(j['ageBand']),
        gender: _str(j['gender']),
        painNotes: _str(j['painNotes']),
      );

  /// Yalnız GERÇEKTEN dize olanı alır. ⛔ `toString()` ÇAĞIRMAZ: `42`yi
  /// `"42"`ye çevirmek, kullanıcının vermediği bir beyanı **uydurmak** olurdu.
  static String? _str(Object? v) => v is String ? v : null;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'completed': completed,
    if (ageBand != null) 'ageBand': ageBand,
    if (gender != null) 'gender': gender,
    if (painNotes != null) 'painNotes': painNotes,
  };

  OnboardingProfile copyWith({
    bool? completed,
    String? ageBand,
    String? gender,
    String? painNotes,
  }) => OnboardingProfile(
    completed: completed ?? this.completed,
    ageBand: ageBand ?? this.ageBand,
    gender: gender ?? this.gender,
    painNotes: painNotes ?? this.painNotes,
  );
}

abstract interface class OnboardingStore {
  Future<OnboardingProfile> read();
  Future<void> write(OnboardingProfile profile);
}

/// Tek-kayıtlı JSON dosyası — `SessionStore`'un JSONL EK-YALNIZ modeliyle
/// KASITLI FARKLI: burada tek bir profil VARDIR ya da YOKTUR, biriken bir
/// olay dizisi değil, o yüzden üzerine-yazma doğru sözleşme.
final class JsonOnboardingStore implements OnboardingStore {
  JsonOnboardingStore(this.file);
  final File file;

  @override
  Future<OnboardingProfile> read() async {
    if (!await file.exists()) return const OnboardingProfile.notStarted();
    final String raw = await file.readAsString();
    if (raw.trim().isEmpty) return const OnboardingProfile.notStarted();
    try {
      return OnboardingProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on Object {
      // Bozuk dosya — çökme yerine "başlanmamış" say: en kötü sonuç
      // kullanıcının onboarding'i BİR KEZ daha görmesi, veri kaybı değil
      // (henüz hiçbir ölçüm profile bağlı DEĞİL — bkz. sınıf dokümanı).
      //
      // 🔴 **EskiDEN yalnız `FormatException` yakalıyordu (L-326)** ve
      // `fromJson`ın `as` cast'leri `TypeError` fırlatıyordu ⇒ geçerli-JSON
      // ama yanlış-tipli bir dosya **açılışta çökertiyordu.**
      // ⇒ Asıl çözüm `fromJson`ın alan-başına toleransı; bu geniş yakalama
      // **arkalık**, tek savunma değil. *Bir tolerans yalnız ayrıştırıcıda
      // olursa, ayrıştırıcının görmediği hata yine dışarı çıkar.*
      return const OnboardingProfile.notStarted();
    }
  }

  @override
  Future<void> write(OnboardingProfile profile) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(profile.toJson()));
  }
}

Future<OnboardingStore> openOnboardingStore({
  LissomLocalScope scope = LissomLocalScope.guest,
}) async {
  final Directory dir = await getApplicationSupportDirectory();
  return JsonOnboardingStore(scope.file(dir, LissomLocalFile.onboarding));
}
