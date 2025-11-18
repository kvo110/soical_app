// lib/screens/settings_screen.dart
// Very simple settings page: theme toggle + logout button.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return GradientBackground(
      child: Row(
        children: [
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
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Settings"),
                backgroundColor: Colors.transparent,
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SwitchListTile(
                    title: const Text("Dark Mode",
                        style: TextStyle(color: Colors.white)),
                    value: themeProv.isDarkMode,
                    onChanged: themeProv.toggleTheme,
                    activeColor: ThemeProvider.discordBlurple,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text("Log Out"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
