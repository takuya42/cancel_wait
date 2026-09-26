import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.update_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('CancelWait', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('店舗管理画面にログイン', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade600)),
                    const SizedBox(height: 32),
                    const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'メールアドレス', prefixIcon: Icon(Icons.mail_outline))),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(onPressed: () => context.go('/home'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('ログイン')),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () {}, child: const Text('パスワードを忘れた方')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
