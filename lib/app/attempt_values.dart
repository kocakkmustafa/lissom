/// **DENEME DEĞERİ — Lissom-sahipli yan defter** (D13, `F2`, `L-316`'nın
/// çözümü).
///
/// `AssessmentResult.value` (ölçülen açı) `recordFor()`de çekirdeğin
/// `SessionRecord`ına çevrilirken düşer — bu KASITLI: `session_store.dart`
/// kendi başlığında söylüyor, aile şeması "attempt-level provenance...
/// deliberately absent too: that is attempt-level data, this is a
/// session-level record." Çekirdek bu alanı APP'İN kendi yan deposunda
/// taşımasını bekliyor, biz onu hiç kurmamıştık.
///
/// Bu dosya `motion_core`un `JsonlSessionStore`ıyla AYNI güvenlik
/// özelliklerini taşır (atomik yazım, şema sürümü, bozuk-satır toleransı,
/// dizin/dosya ayrımı) — ama KOPYALANMADI, çünkü kayıt biçimi farklı ve
/// çekirdeğin private yardımcıları buradan erişilemez. Desen bilinçli tekrar.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'local_account_bridge.dart';
import 'local_write_guard.dart';
import 'local_owner.dart';

/// Bir denemenin ölçülen DEĞERİ — `AssessmentResult`in kalıcılaşan yarısı.
///
/// [lessonId] çekirdeğin `SessionRecord.lessonId`iyle AYNI biçimde kurulur
/// (`historyKeyFor`, `assessment_history.dart`) ve [completedAt] ÇAĞIRANDAN
/// AYNI damgayla gelir — iki depo bu ikisiyle EŞLEŞTİRİLİR, ayrı bir yabancı
/// anahtar şeması icat edilmedi.
final class AttemptValue {
  const AttemptValue({
    required this.lessonId,
    required this.completedAt,
    required this.value,
    required this.unit,
    required this.tier,
    required this.provenance,
    this.bandLabel,
    this.lowestBandFloor,
  });

  final String lessonId;
  final DateTime completedAt;
  final double value;
  final String unit;

  /// `ResultTier.name` — bandın var/yok/altında olduğunu YAZIM ANINDA
  /// damgalar (`AssessmentResult`in kendi dersi: sonradan türetilen sınıf
  /// config değişince sessizce anlam değiştirir).
  final String tier;

  final String? bandLabel;
  final double? lowestBandFloor;

  /// Model sürümü + config sürümü + kalibrasyon profili — İKİ değeri
  /// kıyaslamadan ÖNCE sorulması gereken soru ("aynı koşullarda mı
  /// ölçüldü?"). `ProgressScreen`in "No comparison is made here" kartının
  /// birinci gerekçesi bunun YOKLUĞUYDU; artık var, ama kıyas mantığını
  /// KURMAK bu dosyanın işi değil — taşımak bu dosyanın işi.
  final Map<String, String> provenance;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'lessonId': lessonId,
    'completedAt': completedAt.toUtc().toIso8601String(),
    'value': value,
    'unit': unit,
    'tier': tier,
    'provenance': provenance,
    if (bandLabel != null) 'bandLabel': bandLabel,
    if (lowestBandFloor != null) 'lowestBandFloor': lowestBandFloor,
  };

  factory AttemptValue.fromJson(Map<String, dynamic> j) => AttemptValue(
    lessonId: j['lessonId'] as String,
    completedAt: DateTime.parse(j['completedAt'] as String),
    value: (j['value'] as num).toDouble(),
    unit: j['unit'] as String,
    tier: j['tier'] as String,
    provenance: (j['provenance'] as Map).cast<String, String>(),
    bandLabel: j['bandLabel'] as String?,
    lowestBandFloor: (j['lowestBandFloor'] as num?)?.toDouble(),
  );
}

/// Deneme-değeri deposu — arayüz `SessionStore`unkiyle AYNI ÜÇ hükmü taşır
/// (H-21/M-F-228 dersi buraya da uygulanır): okunamayan kayıt SESSİZCE
/// yutulmaz, dizin-mi-dosya-mı ayrımı GEVŞETİLMEZ, sürümsüz satır atlanır.
abstract interface class AttemptValueStore {
  Future<void> append(AttemptValue value);

  /// Tek bir test+taraf için, YENİDEN ESKİYE. `SessionStore.recent`in
  /// birebir aynı sıra sözleşmesi — iki depo tutarsız sıralanırsa "son
  /// değer" ikisinde FARKLI bir kayda işaret edebilir.
  Future<List<AttemptValue>> forLesson(String lessonId);

  /// `SessionStore.unreadableRecords`ın birebir eşi — VARSAYILANSIZ: bir
  /// depo uygulaması bunu unutursa derleme HATASI verir, sessiz kayıp değil.
  Future<int> unreadableRecords();
}

final class JsonlAttemptValueStore implements AttemptValueStore {
  JsonlAttemptValueStore(this._file, {LissomLocalOwner? owner})
    : _writeGuard = LissomLocalWriteGuard(_file.parent.path, owner: owner);

  /// Bu yazıcının ürettiği satır şeması. H-21'in dersi: sürümsüz kayıt
  /// sessizce atlanır, sınıfını YAZ — burada sınıf en baştan `v: 1`.
  static const int schemaVersion = 1;

  final File _file;
  final LissomLocalWriteGuard _writeGuard;

  @override
  Future<void> append(AttemptValue value) =>
      _writeGuard.write(() => _append(value));

  Future<void> _append(AttemptValue value) async {
    final String line = jsonEncode(<String, dynamic>{
      'v': schemaVersion,
      ...value.toJson(),
    });

    final String existing = await _file.exists()
        ? await _file.readAsString()
        : '';
    final String next = existing.isEmpty ? '$line\n' : '$existing$line\n';

    // Atomik tmp+rename — `JsonlSessionStore`un aynı gerekçesi: yarım kalan
    // bir doğrudan-ekleme bir sonraki okumayı bozar, POSIX rename atomiktir.
    final File tmp = File('${_file.path}.tmp');
    _writeGuard.owner.checkActive();
    await tmp.parent.create(recursive: true);
    _writeGuard.owner.checkActive();
    await tmp.writeAsString(next, flush: true);
    _writeGuard.owner.checkActive();
    await tmp.rename(_file.path);
  }

  @override
  Future<List<AttemptValue>> forLesson(String lessonId) =>
      _writeGuard.read(() => _forLesson(lessonId));

  Future<List<AttemptValue>> _forLesson(String lessonId) async {
    final List<AttemptValue> all = (await _readAll()).values
        .where((AttemptValue v) => v.lessonId == lessonId)
        .toList();
    all.sort(
      (AttemptValue a, AttemptValue b) =>
          b.completedAt.compareTo(a.completedAt),
    );
    return all;
  }

  @override
  Future<int> unreadableRecords() =>
      _writeGuard.read(() async => (await _readAll()).unreadable);

  Future<({List<AttemptValue> values, int unreadable})> _readAll() async {
    // M-F-251 (Gravita) burada da geçerli: `File.exists()` bir DİZİN için
    // false döner. Yol var-ama-dosya-değilken "hiç yazılmamış" dalına
    // girmek, var olan ama okunamayan bir geçmişi `ok` diye okutur.
    final FileSystemEntityType pathType = await FileSystemEntity.type(
      _file.path,
    );
    if (pathType == FileSystemEntityType.notFound) {
      // Yok olan dosya BOŞ geçmiştir, KAYIP geçmiş değil — hiç yazılmadıysa
      // okunamayan da yok. İlk açılış `ok`/0 okumalı.
      return (values: <AttemptValue>[], unreadable: 0);
    }
    if (pathType != FileSystemEntityType.file) {
      throw FileSystemException(
        'deneme-değeri deposu yolu okunabilir bir dosya değil ($pathType) — '
        'bu ilk-açılış DEĞİL, açılamayan bir geçmiştir',
        _file.path,
      );
    }
    final List<AttemptValue> out = <AttemptValue>[];
    int skipped = 0;
    for (final String raw in (await _file.readAsString()).split('\n')) {
      final String line = raw.trim();
      if (line.isEmpty) continue;
      // Bozuk TEK satır tüm geçmişi silmez — ama SESSİZCE de değil: atlanan
      // sayılır ve okuyucuya (`unreadableRecords`) taşınır (M-F-228).
      try {
        final Map<String, dynamic> j = (jsonDecode(line) as Map)
            .cast<String, dynamic>();
        final int v = (j['v'] as num?)?.toInt() ?? 0;
        if (v == schemaVersion) {
          out.add(AttemptValue.fromJson(j));
        } else {
          // Bilinmeyen sürüm bu okuyucu için bir KAYIPTIR — satır sağlam
          // olabilir ama bu sürüm onu okuyamaz; kullanıcı için sonuç aynı.
          skipped++;
        }
      } on Object catch (_) {
        skipped++;
      }
    }
    return (values: out, unreadable: skipped);
  }
}

/// Gerçek cihazdaki depo. `path_provider` YALNIZ burada — `openSessionStore`
/// ile aynı desen, aynı gerekçe (`assessment_history.dart`): çekirdek depo
/// saf Dart kalır, testler geçici bir dosyayla aynı sınıfı koşturabilir.
Future<AttemptValueStore> openAttemptValueStore({
  LissomLocalScope scope = LissomLocalScope.guest,
}) async {
  scope.owner?.checkActive();
  final Directory dir = scope.owner?.supportDirectory ??
      await getApplicationSupportDirectory();
  scope.owner?.checkActive();
  return JsonlAttemptValueStore(
    scope.file(dir, LissomLocalFile.attemptValues),
    owner: scope.owner,
  );
}
