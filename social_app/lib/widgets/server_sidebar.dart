// lib/widgets/server_sidebar.dart
import 'package:flutter/material.dart';

import '../screens/message_boards_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../theme_provider.dart';

class ServerSidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const ServerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final servers = [
      {"emoji": "💬", "label": "General"},
      {"emoji": "🎮", "label": "Gaming"},
      {"emoji": "📘", "label": "School"},
      {"emoji": "🖥️", "label": "Tech"},
      {"emoji": "🚗", "label": "Cars"},
    ];

    return Container(
      width: 72,
      color: ThemeProvider.discordDarker,
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Top "home" style icon (can route to boards)
          _serverIcon(
            emoji: "🏠",
            index: -1,
            isActive: selectedIndex == -1,
            onTap: () => onTap(-1),
          ),

          const SizedBox(height: 10),
          Container(
            height: 1,
            width: 36,
            color: Colors.white24,
          ),

          // Servers list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: servers.length,
              itemBuilder: (_, i) {
                final s = servers[i];
                return _serverIcon(
                  emoji: s["emoji"]!,
                  index: i,
                  isActive: selectedIndex == i,
                  onTap: () => onTap(i),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _serverIcon({
    required String emoji,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: isActive ? ThemeProvider.discordBlurple : Colors.white10,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.white24,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: ThemeProvider.discordBlurple.withOpacity(0.7),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
