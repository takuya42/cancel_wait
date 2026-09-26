import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../widgets/page_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final owner = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  bool initialized = false;
  bool loading = false;

  @override
  void dispose() {
    for (final controller in [name, owner, phone, address]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = ref.watch(shopProvider).value;
    if (shop != null && !initialized) {
      name.text = shop.name;
      owner.text = shop.ownerName;
      phone.text = shop.phone;
      address.text = shop.address;
      initialized = true;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: '店舗設定',
                subtitle: '予約ページに表示する店舗情報を編集します。',
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(labelText: '店舗名'),
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: owner,
                          decoration: const InputDecoration(labelText: '担当者名'),
                          validator: _required,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: '電話番号'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: address,
                          decoration: const InputDecoration(labelText: '住所'),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: loading ? null : _save,
                            child: Text(loading ? '保存中…' : '保存'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.public),
                  title: const Text('顧客向け予約ページ'),
                  subtitle: SelectableText(
                    shop == null ? '読み込み中…' : '/reserve/${shop.id}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(Icons.link_off, color: Colors.orange.shade700),
                  title: const Text('LINE Messaging API：未接続'),
                  subtitle: const Text(
                    '通知操作は安全なモックとして履歴に保存されます。実際のメッセージは送信されません。',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final shopId = ref.read(shopIdProvider).value;
      if (shopId != null) {
        await ref
            .read(dashboardRepositoryProvider)
            .updateShop(
              shopId,
              name: name.text,
              ownerName: owner.text,
              phone: phone.text,
              address: address.text,
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? '入力してください'
      : null;
}
