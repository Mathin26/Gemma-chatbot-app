import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final bool isGenerating;
  final VoidCallback onSend;
  final VoidCallback onMicTap;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isListening,
    required this.isGenerating,
    required this.onSend,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!isGenerating) onSend();
                },
                decoration: InputDecoration(
                  hintText: isListening
                      ? 'Listening... speak now'
                      : 'Message Gemma...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onMicTap,
              icon: Icon(isListening ? Icons.mic : Icons.mic_none),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isGenerating ? null : onSend,
              icon: isGenerating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}