// lib/screens/profile_screen.dart
// Profile screen for the social app.
// I tried to keep this written the way a student would naturally comment stuff.
// Main features:
//  • Edit avatar
//  • Edit display name
//  • Edit About Me
//  • Change user role
//  • Completely overflow-safe layout (even when sidebar collapses)

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/gradient_background.dart';
import '../widgets/server_sidebar.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;

  // roles a user can pick from
  final _roles = const [
    'Student',
    'Gamer',
    'Professor',
    'Tech Support',
    'Admin',
  ];

  bool _updatingRole = false;
  bool _uploadingAvatar = false;
  bool _savingAbout = false;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      FirebaseFirestore.instance.collection('users').doc(_uid);

  // --- PICK + UPLOAD AVATAR ---
  Future<void> _changeAvatar() async {
    try {
      setState(() => _uploadingAvatar = true);

      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (picked == null) {
        setState(() => _uploadingAvatar = false);
        return;
      }

      final file = File(picked.path);
      final ref =
          FirebaseStorage.instance.ref().child('avatars').child('$_uid.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await _userDoc.update({'avatarUrl': url});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Avatar error: $e")));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  // --- UPDATE ROLE ---
  Future<void> _updateRole(String newRole) async {
    try {
      setState(() => _updatingRole = true);
      await _userDoc.update({'role': newRole});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Role error: $e")));
      }
    } finally {
      if (mounted) setState(() => _updatingRole = false);
    }
  }

  // icons for each role (just for fun)
  IconData _roleIcon(String role) {
    switch (role) {
      case 'Gamer':
        return Icons.sports_esports;
      case 'Professor':
        return Icons.menu_book;
      case 'Tech Support':
        return Icons.build;
      case 'Admin':
        return Icons.shield;
      default:
        return Icons.school;
    }
  }

  // --- EDIT DISPLAY NAME ---
  Future<void> _editDisplayName(String oldName) async {
    final ctrl = TextEditingController(text: oldName);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit name"),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: "Display name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                final newName = ctrl.text.trim();
                if (newName.isEmpty) return;

                Navigator.pop(ctx);

                try {
                  await _userDoc.update({'displayName': newName});
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("$e")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // --- EDIT ABOUT ME ---
  Future<void> _editAboutMe(String current) async {
    final ctrl = TextEditingController(text: current);

    await showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: const Text("Edit About Me"),
          content: TextField(
            controller: ctrl,
            minLines: 3,
            maxLines: 6,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Write something about yourself...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(c);
                final newText = ctrl.text.trim();

                setState(() => _savingAbout = true);

                try {
                  await _userDoc.update({'aboutMe': newText});
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Bio error: $e")));
                }

                if (mounted) setState(() => _savingAbout = false);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Row(
        children: [
          // sidebar
          ServerSidebar(
            selectedIndex: 1,
            onTap: (i) {
              if (i == 0) Navigator.pushReplacementNamed(context, '/boards');
              if (i == 2) Navigator.pushReplacementNamed(context, '/settings');
            },
          ),

          // main panel
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Profile"),
                backgroundColor: Colors.transparent,
              ),
              body: StreamBuilder(
                stream: _userDoc.snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        "No profile data found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  final displayName =
                      (data['displayName'] ?? "Unknown user").toString();

                  final email =
                      (data['email'] ?? _auth.currentUser?.email ?? "")
                          .toString();

                  final avatarUrl = data['avatarUrl'];
                  final aboutMe = (data['aboutMe'] ?? "").toString();

                  final roleDB = (data['role'] ?? "Student").toString();
                  final fixedRole = _roles.firstWhere(
                    (r) => r.toLowerCase() == roleDB.toLowerCase(),
                    orElse: () => "Student",
                  );

                  final Timestamp? ts = data['registeredAt'];
                  final joined = ts == null
                      ? null
                      : "Joined: ${ts.toDate().month}/${ts.toDate().day}/${ts.toDate().year}";

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 550),
                        child: Column(
                          children: [
                            // --- MAIN CARD ---
                            Container(
                              decoration: BoxDecoration(
                                color: ThemeProvider.discordDarker,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.45),
                                    blurRadius: 25,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // header banner
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(18),
                                      topRight: Radius.circular(18),
                                    ),
                                    child: Container(
                                      height: 110,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ThemeProvider.discordBlurple,
                                            ThemeProvider.discordBlurple
                                                .withOpacity(.6),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // --- RESPONSIVE PROFILE AREA ---
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: LayoutBuilder(
                                      builder: (context, box) {
                                        final narrow = box.maxWidth < 360;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // use Wrap so avatar + info will break into rows
                                            Wrap(
                                              spacing: 16,
                                              runSpacing: 16,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.start,
                                              children: [
                                                // avatar section
                                                Transform.translate(
                                                  offset: const Offset(0, -36),
                                                  child: GestureDetector(
                                                    onTap: _uploadingAvatar
                                                        ? null
                                                        : _changeAvatar,
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 40,
                                                          backgroundColor:
                                                              Colors.black
                                                                  .withOpacity(
                                                                      0.4),
                                                          backgroundImage:
                                                              avatarUrl != null
                                                                  ? NetworkImage(
                                                                      avatarUrl,
                                                                    )
                                                                  : null,
                                                          child: avatarUrl ==
                                                                  null
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white70,
                                                                  size: 40,
                                                                )
                                                              : null,
                                                        ),
                                                        Positioned(
                                                          right: -2,
                                                          bottom: -2,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.black,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: _uploadingAvatar
                                                                ? const SizedBox(
                                                                    width: 14,
                                                                    height: 14,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor: AlwaysStoppedAnimation<
                                                                              Color>(
                                                                          Colors
                                                                              .white),
                                                                    ),
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 14,
                                                                  ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                // text + dropdown area
                                                SizedBox(
                                                  width: narrow
                                                      ? box.maxWidth
                                                      : box.maxWidth - 120,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              displayName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 21,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color: Colors
                                                                  .white70,
                                                              size: 18,
                                                            ),
                                                            onPressed: () =>
                                                                _editDisplayName(
                                                                    displayName),
                                                          )
                                                        ],
                                                      ),

                                                      const SizedBox(height: 4),
                                                      Text(
                                                        email,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                        ),
                                                      ),

                                                      if (joined != null) ...[
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          joined,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                Colors.white38,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ],

                                                      const SizedBox(
                                                          height: 12),

                                                      // role dropdown
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            "Role:",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white70,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 3,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          .35),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            .18),
                                                                  ),
                                                                ),
                                                                child:
                                                                    DropdownButton(
                                                                  isExpanded:
                                                                      true,
                                                                  value:
                                                                      fixedRole,
                                                                  dropdownColor:
                                                                      ThemeProvider
                                                                          .discordDarker,
                                                                  icon: _updatingRole
                                                                      ? const SizedBox(
                                                                          width:
                                                                              16,
                                                                          height:
                                                                              16,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(Colors.white),
                                                                          ),
                                                                        )
                                                                      : const Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                  onChanged:
                                                                      (v) {
                                                                    if (v !=
                                                                        null) {
                                                                      _updateRole(
                                                                          v);
                                                                    }
                                                                  },
                                                                  items: _roles
                                                                      .map((r) =>
                                                                          DropdownMenuItem(
                                                                            value:
                                                                                r,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Icon(_roleIcon(r), size: 16, color: Colors.white70),
                                                                                const SizedBox(width: 6),
                                                                                Flexible(child: Text(r, overflow: TextOverflow.ellipsis)),
                                                                              ],
                                                                            ),
                                                                          ))
                                                                      .toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // --- ABOUT ME (with smooth animated expansion) ---
                            AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.45),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(.12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "About",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: _savingAbout
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.edit,
                                                  size: 18,
                                                  color: Colors.white70,
                                                ),
                                          onPressed: _savingAbout
                                              ? null
                                              : () => _editAboutMe(aboutMe),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      aboutMe.isEmpty
                                          ? "Nothing here yet. Tap the edit icon to write a short bio."
                                          : aboutMe,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
