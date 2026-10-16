import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lissom/main.dart' as production;
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/shell.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('production main guest boot reaches usable lissom screen', (tester) async {
    await production.main();
    // The shell exists while its bundled facts are still loading. Wait for
    // actual interactive content, keeping the no-spinner assertion below.
    bool ready() => find.byType(CircularProgressIndicator).evaluate().isEmpty &&
        (find.byType(OnboardingFlow).evaluate().isNotEmpty ||
            (find.byType(LissomShell).evaluate().isNotEmpty &&
                find.byType(HomeScreen).evaluate().isNotEmpty));
    for (var i = 0; i < 600 && !ready(); i++) {
      await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(production.LissomApp), findsOneWidget);
    expect(ready(), isTrue,
        reason: 'Production main must reach interactive onboarding or content');
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    debugPrint('MOTION_MAIN_BOOT_READY_lissom');
    await Future<void>.delayed(const Duration(seconds: 3));
  });
}
