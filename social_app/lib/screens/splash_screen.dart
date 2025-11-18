// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  final bool showAuthAfterDelay;

  const SplashScreen({super.key, this.showAuthAfterDelay = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.showAuthAfterDelay) {
      // wait 2 seconds then jump to login
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Social App',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Powered by Flutter + Firebase',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
