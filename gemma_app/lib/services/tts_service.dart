import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _initialized = true;
  }

  Future<void> setLanguage(String languageCode) async {
    await initialize();
    await _tts.setLanguage(languageCode);
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await initialize();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await initialize();
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}