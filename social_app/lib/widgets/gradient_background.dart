// lib/widgets/gradient_background.dart
// Gradient background using real Discord-style purple tones.

import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A5AE0), // discord purple 1
            Color(0xFF7F6BEE), // discord purple 2
            Color(0xFF5E4BC7), // deep violet
          ],
        ),
      ),
      child: child,
    );
  }
}
