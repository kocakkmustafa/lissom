import 'package:flutter/material.dart';

import 'lissom_theme.dart';
import 'locale_text.dart';

enum _Pose { oneLeg, halfPlough, lotus, frog, uprightFrog, fish, seated }

class _Panel {
  const _Panel(this.pose, this.en, this.tr, this.labelsEn, this.labelsTr);
  final _Pose pose;
  final String en, tr;
  final List<String> labelsEn, labelsTr;
}

const _panels = <String, List<_Panel>>{
  'h54': <_Panel>[
    _Panel(
      _Pose.oneLeg,
      'One-leg preparation',
      'Tek bacak hazırlığı',
      <String>[
        'One bent knee raised; the other foot stays grounded with its knee bent.',
        'Head and shoulders remain on the floor.',
      ],
      <String>[
        'Bir bükülü diz yukarıda; öteki ayak yerde, dizi bükülü kalır.',
        'Baş ve omuzlar yerde kalır.',
      ],
    ),
    _Panel(
      _Pose.halfPlough,
      'Ardha Halasana: recognition only',
      'Ardha Halasana: yalnız tanıma',
      <String>[
        'Both legs above the hips; no legs behind the head.',
        'Head, shoulders and hips remain on the floor.',
      ],
      <String>[
        'İki bacak kalçanın üstünde; başın arkasına geçmez.',
        'Baş, omuzlar ve kalça yerde kalır.',
      ],
    ),
  ],
  'h55': <_Panel>[
    _Panel(
      _Pose.lotus,
      'Padmasana: crossed-leg shape',
      'Padmasana: çapraz bacak biçimi',
      <String>[
        'Feet rest on opposite thighs in the named shape.',
        'A comfortable simple seat is a different option; never force the knees.',
      ],
      <String>[
        'Bu adlandırılmış biçimde ayaklar karşı uylukların üzerindedir.',
        'Rahat sade oturuş ayrı bir seçenektir; dizleri zorlama.',
      ],
    ),
    _Panel(
      _Pose.frog,
      'Mandukasana: kneeling shape',
      'Mandukasana: diz üstü biçim',
      <String>[
        'Kneeling base; torso inclines forward.',
        'Hands are near the abdomen in this reference tradition.',
      ],
      <String>[
        'Diz üstü taban; gövde öne eğimli.',
        'Bu kaynak geleneğinde eller karın yakınındadır.',
      ],
    ),
    _Panel(
      _Pose.uprightFrog,
      'Uttana Mandukasana: upright shape',
      'Uttana Mandukasana: dik biçim',
      <String>[
        'Knees apart, big toes together; seated kneeling base.',
        'Folded arms behind the head; torso remains upright.',
      ],
      <String>[
        'Dizler ayrı, ayak başparmakları birlikte; diz üstü oturuş tabanı.',
        'Kollar başın arkasında katlı; gövde dik kalır.',
      ],
    ),
  ],
  'h56': <_Panel>[
    _Panel(
      _Pose.fish,
      'Saral Matsyasana: floor shape',
      'Saral Matsyasana: yerdeki biçim',
      <String>[
        'Raised chest and arched neck distinguish this floor shape.',
        'Elbows and the crown of the head contact the floor; this is not a loading guide.',
      ],
      <String>[
        'Yükselmiş göğüs ve kavisli boyun yerdeki bu biçimi ayırır.',
        'Dirsekler ve başın tepesi yere temas eder; bu bir yük verme yönergesi değildir.',
      ],
    ),
    _Panel(
      _Pose.seated,
      'Seated chest opening: separate option',
      'Oturarak göğüs açma: ayrı seçenek',
      <String>[
        'Head remains upright above the torso.',
        'Chair supports the seated base; this is not the floor Fish pose.',
      ],
      <String>[
        'Baş gövdenin üzerinde dik kalır.',
        'Sandalye oturuş tabanını destekler; bu, yerdeki Balık duruşu değildir.',
      ],
    ),
  ],
};

/// Original conceptual vectors, not an anatomical measurement or a pose score.
class HathaKnowledgeDiagrams extends StatelessWidget {
  const HathaKnowledgeDiagrams({required this.lessonId, super.key});
  final String lessonId;
  static bool supports(String id) => _panels.containsKey(id);

  @override
  Widget build(BuildContext context) {
    final panels = _panels[lessonId];
    if (panels == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final tr = Localizations.localeOf(context).languageCode == 'tr';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LissomCard(
        key: Key('hatha-diagrams-$lessonId'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              localeText(context, 'Study the shapes', 'Biçimleri incele'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              localeText(
                context,
                'Knowledge only. Do not copy these poses. Original stylized schematics show names and contact points, not anatomical measurements, personal suitability or safety approval. Entry, support and exit need qualified instruction.',
                'Yalnız bilgi için. Bu duruşları taklit etme. Özgün stilize şemalar adları ve temas noktalarını gösterir; anatomik ölçüm, kişisel uygunluk veya güvenlik onayı değildir. Giriş, destek ve çıkış nitelikli eğitim gerektirir.',
              ),
              key: Key('hatha-diagrams-warning-$lessonId'),
              style: theme.textTheme.bodyMedium,
            ),
            for (int i = 0; i < panels.length; i++) ...<Widget>[
              const SizedBox(height: 18),
              Text(
                tr ? panels[i].tr : panels[i].en,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ExcludeSemantics(
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _PosePainter(
                      panels[i].pose,
                      theme.textTheme.bodyMedium!,
                    ),
                  ),
                ),
              ),
              for (int j = 0; j < panels[i].labelsEn.length; j++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${j + 1}. ${tr ? panels[i].labelsTr[j] : panels[i].labelsEn[j]}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PosePainter extends CustomPainter {
  const _PosePainter(this.pose, this.labelStyle);
  final _Pose pose;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 180);
    final body = Paint()
      ..color = LissomColors.ink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), body);
    void head(double x, double y) => canvas.drawCircle(Offset(x, y), 12, body);
    void mark(int number, double x, double y) {
      canvas.drawCircle(Offset(x, y), 11, Paint()..color = LissomColors.ink);
      final text = TextPainter(
        text: TextSpan(
          text: '$number',
          style: labelStyle.copyWith(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - text.width / 2, y - text.height / 2));
    }

    line(20, 158, 280, 158);
    switch (pose) {
      case _Pose.oneLeg:
      case _Pose.halfPlough:
        head(45, 144);
        line(59, 151, 150, 151);
        line(85, 150, 129, 156);
        if (pose == _Pose.oneLeg) {
          line(150, 151, 150, 93);
          line(150, 93, 191, 106);
          line(191, 106, 201, 106);
          line(158, 151, 211, 113);
          line(211, 113, 249, 153);
          line(249, 153, 263, 153);
        } else {
          line(150, 151, 150, 40);
          line(158, 151, 158, 40);
        }
        mark(1, 184, 60);
        mark(2, 88, 125);
      case _Pose.lotus:
        head(150, 35);
        line(150, 48, 150, 105);
        line(150, 62, 105, 110);
        line(150, 62, 195, 110);
        canvas.drawPath(
          Path()
            ..moveTo(150, 105)
            ..quadraticBezierTo(85, 110, 90, 145)
            ..quadraticBezierTo(140, 145, 185, 123),
          body,
        );
        canvas.drawPath(
          Path()
            ..moveTo(150, 105)
            ..quadraticBezierTo(215, 110, 210, 145)
            ..quadraticBezierTo(160, 145, 115, 123),
          body,
        );
        mark(1, 190, 112);
        mark(2, 77, 137);
      case _Pose.frog:
        line(112, 136, 205, 136);
        line(205, 136, 154, 153);
        line(154, 153, 226, 153);
        line(112, 136, 81, 99);
        line(81, 99, 110, 80);
        head(121, 72);
        line(83, 103, 123, 119);
        line(123, 119, 112, 132);
        mark(1, 222, 121);
        mark(2, 130, 113);
      case _Pose.uprightFrog:
        head(150, 46);
        line(150, 59, 150, 120);
        line(150, 120, 90, 139);
        line(90, 139, 142, 154);
        line(150, 120, 210, 139);
        line(210, 139, 158, 154);
        line(150, 74, 105, 59);
        line(105, 59, 133, 39);
        line(133, 39, 170, 76);
        line(150, 74, 195, 59);
        line(195, 59, 167, 39);
        line(167, 39, 130, 76);
        mark(1, 225, 140);
        mark(2, 214, 58);
      case _Pose.fish:
        head(47, 145);
        canvas.drawPath(
          Path()
            ..moveTo(59, 145)
            ..quadraticBezierTo(80, 85, 110, 103)
            ..quadraticBezierTo(133, 125, 163, 151),
          body,
        );
        line(163, 151, 266, 151);
        line(163, 146, 266, 146);
        line(94, 106, 115, 154);
        line(115, 154, 157, 151);
        mark(1, 100, 81);
        mark(2, 78, 143);
      case _Pose.seated:
        head(125, 38);
        line(125, 51, 135, 109);
        line(135, 109, 196, 109);
        line(196, 109, 196, 153);
        line(127, 66, 105, 97);
        line(105, 97, 133, 103);
        final chair = Paint()
          ..color = LissomColors.bodySecondary
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(
          Path()
            ..moveTo(103, 68)
            ..lineTo(103, 119)
            ..lineTo(171, 119)
            ..lineTo(171, 158)
            ..moveTo(108, 119)
            ..lineTo(108, 158),
          chair,
        );
        mark(1, 158, 39);
        mark(2, 86, 122);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PosePainter oldDelegate) =>
      oldDelegate.pose != pose || oldDelegate.labelStyle != labelStyle;
}
