// lib/screens/message_boards_screen.dart
// This is the main screen showing all message boards (channels).

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../providers/theme_provider.dart';
import 'chat_screen.dart';

class MessageBoardsScreen extends StatefulWidget {
  const MessageBoardsScreen({super.key});

  @override
  State<MessageBoardsScreen> createState() => _MessageBoardsScreenState();
}

class _MessageBoardsScreenState extends State<MessageBoardsScreen> {
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          // Discord-style left sidebar
          ServerSidebar(
            selectedIndex: 0,
            onTap: (i) {
              if (i == 1) {
                Navigator.pushReplacementNamed(context, '/profile');
              } else if (i == 2) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),

          // Right side content
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Message Boards"),
                backgroundColor: Colors.transparent,
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("boards")
                    .snapshots(), // 🔥 FIXED
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No boards created yet.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final boards = snap.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: boards.length,
                    itemBuilder: (_, i) {
                      final board = boards[i];
                      return _buildBoardTile(
                        board.id, // 🔥 FIXED — Use ID
                        board.id, // also use ID as the title
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // A simple Discord-like board card
  Widget _buildBoardTile(String boardId, String title) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(boardId: boardId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ThemeProvider.discordDarker.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
