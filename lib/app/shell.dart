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

import 'app_facts.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'lissom_theme.dart';
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
  const LissomShell({super.key, this.loader, this.ageBand});

  /// Testte enjekte edilebilir: `rootBundle` widget testinde kilitlenebiliyor
  /// (aile gotcha'sı), o yüzden yükleyici ÇAĞIRANA ait.
  final Future<AppFacts> Function()? loader;

  /// Onboarding'de beyan edilen yaş bandı (`u40` · `40-59` · `60plus`) —
  /// kabuk bunu YORUMLAMAZ, yalnız TAŞIR (G-100: kabuk yalnız kablolama).
  /// `null` → beyan yok; motor en muhafazakâr bandı kullanır.
  final String? ageBand;

  @override
  State<LissomShell> createState() => _LissomShellState();
}

class _LissomShellState extends State<LissomShell> {
  late final Future<AppFacts> _facts = (widget.loader ?? AppFacts.load)();
  int _index = 0;

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
                    label: _label(id),
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
            ageBand: widget.ageBand,
            onOpenLibrary: () => setState(
                () => _index = facts.ia.tabs.indexOf('library')),
          ),
        'library' => LibraryScreen(facts: facts),
        'progress' => ProgressScreen(facts: facts),
        'profile' => ProfileScreen(facts: facts),
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

  static String _label(String id) =>
      id.isEmpty ? id : '${id[0].toUpperCase()}${id.substring(1)}';
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
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: LissomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Lissom couldn't start",
                      style: t.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'The files that describe the tests and the app layout '
                    'could not be read.',
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
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: LissomCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('The app layout and the app do not agree',
                      style: t.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Layout file declares: ${declared.join(" · ")}',
                      style: t.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('This build implements: ${kImplementedTabs.join(" · ")}',
                      style: t.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Showing only the tabs we recognise would hide the '
                    'difference, so we are showing you the difference.',
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
