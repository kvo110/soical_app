// lib/screens/profile_screen.dart
// This page loads the user's Firestore profile and displays it.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          ServerSidebar(
            selectedIndex: 1,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacementNamed(context, '/boards');
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
                title: const Text("Profile"),
              ),
              body: FutureBuilder(
                future: loadUser(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snap.hasData || snap.data == null) {
                    return const Center(
                      child: Text("No profile data found.",
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  final user = snap.data! as Map<String, dynamic>;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ThemeProvider.discordDarker.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user["displayName"] ?? "",
                              style: const TextStyle(
                                  fontSize: 19, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user["email"] ?? "",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Role: ${user["role"] ?? "Student"}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
