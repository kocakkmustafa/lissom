/// "What Lissom doesn't do" — bir özellik değil, bir duruş (design brief §2).
///
/// Metin design paneli çıktısından BİREBİR taşındı, uydurulmadı: beş kalem +
/// gerekçe, `Lissom.dc.html` "07 · What Lissom doesn't do" mockup'ı.
library;

import 'package:flutter/material.dart';

import 'lissom_theme.dart';

final class _Boundary {
  const _Boundary(this.title, this.reason);
  final String title;
  final String reason;
}

const List<_Boundary> _boundaries = <_Boundary>[
  _Boundary(
    'Programmes for children',
    'Our angle models were built and checked on adult bodies. '
        "We won't apply them to growing ones.",
  ),
  _Boundary(
    'Breath measurement',
    'A phone camera cannot see your breathing well enough to measure it. '
        "We won't estimate a number we can't take.",
  ),
  _Boundary(
    'Clinical screening',
    "We measure movement. We don't screen for conditions, and no number "
        'here means anything about your health.',
  ),
  _Boundary(
    'Hot yoga',
    "Heat changes your range while you're in it. We can't separate that "
        'from your own range, so we leave the format out.',
  ),
  _Boundary(
    'Hip rotation',
    "One camera can't isolate the joint from the pelvis reliably. "
        'Until it can, this test stays out of the battery.',
  ),
];

class WhatLissomDoesntDoScreen extends StatelessWidget {
  const WhatLissomDoesntDoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Scaffold(
      // Başlıksız — "Profile" yazmak, henüz var olmayan bir sekmeye ait
      // gibi göründüğü için bir önceki taslakta kaldırıldı (DESIGN-AHEAD-OF-
      // CODE.md "kod > tasarım"). Sayfa kendi serif başlığıyla tanıtılıyor.
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: <Widget>[
            Text("What Lissom doesn't do", style: t.textTheme.headlineLarge),
            const SizedBox(height: 10),
            Text(
              'We would rather be clear about the edges of the product than '
              'let you find them mid-session. Five things we deliberately '
              'leave out.',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            for (final _Boundary b in _boundaries)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: LissomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(b.title, style: t.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(b.reason, style: t.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
