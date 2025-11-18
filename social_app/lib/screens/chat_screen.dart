// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String boardId;
  final String boardName;

  const ChatScreen({
    super.key,
    required this.boardId,
    required this.boardName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msg = TextEditingController();

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msg.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId)
        .collection('messages')
        .add({
      'text': text,
      'userId': user.uid,
      'userName': user.email ?? "Unknown",
      'createdAt': FieldValue.serverTimestamp(),
    });

    _msg.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId)
        .collection('messages')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: ref.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.builder(
                  reverse: true, // newest at bottom visually
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data()!;
                    final ts = data['createdAt'] as Timestamp?;
                    final dt = ts?.toDate();
                    final time = dt == null
                        ? ''
                        : "${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                    return ListTile(
                      title: Text(data['text'] ?? ''),
                      subtitle: Text("${data['userName']} · $time"),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msg,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
