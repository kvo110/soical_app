// lib/screens/register_screen.dart
// Register screen stores user info in Firebase Auth + Firestore.
// UI matches the login card with the same purple blurred styling.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/gradient_background.dart';
import '../providers/theme_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final form = GlobalKey<FormState>();

  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String? errorMsg;

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> doRegister() async {
    final ok = form.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = result.user;
      if (user == null) throw Exception("User creation failed.");

      // save extra data
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "firstName": firstCtrl.text.trim(),
        "lastName": lastCtrl.text.trim(),
        "displayName": "${firstCtrl.text.trim()} ${lastCtrl.text.trim()}",
        "role": "Student",
        "email": emailCtrl.text.trim(),
        "registeredAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/boards");
    } on FirebaseAuthException catch (e) {
      setState(() => errorMsg = e.message);
    } catch (_) {
      setState(() => errorMsg = "Something went wrong.");
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Create Account"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: ThemeProvider.glassBackground(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ThemeProvider.glassBorder(context)),
                  boxShadow: ThemeProvider.glassShadow(context),
                ),
                child: Form(
                  key: form,
                  child: Column(
                    children: [
                      const Text(
                        "Join the community",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // first + last name row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstCtrl,
                              decoration: const InputDecoration(
                                  labelText: "First name"),
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: lastCtrl,
                              decoration:
                                  const InputDecoration(labelText: "Last name"),
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Required" : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (v) => v == null || !v.contains("@")
                            ? "Enter a valid email"
                            : null,
                      ),

                      const SizedBox(height: 14),

                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        validator: (v) => v == null || v.length < 6
                            ? "Min 6 characters"
                            : null,
                      ),

                      const SizedBox(height: 14),

                      if (errorMsg != null)
                        Text(
                          errorMsg!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : doRegister,
                          style: FilledButton.styleFrom(
                              backgroundColor: ThemeProvider.discordBlurple),
                          child: loading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text("Create Account"),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                                context, "/login"),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: ThemeProvider.discordBlurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
