// lib/screens/message_boards_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../theme_provider.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MessageBoardsScreen extends StatefulWidget {
  const MessageBoardsScreen({super.key});

  @override
  State<MessageBoardsScreen> createState() => _MessageBoardsScreenState();
}

class _MessageBoardsScreenState extends State<MessageBoardsScreen> {
  int selectedServer = -1; // -1 = home

  final boards = [
    {"id": "general", "name": "General Chat", "emoji": "💬"},
    {"id": "gaming", "name": "Gaming Hub", "emoji": "🎮"},
    {"id": "school", "name": "School Talk", "emoji": "📘"},
    {"id": "tech", "name": "Tech News", "emoji": "🖥️"},
    {"id": "cars", "name": "Car Talk", "emoji": "🚗"},
  ];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          // LEFT DISCORD SIDEBAR
          ServerSidebar(
            selectedIndex: selectedServer,
            onTap: (i) {
              setState(() {
                selectedServer = i;
              });
              // for now, all sidebar icons keep us on boards
              // later you could filter boards by server
            },
          ),

          // MAIN CONTENT
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Message Boards"),
                centerTitle: true,
                leading: Builder(
                  builder: (context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),
              ),
              drawer: _buildDrawer(context),
              body: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: boards.length,
                itemBuilder: (_, i) {
                  final board = boards[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.96),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: ListTile(
                      leading: Text(
                        board["emoji"]!,
                        style: const TextStyle(fontSize: 26),
                      ),
                      title: Text(
                        board["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              boardId: board["id"]!,
                              boardName: board["name"]!,
                              boardEmoji: board["emoji"]!,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Container(
        color: ThemeProvider.discordDarker,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: ThemeProvider.discordDark,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.forum, color: Colors.white),
              title: const Text(
                "Message Boards",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
