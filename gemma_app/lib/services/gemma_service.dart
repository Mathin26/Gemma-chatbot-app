import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  GemmaService._();

  static final GemmaService instance = GemmaService._();

  InferenceModel? _model;
  dynamic _chat;
  String _currentModelPath = '';
  bool _initialized = false;

  bool get isModelLoaded => _model != null;
  String get currentModelPath => _currentModelPath;

  Future<void> initialize() async {
    if (_initialized) return;

    await FlutterGemma.initialize();
    _initialized = true;
  }

  Future<bool> loadModel(String modelPath) async {
    await initialize();

    try {
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
      ).fromFile(modelPath).install();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.gpu,
      );

      _chat = await _model!.createChat(
        systemInstruction:
            'You are a helpful local mobile assistant. Respond clearly and naturally.',
      );

      _currentModelPath = modelPath;
      return true;
    } catch (_) {
      try {
        _model = await FlutterGemma.getActiveModel(
          maxTokens: 1024,
          preferredBackend: PreferredBackend.cpu,
        );

        _chat = await _model!.createChat(
          systemInstruction:
              'You are a helpful local mobile assistant. Respond clearly and naturally.',
        );

        _currentModelPath = modelPath;
        return true;
      } catch (e) {
        throw Exception('Failed to load model: $e');
      }
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
      return 'No model loaded. Please load a Gemma model from Settings.';
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

    try {
      _chat = await _model!.createChat(
        systemInstruction:
            'You are a helpful local mobile assistant. Respond clearly and naturally.',
      );
    } catch (e) {
      throw Exception('Failed to reset chat: $e');
    }
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