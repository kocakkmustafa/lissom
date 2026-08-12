/// **GEZİLEBİLİRLİK SÖZLEŞMESİ — aile hükmü, kendi ağacımda (L-298).**
///
/// Koordinatör beş hatta bağlayıcı bir sözleşme verdi. Bende **iki parça
/// eksikti** ve ikisi de KATI sayısını bozuyordu:
///
/// **② ENVANTER — elle liste HAFIZADAN okur.** Eski kapım
/// `const List<Type> kCountableScreens` tutuyordu: *"tek adres"* olması onu
/// **tazeleyen** bir şey değil, yalnız **tek yerde** tutuyor.
/// > ***Bir elle liste, modülün kendisi değil onun ANLATIMIDIR*** — ve bu,
/// > bu hattın bugün üç kez ödediği kuralın aynısı.
/// Kusuru **sessiz ve sınırsız**: *ne unuttuğunu bilemezsin.* Ve gerçekten
/// unutmuştu (aşağıda).
///
/// **③ BAŞLANGIÇ — kabuktan başlamak, kullanıcının hiç görmediği bir
/// uygulamayı ölçmektir.** Eski kapım `LissomShell`den başlıyordu; aile
/// hükmü **uygulama kökü / soğuk açılış** diyor — ve ailenin 08-07 hükmü
/// **tam olarak onboarding hakkındaydı.**
///
/// ## Sözleşmenin üç parçası
///
/// **a) Aday küme DESENDEN türetilir** — koddan okunur (Scaffold sahibi
/// yüzeyler + kabuğun `switch`iyle çizilen sekme gövdeleri), elle
/// yazılmaz.
/// **b) Üyelik YÜRÜYEREK kanıtlanır** — `NavigatorObserver` tanıklığı +
/// boyanmış kontrole basmak.
/// **c) Aday olup VARILAMAYAN ayrı raporlanır** — KATI'ya girmez, **ama
/// kaybolmaz.**
///
/// > ***Yürüyüş VARLIĞI kanıtlar, YOKLUĞU kanıtlamaz — bir yokluk iddiası,
/// > BEKLENEN bir küme olmadan kurulamaz.*** (a) o kümeyi verir.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

/// **(a) DESENDEN türetilmiş aday küme.**
///
/// `tools/reachability_candidates.py` kodu tarayarak üretir; burada o
/// çıktının Dart karşılığı **tip olarak** duruyor çünkü `find.byType`
/// çalışma-anı tipi ister. ⚠️ Liste elle GENİŞLETİLMEZ: script'in bulduğu
/// her aday burada olmalı, ve `reachability_candidates.py` ikisini
/// karşılaştırıp ayrışmayı KIRMIZI yakar.
const List<Type> kCandidateScreens = <Type>[
  // kabuk sekme gövdeleri (kabuğun `switch`i çizer)
  HomeScreen, LibraryScreen, ProgressScreen, ProfileScreen,
  // ayrı rotalar (push)
  FamilyPage, WhatLissomDoesntDoScreen, LiveCaptureScreen,
];

/// Rotaları YÜRÜYEREK tanıklayan gözlemci — (b).
class _RouteWitness extends NavigatorObserver {
  final List<String> pushed = <String>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) {
    final String? n = route.settings.name;
    pushed.add(n ?? route.runtimeType.toString());
    super.didPush(route, previous);
  }
}

class _MemStore implements OnboardingStore {
  OnboardingProfile p = const OnboardingProfile.notStarted();
  @override
  Future<OnboardingProfile> read() async => p;
  @override
  Future<void> write(OnboardingProfile profile) async => p = profile;
}

Type? _visible(WidgetTester tester) {
  for (final Type t in kCandidateScreens) {
    if (find.byType(t).evaluate().isNotEmpty) return t;
  }
  return null;
}

void main() {
  testWidgets('SÖZLEŞME — uygulama kökünden, desen adayı, yürüyerek üyelik',
      (WidgetTester tester) async {
    pinNarrowSurface(tester);
    final AppFacts facts = factsFromDisk();
    final _RouteWitness witness = _RouteWitness();
    final _MemStore store = _MemStore();

    // ③ BAŞLANGIÇ = UYGULAMA KÖKÜ, taze kurulum, ilk-koşu bayrağı false.
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      navigatorObservers: <NavigatorObserver>[witness],
      home: OnboardingGate(
        storeLoader: () async => store,
        shellLoader: () async => facts,
      ),
    ));
    await tester.pumpAndSettle();

    // POZİTİF ÇAPA: soğuk açılış GERÇEKTEN onboarding'e düşmeli — düşmezse
    // aşağıdaki sayı kabuktan başlamış olur ve sözleşmeyi ihlal eder.
    expect(find.byKey(const Key('onboarding.continue')), findsOneWidget,
        reason: 'taze kurulumda onboarding görünmedi — başlangıç noktası '
            'uygulama kökü DEĞİL demektir');
    expect(store.p.completed, isFalse, reason: 'ilk-koşu bayrağı false olmalı');

    // Onboarding DÜĞMEYE BASILARAK geçilir (bayrak SET EDİLEREK değil).
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

    expect(store.p.completed, isTrue,
        reason: 'onboarding düğmelerle tamamlanmalıydı');
    expect(find.byType(LissomShell), findsOneWidget);

    // (b) ÜYELİK YÜRÜYEREK — sekmeler + boyanmış kontroller.
    final Set<Type> reached = <Type>{};
    final Set<Type> viaRoute = <Type>{};

    for (final String tab in facts.ia.tabs) {
      await _openTab(tester, tab);
      final Type? s = _visible(tester);
      if (s != null) reached.add(s);
    }

    // Library → aile kartları (rota)
    await _openTab(tester, 'library');
    for (final String title
        in facts.ia.families.map((dynamic f) => f.title as String)) {
      final Finder c = find.text(title);
      await scrollTo(tester, c);
      if (c.evaluate().isEmpty) continue;
      await tester.tap(c.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      final Type? s = _visible(tester);
      if (s != null && reached.add(s)) viaRoute.add(s);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Profile → giriş kartı (rota)
    await _openTab(tester, 'profile');
    final Finder entry = find.byType(InkWell);
    if (entry.evaluate().isNotEmpty) {
      await tester.tap(entry.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      final Type? s = _visible(tester);
      if (s != null && reached.add(s)) viaRoute.add(s);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Home → "Start a measurement" (rota) — ESKİ KAPIMIN GÖRMEDİĞİ YOL.
    await _openTab(tester, 'home');
    await scrollTo(tester, find.byKey(HomeScreen.quickStartKey));
    final Finder start = find.byKey(HomeScreen.startMeasurementKey);
    if (start.evaluate().isNotEmpty) {
      await tester.tap(start);
      await tester.pumpAndSettle();
      final Type? s = _visible(tester);
      if (s != null && reached.add(s)) viaRoute.add(s);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // (c) ADAY OLUP VARILAMAYAN — kaybolmaz.
    final List<Type> unreachable =
        kCandidateScreens.where((Type t) => !reached.contains(t)).toList();

    // ignore: avoid_print
    print('\n═══ GEZİLEBİLİRLİK — SÖZLEŞME (L-298) ═══');
    // ignore: avoid_print
    print('  başlangıç      : UYGULAMA KÖKÜ (soğuk açılış, onboarding dahil)');
    // ignore: avoid_print
    print('  aday (desenden): ${kCandidateScreens.length}');
    // ignore: avoid_print
    print('  KATI (rota)    : ${viaRoute.length}  $viaRoute');
    // ignore: avoid_print
    print('  varıldı toplam : ${reached.length}');
    // ignore: avoid_print
    print('  VARILAMAYAN    : ${unreachable.length}  $unreachable');
    // ignore: avoid_print
    print('  rota tanıklığı : ${witness.pushed.length} push');
    // ignore: avoid_print
    print('════════════════════════════════════════\n');

    expect(unreachable, isEmpty,
        reason: 'desenden aday çıkan ama VARILAMAYAN yüzey: $unreachable — '
            '(c) gereği raporlanır, sessizce düşmez');
    expect(witness.pushed, isNotEmpty,
        reason: 'NavigatorObserver hiç push görmedi — yürüyüş rota '
            'açmıyorsa KATI sayısı tanıksızdır');
  });
}

Future<void> _openTab(WidgetTester tester, String id) async {
  const Map<String, IconData> icons = <String, IconData>{
    'home': Icons.home_outlined,
    'library': Icons.grid_view_outlined,
    'progress': Icons.receipt_long_outlined,
    'profile': Icons.person_outline,
  };
  await tester.tap(find.byIcon(icons[id]!).first, warnIfMissed: false);
  await tester.pumpAndSettle();
}
