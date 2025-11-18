// main.dart
// Kenny Vo - Social App (Discord-style Flutter + Firebase)
// Bootstraps Firebase, sets up global providers, and handles routing.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// firebase config
import 'firebase_options.dart';

// theme + sidebar providers
import 'providers/theme_provider.dart';
import 'providers/sidebar_provider.dart';

// screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/message_boards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SidebarProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Social App",

      // Dark / Light theme switching
      themeMode: themeProv.themeMode,

      // light theme
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "ggSans",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // dark theme (Discord-style)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "ggSans",
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),

      // routes
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/boards': (_) => const MessageBoardsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
      },

      home: const Root(),
    );
  }
}

/// Decides where to send the user based on auth state
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // still loading Firebase → splash screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // logged in
        if (snapshot.hasData) {
          return const MessageBoardsScreen();
        }

        // not logged in
        return const LoginScreen();
      },
    );
  }
}
