import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/page_header.dart';
import '../../auth/application/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).value;
    return SingleChildScrollView(padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 850), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: '設定', subtitle: 'アカウントと事業者情報を管理します。'), const SizedBox(height: 24),
      Card(child: Column(children: [Padding(padding: const EdgeInsets.all(24), child: Row(children: [CircleAvatar(radius: 28, child: Text((user?.email ?? 'T').substring(0,1).toUpperCase())), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('アカウント情報', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(user?.email ?? 'テストログイン中', style: TextStyle(color: Colors.blueGrey.shade600))]))])), const Divider(height: 1), ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), leading: const Icon(Icons.business_outlined), title: const Text('事業情報'), subtitle: const Text('事業名・代表者・連絡先を編集'), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/business')), const Divider(height: 1), ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error), title: Text('ログアウト', style: TextStyle(color: Theme.of(context).colorScheme.error)), onTap: () => _logout(context, ref))])),
    ]))));
  }
  Future<void> _logout(BuildContext context, WidgetRef ref) async { final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('ログアウト'), content: const Text('ログアウトしてログイン画面に戻りますか？'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ログアウト'))])); if (confirmed == true) { await ref.read(authControllerProvider).logout(); if (context.mounted) context.go('/login'); } }
}
