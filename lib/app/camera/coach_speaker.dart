import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Says one short correction with the device's own speech engine. Text only.
abstract interface class CoachSpeaker {
  Future<void> speak(String text, Locale locale);
  Future<void> stop();
}

final class DeviceCoachSpeaker implements CoachSpeaker {
  DeviceCoachSpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  String? _language;
  bool _available = false;

  @override
  Future<void> speak(String text, Locale locale) async {
    try {
      final String tag = locale.toLanguageTag();
      if (_language != tag) {
        _language = tag;
        _available =
            await _tts.isLanguageAvailable(tag) == true ||
            await _tts.isLanguageAvailable(locale.languageCode) == true;
        if (_available) await _tts.setLanguage(tag);
      }
      // No voice for this language: the text stays on screen, nothing is
      // said in another language.
      if (_available) await _tts.speak(text);
    } on Object {
      // Speech is a convenience; the correction is always shown as text.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } on Object {
      // Nothing to stop.
    }
  }
}
