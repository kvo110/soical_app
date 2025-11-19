// lib/screens/chat_screen.dart
// Kenny Vo - Chat room page where all messages show live.
// I added better timestamps, grouped dates, auto-scroll, and
// made sure it shows the user's actual displayName from Firestore.

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
  final scrollCtrl = ScrollController();

  @override
  void dispose() {
    msgCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  Future<String> _getDisplayName(String uid, String fallbackEmail) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (!doc.exists) return fallbackEmail;

      final data = doc.data()!;
      final dn = data["displayName"];
      if (dn != null && dn.toString().trim().isNotEmpty) {
        return dn;
      }
      return fallbackEmail;
    } catch (_) {
      return fallbackEmail;
    }
  }

  Future<void> sendMessage() async {
    final text = msgCtrl.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    msgCtrl.clear();

    final displayName = await _getDisplayName(user.uid, user.email ?? "User");

    await FirebaseFirestore.instance
        .collection("boards")
        .doc(widget.boardId)
        .collection("messages")
        .add({
      "text": text,
      "uid": user.uid,
      "sender": displayName,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await Future.delayed(const Duration(milliseconds: 80));
    if (scrollCtrl.hasClients) {
      scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dt.year, dt.month, dt.day);

    if (msgDay == today) return "Today";
    if (msgDay == today.subtract(const Duration(days: 1))) {
      return "Yesterday";
    }
    return "${dt.month}/${dt.day}/${dt.year}";
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, "0");
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
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
                              child: CircularProgressIndicator());
                        }

                        final msgs = snap.data!.docs;
                        final bubbles = <Widget>[];

                        String lastDate = "";

                        for (int i = 0; i < msgs.length; i++) {
                          final data = msgs[i].data() as Map<String, dynamic>;
                          final ts = data["timestamp"] as Timestamp?;
                          final dt = ts?.toDate() ?? DateTime.now();

                          final dateLabel = _formatDate(dt);

                          if (dateLabel != lastDate) {
                            lastDate = dateLabel;
                            bubbles.add(
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      dateLabel,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          bubbles.add(
                            _bubble(
                              text: data["text"] ?? "",
                              sender: data["sender"] ?? "User",
                              uid: data["uid"] ?? "",
                              time: _formatTime(dt),
                            ),
                          );
                        }

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (scrollCtrl.hasClients) {
                            scrollCtrl
                                .jumpTo(scrollCtrl.position.maxScrollExtent);
                          }
                        });

                        return ListView(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          children: bubbles,
                        );
                      },
                    ),
                  ),
                  _inputBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _bubble({
    required String text,
    required String sender,
    required String uid,
    required String time,
  }) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    final mine = uid == myUid;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine
              ? ThemeProvider.discordBlurple.withOpacity(0.75)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender,
                  style: TextStyle(
                    fontSize: 12,
                    color: mine ? Colors.white70 : Colors.white60,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
