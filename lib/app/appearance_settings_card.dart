// DRAFT ONLY. EN/TR source strings are listed in UI-TEXT-DELTA.json.
import 'package:flutter/material.dart';

import 'lissom_appearance.dart';
import 'lissom_theme.dart';
import 'locale_text.dart';

class AppearanceSettingsCard extends StatelessWidget {
  const AppearanceSettingsCard({required this.controller, super.key});
  final LissomAppearanceController controller;

  String _name(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => localeText(context, 'Use system appearance', 'Sistem görünümünü kullan'),
    ThemeMode.light => localeText(context, 'Light', 'Açık'),
    ThemeMode.dark => localeText(context, 'Dark', 'Koyu'),
  };

  String _status(BuildContext context) => controller.writePendingLong
      ? localeText(context,
          'Saving is taking longer than expected. Your previous appearance is still active. You can close this dialog.',
          'Kaydetme beklenenden uzun sürüyor. Önceki görünümün etkin. Bu pencereyi kapatabilirsin.')
      : localeText(context, 'Saving appearance…', 'Görünüm kaydediliyor…');

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) => LissomCard(
      key: const Key('profile.appearance'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(localeText(context, 'Appearance', 'Görünüm'),
          style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(localeText(context,
          'Appearance is saved on this installation. It does not change your account or practice records.',
          'Görünüm bu kurulumda saklanır; hesabını veya çalışma kayıtlarını değiştirmez.')),
        if (controller.readFailed) ...<Widget>[
          const SizedBox(height: 8),
          Text(localeText(context,
            'The saved appearance could not be read. The current appearance remains active. Retry reading it or choose a new preference.',
            'Kayıtlı görünüm okunamadı. Etkin görünüm korunuyor. Yeniden oku veya yeni tercih seç.'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            key: const Key('profile.appearance.readFailure')),
          TextButton(
            key: const Key('profile.appearance.retryRead'),
            onPressed: controller.isReading || controller.isSaving ? null : controller.retryRead,
            child: Text(localeText(context, 'Retry reading preference', 'Tercihi yeniden oku')),
          ),
        ],
        if (controller.isReading)
          Text(localeText(context, 'Reading appearance…', 'Görünüm okunuyor…'),
            key: const Key('profile.appearance.reading')),
        if (controller.isSaving)
          Text(_status(context), key: const Key('profile.appearance.saving')),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          key: const Key('profile.appearance.choose'),
          icon: const Icon(Icons.contrast),
          onPressed: !controller.isReady || controller.isSaving || controller.isReading
              ? null : () => _choose(context),
          label: Text(_name(context, controller.mode)),
        ),
      ]),
    ),
  );

  Future<void> _choose(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AnimatedBuilder(
      animation: controller,
      builder: (context, child) => AlertDialog(
        key: const Key('profile.appearance.dialog'),
        title: Text(localeText(context, 'Appearance', 'Görünüm')),
        content: SizedBox(width: double.maxFinite,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (controller.writeFailed)
                Semantics(liveRegion: true, child: Text(localeText(context,
                  'The appearance could not be saved. Your previous choice is unchanged. Try again.',
                  'Görünüm kaydedilemedi. Önceki tercihin değişmedi. Yeniden dene.'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  key: const Key('profile.appearance.writeFailure'))),
              if (controller.isSaving)
                Semantics(liveRegion: true, child: Text(_status(context),
                  key: const Key('profile.appearance.dialog.saving'))),
              RadioGroup<ThemeMode>(
                groupValue: controller.mode,
                onChanged: (next) async {
                  if (next == null || !controller.isReady || controller.isSaving || controller.isReading) { return; }
                  final saved = await controller.select(next);
                  if (saved && dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  for (final mode in ThemeMode.values)
                    LissomFocusFrame(child: RadioListTile<ThemeMode>(
                      key: Key('profile.appearance.option.${mode.name}'),
                      value: mode,
                      enabled: controller.isReady && !controller.isSaving && !controller.isReading,
                      title: Text(_name(context, mode)),
                    )),
                ]),
              ),
            ],
          )),
        ),
        actions: <Widget>[
          TextButton(
            key: const Key('profile.appearance.close'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localeText(context, 'Close', 'Kapat')),
          ),
        ],
      ),
    ),
  );
}
