// lib/widgets/server_sidebar.dart
// Kenny Vo - Sidebar but a little nicer.
// Grabs the logged-in user's avatar + display name from Firebase
// and shows it at the top. Also has some light animations so it feels smoother.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // temp user reference
    final user = FirebaseAuth.instance.currentUser;
    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user!.uid);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: GestureDetector(
                onTap: sidebar.toggle,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: isExpanded
                      ? Row(
                          key: const ValueKey("expanded_header"),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Menu",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: sidebar.toggle,
                            ),
                          ],
                        )
                      : Center(
                          key: const ValueKey("collapsed_header"),
                          child: Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                ),
              ),
            ),

            // user info (avatar + display name)
            FutureBuilder<DocumentSnapshot>(
              future: docRef.get(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CircleAvatar(
                      radius: isExpanded ? 26 : 22,
                      backgroundColor: Colors.grey.shade700,
                      child: const Icon(Icons.person, color: Colors.white70),
                    ),
                  );
                }

                final data = snap.data!.data() as Map<String, dynamic>?;

                final avatarUrl = data?['avatarUrl'] as String?;
                final displayName = data?['displayName'] as String? ?? "User";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: isExpanded
                        ? Row(
                            key: const ValueKey("expanded_user"),
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                backgroundColor: Colors.grey.shade700,
                                child: avatarUrl == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white70)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey("collapsed_user"),
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                backgroundColor: Colors.grey.shade700,
                                child: avatarUrl == null
                                    ? const Icon(Icons.person,
                                        color: Colors.white70)
                                    : null,
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

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

  // the clickable menu row
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

    final color = selected
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white70 : Colors.black87);

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            Icon(icon, color: color, size: 24),
            if (expanded) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
