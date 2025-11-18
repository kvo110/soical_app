// lib/providers/sidebar_provider.dart
// Very small provider that controls whether the left sidebar is expanded or collapsed.

import 'package:flutter/material.dart';

class SidebarProvider extends ChangeNotifier {
  bool _isExpanded = true;

  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
}
