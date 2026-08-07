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
            // ⚠️ ÖNCE 'The decisions behind the edges of the product.'
            // diyordu — L-265'te düzelttiğim çerçevenin BAŞKA BİR YÜZEYDEKİ
            // kopyası: beş kalemin üçü karar DEĞİL. Kusuru bulduğun yüzeyde
            // düzeltmek, ürünün geri kalanında düzeltmek değildir (J-151).
            subtitle: 'What we chose not to do, and what we cannot do.',
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
                    // ⚠️ **SONUCU DOĞRU, GEREKÇESİ YANLIŞTI (L-242).** Eski
                    // cümle "Your camera images and your readings stay on
                    // this phone" diyordu — gizlilik iddiası sağlam (hesap
                    // yok, sunucu yok, gönderilecek yer yok) ama dayandığı
                    // mekanizma YOK: uygulama kamerayı hiç açmıyor, ortada
                    // görüntü de okuma da yok.
                    //
                    // Doğru sonucu yanlış gerekçeyle söylemek en zor
                    // yakalanan hatadır: kimse sonucu sorgulamaz. Ve gerekçe
                    // bir gün gerçekleştiğinde cümle aynen kalır, yalnız
                    // artık denetlenmemiş olur.
                    Text(
                      'Lissom has no account and no server of its own, so '
                      'there is nowhere for your data to go. Nothing is '
                      'captured by the camera in this build either — when it '
                      'is, it will stay on this phone for the same reason.',
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
              // ⚠️ Eskiden *"no account, no sync and no reminder **in this
              // build**"* yazıyordu — üçünü de bir DERLEME EKSİĞİ gibi
              // sunuyordu. Oysa hesap ve senkron **tasarım kararı**: gidecek
              // bir sunucu yok ve olmayacak. **Olmayan bir sınırı beyan
              // etmek dürüstlük değil gürültüdür (L-249)** — üstelik
              // "in this build" senkronun geleceğini ima ediyordu.
              //
              // Gerçek sınır olan tek kalem hatırlatıcı; o da isimli kalıyor.
              const NamedGapCard(
                title: 'Nothing to set',
                reason: 'Lissom has no account and nothing to sync — not '
                    'because they are missing, but because everything stays '
                    'on this phone. Reminders are not in this build.',
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
