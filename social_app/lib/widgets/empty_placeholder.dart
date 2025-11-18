// lib/widgets/empty_placeholder.dart
// Simple "nothing here" UI for empty boards or message lists.

import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String message;

  const EmptyPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
    );
  }
}
