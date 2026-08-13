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
import 'package:lissom/app/camera_pose_source.dart';
import 'package:permission_handler/permission_handler.dart';
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

/// ⚠️ **`restricted` AYRI sürülür, `permanentlyDenied`in kopyası değil**
/// (koordinatör şerhi): MDM/ebeveyn denetimli cihazda izin diyaloğu **HİÇ
/// çıkmaz**, yani *"ikinci ret = kalıcı"* sezgisi bu vakayı **ilkece**
/// göremez. Kodda `||` ile kapsandığını GÖRMEK yetmez — o "varlık"
/// ölçümüdür; bu sabit, hâli DAVRANIŞLA sürmek için var.
const int _kRestricted = 2;

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
  _duplicationGate();

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

    testWidgets(
        'RESTRICTED (MDM/ebeveyn denetimi) → düğme VAR — diyalog HİÇ '
        'çıkmadığı için bu hâl "ikinci ret" sezgisiyle bulunamaz',
        (WidgetTester tester) async {
      pinNarrowSurface(tester);
      _stubPermissions(tester, status: _kRestricted);
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
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.disclaimer.ack')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding.continue')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const Key('onboarding.camera.requestPermission')));
      await tester.pumpAndSettle();

      expect(find.textContaining('the system will not ask again'),
          findsOneWidget,
          reason: 'POZİTİF ÇAPA — restricted da KALICI dalına düşmeli');

      final Finder btn =
          find.byKey(const Key('onboarding.camera.openSettings'));
      expect(btn, findsOneWidget,
          reason: 'kısıtlanmış cihazda kullanıcının TEK yolu ayarlardır');
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

/// **TEKRAR YASAĞI — cihazda yürürken görüldü (L-320).**
///
/// Kalıcı-ret ekranı kullanıcıya aynı talimatı **iki kez** veriyordu:
///   *"Camera access is off for Lissom. **Open Settings to turn it on.**"*
///   *"**Open Settings to turn camera access on for Lissom.**"*
/// Geçici dalda da aynısı (*"… Try again."* + *"You can try again."*).
///
/// Sebebi bir katman karışıklığıydı: `camera_pose_source` OLGUYU bildirirken
/// TALİMAT da veriyordu, ekran ise `kind`den türettiği yönergeyi zaten
/// basıyordu. Roller ayrıldı; bu kapı ayrılmanın geri çözülmesini engelliyor.
/// > ***AYNI CÜMLEYİ İKİ KATMAN BİRDEN SÖYLÜYORSA, BİRİ ONU SÖYLEMEMELİDİR.***
///
/// ⛔ Genel bir *"tekrar var mı"* kapısı DEĞİL: yalnız **kaynak katmanının
/// talimat taşımasını** yasaklıyor — ölçülmüş ve adı konmuş tek kusur.
void _duplicationGate() {
  test('poz kaynağı TALİMAT taşımaz — eylem ekranın işi', () {
    // Üretimin GERÇEK metinleri, fixture değil.
    final List<String> texts = <String>[
      (permissionState(PermissionStatus.permanentlyDenied) as PermissionDenied)
          .userText,
      (permissionState(PermissionStatus.denied) as PermissionDenied).userText,
    ];

    // POZİTİF ÇAPA: gerçekten metin ürettik mi?
    expect(texts.every((String s) => s.length > 10), isTrue,
        reason: 'kaynak metin üretmiyor — kapı VAKUM-DOĞRU olurdu');

    for (final String s in texts) {
      final String low = s.toLowerCase();
      expect(low.contains('open settings'), isFalse,
          reason: 'kaynak katmanı "Open Settings" TALİMATI taşıyor; ekran '
              'aynı yönergeyi zaten basıyor ⇒ kullanıcı iki kez okur: «$s»');
      expect(low.contains('try again'), isFalse,
          reason: 'kaynak katmanı "Try again" TALİMATI taşıyor; ekran aynı '
              'yönergeyi zaten basıyor ⇒ kullanıcı iki kez okur: «$s»');
    }
  });
}
