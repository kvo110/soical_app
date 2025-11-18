// lib/screens/settings_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return GradientBackground(
      child: Row(
        children: [
          ServerSidebar(
            selectedIndex: -1,
            onTap: (_) {
              Navigator.pushReplacementNamed(context, '/boards');
            },
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Settings"),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: const Text("Dark Mode"),
                    value: themeProv.isDarkMode,
                    onChanged: (val) => themeProv.toggleTheme(val),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
