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
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
      ).fromFile(modelPath).install();

      _model = await FlutterGemma.getActiveModel(
        maxTokens: 1024,
        preferredBackend: PreferredBackend.cpu,
      );

      _chat = await _model!.createChat(
        systemInstruction:
            'You are a helpful offline assistant. Use relevant memory when it is provided, but do not invent facts.',
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

  Future<String> generateResponse({
    required String prompt,
    String memoryContext = '',
  }) async {
    if (_model == null || _chat == null) {
      return 'No model loaded. Please load a supported model in Settings.';
    }

    try {
      final fullPrompt = memoryContext.isEmpty
          ? prompt
          : '$memoryContext\n\nCurrent user message:\n$prompt';

      await _chat.addQueryChunk(
        Message.text(
          text: fullPrompt,
          isUser: true,
        ),
      );

      final response = await _chat.generateChatResponse();
      return response?.toString().trim().isNotEmpty == true
          ? response.toString().trim()
          : 'I could not generate a response.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> resetChat() async {
    if (_model == null) return;
    _chat = await _model!.createChat(
      systemInstruction:
          'You are a helpful offline assistant. Use relevant memory when it is provided, but do not invent facts.',
    );
  }
}