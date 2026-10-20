/// **profile** sekmesi — ayarlar · "How measurement works" · "What Lissom
/// doesn't do".
///
/// UI-BRIEF §2.2 bu sayfayı Profile'ın içine koyuyor. Önceki turda
/// "What Lissom doesn't do"a giriş, ana ekranın AppBar'ına İCAT EDİLMİŞ bir
/// ikon köprüsüydü (DESIGN-AHEAD-OF-CODE §2, isimli): tasarımın nav mimarisi
/// kodda yoktu, o yüzden geçici bir kapı açılmıştı. Sekmeler geldi, kapı
/// KAPANDI — sayfa artık ait olduğu yerde.
///
/// Installation language is a real persisted preference. Measurement settings
/// and reminders remain unavailable; their explanatory gap stays visible.
library;

import 'package:flutter/material.dart';
import 'package:motion_account/motion_account.dart'
    show motionPaidFeaturesAvailable;

import 'app_facts.dart';
import 'lissom_theme.dart';
import 'local_account_bridge.dart';
import 'locale_text.dart';
import 'lissom_locales.dart';
import 'lissom_localizations.dart';
import 'surfaces.dart';
import 'what_lissom_doesnt_do.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.facts,
    this.accountRouteBuilder,
    this.measurementAvailable = motionPaidFeaturesAvailable,
    super.key,
  });

  static const Key whyNotEntryKey = Key('profile.whyNotEntry');
  static const Key measurementWorksKey = Key('profile.howMeasurementWorks');
  static const Key noSettingsKey = Key('profile.noSettings');
  static const Key accountEntryKey = Key('profile.accountEntry');

  final AppFacts facts;
  final LissomAccountRouteBuilder? accountRouteBuilder;
  final bool measurementAvailable;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final LissomLocaleController? localeController =
        LissomLocaleScope.maybeOf(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LissomColors.screenBackground),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        children: <Widget>[
          SectionHeading(
            localeText(context, 'Profile', 'Profil'),
            subtitle: localeText(
              context,
              'What Lissom knows, what it measures, and where it stops.',
              'Lissom’un ölçtükleri ve ölçümün sınırları.',
            ),
          ),
          const SizedBox(height: 20),

          if (accountRouteBuilder != null) ...<Widget>[
            _EntryCard(
              key: accountEntryKey,
              title: localeText(context, 'Account', 'Hesap'),
              subtitle: localeText(
                context,
                'Open account options.',
                'Hesap seçeneklerini aç.',
              ),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext routeContext) =>
                      accountRouteBuilder!(routeContext, kLissomMotionAppId),
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],

          // ── Giriş: sınırlar sayfası ────────────────────────────────────
          _EntryCard(
            key: whyNotEntryKey,
            title: localeText(
              context,
              "What Lissom doesn't do",
              'Lissom neleri yapmaz?',
            ),
            // ⚠️ ÖNCE 'The decisions behind the edges of the product.'
            // diyordu — L-265'te düzelttiğim çerçevenin BAŞKA BİR YÜZEYDEKİ
            // kopyası: beş kalemin üçü karar DEĞİL. Kusuru bulduğun yüzeyde
            // düzeltmek, ürünün geri kalanında düzeltmek değildir (J-151).
            subtitle: localeText(
              context,
              'What we chose not to do, and what we cannot do.',
              'Mevcut özellikler ve ölçüm sınırları.',
            ),
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
              LissomEyebrow(
                localeText(
                  context,
                  'How measurement works',
                  'Ölçüm nasıl çalışır?',
                ),
              ),
              const SizedBox(height: 10),
              LissomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      MeasurementLimitsFootnote.localizedLimits(context),
                      style: t.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      MeasurementLimitsFootnote.localizedAccuracy(context),
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
                    // 🔴 **BAYAT YOKLUK CÜMLESİ — H-10 sınıfı (L-319).**
                    // Eski hâli: *"Nothing is captured by the camera in this
                    // build either — when it is, it will stay on this phone."*
                    // A1 `L-309`'da kapandı: kamera YAKALIYOR, ölçüm koşuyor,
                    // kayıt `sessions.jsonl`e yazılıyor. Cümle **yazıldığında
                    // doğruydu** ve yokluk bittiği gün bayatladı.
                    //
                    // ⚠️ **VE ÜSTÜNDEKİ YORUM BUNU ÖNCEDEN SÖYLEMİŞTİ:**
                    // *"gerekçe bir gün gerçekleştiğinde cümle aynen kalır,
                    // yalnız artık denetlenmemiş olur."* Kod kendi
                    // bayatlamasını **tahmin etti**, sonra bayatladı.
                    // > ***BİR RİSKİ YORUMA YAZMAK, ONU ÖNLEMEZ — ÖNLEYEN
                    // > ŞEY KAPIDIR*** (`stale_absence_claim_test.dart`).
                    Text(
                      measurementAvailable
                          ? '${CaptureUnavailableNote.localizedAvailability(context, measurementAvailable: true)} '
                                '${localeText(context, 'Subscription sales are closed in this release. Written yoga courses work '
                                    'without a camera. Practice records stay on this device and reflect your own reports. '
                                    'These records are not synced to your Motion account. '
                                    'Self-check answers are not saved. Written recall notes are discarded when you leave the page. '
                                    'Existing measurement records also remain on this device.', 'Bu sürümde abonelik satışı kapalıdır. Yazılı yoga kursları kamera olmadan çalışır. '
                                    'Çalışma kayıtları bu cihazda kalır ve kendi beyanını gösterir. Bu kayıtlar Motion hesabına eşitlenmez. Öz denetim yanıtları kaydedilmez. '
                                    'Yazılı hatırlama notları sayfadan çıkınca silinir. Önceki ölçüm kayıtları da bu cihazda kalır.')}'
                          : localeText(
                              context,
                              'Live camera measurements and subscription sales are '
                                  'closed in this release. Written yoga courses work '
                                  'without a camera. Practice records stay on this device and reflect your own reports. '
                                  'These records are not synced to your Motion account. '
                                  'Self-check answers are not saved. Written recall notes are discarded when you leave the page. '
                                  'Existing measurement records also remain on this device.',
                              'Bu sürümde canlı kamera ölçümleri ve abonelik satışı '
                                  'kapalıdır. Yazılı yoga kursları kamera olmadan çalışır. '
                                  'Çalışma kayıtları bu cihazda kalır ve kendi beyanını gösterir. Bu kayıtlar Motion hesabına eşitlenmez. Öz denetim yanıtları kaydedilmez. '
                                  'Yazılı hatırlama notları sayfadan çıkınca silinir. Önceki ölçüm kayıtları da bu cihazda kalır.',
                            ),
                      style: t.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          if (localeController != null) ...<Widget>[
            _LanguageCard(controller: localeController),
            const SizedBox(height: 22),
          ],
          // Measurement settings remain absent, with the reason visible.
          Column(
            key: noSettingsKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LissomEyebrow(localeText(context, 'Settings', 'Ayarlar')),
              const SizedBox(height: 10),
              // ⚠️ Eskiden *"no account, no sync and no reminder **in this
              // build**"* yazıyordu — üçünü de bir DERLEME EKSİĞİ gibi
              // sunuyordu. Oysa hesap ve senkron **tasarım kararı**: gidecek
              // bir sunucu yok ve olmayacak. **Olmayan bir sınırı beyan
              // etmek dürüstlük değil gürültüdür (L-249)** — üstelik
              // "in this build" senkronun geleceğini ima ediyordu.
              //
              // Gerçek sınır olan tek kalem hatırlatıcı; o da isimli kalıyor.
              NamedGapCard(
                title: localeText(
                  context,
                  'Other settings are unavailable',
                  'Diğer ayarlar bulunmuyor',
                ),
                reason: localeText(
                  context,
                  'Measurement preferences and reminders are not available '
                      'in this build. Lissom does not sync measurement records '
                      'to your Motion account.',
                  'Ölçüm tercihleri ve hatırlatıcılar bu sürümde bulunmuyor. '
                      'Lissom ölçüm kayıtlarını Motion hesabına eşitlemez.',
                ),
                detail: localeText(
                  context,
                  'Controls for unavailable features are not shown.',
                  'Sunulmayan özellikler için ayar gösterilmez.',
                ),
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
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left : Icons.chevron_right,
              color: LissomColors.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.controller});

  final LissomLocaleController controller;

  @override
  Widget build(BuildContext context) {
    final LissomLocalizations? catalog = LissomLocalizations.maybeOf(context);
    final String currentTag =
        canonicalLocaleTag(Localizations.localeOf(context));
    return LissomCard(
      key: const Key('profile.language'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(localeText(context, 'App language', 'Uygulama dili'),
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(localeText(
            context,
            'Language is saved on this installation and does not change your account or practice records.',
            'Dil bu kurulumda saklanır; hesabını veya çalışma kayıtlarını değiştirmez.',
          )),
          const SizedBox(height: 8),
          Text(localeText(
            context,
            'Text without an available translation is shown in English.',
            'Çevirisi bulunmayan metinler İngilizce gösterilir.',
          )),
          const SizedBox(height: 8),
          if (controller.readFailed)
            Text(localeText(
              context,
              'The saved language could not be read. The system language is being used. Choose a language to save a new preference.',
              'Kayıtlı dil okunamadı. Sistem dili kullanılıyor. Yeni tercih kaydetmek için bir dil seç.',
            ), key: const Key('profile.language.readFailure')),
          if (catalog != null && !catalog.catalogAvailable)
            Text(localeText(
              context,
              'This language catalog could not be loaded. Missing text is shown in English.',
              'Bu dilin kataloğu yüklenemedi. Eksik metinler İngilizce gösterilir.',
            ), key: const Key('profile.language.catalogFailure')),
          FilledButton.tonalIcon(
            key: const Key('profile.language.choose'),
            icon: const Icon(Icons.language),
            onPressed: !controller.isReady || controller.isSaving
                ? null : () => _choose(context),
            label: Text(controller.tag == null
                ? localeTemplate(context,
                    'System language ({language})', 'Sistem dili ({language})',
                    <String, Object>{'language': kLissomLanguageNames[currentTag]!})
                : kLissomLanguageNames[controller.tag]!),
          ),
        ],
      ),
    );
  }

  Future<void> _choose(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => AlertDialog(
        key: const Key('profile.language.dialog'),
        title: Text(localeText(context, 'App language', 'Uygulama dili')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (controller.writeFailed)
                  Text(localeText(
                    context,
                    'The language could not be saved. Your previous language is unchanged. Try again.',
                    'Dil kaydedilemedi. Önceki dilin değişmedi. Yeniden dene.',
                  ), key: const Key('profile.language.writeFailure')),
                _option(context, null,
                  localeText(context, 'Use system language', 'Sistem dilini kullan')),
                for (final MapEntry<String, String> language
                    in kLissomLanguageNames.entries)
                  _option(context, language.key, language.value),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: controller.isSaving ? null : () => Navigator.of(context).pop(),
            child: Text(localeText(context, 'Cancel', 'Vazgeç')),
          ),
        ],
      ),
    ),
  );

  Widget _option(BuildContext context, String? tag, String label) =>
      RadioListTile<String>(
        key: Key('profile.language.option.${tag ?? 'system'}'),
        value: tag ?? 'system',
        groupValue: controller.tag ?? 'system',
        title: Text(label),
        onChanged: controller.isSaving ? null : (String? _) async {
          final bool saved = await controller.select(tag);
          if (context.mounted && saved) Navigator.of(context).pop();
        },
      );
}
