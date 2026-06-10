import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._();

  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();

  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
      onError: (SpeechRecognitionError error) {
        _isListening = false;
      },
    );

    return _isInitialized;
  }

  Future<bool> startListening({
    required void Function(String text) onResult,
    String? localeId,
  }) async {
    final available = await initialize();
    if (!available) return false;

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;

    await _speech.listen(
      localeId: localeId,
      partialResults: true,
      listenMode: ListenMode.dictation,
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
    );

    return true;
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _isListening = false;
  }

  Future<List<LocaleName>> getLocales() async {
    await initialize();
    return _speech.locales();
  }

  Future<LocaleName?> getSystemLocale() async {
    await initialize();
    return _speech.systemLocale();
  }

  void dispose() {
    _speech.cancel();
    _isListening = false;
  }
}