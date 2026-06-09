import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../services/gemma_service.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  bool _isGenerating = false;

  bool _isListening = false;

  bool _ttsEnabled = true;

  bool _modelLoaded = false;

  String _currentModel = "No model loaded";

  @override
  void initState() {
    super.initState();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
  setState(() {
    _modelLoaded =
        GemmaService.instance.isModelLoaded;

    _currentModel =
        GemmaService.instance.currentModelPath;
  });
}

  Future<void> _sendMessage() async {
    final prompt = _messageController.text.trim();

    if (prompt.isEmpty) {
      return;
    }

    setState(() {
      _messages.add({
        "role": "user",
        "message": prompt,
      });
    });

    _messageController.clear();

    _scrollToBottom();

    setState(() {
      _isGenerating = true;
    });

    try {
      //--------------------------------------------------
      // Replace this section with Gemma inference later
      //--------------------------------------------------

      
      String response =
    await GemmaService.instance
        .generateResponse(prompt);
      //--------------------------------------------------

      setState(() {
        _messages.add({
          "role": "assistant",
          "message": response,
        });
      });

      if (_ttsEnabled) {
  await _speak(response);
}
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "assistant",
          "message":
              "Error generating response.",
        });
      });
    }

    setState(() {
      _isGenerating = false;
    });

    _scrollToBottom();
  }

  Future<void> _startListening() async {
  setState(() {
    _isListening = true;
  });

  await SpeechService.instance.startListening(
    onResult: (text) {
      setState(() {
        _messageController.text = text;
      });
    },
  );
}

Future<void> _stopListening() async {
  await SpeechService.instance.stopListening();

  setState(() {
    _isListening = false;
  });
}

Future<void> _speak(String text) async {
  //----------------------------------------
  // TTS code will go here later
  //----------------------------------------
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Widget _buildMessage(
    Map<String, dynamic> message,
  ) {
    final bool isUser =
        message["role"] == "user";

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Colors.blue
              : Colors.grey.shade800,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Text(
          message["message"],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization:
                    TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      "Message Gemma...",
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      25,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            const SizedBox(width: 8),

IconButton(
  onPressed: () async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  },
  icon: Icon(
    _isListening
        ? Icons.mic
        : Icons.mic_none,
  ),
),

IconButton(
  onPressed:
      _isGenerating ? null : _sendMessage,
  icon: const Icon(
    Icons.send,
  ),
),
  icon: Icon(
    _isListening
        ? Icons.mic
        : Icons.mic_none,
  ),
),

IconButton(
  onPressed:
      _isGenerating ? null : _sendMessage,
  icon: const Icon(
    Icons.send,
  ),
),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelStatus() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black12,
      child: Row(
        children: [
          Icon(
            _modelLoaded
                ? Icons.check_circle
                : Icons.error_outline,
            color: _modelLoaded
                ? Colors.green
                : Colors.orange,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              _currentModel,
              overflow:
                  TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text("Gemma is thinking..."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Gemma Voice AI"),
        actions: [
          IconButton(
            icon: Icon(
              _ttsEnabled
                  ? Icons.volume_up
                  : Icons.volume_off,
            ),
            onPressed: () {
              setState(() {
                _ttsEnabled =
                    !_ttsEnabled;
              });
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/settings",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModelStatus(),

          Expanded(
            child: ListView.builder(
              controller:
                  _scrollController,
              itemCount:
                  _messages.length +
                      (_isGenerating
                          ? 1
                          : 0),
              itemBuilder:
                  (context, index) {
                if (_isGenerating &&
                    index ==
                        _messages.length) {
                  return _buildTypingIndicator();
                }

                return _buildMessage(
                  _messages[index],
                );
              },
            ),
          ),

          _buildInputArea(),
        ],
      ),
    );
  }
}