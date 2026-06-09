import 'package:flutter_gemma/flutter_gemma.dart';
class GemmaService {
  GemmaService._();

  static final GemmaService instance = GemmaService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      gemma.initialize();
      _initialized = true;
    } catch (e) {
      throw Exception(
        'Failed to initialize Gemma: $e',
      );
    }
  }

  bool get isModelLoaded {
    return gemma.isModelLoaded;
  }

  String get currentModelPath {
    return gemma.currentModelPath;
  }

  Future<bool> loadModel(String modelPath) async {
    try {
      await initialize();

      final success =
          await gemma.loadModel(modelPath);

      return success;
    } catch (e) {
      throw Exception(
        'Failed to load model: $e',
      );
    }
  }

  Future<void> unloadModel() async {
    try {
      await gemma.unloadModel();
    } catch (e) {
      throw Exception(
        'Failed to unload model: $e',
      );
    }
  }

  Future<String> generateResponse(
    String prompt,
  ) async {
    try {
      if (!gemma.isModelLoaded) {
        return "No model loaded. Please load a Gemma model first.";
      }

      final response =
          await gemma.generateResponse(
        prompt,
      );

      return response;
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> dispose() async {
    try {
      gemma.dispose();
      _initialized = false;
    } catch (_) {}
  }
}