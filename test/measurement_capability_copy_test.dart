import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/locale_text.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

String _status(String language, bool available) => language == 'tr'
    ? available
          ? 'Desteklenen testlerde Ana Sayfa’dan canlı kamera ölçümü başlatabilirsin.'
          : 'Bu sürümde canlı kamera ölçümleri kapalıdır.'
    : available
    ? 'You can start a live camera measurement from Home for supported tests.'
    : 'Live camera measurements are closed in this release.';

Future<void> _expectContext(
  WidgetTester tester,
  String language,
  bool available, {
  bool footnote = false,
}) async {
  final note = find.descendant(
    of: find.byKey(CaptureUnavailableNote.key_),
    matching: find.byType(Text),
  );
  expect(note, findsOneWidget);
  expect(
    tester.widget<Text>(note).data!,
    contains(_status(language, available)),
  );
  expect(
    tester.widget<Text>(note).data!,
    contains(
      language == 'tr'
          ? 'kalibrasyon doğrulanmadı'
          : DevicePassClaim.stillNeeds,
    ),
  );
  final messagesBeforeScroll = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .join('\n');
  if (footnote) {
    final caption = find.descendant(
      of: find.byKey(MeasurementLimitsFootnote.key_),
      matching: find.textContaining(
        language == 'tr'
            ? 'kamera ölçümü alındığında'
            : 'when a camera reading is taken',
      ),
    );
    // Course inventories can put the footnote beyond the lazy viewport.
    await scrollTo(tester, caption);
    expect(caption, findsOneWidget);
    expect(
      tester.widget<Text>(caption).data!,
      contains(_status(language, available)),
    );
  }
  if (available) {
    final messagesAfterScroll = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .join('\n');
    final messages = '$messagesBeforeScroll\n$messagesAfterScroll';
    for (final closed in [
      'Live camera measurements are closed in this release',
      'Live camera measurements are closed in this release.',
      'camera closed in this release',
      'canlı kamera ölçümleri kapalıdır',
      'Bu sürümde canlı kamera ölçümleri kapalıdır.',
      'bu sürümde kamera kapalı',
    ]) {
      expect(messages, isNot(contains(closed)));
    }
  }
  expect(tester.takeException(), isNull);
}

void main() {
  for (final language in ['en', 'tr']) {
    for (final available in [false, true]) {
      for (final inventory in ['mixed', 'allLive', 'allBlocked']) {
        testWidgets(
          'shell camera copy follows capability=$available ($language/$inventory)',
          (tester) async {
            pinTallSurface(tester, height: 6000);
            expect(motionPaidFeaturesAvailable, isFalse);
            expect(DevicePassClaim.verified, isFalse);
            final original = factsFromDisk();
            final facts = AppFacts(
              ia: original.ia,
              battery: original.battery,
              liveness: switch (inventory) {
                'allLive' => original.live,
                'allBlocked' => original.blocked,
                _ => original.liveness,
              },
              history: original.history,
              hatha: original.hatha,
              chairOffice: original.chairOffice,
              vinyasa: original.vinyasa,
              yin: original.yin,
              hathaProgress: original.hathaProgress,
            );
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(language),
                supportedLocales: const [Locale('en'), Locale('tr')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                theme: buildLissomTheme(),
                home: LissomShell(
                  loader: () async => facts,
                  measurementAvailable: available,
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester
                  .widget<HomeScreen>(find.byType(HomeScreen))
                  .measurementAvailable,
              available,
            );
            expect(
              find.byKey(HomeScreen.startMeasurementKey),
              available && facts.live.isNotEmpty
                  ? findsOneWidget
                  : findsNothing,
            );
            Future<void> tab(String en, String tr) async {
              await tester.tap(
                find.descendant(
                  of: find.byType(NavigationBar),
                  matching: find.text(language == 'tr' ? tr : en),
                ),
              );
              await tester.pumpAndSettle();
            }

            await tab('Library', 'Kütüphane');
            await _expectContext(tester, language, available);
            final family = facts.ia.built.firstWhere(
              (family) => !family.teachingOnly,
            );
            final entry = find.text(
              configText(
                tester.element(find.byType(LibraryScreen)),
                family.title,
              ),
            );
            await tester.ensureVisible(entry);
            await tester.tap(entry);
            await tester.pumpAndSettle();
            expect(find.byType(FamilyPage), findsOneWidget);
            expect(
              find.byKey(FamilyPage.liveListKey),
              facts.live.isEmpty ? findsNothing : findsOneWidget,
            );
            expect(
              find.byKey(FamilyPage.blockedListKey),
              facts.blocked.isEmpty ? findsNothing : findsOneWidget,
            );
            await _expectContext(tester, language, available, footnote: true);
            expect(find.byType(BackButton), findsOneWidget);
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();
            final pending = facts.ia.notBuilt.first;
            final pendingEntry = find.text(
              configText(
                tester.element(find.byType(LibraryScreen)),
                pending.title,
              ),
            );
            await tester.ensureVisible(pendingEntry);
            await tester.tap(pendingEntry);
            await tester.pumpAndSettle();
            expect(find.byType(FamilyPage), findsOneWidget);
            await _expectContext(tester, language, available, footnote: true);
            expect(find.byType(BackButton), findsOneWidget);
            await tester.tap(find.byType(BackButton));
            await tester.pumpAndSettle();

            await tab('Progress', 'İlerleme');
            expect(find.byType(ProgressScreen), findsOneWidget);
            await _expectContext(tester, language, available, footnote: true);
            await tab('Profile', 'Profil');
            expect(find.byType(ProfileScreen), findsOneWidget);
            expect(
              find.textContaining(
                available
                    ? _status(language, available)
                    : language == 'tr'
                    ? 'Bu sürümde canlı kamera ölçümleri kapalıdır.'
                    : 'Live camera measurements are closed in this release.',
              ),
              findsOneWidget,
            );
            expect(
              find.textContaining(
                language == 'tr'
                    ? 'kalan dersler Lissom veya Motion+ aboneliğiyle açılır'
                    : 'a Lissom or Motion+ subscription unlocks the remaining lessons',
              ),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
