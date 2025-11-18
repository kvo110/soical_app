// main.dart
// Kenny Vo — Social App (Discord-style Flutter + Firebase)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/sidebar_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/message_boards_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

/// App entry point
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
      child:
          const AppRoot(), // <-- MaterialApp moved OUTSIDE provider rebuild cycle
    ),
  );
}

/// Wrapper around MaterialApp so it **never rebuilds unexpectedly**
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Only reads themeMode — this does NOT recreate MaterialApp
    final themeProv = Provider.of<ThemeProvider>(context, listen: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Social App",
      themeMode: themeProv.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "ggSans",
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "ggSans",
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
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

/// Sends the user to the correct screen depending on Firebase auth state
class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snap.hasData) {
          return const MessageBoardsScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
