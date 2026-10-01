/// **BAYAT YOKLUK CÜMLESİ KAPISI — aile sınıfı H-10 (L-319).**
///
/// ═══════════════════════════════════════════════════════════════════
/// ## SINIF — iki hat aynı gece BAĞIMSIZ buldu
/// ═══════════════════════════════════════════════════════════════════
///
/// Koordinatör hükmü `H-10`, `2026-08-14`:
///   > ***BİR YOKLUK CÜMLESİ, YOKLUK BİTTİĞİ GÜN BAYATLAR.***
///
/// · **Choreia (`C-275`)** — onboarding'in son kartı *"Nothing you do is saved
///   anywhere in this version"* diyordu; depo `C-268`'de kurulmuştu.
/// · **Lissom (`L-317`)** — boş-hâl kartı *"No session can be captured in this
///   build"*; `A1` `L-309`'da kapanmıştı.
///
/// Ve bu hatta **iki tane daha** çıktı (`L-319`), ikisi de H-10 görevinin
/// taramasıyla:
/// · `profile_screen.dart` — *"Nothing is captured by the camera in this build
///   either"*. 🔴 **Üstündeki yorum bunu ÖNCEDEN yazmıştı:** *"gerekçe bir gün
///   gerçekleştiğinde cümle aynen kalır, yalnız artık denetlenmemiş olur."*
///   Kod kendi bayatlamasını tahmin etti, sonra bayatladı.
///   > ***BİR RİSKİ YORUMA YAZMAK, ONU ÖNLEMEZ — ÖNLEYEN ŞEY KAPIDIR.***
/// · `onboarding_flow.dart` — *"nothing is recorded, saved, or sent anywhere"*.
///   Öznesi VİDEOYDU ama **her şey** diye okunur, ve Lissom ölçüm kaydını diske
///   yazıyor ⇒ Progress'in *"the test and the date … appear in this list"*
///   cümlesiyle **çelişiyordu.**
///   > ***BİR YOKLUK CÜMLESİNİN ÖZNESİ BELİRSİZSE, YOKLUK BÜYÜR —***
///   > *okuyucu onu en geniş hâliyle anlar, ve en geniş hâli yalandır.*
///
/// ═══════════════════════════════════════════════════════════════════
/// ## KAPI NE YAPAR — ve ne YAPMAZ
/// ═══════════════════════════════════════════════════════════════════
///
/// Her yasak desen, **artık DOĞRU OLMADIĞI için** yasak; her birinin yanında
/// *onu yalanlayan ölçüm* yazılı. ⛔ Bu bir üslup kapısı DEĞİL: bir cümle
/// yalnız **gerçekliğe aykırı** olduğu için listeye girer.
///
/// ⛔ **Kurmadığım kapı:** *"her yokluk cümlesi hâlâ doğru mu"* — o metin-anlam
/// sorusudur, kapı değil HÜKÜM ister (`L-316`'da da kurmamıştım). Bu kapı
/// yalnız **bilinen ve ölçülmüş** yalanların geri gelmesini engeller.
/// > *Bir kapı her şeyi koruyamaz; koruduğu şeyi ADIYLA yazmalı.*
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/lissom_theme.dart';
import 'package:lissom/app/onboarding_flow.dart';
import 'package:lissom/app/onboarding_store.dart';

import 'support/narrow_surface.dart';

final class _FakeStore implements OnboardingStore {
  @override
  Future<OnboardingProfile> read() async => const OnboardingProfile.notStarted();
  @override
  Future<void> write(OnboardingProfile profile) async {}
}

/// Yasak desen → **onu yalanlayan ÖLÇÜM.**
const Map<String, String> _staleClaims = <String, String>{
  'no session can be captured':
      'A1 kapandı (L-309): ölçüm uçtan uca koşuyor ve depoya yazıyor',
  'nothing is captured by the camera':
      'A1 kapandı (L-309): kamera yakalıyor ve kayıt sessions.jsonl\'e giriyor',
  'nothing is recorded, saved':
      'ölçüm kaydı diske YAZILIYOR (JsonlSessionStore) — öznesi belirsiz bir '
          'yokluk cümlesi, en geniş hâliyle okunur ve o hâli yalandır',
  'nothing you do is saved':
      'Choreia\'nın vakası (C-275) — bu hatta da girmesin',
  'not saved anywhere':
      'ölçüm kaydı bu cihazda saklanıyor',
};

void main() {
  _capabilityClaimGate();

  test('sevk edilen kodda BAYAT yokluk cümlesi YOK', () {
    final Map<String, List<String>> found = <String, List<String>>{};
    int scanned = 0;

    for (final FileSystemEntity e
        in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;

      // 🪤 Yorumlar HARİÇ — bu dosyanın ve `profile_screen.dart`ın kendi
      // belgeleri yasak cümleleri ALINTILIYOR. Dışlanmasaydı kapı, kusuru
      // ANLATAN metni kusur sayardı (L-317'de kendi sabotaj-doğrulamam
      // tam bu yüzden yanlış okumuştu).
      final List<String> code = e
          .readAsLinesSync()
          .where((String l) => !l.trimLeft().startsWith('//'))
          .toList();
      scanned += code.length;

      // 🔴 **BU KAPI DA KÖR DOĞDU — sabotaj yakaladı (L-319).**
      // İlk yazımım satır satır tarıyordu ve sabotaj **ötmedi.** Sebep
      // yapısal: Dart uzun dizeleri satırlara BÖLER —
      //     'there is nowhere for your data to go. Nothing is '
      //     'captured by the camera in this build either. …'
      // ⇒ *"nothing is captured by the camera"* HİÇBİR SATIRDA tam geçmez.
      // Satır tabanlı bir tarayıcı yalnız **bir satıra sığan** ifadeleri
      // yakalar — yani tam da bayat iddiaları taşıyan UZUN cümleleri
      // göremez.
      // > ***BİR KAYNAK TARAYICISI, DİLİN METNİ BÖLDÜĞÜ YERİ BİLMİYORSA,
      // > ARADIĞI ŞEYİN EN UZUN HÂLİNİ HİÇ GÖREMEZ.***
      // ⇒ Bitişik dize parçaları BİRLEŞTİRİLİYOR: `' … ' \n ' … '` → tek dize.
      final String joined = code
          .join('\n')
          .replaceAll(RegExp(r"'\s*\n\s*'"), '')
          .toLowerCase();

      for (final MapEntry<String, String> c in _staleClaims.entries) {
        if (joined.contains(c.key)) {
          (found[e.path] ??= <String>[])
              .add('«${c.key}» — ÇÜRÜTEN ÖLÇÜM: ${c.value}');
        }
      }
    }

    // POZİTİF ÇAPA: tarayıcı gerçekten kod okudu mu?
    expect(scanned, greaterThan(500),
        reason: 'tarayıcı yeterli satır görmedi — "0 ihlal" VAKUM-DOĞRU olurdu');

    expect(found, isEmpty,
        reason: 'BAYAT YOKLUK CÜMLESİ (H-10): artık doğru olmayan bir yokluk '
            'beyanı sevk edilen kodda → $found');
  });

  test('POZİTİF KONTROL: desen bayat bir cümleyi GERÇEKTEN yakalar', () {
    const String fake =
        "  reason: 'No session can be captured in this build, so …',";
    expect(_staleClaims.keys.any(fake.toLowerCase().contains), isTrue,
        reason: 'desen bayat cümleyi yakalamıyor — kapı kör');

    const String ok = "  reason: 'When you measure, the test and the date …',";
    expect(_staleClaims.keys.any(ok.toLowerCase().contains), isFalse,
        reason: 'desen meşru metni suçluyor — hat kapıyı kapatır ve koruma '
            'tamamen kaybolur');
  });

  testWidgets('ONBOARDING ile PROGRESS aynı şeyi söylüyor — çelişki YOK',
      (WidgetTester tester) async {
    pinTallSurface(tester);

    // Onboarding'in kamera adımı: yokluk cümlesinin ÖZNESİ açık olmalı —
    // *video* saklanmıyor, *kayıt* saklanıyor. İkisi ayrı olgu.
    await tester.pumpWidget(MaterialApp(
      theme: buildLissomTheme(),
      home: OnboardingFlow(
        store: _FakeStore(),
        onDone: (OnboardingProfile _) {},
      ),
    ));
    await tester.pumpAndSettle();

    // Kamera adımına kadar yürü (düğmeyle — bayrak set ederek DEĞİL).
    for (int i = 0; i < 6; i++) {
      final Finder cb = find.byType(Checkbox);
      if (cb.evaluate().isNotEmpty) {
        await tester.tap(cb.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
      if (find.textContaining('never recorded').evaluate().isNotEmpty) break;
      final Finder next = find.widgetWithText(FilledButton, 'Continue');
      if (next.evaluate().isEmpty) break;
      await tester.tap(next.first, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    // POZİTİF ÇAPA: kamera adımına GERÇEKTEN varıldı mı?
    expect(find.textContaining('never recorded'), findsOneWidget,
        reason: 'kamera adımına varılamadı — aşağıdaki hüküm VAKUM-DOĞRU olurdu');

    // ⇒ Ve "hiçbir şey saklanmıyor" ARTIK DENMİYOR: saklananın ne olduğu
    // adıyla söyleniyor, Progress'in listesiyle aynı cümleyle.
    expect(find.textContaining('Test results and dates are saved'),
        findsOneWidget,
        reason: 'onboarding neyin saklandığını SÖYLEMİYOR — kullanıcı '
            '"hiçbir şey saklanmıyor" diye anlar ve Progress onu yalanlar');
  });
}

/// **H-13'ÜN İKİNCİ YÖNÜ — *"yapmadığımızı yapıyoruz dedik"* (L-327).**
///
/// `H-10`/bu dosyanın üst yarısı *"yokta olmayanı yok dedik"* yönünü kapatıyor.
/// `H-13` ikinci yönü aileye bağladı ve Gravita'nın `G-213`/`G-214`'ünde en
/// pahalı hâlini gösterdi: **ürünün dürüstlük kartının kendisi** yalan
/// söylüyordu.
///
/// Bu hatta bulunan vaka (`config/ia/library.v1.json`):
///   > *"Twelve camera-based movement tests … and **feeds your daily plan**."*
/// Oysa Home aynı derlemede diyor ki: *"A daily routine is meant to be built
/// from your own measurements. **The part of Lissom that builds it is not in
/// this build.**"* ⇒ **İki yüzey, bir derleme, zıt iddia.**
///
/// ⚠️ Ve bu **`lib/`de değil `config/`de** duruyordu — `H-13`'ün uyarısı
/// birebir: *"`lib/` yetmez: `content/`, onboarding, yardım, dürüstlük kartı
/// dahil."* Yalnız Dart tarayan bir kapı bunu **hiç göremezdi.**
///
/// > ***BİR YETENEK VAADİ, ONU YALANLAYAN CÜMLEYLE AYNI DERLEMEDE
/// > YAŞAYABİLİR — VE İKİSİ FARKLI DOSYA TÜRLERİNDEYSE HİÇBİR KAPI İKİSİNİ
/// > BİRDEN OKUMAZ.***
void _capabilityClaimGate() {
  test('config: karşılığı OLMAYAN yetenek vaadi YOK', () {
    // Yasak vaat → onu YALANLAYAN ölçüm. Liste kısa ve ÖLÇÜLMÜŞ; üslup
    // kapısı değil.
    const Map<String, String> unbacked = <String, String>{
      'feeds your daily plan':
          'günlük plan üreteci bu derlemede YOK — Home bunu kendisi söylüyor '
              '("The part of Lissom that builds it is not in this build")',
      'we tell you what to change':
          'Gravita G-213 vakası — bu hatta koçluk katmanı yok',
      'adapts to you':
          'uyarlama yapan hiçbir kod yok',
    };

    final List<String> found = <String>[];
    int scanned = 0;
    for (final FileSystemEntity e
        in Directory('config').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.json')) continue;
      final String raw = e.readAsStringSync().toLowerCase();
      scanned += raw.length;
      for (final MapEntry<String, String> c in unbacked.entries) {
        if (raw.contains(c.key)) {
          found.add('${e.path}: «${c.key}» — ÇÜRÜTEN: ${c.value}');
        }
      }
    }

    // POZİTİF ÇAPA: config gerçekten okundu mu?
    expect(scanned, greaterThan(5000),
        reason: 'config taranamadı — "0 vaat" VAKUM-DOĞRU olurdu');

    expect(found, isEmpty,
        reason: 'KARŞILIKSIZ YETENEK VAADİ (H-13): $found');
  });

  test('POZİTİF KONTROL: desen karşılıksız vaadi YAKALAR', () {
    const String fake = 'each one measures a specific area and feeds your '
        'daily plan.';
    expect(fake.contains('feeds your daily plan'), isTrue,
        reason: 'desen vaadi yakalamıyor — kapı kör');
  });
}
