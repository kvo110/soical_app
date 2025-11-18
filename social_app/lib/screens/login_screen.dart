// lib/screens/login_screen.dart
// Login page with glass-card UI (Discord styled).
// This loads after Firebase auth decides the user is not logged in.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/gradient_background.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  String? errorMsg;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> doLogin() async {
    final ok = form.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/boards');
    } on FirebaseAuthException catch (e) {
      setState(() => errorMsg = e.message);
    } catch (_) {
      setState(() => errorMsg = "Login failed. Please try again.");
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
          title: const Text("Welcome back"),
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
                        "Log In",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Good to see you again.",
                        style: TextStyle(color: ThemeProvider.discordTextMuted),
                      ),
                      const SizedBox(height: 20),

                      // email box
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator: (v) {
                          if (v == null || !v.contains("@")) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // password box
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        validator: (v) {
                          if (v == null || v.length < 6) {
                            return "Min 6 characters";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      if (errorMsg != null)
                        Text(
                          errorMsg!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 13),
                        ),

                      const SizedBox(height: 10),

                      // login button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : doLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: ThemeProvider.discordBlurple,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text("Log In"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Need an account? "),
                          InkWell(
                            onTap: () => Navigator.pushReplacementNamed(
                                context, "/register"),
                            child: const Text(
                              "Register",
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
