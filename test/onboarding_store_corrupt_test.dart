/// **H-20 KONTROL LİSTESİ, İKİNCİ DEPOYA UYGULANDI (L-326).**
///
/// `H-20` (benim `L-325`'imden doğdu) aileye görev verdi: *depon kısmi/bozuk
/// okuma üretebiliyor mu, ve o durumda hangi dal çiziliyor?* `L-325`'te
/// **seans deposunu** düzelttim. Bu dosya **ikinci depoyu** — onboarding
/// profilini — aynı listeyle tarıyor.
///
/// ⚠️ **Ve burada kusur daha sinsi:** `JsonOnboardingStore.read()` yalnız
/// **`FormatException`** yakalıyor. Ama `OnboardingProfile.fromJson`
/// `as bool?` / `as String?` **cast**'leri kullanıyor — geçerli JSON ama
/// **yanlış tipli** bir alan `TypeError` fırlatır, ve o `catch` bloğundan
/// KAÇAR.
///
/// > ***BİR "BOZUK DOSYA" KORUMASI, YALNIZ KENDİ HAYAL ETTİĞİ BOZULMA
/// > BİÇİMİNİ YAKALAR — VE DOSYALAR HAYAL EDİLMEMİŞ BİÇİMLERDE BOZULUR.***
///
/// Bu bir kuram değil: şema değişirse (alan tipi `String` → `int`, ya da bir
/// anahtar yeniden adlandırılırsa) üretilen dosya **tam olarak** bu biçimde
/// bozulur — `L-325`'in `v` alanı vakasının kardeşi.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lissom/app/onboarding_store.dart';

Future<File> _tmp(String contents) async {
  final Directory d = await Directory.systemTemp.createTemp('lissom_ob');
  final File f = File('${d.path}/onboarding.json');
  await f.writeAsString(contents);
  addTearDown(() async {
    if (await d.exists()) await d.delete(recursive: true);
  });
  return f;
}

void main() {
  test('BOZUK JSON → başlanmamış sayılır (mevcut, doğru davranış)', () async {
    final File f = await _tmp('{ this is not json');
    final OnboardingProfile p = await JsonOnboardingStore(f).read();
    expect(p.completed, isFalse,
        reason: 'bozuk dosya çökertmemeli — en kötüsü onboarding tekrarı');
  });

  test('BOŞ dosya → başlanmamış sayılır', () async {
    final File f = await _tmp('   ');
    final OnboardingProfile p = await JsonOnboardingStore(f).read();
    expect(p.completed, isFalse);
  });

  test('GEÇERLİ JSON ama YANLIŞ TİP → çökmemeli (H-20 · L-326)', () async {
    // Şema değişikliğinin ürettiği gerçekçi bozulma: `completed` bir dize,
    // `ageBand` bir sayı. JSON geçerli ⇒ `FormatException` YOK ⇒ eski kod
    // `TypeError` fırlatır ve bu **yakalanmaz.**
    final File f = await _tmp(jsonEncode(<String, Object>{
      'completed': 'true',
      'ageBand': 40,
    }));

    // POZİTİF ÇAPA: dosya gerçekten GEÇERLİ JSON mu? Değilse bu test
    // yalnızca bir üstteki vakayı tekrar ederdi.
    expect(() => jsonDecode(f.readAsStringSync()), returnsNormally,
        reason: 'fixture geçerli JSON olmalı — yoksa FormatException dalını '
            'ölçerdik ve bu test hiçbir yeni şey söylemezdi');

    final OnboardingProfile p = await JsonOnboardingStore(f).read();
    expect(p.completed, isFalse,
        reason: 'yanlış tipli alan uygulamayı çökertiyor: `read()` yalnız '
            'FormatException yakalıyor, cast hatası TypeError fırlatıyor');
  });

  test('KISMEN geçerli → okunabilen alanlar KORUNUR, ötekiler düşer',
      () async {
    // `ageBand` doğru tipte, `gender` yanlış. Hepsini atmak, okunabilen
    // beyanı da kaybetmek olurdu — `L-325`'in dersi: *okunamayan, boş
    // değildir* (ve tersi de: bir alanın okunamaması ötekini geçersiz kılmaz).
    final File f = await _tmp(jsonEncode(<String, Object>{
      'completed': true,
      'ageBand': 'u40',
      'gender': 42,
    }));
    final OnboardingProfile p = await JsonOnboardingStore(f).read();
    expect(p.ageBand, 'u40',
        reason: 'okunabilir yaş bandı, başka bir alanın bozukluğu yüzünden '
            'atıldı — kullanıcı beyanını yeniden vermek zorunda kalır');
    expect(p.completed, isTrue);
  });
}
