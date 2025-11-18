// lib/screens/chat_screen.dart
// A Discord-style chat room that loads messages live using Firestore snapshots.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String boardId;

  const ChatScreen({super.key, required this.boardId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgCtrl = TextEditingController();

  Future<void> sendMessage() async {
    if (msgCtrl.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    final text = msgCtrl.text.trim();
    msgCtrl.clear();

    await FirebaseFirestore.instance
        .collection("boards")
        .doc(widget.boardId)
        .collection("messages")
        .add({
      "text": text,
      "uid": user.uid,
      "sender": user.email ?? "User",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          ServerSidebar(
            selectedIndex: 0,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacementNamed(context, '/boards');
              } else if (i == 1) {
                Navigator.pushReplacementNamed(context, '/profile');
              } else if (i == 2) {
                Navigator.pushReplacementNamed(context, '/settings');
              }
            },
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: const Text("Chat"),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("boards")
                          .doc(widget.boardId)
                          .collection("messages")
                          .orderBy("timestamp", descending: false)
                          .snapshots(),
                      builder: (_, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final msgs = snap.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: msgs.length,
                          itemBuilder: (_, i) {
                            final msg = msgs[i];
                            return _bubble(
                              msg["text"],
                              msg["sender"],
                              msg["uid"],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _inputBar(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: msgCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                hintText: "Type a message...",
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _bubble(String text, String sender, String uid) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final mine = uid == myUid;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine
              ? ThemeProvider.discordBlurple.withOpacity(0.7)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 11,
                color: mine ? Colors.white70 : Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
