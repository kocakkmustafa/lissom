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

  static Future<AppFacts> load() async {
    final String batteryRaw =
        await rootBundle.loadString('config/tests/lissom-assessment.v1.json');
    final String iaRaw =
        await rootBundle.loadString('config/ia/library.v1.json');
    final Battery battery = Battery.parseJson(batteryRaw);
    return AppFacts(
      ia: LibraryIa.parseJson(iaRaw),
      battery: battery,
      liveness: deriveLiveness(battery),
      history: await SessionHistoryView.read(openSessionStore),
    );
  }
}
