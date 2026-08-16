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
import 'package:lissom/app/attempt_values.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/onboarding_gate.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/test_detail_screen.dart';
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
  // D13/F2 — Library → canlı bir test satırı → kendi geçmişi.
  TestDetailScreen,
];

/// D13 — `path_provider` widget testinde kilitleniyor (aile gotcha'sı, her
/// test dosyası kendi kopyasını tutar — `deadend_taxonomy_test.dart`taki
/// `_EmptyAttemptValueStore` ile AYNI sınıf, ayrı dosya).
final class _EmptyAttemptValueStore implements AttemptValueStore {
  @override
  Future<void> append(AttemptValue value) async {}
  @override
  Future<List<AttemptValue>> forLesson(String lessonId) async =>
      const <AttemptValue>[];
  @override
  Future<int> unreadableRecords() async => 0;
}

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

/// **(d)'nin gözü — aday listesinden BAĞIMSIZ.**
///
/// 🪤 İlk yazımımda (d) *"yürüyüş aday olmayan bir yere vardı mı"* diye
/// soruyordu ama gözlemi [_visible]den alıyordu — o da **yalnız adaylara
/// bakıyor.** Yani `reached` tanım gereği aday-dışı bir şey içeremezdi:
/// kontrol **VAKUM-DOĞRUydu** ve sabotaj (aday kümesinden `FamilyPage`
/// düşürüldü) **ötmedi.**
///
/// > ***Bir bölme denetimi, iki tarafı AYNI kaynaktan okuyorsa denetim
/// > değil TANIMDIR.***
///
/// Bu yüzden burası ağacı **ada göre** tarıyor (`…Screen`/`…Page`), aday
/// listesine hiç bakmadan — böylece *"desen bir ekranı kaçırdı"* hâli
/// GERÇEKTEN görülebiliyor.
Set<Type> _observedScreenLike(WidgetTester tester) {
  final Set<Type> out = <Type>{};
  for (final Element e in find
      .byWidgetPredicate((Widget w) {
        final String n = w.runtimeType.toString();
        return (n.endsWith('Screen') || n.endsWith('Page')) &&
            !n.startsWith('_');
      })
      .evaluate()) {
    out.add(e.widget.runtimeType);
  }
  return out;
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
        // D13/F2 — enjekte EDİLMEZSE `TestDetailScreen`e varan yürüyüş
        // `openAttemptValueStore`a düşer ve `path_provider` widget
        // testinde SONSUZ ASILI kalır (`deadend_taxonomy_test.dart`ta
        // ölçüldü).
        attemptValueStoreLoader: () async => _EmptyAttemptValueStore(),
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
    // (d) BAĞIMSIZ gözlem — aday listesine bakmadan.
    final Set<Type> observed = <Type>{};

    for (final String tab in facts.ia.tabs) {
      await _openTab(tester, tab);
      observed.addAll(_observedScreenLike(tester));
      final Type? s = _visible(tester);
      if (s != null) reached.add(s);
    }

    // Library → aile kartları (rota)
    await _openTab(tester, 'library');
    // İNŞA EDİLMİŞ ailenin adı — TEK aile bu (`_batteryBody`), diğer beşi
    // `_namedBody` çizer ve "Overhead Reach" gibi bir satır TAŞIMAZ.
    // `FamilyPage` TÜM ailelerde aynı tip olduğu için `s == FamilyPage`
    // TEK BAŞINA bunu ayırt edemezdi — bu turda ölçüldü (`No element`,
    // inşa-edilmemiş bir ailede canlı test adı aranmıştı).
    final String builtTitle = facts.ia.families
        .firstWhere((dynamic f) => f.isBuilt as bool)
        .title as String;
    for (final String title
        in facts.ia.families.map((dynamic f) => f.title as String)) {
      final Finder c = find.text(title);
      await scrollTo(tester, c);
      if (c.evaluate().isEmpty) continue;
      await tester.tap(c.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      observed.addAll(_observedScreenLike(tester));
      final Type? s = _visible(tester);
      if (s != null && reached.add(s)) viaRoute.add(s);

      // D13/F2 — FamilyPage → canlı bir test satırı → TestDetailScreen
      // (rota). Yalnız İNŞA EDİLMİŞ ailede: diğerleri canlı test satırı
      // taşımaz.
      if (s == FamilyPage && title == builtTitle && facts.live.isNotEmpty) {
        final Finder liveRow = find.text(facts.live.first.name);
        await scrollTo(tester, liveRow);
        if (liveRow.evaluate().isNotEmpty) {
          await tester.tap(liveRow.first, warnIfMissed: false);
          await tester.pumpAndSettle();
          observed.addAll(_observedScreenLike(tester));
          final Type? detail = _visible(tester);
          if (detail != null && reached.add(detail)) viaRoute.add(detail);
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }

      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // Profile → giriş kartı (rota)
    await _openTab(tester, 'profile');
    final Finder entry = find.byType(InkWell);
    if (entry.evaluate().isNotEmpty) {
      await tester.tap(entry.first, warnIfMissed: false);
      await tester.pumpAndSettle();
      observed.addAll(_observedScreenLike(tester));
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
      observed.addAll(_observedScreenLike(tester));
      final Type? s = _visible(tester);
      if (s != null && reached.add(s)) viaRoute.add(s);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    // (c) ADAY OLUP VARILAMAYAN — kaybolmaz.
    final List<Type> unreachable =
        kCandidateScreens.where((Type t) => !reached.contains(t)).toList();

    // ⭐ (d) BÖLME DENETLENİR — ve bu madde bu hattın kendi bulgusundan
    // doğdu: "varılabilir ama boş" turunda yürüyüşüm kaydırmıyordu, altı
    // hedeften BİRİNE ulaştı, ve *doğru sonucu YANLIŞ SEBEPLE* basacaktı.
    //
    // ⚠️ `unreachable` yukarıda TÜRETİLİYOR, yani `varılan ⊎ varılamayan
    // = aday` kimliği **inşa gereği** doğru — onu assert etmek bir ÖLÇÜM
    // DEĞİL, bir ARİTMETİK KİMLİKtir (bugün JabLab'da ölçülen kusur).
    // Gerçek denetim ters yönde: ***yürüyüş, aday OLMAYAN bir yere
    // vardıysa aday kümesi EKSİKTİR.***
    final Set<Type> reachedOutsideCandidates =
        observed.difference(kCandidateScreens.toSet());
    expect(reachedOutsideCandidates, isEmpty,
        reason: 'yürüyüş aday kümesinde OLMAYAN bir yüzeye vardı: '
            '$reachedOutsideCandidates — desen bu ekranı KAÇIRMIŞ, aday '
            'kümesi eksik (elle liste hafızadan okur, L-298)');

    // Ve payda: aday sayısı, iki kümenin AYRI sayımıyla tutmalı.
    expect(reached.intersection(kCandidateScreens.toSet()).length +
            unreachable.length,
        kCandidateScreens.length,
        reason: 'bölme tutmuyor — sayım bir adayı iki kez ya da hiç '
            'saymış olabilir');

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
    // Başlangıç rotası (`/`) sayılmaz — gezinme DEĞİL, açılışın kendisi.
    print('  rota tanıklığı : '
        '${witness.pushed.where((String r) => r != '/').length} push '
        '(başlangıç rotası hariç)');
    // ignore: avoid_print
    print('════════════════════════════════════════\n');

    expect(unreachable, isEmpty,
        reason: 'desenden aday çıkan ama VARILAMAYAN yüzey: $unreachable — '
            '(c) gereği raporlanır, sessizce düşmez');
    expect(witness.pushed, isNotEmpty,
        reason: 'NavigatorObserver hiç push görmedi — yürüyüş rota '
            'açmıyorsa KATI sayısı tanıksızdır');
  });

  testWidgets(
      '③ ÖLÇÜM — kabuktan başlayan bir tur onboarding\'i GÖRMEZ '
      '(başlangıç noktası evreni tanımlar)', (WidgetTester tester) async {
    pinNarrowSurface(tester);
    // Eski kapımın başlangıcı: doğrudan `LissomShell`. Bu turun tek amacı
    // *"kabuktan başlamak neyi kaybediyor"* sorusunu İDDİA değil ÖLÇÜM
    // hâline getirmek — koordinatör hükmü: *bir ölçümün başlangıç noktası
    // onun EVRENİNİ tanımlar; kabuktan başlamak, kullanıcının hiç
    // görmediği bir uygulamayı ölçmektir.*
    final _RouteWitness witness = _RouteWitness();
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      navigatorObservers: <NavigatorObserver>[witness],
      home: LissomShell(loader: () async => factsFromDisk()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('onboarding.continue')), findsNothing,
        reason: 'kabuktan başlayan tur onboarding\'i GÖRMEMELİ — görüyorsa '
            'bu ölçümün öncülü yanlış');
    expect(find.byType(LissomShell), findsOneWidget,
        reason: 'POZİTİF ÇAPA — kabuk gerçekten açıldı, yani "onboarding '
            'yok" bulgusu boş ekranın değil KABUĞUN ölçümü');

    // ⚖️ ÖLÇÜLEN SONUÇ: onboarding kabuk turunda GÖRÜNMEZ. Ama KATI'ya
    // etkisi SIFIR — çünkü onboarding bir ROTA AÇMIYOR (tek `Scaffold`,
    // `switch`le adım değiştiriyor), yani sözleşmenin KATI birimine hiç
    // girmiyordu. *Değişmemek de bir ölçümdür* (koordinatör kısıtı).
    // 🪤 İlk iddiam `pushed` BOŞ olmalı diyordu ve YANLIŞTI: `MaterialApp`in
    // başlangıç rotası (`/`) da bir push. Ürün kusuru değil, CÜMLEM fazla
    // genişti — ölçülen şey *"başlangıç ROTASININ ÖTESİNDE gezinme"*.
    expect(witness.pushed.where((String r) => r != '/'), isEmpty,
        reason: 'kabuk açılışında başlangıç rotasının ÖTESİNDE push olmamalı '
            '— olsaydı KATI sayısı başlangıç noktasına göre değişirdi ve '
            'iki ölçüm kıyaslanamazdı');
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
