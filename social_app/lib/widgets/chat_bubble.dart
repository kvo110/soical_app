// lib/widgets/chat_bubble.dart
// A reusable message bubble for chat messages.

import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool mine;

  const ChatBubble({
    super.key,
    required this.text,
    required this.sender,
    required this.mine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine
              ? ThemeProvider.discordBlurple.withOpacity(0.75)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                color: mine ? Colors.white70 : Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
