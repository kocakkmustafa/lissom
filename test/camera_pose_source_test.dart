/// `CameraPoseSource` — SAF eşleme mantığının kanıtı (kamera-kabuğu sevki,
/// 2026-08-12).
///
/// Bu dosyanın SINIRI isimle: gerçek `MotionCameraController` bir
/// `MethodChannel` sarmalı ve `flutter test`te platform kanalı
/// mocklanmadan çağrılamaz — o yüzden `start()`/`dispose()`/gerçek kare
/// akışı BURADA sınanmıyor (Ostinato'nun "kanıt sınıfı dürüst" itirafının
/// aynısı: bağlandı ≠ canlı, gerçek doğrulama cihaz turu). Sınanan şey:
/// `permissionState`/`failureState` — `PermissionStatus`/`CameraException`
/// DEĞERLERİNDEN `LiveSessionState`e eşleme, saf fonksiyonlar.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/camera_pose_source.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_camera/motion_camera.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('permissionState — kalıcı/geçici ayrımı KORUNUYOR', () {
    test('reddedildi (geçici) → PermissionDenied.transient, "tekrar dene" ANLAMLI', () {
      final LiveSessionState s = permissionState(PermissionStatus.denied);
      expect(s, isA<PermissionDenied>());
      final PermissionDenied p = s as PermissionDenied;
      expect(p.kind, PermissionDenialKind.transient);
      expect(p.retryMakesSense, isTrue);
    });

    test('kalıcı reddedildi → PermissionDenied.permanent, "tekrar dene" ANLAMSIZ', () {
      final LiveSessionState s =
          permissionState(PermissionStatus.permanentlyDenied);
      expect(s, isA<PermissionDenied>());
      final PermissionDenied p = s as PermissionDenied;
      expect(p.kind, PermissionDenialKind.permanent);
      expect(p.retryMakesSense, isFalse,
          reason: 'kalıcı rette "tekrar dene" göstermek kullanıcıyı hiçbir '
              'yere varmayan bir düğmeye hapseder — LiveSessionState '
              'dokümanının desen 2 hükmü');
    });

    test('kısıtlı (ebeveyn kontrolü vb.) → KALICI sayılır, geçici DEĞİL', () {
      final LiveSessionState s = permissionState(PermissionStatus.restricted);
      expect((s as PermissionDenied).kind, PermissionDenialKind.permanent);
    });

    test('her iki hâlde de userText BOŞ DEĞİL', () {
      for (final PermissionStatus st in <PermissionStatus>[
        PermissionStatus.denied,
        PermissionStatus.permanentlyDenied,
        PermissionStatus.restricted,
      ]) {
        expect(permissionState(st).userText, isNotEmpty);
      }
    });
  });

  group('failureState — CameraFailure kodları İSİMLE taşınıyor', () {
    test('permissionDenied → PermissionDenied (geçici), izin akışıyla AYNI hâl', () {
      final LiveSessionState s =
          failureState(const CameraException(CameraFailure.permissionDenied, null));
      expect(s, isA<PermissionDenied>());
    });

    test('diğer HER CameraFailure kodu → SetupFailed, kod SESSİZCE yutulmaz', () {
      for (final CameraFailure f in CameraFailure.values) {
        if (f == CameraFailure.permissionDenied) continue;
        final LiveSessionState s =
            failureState(CameraException(f, null));
        expect(s, isA<SetupFailed>(),
            reason: '${f.name}: isimsiz bir jenerik hataya düşmemeli');
        expect((s as SetupFailed).code, f.code,
            reason: 'kod DEĞİŞTİRİLMEDEN taşınmalı — battery_summary '
                'deseni: bilinmeyen kod bile GÖSTERİLİR');
      }
    });

    test('CameraException OLMAYAN bir hata bile isimsiz düşmez', () {
      final LiveSessionState s = failureState(StateError('beklenmeyen'));
      expect(s, isA<SetupFailed>());
      expect((s as SetupFailed).code, 'unexpected');
      expect(s.userText, contains('beklenmeyen'),
          reason: 'ham hata metni yutulmamalı, kullanıcı diline karışmasa '
              'bile İZ olarak kalmalı');
    });
  });
}
