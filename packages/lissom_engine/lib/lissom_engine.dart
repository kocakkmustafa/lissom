/// ROM Assessment Engine — Lissom'un hareket-ölçümü motoru.
///
/// **Test-bağımsızdır.** Motor kodunda hiçbir test adı, eşik ya da skor bandı
/// sabit DEĞİLDİR; hepsi versiyonlu config'ten gelir (`config/tests/`,
/// `config/metrics/`, `config/phases/`). Yeni bir ROM testi eklemek kod değil
/// kayıt ister.
///
/// **M-F-71 hükmü mimariye gömülüdür** (bkz. `src/assessment_engine.dart` ve
/// `src/assessment_result.dart`): girişim kapısı ROM eşiği değil hareket-
/// varlığıdır · girişim algılandıysa ölçüm daima tamamlanır · en düşük skor
/// bandının altı "skorsuz ama ölçülü" bölgedir · her çıkış yolu isimli bir
/// sonuç kodu üretir (timeout dahil) · eşik-altında konuşan katman
/// KOÇLANAN'dır, skorlanan değil.
///
/// Ölçüm matematiği çekirdekten gelir (`motion_core`, pinli sürüm); bu paket
/// onun üstünde ölçüm-testi semantiğini kurar. Paralel geometri
/// implementasyonu YAZILMAZ.
library;

export 'src/assessment_engine.dart';
export 'src/assessment_result.dart';
export 'src/battery.dart';
export 'src/battery_summary.dart';
export 'src/assessment_session.dart';
export 'src/metric_bridge.dart';
