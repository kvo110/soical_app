// lib/screens/settings_screen.dart
// Kenny Vo - Settings page for the social app.
// This page covers:
// - Theme toggle
// - App information card
// - Change password panel with smooth animation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/server_sidebar.dart';
import '../widgets/gradient_background.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;

  bool _showPasswordPanel = false;
  bool _savingPassword = false;

  // basic controllers for the password form
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmNewPass = TextEditingController();

  // this handles the actual password update
  Future<void> _handlePasswordChange() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final oldPassword = _oldPass.text.trim();
    final newPassword = _newPass.text.trim();
    final confirmPassword = _confirmNewPass.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords don't match")),
      );
      return;
    }

    try {
      setState(() => _savingPassword = true);

      // firebase needs re-auth before password changes
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      _oldPass.clear();
      _newPass.clear();
      _confirmNewPass.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final isDark = themeProv.isDarkMode;

    final cardColor =
        isDark ? const Color(0xFF1E1F22) : const Color(0xFFF2F2F2);

    return GradientBackground(
      child: Row(
        children: [
          // left sidebar navigation
          ServerSidebar(
            selectedIndex: 2,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacementNamed(context, '/boards');
              } else if (i == 1) {
                Navigator.pushReplacementNamed(context, '/profile');
              }
            },
          ),

          // main content
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Settings"),
                backgroundColor: Colors.transparent,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        // THEME TOGGLE CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black26,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Dark Mode",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              Switch(
                                value: isDark,
                                onChanged: (v) => themeProv.toggleTheme(v),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // APP INFO CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black26,
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "App Info",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text("App Name: Social App"),
                              Text("Version: 1.0.0"),
                              Text("Developer: Kenny Vo"),
                              Text(
                                "Firebase: Connected",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // CHANGE PASSWORD CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black26,
                            ),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showPasswordPanel = !_showPasswordPanel;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Change Password",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      _showPasswordPanel
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ],
                                ),
                              ),

                              // smooth expand animation
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                transitionBuilder: (child, anim) {
                                  return SizeTransition(
                                    sizeFactor: anim,
                                    child: child,
                                  );
                                },
                                child: _showPasswordPanel
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: _oldPass,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: "Old Password",
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: _newPass,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: "New Password",
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: _confirmNewPass,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    "Confirm New Password",
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: _savingPassword
                                                  ? null
                                                  : _handlePasswordChange,
                                              child: _savingPassword
                                                  ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Text(
                                                      "Save Password",
                                                    ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
