import 'package:flutter/material.dart';

import 'lissom_theme.dart';
import 'locale_text.dart';

/// A previous practice record cannot stand in for preparation today.
/// This acknowledgment deliberately stays in memory and is never a form grade.
final class HathaSessionPreparation {
  HathaSessionPreparation({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  DateTime? _acknowledgedOn;

  bool get acknowledged {
    final DateTime? previous = _acknowledgedOn;
    final DateTime today = _now();
    return previous != null &&
        previous.year == today.year &&
        previous.month == today.month &&
        previous.day == today.day;
  }

  void acknowledge() => _acknowledgedOn = _now();

  void reset() => _acknowledgedOn = null;

  Duration untilNextDay() {
    final DateTime now = _now().toLocal();
    return DateTime(now.year, now.month, now.day + 1).difference(now);
  }

  /// Physical lesson routes need a fresh self-report. h05 teaches the warm-up
  /// itself; h55 is knowledge-only. h54/h56/h59 mix study with movement.
  static bool requiredFor(String lessonId) {
    if (const {'a04', 'a05', 'a06', 'a07', 'a09', 'a11'}.contains(lessonId)) {
      return true;
    }
    if (RegExp(r'^y0[2-8]$').hasMatch(lessonId)) return true;
    if (RegExp(r'^v(0[2-6]|0[89]|10)$').hasMatch(lessonId)) return true;
    if (RegExp(r'^c(0[1-9]|10|12)$').hasMatch(lessonId)) return true;
    if (!RegExp(r'^h\d\d$').hasMatch(lessonId)) return false;
    final int number = int.parse(lessonId.substring(1));
    return number == 3 ||
        number == 4 ||
        (number >= 7 && number <= 30) ||
        (number >= 34 && number <= 54) ||
        (number >= 56 && number <= 60);
  }
}

class HathaSessionPreparationCard extends StatelessWidget {
  const HathaSessionPreparationCard({
    required this.onPrepared,
    required this.onReadOnly,
    required this.onStop,
    this.chairOnly = false,
    this.vinyasaOnly = false,
    this.yinOnly = false,
    this.ashtangaOnly = false,
    super.key,
  });

  final VoidCallback onPrepared;
  final VoidCallback onReadOnly;
  final VoidCallback onStop;
  final bool chairOnly;
  final bool vinyasaOnly;
  final bool yinOnly;
  final bool ashtangaOnly;

  @override
  Widget build(BuildContext context) {
    final List<String> steps = <String>[
      localeText(
        context,
        ashtangaOnly
            ? 'Review a03: clear nonslip standing space, a verified solid wall for needed hand support and a familiar rest/exit. No floor transfer is required.'
            : yinOnly
            ? 'Use a level nonslip floor, low firm props and a familiar rest/exit. Set supports outside the pose; never move a loaded prop. Chair observation is not the floor skill.'
            : vinyasaOnly
            ? 'Use clear nonslip space and a verified solid wall, not glass, a door or moving furniture. Keep required hand support; use a stable wheelless rest chair.'
            : chairOnly
            ? 'Choose a solid chair without wheels or swivel that cannot rock or slide, with both feet flat and clear space. Keep needed support; the desk is not a weight-bearing prop.'
            : 'Clear space and choose a stable wall, chair or mat before moving.',
        ashtangaOnly
            ? 'a03’ü incele: açık kaymayan ayakta alan, gereken el desteği için sağlam sabit duvar ve tanıdık dinlenme/çıkış. Yere geçiş gerekmez.'
            : yinOnly
            ? 'Düz kaymayan zemin, alçak sağlam destek ve tanıdık dinlenme/çıkış seç. Desteği poz dışında kur; yüklü desteği taşıma. Sandalye gözlemi yer becerisi değildir.'
            : vinyasaOnly
            ? 'Açık kaymayan alan ve sağlam sabit duvar kullan; cam, kapı veya oynayan mobilya değil. Gereken el desteğini koru; sabit tekerleksiz dinlenme sandalyesi seç.'
            : chairOnly
            ? 'Sallanıp kaymayan, tekerleksiz/dönmeyen sağlam sandalye, yerde iki ayak ve açık alan seç. Gereken desteği koru; masaya ağırlık verme.'
            : 'Harekete geçmeden alanı boşalt; sağlam duvar, sandalye veya mat desteğini seç.',
      ),
      localeText(
        context,
        ashtangaOnly
            ? 'Use suitable familiar preparation before movement. A course tick is not readiness; a04/a05/a06/a07 teach the standing actions and returns used later.'
            : yinOnly
            ? 'Review y01/y02 setup and real Hatha foundations. Floor access must already be familiar and comfortable; reading h35 or ticking this card does not establish transfer ability or suitability.'
            : vinyasaOnly
            ? 'v01 teaches setup, v02 supported standing/breath and v03 shallow entry/return. Study real Hatha h01/h02/h03/h05/h11/h35 foundations if needed; do not use a completion tick as physical readiness.'
            : chairOnly
            ? 'Begin with supported arrival and ordinary breathing. Preparation is taught in c03; use only familiar comfortable actions before later movement lessons.'
            : 'Before this lesson, move joints gently within a comfortable range, starting small and unhurried.',
        ashtangaOnly
            ? 'Hareketten önce uygun tanıdık hazırlık kullan. Kurs işareti hazırlık değildir; a04/a05/a06/a07 sonraki yollardaki ayakta eylem ve dönüşleri öğretir.'
            : yinOnly
            ? 'y01/y02 kurulumu ve gerçek Hatha temellerini incele. Yer erişimi zaten tanıdık ve rahat olmalı; h35 okumak veya kartı işaretlemek transfer becerisi/uygunluk göstermez.'
            : vinyasaOnly
            ? 'v01 kurulum, v02 destekli duruş/nefes, v03 sığ giriş/dönüşü öğretir. Gerekiyorsa gerçek Hatha h01/h02/h03/h05/h11/h35 temellerini çalış; tamamlama işaretini fiziksel hazırlık sayma.'
            : chairOnly
            ? 'Destekli başlangıç ve doğal nefes kullan. Hazırlık c03’te öğretilir; sonraki hareket derslerinden önce yalnız tanıdık rahat eylemleri kullan.'
            : 'Bu dersten önce eklemleri rahat aralıkta, küçük ve acele etmeden hareket ettir.',
      ),
      localeText(
        context,
        ashtangaOnly
            ? 'Use small familiar standing adaptations, ordinary breathing and pauses. Traditional floor stations, jumps, breath control and inversions are not required or taught physical tasks here.'
            : yinOnly
            ? 'Choose only suitable familiar small forms; ordinary breath, no deepening or retention. Leave before the timer if needed; no symptomatic retest.'
            : 'Try an easier version before the lesson shape; rest or choose observation whenever needed.',
        ashtangaOnly
            ? 'Küçük tanıdık ayakta uyarlamalar, doğal nefes ve duraklama kullan. Geleneksel yer durakları, sıçrama, nefes kontrolü ve ters duruşlar burada zorunlu veya öğretilmiş fiziksel görev değildir.'
            : yinOnly
            ? 'Yalnız uygun tanıdık küçük biçim seç; normal nefes, derinleşme/tutma yok. Gerektiğinde süreden önce çık; belirtide tekrar yok.'
            : 'Ders biçiminden önce kolay seçeneği dene; gerektiğinde dinlen veya yalnız gözlemle.',
      ),
    ];
    return LissomCard(
      key: const Key('hatha.session.preparation'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LissomEyebrow(
            localeText(context, 'Prepare this session', 'Bu oturuma hazırlan'),
          ),
          const SizedBox(height: 10),
          for (int index = 0; index < steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${localizedInteger(context, index + 1)}. ${steps[index]}',
              ),
            ),
          Text(
            localeText(
              context,
              'Reading this card is not a warm-up. Stop for pain, dizziness or feeling unwell. This is your report, not a camera or medical check.',
              'Bu kartı okumak ısınmak değildir. Ağrı, baş dönmesi veya kötü hissetmede dur. Bu senin beyanındır; kamera veya sağlık kontrolü değildir.',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('hatha.session.prepared'),
            onPressed: onPrepared,
            child: Text(
              localeText(
                context,
                'I have prepared for this session',
                'Bu oturum için hazırlığımı yaptım',
              ),
            ),
          ),
          TextButton(
            key: const Key('hatha.session.readOnly'),
            onPressed: onReadOnly,
            child: Text(
              localeText(
                context,
                'Preview without physical practice',
                'Fiziksel çalışma yapmadan incele',
              ),
            ),
          ),
          TextButton(
            key: const Key('hatha.session.stop'),
            onPressed: onStop,
            child: Text(
              localeText(context, 'Stop and return', 'Dur ve geri dön'),
            ),
          ),
        ],
      ),
    );
  }
}
