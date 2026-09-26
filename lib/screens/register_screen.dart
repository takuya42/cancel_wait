import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _key = GlobalKey<FormState>();
  final _shop = TextEditingController();
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override void dispose() { for (final c in [_shop, _owner, _email, _password, _confirmation]) { c.dispose(); } super.dispose(); }

  Future<void> _register() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _loading = true);
    User? createdUser;
    try {
      final credential = await ref.read(authRepositoryProvider).createUser(email: _email.text, password: _password.text);
      createdUser = credential.user;
      if (createdUser == null) throw StateError('User creation failed');
      await ref.read(shopRepositoryProvider).createOwnerShop(uid: createdUser.uid, shopName: _shop.text, ownerName: _owner.text, email: _email.text);
    } catch (error) {
      // Do not leave an Authentication account without its required store data.
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // The original error is more useful to the user. A subsequent login
          // can safely retry after support removes a rare orphaned account.
        }
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? '入力してください。' : null;

  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: IconButton(onPressed: () => context.go('/login'), icon: const Icon(Icons.arrow_back)), title: const Text('店舗アカウント作成')), body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: Card(child: Padding(padding: const EdgeInsets.all(36), child: Form(key: _key, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Text('店舗情報を登録', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
    const SizedBox(height: 8), const Text('管理者アカウントと店舗を同時に作成します。'), const SizedBox(height: 28),
    TextFormField(controller: _shop, decoration: const InputDecoration(labelText: '店舗名', prefixIcon: Icon(Icons.store_outlined)), validator: _required), const SizedBox(height: 14),
    TextFormField(controller: _owner, decoration: const InputDecoration(labelText: '担当者名', prefixIcon: Icon(Icons.person_outline)), validator: _required), const SizedBox(height: 14),
    TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'メールアドレス', prefixIcon: Icon(Icons.mail_outline)), validator: (value) => value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim()) ? '正しいメールアドレスを入力してください。' : null), const SizedBox(height: 14),
    TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'パスワード', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (value) => value == null || value.length < 6 ? '6文字以上で入力してください。' : null), const SizedBox(height: 14),
    TextFormField(controller: _confirmation, obscureText: _obscure, decoration: const InputDecoration(labelText: 'パスワード確認', prefixIcon: Icon(Icons.lock_reset_outlined)), validator: (value) => value != _password.text ? 'パスワードが一致しません。' : null), const SizedBox(height: 24),
    FilledButton(onPressed: _loading ? null : _register, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('アカウントを作成')),
  ]))))))));
}
