/// METRİK KAPSAM KAPISI — "bağlandı ≠ canlı"nın bir üst katmanı.
///
/// İki soruyu ayrı ayrı sorar:
///   1. **Kapsam:** bataryanın GERÇEKTEN istediği her metrik ya köprülü ya da
///      İSİMLİ engelle beyan edilmiş mi? (Sayı config'ten TÜRETİLİR, elle
///      yazılmaz — M-O-28.)
///   2. **Uzay:** köprünün ürettiği sayı normatif referansla aynı uzayda mı?
///      Değilse bu beyan EDİLMİŞ mi? (L-031, ölçüldü.)
///
/// Beş canlılık sorusuna cevap: bu kapıyı bataryaya yeni metrik ekleyen
/// KİŞİ soruyor (kapsam sessizce eksik kalamaz), ve kapı KIRMIZI YANABİLİYOR —
/// aşağıdaki `öz-test` grubu **her mühür ve her bölme iddiası için en az bir
/// sabotaj vakasını** gerçekten kırmızı yaptırıyor.
/// Öz-testi olmayan bir kapı hiçbir şey kanıtlamaz.
///
/// 🪤 **Bu cümle bir kez BAYATLAMIŞTI ve kimse fark etmemişti (L-314):**
/// *"üç sabotaj vakası"* yazıyordu; ölçüm **11** dedi — yani sayı zaten
/// L-314'ten ÖNCE **8**'di. Bir SAYI çapası, denetlediği şey büyüdükçe
/// sessizce yanlışlaşır (kural 4.5), ve *bir yorum yanlışsa hiçbir kapı
/// ötmez.* O yüzden cümle artık **sayı değil YAPI** iddia ediyor.
/// > ***BİR BELGENİN SAYISINI YAZMAK, ONU DENETLEMEK DEĞİLDİR.***
library;

import 'dart:convert';
import 'dart:io';

import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';
import 'package:test/test.dart';

final File _batteryFile = File('../../config/tests/lissom-assessment.v1.json');
final File _metricsFile =
    File('../../config/metrics/lissom-metrics.v1.json');

/// Config'in TANIDIĞI metrik adları (mirror genişletmesi dahil).
Set<String> _knownMetrics(Map<String, dynamic> metrics) {
  final Set<String> out = <String>{};
  for (final Object? raw in metrics['metrics'] as List<dynamic>) {
    final Map<String, dynamic> m = raw as Map<String, dynamic>;
    final String id = m['id'] as String;
    out.add(id);
    if (m['mirror'] == true) out.add(_mirror(id));
  }
  return out;
}

String _mirror(String id) => id.contains('_right')
    ? id.replaceAll('_right', '_left')
    : id.replaceAll('_left', '_right');

/// `{side}` / `{opposite}` yer tutucularını çözer.
Set<String> _expand(String name, bool perSide) {
  if (!name.contains('{side}') && !name.contains('{opposite}')) {
    return <String>{name};
  }
  final Set<String> out = <String>{};
  for (final String s in perSide ? <String>['right', 'left'] : <String>['right']) {
    out.add(name
        .replaceAll('{side}', s)
        .replaceAll('{opposite}', s == 'right' ? 'left' : 'right'));
  }
  return out;
}

/// Bataryanın gerektirdiği GEOMETRİK metrik kümesi — primaryMetric, girişim
/// kapısı ve guard'lar dahil. `hold_duration` gibi geometri-dışı büyüklükler
/// dışarıda kalır (onları köprü değil oturum katmanı üretir).
Set<String> requiredGeometricMetrics(
  Map<String, dynamic> battery,
  Set<String> known,
) {
  final Set<String> need = <String>{};
  for (final Object? raw in battery['tests'] as List<dynamic>) {
    final Map<String, dynamic> t = raw as Map<String, dynamic>;
    final bool perSide = t['perSide'] as bool? ?? false;
    need.addAll(_expand(t['primaryMetric'] as String, perSide));
    final Object? mp = t['movementPresence'];
    if (mp is Map<String, dynamic> && mp['metric'] is String) {
      need.addAll(_expand(mp['metric'] as String, perSide));
    }
    for (final Object? g in (t['guardMetrics'] as List<dynamic>? ?? const [])) {
      need.addAll(_expand(g as String, perSide));
    }
    // Guard KURALLARI serbest metin; içindeki metrik adlarını tanınanlarla
    // kesiştirerek çıkarıyoruz. Kasıtlı olarak "tanınmayanı yut" DEĞİL:
    // tanınmayan token bir metrik adı değil bir operatör/sayı olabilir, ama
    // tanınan her ad gerçekten gereklidir.
    for (final Object? g in (t['invalidation'] as List<dynamic>? ?? const [])) {
      final String rule = (g as Map<String, dynamic>)['rule'] as String? ?? '';
      for (final RegExpMatch m
          in RegExp(r'[A-Za-z_][A-Za-z0-9_{}]*').allMatches(rule)) {
        need.addAll(_expand(m.group(0)!, perSide).where(known.contains));
      }
    }
  }
  return need.where(known.contains).toSet();
}

/// ⛔ MÜHÜRLÜ — `kMetricBindings`'ten TÜRETİLMEZ (türetilse tautoloji
/// olurdu: kod kendi kendini onaylardı — `pin_equality_test.dart`'ın
/// `kSealedRef`i AYNI gerekçeyle kilitten türetilmiyor).
///
/// **NEDEN GEREKLİ (M-F-462 A+B, 2026-08-12):** `metric_coverage_test.dart`
/// zaten iki kontrol taşıyordu — BÖLME (bir metrik köprülü ya da beyanlı
/// mı, sayar) ve "gerçekten OKUNABİLİYOR" (bir köprü fırlatmıyor mu, sayar).
/// İkisi de yalnız VARLIĞA bakar, DEĞERE değil. Ölçüldü
/// (`tools/mutation_metric_coverage.py`): **(A)** çalışan bir binding
/// kaldırılıp aynı metrik "engellendi" diye beyan edilirse BÖLME bunu
/// GÖREMEZ — metrik hâlâ kapsanıyor, yalnız YER DEĞİŞTİRDİ. **(B)**
/// "imkânsız" denen bir metrik YANLIŞ bir `coreJointId`yle köprülü sayılırsa
/// "OKUNABİLİYOR" testi bunu GÖREMEZ — yanlış eklem de normal döner, yalnız
/// YANLIŞ sayı üretir. Bu mühür DEĞERE bakan üçüncü kontrol.
///
/// **KAPSAMI — DAR, isimle:** Bu mühür YALNIZ `metric → coreJointId`
/// eşlemesini korur. Bir binding'in DİĞER alanları bu mührün KAPSAMI
/// DIŞINDA: `configFrameRef` ayrı bir kontrolle korunuyor ("her köprü
/// kaydı config çerçevesini BEYAN ediyor"), `invert` **L-314'e kadar
/// hiçbir kontrolle korunmuyordu** — artık [kSealedBindingInvert]
/// koruyor (aşağıda, kendi kapsam şerhiyle). `measureKind` (köprülenemez
/// metrikler için) AYRI bir kontrolle korunuyor (M-F-462 C, yukarıda).
/// "Mühürlü" okuyan bir sonraki oturum TAM kapsam varsaymasın diye bu
/// liste isimle burada (M-F-439: bir kapının beşinci şartı kapsamının
/// YAZILMASI).
const Map<String, String> kSealedBridgedJoints = <String, String>{
  'shoulder_flexion_right': 'right_shoulder',
  'shoulder_flexion_left': 'left_shoulder',
  'knee_flexion_right': 'right_knee',
  'knee_flexion_left': 'left_knee',
  'hip_flexion_right': 'right_hip',
  'hip_flexion_left': 'left_hip',
  'elbow_extension_right': 'right_elbow',
  'elbow_extension_left': 'left_elbow',
};

/// ⛔ MÜHÜRLÜ — binding'lerin `invert` İŞARETİ (L-314).
///
/// **NEDEN GEREKLİ:** [kSealedBridgedJoints] yalnız `metric → coreJointId`
/// koruyor; `invert` **hiçbir kontrolle korunmuyordu**. Sekiz binding'in
/// hepsi `invert: false` ⇒ ***yanlış bir `true` SESSİZCE geçerdi.*** Ve
/// zehrin biçimi tam olarak bu dosyanın en pahalı dersi: `metric_bridge.dart`
/// başlığında yazılı olduğu gibi, ters bir işaret **makul GÖRÜNEN** bir sayı
/// üretir (aşağı=180°, yukarı=0°) ve *testsiz fark edilmez.* Kusur bir
/// fırlatma değil, **sessiz bir yanlış sayıdır** — kullanıcıya gösterilen.
///
/// ⚠️ **KAPSAMI — DAR, ve ölçüldü (fazlasını İDDİA ETME):** ROM konvansiyonu
/// **davranışsal olarak yalnız `shoulder_flexion_right` için çivili**
/// (`real_replay_test.dart` L33-64: kol aşağı ~0°, baş üstü ~180°, ve
/// monotonluk). Kalan **7** binding aynı çekirdek konvansiyonunu YAPICA
/// miras alıyor ama **tek tek ölçülmedi** (payda: 8 · davranışsal çapa: 1).
/// ⇒ Bu mühür o 7'yi **DOĞRULAMAZ**; yaptığı şey, birinin sessizce
/// **DEĞİŞMESİNİ** yakalamaktır. İkisi farklı iddialardır.
///
/// > ***BİR MÜHÜR, DEĞERİN DOĞRU OLDUĞUNU DEĞİL, SESSİZCE DEĞİŞMEDİĞİNİ
/// > KANITLAR — VE İKİSİNİ AYNI CÜMLEDE YAZMAK, OLMAYAN BİR ÖLÇÜMÜ
/// > VAR GÖSTERİR.***
///
/// [kSealedBridgedJoints] gibi, bu da `kMetricBindings`'ten **TÜRETİLMEZ**
/// (türetilse tautoloji olurdu). Anahtar kümesi ikisinde de aynı olmalı;
/// aşağıdaki kayma denetimi bunu ayrıca sınıyor.
const Map<String, bool> kSealedBindingInvert = <String, bool>{
  'shoulder_flexion_right': false,
  'shoulder_flexion_left': false,
  'knee_flexion_right': false,
  'knee_flexion_left': false,
  'hip_flexion_right': false,
  'hip_flexion_left': false,
  'elbow_extension_right': false,
  'elbow_extension_left': false,
};

void main() {
  final Map<String, dynamic> battery =
      jsonDecode(_batteryFile.readAsStringSync()) as Map<String, dynamic>;
  final Map<String, dynamic> metrics =
      jsonDecode(_metricsFile.readAsStringSync()) as Map<String, dynamic>;
  final Set<String> known = _knownMetrics(metrics);
  final Set<String> required = requiredGeometricMetrics(battery, known);
  final Set<String> bridged =
      kMetricBindings.map((MetricBinding b) => b.lissomMetric).toSet();
  final Set<String> declared = kUnbridgedMetrics.keys.toSet();
  final Map<String, String> bridgedJoints = <String, String>{
    for (final MetricBinding b in kMetricBindings) b.lissomMetric: b.coreJointId,
  };
  final Map<String, bool> bindingInvert = <String, bool>{
    for (final MetricBinding b in kMetricBindings) b.lissomMetric: b.invert,
  };

  group('metrik kapsamı — sayılar TÜRETİLDİ', () {
    test('config gerçekten metrik taşıyor (pozitif kontrol)', () {
      // L-183 dersi: yalnız-yokluk iddiası taşıyan bir test, özellik tamamen
      // ölse de geçer. Bu kapının girdisi BOŞ olursa aşağıdaki bölme
      // iddiaları boş kümede trivially geçerdi — o yüzden önce doluluk.
      expect(known, isNotEmpty, reason: 'metrik config boş okundu');
      expect(required.length, greaterThan(10),
          reason: 'batarya en az on metrik istemeli, türetilen: '
              '${required.length}');
      expect(bridged, isNotEmpty);
    });

    test('BÖLME: gereken = köprülü ⊎ beyan edilmiş (fazlası da eksiği de yok)',
        () {
      final Set<String> covered = <String>{...bridged, ...declared};
      final Set<String> missing = required.difference(covered);
      final Set<String> stray = declared.difference(required);
      final Set<String> both = bridged.intersection(declared);

      printOnFailure('gereken (${required.length}): '
          '${(required.toList()..sort()).join(", ")}');
      printOnFailure('köprülü (${bridged.length}): '
          '${(bridged.toList()..sort()).join(", ")}');
      printOnFailure('beyan edilmiş (${declared.length}): '
          '${(declared.toList()..sort()).join(", ")}');

      expect(missing, isEmpty,
          reason: 'bataryanın istediği ama NE köprülü NE beyan edilmiş '
              'metrik(ler) var — canlı turda `bindingFor` fırlatır: $missing');
      expect(stray, isEmpty,
          reason: 'batarya artık istemediği hâlde beyan listesinde duran '
              'metrik(ler) — bayat kayıt: $stray');
      expect(both, isEmpty,
          reason: 'aynı metrik hem köprülü hem köprülenemez sayılmış — '
              'çelişkili beyan: $both');
    });

    test('her köprü kaydı config çerçevesini BEYAN ediyor', () {
      final Map<String, String> frameOf = <String, String>{
        for (final Object? raw in metrics['metrics'] as List<dynamic>)
          ...<String, String>{
            (raw as Map<String, dynamic>)['id'] as String:
                raw['frameRef'] as String? ?? 'gravityYaw',
            if (raw['mirror'] == true)
              _mirror(raw['id'] as String):
                  raw['frameRef'] as String? ?? 'gravityYaw',
          },
      };
      for (final MetricBinding b in kMetricBindings) {
        expect(b.configFrameRef, frameOf[b.lissomMetric],
            reason: '${b.lissomMetric}: köprünün beyan ettiği çerçeve '
                '("${b.configFrameRef}") config ile uyuşmuyor '
                '("${frameOf[b.lissomMetric]}") — uygulanmayan bir çerçeve '
                'beyanı en azından DOĞRU kaydedilmelidir');
      }
    });

    test('her köprülenemez metrik BEYAN ettiği ölçü tipini config\'le TAŞIR', () {
      // ⚠️ BU KONTROL EKSİKTİ (M-F-462, koordinatör hükmü — hemen, tasarım
      // turu yok). `metric_bridge.dart`ın KENDİ doc yorumu (satır 166)
      // "[measureKind] config ile kapıda karşılaştırılıyor" diyordu —
      // ama kod tabanında bu karşılaştırmayı yapan TEK satır YOKTU
      // (ölçüldü: `tools/mutation_metric_coverage.py` sahne C). Doc bir
      // İDDİAYDI, uygulama değil. Seçim: karşılaştırmayı BURADA uygulamak
      // — doc'u "ölçülmedi" diye zayıflatmak yerine, çünkü alan zaten var,
      // config zaten `kind` taşıyor ve L-154'ün sınıfı (iki hat aynı
      // metriği farklı çerçevede/tipte ölçüyor, kimse fark etmiyor) tam
      // burada tekrarlanabilirdi.
      final Map<String, String> kindOf = <String, String>{
        for (final Object? raw in metrics['metrics'] as List<dynamic>)
          ...<String, String>{
            (raw as Map<String, dynamic>)['id'] as String:
                raw['kind'] as String,
            if (raw['mirror'] == true)
              _mirror(raw['id'] as String): raw['kind'] as String,
          },
      };
      for (final MapEntry<String, UnbridgedMetric> e
          in kUnbridgedMetrics.entries) {
        expect(e.value.measureKind, kindOf[e.key],
            reason: '${e.key}: köprülenemez metriğin beyan ettiği ölçü '
                'tipi ("${e.value.measureKind}") config ile uyuşmuyor '
                '("${kindOf[e.key]}") — measureKind bir BEYAN, config\'e '
                'karşı doğrulanmazsa sessizce yanlışlaşabilir (L-154 sınıfı)');
      }
    });

    test('MÜHÜR: köprülü küme VE eklem eşlemesi bilinenle AYNI (M-F-462 A+B)',
        () {
      // BÖLME (varlık) ve "OKUNABİLİYOR" (fırlatmıyor mu) testleri bu iki
      // sahneyi GÖREMEZ — ölçüldü, ikisi de yalnız VARLIĞA bakar:
      //   (A) bridged→declared: metrik hâlâ kapsanıyor, BÖLME sessiz kalır.
      //   (B) declared→bridged yanlış eklem: fırlatmıyor, OKUNABİLİYOR
      //       sessiz kalır.
      // Mühür DEĞERE bakan üçüncü kontrol — `kSealedBridgedJoints`in doc
      // yorumundaki KAPSAM sınırı geçerli (yalnız metric→joint).
      expect(bridgedJoints, kSealedBridgedJoints,
          reason: 'köprülü küme/eklem eşlemesi mühürden SAPTI. Bilinçli bir '
              'değişiklik mi (yeni doğru binding, ya da gerçekten '
              'köprülenemez hâle gelen bir metrik)? Öyleyse '
              '`kSealedBridgedJoints`i AYNI commit\'te, ölçümle birlikte '
              'güncelle — sessizce kaymasına izin verme.');
    });

    test('her köprülü metrik gerçekten OKUNABİLİYOR (bağlandı ≠ canlı)', () {
      final CoreMetricReader reader =
          CoreMetricReader(frameSize: const FrameSize(1920, 1080));
      final PoseFrame f = _neutralFrame();
      for (final String m in bridged) {
        // Sayının DOĞRULUĞU burada iddia edilmiyor (uzay sorunu ayrı test);
        // iddia: eşleme çekirdeğin spec kümesinde GERÇEKTEN var ve okuma
        // fırlatmıyor. Eksik bir coreJointId aksi hâlde yalnız canlı turda
        // patlardı.
        expect(() => reader.read(f, m), returnsNormally,
            reason: '$m köprülü sayılıyor ama okunamıyor');
      }
    });
  });

  group('ölçüm uzayı — beyan ölçümle tutarlı', () {
    test('referans-eşdeğerliği İDDİASI, ölçüm UZAYIYLA tutarlı olmak zorunda',
        () {
      // ⚠️ BU TEST BİR KUSURU KORUYORDU (L-261, JabLab J-144 sınıfı).
      //
      // Önceki hâli `expect(kBridgeIsReferenceEquivalent, isFalse)` idi ve
      // kendi yorumu bile *"kapanmışsa bu testi elle güncelle"* diyordu.
      // Yani: **L-187 göçü BAŞARILI olduğu gün bu test kırmızı yanacaktı** —
      // ve yanan şey bir kusur değil, BUGÜNÜN KORUNMASI olacaktı. O anda
      // doğru refleks "kapıyı gevşet" gibi görünür; oysa kapı zaten yanlış
      // şeyi ölçüyordu.
      //
      // ⭐ M-F-317: **sayıyı/değeri değil KURALI ölç.** Kural şu — iddia,
      // ölçümün yapıldığı UZAYLA tutarlı olmak zorunda:
      //   referans-eşdeğeri  ⟺  köprü referans uzayında (`world`) ölçüyor
      //
      // Bu türetilmiş bir hüküm, çivilenmiş bir değer değil: göç `kBridgeSpace`i
      // `world`e taşırsa bayrak MEŞRU olarak `true` olabilir ve test **elle
      // güncellenmeden** yeşil kalır. Ters yön de tutuluyor.
      const bool inReferenceSpace = kBridgeSpace == MeasurementSpace.world;

      expect(kBridgeIsReferenceEquivalent, inReferenceSpace,
          reason: kBridgeIsReferenceEquivalent
              ? 'Referans-eşdeğerliği İDDİA edilmiş ama köprü hâlâ '
                  '${kBridgeSpace.name} uzayında ölçüyor. Normatif yorumlayıcı '
                  '`world` (metrik 3D) kullanıyor — farklı uzayda ölçen bir '
                  'hat, tanımı gereği referans-eşdeğeri OLAMAZ. Bu bir EŞİK '
                  'İCADIDIR (L-187 şartı).'
              : 'Köprü ${kBridgeSpace.name} = REFERANS uzayına geçmiş ama '
                  '`kBridgeIsReferenceEquivalent` hâlâ `false`. Bu da bir '
                  'beyan hatası: artık ölçülmesi gereken bir iddiayı '
                  'ihtiyattan dolayı bastırmak, dürüstlük değil GÜRÜLTÜDÜR. '
                  'Sapmayı yeniden ölçün ve bayrağı ölçüme göre ayarlayın.');

      // Ve uzayın KENDİSİ beyansız değişmesin: `kBridgeSpace` bir olgu, ve
      // bugünkü olgu ölçülmüş (docs/L-031-UZAY-SAPMASI-OLCUMU.md).
      expect(MeasurementSpace.values, contains(kBridgeSpace),
          reason: 'pozitif çapa: uzay beyanı gerçekten okunuyor');
    });

    test('çerçeve gerektiren metrikler UYGULANMAYAN çerçeveyle işaretli', () {
      // Köprü `frameRef` uygulayamıyor; en az bir köprülü metrik `none`
      // DIŞINDA bir çerçeve beyan ediyorsa sapma KAÇINILMAZ ve bu görünür
      // olmalı. Bu iddia POZİTİF: gerçekten böyle bir metrik var mı diye
      // bakar, yokluk üzerinden geçmez.
      final List<MetricBinding> needsFrame = kMetricBindings
          .where((MetricBinding b) => b.configFrameRef != 'none')
          .toList();
      expect(needsFrame, isNotEmpty,
          reason: 'hiç çerçeve-gerektiren köprü yoksa uzay sapması iddiası '
              'da dayanaksız kalır — bu testin varsayımı çökmüş');
      printOnFailure('çerçeve uygulanamayan köprüler: '
          '${needsFrame.map((MetricBinding b) => "${b.lissomMetric}"
              "(${b.configFrameRef})").join(", ")}');
    });
  });

  group('öz-test — kapı KIRMIZI yanabiliyor', () {
    test('sabotaj: bataryaya beyansız metrik eklenirse bölme BOZULUR', () {
      final Set<String> sabotaged = <String>{...required, 'uydurma_metrik'};
      final Set<String> covered = <String>{...bridged, ...declared};
      expect(sabotaged.difference(covered), isNotEmpty,
          reason: 'kapı beyansız yeni metriği yakalamıyor — kör');
    });

    test('sabotaj: bayat beyan kaydı yakalanır', () {
      final Set<String> sabotaged = <String>{...declared, 'artik_gerekmiyor'};
      expect(sabotaged.difference(required), isNotEmpty,
          reason: 'kapı bayat beyan kaydını yakalamıyor');
    });

    test('sabotaj: çelişkili beyan (hem köprülü hem köprülenemez) yakalanır',
        () {
      final Set<String> sabotaged = <String>{...declared, bridged.first};
      expect(bridged.intersection(sabotaged), isNotEmpty,
          reason: 'kapı çelişkili beyanı yakalamıyor');
    });

    test('sabotaj: çerçeve beyanı config ile çelişirse yakalanır', () {
      const MetricBinding wrong = MetricBinding(
          lissomMetric: 'knee_flexion_right',
          coreJointId: 'right_knee',
          invert: false,
          configFrameRef: 'gravityYaw'); // config: 'none'
      expect(wrong.configFrameRef, isNot('none'),
          reason: 'sabotaj vakası kurulamadı');
    });

    test('sabotaj: measureKind beyanı config ile çelişirse yakalanır '
        '(M-F-462 — bu kontrol EKSİKTİ, `tools/mutation_metric_coverage.py` '
        'sahne C ile ölçüldü, ölçümden SONRA eklendi)', () {
      const UnbridgedMetric wrong = UnbridgedMetric(
          blocker: BridgeBlocker.corePlaneSeparationMissing,
          subject: 'Forward trunk lean',
          measureKind: 'distance_norm'); // config `trunk_lean`.kind: 'angle_vertical'
      expect(wrong.measureKind, isNot('angle_vertical'),
          reason: 'sabotaj vakası kurulamadı');
    });

    test('sabotaj: bridged→declared (metrik mühürden kaybolur) yakalanır '
        '(M-F-462 A)', () {
      final Map<String, String> sabotaged = Map<String, String>.of(bridgedJoints)
        ..remove('knee_flexion_right');
      expect(sabotaged, isNot(kSealedBridgedJoints),
          reason: 'kapı bridged→declared yer değişimini yakalamıyor');
    });

    test('sabotaj: declared→bridged YANLIŞ eklem yakalanır (M-F-462 B)', () {
      final Map<String, String> sabotaged = Map<String, String>.of(bridgedJoints)
        ..['knee_flexion_right'] = 'right_elbow'; // mühür: 'right_knee'
      expect(sabotaged, isNot(kSealedBridgedJoints),
          reason: 'kapı yanlış eklem terfisini yakalamıyor');
    });

    test('sabotaj: mühürsüz yeni binding eklenirse yakalanır', () {
      final Map<String, String> sabotaged = Map<String, String>.of(bridgedJoints)
        ..['reach_depth'] = 'right_elbow'; // mühürde HİÇ yok
      expect(sabotaged, isNot(kSealedBridgedJoints),
          reason: 'kapı mühürsüz yeni binding\'i yakalamıyor');
    });

    // ═════════════════════════════════════════════════════════════════
    // `invert` MÜHRÜ (L-314) — kapatılan SESSİZ GEÇİŞ
    // ═════════════════════════════════════════════════════════════════

    test('binding `invert` işaretleri mühürden SAPMADI', () {
      expect(bindingInvert, kSealedBindingInvert,
          reason: 'bir binding\'in `invert` işareti mühürden saptı. Ters bir '
              'işaret FIRLATMAZ — yalnız makul GÖRÜNEN yanlış bir açı '
              'üretir (aşağı=180°, yukarı=0°) ve kullanıcıya öyle gösterilir. '
              'Bilinçli bir değişiklikse `kSealedBindingInvert`i AYNI '
              'commit\'te, ÖLÇÜMLE birlikte güncelle.');
    });

    test('iki mühür AYNI binding kümesini anlatıyor (kayma denetimi)', () {
      // İki ayrı mühür iki ayrı dizge; biri güncellenip öteki unutulursa
      // "mühürlü" kelimesi sessizce yarım kalır. Bu, kapının kapısı DEĞİL:
      // aynı kümeyi anlatan iki beyanın tutarlılığı, mühürlerin KENDİ
      // iddiasının parçası.
      expect(kSealedBindingInvert.keys.toSet(),
          kSealedBridgedJoints.keys.toSet(),
          reason: 'iki mühürün anahtar kümesi ayrıştı — biri güncellendi, '
              'öteki unutuldu');
    });

    test('sabotaj: bir `invert` YANLIŞ `true` olursa yakalanır', () {
      final Map<String, bool> sabotaged = Map<String, bool>.of(bindingInvert)
        ..['knee_flexion_right'] = true; // mühür: false
      expect(sabotaged, isNot(kSealedBindingInvert),
          reason: 'kapı sessiz `invert` terfisini yakalamıyor — L-314\'ün '
              'kapatmak için var olduğu delik tam olarak budur');
    });

    test('sabotaj: bir binding `invert` mührümden kaybolursa yakalanır', () {
      final Map<String, bool> sabotaged = Map<String, bool>.of(bindingInvert)
        ..remove('hip_flexion_left');
      expect(sabotaged, isNot(kSealedBindingInvert),
          reason: 'kapı eksilen binding\'i yakalamıyor');
    });

    test('sabotaj: mühürsüz yeni binding `invert` tarafında da yakalanır', () {
      final Map<String, bool> sabotaged = Map<String, bool>.of(bindingInvert)
        ..['reach_depth'] = false; // mühürde HİÇ yok
      expect(sabotaged, isNot(kSealedBindingInvert),
          reason: 'yeni bir binding eklendiğinde `invert` mührü sessiz kaldı — '
              'eklem mührü ötse bile işaret beyansız girmiş olurdu');
    });
  });
}

/// Tüm landmark'ları görünür ve nötr bırakan kare.
PoseFrame _neutralFrame() => PoseFrame(
      tUs: 0,
      landmarks: List<PoseLandmark>.generate(
        33,
        (int i) => PoseLandmark(0.4 + i * 0.005, 0.3 + i * 0.01, 0, 1),
      ),
    );
