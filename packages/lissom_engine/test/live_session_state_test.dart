/// Canlı seans hâllerinin kapısı — JabLab'ın üç deseni (M-F-267) SINANIYOR.
///
/// Her desen için hem POZİTİF iddia (mekanizma çalışıyor) hem sabotaj (kapı
/// kırmızı yanabiliyor) var — L-183'ün pozitif-ikiz dersi.
library;

import 'package:lissom_engine/lissom_engine.dart';
import 'package:test/test.dart';

void main() {
  group('desen 1 — ÇIKMAZ-SOKAK YASAĞI', () {
    test('kurulum hatası bir HÂL, istisna değil: ekran açılır ve konuşur', () {
      const LiveSessionState s = SetupFailed(
          code: 'camera-open-failed', userText: 'Kamerayı açamadım.');
      expect(s, isA<LiveSessionState>(),
          reason: 'kurulum hatası seansın İÇİNDE bir hâl olmalı — dışına '
              'fırlarsa ekran açılmaz ve çıkmaz sokak doğar');
      expect(s.canMeasure, isFalse);
      expect(s.userText, isNotEmpty,
          reason: 'sessiz-dokun-hiçbir-şey-olmaz yasak');
    });

    test('HİÇBİR hâl boş gerekçeyle var olamaz (tüm alt tipler)', () {
      // Pozitif kontrol: liste GERÇEKTEN dolu mu? Boşsa aşağıdaki döngü
      // trivially geçer ve hiçbir şey kanıtlamaz.
      final List<LiveSessionState> all = <LiveSessionState>[
        const LiveIdle(),
        const SetupFailed(code: 'x', userText: 'kurulum patladı'),
        const PermissionDenied(
            kind: PermissionDenialKind.transient, userText: 'izin yok'),
        const NoPersonDetected(),
        const JointsOutOfFrame(missingGroup: 'lower-body'),
        Measuring(
            reading: const LiveReading.absent(
                metric: 'shoulder_flexion_right',
                narrative: 'henüz denemediniz')),
      ];
      expect(all.length, 6, reason: 'hâl listesi eksilmiş — yeni hâl eklendiyse '
          'bu testi de güncelle (sealed switch derleme hatası verir ama LİSTE '
          'sessizce eksik kalabilir)');
      for (final LiveSessionState s in all) {
        expect(s.userText.trim(), isNotEmpty,
            reason: '${s.runtimeType} gerekçesiz — L-135 ihlali');
      }
    });
  });

  group('desen 2 — İZİN-REDDİ kalıcı/geçici AYRIMI', () {
    test('geçici redde "tekrar dene" ANLAMLI', () {
      const PermissionDenied p = PermissionDenied(
          kind: PermissionDenialKind.transient, userText: 'İzin gerekiyor.');
      expect(p.retryMakesSense, isTrue);
    });

    test('KALICI redde "tekrar dene" ANLAMSIZ — ayarlara yönlendirilmeli', () {
      const PermissionDenied p = PermissionDenied(
          kind: PermissionDenialKind.permanent,
          userText: 'İzni Ayarlar\'dan açmanız gerekiyor.');
      expect(p.retryMakesSense, isFalse,
          reason: 'kalıcı rette sistem bir daha sormaz; "tekrar dene" düğmesi '
              'kullanıcıyı hiçbir yere varmayan bir döngüye hapseder — '
              'çıkmaz-sokak yasağının bir katman içeridesi');
    });

    test('sabotaj: iki hâli TEK bayrağa indirmek ayrımı SİLER', () {
      // Tek `bool denied` tutulsaydı bu iki durum ayırt edilemezdi ve kapı
      // hiçbir şey ölçmezdi. İddia: enum GERÇEKTEN iki değer taşıyor.
      expect(PermissionDenialKind.values.length, 2,
          reason: 'kalıcılık ayrımı çöktü');
    });
  });

  group('desen 3 — "HİÇ BAŞLAMADI ≠ SIFIR"', () {
    test('yokluk 0 olarak SIZMIYOR — sayı null, anlatı dolu', () {
      const LiveReading r = LiveReading.absent(
          metric: 'knee_flexion_right', narrative: 'Henüz çömelmediniz.');
      expect(r.degrees, isNull,
          reason: 'yokluk bir SAYI değil; 0 sanılırsa "hiç yapmadın" yerine '
              '"0° yaptın" anlatısı doğar');
      expect(r.hasMeasurement, isFalse);
      expect(r.display, 'Henüz çömelmediniz.');
      expect(r.display, isNot(contains('0')),
          reason: 'yokluk yüzeyde sayı olarak görünemez');
    });

    test('GERÇEK sıfır ölçümü ise sayı olarak gösterilir (pozitif ikiz)', () {
      // Bu iddia olmadan üstteki test "sıfırı hiç göstermeyen" bir sistemi de
      // geçirirdi — o da yanlış olurdu: 0° meşru bir ölçümdür.
      const LiveReading r =
          LiveReading.measured(0, metric: 'shoulder_flexion_right');
      expect(r.hasMeasurement, isTrue);
      expect(r.degrees, 0);
      expect(r.display, '0°',
          reason: 'kol yanda aşağıyken 0° GERÇEK bir ölçümdür ve gösterilir — '
              'yokluk ile karıştırılan şey buydu, tersi değil');
    });

    test('Measuring yokluk taşıyabilir — ölçüm başlamadan da hâl geçerli', () {
      final Measuring m = Measuring(
          reading: const LiveReading.absent(
              metric: 'hip_flexion_right', narrative: 'Bacağınızı kaldırın.'));
      expect(m.canMeasure, isTrue,
          reason: 'ölçüm koşuyor ama henüz değer yok — bu geçerli bir hâl');
      expect(m.userText, 'Bacağınızı kaldırın.');
    });
  });

  group('kadraj: "landmark bulundu ≠ geçerli ölçüm" (L-201 ürün yüzeyi)', () {
    test('kimse-yok ile eklem-kadraj-dışı AYRI tipler (eylem farklı)', () {
      const LiveSessionState noPerson = NoPersonDetected();
      const LiveSessionState outOfFrame =
          JointsOutOfFrame(missingGroup: 'lower-body');
      expect(noPerson.runtimeType, isNot(outOfFrame.runtimeType),
          reason: '"kadraja gir" ile "geri çekil" farklı eylemler; tek tipe '
              'indirilirse kullanıcı yanlış şeyi dener');
      expect((outOfFrame as JointsOutOfFrame).missingGroup, 'lower-body',
          reason: 'eksik grup İSİMLİ olmalı — "bir şeyler görünmüyor" değil');
    });

    test('kadraj durumu iki değerli (pozitif kontrol)', () {
      expect(JointCoverage.values.length, 2);
    });
  });
}
