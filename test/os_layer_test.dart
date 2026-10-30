/// **İŞLETİM SİSTEMİ KATMANI (L-250)** — hiçbir kapının bakmadığı katman.
///
/// Koordinatörün sorusu: *"kapı yazarken ilk soru 'hangi kelimeler' değil,
/// 'hangi KATMANLAR'."* Ölçüldü — `wellness_lint` şu katmanlara bakıyor:
/// `config/**` · `lib/**` · `packages/lissom_engine/lib/**`. **Bakmadığı:**
/// `ios/Runner/Info.plist` ve Android manifest — oysa oradaki metinler
/// kullanıcıya **işletim sisteminin kendi diyaloğunda** gösterilir ve
/// uygulamanın dışına çıkan ilk cümledir.
///
/// ## Bulgu: `NSCameraUsageDescription` YOK
///
/// `motion_camera` bir bağımlılık, ürünün tüm önermesi kamerayla ölçüm — ama
/// izin metni **hiç yok.** iOS'ta izin isteyen bir uygulama bu anahtar
/// olmadan **anında çökerti verir.**
///
/// ⛔ **Metni ŞİMDİ EKLEMEDİM ve bu bilinçli.** Bugün hiçbir capture yolu yok
/// (L-242); kamera izni beyan etmek, **olmayan bir yeteneği beyan etmek**
/// olurdu — az önce yedi yüzeyde düzelttiğim sınıfın ta kendisi. Ve *"olmayan
/// bir sınırı beyan etmek gürültüdür"*in ikizi: **olmayan bir yeteneği beyan
/// etmek de gürültüdür.**
///
/// Onun yerine ikisi BİRBİRİNE BAĞLANDI: capture yolu doğduğu an izin metni
/// zorunlu olur. Bugün yeşil, yarın kendiliğinden kırmızı.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `lib/` içinde bir kamera-capture yolu var mı?
bool _hasCapturePath() {
  for (final FileSystemEntity f in Directory('lib').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final String src = File(f.path)
        .readAsStringSync()
        .replaceAll(RegExp(r'//[^\n]*'), ' ');
    if (RegExp(r'\bCameraController\b|\bmotion_camera\b|\bstartImageStream\b')
        .hasMatch(src)) {
      return true;
    }
  }
  return false;
}

String _infoPlist() => File('ios/Runner/Info.plist').readAsStringSync();

void main() {
  test('KAMERA İZNİ: capture yolu ile izin metni BİRLİKTE yaşar', () {
    final bool capture = _hasCapturePath();
    final bool hasKey = _infoPlist().contains('NSCameraUsageDescription');

    if (capture) {
      expect(hasKey, isTrue,
          reason: 'lib/ içinde bir kamera yolu var ama '
              '`NSCameraUsageDescription` YOK — iOS izin isteyen uygulamayı '
              'bu anahtar olmadan ANINDA çökertir');
    } else {
      // ⚠️ **BU DAL GEVŞETİLDİ (L-273) ve gerekçesi ölçüldü.**
      //
      // Önce `expect(hasKey, isFalse)` idi: *"capture yokken izin metni
      // olmamalı — olmayan bir yeteneği beyan etmek."* Koordinatör anahtarı
      // istediğinde kapı reddetti ve ilk refleksim kapıyı savunmak oldu.
      //
      // Sonra ölçtüm: **L-262'nin zararı "KULLANICIYA olmayan bir yeteneği
      // anlatmak"tı.** İzin metnini kullanıcıya gösteren şey **izin
      // diyaloğudur**, ve kamera hiç çalışmadığı için o diyalog **hiç
      // açılmıyor** — metin bugün **hiçbir kullanıcıya görünmüyor.** Yani
      // korumaya çalıştığım zarar **oluşamıyor**.
      //
      // Buna karşılık `motion_camera` **bağlı bir bağımlılık**: Apple'ın
      // statik denetimi kamera API'sini görür ve string yoksa **reddeder**.
      //
      // Kapı **fazla genişti** — bu gece defalarca başkasında bulduğum kusur,
      // bu kez benim kapımdaydı ve **kendi kapımı savunarak** onu bir tur
      // daha yaşattım.
      //
      // Kalan kural (dar ve gerçek): metin varsa **dürüst** olmalı — ne
      // yaptığını söylemeli, olmayan bir şeyi vaat etmemeli.
      if (hasKey) {
        expect(_infoPlist(), isNot(contains('NSMicrophoneUsageDescription')),
            reason: 'Ürün ses KAYDETMİYOR (beş hatta ölçülü sıfır ses '
                'hattı) — mikrofon izni istemek, olmayan bir yeteneği '
                'BEYAN ETMEK olurdu ve o diyalog kullanıcıya GÖRÜNÜR.');
      }
    }
  });

  test('İŞLETİM SİSTEMİ metinleri BİLİNİYOR — sessiz katman kalmıyor', () {
    // Pozitif çapa: plist gerçekten okundu mu?
    final String plist = _infoPlist();
    expect(plist, contains('CFBundleDisplayName'),
        reason: 'plist okunamadı — bu test hiçbir şey ölçmüyor');

    // Bugün OS katmanında kullanıcıya görünen TEK metin uygulama adı.
    // Yeni bir `*UsageDescription` eklendiğinde bu liste büyümeli ve o metin
    // `wellness_lint`ten geçmeli; aksi hâlde uygulamanın dışına çıkan ilk
    // cümle hiçbir denetimden geçmemiş olur.
    // POZİTİF İKİZ (L-255): desen, olması gereken şeyi buluyor mu? Bu bir
    // YOKLUK iddiası — bozuk bir desen ile doğru bir sonuç ayırt edilemez.
    final RegExp usagePattern = RegExp(r'<key>(NS\w*UsageDescription)</key>');
    expect(
        usagePattern.hasMatch('<key>NSCameraUsageDescription</key>'), isTrue,
        reason: 'BULUCU BOZUK: desen apaçık bir izin anahtarını bile '
            'bulamıyor — aşağıdaki "izin metni yok" iddiası vakum-doğru');

    // ⚠️ Bu iddia ÖNCE `isEmpty` idi: *"linter OS katmanına bakana kadar
    // hiç izin metni olmasın."* Doğru bir bekçilikti ama **karşılanamaz**
    // biçimde yazılmıştı — metni ekleyen her commit'i, linter genişletilse
    // bile kırmızıya çeviriyordu.
    //
    // Linter artık plist'i tarıyor (L-273: `OS_FILES` + `strings_from_plist`),
    // yani kural **karşılanabilir** hâle geldi. Gerçek kural şu: **her izin
    // metni denetimden GEÇMİŞ olmalı** — yokluğu değil, KAPSANMASI ölçülür.
    final List<String> keys = usagePattern
        .allMatches(plist)
        .map((RegExpMatch m) => m.group(1)!)
        .toList();
    final String lint = File('tools/wellness_lint.py').readAsStringSync();
    if (keys.isNotEmpty) {
      // ⚠️ Bu iddia önce `lint.contains('strings_from_plist')` idi ve
      // **sabotajı geçti**: fonksiyonu yeniden adlandırdım, çağrı yeri hâlâ
      // o adı taşıdığı için metin eşleşti. *Kelimenin varlığı, çağrının
      // çalıştığı değildir.* Davranış artık `lint_selftest.py`de gerçek
      // linter koşturularak sınanıyor; burada o ÖZ-TESTİN varlığını
      // çiviliyorum — silinirse davranış denetimi sessizce kaybolur.
      final String selftest =
          File('tools/lint_selftest.py').readAsStringSync();
      expect(selftest, contains('run_plist'),
          reason: 'İzin metni var (${keys.join(", ")}) ama linter\'in OS '
              'katmanı DAVRANIŞSAL olarak sınanmıyor — uygulamanın DIŞINA '
              'çıkan ilk cümle hiçbir denetimden geçmemiş olur.');
      expect(lint, contains('Info.plist'),
          reason: 'plist tarama listesinde DEĞİL — kod duruyor, tetiği yok.');
      // Ve metin BOŞ olamaz: Apple gerekçesiz izin isteğini reddeder.
      for (final String k in keys) {
        final RegExpMatch? m = RegExp(
                '<key>$k</key>\\s*<string>([^<]*)</string>')
            .firstMatch(plist);
        expect((m?.group(1) ?? '').trim().length, greaterThan(20),
            reason: '$k metni boş ya da çok kısa — Apple gerekçe ister, '
                've kullanıcı o cümleyi izin diyaloğunda OKUR');
      }
    }
  });

  test('KAMERA İZNİ: 14 dilde önce "bu sürümde kapalı" der', () {
    // Kamera ölçümü bu sürümde kapalı; izin metni eskiden "hareket
    // testleri için kamera" diyordu. Metin önce kapalı olduğunu, sonra
    // ileride açılırsa ne yapacağını söyler (JabLab/Ostinato kalıbı).
    // Wellness lint yalnız Info.plist'i okur; .lproj çevirileri burada.
    const Map<String, String> closed = <String, String>{
      'en': 'Live camera measurements are closed in this release.',
      'tr': 'Bu sürümde canlı kamera ölçümleri kapalıdır.',
      'de': 'Live-Kameramessungen sind in dieser Version geschlossen.',
      'es-419':
          'Las mediciones con cámara en vivo están deshabilitadas en esta versión.',
      'fr': 'Les mesures en direct par caméra sont fermées dans cette version.',
      'it':
          'Le misurazioni in tempo reale tramite fotocamera sono disattivate in questa versione.',
      'pt-BR': 'Medições ao vivo pela câmera estão fechadas nesta versão.',
      'id': 'Pengukuran kamera langsung ditutup dalam rilis ini.',
      'pl': 'Pomiary kamerą na żywo są wyłączone w tym wydaniu.',
      'ja': 'このリリースではライブカメラ測定を閉じています。',
      'ko': '이번 버전에서는 실시간 카메라 측정이 닫혀 있습니다.',
      'zh-Hans': '此版本已关闭实时摄像头测量。',
      'hi': 'इस संस्करण में लाइव कैमरा माप बंद हैं।',
      'ar': 'قياسات الكاميرا المباشرة مغلقة في هذا الإصدار.',
    };
    final RegExp value = RegExp(r'"NSCameraUsageDescription" = "([^"]+)";');
    String camera(String locale) {
      final String src = File(
        'ios/Runner/$locale.lproj/InfoPlist.strings',
      ).readAsStringSync();
      return value.firstMatch(src)?.group(1) ?? '';
    }

    for (final MapEntry<String, String> e in closed.entries) {
      expect(
        camera(e.key),
        startsWith(e.value),
        reason: '${e.key}: izin metni kapalı durumu söylemeye başlamıyor',
      );
      expect(camera(e.key), contains('Lissom'), reason: e.key);
    }
    final RegExpMatch? plist = RegExp(
      r'<key>NSCameraUsageDescription</key>\s*<string>([^<]*)</string>',
    ).firstMatch(_infoPlist());
    expect(
      plist?.group(1),
      camera('en'),
      reason: 'Info.plist ve en.lproj aynı metni taşımalı',
    );
    expect(plist?.group(1), isNot(contains('movement tests')));
  });
}
