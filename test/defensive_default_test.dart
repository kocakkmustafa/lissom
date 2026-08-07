/// **SAVUNMACI VARSAYILAN → YARGI KAPISI (L-267)** — O-070 aktarımı.
///
/// Ostinato'da bulunan kusur:
/// ```dart
/// insideShare => sampleCount == 0 ? 1 : 1 - outCount/sampleCount
/// verdict     => insideShare > 0.66 ? 'Steady.' : …
/// ```
/// **Sıfır ölçüm ⇒ 1.0 ⇒ *"Steady."*** — kamera hiç okunamadığında kullanıcı
/// **sıfır ölçümle OLUMLU bir hüküm** görüyordu.
///
/// > ***Savunmacı bir varsayılan, ölçülmemiş bir iddiaya dönüşmüş.***
///
/// Sinsi olan: `? 1 :` **matematiksel olarak masum** bir bölme-sıfır koruması.
/// **Kod düzeyinde doğru, ürün düzeyinde yalan** — ürünün en sert kuralını
/// *hiçbir cümle ihlal etmeden* çiğniyor.
///
/// ## Ölçüm: sende bu sınıf YAPISAL OLARAK kapalı — ama kapısı yoktu
///
/// Dört savunmacı varsayılan tarandı; **hiçbiri olumlu bir yargıya
/// bağlanmıyor**, çünkü motor ayrımı isimle koruyor:
///
///   - `_attemptMicros` → girişim yoksa **`null`, `0` DEĞİL** (kodun kendi
///     yorumu: *"çalışma yapılmadı" ile "sıfır saniye çalışıldı" aynı şey
///     değil*).
///   - `elapsed = end - (_firstFrameUs ?? end)` → varsayılan **ihtiyatlı**
///     yöne düşüyor (`noAttemptDetected`, `setupTimedOut` değil) ve ikisi de
///     `notMeasured` ailesinden — **olumlu hüküm değil**.
///   - Bandın altındaki değere etiket **verilmiyor** — ve mekanizma
///     **iki katmanlı**: ① eşleşme döngüsü `value >= floor` istiyor, yani
///     alttaki bir değer zaten hiçbir bantla eşleşmiyor ② `value < floor ?
///     null : label` bunu bir kez daha kapatıyor. ⚠️ Bunu ilk yazımda
///     **yanlış atfetmiştim** (yalnız ②'ye); sabotaj ② kaldırılınca hiçbir
///     şeyin değişmediğini gösterdi — *doğru sonuç, yanlış gerekçe*.
///   - `assessment_history` `?? 0` yapıyor **ama** ayrımı `unmeasuredUnits`
///     alanında koruyor (`attemptMicros != null`).
///
/// Yani bugün temiz. **Kapı, yarını tutuyor**: bu dosyadaki iddialar,
/// varsayılanın bir eşikten geçip yargıya dönmesini yapısal olarak yasaklıyor.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom_engine/lissom_engine.dart';

void main() {
  test('POZİTİF İKİZ: ölçülmüş bir sonuç GERÇEKTEN etiket taşıyabiliyor', () {
    // L-255: aşağıdaki iddiaların hepsi YOKLUK ölçüyor. Kurucu hiç etiket
    // üretemiyorsa, "etiket üretilmiyor" iddiaları vakum-doğru olur.
    final AssessmentResult ok = AssessmentResult.measured(
      testId: 't',
      side: 'right',
      value: 90,
      unit: 'deg',
      bandFloors: const <String, double>{'typical': 60},
      provenance: const <String, String>{'src': 'test'},
    );
    expect(ok.bandLabel, isNotNull,
        reason: 'BULUCU BOZUK: bandın ÜSTÜNDEKİ bir değer bile etiket '
            'almıyorsa, aşağıdaki "etiket yok" iddiaları hiçbir şey '
            'kanıtlamaz');
    expect(ok.isMeasured, isTrue);
  });

  test('BANDIN ALTINDAKİ değere etiket VERİLMEZ — sert kural, yapıda', () {
    final AssessmentResult low = AssessmentResult.measured(
      testId: 't',
      side: 'right',
      value: 10,
      unit: 'deg',
      bandFloors: const <String, double>{'typical': 60},
      provenance: const <String, String>{'src': 'test'},
    );
    expect(low.bandLabel, isNull,
        reason: 'Bandın ALTINDAKİ bir değere bant etiketi verilmiş. Bu, '
            'ölçülen şeyi olduğundan iyi göstermenin en sessiz yolu.');
    expect(low.isMeasured, isTrue,
        reason: 'ölçüldü — etiketsiz olması ölçülmediği anlamına GELMEZ');
    // Ve KATMAN adıyla: bu değer "skorsuz ama ölçülü" bölgede (M-F-71).
    expect(low.tier, ResultTier.measuredBelowRange,
        reason: 'Bandın altındaki ölçüm `scored` sayılmış. Tier bir SUNUM '
            'ayrıntısı değil: `scored` satırı yüzeyde bir hüküm taşır.');
  });

  test('ÖLÇÜLMEMİŞ sonuç ne DEĞER ne ETİKET taşır — sıfır da bir iddiadır', () {
    for (final ResultCode c in <ResultCode>[
      ResultCode.noAttemptDetected,
      ResultCode.aborted,
      ResultCode.setupTimedOut,
    ]) {
      final AssessmentResult r = AssessmentResult.notMeasured(
        testId: 't',
        side: 'right',
        code: c,
        provenance: const <String, String>{'src': 'test'},
      );
      expect(r.isMeasured, isFalse);
      expect(r.value, isNull,
          reason: '${c.name}: ölçülmemiş bir sonuç DEĞER taşıyor. O-070\'in '
              'tam hâli — savunmacı bir varsayılan (0 ya da 1) bir eşikten '
              'geçtiği an ölçülmemiş bir İDDİAYA dönüşür.');
      expect(r.bandLabel, isNull,
          reason: '${c.name}: ölçülmemiş bir sonuç bant ETİKETİ taşıyor');
    }
  });

  test('GİRİŞİM YOKSA süre `null`, `0` DEĞİL — ikisi aynı şey değil', () {
    // Motorun kendi yorumu bunu söylüyor; kapı onu ÇİVİLİYOR. `0` yazsaydık
    // "sıfır saniye çalıştın" derdik — ölçmediğimiz bir şeyi söylemek.
    final AssessmentResult r = AssessmentResult.notMeasured(
      testId: 't',
      side: 'right',
      code: ResultCode.noAttemptDetected,
      provenance: const <String, String>{'src': 'test'},
    );
    expect(r.attemptMicros, isNull,
        reason: '"çalışma yapılmadı" ile "sıfır saniye çalışıldı" AYNI ŞEY '
            'DEĞİL. `0` yazmak, ölçülmemiş bir olguyu beyan etmektir.');
  });
}
