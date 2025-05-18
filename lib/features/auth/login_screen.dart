import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> _submit() async {
    final auth = ref.read(authServiceProvider);

    final success = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!success) {
      setState(() => error = "Login fehlgeschlagen");
    } else {
      Navigator.of(context).pop(); // z. B. zurück zum Hauptscreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
            const SizedBox(height: 16),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _submit, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
