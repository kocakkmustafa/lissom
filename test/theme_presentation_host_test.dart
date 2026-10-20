// DRAFT ONLY / UNRUN. Verifies the real app-side bridge's child lifetime.
// Actual Core gate/owner epoch acceptance still requires the consumer checkpoint.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_appearance.dart';
import 'package:lissom/app/lissom_locales.dart';
import 'package:lissom/app/lissom_presentation_host.dart';

import 'lissom_appearance_test.dart' show MemoryAppearanceStore;

final class _MemoryLocale implements LocalePreferenceStore {
  String? value = 'tr';
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String? tag) async { value = tag; }
}

class _EpochProbe extends StatefulWidget {
  const _EpochProbe({super.key});
  @override
  State<_EpochProbe> createState() => _EpochProbeState();
}
class _EpochProbeState extends State<_EpochProbe> {
  Locale? locale;
  Brightness? brightness;
  final Object lifetimeToken = Object();
  @override
  Widget build(BuildContext context) {
    locale = Localizations.localeOf(context);
    brightness = Theme.of(context).brightness;
    return const SizedBox();
  }
}

Future<void> _waitForProbe(WidgetTester tester, Key key, String language) async {
  final ready = await tester.runAsync(() async {
    final elapsed = Stopwatch()..start();
    while (elapsed.elapsed < const Duration(seconds: 10)) {
      await tester.pump();
      final probe = find.byKey(key);
      if (probe.evaluate().length == 1 &&
          tester.state<_EpochProbeState>(probe).locale?.languageCode == language) {
        return true;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    return false;
  });
  expect(ready, isTrue,
    reason: 'Global delegates must finish postmount locale resolution.');
}

void main() {
  testWidgets('manual locale/theme and system changes preserve the bridge child lifetime', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en')];
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final locale = LissomLocaleController(store: _MemoryLocale());
    final appearance = LissomAppearanceController(store: MemoryAppearanceStore()..value = ThemeMode.dark);
    addTearDown(locale.dispose);
    addTearDown(appearance.dispose);
    await locale.initialize();
    await appearance.initialize();
    const probeKey = Key('bridge.epoch.probe');
    await tester.pumpWidget(LissomAppearanceHost(controller: appearance,
      child: LissomLocaleHost(controller: locale,
        child: const LissomPresentationHost(child: _EpochProbe(key: probeKey)))));
    await _waitForProbe(tester, probeKey, 'tr');
    final before = tester.state<_EpochProbeState>(find.byKey(probeKey));
    final token = before.lifetimeToken;
    expect(before.locale!.languageCode, 'tr');
    expect(before.brightness, Brightness.dark);
    expect(await locale.select('ja'), isTrue);
    await _waitForProbe(tester, probeKey, 'ja');
    final after = tester.state<_EpochProbeState>(find.byKey(probeKey));
    expect(identical(before, after), isTrue);
    expect(identical(token, after.lifetimeToken), isTrue);
    expect(after.locale!.languageCode, 'ja');
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    await _waitForProbe(tester, probeKey, 'ja');
    expect(after.locale!.languageCode, 'ja', reason: 'Manual locale overrides OS locale.');
    expect(await locale.select(null), isTrue);
    expect(await appearance.select(ThemeMode.system), isTrue);
    await _waitForProbe(tester, probeKey, 'fr');
    expect(after.locale!.languageCode, 'fr');
    expect(after.brightness, Brightness.light);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await _waitForProbe(tester, probeKey, 'fr');
    expect(after.brightness, Brightness.dark);
    expect(identical(before, tester.state(find.byKey(probeKey))), isTrue);
  });
}
