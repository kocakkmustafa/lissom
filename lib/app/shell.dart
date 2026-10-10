/// Dört sekmeli kabuk — IA config'in `tabs` listesinden TÜRETİLİR.
///
/// **Kabuk yalnız KABLOLAMA (G-100).** Hiçbir hüküm burada yaşamaz: sekme
/// adları config'ten, testlerin canlılığı köprüden, geçmişin sağlığı depodan
/// gelir. Bu dosya hâlleri GÖSTERİR, karar VERMEZ.
///
/// ## Sekme kapısı — sessiz sapma İMKÂNSIZ
///
/// Config dört sekme beyan ediyor; kod dördünü uyguluyor. İkisi ayrışırsa
/// (config'e beşinci sekme eklenir, ya da bir ad değişir) kabuk **sessizce
/// dördünü göstermez** — [_TabMismatchScreen] iki kümeyi de ADIYLA basar.
///
/// Alternatif — bilinen sekmeleri gösterip bilinmeyeni atlamak — tam olarak
/// ailenin 4. dersidir: *yapısal kaldırma, yokluk iddialarını sessizce
/// vakum-doğru yapar.* Config'e eklenen bir sekme hiç görünmez, hiçbir test
/// kırmızıya dönmez ve kimse fark etmez.
///
/// ## Neden `IndexedStack` değil
///
/// Dört sekme de aynı [AppFacts] örneğini okuyor — durum sekmede DEĞİL,
/// yukarıda. Sekme değişimi bir yeniden-yapıdır, bir yeniden-yükleme değil;
/// geçmiş dosyası her dokunuşta yeniden okunmaz.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;
import 'package:motion_core/motion_core.dart';

import 'app_facts.dart';
import 'attempt_values.dart';
import 'home_screen.dart';
import 'hatha_progress.dart';
import 'hatha_course_screen.dart';
import 'library_screen.dart';
import 'lissom_theme.dart';
import 'local_account_bridge.dart';
import 'locale_text.dart';
import 'assessment_history.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

/// Kodun UYGULADIĞI sekmeler — SIRA dahil. Config bununla karşılaştırılır.
const List<String> kImplementedTabs = <String>[
  'home',
  'library',
  'progress',
  'profile',
];

class LissomShell extends StatefulWidget {
  const LissomShell({
    super.key,
    this.loader,
    this.ageBand,
    this.poseSourceLoader,
    this.sessionStoreLoader,
    this.attemptValueStoreLoader,
    this.localScope = LissomLocalScope.guest,
    this.accountRouteBuilder,
    this.beforeMeasurement,
    this.measurementAvailable,
  });

  final LissomLocalScope localScope;
  final LissomAccountRouteBuilder? accountRouteBuilder;
  final Future<bool> Function(BuildContext)? beforeMeasurement;

  /// Null follows the shared release policy. Tests can exercise the future
  /// camera journey without changing the production default.
  final bool? measurementAvailable;

  /// Testte enjekte edilebilir: `rootBundle` widget testinde kilitlenebiliyor
  /// (aile gotcha'sı), o yüzden yükleyici ÇAĞIRANA ait.
  final Future<AppFacts> Function()? loader;

  /// **A1 DİKİŞİ (L-309)** — `HomeScreen`e AYNEN taşınır, burada
  /// YORUMLANMAZ. Kabuk yalnız kablolamadır (G-100): bu iki alan da
  /// `ageBand`la aynı sözleşmede — taşınır, okunmaz.
  final PoseSource Function()? poseSourceLoader;
  final Future<SessionStore> Function()? sessionStoreLoader;

  /// D13/F2 — `LibraryScreen` → `TestDetailScreen` yoluna taşınır. AYNI
  /// sözleşme: kabuk yorumlamaz, yalnız kablolar.
  final Future<AttemptValueStore> Function()? attemptValueStoreLoader;

  /// Onboarding'de beyan edilen yaş bandı (`u40` · `40-59` · `60plus`) —
  /// kabuk bunu YORUMLAMAZ, yalnız TAŞIR (G-100: kabuk yalnız kablolama).
  /// `null` → beyan yok; motor en muhafazakâr bandı kullanır.
  final String? ageBand;

  @override
  State<LissomShell> createState() => _LissomShellState();
}

class _LissomShellState extends State<LissomShell> {
  /// ⚠️ `late final` DEĞİL — bilerek (L-287).
  ///
  /// `AppFacts` GEÇMİŞİ de taşıyor (`SessionHistoryView.read`). Bir kez
  /// okunup dondurulduğunda, kullanıcı ölçüm yapıp döndüğünde Home ve
  /// Progress **hâlâ ölçümden ÖNCEKİ dünyayı** gösteriyordu: kayıt diskte
  /// DOĞRU, yüzey onu göstermiyor. Ölçümü kaydetmek (L-285) tek başına
  /// yetmedi — *bir verinin YAZILMASI, GÖRÜNMESİ değildir.*
  late Future<AppFacts> _facts = _loadFacts();
  int _index = 0;

  Future<AppFacts> _loadFacts() =>
      (widget.loader ?? () => AppFacts.load(scope: widget.localScope))();

  @override
  void didUpdateWidget(covariant LissomShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localScope.lifetimeKey != widget.localScope.lifetimeKey) {
      _index = 0;
      _facts = _loadFacts();
    }
  }

  /// Ölçümden dönüşte geçmişi YENİDEN okur.
  ///
  /// Config değil GEÇMİŞ değiştiği için tümünü yeniden okumak fazladan iş
  /// gibi görünür — ama `AppFacts` tek parça bir olgu kümesi ve yarısını
  /// tazelemek iki kaynak tek olgu üretirdi (L-272). Ölçüm sonrası TEK bir
  /// dönüşte oluyor, sıcak yol değil.
  ///
  /// ⚠️ Gövde BLOK, ok-fonksiyonu DEĞİL: `setState(() => _facts = …)` atamanın
  /// DEĞERİNİ (bir `Future`) döndürür ve Flutter bunu *"setState callback
  /// argument returned a Future"* diye reddeder. Framework bu kusuru ilk
  /// koşumda yakaladı.
  void _reloadFacts() {
    setState(() {
      _facts = _loadFacts();
    });
  }

  Future<HathaProgressStore> Function() _hathaStoreLoader() {
    final LissomLocalScope scope = widget.localScope;
    return () => openHathaProgressStore(
      scope: scope,
      canWrite: () => mounted &&
          (scope.owner?.isActive ?? true) &&
          widget.localScope.lifetimeKey == scope.lifetimeKey,
    );
  }

  Future<SessionStore> Function() _sessionStoreLoader() {
    final LissomLocalScope scope = widget.localScope;
    return widget.sessionStoreLoader ?? () => openSessionStore(scope: scope);
  }

  Future<AttemptValueStore> Function() _attemptValueStoreLoader() {
    final LissomLocalScope scope = widget.localScope;
    return widget.attemptValueStoreLoader ??
        () => openAttemptValueStore(scope: scope);
  }

  Future<void> _openHatha(
    AppFacts facts, {
    bool chairOffice = false,
    bool vinyasa = false,
    bool yin = false,
  }) async {
    final course = yin ? facts.yin : vinyasa ? facts.vinyasa : chairOffice ? facts.chairOffice : facts.hatha;
    if (course == null) return;
    final Future<HathaProgressStore> Function() storeLoader =
        _hathaStoreLoader();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HathaCourseScreen(
          course: course,
          initialProgress:
              facts.hathaProgress ??
              const HathaProgress(
                records: <HathaPracticeRecord>[],
                unreadableRecords: 0,
              ),
          storeLoader: storeLoader,
        ),
      ),
    );
    if (mounted) _reloadFacts();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppFacts>(
    future: _facts,
    builder: (BuildContext c, AsyncSnapshot<AppFacts> s) {
      // ÇIKMAZ-SOKAK YASAĞI (M-F-267): config okunamazsa ekran yine AÇILIR
      // ve sebebi SÖYLER. Sessiz boş ekran / sonsuz spinner yasak.
      if (s.hasError) return _LoadFailureScreen(error: '${s.error}');
      if (!s.hasData) return const _LoadingScreen();

      final AppFacts facts = s.data!;
      if (!_tabsMatch(facts)) {
        return _TabMismatchScreen(declared: facts.ia.tabs);
      }
      return Scaffold(
        body: SafeArea(bottom: false, child: _page(facts)),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (int i) => setState(() => _index = i),
          backgroundColor: LissomColors.card,
          indicatorColor: LissomColors.cream,
          surfaceTintColor: Colors.transparent,
          destinations: <Widget>[
            for (final String id in facts.ia.tabs)
              NavigationDestination(
                icon: Icon(_icons[id]),
                // Etiket id'den TÜRETİLİR — ikinci bir ad listesi
                // tutmuyoruz, çünkü iki liste ayrışır.
                label: _label(context, id),
              ),
          ],
        ),
      );
    },
  );

  static bool _tabsMatch(AppFacts facts) {
    final List<String> declared = facts.ia.tabs;
    if (declared.length != kImplementedTabs.length) return false;
    for (int i = 0; i < declared.length; i++) {
      if (declared[i] != kImplementedTabs[i]) return false;
    }
    return true;
  }

  Widget _page(AppFacts facts) => switch (facts.ia.tabs[_index]) {
    'home' => HomeScreen(
      facts: facts,
      beforeMeasurement: widget.beforeMeasurement,
      measurementAvailable:
          widget.measurementAvailable ?? motionPaidFeaturesAvailable,
      ageBand: widget.ageBand,
      onOpenLibrary: () =>
          setState(() => _index = facts.ia.tabs.indexOf('library')),
      onMeasurementDone: _reloadFacts,
      onOpenHatha: () => _openHatha(facts),
      onOpenYin: () => _openHatha(facts, yin: true),
      onOpenVinyasa: () => _openHatha(facts, vinyasa: true),
      onOpenChairOffice: () => _openHatha(facts, chairOffice: true),
      poseSourceLoader: widget.poseSourceLoader,
      sessionStoreLoader: _sessionStoreLoader(),
      attemptValueStoreLoader: _attemptValueStoreLoader(),
    ),
    'library' => LibraryScreen(
      facts: facts,
      onCourseDone: _reloadFacts,
      hathaStoreLoader: _hathaStoreLoader(),
      attemptValueStoreLoader: _attemptValueStoreLoader(),
    ),
    'progress' => ProgressScreen(facts: facts),
    'profile' => ProfileScreen(
      facts: facts,
      accountRouteBuilder: widget.accountRouteBuilder,
    ),
    // Erişilemez: `_tabsMatch` yukarıda kapıyı tutuyor. Yine de sessiz
    // boş widget DEĞİL — bir gün kapı gevşerse bu görünür olmalı.
    final String other => _TabMismatchScreen(declared: <String>[other]),
  };

  static const Map<String, IconData> _icons = <String, IconData>{
    'home': Icons.home_outlined,
    'library': Icons.grid_view_outlined,
    'progress': Icons.receipt_long_outlined,
    'profile': Icons.person_outline,
  };

  static String _label(BuildContext context, String id) => switch (id) {
    'home' => localeText(context, 'Home', 'Ana Sayfa'),
    'library' => localeText(context, 'Library', 'Kütüphane'),
    'progress' => localeText(context, 'Progress', 'İlerleme'),
    'profile' => localeText(context, 'Profile', 'Profil'),
    _ => id,
  };
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: DecoratedBox(
      decoration: BoxDecoration(gradient: LissomColors.screenBackground),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

/// Yükleme patladı — sebep YUTULMAZ.
class _LoadFailureScreen extends StatelessWidget {
  const _LoadFailureScreen({required this.error});
  static const Key key_ = Key('shell.loadFailure');
  final String error;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      key: key_,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: LissomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    localeText(
                      context,
                      "Lissom couldn't start",
                      'Lissom başlatılamadı',
                    ),
                    style: t.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      'The files that describe the tests and the app layout could not be read.',
                      'Testleri ve uygulama düzenini tanımlayan dosyalar okunamadı.',
                    ),
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(error, style: t.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Config'in beyan ettiği sekmeler kodun uyguladıklarıyla AYRIŞTI.
class _TabMismatchScreen extends StatelessWidget {
  const _TabMismatchScreen({required this.declared});
  static const Key key_ = Key('shell.tabMismatch');
  final List<String> declared;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      key: key_,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LissomColors.screenBackground,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: LissomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    localeText(
                      context,
                      'The app layout and the app do not agree',
                      'Uygulama düzeniyle uygulama uyuşmuyor',
                    ),
                    style: t.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localeText(
                      context,
                      'Layout file declares: ${declared.join(" · ")}',
                      'Düzen dosyasındaki sekmeler: ${declared.join(" · ")}',
                    ),
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localeText(
                      context,
                      'This build implements: ${kImplementedTabs.join(" · ")}',
                      'Bu sürümdeki sekmeler: ${kImplementedTabs.join(" · ")}',
                    ),
                    style: t.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    localeText(
                      context,
                      'Showing only the tabs we recognise would hide the difference, so we are showing you the difference.',
                      'Farkı gizlememek için sekme uyuşmazlığını burada gösteriyoruz.',
                    ),
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
