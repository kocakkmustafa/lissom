/// **GÖRSEL YASAKLAR — HER ERİŞİLEBİLİR YÜZEYDE (L-258).**
///
/// Koordinatörün sert-kural süpürmesi bir kapsam kusuru buldu ve **tahmini
/// doğru çıktı**: `⛔ gauge/dolum göstergesi yok` ailenin en sert görsel
/// yasağı, ama kapısı **beş yüzeyin YALNIZ BİRİNDE** duruyordu
/// (`progress_screen_test`). Home · Library · FamilyPage · Profile
/// **kapsam dışıydı** — yani yasağın kendisi değil, *bir ekrandaki* hâli
/// korunuyordu.
///
/// > *"50°'de neredeyse boş bir çubuk, grafikle söylenmiş bir 'yetersizsin'
/// > hükmüdür."* — yasak metinde değil, **çizimde** yaşıyor. `wellness_lint`
/// > metin tarıyor; çizimi kimse taramıyordu.
///
/// ## Kapsam ekran LİSTESİNDEN değil, kabuğun KENDİ ROTASINDAN
///
/// Elle yazılmış bir ekran listesi, altıncı ekran eklendiği gün sessizce
/// eksik kalırdı — bu gecenin en sık kusuru (L-178/L-181 sınıfı). Bu yüzden
/// kapı `LissomShell`i sürüyor ve sekmeleri **config'in kendi `tabs`
/// listesinden** geziyor: yeni bir sekme eklenirse **kendiliğinden** kapsama
/// girer.
///
/// ## Kapı ne YAPMIYOR — isimle
///
/// - **Yükleme spinner'ını yasaklamıyor.** `_LoadingScreen`in
///   `CircularProgressIndicator`ı bir ÖLÇÜM göstergesi değil, bir bekleme
///   işareti. Kapı `pumpAndSettle` sonrası ölçtüğü için o hâl zaten geçmiş
///   olur — yani muafiyet yazmıyorum, **kapsam** doğru çiziliyor. (Muafiyet
///   yazsaydım, gerçek bir gauge onun arkasına saklanabilirdi.)
/// - **Her `CustomPaint`i yasaklamıyor.** Yasak, `painter`ı OLAN
///   `CustomPaint`e; Flutter'ın kendi düzen widget'ları painter'sız
///   `CustomPaint` üretir ve onları yasaklamak doğru davranışı cezalandırırdı.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/shell.dart';

import 'support/facts_from_disk.dart';
import 'support/finder_twin.dart';
import 'support/narrow_surface.dart';

/// Dolum/gauge sınıfı widget'lar — **tek adres** (L-256). İddia ve pozitif
/// ikiz aynı listeyi kullanır.
const List<Type> kGaugeTypes = <Type>[
  LinearProgressIndicator,
  CircularProgressIndicator,
];

void main() {
  testWidgets('POZİTİF İKİZ: gauge bulucuları GERÇEKTEN buluyor', (
    WidgetTester tester,
  ) async {
    // L-255: bu dosyanın tamamı YOKLUK ölçüyor. Bozuk bir bulucu ile temiz
    // bir ürün birbirinden ayırt edilemez.
    for (final Type t in kGaugeTypes) {
      await expectFinderWorks(
        tester,
        probe: t == LinearProgressIndicator
            ? const LinearProgressIndicator()
            : const CircularProgressIndicator(),
        finder: find.byType(t),
        what: '$t bulucusu',
      );
    }
    // Ve painter yüklemi (yokluk iddiasının KENDİ yüklemi).
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: CustomPaint(painter: ProbePainter(), child: SizedBox()))));
    await tester.pump();
    expect(appAuthoredPainters(tester), isNotEmpty,
        reason: 'BULUCU BOZUK: `appAuthoredPainters`, uygulama-yazımı bir '
            'painter\'ı bile bulamıyor — "çizilmiş gauge yok" iddiası '
            'vakum-doğru');
  });

  testWidgets('HER sekmede gauge YOK — kapsam kabuğun rotasından TÜRETİLİR', (
    WidgetTester tester,
  ) async {
    pinTallSurface(tester, height: 4000);
    final AppFacts facts = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();

    // Pozitif çapa: kabuk gerçekten açıldı mı? Yükleme/hata ekranında kalsaydı
    // aşağıdaki tur boş bir yüzeyi gezerdi (L-183).
    expect(find.byType(NavigationBar), findsOneWidget,
        reason: 'kabuk açılmadı — tur boş yüzeyi geziyor olurdu');

    final int tabCount = facts.ia.tabs.length;
    expect(tabCount, greaterThan(1), reason: 'pozitif çapa: sekmeler okundu');

    for (int i = 0; i < tabCount; i++) {
      final String tab = facts.ia.tabs[i];
      await tester.tap(find.byType(NavigationDestination).at(i));
      await tester.pumpAndSettle();

      for (final Type t in kGaugeTypes) {
        expect(find.byType(t), findsNothing,
            reason: '«$tab» sekmesinde $t var. ⛔ Dolum/gauge göstergesi '
                'ÖLÇÜM için yasak: 50°\'de neredeyse boş bir çubuk, grafikle '
                'söylenmiş bir "yetersizsin" hükmüdür — ve bant, nokta '
                'değildir (K8).');
      }
      expect(appAuthoredPainters(tester), isEmpty,
          reason: '«$tab» sekmesinde UYGULAMANIN ÇİZDİĞİ bir gösterge var. '
              'Yasak metinde değil çizimde yaşıyor; `wellness_lint` göremez.');
    }
  });

  testWidgets('Library\'den açılan AİLE SAYFASINDA da gauge YOK', (
    WidgetTester tester,
  ) async {
    // Sekme turu FamilyPage'i görmez: oraya navigasyonla gidiliyor. Bir
    // yüzeyin "sekme değil" olması, kullanıcının oraya gitmediği anlamına
    // gelmiyor — ve ölçüm sonuçlarının yaşadığı yer TAM ORASI.
    pinTallSurface(tester, height: 6000);
    final AppFacts facts = factsFromDisk();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: LissomShell(loader: () async => facts),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination)
        .at(facts.ia.tabs.indexOf('library')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assessment Battery'));
    await tester.pumpAndSettle();

    // Pozitif çapa: gerçekten aile sayfasına GİRDİK mi?
    // Çapa YAPISAL: metin çapası tembel listede kurulmamış olabilir ve
    // "girilemedi" ile "aşağı kaydırılmadı" birbirine karışır.
    expect(find.byType(FamilyPage), findsOneWidget,
        reason: 'aile sayfasına girilemedi — aşağıdaki yokluk iddiası '
            'Library ekranını ölçüyor olurdu');

    for (final Type t in kGaugeTypes) {
      expect(find.byType(t), findsNothing,
          reason: 'Aile sayfasında $t var — ölçüm sonuçlarının yaşadığı '
              'yüzeyde dolum göstergesi, yasağın TAM hedefi');
    }
    expect(appAuthoredPainters(tester), isEmpty,
        reason: 'aile sayfasında uygulamanın çizdiği bir gösterge var');
  });
}
