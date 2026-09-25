/// **A1 — TAM AKIŞ, TEK YÜRÜYÜŞ (L-309).**
///
/// Ölçüt (`YAYIN-HAZIRLIK-OLCUTU.md` A1): *"En az bir TAM AKIŞ baştan sona
/// çalışıyor — ilk açılış → seçim → oturum → sonuç"*, kanıtı **yürüyüş
/// testi, TAZE KURULUMDAN, `NavigatorObserver` tanığıyla.**
///
/// ## Neden bu dosya var — ölçülmüş boşluk
///
/// Zincir **iki yeşil yarımdı ve köprüsü yoktu**:
///
/// | yarım | nerede | eksik olan |
/// |---|---|---|
/// | taze kurulum → onboarding → kabuk → `LiveCaptureScreen` | `reachability_contract_test.dart` | ekrana varıp `pageBack` yapıyordu; **oturum yok, sonuç yok** |
/// | kare akışı → `Measuring` → *I'm done* → sonuç | `live_capture_screen_test.dart` | doğrudan `pumpWidget` + `FakePoseSource`; **yürüyüş yok, tanık yok** |
///
/// Ölçüm: `grep -rl "onboarding.continue" test/` **5 dosya** ·
/// `grep -rl "liveCapture.finish" test/` **2 dosya** · **kesişim BOŞ.**
/// (Pozitif kontrol: iki tarama da dolu döndü ⇒ boş kesişim aletin körlüğü
/// değil, ***gerçek bir boşluktu***.)
///
/// > ***İKİ YEŞİL YARIM BİR YEŞİL BÜTÜN DEĞİLDİR — aralarındaki dikiş
/// > hiçbirinin testinde geçmez.***
///
/// ## Köprünün kendisi: yeni desen DEĞİL, var olanın uzatılması
///
/// `LiveCaptureScreen.sourceOverride` **zaten vardı**; ona ulaşamayan şey
/// `HomeScreen`di (`home_screen.dart` `LiveCaptureScreen`i enjeksiyonsuz
/// kuruyordu). Dikiş `ageBand`ın izlediği yolun AYNISINDAN geçirildi:
/// `OnboardingGate → LissomShell → HomeScreen → LiveCaptureScreen`.
/// Üretimde iki alan da `null` ⇒ ekran kendi varsayılanlarını kurar
/// (`CameraPoseSource` / `openSessionStore`); ***enjeksiyon yürüyüşü mümkün
/// kılar, davranışı değiştirmez.***
///
/// ## ⚠️ NE KANITLAMIYOR — sınırı DAR yazmak, geniş yazmak kadar önemli
///
/// Bu yürüyüş **kamerayı kanıtlamaz.** Kaynak `FakePoseSource`; gerçek kare
/// akışı, gerçek ışıkta landmark kalitesi ve kalibrasyon eşiği hâlâ
/// **cihazda doğrulanmadı** (`live_capture_screen.dart` başlığındaki
/// *"Bağlandı ≠ canlı"* tablosu aynen geçerli, ve **A12 hâlâ açık**).
/// Kanıtlanan tam olarak şu: ***kullanıcının bastığı düğmeler, taze bir
/// kurulumdan bir ölçüm sonucuna kadar birbirine bağlı.***
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// ⚠️ **KARE, aspect-oranı BOZMAYAN bir yüzey.** `FrameSize(1080, 1920)`
/// normalize koordinatları farklı katsayılarla ölçekler ve sentetik bir dik
/// açı ekranda **dik olmaktan çıkar** — fixture'ın geometrisi ölçülen açıyı
/// sessizce değiştirirdi. Kare yüzeyde niyet ile ölçüm aynı şeyi söyler.
const FrameSize _size = FrameSize(1080, 1080);

/// **Sırtüstü düz bacak kaldırma (`active_straight_leg_raise`) duruşu.**
///
/// Landmark üçlüleri config'ten okundu, hafızadan yazılmadı:
/// `hip_flexion_right` = ∠(12 R_SHOULDER, 24 R_HIP, 26 R_KNEE) ·
/// `knee_flexion_right` = ∠(24, 26, 28) · `hip_flexion_left` = ∠(11, 23, 25).
///
/// Testin KENDİ geçersizleme kuralları duruşu belirledi (uydurulmadı):
/// `knee_flexion_{side} < 165` → `BENT_KNEE` (kaldırılan bacak DÜZ olmalı) ·
/// `hip_flexion_{opposite} < 170` → `OPPOSITE_LEG_LIFTED` (öteki bacak yerde).
PoseFrame _supineRaiseFrame({required double kneeY, int tUs = 0}) {
  // Gövde x ekseninde uzanıyor (baş solda, kalça sağda), y = zemin.
  const double floorY = 0.70;
  final List<PoseLandmark> lms = List<PoseLandmark>.generate(33, (int i) {
    return switch (i) {
      11 => const PoseLandmark(0.30, floorY, 0, 1), // sol omuz
      12 => const PoseLandmark(0.30, floorY, 0, 1), // sağ omuz
      23 => const PoseLandmark(0.55, floorY, 0, 1), // sol kalça
      24 => const PoseLandmark(0.55, floorY, 0, 1), // sağ kalça
      25 => const PoseLandmark(0.75, floorY, 0, 1), // sol diz — YERDE
      27 => const PoseLandmark(0.92, floorY, 0, 1), // sol ayak bileği — YERDE
      // Sağ bacak KALDIRILIYOR: diz kalçanın üstünde, ayak bileği aynı
      // hizada devam ediyor ⇒ diz DÜZ kalır (BENT_KNEE tetiklenmez).
      26 => PoseLandmark(0.55, kneeY, 0, 1),
      28 => PoseLandmark(0.55, kneeY - 0.23, 0, 1),
      _ => const PoseLandmark(0.5, 0.5, 0, 1),
    };
  });
  return PoseFrame(tUs: tUs, landmarks: lms);
}

/// Bacağın yerden ~dikeye kalktığı, tutulan bir deneme.
List<PoseSourceEvent> _raiseScript() => <PoseSourceEvent>[
  for (int i = 0; i <= 14; i++)
    SourceFrameEvent(
      _supineRaiseFrame(kneeY: 0.45, tUs: i * 100000),
      size: _size,
    ),
];

class _MemOnboardingStore implements OnboardingStore {
  OnboardingProfile p = const OnboardingProfile.notStarted();
  @override
  Future<OnboardingProfile> read() async => p;
  @override
  Future<void> write(OnboardingProfile profile) async => p = profile;
}

/// Ölçümün GERÇEKTEN yazıldığını görebilmek için — `_RecordingStore`
/// (`measurement_persistence_test.dart`) ile aynı şekil, ikinci bir sözleşme
/// icat edilmedi.
class _RecordingStore implements SessionStore {
  final List<SessionRecord> written = <SessionRecord>[];

  @override
  Future<void> append(SessionRecord r) async => written.add(r);

  /// Newest FIRST — çekirdeğin sözleşmesi.
  @override
  Future<List<SessionRecord>> recent({int? limit}) async {
    final List<SessionRecord> out = written.reversed.toList();
    return limit == null ? out : out.take(limit).toList();
  }

  @override
  Future<int> workedSecondsFor(String lessonId) async => 0;

  /// **0 bir VARSAYILAN değil, bir BEYAN** (çekirdeğin kendi hükmü): bu depo
  /// bellekte tutar, okunamayan kayıt kavramı YOKTUR. Sessiz bir varsayılan
  /// olsaydı, veri kaybeden bir uygulama tam da cevaplaması gereken soruda
  /// susabilirdi (M-F-228).
  @override
  Future<int> unreadableRecords() async => 0;
}

/// Rotaları YÜRÜYEREK tanıklayan gözlemci — sözleşme (b).
///
/// ⚠️ `route.name` bu uygulamada **boş**; tanık adı değil **OLAYI** sayar,
/// yoksa sessizce boş kalırdı (Ostinato, M-F-582).
class _RouteWitness extends NavigatorObserver {
  final List<String> pushed = <String>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) {
    pushed.add(route.settings.name ?? route.runtimeType.toString());
    super.didPush(route, previous);
  }
}

/// Taze kurulumdan onboarding'i **DÜĞMELERE BASARAK** geçer ve kabuğa varır.
/// Bayrak set EDİLMEZ (③ başlangıç kuralı).
Future<void> _walkThroughOnboarding(
  WidgetTester tester,
  _MemOnboardingStore store,
) async {
  // POZİTİF ÇAPA: soğuk açılış GERÇEKTEN onboarding'e düşmeli. Düşmezse
  // aşağıdaki her şey "kullanıcının hiç görmediği bir uygulamanın" ölçümü
  // olurdu.
  expect(
    find.byKey(const Key('onboarding.continue')),
    findsOneWidget,
    reason:
        'taze kurulumda onboarding görünmedi — başlangıç noktası '
        'uygulama kökü DEĞİL demektir',
  );
  expect(store.p.completed, isFalse, reason: 'ilk-koşu bayrağı false olmalı');

  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.ageBand.u40')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboarding.continue')));
  await tester.pumpAndSettle();

  expect(
    store.p.completed,
    isTrue,
    reason:
        'onboarding DÜĞMELERLE tamamlanmalıydı (bayrak set edilerek '
        'değil) — A2 tam olarak bunu istiyor',
  );
  expect(find.byType(LissomShell), findsOneWidget);
}

void main() {
  testWidgets(
    'A1 — TEK YÜRÜYÜŞ: taze kurulum → onboarding → Home → ölçüm → SONUÇ',
    (WidgetTester tester) async {
      pinNarrowSurface(tester);
      final AppFacts facts = factsFromDisk();
      final _RouteWitness witness = _RouteWitness();
      final _MemOnboardingStore onboarding = _MemOnboardingStore();
      final _RecordingStore sessions = _RecordingStore();

      // ③ BAŞLANGIÇ = UYGULAMA KÖKÜ. Kabuktan değil, kökten.
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          navigatorObservers: <NavigatorObserver>[witness],
          home: OnboardingGate(
            measurementAvailable: true,
            storeLoader: () async => onboarding,
            shellLoader: () async => facts,
            poseSourceLoader: () => FakePoseSource(_raiseScript()),
            sessionStoreLoader: () async => sessions,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _walkThroughOnboarding(tester, onboarding);

      // ── SEÇİM: Home'daki BOYANMIŞ düğme ────────────────────────────────
      // POZİTİF ÇAPA: düğme ancak motorun okuyabildiği EN AZ BİR test varsa
      // basılır. Yoksa bu yürüyüş vakum-doğru olurdu (*"ölçüm yapamadım ama
      // hata da yok"*).
      expect(
        facts.live,
        isNotEmpty,
        reason:
            'köprüde hiç canlı test yok — "Start a measurement" düğmesi '
            'zaten çizilmez ve bu yürüyüş hiçbir şey ölçmez',
      );

      await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
      final Finder start = find.byKey(HomeScreen.startMeasurementKey);
      expect(
        start,
        findsOneWidget,
        reason:
            'Home ölçüme giden boyanmış kontrolü sunmuyor — zincir '
            'burada kopuk',
      );

      final int pushesBefore = witness.pushed
          .where((String r) => r != '/')
          .length;
      await tester.tap(start);
      await tester.pumpAndSettle();

      // (b) ÜYELİK YÜRÜYEREK: ölçüm ekranına GERÇEK bir rota ile gelindi.
      expect(
        witness.pushed.where((String r) => r != '/').length,
        greaterThan(pushesBefore),
        reason:
            'ölçüm ekranı bir rota push\'u ile açılmadı — tanıksız bir '
            'varış, yürüyüş sayılmaz',
      );

      // ── OTURUM: enjekte kaynaktan gerçek kareler ───────────────────────
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      final Finder finish = find.byKey(const Key('liveCapture.finish'));
      expect(
        finish,
        findsOneWidget,
        reason:
            'kare akışı `Measuring` hâlini üretmeliydi — üretmediyse '
            'Home\'dan açılan ekran kaynağı almıyor, yani dikiş kopuk',
      );

      await tester.tap(finish);
      await tester.pumpAndSettle();

      // ── SONUÇ ──────────────────────────────────────────────────────────
      expect(
        find.byKey(const Key('liveCapture.tryAgain')),
        findsOneWidget,
        reason: 'bitirince SONUÇ yüzeyi görünmeli — A1\'in son halkası',
      );

      // Ve sonuç bir OLGUYA bağlandı: kayıt gerçekten deponun içine düştü.
      // ⚠️ Değer/bant ÇİVİLENMİYOR (L-239: sayıyı değil KURALI ölç) — ölçülen
      // şey *"bir deneme yazıldı"*, *"şu skor çıktı"* değil.
      expect(
        sessions.written,
        hasLength(1),
        reason:
            'yürüyüş sonuca vardı ama depoya hiçbir şey yazılmadı — '
            'kullanıcının gördüğü sonuç hiçbir yere bağlanmıyor demektir',
      );

      // ignore: avoid_print
      print('\n═══ A1 — TAM AKIŞ (L-309) ═══');
      // ignore: avoid_print
      print('  başlangıç      : UYGULAMA KÖKÜ (taze kurulum, bayrak false)');
      // ignore: avoid_print
      print('  onboarding     : ${'düğmeyle geçildi'} (7 dokunuş)');
      // ignore: avoid_print
      print(
        '  seçilen test   : ${facts.live.first.testId} '
        '(canlı ${facts.live.length}/${facts.liveness.length})',
      );
      // ignore: avoid_print
      print(
        '  rota tanıklığı : '
        '${witness.pushed.where((String r) => r != '/').length} push '
        '(başlangıç rotası hariç)',
      );
      // ignore: avoid_print
      print(
        '  yazılan kayıt  : ${sessions.written.length} '
        '(${sessions.written.single.lessonId})',
      );
      // ignore: avoid_print
      print('════════════════════════════\n');
    },
  );

  testWidgets(
    'SABOTAJ — kaynak BOŞken yürüyüş sonuca VARAMAZ (yürüyüşün kendisi '
    'vakum-doğru değil)',
    (WidgetTester tester) async {
      pinNarrowSurface(tester);
      // 🔒 Bu ikiz olmadan yukarıdaki test *"her koşulda yeşil"* olabilirdi.
      // > ***Bir yürüyüşün başarısı, ancak BAŞARISIZ OLABİLDİĞİ gösterildiğinde
      // > ölçümdür.*** Tek fark: kaynak script'i BOŞ. Aynı dikiş, aynı yol.
      final AppFacts facts = factsFromDisk();
      final _MemOnboardingStore onboarding = _MemOnboardingStore();
      final _RecordingStore sessions = _RecordingStore();

      await tester.pumpWidget(
        MaterialApp(
          theme: buildLissomTheme(),
          home: OnboardingGate(
            measurementAvailable: true,
            storeLoader: () async => onboarding,
            shellLoader: () async => facts,
            poseSourceLoader: () =>
                FakePoseSource(const <PoseSourceEvent>[]), // ⛔ BOŞ
            sessionStoreLoader: () async => sessions,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _walkThroughOnboarding(tester, onboarding);

      await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
      await tester.tap(find.byKey(HomeScreen.startMeasurementKey));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.byKey(const Key('liveCapture.finish')),
        findsNothing,
        reason:
            'kare yokken "I\'m done" görünüyorsa ekran uyduruyor — ve '
            'yukarıdaki yürüyüş hiçbir şey kanıtlamıyor demektir',
      );
      expect(
        sessions.written,
        isEmpty,
        reason: 'ölçüm hiç olmadı; depoya kayıt düşmemeli',
      );
    },
  );
}
