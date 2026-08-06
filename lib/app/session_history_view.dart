/// Geçmiş katmanının **ÜÇ HÂLLİ** okuması — çekirdeğin şart koştuğu ayrım.
///
/// `SessionStore.unreadableRecords()` varsayılansız zorunlu bir soru soruyor
/// ve nedeni JabLab'da ÖLÇÜLDÜ (M-F-228): 50 satırın 40'ı bozukken özet "10
/// oturum" dedi ve tam güvenle söyledi — *"daha az yaptın"* yalanı. Yüzey bu
/// üç hâli AYIRT ETMEK ZORUNDA:
///
///   - **ok** — depo açıldı, okunamayan yok. Sayılar TAM.
///   - **partial(n)** — depo açıldı, n kayıt okunamadı. Sayılar bir ALT
///     SINIRDIR ve yüzey bunu SÖYLER.
///   - **unavailable** — depo hiç açılamadı. **Sayı GÖSTERİLMEZ.**
///     *"Hiç yapmadın" ≠ "bilmiyorum"* — ikisini karıştırmak, kullanıcının
///     yaptığı işi silmektir.
///
/// Bu tip app tarafında yaşıyor (çekirdeğin kendi notu: "The tri-state TYPE
/// stays app-side until the shell arbitration promotes a shared surface").
library;

import 'package:motion_core/motion_core.dart';

enum HistoryHealth { ok, partial, unavailable }

final class SessionHistoryView {
  const SessionHistoryView._({
    required this.health,
    required this.records,
    required this.unreadable,
    required this.failure,
  });

  const SessionHistoryView.ok(List<SessionRecord> records)
      : this._(
            health: HistoryHealth.ok,
            records: records,
            unreadable: 0,
            failure: null);

  const SessionHistoryView.partial(List<SessionRecord> records, int unreadable)
      : this._(
            health: HistoryHealth.partial,
            records: records,
            unreadable: unreadable,
            failure: null);

  /// [failure] KULLANICI diline çevrilmez ve YUTULMAZ: çıkmaz-sokak yasağı
  /// (M-F-267) sebebi görünür kılmayı şart koşuyor. Ham hata metni yüzeye
  /// SIZMAZ ama yüzey onu bir detay satırında gösterebilir — sessizlik yalan
  /// söyler, jargon yalnız çirkindir.
  const SessionHistoryView.unavailable(String failure)
      : this._(
            health: HistoryHealth.unavailable,
            records: const <SessionRecord>[],
            unreadable: 0,
            failure: failure);

  final HistoryHealth health;

  /// Yeniden ESKİYE sıralı. [HistoryHealth.unavailable] iken DAİMA boş —
  /// ve bu boşluk "hiç kayıt yok" DİYE OKUNAMAZ (bkz. [countsAreTrustworthy]).
  final List<SessionRecord> records;

  final int unreadable;
  final String? failure;

  /// Yüzey bu listeden bir SAYI türetebilir mi?
  ///
  /// `unavailable` iken **hayır** — o hâlde boş liste bir bilgi değil, bir
  /// bilgisizliktir.
  bool get countsAreTrustworthy => health != HistoryHealth.unavailable;

  /// Sayılar bir ALT SINIR mı (kayıp kayıt var mı)?
  bool get countsAreFloor => health == HistoryHealth.partial;

  /// **Yalnız `ok`/`partial` hâlinde anlamlı.** `unavailable` iken çağıran
  /// önce [countsAreTrustworthy]'e bakmalı; burada `false` dönmesi "kayıt yok"
  /// demek DEĞİLDİR.
  bool get hasRecords => records.isNotEmpty;

  SessionRecord? get mostRecent => records.isEmpty ? null : records.first;

  /// Depoyu üç hâlli okur. Açılış/okuma hatası FIRLATILMAZ — `unavailable`
  /// hâline çevrilir, çünkü bir istisna yüzeyi çıkmaz sokağa sokar.
  static Future<SessionHistoryView> read(
    Future<SessionStore> Function() open,
  ) async {
    try {
      final SessionStore store = await open();
      final List<SessionRecord> records = await store.recent();
      final int unreadable = await store.unreadableRecords();
      return unreadable == 0
          ? SessionHistoryView.ok(records)
          : SessionHistoryView.partial(records, unreadable);
    } on Object catch (e) {
      return SessionHistoryView.unavailable('$e');
    }
  }
}
