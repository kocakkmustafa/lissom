/// **home** sekmesi — IA config'in dört bölümü, hepsi DÜRÜST hâliyle.
///
/// Bölümlerin başlıkları ve sırası `config/ia/library.v1.json`'dan TÜRETİLİR;
/// bu dosya onları yeniden yazmaz. Her bölümün beslendiği kaynak (`source`)
/// dahili sözlüktür ve yüzeye ÇIKMAZ — görünen şey o kaynağın VAR OLUP
/// OLMADIĞININ sonucudur.
///
/// ## `retest_countdown` — hükmün varsaydığı artefakt YOK
///
/// §5.2 hükmü *"ana ekranda sakin kart: 'yeniden ölçüm: X gün'"* diyor. O X
/// bir SAYIDIR ve **hiçbir config'te tanımlı değil** — `lissom-assessment`,
/// `assessment-blocks`, `lissom-phases`, `library` dosyalarının hiçbirinde
/// yeniden-ölçüm aralığı yok (arandı, bulunamadı). Eşik icadı yasak olduğuna
/// göre (her eşik artefakttan türer) burada bir gün sayısı YAZILAMAZ.
///
/// Bu, hükmü ihlal etmiyor — hükmün RUHUNU uyguluyor: *"davet, geri sayım
/// değil."* Geri sayımın sayıya ihtiyacı var, davetin yok. Yüzey son ölçüm
/// TARİHİNİ (bir olgu) gösterir, bir vade GÖSTERMEZ, ve aralığın tanımsız
/// olduğunu söyler. **Artefakt gelirse kart bir vade kazanabilir; o karar
/// koordinatörde.**
///
/// ## Gecikme ASLA suçlanmaz
///
/// Bu ekranda "kaçırdın", "geciktin", "X gündür ölçmedin" YOKTUR. Ton
/// *"hazır olduğunda"*. Kullanıcının uzun süre ölçmemiş olması bir bilgi
/// değil bir yargıdır — ve yargı vermiyoruz.
library;

import 'package:flutter/material.dart';
import 'package:lissom_engine/lissom_engine.dart';
import 'package:motion_core/motion_core.dart';

import 'app_facts.dart';
import 'ia.dart';
import 'lissom_theme.dart';
import 'session_history_view.dart';
import 'surfaces.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.facts, required this.onOpenLibrary, super.key});

  static const Key todayKey = Key('home.today');
  static const Key retestKey = Key('home.retest_countdown');
  static const Key continueKey = Key('home.continue');
  static const Key quickStartKey = Key('home.quick_start');

  /// Bölüm id'si → o bölümün gövdesi. Config'te TANIMSIZ bir bölüm gelirse
  /// sessizce atlanmaz: [_unknownSection] onu ADIYLA gösterir. Sessiz atlama,
  /// config'e eklenen bir bölümün hiç görünmemesine ve kimsenin fark
  /// etmemesine yol açardı (L-181 sınıfı: okuyucusu olmayan alan).
  static const Map<String, Key> _keys = <String, Key>{
    'today': todayKey,
    'retest_countdown': retestKey,
    'continue': continueKey,
    'quick_start': quickStartKey,
  };

  final AppFacts facts;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          const DeclarationBanner(
            eyebrow: 'Where Lissom is today',
            body: 'The measurement engine and the twelve-test battery are '
                'live. The camera run is not wired to a screen in this build, '
                'so no session can be captured here — what you can do today '
                'is read exactly what each test measures, and what it cannot.',
          ),
          const SizedBox(height: 24),
          for (final HomeSection s in facts.ia.homeSections) ...<Widget>[
            _section(context, s),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _section(BuildContext context, HomeSection s) {
    final Key? k = _keys[s.id];
    if (k == null) return _unknownSection(context, s);
    return Column(
      key: k,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LissomEyebrow(s.title),
        const SizedBox(height: 10),
        switch (s.id) {
          'today' => _today(context),
          'retest_countdown' => _retest(context),
          'continue' => _continue(context),
          'quick_start' => _quickStart(context),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  /// Config'e yeni bir bölüm eklenip koda karşılığı yazılmadıysa: SESSİZLİK
  /// YOK. Kullanıcı "burada bir şey olacaktı" bilgisini görür, biz de
  /// eksikliği yüzeyde yakalarız.
  Widget _unknownSection(BuildContext context, HomeSection s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(s.title),
          const SizedBox(height: 10),
          NamedGapCard(
            title: s.title,
            reason: 'This section is declared in the app layout but nothing '
                'in the app fills it.',
          ),
        ],
      );

  /// `program_engine` — kodda YOK. Uydurulmuş bir "günün planı" göstermek,
  /// sahte veri yasağının doğrudan ihlali olurdu.
  Widget _today(BuildContext context) => const NamedGapCard(
        title: 'No routine is built for you',
        reason: 'A daily routine is meant to be built from your own '
            'measurements. The part of Lissom that builds it is not in this '
            'build, so there is nothing here that would be yours.',
        detail: 'We would rather show you an empty section than a routine we '
            'made up.',
      );

  /// **DAVET.** Geri sayım estetiği yok, vade yok, suçlama yok.
  Widget _retest(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final SessionHistoryView h = facts.history;

    // "Hiç yapmadın" ≠ "bilmiyorum". Depo açılmadıysa SAYI ve TARİH
    // GÖSTERİLMEZ — boş liste burada bir bilgi değil, bir bilgisizliktir.
    if (!h.countsAreTrustworthy) {
      return NamedGapCard(
        title: "We couldn't open your history",
        reason: 'Your measurements may be on this device — we just could not '
            'read the file, so we are not going to tell you a date either way.',
        detail: h.failure,
      );
    }

    final SessionRecord? last = h.mostRecent;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            last == null
                ? 'Measure when you are ready'
                : 'Measure again when you are ready',
            style: t.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            last == null
                ? 'Nothing has been measured on this device. There is no '
                    'right day to start.'
                : 'Last measurement on this device: '
                    '${_formatDate(last.completedAt)}.',
            style: t.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          // Vade YOK ve NEDENİ yazılı. Bir gün sayısı uydurmak, ölçmediğimiz
          // bir aralığı ölçmüş gibi göstermek olurdu.
          Text(
            'Lissom does not set a date for your next measurement. How long '
            'two measurements need to be apart to mean anything is something '
            'we have not established, so we are not going to schedule you.',
            style: t.textTheme.bodySmall,
          ),
          if (h.countsAreFloor) ...<Widget>[
            const SizedBox(height: 10),
            _floorNote(t, h.unreadable),
          ],
        ],
      ),
    );
  }

  Widget _continue(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final SessionHistoryView h = facts.history;

    if (!h.countsAreTrustworthy) {
      return const NamedGapCard(
        title: 'Unknown',
        reason: 'Your history did not open, so we cannot say whether anything '
            'is in progress.',
      );
    }
    final SessionRecord? last = h.mostRecent;
    if (last == null) {
      return const NamedGapCard(
        title: 'Nothing in progress',
        reason: 'Nothing has been measured on this device.',
      );
    }
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(facts.testNameFor(last.lessonId), style: t.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '${_formatDate(last.completedAt)} · '
            '${_recordClassText(last)}',
            style: t.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Bugün gerçekten ölçülebilen testler — TÜRETİLİR, elle yazılmaz.
  Widget _quickStart(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<TestLiveness> live = facts.live;
    return LissomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            live.isEmpty
                ? 'No test can be measured by camera in this build'
                : '${live.length} of ${facts.liveness.length} tests can be '
                    'measured by camera',
            style: t.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final TestLiveness x in live)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('· ${x.name}', style: t.textTheme.bodyMedium),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              // Bu düğme GERÇEKTEN bir yere gidiyor. Ölçüm başlatan bir düğme
              // KOYULMADI: canlı-tur ekranı yok, ve hiçbir şey yapmayan bir
              // "Start" düğmesi ölü-buton sınıfının ta kendisi olurdu.
              onPressed: onOpenLibrary,
              child: const Text('See what each test measures'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _floorNote(ThemeData t, int unreadable) => Text(
        '$unreadable stored record${unreadable == 1 ? '' : 's'} could not be '
        'read, so anything counted here is a floor, not a total.',
        style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.primary),
      );

  /// Kaydın SINIFI kullanıcı diliyle. `lessonClass` yazım anında damgalanır —
  /// sonradan TÜRETİLMEZ, çünkü sonradan hesaplanan bir sınıf geçmişi sessizce
  /// yeniden yorumlar (çekirdeğin kendi şartı).
  static String _recordClassText(SessionRecord r) => switch (r.lessonClass) {
        'scored' => 'measured and compared with a reference range',
        'coached' => 'measured, below the lowest reference line',
        'qualitative' => 'measured, this test has no numeric range by design',
        'measurementOnly' => 'measured, not compared with any reference',
        'notMeasured' => 'attempted, no reading could be taken',
        // Bilinmeyen sınıf UYDURULMAZ. Çekirdeğin en-az-yetki kuralı: şüphede
        // daha AZ iddia et.
        _ => 'recorded',
      };

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Mutlak tarih — **göreli süre ("3 gün önce") BİLEREK yok.** Göreli süre,
  /// bir gecikme duygusu üretmenin en sessiz yoludur ve §5.2 gecikmeyi
  /// suçlamayı yasaklıyor. Bir tarih olgudur; "3 gündür" bir ima taşır.
  static String _formatDate(DateTime d) {
    final DateTime l = d.toLocal();
    return '${l.day} ${_months[l.month - 1]} ${l.year}';
  }
}
