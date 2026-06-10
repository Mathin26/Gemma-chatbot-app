import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  GemmaService._();

  static final GemmaService instance = GemmaService._();

  final FlutterGemma _gemma = FlutterGemma.gemma;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _gemma.initialize();
      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize Gemma: $e');
    }
  }

  bool get isModelLoaded {
    try {
      return _gemma.isModelLoaded;
    } catch (_) {
      return false;
    }
  }

  String get currentModelPath {
    try {
      return _gemma.currentModelPath;
    } catch (_) {
      return '';
    }
  }

  Future<bool> loadModel(String modelPath) async {
    await initialize();

    try {
      final loaded = await _gemma.loadModel(modelPath);
      return loaded;
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<void> unloadModel() async {
    try {
      await _gemma.unloadModel();
    } catch (e) {
      throw Exception('Failed to unload model: $e');
    }
  }

  Future<String> generateResponse(String prompt) async {
    try {
      if (!isModelLoaded) {
        return 'No model loaded. Please load a GGUF Gemma model from Settings.';
      }

      final response = await _gemma.generateResponse(prompt);
      if (response.trim().isEmpty) {
        return 'I could not generate a response for that input.';
      }

      return response.trim();
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> dispose() async {
    try {
      _gemma.dispose();
      _initialized = false;
    } catch (_) {}
  }
}