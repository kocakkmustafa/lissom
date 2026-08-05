/// Canlı değerlendirme kablolaması — **kaynak bildirir, değerlendirici ölçer.**
///
/// Ostinato deseni (M-F-272): kamera yaşam-döngüsünü [PoseSource] bildirir;
/// [LiveEvaluator] yalnız ÖLÇER. Bu ayrım olmadan yüzey kameranın hâllerini
/// bilmek zorunda kalır ve gerçek kamera geldiğinde YÜZEY DEĞİŞİR — oysa
/// değişmemesi gerekiyor: `FakePoseSource` ile koşan ekran, `CameraPoseSource`
/// ile de aynı kodla koşar.
///
/// Soyutlama BURADA (saf Dart, test edilebilir); kamera adaptörü APP
/// katmanında, çünkü `motion_camera` bir Flutter **plugin**'i ve engine'in
/// Flutter'a bağımlı olmaması gerekiyor (aile kuralı: app mantığı çekirdeğe
/// sızmaz, çekirdek Flutter'a bağlanmaz).
library;

import 'package:motion_core/motion_core.dart';

import 'battery.dart';
import 'live_session_state.dart';
import 'metric_bridge.dart';

/// Bir poz kaynağının bildirdiği olay — hâl VEYA kare.
///
/// `sealed`: kaynak "ne olduğunu" söylemek zorunda; sessizce hiçbir şey
/// bildirmeyen bir kaynak çıkmaz-sokak üretir (M-F-267 desen 1).
sealed class PoseSourceEvent {
  const PoseSourceEvent();
}

/// Kaynak bir yaşam-döngü hâli bildiriyor (kurulum · izin · kimse-yok).
final class SourceStateEvent extends PoseSourceEvent {
  const SourceStateEvent(this.state);
  final LiveSessionState state;
}

/// Kaynak ölçülebilir bir kare verdi.
final class SourceFrameEvent extends PoseSourceEvent {
  const SourceFrameEvent(this.frame, {required this.size});
  final PoseFrame frame;

  /// Kare boyutu — [CoreMetricReader] bunu ZORUNLU istiyor (M-F-30/J-028:
  /// ham anizotropik uzayda ölçülen açı en-boy oranıyla büküyor).
  final FrameSize size;
}

/// Poz kaynağı sözleşmesi. Kamera da, fixture da, fake de bunu konuşur.
abstract interface class PoseSource {
  Stream<PoseSourceEvent> events();
  Future<void> dispose();
}

/// Canlı ölçüm değerlendiricisi — kaynağın olaylarını yüzey hâllerine çevirir.
///
/// **Karar vermez, ölçer.** Girişim kapısı / tepe toplama / sonuç kodu
/// semantiği [AssessmentEngine]'de yaşıyor; burası yalnız o motoru besleyen
/// ve hâl akışını üreten kablo.
final class LiveEvaluator {
  LiveEvaluator({
    required this.test,
    required this.side,
    required PoseSource source,
    ConfidenceGate gate = const ConfidenceGate(),
  })  : _source = source,
        _gate = gate;

  final TestSpec test;
  final String side;
  final PoseSource _source;
  final ConfidenceGate _gate;

  /// Bu testin okuduğu metrik (`{side}` çözülmüş).
  String get metricName => test.primaryMetricFor(side);

  /// Hâl akışı — yüzey YALNIZ bunu dinler.
  ///
  /// Ölçüm hiç başlamadığında [LiveReading.absent] yayılır: çıplak `0°`
  /// GÖSTERİLMEZ ("hiç başlamadı ≠ sıfır", M-F-267 desen 3).
  Stream<LiveSessionState> states() async* {
    double? peak;
    yield const LiveIdle();

    await for (final PoseSourceEvent e in _source.events()) {
      switch (e) {
        // Kaynak bir hâl bildirdi — olduğu gibi geçir. Değerlendirici
        // kameranın gerekçesini YENİDEN YAZMAZ; "kamera bozuk" ile
        // "geri çekil" farkını silmemenin yolu bu (M-F-266).
        case SourceStateEvent(state: final LiveSessionState s):
          yield s;

        case SourceFrameEvent(frame: final PoseFrame f, size: final FrameSize z):
          // Kare kalitesi kapısı: hüküm-dışı kareden ölçüm ALINMAZ, ama bu
          // bir ARIZA değil — akış sürer ve o anki tepe korunur.
          final FrameQuality q = _gate.evaluate(f, required: const <int>[]);
          if (!q.judgeable) {
            yield Measuring(reading: _reading(peak, 'Görüntü net değil.'));
            continue;
          }
          final double? v = CoreMetricReader(frameSize: z).read(f, metricName);
          if (v == null) {
            // Metrik okunamadı (landmark güvensiz) — L-201'in tam hâli:
            // "landmark bulundu ≠ geçerli ölçüm".
            yield JointsOutOfFrame(
              missingGroup: _groupOf(metricName),
              userText: 'Ölçüm için gereken eklemler görünmüyor.',
            );
            continue;
          }
          // Tepe yönü config'ten gelir — sessiz varsayılan YOK (L-181).
          if (peak == null ||
              (test.scoring.higherIsBetter ? v > peak : v < peak)) {
            peak = v;
          }
          yield Measuring(
              reading: LiveReading.measured(peak, metric: metricName));
      }
    }
  }

  LiveReading _reading(double? peak, String absentText) => peak == null
      ? LiveReading.absent(metric: metricName, narrative: absentText)
      : LiveReading.measured(peak, metric: metricName);

  /// Metrik adından kaba eklem grubu — yüzeyin "neresi görünmüyor" cümlesi
  /// İSİMLİ olsun diye ("bir şeyler görünmüyor" yasak).
  static String _groupOf(String metric) =>
      metric.contains('knee') || metric.contains('hip') ||
              metric.contains('ankle') || metric.contains('tibia')
          ? 'lower-body'
          : 'upper-body';

  Future<void> dispose() => _source.dispose();
}

/// Test/geliştirme kaynağı — **kamera olmadan canlı yolu uçtan uca koşturur.**
///
/// Sim kanıtının dayanağı: iOS simülatöründe kamera YOK, dolayısıyla dürüst
/// hâller ve canlı-3 yüzeyi ancak böyle bir kaynakla gösterilebilir. Bu bir
/// "mock" değil, ürünün desteklediği ikinci bir kaynak tipi — yüzey ikisini
/// ayırt etmiyor, etmemesi de tasarımın kendisi.
final class FakePoseSource implements PoseSource {
  FakePoseSource(this.script, {this.size = const FrameSize(1080, 1920)});

  /// Yayılacak olaylar, sırayla.
  final List<PoseSourceEvent> script;
  final FrameSize size;

  bool _disposed = false;

  @override
  Stream<PoseSourceEvent> events() async* {
    for (final PoseSourceEvent e in script) {
      if (_disposed) return;
      yield e;
    }
  }

  @override
  Future<void> dispose() async => _disposed = true;
}
