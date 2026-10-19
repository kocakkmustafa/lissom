import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/library_screen.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/profile_screen.dart';
import 'package:lissom/app/surfaces.dart';
import 'package:lissom/app/what_lissom_doesnt_do.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'support/facts_from_disk.dart';
import 'support/narrow_surface.dart';

const _plannedFamilyIds = <String>[
  'flexibility_goals',
  'population_packs',
  'family_warmups',
  'breath_meditation',
];

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  String language,
) async {
  // This tall host surface materialises copy; it is not device/a11y acceptance.
  pinTallSurface(tester, height: 6000);
  expect(
    motionPaidFeaturesAvailable,
    isFalse,
    reason: 'These claims describe the current closed release policy.',
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildLissomTheme(),
      home: Scaffold(body: screen),
    ),
  );
  await tester.pumpAndSettle();
}

String _copy(WidgetTester tester, Finder root) => tester
    .widgetList<Text>(
      find.descendant(of: root, matching: find.byType(Text)),
    )
    .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
    .join('\n');

void _expectNoFutureSuffix(String copy) {
  expect(RegExp(r'\byet\b|henüz', caseSensitive: false).hasMatch(copy), isFalse);
}

List<String> _plannedCopy(String familyId, bool turkish) => switch (familyId) {
  'flexibility_goals' => turkish
      ? <String>[
          'Esneklik hedefleri için yollar planda listelenir. Bu sürümde program, eğilim grafiği veya zamanlanmış yeniden ölçüm bulunmaz.',
          'Bu sürümde hedef ölçümleri veya zamanlanmış yeniden testler bulunmaz.',
          'Ölçüm gürültüsü eşiği veya ilerleme değişikliği değerlendirmesi sunulmaz.',
        ]
      : <String>[
          'Flexibility goal paths are listed in the plan. No programme, trend chart or scheduled re-measurement is included in this release.',
          'No goal measurements or scheduled re-tests are available in this build.',
          'No measurement-noise threshold or progress-change judgement is available.',
        ],
  'population_packs' => turkish
      ? <String>[
          'Günlük hareket programları planda listelenir. Bu sürümde programlar veya test ağırlıkları günlük rutinine uyarlanmaz.',
          'Bu sürümde rutinine göre ağırlıklandırılmış hareket testi veya kişiselleştirilmiş program bulunmaz.',
        ]
      : <String>[
          'Day-to-day movement programmes are listed in the plan. This release does not adapt programmes or weight tests to your routine.',
          'No routine-weighted movement tests or personalised programmes are available in this build.',
        ],
  'family_warmups' => turkish
      ? <String>[
          'Diğer sporlar için hazırlıklar planda listelenir. Bu sürümde hazırlık içeriği veya başka uygulamaya aktarım bulunmaz.',
          'Bu sürümde diğer uygulamalara yönelik hareketlilik kontrolü veya uygulamaya aktarım bulunmaz.',
        ]
      : <String>[
          'Warm-ups for other sports are listed in the plan. No warm-up content or handoff to another app is included in this release.',
          'No partner-app mobility checks or app handoffs are available in this build.',
        ],
  'breath_meditation' => turkish
      ? <String>[
          'Bu sürümde nefes veya sakinleşme oturumu, sesli rehberlik veya oturum zamanlayıcısı bulunmaz.',
          'Bu sürümde sesli rehberli veya zamanlayıcılı oturum bulunmaz. Kamera kapalıdır.',
        ]
      : <String>[
          'No breath or wind-down sessions, audio guidance or session timer are included in this release.',
          'No audio-guided or timed sessions are available in this build. The camera is off.',
        ],
  _ => throw ArgumentError.value(familyId, 'familyId'),
};

const _legacyFamilyClaims = <String>[
  'The joint angle the goal is defined by, re-measured on a fixed cadence',
  'Hedefin tanımlandığı eklem açısı, belirli aralıklarla yeniden ölçülür.',
  "Changes smaller than our measurement noise: below that threshold we say 'no change', not 'improved'",
  'Ölçüm gürültüsünden küçük farklar gelişme olarak yorumlanmaz.',
  'The same movement tests, weighted toward the areas your routine loads most',
  'Aynı hareket testleri, günlük rutininin en çok kullandığı bölgelere odaklanır.',
  "The mobility prerequisites the partner app's skills depend on",
  'Diğer uygulamadaki becerilerin gerektirdiği hareketlilik temeli',
  'These sessions are guided by audio and timed',
];

void main() {
  for (final language in <String>['en', 'tr']) {
    final turkish = language == 'tr';

    testWidgets('Profile describes self-report storage accurately ($language)', (
      tester,
    ) async {
      await _pump(tester, ProfileScreen(facts: factsFromDisk()), language);
      final storage = find.textContaining(
        turkish
            ? 'Öz denetim yanıtları kaydedilmez.'
            : 'Self-check answers are not saved.',
      );
      await scrollTo(tester, storage);
      expect(storage, findsOneWidget);
      final copy = _copy(tester, find.byType(ProfileScreen));
      for (final sentence in turkish
          ? <String>[
              'Bu sürümde canlı kamera ölçümleri ve abonelik satışı kapalıdır.',
              'Yazılı yoga kursları kamera olmadan çalışır.',
              'Çalışma kayıtları bu cihazda kalır ve kendi beyanını gösterir.',
              'Bu kayıtlar Motion hesabına eşitlenmez.',
              'Öz denetim yanıtları kaydedilmez.',
              'Yazılı hatırlama notları sayfadan çıkınca silinir.',
            ]
          : <String>[
              'Live camera measurements and subscription sales are closed in this release.',
              'Written yoga courses work without a camera.',
              'Practice records stay on this device and reflect your own reports.',
              'These records are not synced to your Motion account.',
              'Self-check answers are not saved.',
              'Written recall notes are discarded when you leave the page.',
            ]) {
        expect(copy, contains(sentence));
      }
      expect(copy, isNot(contains('Course progress and self-checks stay')));
      expect(copy, isNot(contains('Kurs ilerlemesi ve öz denetimler yerel')));
      _expectNoFutureSuffix(copy);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Profile boundaries describe planned pose scope ($language)', (
      tester,
    ) async {
      final facts = factsFromDisk();
      expect(facts.ia.poseTiers, hasLength(3));
      await _pump(tester, ProfileScreen(facts: facts), language);
      await tester.tap(find.byKey(ProfileScreen.whyNotEntryKey));
      await tester.pumpAndSettle();
      expect(find.byType(WhatLissomDoesntDoScreen), findsOneWidget);

      final heading = find.text(
        (turkish
                ? 'Planlanan poz gözlemi kategorileri'
                : 'Planned pose observation categories')
            .toUpperCase(),
      );
      await scrollTo(tester, heading);
      expect(heading, findsOneWidget);
      final intro = turkish
          ? 'Bu kategoriler planlanan kapsamı ve kamera sınırlarını açıklar. Bu sürümde kamerayla poz koçluğu, poz puanı veya avatar gösterimi sunulmaz.'
          : 'These categories describe planned scope and camera limits. This release provides no camera pose coaching, pose scores or avatar demonstrations.';
      expect(find.text(intro), findsOneWidget);

      final tiers = find.byKey(WhatLissomDoesntDoScreen.tiersKey);
      await scrollTo(tester, tiers);
      expect(tiers, findsOneWidget);
      final tierCopy = _copy(tester, tiers);
      for (final sentence in turkish
          ? <String>[
              'Ayakta, oturarak ve diz çökerek yapılan duruşlar',
              'Duruş bazında koçluk ve referans puanlaması sunulmaz.',
              'Kamerayla rehberlik ve puanlama sunulmaz.',
              'Avatar gösterimi ve puanlama sunulmaz.',
              'Yerde uzanırken vücut, yan kameradan birçok eklem noktasını örter.',
              'Poz modelleri ters duruşlarda uzuv adlarını yüksek güvenle yanlış eşleyebilir',
            ]
          : <String>[
              'Standing, seated and kneeling poses',
              'Pose-by-pose coaching and reference scoring are not available.',
              'Guided camera coaching and scoring are not available.',
              'Avatar demonstrations and scoring are not available.',
              'Self-occlusion: lying on the floor hides most landmarks from a side camera',
              'Pose models silently swap limb labels on inverted bodies with high confidence',
            ]) {
        expect(tierCopy, contains(sentence));
      }
      for (final legacy in <String>[
        'Coached pose by pose, and set against a reference range.',
        'Guided, but scored loosely',
        'Shown by the avatar only.',
        'Duruş bazında rehberlik ve referans aralığıyla değerlendirme.',
        'Rehberlik sunulur; kamera daha az gördüğü için değerlendirme sınırlıdır.',
        'Yalnızca avatar gösterir; puanlama yapılmaz.',
        '150-250',
        '150–250',
      ]) {
        expect(tierCopy, isNot(contains(legacy)));
      }
      _expectNoFutureSuffix(tierCopy);
      expect(tester.takeException(), isNull);
    });

    for (final familyId in _plannedFamilyIds) {
      testWidgets('$familyId remains unavailable in the plan ($language)', (
        tester,
      ) async {
        final facts = factsFromDisk();
        expect(
          facts.ia.notBuilt.map((family) => family.id),
          unorderedEquals(_plannedFamilyIds),
        );
        final family = facts.ia.notBuilt.singleWhere(
          (family) => family.id == familyId,
        );
        expect(family.honestyBox.measured, isNotEmpty);
        await _pump(
          tester,
          FamilyPage(family: family, facts: facts),
          language,
        );

        final openingCopy = _copy(tester, find.byType(FamilyPage));
        final honesty = find.byKey(FamilyPage.honestyKey);
        await scrollTo(tester, honesty);
        expect(honesty, findsOneWidget);
        final copy = '$openingCopy\n${_copy(tester, find.byType(FamilyPage))}';
        for (final sentence in _plannedCopy(familyId, turkish)) {
          expect(copy, contains(sentence));
        }
        expect(
          copy,
          contains(
            turkish
                ? 'Bu sürümde canlı kamera ölçümleri kapalıdır.'
                : 'Live camera measurements are closed in this release.',
          ),
        );
        expect(
          find.descendant(
            of: honesty,
            matching: find.text(
              (turkish
                      ? 'Bu sürümde bulunmuyor'
                      : 'Not available in this build')
                  .toUpperCase(),
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: honesty,
            matching: find.text(
              (turkish
                      ? 'Ölçüm motorunun kapsamı'
                      : 'Measurement engine coverage')
                  .toUpperCase(),
            ),
          ),
          findsNothing,
        );

        final measured = find.descendant(
          of: honesty,
          matching: find.byKey(HonestyBoxCard.measuredKey),
        );
        expect(measured, findsOneWidget);
        expect(
          find.descendant(
            of: measured,
            matching: find.byIcon(Icons.videocam_outlined),
          ),
          findsNothing,
        );
        final closedIcons = find.descendant(
          of: measured,
          matching: find.byIcon(Icons.videocam_off_outlined),
        );
        expect(closedIcons, findsNWidgets(family.honestyBox.measured.length));
        for (final icon in tester.widgetList<Icon>(closedIcons)) {
          expect(icon.color, LissomColors.bodySecondary);
        }
        expect(find.byKey(FamilyPage.liveListKey), findsNothing);
        expect(find.byKey(FamilyPage.blockedListKey), findsNothing);
        expect(
          find.byKey(FamilyPage.namedChildrenKey),
          family.children.isEmpty ? findsNothing : findsOneWidget,
        );
        for (final legacy in _legacyFamilyClaims) {
          expect(copy, isNot(contains(legacy)));
        }
        _expectNoFutureSuffix(copy);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
