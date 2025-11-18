// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;

  final _first = TextEditingController();
  final _last = TextEditingController();
  final _role = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      _first.text = data['firstName'] ?? "";
      _last.text = data['lastName'] ?? "";
      _role.text = data['role'] ?? "";
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': _first.text.trim(),
      'lastName': _last.text.trim(),
      'role': _role.text.trim(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile updated")));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _first,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: _last,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: _role,
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
