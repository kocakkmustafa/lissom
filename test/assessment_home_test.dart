/// Canlı-3 / engelli-9 yüzey kapısı (L-206 hükmü).
///
/// **Pozitif ikiz iki yönü de sınıyor** (koordinatör şartı): canlı-3 canlı
/// GÖRÜNÜR **ve** engelli-9 İSİMLİ görünür. Tek yön sınanırsa, hepsini
/// engelli gösteren (ya da hepsini canlı gösteren) bir yüzey de geçerdi.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/assessment_home.dart';
import 'package:lissom/app/summary_strings.dart';
import 'package:lissom_engine/lissom_engine.dart';

/// Config'i DOSYADAN okur — `rootBundle` widget testinde kilitlenebiliyor
/// (aile gotcha'sı), o yüzden yükleyici enjekte edilir.
Future<List<TestLiveness>> _fromDisk() async {
  final String raw =
      File('config/tests/lissom-assessment.v1.json').readAsStringSync();
  return deriveLiveness(Battery.parseJson(raw));
}

void main() {
  testWidgets('türetim: 3 canlı · 9 engelli — sayılar TÜRETİLİR', (
    WidgetTester tester,
  ) async {
    final List<TestLiveness> all = await _fromDisk();
    final List<TestLiveness> live =
        all.where((TestLiveness x) => x.isLive).toList();
    final List<TestLiveness> blocked =
        all.where((TestLiveness x) => !x.isLive).toList();

    // Pozitif kontrol: config GERÇEKTEN okundu mu? Boşsa aşağıdaki iki yön de
    // trivially geçerdi (L-183 vacuous-geçiş sınıfı).
    expect(all.length, 12, reason: 'batarya 12 test taşımalı, okunan: '
        '${all.length}');
    expect(live.map((TestLiveness x) => x.testId).toList()..sort(),
        <String>['active_straight_leg_raise', 'deep_squat', 'overhead_reach'],
        reason: 'canlı küme köprüden TÜRETİLİR; değiştiyse köprü değişmiş '
            'olmalı (kMetricBindings) — burayı elle güncellemek türetimi '
            'yalana çevirir');
    expect(blocked, hasLength(9));

    // Her engelin GEREKÇESİ var ve boş değil.
    for (final TestLiveness x in blocked) {
      expect(x.blocker, isNotNull);
      expect(x.blocker!.trim(), isNotEmpty,
          reason: '${x.testId} gerekçesiz engelli — L-135 ihlali');
    }
  });

  testWidgets('YÜZEY: canlı-3 canlı görünür VE engelli-9 isimli görünür', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
        home: AssessmentHomeScreen(livenessLoader: _fromDisk)));
    await tester.pumpAndSettle();

    // YÖN 1 — canlı testler yüzeyde (insan-okur ad, TestSpec.name'den TAŞINIR).
    expect(find.text('Overhead Reach'), findsOneWidget);
    expect(find.text('Deep Squat'), findsOneWidget);
    expect(find.text('Active Straight Leg Raise'), findsOneWidget);
    // Bölüm etiketleri `LissomEyebrow` ile basılır ve BÜYÜK HARFE çevrilir
    // (tasarımın eyebrow-etiket dili) — arama da büyük harfle olmalı.
    expect(find.textContaining('MEASURED BY CAMERA NOW (3)'), findsOneWidget);

    // YÖN 2 — engelli testler de yüzeyde, GEREKÇELİ.
    expect(find.textContaining('NOT MEASURABLE YET (9)'), findsOneWidget);
    // Kaydırmadan görünmeyenler için: bölüm başlığı ve sayı yeterli kanıt,
    // ama en az bir engel gerekçesinin metni de yüzeyde olmalı. Ortak alt-dize
    // her iki blocker varyantında da geçer (bkz. metric_bridge.dart._blockerText).
    expect(
        find.textContaining('in the measurement engine yet',
            skipOffstage: false),
        findsWidgets,
        reason: 'engel gerekçesi yüzeyde görünmüyorsa "isimli engel" iddiası '
            'boş kalır');
  });

  testWidgets('BEYAN yüzeyin TEPESİNDE (M-F-186 koşul 4)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
        home: AssessmentHomeScreen(livenessLoader: _fromDisk)));
    await tester.pumpAndSettle();
    expect(find.text(SummaryStrings.header), findsOneWidget);
    // Beyan, ilk test kartından ÖNCE gelmeli — aşağıda olsaydı kaydırmayan
    // kullanıcı hiç görmezdi.
    final double declY = tester.getTopLeft(find.text(SummaryStrings.header)).dy;
    final double firstTestY =
        tester.getTopLeft(find.text('Overhead Reach')).dy;
    expect(declY, lessThan(firstTestY));
  });

  testWidgets('VAAT DİLİ YOK — "yakında"/comingSoon yüzeyde geçmez', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
        home: AssessmentHomeScreen(livenessLoader: _fromDisk)));
    await tester.pumpAndSettle();
    // M-F-186: vaat, bilmediğimiz bir tarihi ima eder. Tek istisna, vaadi
    // AÇIKÇA REDDEDEN cümle ("Bunlar 'yakında' değil") — o yüzden yasak
    // kelimeyi değil, VAAT ANLAMINI arıyoruz: tırnaksız/olumlu kullanım.
    final Iterable<Text> texts =
        tester.widgetList<Text>(find.byType(Text, skipOffstage: false));
    for (final Text w in texts) {
      final String s = w.data ?? '';
      expect(s.toLowerCase(), isNot(contains('comingsoon')));
      expect(s.toLowerCase(), isNot(contains('coming soon')));
      if (s.toLowerCase().contains('yakında')) {
        expect(s, contains('“yakında” değil'),
            reason: 'yüzeyde vaat dili var: "$s"');
      }
    }
  });

  testWidgets('ÇIKMAZ-SOKAK YASAĞI: config patlasa da ekran AÇILIR ve söyler', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(
      home: AssessmentHomeScreen(
        livenessLoader: () async => throw const FormatException('bozuk config'),
      ),
    ));
    await tester.pumpAndSettle();
    // Sessiz boş ekran YASAK: hem beyan hem hata görünür.
    expect(find.text(SummaryStrings.header), findsOneWidget);
    expect(find.text("We couldn't read the test list"), findsOneWidget);
    expect(find.textContaining('bozuk config'), findsOneWidget,
        reason: 'sebep YUTULMAZ — kullanıcı neyin patladığını görür');
  });

  test('config asset olarak KAYITLI (yoksa canlı cihazda okunamaz)', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    // Flutter asset kaydı DİZİN olarak da yapılabilir (`- config/tests/`) ve o
    // hâlde dizindeki her dosya paketlenir. İlk yazımımda yalnız tam dosya
    // yolunu arıyordum ve kapı KIRMIZI yandı — oysa kayıt vardı, iddiam fazla
    // katıydı. Kusur üretimde değil testte olduğu için iddia düzeltildi:
    // aranan şey "bu config paketleniyor mu", "hangi sözdizimiyle" değil.
    expect(
        pubspec.contains('config/tests/lissom-assessment.v1.json') ||
            pubspec.contains('- config/tests/'),
        isTrue,
        reason: 'asset kaydı olmadan `rootBundle` cihazda FIRLATIR — test '
            'dosyadan okuduğu için bunu yakalamaz, o yüzden ayrı iddia');
    // Dosya gerçekten var mı (kayıt ≠ varlık).
    expect(File('config/tests/lissom-assessment.v1.json').existsSync(), isTrue);
    expect(
        jsonDecode(File('config/tests/lissom-assessment.v1.json')
            .readAsStringSync()),
        isA<Map<String, dynamic>>());
  });
}
