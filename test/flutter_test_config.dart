/// Aile gotcha'sının panzehiri: **`google_fonts` `flutter_test` altında yazı
/// tipi ÇEKEMEZ** ve denemesi testi patlatır (`HttpOverrides.global` 400).
///
/// `allowRuntimeFetching = false` çekme yolunu tamamen kapatır; yüzey yedek
/// yazı tipiyle çizilir.
///
/// ⚠️ **BU BAYRAK BİR BULGUYU AÇIĞA ÇIKARIYOR (L-222).** Testte kapattığımız
/// şey ÜRETİMDE AÇIK: `google_fonts` varsayılan olarak yazı tiplerini
/// **çalışma anında `fonts.gstatic.com`'dan indirir.** İki sonucu var ve
/// ikisi de ürün-düzeyi:
///
///   1. **Çevrimdışı ilk açılış** — ağ yoksa tasarımın tipografisi hiç
///      yüklenmez ve uygulama yedek yazı tipiyle açılır. "Her şey cihazda"
///      diyen bir üründe bu sessiz bir bozulma.
///   2. **Gizlilik** — cihaz, kullanıcı hiçbir şey yapmadan üçüncü bir
///      sunucuya bağlanır. Ölçüm verisi GİTMİYOR (gönderilecek yer yok), ama
///      bir istek gidiyor ve bu, gizlilik beyanının kapsamına girer.
///
/// Panzehir yazı tiplerini pakete GÖMMEK (üçü de OFL: Newsreader · Nunito
/// Sans · IBM Plex Mono) — aynı iş hem çevrimdışı açılışı hem golden
/// tipografisini düzeltir. **Lisans/bağımlılık kararı olduğu için
/// koordinatöre gitti, burada tek taraflı yapılmadı.**
library;

import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
