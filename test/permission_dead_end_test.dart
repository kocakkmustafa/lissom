/// **ÇIKMAZ SOKAK KAPISI — kalıcı izin reddi (L-283).**
///
/// Koordinatör aile taraması Lissom'u *aday* işaretledi: `permanentlyDenied`
/// işleniyor ama OS ayarlarını açan çağrı **0**. Ölçtüm — **VARDI, iki
/// yerde**, ve ikisi de aynı sınıf:
///
/// > ***Kullanıcıya bir TALİMAT verilip ("Open Settings"), onu uygulayacak
/// > YOL verilmiyordu.***
///
///  1. **Canlı ölçüm ekranı** — kalıcı rette metin *"Open Settings to turn
///     camera access on for Lissom"* diyordu, hiçbir kontrol yoktu, ve
///     `canMeasure` false olduğu için ekranda BAŞKA düğme de kalmıyordu.
///  2. **Onboarding O3** — metin *"You can turn it on later in Settings"*
///     diyordu; kalan tek kontrol (*"Check again"*), kullanıcı ayarları
///     açıp izni değiştirene kadar hiçbir gözle görülür şey yapmıyordu —
///     **ve uygulama ona ayarları açmanın bir yolunu vermiyordu.** Yani
///     düğme, kullanıcının fiilen izleyebildiği yol boyunca ATIL kalıyordu.
///
/// ⚠️ **"Ölü düğme" demedim, tam hâlini yazdım:** *"Check again"* kullanıcı
/// ayarlardan DÖNDÜKTEN sonra gerçekten çalışır (`request()` güncel durumu
/// okur). Kusur düğmenin kendisi değil, **oraya gitmenin yolunun
/// olmaması.** Fazla iddia, eksik iddia kadar pahalıdır.
///
/// ## İCAT EDİLMEDİ, ADAPTE EDİLDİ — ama JabLab'dan DEĞİL
///
/// Sevk *"JabLab çözmüş (`openAppSettings` 4), adapte et"* diyordu.
/// **Ölçüm bunu yalanladı:** JabLab'da `openAppSettings` **0**, ve
/// `_openSettings`i uygulamanın **KENDİ** `SettingsPage`ine gidiyor — OS
/// ayarlarını açan hiçbir çağrı yok (`openAppSettings`/`AppSettings.`/
/// `url_launcher`/`launchUrl` hepsi 0). JabLab'ın kalıcı-ret dalı da yalnız
/// bir CÜMLE üretiyor. **Aile taramasında OS-ayar-açma taşıyan tek hat
/// Ostinato** (`live_screen.dart`), ve desen ondan alındı: *dürüst hâl
/// ekranı bir EYLEM taşır* (etiket + geri çağırım).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/live_capture_screen.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';
import 'package:lissom_engine/lissom_engine.dart';

import 'support/narrow_surface.dart';

/// `permission_handler`ın gerçek kanalı — ADI ve dönüş ŞEKLİ paketin
/// kaynağından DOĞRULANDI (`method_channel_permission_handler.dart`),
/// hafızadan yazılmadı.
const MethodChannel _permChannel =
    MethodChannel('flutter.baseflow.com/permissions/methods');

/// `PermissionStatus` sıra numaraları paketin enum'undan ÖLÇÜLDÜ:
/// denied 0 · granted 1 · restricted 2 · limited 3 · **permanentlyDenied 4**
/// · provisional 5. (İlk sayımım camelCase'i süzen bir regex yüzünden
/// `permanentlyDenied`i ATLAMIŞTI — araç kusuru, düzeltildi.)
const int _kPermanentlyDenied = 4;
const int _kGranted = 1;

void _stubPermissions(WidgetTester tester, {required int status}) {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _permChannel,
    (MethodCall call) async => switch (call.method) {
      'requestPermissions' => <int, int>{
          for (final Object? p in (call.arguments as List<Object?>))
            (p! as int): status,
        },
      'checkPermissionStatus' => status,
      'shouldShowRequestPermissionRationale' => false,
      _ => null,
    },
  );
  addTearDown(() => tester.binding.defaultBinaryMessenger
      .setMockMethodCallHandler(_permChannel, null));
}

TestSpec _spec() => Battery.parseJson('''
{
  "id": "t", "version": "1",
  "tests": [{
    "id": "overhead_reach", "perSide": true, "holdSeconds": 2,
    "primaryMetric": "shoulder_flexion_{side}",
    "scoring": {
      "type": "banded", "unit": "deg", "higherIsBetter": true,
      "bands": {"u40": {"low": 100}},
      "source": "TEST — kablolama sınaması, bant iddiası değil."
    }
  }]
}
''').tests['overhead_reach']!;

Future<void> _pumpLive(
  WidgetTester tester, {
  required PermissionDenialKind kind,
  required List<String> opened,
}) async {
  await tester.pumpWidget(MaterialApp(
    theme: buildLissomTheme(),
    home: LiveCaptureScreen(
      test: _spec(),
      batteryVersion: 'test',
      onOpenSettings: () async {
        opened.add('yes');
        return true;
      },
      sourceOverride: FakePoseSource(<PoseSourceEvent>[
        SourceStateEvent(PermissionDenied(
          kind: kind,
          userText: 'Camera access is off.',
        )),
      ]),
    ),
  ));
  await tester.pump();
  await tester.pump();
}

void main() {
  group('Canlı ölçüm ekranı', () {
    testWidgets('KALICI ret → "Open Settings" VAR ve GERÇEKTEN çağırıyor',
        (WidgetTester tester) async {
      pinNarrowSurface(tester);
      final List<String> opened = <String>[];
      await _pumpLive(
          tester, kind: PermissionDenialKind.permanent, opened: opened);

      // POZİTİF ÇAPA: gerçekten kalıcı-ret hâlindeyiz, boş ekranı
      // ölçmüyoruz.
      expect(find.textContaining('Open Settings to turn camera access on'),
          findsOneWidget,
          reason: 'kalıcı ret metni görünmüyorsa bu test o dalı ölçmüyor');

      final Finder btn = find.byKey(const Key('liveCapture.openSettings'));
      expect(btn, findsOneWidget,
          reason: 'metin "Open Settings" diyor ama oraya GİDEN kontrol yok — '
              'talimat verilip yol verilmemesi ÇIKMAZ SOKAKTIR');

      await tester.tap(btn);
      await tester.pump();
      expect(opened, <String>['yes'],
          reason: 'düğme VAR ama bir şey YAPMIYORSA ölü düğmedir — '
              'varlığı değil ETKİSİ ölçülür');
    });

    testWidgets('GEÇİCİ ret → düğme YOK (gereksiz yolculuğa gönderme)',
        (WidgetTester tester) async {
      pinNarrowSurface(tester);
      final List<String> opened = <String>[];
      await _pumpLive(
          tester, kind: PermissionDenialKind.transient, opened: opened);

      expect(find.textContaining('You can try again'), findsOneWidget,
          reason: 'POZİTİF ÇAPA — geçici ret dalında olduğumuzu doğrular');
      expect(find.byKey(const Key('liveCapture.openSettings')), findsNothing,
          reason: 'sistem hâlâ soracak; kullanıcıyı OS ayarlarına yollamak '
              'gereksiz bir yolculuk ve yanlış bir kesinlik iması');
    });
  });

  group('Onboarding O3', () {
    testWidgets('KALICI ret → "Open Settings" VAR ve GERÇEKTEN çağırıyor',
        (WidgetTester tester) async {
      pinNarrowSurface(tester);
      _stubPermissions(tester, status: _kPermanentlyDenied);
      final List<String> opened = <String>[];

      await tester.pumpWidget(MaterialApp(
        theme: buildLissomTheme(),
        home: OnboardingFlow(
          store: _NullStore(),
          onDone: (OnboardingProfile _) {},
          onOpenSettings: () async {
            opened.add('yes');
            return true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // O1 → O2 → O3
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();

      // İzin İSTENMEDEN düğme OLMAMALI: hâl bilinmiyorken "ayarlara git"
      // demek, ölçülmemiş bir şeyi iddia etmektir.
      expect(find.byKey(const Key('onboarding.camera.openSettings')),
          findsNothing,
          reason: 'izin daha istenmedi — durum BİLİNMİYOR');

      await tester
          .tap(find.byKey(const Key('onboarding.camera.requestPermission')));
      await tester.pumpAndSettle();

      expect(find.textContaining('the system will not ask again'),
          findsOneWidget,
          reason: 'POZİTİF ÇAPA — kalıcı-ret dalına GERÇEKTEN girdik');

      final Finder btn =
          find.byKey(const Key('onboarding.camera.openSettings'));
      expect(btn, findsOneWidget);
      await tester.tap(btn);
      await tester.pump();
      expect(opened, <String>['yes']);
    });

    testWidgets('İZİN VERİLDİ → düğme YOK', (WidgetTester tester) async {
      pinNarrowSurface(tester);
      _stubPermissions(tester, status: _kGranted);

      await tester.pumpWidget(MaterialApp(
        theme: buildLissomTheme(),
        home: OnboardingFlow(
          store: _NullStore(),
          onDone: (OnboardingProfile _) {},
          onOpenSettings: () async => true,
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('onboarding.camera.requestPermission')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Camera access granted'), findsOneWidget,
          reason: 'POZİTİF ÇAPA — izin-verildi dalındayız');
      expect(find.byKey(const Key('onboarding.camera.openSettings')),
          findsNothing);
    });
  });
}

class _NullStore implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async =>
      const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async {}
}
