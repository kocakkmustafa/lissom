/// **YAŞ BANDI — TOPLANANIN GERÇEKTEN KULLANILDIĞININ KAPISI (L-280).**
///
/// Ölçüm (2026-08-12): onboarding kullanıcıya yaş bandını **ZORUNLU** olarak
/// seçtiriyordu (`_canContinue` → `_ageBand != null`), diske yazıyordu, ve
/// **hiçbir yer okumuyordu** — `OnboardingProfile`ın `lib/app/onboarding_*`
/// dışında TEK bir okuyucusu yoktu (pozitif kontrollü ölçüm: aynı süzgeç
/// `LissomShell` için 3, `AppFacts` için 6 dosya buluyordu).
///
/// Yani ekran *"Scoring bands are age-based"* diyor, kullanıcı seçiyor, ve
/// **her ölçüm en muhafazakâr bantla koşuyordu.** L-262 sınıfı: *kullanıcıya
/// OLMAYAN bir yeteneği anlatmak.*
///
/// ## Bu dosya ne koruyor
///
/// Zincir: onboarding → geçit → kabuk → home → canlı ölçüm → **motor**.
/// Zincirin herhangi bir halkası kopunca kullanıcı seçim yapmaya devam eder
/// ve seçim hiçbir şeyi değiştirmez — **sessizce**. Bu dosya o sessizliği
/// imkânsız kılar.
///
/// ## ⚠️ Kapı bir YAZIM kapısı DEĞİL
///
/// `ScoringSpec.floorsFor` tanımadığı bantta `BatteryError` **FIRLATIR**.
/// Bu yüzden kapı iki listeyi karşılaştırmıyor; **gerçek config üstünde her
/// bandı gerçekten çağırıyor.** Ve kapının kendisi de sabotajla sınanıyor
/// (uydurma bant FIRLATMALI) — yoksa "hiçbir şey fırlatmadı" cümlesi
/// kapının çalıştığını değil, *hiçbir şeyi çağırmadığını* da anlatabilirdi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

double _lowestFloor(Map<String, double> floors) =>
    floors.values.reduce((double a, double b) => a < b ? a : b);

/// Ölçüm ÜRETMEYEN motor koşumu — `finish()` her hâlde isimli bir sonuç
/// döndürür ve provenance'ı DAİMA taşır, o yüzden kare beslemeden de
/// "bant kayda girdi mi" sorusu cevaplanabilir.
AssessmentResult _finishWithoutFrames(TestSpec test, String? declared) =>
    buildLiveEngine(
      test: test,
      side: 'right',
      declaredAgeBand: declared,
      batteryVersion: 'test',
      metricReader: (PoseFrame f, String m) => null,
    ).finish();

void main() {
  final Battery battery = batteryFromDisk();

  group(
    'KAPI — sunulan her bant, gerçek config\'in HER testinde çağrılabilir',
    () {
      test('hiçbir (test × bant) çifti FIRLATMIYOR', () {
        expect(
          battery.tests,
          isNotEmpty,
          reason:
              'POZİTİF ÇAPA — config testsiz okunduysa bu kapı boş bir '
              'döngüdür ve hiçbir şey kanıtlamaz',
        );

        for (final MapEntry<String, TestSpec> e in battery.tests.entries) {
          for (final String band in kOfferedAgeBands) {
            expect(
              () => e.value.scoring.floorsFor(band),
              returnsNormally,
              reason:
                  '«${e.key}» testi «$band» bandını tanımıyor. Onboarding '
                  'bu bandı KULLANICIYA SUNUYOR; motora geçtiği an '
                  'BatteryError fırlar ve ölçüm ekranı ÇIKMAZ SOKAK olur '
                  '(M-F-267). Ya config\'e bandı ekleyin ya '
                  'kOfferedAgeBands\'ten çıkarın.',
            );
          }
        }
      });

      test('POZİTİF KONTROL — uydurma bant GERÇEKTEN fırlatıyor', () {
        // Bu olmadan yukarıdaki test vakum-doğru olabilirdi: nitel testlerin
        // bandı yok ve `floorsFor` onlarda ERKEN null döner. Bantlı bir test
        // seçip sabotajın İNDİĞİNİ ölçüyoruz.
        final TestSpec banded = battery.tests.values.firstWhere(
          (TestSpec t) => t.scoring.bandFloorsByAge.isNotEmpty,
        );
        expect(
          () => banded.scoring.floorsFor('ZZQQ-olmayan-bant'),
          throwsA(isA<BatteryError>()),
          reason:
              'kapının yakalamayı iddia ettiği arıza gerçekten '
              'yakalanabiliyor olmalı',
        );
      });

      test(
        'bantlar GERÇEKTEN farklı taban üretiyor — kablolama kozmetik değil',
        () {
          // Kablolamanın bir ETKİSİ olmasaydı bu dosyanın tamamı tiyatro olurdu.
          final TestSpec reach = battery.tests['overhead_reach']!;
          final double u40 = _lowestFloor(reach.scoring.floorsFor('u40')!);
          final double older = _lowestFloor(reach.scoring.floorsFor('60plus')!);
          expect(
            u40,
            isNot(equals(older)),
            reason:
                'aynı ölçüm iki bantta AYNI tabana düşüyorsa bandı '
                'taşımanın kullanıcı için bir karşılığı yok demektir',
          );
        },
      );
    },
  );

  group('Onboarding yüzeyi', () {
    test('sunulan her bandın bir ETİKETİ var', () {
      for (final String band in kOfferedAgeBands) {
        expect(
          kAgeBandLabels.containsKey(band),
          isTrue,
          reason:
              '«$band» etiketsiz — ekranda anahtarın kendisi görünür '
              '(«60plus» gibi), yani kullanıcıya ham bir config değeri '
              'gösterilir',
        );
      }
    });
  });

  group('Motor bağlantısı — beyan MOTORA ve KAYDA ulaşıyor', () {
    test('beyan edilen bant motora geçer ve provenance\'a yazılır', () {
      final TestSpec reach = battery.tests['overhead_reach']!;
      final AssessmentEngine engine = buildLiveEngine(
        test: reach,
        side: 'right',
        declaredAgeBand: '60plus',
        batteryVersion: 'test',
        metricReader: (PoseFrame f, String m) => null,
      );
      expect(
        engine.ageBand,
        '60plus',
        reason:
            'ekranın motoru kurduğu TEK yol bu — bant burada '
            'düşerse kullanıcının seçimi hiçbir şeye dokunmaz',
      );

      final AssessmentResult r = _finishWithoutFrames(reach, '60plus');
      expect(
        r.provenance['ageBand'],
        '60plus',
        reason: 'ölçümün HANGİ bantla skorlandığı kaydın parçasıdır',
      );
    });

    test(
      'beyan YOKKEN en muhafazakâr bant — ve kayıt bunu boş dizeyle söyler',
      () {
        final TestSpec reach = battery.tests['overhead_reach']!;
        expect(effectiveAgeBand(reach, null), isNull);
        expect(_finishWithoutFrames(reach, null).provenance['ageBand'], '');
      },
    );
  });

  group('EMNİYET KEMERİ — tanınmayan bant çıkmaz sokak ÜRETMEZ', () {
    test(
      'bu testte tanınmayan bant DÜŞÜRÜLÜR, fırlatmaz, ve İSİMLE kaydedilir',
      () {
        final TestSpec reach = battery.tests['overhead_reach']!;
        expect(
          effectiveAgeBand(reach, 'eski-bant-adi'),
          isNull,
          reason: 'motora geçseydi floorsFor FIRLATIRDI',
        );

        final AssessmentResult r = _finishWithoutFrames(reach, 'eski-bant-adi');
        expect(
          r.provenance['ageBand'],
          '',
          reason: 'en muhafazakâr banda dönüldü',
        );
        expect(
          r.provenance['ageBandDeclaredButUnknown'],
          'eski-bant-adi',
          reason: 'SESSİZ düşürme yasak — kayıt beyanın düştüğünü söylemeli',
        );
      },
    );

    test(
      'nitel test (bandı olmayan) beyanı sessizce yutmaz, sadece kullanmaz',
      () {
        final TestSpec qualitative = battery.tests.values.firstWhere(
          (TestSpec t) => t.scoring.bandFloorsByAge.isEmpty,
        );
        expect(effectiveAgeBand(qualitative, 'u40'), isNull);
        // Burada 'düştü' demek YANLIŞ olurdu: bant geçerli, test bantsız.
        final AssessmentResult r = _finishWithoutFrames(qualitative, 'u40');
        expect(
          r.provenance.containsKey('ageBandDeclaredButUnknown'),
          isFalse,
          reason:
              'bant TANINMADI değil, test BANTSIZ — ikisi ayrı olgu ve '
              'kayıt geçerli bir beyanı "bilinmeyen" diye damgalamamalı',
        );
      },
    );
  });

  group('ZİNCİR — halka halka, kabuktan motora', () {
    testWidgets('kabuk bandı HomeScreen üzerinden LiveCaptureScreen\'e taşır', (
      WidgetTester tester,
    ) async {
      pinNarrowSurface(tester);
      final AppFacts facts = factsFromDisk();
      expect(
        facts.live,
        isNotEmpty,
        reason:
            'POZİTİF ÇAPA — canlı test yoksa "Start" düğmesi hiç '
            'çizilmez ve bu test vakum-doğru olur',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: LissomShell(
            loader: () async => facts,
            ageBand: '60plus',
            measurementAvailable: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
      await tester.tap(find.byKey(HomeScreen.startMeasurementKey));
      await tester.pumpAndSettle();

      final LiveCaptureScreen screen = tester.widget<LiveCaptureScreen>(
        find.byType(LiveCaptureScreen),
      );
      expect(
        screen.ageBand,
        '60plus',
        reason: 'zincirin kabuk→home→ölçüm halkası',
      );
    });

    testWidgets('onboarding AZ ÖNCE bitince bant kabuğa ULAŞIR — bir sonraki '
        'açılışı BEKLEMEZ', (WidgetTester tester) async {
      pinNarrowSurface(tester);
      final AppFacts facts = factsFromDisk();
      final _MemoryOnboardingStore store = _MemoryOnboardingStore();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: OnboardingGate(
            storeLoader: () async => store,
            shellLoader: () async => facts,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // O1 Welcome → O2 Disclaimer → O3 Camera → O4 Profile → O5 Limits
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.ageBand.60plus')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();

      expect(
        store.written?.ageBand,
        '60plus',
        reason: 'POZİTİF ÇAPA — akış gerçekten tamamlanmalı',
      );

      final LissomShell shell = tester.widget<LissomShell>(
        find.byType(LissomShell),
      );
      expect(
        shell.ageBand,
        '60plus',
        reason:
            'geçit `_loaded`\'ı diskten YENİDEN OKUMUYOR (bilerek). '
            'Bant `onDone` ile taşınmazsa kabuk AÇILIŞTA okunmuş BOŞ '
            'profili görür ve kullanıcının İLK ölçümü yanlış bantla '
            'koşar — beyan bir sonraki açılışa kadar ölüdür.',
      );
    });
  });
}

class _MemoryOnboardingStore implements OnboardingStore {
  OnboardingProfile? written;

  @override
  Future<OnboardingProfile> read() async =>
      written ?? const OnboardingProfile.notStarted();

  @override
  Future<void> write(OnboardingProfile profile) async => written = profile;
}
