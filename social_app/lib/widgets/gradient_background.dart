// lib/widgets/gradient_background.dart
// Ultra-smooth Aurora Gradient (Discord Nitro style)
// This version includes:
// - Multi-layer aurora waves
// - Soft blur / glow diffusion
// - Very smooth animation loops
// - Dark/light mode support

import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class GradientBackground extends StatefulWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Longer duration = smoother, slower transitions
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // tiny helper for color blending
  Color mix(Color a, Color b, double t) {
    return Color.lerp(a, b, t)!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        double t = _controller.value;

        // base colors for mode
        final base1 =
            isDark ? ThemeProvider.discordDarker : Colors.grey.shade200;

        final base2 = isDark
            ? ThemeProvider.discordBlurple.withOpacity(0.6)
            : ThemeProvider.discordBlurple.withOpacity(0.3);

        final base3 = isDark
            ? ThemeProvider.discordDarker.withOpacity(0.85)
            : Colors.grey.shade300;

        return Stack(
          children: [
            // MAIN GRADIENT BACKGROUND
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mix(base1, base2, t * 0.45),
                    mix(base2, base3, (t * 0.6)),
                    mix(base3, base1, (t * 0.4)),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            // LAYER 1 — soft blurred blob drifting diagonally
            Positioned.fill(
              child: Opacity(
                opacity: 0.22,
                child: Transform.translate(
                  offset: Offset(200 * (t - 0.5), 160 * (0.5 - t)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          ThemeProvider.discordBlurple.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        radius: 1.35,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // LAYER 2 — slower secondary wave for smoother look
            Positioned.fill(
              child: Opacity(
                opacity: 0.18,
                child: Transform.translate(
                  offset: Offset(120 * (0.5 - t), 180 * (t - 0.5)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          ThemeProvider.discordBlurple.withOpacity(0.35),
                          Colors.transparent,
                        ],
                        radius: 1.7,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // GLOBAL BLUR — this softens transitions massively
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 65,
                  sigmaY: 65,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),

            // CHILD CONTENT
            widget.child,
          ],
        );
      },
    );
  }
}
