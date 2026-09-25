/// Uygulamanın TEK gerçek-kaynağı — dört sekmenin de okuduğu olgular.
///
/// **Neden tek yerde yükleniyor:** aynı config'i her sekmede yeniden okumak,
/// iki sekmenin AYNI ANDA FARKLI bir gerçeği göstermesini mümkün kılardı
/// (Library "12 test" derken Home "3 test" demesi gibi). Tek okuma, tek
/// gerçek.
///
/// **Hiçbir alan opsiyonel/varsayılan değil.** Bir olgu okunamadıysa yükleme
/// FIRLATIR ve kabuk sebebi ADIYLA gösterir (çıkmaz-sokak yasağı, M-F-267) —
/// sessizce boş listeye düşmek, "veri yok" ile "okuyamadım"ı karıştırırdı.
library;

import 'package:flutter/services.dart' show rootBundle;
import 'package:lissom_engine/lissom_engine.dart';

import 'assessment_history.dart';
import 'ia.dart';
import 'local_account_bridge.dart';
import 'session_history_view.dart';

final class AppFacts {
  const AppFacts({
    required this.ia,
    required this.battery,
    required this.liveness,
    required this.history,
  });

  final LibraryIa ia;
  final Battery battery;

  /// Testlerin canlılığı — TÜRETİLİR (M-F-272 / L-206).
  final List<TestLiveness> liveness;

  /// Geçmiş katmanının üç hâlli okuması.
  final SessionHistoryView history;

  List<TestLiveness> get live =>
      liveness.where((TestLiveness x) => x.isLive).toList(growable: false);
  List<TestLiveness> get blocked =>
      liveness.where((TestLiveness x) => !x.isLive).toList(growable: false);

  /// `lessonId` → insan-okur test adı. Anahtar `testId` ya da `testId:side`
  /// olabilir (bkz. [historyKeyFor]); taraf ayrımı KORUNUR çünkü sol/sağ ROM
  /// gerçekten farklıdır ve ortalamak asimetriyi yok eder.
  String testNameFor(String lessonId) {
    final int sep = lessonId.indexOf(':');
    final String id = sep == -1 ? lessonId : lessonId.substring(0, sep);
    final String? side = sep == -1 ? null : lessonId.substring(sep + 1);
    final TestSpec? spec = battery.tests[id];
    // Bataryada olmayan bir kayıt: SESSİZCE ATILMAZ ve güzel bir ad
    // UYDURULMAZ. Ham anahtar görünür — kullanıcı en azından bir şeyin
    // kaydedildiğini görür (M-F-228 sınıfı: kayıp kaydı yutmak yalan söyler).
    final String name = spec?.name ?? lessonId;
    return side == null ? name : '$name · $side';
  }

  /// **Dürüstlük kutusunun denetçisi (L-230).** Bir iddianın dayandığı
  /// metriklerin HEPSİ köprülü mü?
  ///
  /// Gerekçe köprünün KENDİ metninden gelir ([blockerTextFor]) — burada
  /// yeniden yazılmaz. İki metin olsaydı biri bayatlardı ve bayatlayan taraf
  /// büyük ihtimalle yüzeydeki olurdu.
  ///
  /// Dayanaksız iddia (`requires` boş) **canlı sayılmaz ve canlı-değil de
  /// sayılmaz** — hiç denetlenemez, o yüzden `null` döner: yalnız inşa
  /// EDİLMEMİŞ ailede meşru, ve orada aile durumu zaten hiçbir şeyin canlı
  /// olmadığını söylüyor.
  String? blockerForClaim(HonestyClaim claim) {
    if (!claim.isCheckable) return null;
    final Set<String> bridged = kMetricBindings
        .map((MetricBinding b) => b.lissomMetric)
        .toSet();
    final List<String> missing = claim.requires
        .where((String m) => !bridged.contains(m))
        .toList(growable: false);
    if (missing.isEmpty) return null;
    final Set<String> phase = battery.derivedMeasures.entries
        .where((MapEntry<String, DerivedMeasure> e) => e.value.isPhaseDerived)
        .map((MapEntry<String, DerivedMeasure> e) => e.key)
        .toSet();
    return blockerTextFor(missing, phaseDerived: phase);
  }

  /// **Bir iddianın HÜKÜM sınırı — cümlenin İÇİNE (L-233, JabLab J-113).**
  ///
  /// L-230 iddiaların **varlığını** denetliyordu ("bu gerçekten ölçülüyor
  /// mu?"). Bu ayrı bir eksen: **sınıf.** *"Omuz, kalça ve diz açıları"*
  /// diyen bir satır, kullanıcı tarafından *"ve bize nasıl olduğunu
  /// söyleyeceksiniz"* diye okunur — oysa ölçüldü:
  ///
  ///   - `overhead_reach` (omuz) → **measurementOnly**, referans YOK
  ///   - `deep_squat` (diz)      → **measurementOnly**, referans YOK
  ///   - `active_straight_leg_raise` (kalça) → bantlı, referansa kıyaslanır
  ///
  /// Yani **tek bir cümle, iki farklı hüküm sınıfını tek başlıkta
  /// topluyordu** ve görünen taraf FAZLA iddia ediyordu. Bu, bir sınırı
  /// olduğundan geniş yazmanın TERSİ değil aynısı ama daha tehlikelisi:
  /// hata kullanıcının ALEYHİNE. Kıyasın zaten kapalı olduğu (MDC eşiği yok)
  /// bir üründe *"ölçtük"* ile *"iyi/kötü dedik"* arasındaki mesafe,
  /// korumaya çalıştığımız şeyin ta kendisi.
  ///
  /// Kutunun iki yarısı arasındaki ASİMETRİ buydu: `notMeasured` tarafı uzun
  /// ve gerekçeliydi, `measured` tarafı sınırsızdı.
  ///
  /// **TÜRETİLİR, yazılmaz:** bir test terfi ederse (`measurementOnly` →
  /// bantlı) cümle kendiliğinden değişir. Elle yazılsaydı bayatlardı.
  String? verdictNoteFor(HonestyClaim claim) {
    if (!claim.isCheckable || blockerForClaim(claim) != null) return null;
    final Set<String> needed = claim.requires.toSet();
    final Set<String> withRef = <String>{};
    final Set<String> withoutRef = <String>{};
    for (final TestSpec t in battery.tests.values) {
      final List<String> sides = t.perSide
          ? <String>['right', 'left']
          : <String>['right'];
      final bool touches = sides.any(
        (String s) => needed.contains(t.primaryMetricFor(s)),
      );
      if (!touches) continue;
      if (t.referenceStatus?.isMeasurementOnly ?? false) {
        withoutRef.add(t.id);
      } else {
        withRef.add(t.id);
      }
    }
    if (withRef.isEmpty && withoutRef.isEmpty) return null;
    if (withoutRef.isEmpty) {
      return 'Compared against an age-banded reference range.';
    }
    if (withRef.isEmpty) {
      return 'Reported without any reference range — the number is a reading, '
          'not a verdict.';
    }
    return 'Of the ${withRef.length + withoutRef.length} tests behind this '
        'line, ${withRef.length} is compared against a reference range and '
        '${withoutRef.length} are reported without one — the second kind '
        'carries no verdict.';
  }

  static Future<AppFacts> load({
    LissomLocalScope scope = LissomLocalScope.guest,
  }) async {
    final String batteryRaw = await rootBundle.loadString(
      'config/tests/lissom-assessment.v1.json',
    );
    final String iaRaw = await rootBundle.loadString(
      'config/ia/library.v1.json',
    );
    final Battery battery = Battery.parseJson(batteryRaw);
    return AppFacts(
      ia: LibraryIa.parseJson(iaRaw),
      battery: battery,
      liveness: deriveLiveness(battery),
      history: await SessionHistoryView.read(
        () => openSessionStore(scope: scope),
      ),
    );
  }
}
