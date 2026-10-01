/// **YAZILAN VERİ GÖRÜNÜYOR MU (L-287).**
///
/// L-285 ölçümü diske yazdı. Ama kabuk `AppFacts`i **bir kez** okuyordu
/// (`late final`), ve `AppFacts` GEÇMİŞİ de taşıyor — yani kullanıcı ölçüm
/// yapıp dönünce Home ve Progress **hâlâ ölçümden ÖNCEKİ dünyayı**
/// gösteriyordu:
///
/// > ***Kayıt diskte DOĞRU, yüzey onu göstermiyor.***
/// > *Bir verinin YAZILMASI, GÖRÜNMESİ değildir.*
///
/// Bu, bugünün zincirinin son halkası: `ageBand` **toplanan ama okunmayan**
/// → ölçüm **üretilen ama saklanmayan** → geçmiş **saklanan ama
/// gösterilmeyen.** Üçü de aynı sınıfın farklı yüzü.
///
/// ## Kapı neyi ölçer
///
/// Yükleyici **çağrı sayısını** sayıyor ve **ikinci çağrıda BAŞKA bir
/// dünya** döndürüyor. Böylece *"tazeleme çağrıldı mı"* değil, ***yüzey
/// yeni olguyu GÖSTERİYOR mu*** ölçülüyor — çağrıyı saymak, `onPressed`in
/// varlığını ölçmek olurdu (bu deponun tekrar eden dersi: VARLIK ≠ ETKİ).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom/app/shell.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

void main() {
  testWidgets(
    'ölçümden DÖNÜNCE geçmiş yeniden okunur — yüzey yeni kaydı GÖSTERİR',
    (WidgetTester tester) async {
      pinNarrowSurface(tester);

      int loads = 0;
      // İlk açılış: geçmiş BOŞ. Ölçümden dönüşte: bir kayıt VAR.
      // (Gerçek dünyada değişimi disk yapar; burada yükleyici, çünkü ölçülen
      // şey deponun kendisi değil KABUĞUN yeniden okuyup okumadığı.)
      Future<AppFacts> loader() async {
        loads++;
        return factsFromDisk(
          history: loads == 1
              ? const SessionHistoryView.ok(<SessionRecord>[])
              : SessionHistoryView.ok(<SessionRecord>[
                  recordOf(
                    lessonId: 'overhead_reach:right',
                    lessonClass: 'measurementOnly',
                  ),
                ]),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: LissomShell(loader: loader, measurementAvailable: true),
        ),
      );
      await tester.pumpAndSettle();
      expect(loads, 1, reason: 'POZİTİF ÇAPA — kabuk bir kez okumuş olmalı');

      // Ölçüm yolunu GERÇEKTEN sür: Home → LiveCaptureScreen → geri.
      await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
      await tester.tap(find.byKey(HomeScreen.startMeasurementKey));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        loads,
        2,
        reason:
            'ölçüm ekranından dönüldü — geçmiş YENİDEN okunmalıydı. '
            'Okunmazsa kullanıcı ölçüm yapar, kayıt diske girer, ve Home '
            'hâlâ ölçümden önceki dünyayı gösterir (L-287).',
      );

      // VARLIK değil ETKİ: yüzey gerçekten YENİ olguyu mu gösteriyor?
      expect(
        find.textContaining('Nothing recorded on this device'),
        findsNothing,
        reason:
            'geçmişte artık bir kayıt VAR — "hiçbir şey kaydedilmedi" '
            'cümlesi ayakta kalıyorsa yüzey eski dünyayı gösteriyordur',
      );
    },
  );

  testWidgets('ölçüme HİÇ girilmezse gereksiz yeniden okuma YOK', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    int loads = 0;
    Future<AppFacts> loader() async {
      loads++;
      return factsFromDisk();
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLissomTheme(),
        home: LissomShell(loader: loader),
      ),
    );
    await tester.pumpAndSettle();

    // Sekmeler arasında gezinmek geçmişi değiştirmez — tazeleme ölçüme
    // BAĞLI olmalı, her dokunuşta değil (aksi hâlde kapı "hep tazeler"
    // diyen bir yüzeyi de geçirirdi ve hiçbir şey ölçmezdi).
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(
      loads,
      1,
      reason:
          'sekme gezinmesi geçmişi değiştirmez; her dokunuşta diski '
          'yeniden okumak tazelemeyi ANLAMSIZ kılardı (koşulsuz tazeleyen '
          'bir yüzey, yukarıdaki testi de geçerdi — L-258 sınıfı)',
    );
  });
}
