import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../providers/auth_providers.dart';
import '../repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider).login(_email.text, _password.text);
    } catch (error) {
      if (mounted) _showMessage(authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController(text: _email.text);
    final email = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('パスワードを再設定'),
      content: TextField(controller: controller, autofocus: true, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'メールアドレス')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')), FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('送信'))],
    ));
    controller.dispose();
    if (email == null || email.trim().isEmpty) return;
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (mounted) _showMessage('パスワード再設定メールを送信しました。');
    } catch (error) {
      if (mounted) _showMessage(authErrorMessage(error));
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Card(child: Padding(
      padding: const EdgeInsets.all(36),
      child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Icon(Icons.update_rounded, size: 44, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text('CancelWait', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('店舗管理画面にログイン', textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey.shade600)),
        const SizedBox(height: 32),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], decoration: const InputDecoration(labelText: 'メールアドレス', prefixIcon: Icon(Icons.mail_outline)), validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim()) ? '正しいメールアドレスを入力してください。' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _password, obscureText: _obscurePassword, autofillHints: const [AutofillHints.password], decoration: InputDecoration(labelText: 'パスワード', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscurePassword = !_obscurePassword), icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (value) => value == null || value.isEmpty ? 'パスワードを入力してください。' : null, onFieldSubmitted: (_) => _login()),
        const SizedBox(height: 24),
        FilledButton(onPressed: _loading ? null : _login, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('ログイン')),
        TextButton(onPressed: _loading ? null : _resetPassword, child: const Text('パスワードを忘れた方')),
        const Divider(height: 28),
        OutlinedButton(onPressed: _loading ? null : () => context.go('/register'), child: const Text('店舗アカウントを作成')),
        if (AppConfig.enableDemoLogin) ...[
          const SizedBox(height: 10),
          TextButton.icon(onPressed: _loading ? null : () => ref.read(authControllerProvider).demoLogin(), icon: const Icon(Icons.science_outlined), label: const Text('テストログイン')),
          Text('開発確認用（Firestoreには接続しません）', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey)),
        ],
      ])),
    ))),
  )));
}
