// lib/screens/message_boards_screen.dart
// Home screen after login.
// Shows all message boards (chats) grouped by category.
// Also lets the user create new boards that are stored in Firestore.

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
  // these controllers are only used inside the "new board" dialog
  final _titleCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _iconCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _categoryCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  // opens a dialog so the user can create a new board/chat
  Future<void> _openCreateBoardDialog() async {
    _titleCtrl.clear();
    _categoryCtrl.clear();
    _iconCtrl.clear();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ThemeProvider.discordDarker.withOpacity(0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Create a new board",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Board name",
                  hintText: "ex: CS Study Group",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(
                  labelText: "Category (optional)",
                  hintText: "ex: Classes, Friends, Clubs",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _iconCtrl,
                decoration: const InputDecoration(
                  labelText: "Emoji icon (optional)",
                  hintText: "ex: 📚, 💬, 🎮",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                final title = _titleCtrl.text.trim();
                if (title.isEmpty) return;

                final categoryText = _categoryCtrl.text.trim();
                final iconText = _iconCtrl.text.trim();

                final category =
                    categoryText.isEmpty ? "General" : categoryText;
                final icon = iconText.isEmpty ? "💬" : iconText;

                await FirebaseFirestore.instance.collection("boards").add({
                  "title": title,
                  "category": category,
                  "icon": icon,
                  "createdAt": FieldValue.serverTimestamp(),
                });

                if (mounted) {
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          // left sidebar like Discord
          ServerSidebar(
            selectedIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacementNamed(context, '/profile');
              } else if (index == 2) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),

          // right side with boards list
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Message Boards"),
                backgroundColor: Colors.transparent,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _openCreateBoardDialog,
                child: const Icon(Icons.add),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("boards")
                    .orderBy("createdAt", descending: false)
                    .snapshots(),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No boards created yet.\nTap + to make your first one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // group boards by category label
                  final Map<String, List<QueryDocumentSnapshot>> grouped = {};
                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final cat =
                        (data["category"] as String?)?.trim().isNotEmpty == true
                            ? data["category"] as String
                            : "General";
                    grouped.putIfAbsent(cat, () => []).add(doc);
                  }

                  final categories = grouped.keys.toList()..sort();

                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: categories.length,
                    itemBuilder: (ctx, catIndex) {
                      final catName = categories[catIndex];
                      final boards = grouped[catName]!;
                      return _buildCategorySection(catName, boards);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // draws one "category" section (like Classes, Friends, etc)
  Widget _buildCategorySection(
    String category,
    List<QueryDocumentSnapshot> boards,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // small category label
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // each board in this category
        ...List.generate(boards.length, (i) {
          final doc = boards[i];
          final data = doc.data() as Map<String, dynamic>;
          final title = data["title"] as String? ?? "Unnamed Board";
          final icon = data["icon"] as String? ?? "💬";

          return _buildBoardTile(
            index: i,
            boardId: doc.id,
            title: title,
            icon: icon,
          );
        }),
        const SizedBox(height: 10),
      ],
    );
  }

  // a single board card with a tiny animation + icon
  Widget _buildBoardTile({
    required int index,
    required String boardId,
    required String title,
    required String icon,
  }) {
    return TweenAnimationBuilder<double>(
      // simple fade + slide animation when the list builds
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + index * 40),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(boardId: boardId),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeProvider.discordDarker.withOpacity(0.88),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              // little icon avatar for the board
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.08),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
