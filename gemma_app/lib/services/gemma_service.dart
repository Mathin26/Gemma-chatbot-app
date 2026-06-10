import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  GemmaService._();

  static final GemmaService instance = GemmaService._();

  InferenceModel? _model;
  dynamic _chat;
  String _currentModelPath = '';

  bool get isModelLoaded => _model != null;
  String get currentModelPath => _currentModelPath;

  Future<bool> loadModel(String modelPath) async {
    try {
      final lowered = modelPath.toLowerCase();

      final modelType = ModelType.gemmaIt;

      await FlutterGemma.installModel(
        modelType: modelType,
      ).fromFile(modelPath).install();

      final preferredBackend = lowered.endsWith('.litertlm')
          ? PreferredBackend.gpu
          : PreferredBackend.cpu;

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: preferredBackend,
      );

      _chat = await _model!.createChat(
        systemInstruction:
            'You are a helpful offline mobile assistant. Respond clearly and naturally.',
      );

      _currentModelPath = modelPath;
      return true;
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  Future<void> unloadModel() async {
    try {
      await _model?.close();
    } catch (_) {}

    _model = null;
    _chat = null;
    _currentModelPath = '';
  }

  Future<String> generateResponse(String prompt) async {
    if (_model == null || _chat == null) {
      return 'No model loaded. Please select and load a supported model file in Settings.';
    }

    try {
      await _chat.addQueryChunk(
        Message.text(
          text: prompt,
          isUser: true,
        ),
      );

      final response = await _chat.generateChatResponse();

      if (response == null || response.toString().trim().isEmpty) {
        return 'I could not generate a response.';
      }

      return response.toString().trim();
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> resetChat() async {
    if (_model == null) return;

    _chat = await _model!.createChat(
      systemInstruction:
          'You are a helpful offline mobile assistant. Respond clearly and naturally.',
    );
  }

  Future<void> dispose() async {
    try {
      await _model?.close();
    } catch (_) {}

    _model = null;
    _chat = null;
    _currentModelPath = '';
  }
}