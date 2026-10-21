/// **YETENEK İDDİASI KAPISI (L-262)** — J-147 aktarımının bende çıkan hâli.
///
/// Koordinatörün ucuz yöntemi: **«bunu kim görüyor?» sorusu, «bu doğru mu?»
/// sorusunun cevabını da getiriyor.** Denedim, ve getirdi.
///
/// ## Bulunan kusur — ve TEHLİKELİ yönde
///
/// *"What Lissom doesn't do"* kalem 2, bir **sınırı** anlatırken araya bir
/// **yetenek** sıkıştırmıştı:
///
/// > *"Our breath sessions are **voice-guided** with the camera off"*
///
/// Ölçüm: **bu üründe hiçbir ses/TTS hattı yok** (`pubspec`te ses paketi yok,
/// `lib/` ve motorda konuşma çağrısı yok) ve `breath_meditation` ailesi
/// **`notBuilt`, sıfır çocuklu.** Yani cümle, olmayan bir yeteneği **şimdiki
/// zamanda** anlatıyordu.
///
/// Bu, M-F-287'nin **ters** yönü: bir yeteneği olduğundan **geniş** yazmak.
/// Ve daha tehlikeli, çünkü hata **kullanıcı aleyhine** veriyor — eksik yazmak
/// kullanıcıyı korur, fazla yazmak aldatır.
///
/// ## Kural REFERANSA bağlı — icat değil
///
/// *"'voice' kelimesi yasak"* demiyorum; o benim icadım olurdu ve bir gün ses
/// eklenirse **doğru cümleyi** öldürürdü. Kural: **bir yetenek iddiası, o
/// yeteneğin KOD YOLU varsa meşrudur.** Ses hattı eklendiği gün kapı
/// kendiliğinden serbest bırakır (L-248).
///
/// ## Bu kapının ÖLÇMEDİĞİ — isimle
///
/// Yalnız **ses** sınıfını ölçüyor, çünkü ölçülmüş bir yokluk o. *"Kişiselleş-
/// tirilmiş plan"*, *"hatırlatma"* gibi başka yetenek iddiaları bu kapının
/// **dışında**; onlar için ayrı bir yokluk ölçümü gerekir. Kapıyı geniş
/// yazmak, ölçmediğim şeyi ölçüyor gibi göstermek olurdu.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ses/konuşma YOLU — **tek adres** (L-256). İddia ve ikiz aynı kodu çağırır.
bool hasAudioCodePath() {
  final RegExp dep = RegExp(
      r'^\s*(flutter_tts|just_audio|audioplayers|audio_session|'
      r'speech_to_text|record)\s*:',
      multiLine: true);
  if (dep.hasMatch(File('pubspec.yaml').readAsStringSync())) return true;

  final RegExp call = RegExp(r'\b(FlutterTts|AudioPlayer|AudioSession|'
      r'\.speak\(|playAudio|TextToSpeech)');
  for (final String dir in <String>['lib', 'packages/lissom_engine/lib']) {
    for (final FileSystemEntity f in Directory(dir).listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final String src = File(f.path)
          .readAsStringSync()
          .replaceAll(RegExp(r'^\s*///.*$', multiLine: true), '')
          .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');
      if (call.hasMatch(src)) return true;
    }
  }
  return false;
}

/// Kullanıcıya SES vaat eden ifadeler.
///
/// ⚠️ Dar tutuldu: *"voice"* kelimesi tek başına yasak DEĞİL — *"voice of the
/// product"* gibi meşru kullanımlar var. Yasak olan **rehberlik/anlatım
/// iddiası**.
final RegExp _audioClaim = RegExp(
    r'(voice-guided|voice guided|spoken (cue|instruction|guidance)|'
    r'read(s)? (them |it )?aloud|audio (cue|guidance)|talks you through)',
    caseSensitive: false);

// Olumsuz beyan ("No … audio guidance … is included") bir vaat değil, tersi.
// Aynı cümlede eşleşmeden ÖNCE, araya karşıtlık ("but"/";") girmeden duran bir
// olumsuzluk vaadi siler. Katalog (config/l10n) bu beyanı anahtar olarak taşır.
final RegExp _negation =
    RegExp(r'\b(no|not|never|without|none)\b', caseSensitive: false);

bool _isAudioClaim(String text) {
  for (final String sentence in text.split(RegExp(r'(?<=[.!?])\s+'))) {
    for (final RegExpMatch m in _audioClaim.allMatches(sentence)) {
      String before = sentence.substring(0, m.start);
      final int cut = <int>[
        before.toLowerCase().lastIndexOf(' but '),
        before.lastIndexOf(';'),
      ].reduce((int a, int b) => a > b ? a : b);
      if (cut >= 0) before = before.substring(cut);
      if (!_negation.hasMatch(before)) return true;
    }
  }
  return false;
}

Iterable<String> _configStrings() sync* {
  for (final FileSystemEntity f
      in Directory('config').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.json')) continue;
    yield* _strings(jsonDecode(File(f.path).readAsStringSync()));
  }
}

Iterable<String> _strings(Object? node) sync* {
  if (node is String) {
    yield node;
  } else if (node is Map<String, dynamic>) {
    for (final Object? v in node.values) {
      yield* _strings(v);
    }
  } else if (node is List) {
    for (final Object? v in node) {
      yield* _strings(v);
    }
  }
}

void main() {
  test('POZİTİF İKİZ: iddia deseni ve yol-bulucu ÇALIŞIYOR', () {
    // L-255: aşağıdaki iddia bir YOKLUK — bozuk desenle sonsuza dek yeşil.
    expect(_audioClaim.hasMatch('Our breath sessions are voice-guided.'),
        isTrue,
        reason: 'BULUCU BOZUK: desen, TAM OLARAK bulduğum ihlali bile '
            'yakalayamıyor — bu kapının her yeşili vakum-doğru');

    // ⭐ TERS İKİZ: kapının DARLIĞI (L-248). Bu cümleler MEŞRU ve kalmalı.
    for (final String ok in <String>[
      'Lissom keeps a plain voice: it says what it measured.',
      'We will not estimate a number we cannot take.',
    ]) {
      expect(_audioClaim.hasMatch(ok), isFalse,
          reason: 'KAPI FAZLA GENİŞ: «$ok» bir ses vaadi DEĞİL. Yasak '
              'kelime değil, REHBERLİK İDDİASI.');
    }

    // Olumsuz beyan vaat değildir; karşıtlıkla gelen vaat yine yakalanır.
    expect(
        _isAudioClaim('No breath or wind-down sessions, audio guidance or '
            'session timer are included in this release.'),
        isFalse,
        reason: 'KAPI FAZLA GENİŞ: açık bir YOKLUK beyanı ses vaadi sayıldı');
    expect(_isAudioClaim('Audio guidance talks you through each pose.'), isTrue,
        reason: 'BULUCU BOZUK: olumlu ses vaadi kaçtı');
    expect(_isAudioClaim('No timer, but audio guidance is included.'), isTrue,
        reason: 'BULUCU BOZUK: "but" sonrası vaat olumsuzlukla örtüldü');

    // Ve yol-bulucu gerçekten arıyor mu?
    expect(File('pubspec.yaml').existsSync(), isTrue,
        reason: 'pozitif çapa: yol-bulucu okunacak dosyayı bulamıyor');
  });

  test('SES vaadi, ses KOD YOLU olmadan edilemez', () {
    final bool audio = hasAudioCodePath();
    final List<String> claims =
        _configStrings().where(_isAudioClaim).toList();

    // Pozitif çapa: config gerçekten okundu mu (L-183)?
    final int total = _configStrings().length;
    expect(total, greaterThan(50),
        reason: 'config\'ten yalnız $total metin çıktı — tarayıcı çalışmıyor');

    if (audio) {
      // Yetenek geldiyse kural kendiliğinden serbest: kapı geleceğin doğru
      // hâlini yasaklamıyor. Ama beyan da güncellenmiş olmalı.
      return;
    }
    expect(claims, isEmpty,
        reason: 'Bu build\'de HİÇBİR ses/TTS kod yolu yok, ama metin ses '
            'rehberliği VAAT EDİYOR:\n  ${claims.join("\n  ")}\n\n'
            'Bu, bir yeteneği olduğundan GENİŞ yazmaktır (M-F-287\'nin ters '
            'yönü) ve eksik yazmaktan daha tehlikelidir: eksik yazmak '
            'kullanıcıyı korur, fazla yazmak ALDATIR.');
  });
}
