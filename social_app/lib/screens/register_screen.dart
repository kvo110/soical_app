// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final error = await _auth.register(
      email: _email.text.trim(),
      password: _password.text.trim(),
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/boards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: "First name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter first name" : null,
              ),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: "Last name"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter last name" : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (v) => v == null || v.isEmpty ? "Enter email" : null,
              ),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) =>
                    v != null && v.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _handleRegister,
                      child: const Text("Create Account"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
