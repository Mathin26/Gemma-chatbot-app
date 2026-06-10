import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final assistantBg =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);

    const userBg = Color(0xFF2F9BFF);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: BoxConstraints(
          maxWidth: isUser
              ? MediaQuery.of(context).size.width * 0.55
              : MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBg : assistantBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.5,
            color: isUser
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }
}