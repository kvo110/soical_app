// lib/widgets/server_sidebar.dart
// Kenny Vo - collapsible Discord-style sidebar (overflow safe)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sidebar_provider.dart';

class ServerSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ServerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sidebar = Provider.of<SidebarProvider>(context);
    final isExpanded = sidebar.isExpanded;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sidebarColor =
        isDark ? const Color(0xFF1E1F22) : const Color(0xFFD6D6D6);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isExpanded ? 240 : 70,
        decoration: BoxDecoration(
          color: sidebarColor.withOpacity(0.95),
          border: Border(
            right: BorderSide(
              color: isDark ? Colors.white12 : Colors.black26,
            ),
          ),
        ),
        child: Column(
          children: [
            // SAFE HEADER (NO OVERFLOW)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: isExpanded
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Menu",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          onPressed: sidebar.toggle,
                        ),
                      ],
                    )
                  : Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        onPressed: sidebar.toggle,
                      ),
                    ),
            ),

            const SizedBox(height: 4),

            // Navigation buttons
            _item(
              context,
              index: 0,
              icon: Icons.chat_bubble,
              label: "Boards",
              selected: selectedIndex == 0,
              expanded: isExpanded,
              onTap: onTap,
            ),
            _item(
              context,
              index: 1,
              icon: Icons.person,
              label: "Profile",
              selected: selectedIndex == 1,
              expanded: isExpanded,
              onTap: onTap,
            ),
            _item(
              context,
              index: 2,
              icon: Icons.settings,
              label: "Settings",
              selected: selectedIndex == 2,
              expanded: isExpanded,
              onTap: onTap,
            ),

            const Spacer(),

            _item(
              context,
              index: 3,
              icon: Icons.logout,
              label: "Logout",
              selected: false,
              expanded: isExpanded,
              onTap: onTap,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Sidebar item widget
  Widget _item(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool expanded,
    required bool selected,
    required Function(int) onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconColor = isDark
        ? (selected ? Colors.white : Colors.white70)
        : (selected ? Colors.black : Colors.black87);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 14,
          horizontal: expanded ? 20 : 0,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white12 : Colors.black12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment:
              expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            if (expanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: iconColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
