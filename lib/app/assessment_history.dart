/// Lissom ↔ aile kalıcılık şeması KABLOLAMASI (`motion_core-v0.9.0`,
/// M-F-193). Depo BİÇİMİ çekirdekte; burada olan tek şey ÇEVİRİ.
///
/// Çevirinin dört kararı ve her birinin ÖLÇÜLMÜŞ gerekçesi:
///
/// **1. Kayıt birimi TEST'tir, blok ya da batarya değil.** `SessionRecord`
/// başına TEK bir `lessonClass` var; bir Lissom bloğu ise sınıf BAKIMINDAN
/// KARIŞIK (`standing_sagittal`ın 6 testinden biri `measurementOnly`,
/// diğerleri bantlı). Blok başına yazmak, karışık kümeye tek sınıf dayatmayı
/// zorlardı: `'scored'` seçmek `measurementOnly` bir ölçümü GEÇMİŞ katmanında
/// skorlanmış gösterirdi (M-F-186 ihlali), `'measurementOnly'` seçmek de
/// gerçekten kıyaslanmışları eksik anlatırdı. Test başına yazmak sınıfı
/// dürüst tutuyor — zaten `AssessmentResult` üstünde test başına damgalı.
///
/// **2. Birim `'attempt'`, `plannedUnits` 1 — config `reps: 3` DERKEN.**
/// Ölçtüm: `reps` alanının bataryada HİÇBİR okuyucusu yok (`TestSpec` onu
/// parse bile etmiyor) ve motor `finish()` başına TEK bir deneme penceresi
/// kapatıyor (tepe o pencerede birikir). Yani boru hattının gerçekten
/// yaptığı şey bir denemedir. `plannedUnits: 3` yazmak iki yoldan da yalan
/// olurdu: her test sonsuza dek "1/3 tamamlanmamış" görünürdü (kullanıcı
/// uygulamanın İSTEDİĞİ her şeyi yapmışken), ya da bir yüzey 3 tekrarın
/// olduğunu iddia ederdi. Kayıt, ÖLÇÜLENİ söyler. `reps`'in sahipsizliği
/// ayrıca bir bulgu olarak defterde (L-178) — okuyucusu olmayan config
/// alanı, "yazıldı ama yol hiç geçilmiyor" sınıfının ta kendisi.
///
/// **3. `workedSeconds` deneme PENCERESİNDEN gelir, duvar saatinden değil.**
/// Çekirdek şeması onu "gerçekten çalışılan saniye, dinlenme hariç" diye
/// tanımlıyor ve ilerleme kapıları onu sayıyor. `ready` fazında geçen süreyi
/// eklemek, kullanıcının kazanmadığı kapıları geçirirdi.
///
/// **4. Ölçülemeyen deneme `unmeasuredUnits`'e YAZILIR, düşürülmez.**
/// Çekirdeğin `isComplete`'i girişimleri sayıyor ("analiz edilemeyen bir
/// deneme ilerlemeyi ASLA düşürmez") ve sebep isimli gider. Kaydetmemek,
/// yarın yüzeyin "1 deneme" demesine yol açardı — kullanıcı 1 yapmış ve o
/// ölçülememişken: sessizlik yalan söyler.
library;

import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:path_provider/path_provider.dart';

import 'local_account_bridge.dart';

/// Lissom'un `lessonClass` SÖZLÜĞÜ — yazım anında damgalanır.
///
/// Çekirdeğin en-az-yetki okuması (M-F-193 §3) yalnız `'scored'`ı skorlanmış
/// sayıyor. Bu sözlük o kuralı KASITLI olarak kullanıyor: bandın altındaki
/// ölçüm `'coached'` diye gider, `'scored'` DEĞİL — M-F-71 madde 5 (eşik
/// altında konuşan katman KOÇLANAN'dır) geçmiş katmanında da geçerli.
abstract final class LissomLessonClass {
  /// Ölçüldü VE geçerli bir referans bandıyla kıyaslandı.
  static const String scored = 'scored';

  /// Ölçüldü, kıyaslandı, en alt çizginin altında. Skor DEĞİL.
  static const String coached = 'coached';

  /// Ölçüldü; testin sayısal bandı TASARIMLA yok (nitel/ordinal).
  static const String qualitative = 'qualitative';

  /// Ölçüldü ama referans HENÜZ yok (`referenceStatus.measurementOnly`).
  static const String measurementOnly = 'measurementOnly';

  /// Ölçüm alınamadı; sebep `unmeasuredReason`'da isimli.
  static const String notMeasured = 'notMeasured';
}

/// Geçmiş ANAHTARI — biçim TEK adreste kurulur.
///
/// Neden taraf anahtara giriyor: `workedSecondsFor` ve ilerleme serileri
/// derse göre toplanır, ve sol/sağ ROM GERÇEKTEN farklıdır. İkisini tek
/// seriye katmak, değerlendirmenin asıl konusu olan asimetriyi ortalamanın
/// içinde yok ederdi — donuk sol omuzla hareketli sağ omuz "ortalama iyi"
/// diye okunurdu. Çift-taraflı testte taraf yok, çünkü uydurma bir ayrım
/// olurdu.
String historyKeyFor(TestSpec test, String side) =>
    test.perSide ? '${test.id}:$side' : test.id;

/// Bir test sonucunu aile kaydına çevirir.
///
/// [completedAt] ÇAĞIRANDAN gelir (enjekte edilebilir saat): kayıt zamanını
/// içeride `DateTime.now()` ile üretmek, testleri gerçek zamana bağımlı
/// yapardı ve zaman-sıralı senaryolar sınanamaz hâle gelirdi.
SessionRecord recordFor({
  required TestSpec test,
  required AssessmentResult result,
  required DateTime completedAt,
}) {
  final int workedSeconds = ((result.attemptMicros ?? 0) / 1e6).round();
  final bool measured = result.isMeasured;

  // Girişim BAŞLADI ama hüküm verilemedi → o çalışma gerçekten oldu.
  // `attemptMicros` null ise girişim hiç algılanmadı: sayılacak çalışma yok.
  final bool unmeasuredWork = !measured && result.attemptMicros != null;

  return SessionRecord(
    lessonId: historyKeyFor(test, result.side),
    completedAt: completedAt,
    workedSeconds: workedSeconds,
    unitsCompleted: measured ? 1 : 0,
    unmeasuredUnits: unmeasuredWork ? 1 : 0,
    unmeasuredReason: measured ? null : result.code.name,
    plannedUnits: 1,
    unitLabel: 'attempt',
    lessonClass: _classOf(test, result),
  );
}

/// Sonuç → sınıf. **SIRA anlamlıdır ve canlı bir kusuru kapatıyor.**
///
/// `measurementOnly` kontrolü katman (`tier`) anahtarının ÜSTÜNDE, çünkü ikisi
/// birbirini dışlamıyor: `overhead_reach` HEM skor bantlarına sahip (u40
/// low:150) HEM `referenceStatus.measurementOnly`. 150°'lik bir uzanma
/// `tier: scored` üretir — katmana göre eşleştirsem geçmişe `'scored'`
/// yazılırdı, yani doğrulanmış bir referansa hiç kıyaslanmamış bir ölçüm
/// skorlanmış olarak KAYDA GEÇERDİ. Bu varsayımsal değil, mevcut config'te
/// canlı.
String _classOf(TestSpec test, AssessmentResult result) {
  if (!result.isMeasured) return LissomLessonClass.notMeasured;
  if (result.isMeasurementOnly) return LissomLessonClass.measurementOnly;
  return switch (result.tier) {
    ResultTier.scored => LissomLessonClass.scored,
    ResultTier.measuredBelowRange => LissomLessonClass.coached,
    ResultTier.measuredNoBands => LissomLessonClass.qualitative,
    ResultTier.notMeasured => LissomLessonClass.notMeasured,
  };
}

/// **KORUNAN** ölçümleri geçmişe yazar — yarım blok GİRMEZ.
///
/// [AssessmentSession.preservedResults] yalnız tamamlanmış blokların
/// ölçümlerini verir (M-F-133/3: bir blok tek kalibrasyon penceresinde
/// tamamlanır). Yarım bloğun ölçümlerini kalıcılaştırmak, tek-kalibrasyon
/// kuralını geçmiş katmanından SESSİZCE gevşetirdi — kayıt bir daha hangi
/// pencereye ait olduğunu söyleyemezdi.
Future<int> appendPreserved({
  required AssessmentSession session,
  required Battery battery,
  required SessionStore store,
  required DateTime completedAt,
}) async {
  int written = 0;
  for (final MapEntry<String, AssessmentResult> e
      in session.preservedResults.entries) {
    final TestSpec? test = battery.tests[e.key];
    if (test == null) {
      throw ArgumentError(
        'geçmişe yazılacak sonuç bataryada yok: ${e.key} — eşleşmeyen kayıt '
        'sessizce kalıcılaşamaz',
      );
    }
    await store.append(
      recordFor(test: test, result: e.value, completedAt: completedAt),
    );
    written++;
  }
  return written;
}

/// Gerçek cihazdaki depo. `path_provider` YALNIZ burada — çekirdek depo saf
/// Dart kaldığı için testler geçici bir dosyayla aynı sınıfı koşturabiliyor.
Future<SessionStore> openSessionStore({
  LissomLocalScope scope = LissomLocalScope.guest,
}) async {
  final Directory dir = await getApplicationSupportDirectory();
  return JsonlSessionStore(scope.file(dir, LissomLocalFile.sessions));
}
