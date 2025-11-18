// lib/screens/message_boards_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MessageBoardsScreen extends StatelessWidget {
  const MessageBoardsScreen({super.key});

  static final boards = [
    {'id': 'general', 'name': 'General Chat', 'icon': Icons.chat},
    {'id': 'school', 'name': 'School Help', 'icon': Icons.school},
    {'id': 'random', 'name': 'Random Stuff', 'icon': Icons.tag},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Message Boards')),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.email ?? "Unknown"),
              accountEmail: Text(user?.uid ?? ""),
              currentAccountPicture:
                  const CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text("Message Boards"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boards.length,
        itemBuilder: (_, i) {
          final b = boards[i];
          return Card(
            child: ListTile(
              leading: Icon(b['icon'] as IconData),
              title: Text(b['name'] as String),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      boardId: b['id'] as String,
                      boardName: b['name'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
