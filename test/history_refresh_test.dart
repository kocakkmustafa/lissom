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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/app_facts.dart';
import 'package:lissom/app/hatha_course_screen.dart';
import 'package:lissom/app/hatha_progress.dart';
import 'package:lissom/app/home_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/local_account_bridge.dart';
import 'package:lissom/app/local_owner.dart';
import 'package:lissom/app/progress_screen.dart';
import 'package:lissom/app/session_history_view.dart';
import 'package:lissom/app/shell.dart';
import 'package:lissom/app/study_review.dart';
import 'package:motion_core/motion_core.dart';

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

// These helpers bound animation/IO waits. Real filesystem work is started by
// runAsync at mount/tap time; a settled animation alone does not prove a save.
Future<void> _refreshFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 20),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 3),
  );
}

Future<void> _refreshUntil(
  WidgetTester tester,
  bool Function() ready,
  String stage,
) async {
  for (int attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump(const Duration(milliseconds: 25));
    if (ready()) return;
  }
  fail('Timed out waiting for $stage');
}

Future<void> _refreshVisible(WidgetTester tester, Finder target) async {
  // A popped lesson can disappear before its course's reverse transition has
  // finished. Only inspect the active route after those frames are complete.
  await _refreshFrames(tester);
  if (target.evaluate().isEmpty) {
    final Finder scrollable = find.byType(Scrollable).hitTestable().last;
    expect(
      scrollable,
      findsOneWidget,
      reason: 'An active scroll route is needed',
    );
    final ScrollableState state = tester.state<ScrollableState>(scrollable);
    // The progress card precedes Continue. On return it can be lazily unbuilt
    // above the saved scroll offset, so a down-only search would never find it.
    for (
      int attempt = 0;
      attempt < 60 && state.position.pixels > state.position.minScrollExtent;
      attempt++
    ) {
      await tester.drag(scrollable, const Offset(0, 500));
      await _refreshFrames(tester);
    }
    expect(
      state.position.pixels,
      lessThanOrEqualTo(state.position.minScrollExtent),
      reason: 'The actual route must scroll back to its start before searching',
    );
    await tester.scrollUntilVisible(
      target,
      300,
      maxScrolls: 60,
      scrollable: scrollable,
    );
  }
  await tester.ensureVisible(target);
  await _refreshFrames(tester);
  expect(target.hitTestable(), findsOneWidget);
}

Future<void> _refreshTap(WidgetTester tester, Finder target) async {
  await _refreshVisible(tester, target);
  await tester.runAsync(() async {
    await tester.tap(target.hitTestable());
  });
  await _refreshFrames(tester);
}

Future<void> _refreshTab(WidgetTester tester, String label) => _refreshTap(
  tester,
  find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
);

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

  for (final String language in <String>['en', 'tr']) {
    testWidgets(
      '$language recall course save refreshes actual JSONL progress on return',
      (WidgetTester tester) async {
        pinNarrowSurface(tester);
        final AppFacts base = factsFromDisk();
        final course = base.hatha!;
        final Directory support = (await tester.runAsync(
          () => Directory.systemTemp.createTemp('lissom-recall-refresh-'),
        ))!;
        final LissomLocalOwner owner = LissomLocalOwner(
          userId: null,
          epoch: 1,
          supportDirectory: support,
        );
        final LissomLocalScope scope = LissomLocalScope.guestWithOwner(owner);
        int loads = 0;
        Future<AppFacts> loader() async {
          loads++;
          final HathaProgress progress = await (await openHathaProgressStore(
            scope: scope,
          )).read();
          return AppFacts(
            ia: base.ia,
            battery: base.battery,
            liveness: base.liveness,
            history: base.history,
            hatha: course,
            hathaProgress: progress,
          );
        }

        final String emptyText = language == 'tr'
            ? '0/60 ders çalışıldı · öz kayıt'
            : '0/60 lessons practised · self-recorded';
        final String savedText = language == 'tr'
            ? '1/60 ders çalışıldı · öz kayıt'
            : '1/60 lessons practised · self-recorded';
        final String courseSavedText = language == 'tr'
            ? '60 dersten 1 tanesi çalışıldı'
            : '1 of 60 lessons practised';
        final String library = language == 'tr' ? 'Kütüphane' : 'Library';
        final String progress = language == 'tr' ? 'İlerleme' : 'Progress';

        try {
          expect(course.lessons.first.id, 'h01');
          expect(course.lessons, hasLength(60));
          // The owner supplies the temporary support directory. The shell and
          // course therefore use real JSONL IO without path_provider/user data.
          await tester.runAsync(() async {
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(language),
                supportedLocales: const <Locale>[Locale('en'), Locale('tr')],
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                theme: buildLissomTheme(),
                home: LissomShell(
                  loader: loader,
                  localScope: scope,
                  measurementAvailable: false,
                ),
              ),
            );
          });
          await _refreshUntil(
            tester,
            () => find.byType(NavigationBar).evaluate().isNotEmpty,
            'initial shell read',
          );
          expect(loads, 1);
          await _refreshTab(tester, progress);
          await _refreshVisible(tester, find.text(emptyText));
          await _refreshTab(tester, library);
          expect(
            loads,
            1,
            reason: 'Tab changes must not mask a missing callback',
          );

          await _refreshTap(
            tester,
            find.byKey(const Key('study-review-entry')),
          );
          final Finder entry = find.byKey(const Key('study-course-hatha'));
          await _refreshTap(
            tester,
            find.descendant(of: entry, matching: find.byType(FilledButton)),
          );
          await _refreshUntil(
            tester,
            () => find.byType(HathaCourseScreen).evaluate().isNotEmpty,
            'actual Hatha course',
          );
          await _refreshTap(tester, find.byKey(HathaCourseScreen.continueKey));
          await _refreshUntil(
            tester,
            () => find.byType(HathaLessonScreen).evaluate().isNotEmpty,
            'actual h01 lesson',
          );
          expect(
            tester
                .widget<HathaLessonScreen>(find.byType(HathaLessonScreen))
                .lesson
                .id,
            'h01',
          );
          await _refreshTap(
            tester,
            find.byKey(HathaLessonScreen.reflectionKey),
          );
          await _refreshTap(tester, find.byKey(HathaLessonScreen.practiceKey));
          await _refreshUntil(
            tester,
            () => find.byType(HathaLessonScreen).evaluate().isEmpty,
            'completed save returning to the course',
          );
          await _refreshVisible(
            tester,
            find.byKey(HathaCourseScreen.progressKey),
          );
          await _refreshUntil(
            tester,
            () =>
                find.text(courseSavedText).hitTestable().evaluate().isNotEmpty,
            'refreshed visible course count',
          );

          final HathaProgress disk = (await tester.runAsync(
            () async => (await openHathaProgressStore(scope: scope)).read(),
          ))!;
          expect(disk.records, hasLength(1));
          expect(disk.unreadableRecords, 0);
          expect(disk.records.single.lessonId, 'h01');
          expect(disk.records.single.courseId, course.id);
          expect(disk.records.single.courseVersion, course.version);
          expect(disk.practicedIn(course), <String>{'h01'});
          expect(
            loads,
            1,
            reason: 'A child course must not refresh the shell yet',
          );

          await _refreshTap(tester, find.byType(BackButton));
          expect(find.byType(StudyReviewPage), findsOneWidget);
          expect(
            loads,
            1,
            reason: 'Only the whole recall return refreshes facts',
          );
          await _refreshTap(tester, find.byType(BackButton));
          await _refreshUntil(
            tester,
            () =>
                loads == 2 && find.byType(NavigationBar).evaluate().isNotEmpty,
            'single recall-return reload',
          );
          await _refreshTab(tester, progress);
          await _refreshUntil(
            tester,
            () =>
                find.byType(ProgressScreen).evaluate().isNotEmpty &&
                tester
                        .widget<ProgressScreen>(find.byType(ProgressScreen))
                        .facts
                        .hathaProgress!
                        .practicedIn(course)
                        .length ==
                    1,
            'fresh Progress facts from the persisted record',
          );
          await _refreshVisible(tester, find.text(savedText));
          expect(find.text(emptyText), findsNothing);
          expect(loads, 2);
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.runAsync(() async {
            await owner.retireAndDrain();
            await support.delete(recursive: true);
          });
        }
      },
    );
  }

  testWidgets('one recall route and callback for rapid repeated entry taps', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    int returns = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StudyReviewEntry(onCourseDone: () => returns++)),
      ),
    );
    final Finder entry = find.byKey(const Key('study-review-entry'));
    await _refreshVisible(tester, entry);
    final Offset entryPoint = tester.getCenter(entry.hitTestable());
    // Repeat the real pointer location. After the first push the old button is
    // covered, so re-finding and tapping that widget would be a missed tap.
    await tester.tapAt(entryPoint);
    await tester.tapAt(entryPoint);
    await _refreshFrames(tester);
    expect(find.byType(StudyReviewPage, skipOffstage: false), findsOneWidget);
    expect(returns, 0);
    await _refreshTap(tester, find.byType(BackButton));
    expect(find.byType(StudyReviewPage, skipOffstage: false), findsNothing);
    expect(returns, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposed recall entry does not call a late return callback', (
    WidgetTester tester,
  ) async {
    pinNarrowSurface(tester);
    final ValueNotifier<bool> showEntry = ValueNotifier<bool>(true);
    addTearDown(showEntry.dispose);
    int returns = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: showEntry,
          builder: (BuildContext context, bool visible, Widget? child) =>
              Scaffold(
                body: visible
                    ? StudyReviewEntry(onCourseDone: () => returns++)
                    : const Text('Entry removed'),
              ),
        ),
      ),
    );
    await _refreshTap(tester, find.byKey(const Key('study-review-entry')));
    showEntry.value = false;
    await tester.pump();
    await _refreshTap(tester, find.byType(BackButton));
    expect(find.text('Entry removed'), findsOneWidget);
    expect(returns, 0);
    expect(tester.takeException(), isNull);
  });
}
