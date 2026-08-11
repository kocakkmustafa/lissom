/// **HÜKÜM L-187'nin ŞARTI, ÇİVİLENMİŞ (L-254) — VE KANIT ZİNCİRİNE
/// BAĞLANMIŞ (L-277, M-F-462/474, koordinatör onayı 2026-08-12).**
///
/// Koordinatörün hükmü göçü onayladı — **ama bir şartla, ve şart hükmün
/// ayrılmaz parçası:**
///
/// > `kBridgeIsReferenceEquivalent` **ÖLÇÜMLE** `true` olur, **göç yapıldı
/// > diye değil.** Göç sonrası sapma yeniden ölçülür; hedefe düşmezse bayrak
/// > `false` KALIR ve göç yine de değerlidir (4 metrik açılır) ama **iddia
/// > derecesi değişmez.** Aksi hâlde *"göç yaptık, artık referans-eşdeğeriz"*
/// > denir ve bu **eşik icadıdır.**
///
/// ## L-254'ün deliği — ölçüldü, kapatıldı
///
/// L-254 bu şartı REGEX'le kurmuştu: `docs/L-031-UZAY-SAPMASI-OLCUMU.md`'de
/// "medyan N,N°" gibi metin desenleri arardı. `tools/
/// mutation_reference_equivalence.py`'nin 2. turu (2026-08-11) bunu
/// YALANLADI: 500+ karakterlik gerçekçi ama tamamen UYDURMA bir paragraf,
/// hiçbir gerçek ölçüm olmadan, dört deseni de karşılayıp kapıyı yeşile
/// düşürdü. **Regex NESRİ doğrular, İSPATI değil.**
///
/// Bu tur artefaktı bir KANIT ZİNCİRİNE bağlıyor
/// (`docs/L-031-ESDEGERLIK-KANITI.json`, YALNIZ `tools/
/// l031_space_divergence.py --claim-equivalence` tarafından yazılır —
/// bu dosya asla elle düzenlenemez, elle düzenlenirse `inputsSha256`
/// bağı tutmaz):
///
///  1. `inputsSha256` — ölçülen KOD DURUMUNUN içerik-hash HARİTASI
///     (dosya→hash, choreia `harvest_rig/manifest.py`'nin `rig_version()`
///     ilkesinin dar hâli — çok-repo kimlik denetimi Lissom tek-repo
///     olduğu için gereksiz, yalnız "hangi kod ölçüldü" bağı kalıyor).
///     Bu kapı AYNI dosyaları AYNI algoritmayla (SHA-256, ham bayt) ŞİMDİKİ
///     ağaçtan yeniden hesaplar; uyuşmazsa BAYAT/tutarsız kanıt.
///  2. `dartAnglesSha256` — GERÇEK bir hasat koşumunun (bugün 44K+ kare)
///     ham kare-dökümünün hash'i; elle üretmesi gerçek koşumdan ucuz
///     DEĞİL.
///  3. `passesOwnCriterion` — kapı bunu OKUR, YENİDEN HESAPLAMAZ
///     (`validate_metric_vocabulary.py`'nin `readers_of()` ilkesi:
///     doğrulayıcı, doğruladığı iddiayı üreten yolla AYNI olamaz —
///     kapı kendi kendini ölçen taraf olsaydı bu artefakt da kendi
///     kendini onaylardı).
///
/// **Choreia'dan aktarılmayan (bilerek):** `rig_staleness_warning()`'in
/// "uyar, REDDETME" tutumu. Oradaki gerekçe dal-içi araç geliştirmeyi
/// kırmamaktı; buradaki risk TAM TERSİ — mutasyon testi zaten "elle iki
/// sabit + bir paragraf"ın BEDAVA geçtiğini kanıtladı. Bu kapı fail-CLOSED.
///
/// **Dürüst sınır — isimle:** hash bağı sahtelemenin MALİYETİNİ gerçek bir
/// koşumla eşitler, NİYETİ kanıtlamaz. `rig_version()`'ın kendisi de aynı
/// sınırı taşır — kimlik+güncellik kanıtlar, art niyeti değil.
///
/// ## Kapı ne YAPMIYOR — isimle
///
/// *"11,29° iyi mi, 3° iyi mi"* sorusuna **CEVAP VERMİYOR** ve veremez: o bir
/// eşik ve eşik icadı yasak. `acceptanceCriterion` ölçenin KENDİ beyanı,
/// `l031_space_divergence.py --claim-equivalence`'a KOMUT SATIRINDAN
/// verilir — bu dosyada YOK, icat edilmiyor.
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lissom_engine/lissom_engine.dart';

File get _artifact => File('docs/L-031-UZAY-SAPMASI-OLCUMU.md');
File get _witness => File('docs/L-031-ESDEGERLIK-KANITI.json');

/// Ölçülen kod durumunu bağlayan girdiler — üreticiyle
/// (`tools/l031_space_divergence.py`'nin `INPUT_PATHS`'i) AYNI liste, elle
/// senkron tutulur (iki dilde paylaşılan tek kaynak yok — ayrışırsa
/// aşağıdaki "extra keys" kontrolü İKİ TARAFI da yakalar, sessizce kaçmaz).
const List<String> _inputPaths = <String>[
  'packages/lissom_engine/lib/src/metric_bridge.dart',
  'config/tests/lissom-assessment.v1.json',
  'config/metrics/lissom-metrics.v1.json',
];

String _sha256OfFile(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void main() {
  test('BAYRAK ancak ÖLÇÜMLE `true` olur — göç yapıldı diye değil', () {
    // Pozitif çapa: artefakt gerçekten okunuyor mu? Yoksa aşağıdaki iddialar
    // boş dosyada trivially geçerdi (L-183).
    expect(_artifact.existsSync(), isTrue,
        reason: 'L-031 ölçüm artefaktı yok — bu kapı hiçbir şey ölçmüyor');
    final String doc = _artifact.readAsStringSync();
    expect(doc.length, greaterThan(500), reason: 'artefakt boş okundu');

    if (!kBridgeIsReferenceEquivalent) {
      // BUGÜNKÜ HÂL. Karşıt yön de sınanıyor: bayrak `false` iken artefakt
      // hâlâ bir sapma ÖLÇÜMÜ taşımalı — çünkü `false` da bir iddiadır ve
      // gerekçesiz bir "eşdeğer değiliz" ihtiyat beyanına dönerdi.
      expect(RegExp(r'\d+[,.]\d+\s*°').hasMatch(doc), isTrue,
          reason: '`false` da ÖLÇÜLMÜŞ bir olgu olmalı, ihtiyat beyanı değil');
      return;
    }

    // BAYRAK `true` YAPILMIŞ. Artık NESİR yetmez — kanıt zinciri ZORUNLU.
    expect(_witness.existsSync(), isTrue,
        reason: '`kBridgeIsReferenceEquivalent` `true` ama '
            '${_witness.path} YOK — kanıt yok, yalnız iddia var. HÜKÜM '
            'L-187\'nin şartı: bayrak ÖLÇÜMLE true olur, göç yapıldı diye '
            'değil. Üret: `tools/l031_space_divergence.py '
            '--claim-equivalence ...`');

    final Map<String, dynamic> w =
        jsonDecode(_witness.readAsStringSync()) as Map<String, dynamic>;

    // 1) KİMLİK — kanıtı yazan script bu ağaçta git-takipli mi (elle
    // kopyalanıp hackenmiş bir script'ten mi geldi)?
    final Map<String, dynamic>? producedBy =
        w['producedBy'] as Map<String, dynamic>?;
    expect(producedBy != null && producedBy['tracked'] == true, isTrue,
        reason: 'kanıtı yazan script bu ağaçta git-takipli değil — kanıt '
            'ORTAMDAN gelmiyor, güvenilemez (`producedBy`: $producedBy)');

    final Map<String, dynamic>? claimedSha =
        w['inputsSha256'] as Map<String, dynamic>?;
    expect(claimedSha, isNotNull,
        reason: 'kanıt `inputsSha256` taşımıyor — hangi kod durumunun '
            'ölçüldüğü bilinmiyor');

    // 2) GÜNCELLİK — her girdi AYRI hash'lenir (BİRLEŞİK hash değil):
    // hangi dosyanın bayatladığı İSİMLE görünsün, ürünün hatası kapının
    // hatasından ayrılabilsin (koordinatör hükmü, L-277 revizyonu #1).
    //
    // Üçüncü hâl (M-F-444 deseni): kanıt bir dosya listeliyor ama o dosya
    // bu ağaçta YOK (yeniden adlandırma/silme) — sessiz geçme, opak kırmızı
    // da değil, İSİMLE söyle.
    final List<String> unverifiable = <String>[];
    final List<String> stale = <String>[];
    for (final String path in _inputPaths) {
      if (!File(path).existsSync()) {
        unverifiable.add(path);
        continue;
      }
      final String claimed = claimedSha![path] as String? ?? '';
      final String actual = _sha256OfFile(path);
      if (claimed != actual) stale.add(path);
    }
    expect(unverifiable, isEmpty,
        reason: '`inputsSha256` şu dosyaları listeliyor ama ağaçta YOK — '
            'kanıt bu ağaçta DOĞRULANAMIYOR:\n  - '
            '${unverifiable.join("\n  - ")}');
    expect(stale, isEmpty,
        reason: 'kanıt BAYAT — şu dosyalar ölçüldüğünden beri DEĞİŞMİŞ '
            '(hash uyuşmuyor):\n  - ${stale.join("\n  - ")}\n\nÖlçüm bu kod '
            'durumunu KANITLAMIYOR; yeniden koşulmalı.');

    // Kanıt, bu testin BİLMEDİĞİ bir girdi listeliyorsa da adı geçsin —
    // üretici/doğrulayıcı listeleri ayrışmış demektir, sessiz kaçmasın.
    final Set<String> claimedPaths = claimedSha!.keys.toSet();
    final Set<String> extra = claimedPaths.difference(_inputPaths.toSet());
    expect(extra, isEmpty,
        reason: 'kanıt bu testin BİLMEDİĞİ girdi(ler) listeliyor: '
            '${extra.join(", ")} — `_inputPaths` güncellenmeli, yoksa bu '
            'dosyalardaki değişiklik SESSİZCE kaçar');

    // 3) HÜKÜM — kanıt zinciri sağlam VE güncel. Şimdi üreticinin KENDİ
    // kabul-hükmünü OKU, yeniden hesaplama YOK (`readers_of()` ilkesi: bu
    // kapı kendi kendini ölçen taraf OLAMAZ).
    final dynamic passes = w['passesOwnCriterion'];
    expect(passes, isNotNull,
        reason: 'kanıt `passesOwnCriterion` taşımıyor');
    if (passes != true) {
      // Bu İKİ ayrı arıza: "kanıt yok" (yukarıda ele alındı) ile "kanıt VAR
      // ve GEÇMEDİĞİNİ söylüyor" AYNI kırmızıya çökerse bir sonraki oturum
      // yanlış yeri arar (koordinatör hükmü, L-277 revizyonu #2).
      fail('Kanıt VAR ve GÜNCEL ama üretici kendi kabul ölçütünü '
          'GEÇMEDİĞİNİ söylüyor (`passesOwnCriterion`: $passes). Bu "kanıt '
          'yok" arızası DEĞİL — "kanıt var ve hayır diyor" arızası. Bayrak '
          '`true` olamaz.\n  ölçüt: ${w['acceptanceCriterion']}\n  '
          'ölçülen: ${w['measured']}');
    }

    // 4) GERÇEK-KOŞUM İMZASI — ham kare-dökümünün hash'i, elle yazılan bir
    // JSON'da bedava üretilemeyecek katman.
    expect(w['dartAnglesSha256'], isA<String>(),
        reason: 'kanıt ham kare-dökümünün hash\'ini taşımıyor — gerçek bir '
            'hasat koşumundan geldiği doğrulanamıyor');
    expect((w['dartAnglesSha256'] as String).length, 64,
        reason: '`dartAnglesSha256` SHA-256 hex olmalı (64 karakter)');
  });

  test('bayrağın DEĞERİ tek kaynakta ve yüzeye SIZMIYOR', () {
    // Bayrak bir mühendislik olgusu; kullanıcı yüzeyinde karşılığı
    // "referans-derecesi sunulamaz" davranışıdır, bayrağın kendisi değil.
    for (final FileSystemEntity f
        in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      expect(File(f.path).readAsStringSync(),
          isNot(contains('kBridgeIsReferenceEquivalent')),
          reason: '${f.path}: mühendislik bayrağı kabuk katmanına sızmış — '
              'yüzey DAVRANIŞI taşır, bayrağı değil');
    }
  });
}
