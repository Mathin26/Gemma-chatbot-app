import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/gemma_service.dart';
import '../services/speech_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  bool _isGenerating = false;
  bool _isListening = false;
  bool _ttsEnabled = true;
  bool _modelLoaded = false;

  String _currentModel = 'No model loaded';
  String? _speechLocaleId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final storedMessages = await StorageService.instance.loadMessages();
    final ttsEnabled = await StorageService.instance.loadTtsEnabled();
    final savedModelPath = await StorageService.instance.loadSelectedModelPath();
    final savedLocale = await StorageService.instance.loadSpeechLocale();

    await TtsService.instance.initialize();
    await SpeechService.instance.initialize();

    if (!mounted) return;

    setState(() {
      _messages
        ..clear()
        ..addAll(storedMessages);
      _ttsEnabled = ttsEnabled;
      _speechLocaleId = savedLocale;
      _modelLoaded = GemmaService.instance.isModelLoaded;
      _currentModel = GemmaService.instance.currentModelPath.isNotEmpty
          ? GemmaService.instance.currentModelPath
          : savedModelPath.isNotEmpty
              ? savedModelPath
              : 'No model loaded';
    });

    _scrollToBottom(jump: true);
  }

  Future<void> _persistMessages() async {
    await StorageService.instance.saveMessages(_messages);
  }

  Future<void> _sendMessage() async {
    final prompt = _messageController.text.trim();
    if (prompt.isEmpty || _isGenerating) return;

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: prompt,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
    });

    _messageController.clear();
    await _persistMessages();
    _scrollToBottom();

    try {
      final response = await GemmaService.instance.generateResponse(prompt);

      final assistantMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        text: response,
        timestamp: DateTime.now(),
        isError: response.startsWith('Error:'),
      );

      if (!mounted) return;

      setState(() {
        _messages.add(assistantMessage);
      });

      await _persistMessages();

      if (_ttsEnabled && !assistantMessage.isError) {
        await TtsService.instance.speak(assistantMessage.text);
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        text: 'Error generating response: $e',
        timestamp: DateTime.now(),
        isError: true,
      );

      if (!mounted) return;

      setState(() {
        _messages.add(errorMessage);
      });

      await _persistMessages();
    } finally {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _modelLoaded = GemmaService.instance.isModelLoaded;
        _currentModel = GemmaService.instance.currentModelPath.isNotEmpty
            ? GemmaService.instance.currentModelPath
            : _currentModel;
      });

      _scrollToBottom();
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await SpeechService.instance.stopListening();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      return;
    }

    final started = await SpeechService.instance.startListening(
      localeId: _speechLocaleId,
      onResult: (text) {
        if (!mounted) return;
        setState(() {
          _messageController.text = text;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
        });
      },
    );

    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device.'),
        ),
      );
      return;
    }

    setState(() {
      _isListening = true;
    });
  }

  Future<void> _toggleTts() async {
    final next = !_ttsEnabled;
    setState(() {
      _ttsEnabled = next;
    });

    await StorageService.instance.saveTtsEnabled(next);

    if (!next) {
      await TtsService.instance.stop();
    }
  }

  Future<void> _openSettings() async {
    await Navigator.pushNamed(context, '/settings');
    await _loadInitialData();
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final position = _scrollController.position.maxScrollExtent;
      if (jump) {
        _scrollController.jumpTo(position);
      } else {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    SpeechService.instance.dispose();
    TtsService.instance.dispose();
    super.dispose();
  }

  Widget _buildModelStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black12
          : const Color(0xFFF1EEEE),
      child: Row(
        children: [
          Icon(
            _modelLoaded ? Icons.check_circle : Icons.error_outline,
            color: _modelLoaded ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentModel,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Load a supported local model in Settings and start chatting.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gemma Offline Chat',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _toggleTts,
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModelStatus(),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          ChatInput(
            controller: _messageController,
            isListening: _isListening,
            isGenerating: _isGenerating,
            onSend: _sendMessage,
            onMicTap: _toggleListening,
          ),
        ],
      ),
    );
  }
}