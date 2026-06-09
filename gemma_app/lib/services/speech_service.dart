import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  SpeechService._();

  static final SpeechService instance =
      SpeechService._();

  final SpeechToText _speech =
      SpeechToText();

  bool _isInitialized = false;

  bool _isListening = false;

  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized =
          await _speech.initialize(
        onStatus: (status) {
          print("Speech Status: $status");
        },
        onError: (error) {
          print("Speech Error: $error");
        },
      );

      return _isInitialized;
    } catch (e) {
      print(
        "Speech initialization failed: $e",
      );

      return false;
    }
  }

  Future<void> startListening({
    required Function(String text)
        onResult,
  }) async {
    try {
      final available =
          await initialize();

      if (!available) return;

      _isListening = true;

      await _speech.listen(
        listenMode:
            ListenMode.confirmation,
        partialResults: true,
        onResult: (result) {
          onResult(
            result.recognizedWords,
          );
        },
      );
    } catch (e) {
      print(
        "Start listening error: $e",
      );
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();

      _isListening = false;
    } catch (e) {
      print(
        "Stop listening error: $e",
      );
    }
  }

  Future<void> cancelListening() async {
    try {
      await _speech.cancel();

      _isListening = false;
    } catch (e) {
      print(
        "Cancel listening error: $e",
      );
    }
  }

  Future<bool> hasPermission() async {
    return await initialize();
  }

  Future<List<LocaleName>> getLocales() async {
  return await _speech.locales();
}

Future<LocaleName?> getSystemLocale() async {
  return await _speech.systemLocale();
}

  void dispose() {
    _speech.cancel();

    _isListening = false;
  }
}