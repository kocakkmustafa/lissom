/// **AĞ GEÇİDİ — deneme-değeri kalıcılık yolu (D14 kararının kodda kilidi).**
///
/// Orkestratörün `D14` kararı: `attempt_values.jsonl` hiçbir zaman ağa
/// çıkmaz, bu yüzden Apple'ın App Privacy anlamında "toplanmış" sayılmaz ve
/// ASC anketinde bugün beyan edilecek bir şey yok. Ama bu karar BUGÜNÜN
/// koduna dayanıyor — ve bir kararı doğru tutan şey onu yazan BELGE değil,
/// yanlış olduğu an öten bir KAPIDIR.
///
/// > ***BİR BEYANI DOĞRU TUTAN ŞEY, ONU YAZAN BELGE DEĞİL, YANLIŞ OLDUĞU AN
/// > ÖTEN KAPIDIR — BELGE OKUNMAZ, KAPI KOŞAR.***
///
/// ⚠️ **BU KAPI ÖTERSE:** deneme-değeri yazma/okuma yoluna bir ağ çağrısı
/// eklenmiş demektir (paylaşım ekranı · destek paketi · analitik ardyolu ·
/// bulut senkronu — hiçbiri bugün planlı değil, hiçbiri de imkânsız değil).
/// O an yapılacak şey bu testi gevşetmek DEĞİL: `D14` kararı YENİDEN
/// değerlendirilmeli, ASC App Privacy anketi güncellenmeli.
///
/// Gravita'nın `D1`/`G-227` deseninin AYNI FİKRİ (test-zamanı HTTP sayacı,
/// regresyon kapısı olarak bırakılır) — ama KAPSAM bilerek dar: Gravita
/// TÜM uygulamayı sıfıra çekti (`google_fonts` kaldırıldı, `D1`), Lissom'un
/// kendi `D1`i bu commit'te HENÜZ inmedi (`google_fonts` hâlâ bağımlılıkta,
/// `flutter_test_config.dart` onu yalnız TESTTE susturuyor). Uygulama
/// genelinde bugün sıfır iddia etmek YANLIŞ olurdu — bu kapı yalnız
/// **deneme-değeri kalıcılık yolunu** sayar, iddiası da yalnız o kadar.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/attempt_values.dart';

/// `HttpOverrides.runZoned`ın `createHttpClient` geri çağırması — global
/// `HttpOverrides.global` MUTASYONU yok, zon kapanınca kendiliğinden temiz.
final class _HttpClientCounter {
  int creations = 0;
  HttpClient createHttpClient(SecurityContext? context) {
    creations++;
    return HttpClient(context: context);
  }
}

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('lissom_net_gate'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test(
      'deneme-değeri yazma/okuma yolu SIFIR HttpClient üretir '
      '(D14 kararının koddaki kilidi)', () async {
    final _HttpClientCounter counter = _HttpClientCounter();

    await HttpOverrides.runZoned(() async {
      final File f = File('${tmp.path}/attempt_values.jsonl');
      final JsonlAttemptValueStore store = JsonlAttemptValueStore(f);

      // Arayüzün TAMAMI çalıştırılır — tek bir metot değil. `append` +
      // `forLesson` + `unreadableRecords`, gerçek yazma-okuma turunun
      // kapsadığı ÜÇÜ.
      await store.append(AttemptValue(
        lessonId: 'overhead_reach:right',
        completedAt: DateTime.utc(2026, 8, 16),
        value: 150,
        unit: 'deg',
        tier: 'scored',
        bandLabel: 'good',
        lowestBandFloor: 100,
        provenance: const <String, String>{
          'modelId': 'pose_landmarker_full',
          'batteryVersion': 'v1',
        },
      ));
      final List<AttemptValue> back =
          await store.forLesson('overhead_reach:right');
      expect(back, hasLength(1),
          reason: 'POZİTİF ÇAPA — yazma/okuma GERÇEKTEN çalıştı mı? '
              'Çalışmadıysa aşağıdaki "sıfır ağ" iddiası vakum-doğru olurdu.');
      await store.unreadableRecords();

      // İkinci bir dosya/dizin senaryosu — ilk-açılış (dosya yok) yolu da
      // AYNI kapsamda: bu da GERÇEK bir kod dalı, atlanırsa kapı o dalı
      // hiç görmez.
      final JsonlAttemptValueStore emptyStore =
          JsonlAttemptValueStore(File('${tmp.path}/never_written.jsonl'));
      await emptyStore.forLesson('deep_squat');
      await emptyStore.unreadableRecords();
    }, createHttpClient: counter.createHttpClient);

    expect(
      counter.creations,
      0,
      reason: '🔴 D14 KARARI TEHLİKEDE: deneme-değeri kalıcılık yolu bir '
          'HttpClient ÜRETTİ. Bu, ASC App Privacy anketinin "beyan '
          'gerekmiyor" kararının dayandığı öncülü ÇÜRÜTÜR. Yapılacak şey bu '
          'sayıyı gevşetmek DEĞİL — D14 kararını orkestratörle yeniden '
          'değerlendirmek.',
    );
  });
}
