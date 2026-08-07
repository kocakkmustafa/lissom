/// **profile** sekmesi — ayarlar · "How measurement works" · "What Lissom
/// doesn't do".
///
/// UI-BRIEF §2.2 bu sayfayı Profile'ın içine koyuyor. Önceki turda
/// "What Lissom doesn't do"a giriş, ana ekranın AppBar'ına İCAT EDİLMİŞ bir
/// ikon köprüsüydü (DESIGN-AHEAD-OF-CODE §2, isimli): tasarımın nav mimarisi
/// kodda yoktu, o yüzden geçici bir kapı açılmıştı. Sekmeler geldi, kapı
/// KAPANDI — sayfa artık ait olduğu yerde.
///
/// ⛔ **Burada bir "ayarlar" listesi UYDURULMADI.** Bildirim tercihi, birim
/// seçimi, hesap, dil — hiçbiri kodda yok. Kapatmayan bir anahtar koymak, ölü
/// buton sınıfının ta kendisidir.
library;

import 'package:flutter/material.dart';

import 'app_facts.dart';
import 'lissom_theme.dart';
import 'surfaces.dart';
import 'what_lissom_doesnt_do.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.facts, super.key});

  static const Key whyNotEntryKey = Key('profile.whyNotEntry');
  static const Key measurementWorksKey = Key('profile.howMeasurementWorks');
  static const Key noSettingsKey = Key('profile.noSettings');

  final AppFacts facts;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          const SectionHeading(
            'Profile',
            subtitle: 'What Lissom knows, what it measures, and where it stops.',
          ),
          const SizedBox(height: 20),

          // ── Giriş: sınırlar sayfası ────────────────────────────────────
          _EntryCard(
            key: whyNotEntryKey,
            title: "What Lissom doesn't do",
            subtitle: 'The decisions behind the edges of the product.',
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => WhatLissomDoesntDoScreen(
                  items: facts.ia.whyNot,
                  excluded: facts.battery.excluded,
                  poseTiers: facts.ia.poseTiers,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── How measurement works ──────────────────────────────────────
          Column(
            key: measurementWorksKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LissomEyebrow('How measurement works'),
              const SizedBox(height: 10),
              LissomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      MeasurementLimitsFootnote.limitsCopy,
                      style: t.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      MeasurementLimitsFootnote.accuracyStatement,
                      style: t.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    // Ölçülmüş ve doğrulanabilir: uygulamanın hesabı yok,
                    // sunucusu yok, yükleme yolu yok. Bu bir vaat değil bir
                    // yapı beyanı — kodda gönderilecek bir yer YOK.
                    Text(
                      'Your camera images and your readings stay on this '
                      'phone. Lissom has no account, no server of its own, '
                      'and nowhere to send them.',
                      style: t.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Ayarlar: YOK, ve nedeni yazılı ─────────────────────────────
          Column(
            key: noSettingsKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LissomEyebrow('Settings'),
              const SizedBox(height: 10),
              const NamedGapCard(
                title: 'Nothing to set',
                reason: 'There is no account, no sync and no reminder in this '
                    'build, so there is nothing here to switch on or off.',
                detail: 'We would rather leave the section empty than fill it '
                    'with switches that do nothing.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(LissomRadii.card),
      onTap: onTap,
      child: LissomCard(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: t.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(subtitle, style: t.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: LissomColors.bodySecondary),
          ],
        ),
      ),
    );
  }
}
