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
    super.key,
  });

  final VoidCallback onPrepared;
  final VoidCallback onReadOnly;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final List<String> steps = <String>[
      localeText(
        context,
        'Clear space and choose a stable wall, chair or mat before moving.',
        'Harekete geçmeden alanı boşalt; sağlam duvar, sandalye veya mat desteğini seç.',
      ),
      localeText(
        context,
        'Recall lesson h05: move joints gently within a comfortable range, starting small and unhurried.',
        'h05 dersini hatırla: eklemleri rahat aralıkta, küçük ve acele etmeden hareket ettir.',
      ),
      localeText(
        context,
        'Try an easier version before the lesson shape; rest or choose observation whenever needed.',
        'Ders biçiminden önce kolay seçeneği dene; gerektiğinde dinlen veya yalnız gözlemle.',
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
              child: Text('${index + 1}. ${steps[index]}'),
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
