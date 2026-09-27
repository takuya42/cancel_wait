import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/page_header.dart';
import '../../organization/application/organization_providers.dart';
import '../application/finance_providers.dart';
import '../domain/finance_entry.dart';
import 'finance_entry_dialog.dart';

class FinanceListScreen extends ConsumerWidget {
  const FinanceListScreen({required this.type, super.key});
  final EntryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = type == EntryType.sale;
    final label = sales ? '売上' : '経費';
    final entries = ref.watch(sales ? salesProvider : expensesProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(
              title: '$label管理',
              subtitle: '$labelを登録・編集し、日々の実績を正確に管理します。',
              action: FilledButton.icon(
                onPressed: () => _edit(context, ref),
                icon: const Icon(Icons.add),
                label: Text('$labelを追加'),
              ),
            ),
            const SizedBox(height: 24),
            entries.when(
              loading: () => const Card(child: SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))),
              error: (error, _) => _ErrorCard(onRetry: () => ref.invalidate(sales ? salesProvider : expensesProvider)),
              data: (items) => items.isEmpty
                  ? _EmptyCard(label: label, onAdd: () => _edit(context, ref))
                  : _EntryList(items: items, type: type, onEdit: (entry) => _edit(context, ref, entry), onDelete: (entry) => _delete(context, ref, entry)),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, [FinanceEntry? entry]) async {
    final organizationId = ref.read(organizationIdProvider).value;
    if (organizationId == null) {
      _message(context, '組織情報を読み込めませんでした。再ログインしてください。');
      return;
    }
    final input = await showFinanceEntryDialog(context, type: type, entry: entry);
    if (input == null || !context.mounted) return;
    try {
      await ref.read(financeRepositoryProvider).save(organizationId: organizationId, type: type, existing: entry, date: input.date, amount: input.amount, category: input.category, memo: input.memo);
      if (context.mounted) _message(context, '${type == EntryType.sale ? '売上' : '経費'}を${entry == null ? '登録' : '更新'}しました。');
    } catch (_) {
      if (context.mounted) _message(context, '保存できませんでした。通信環境をご確認ください。');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, FinanceEntry entry) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('削除の確認'),
      content: Text('${formatDate(entry.date)}のデータを削除します。この操作は取り消せません。'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')), FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: () => Navigator.pop(context, true), child: const Text('削除する'))],
    ));
    if (confirmed != true || !context.mounted) return;
    final organizationId = ref.read(organizationIdProvider).value;
    if (organizationId == null) return;
    try {
      await ref.read(financeRepositoryProvider).delete(organizationId, type, entry.id);
      if (context.mounted) _message(context, '削除しました。');
    } catch (_) {
      if (context.mounted) _message(context, '削除できませんでした。');
    }
  }

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.items, required this.type, required this.onEdit, required this.onDelete});
  final List<FinanceEntry> items;
  final EntryType type;
  final ValueChanged<FinanceEntry> onEdit;
  final ValueChanged<FinanceEntry> onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(children: [
      Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Text('${items.length}件', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text('合計 ${formatCurrency(items.fold<int>(0, (sum, item) => sum + item.amount))}', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
      ])),
      const Divider(height: 1),
      ...items.map((entry) => Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(backgroundColor: type == EntryType.sale ? const Color(0xFFE8F1FF) : const Color(0xFFFFF1E5), child: Icon(type == EntryType.sale ? Icons.arrow_upward : Icons.arrow_downward, color: type == EntryType.sale ? Colors.blue : Colors.orange.shade800)),
          title: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${formatDate(entry.date)}${entry.memo.isEmpty ? '' : '  •  ${entry.memo}'}${entry.createdAt == null ? '' : '\n登録: ${formatDate(entry.createdAt!)}'}'),
          isThreeLine: entry.createdAt != null,
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(formatCurrency(entry.amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            PopupMenuButton<String>(onSelected: (value) => value == 'edit' ? onEdit(entry) : onDelete(entry), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('編集')), PopupMenuItem(value: 'delete', child: Text('削除'))]),
          ]),
        ),
        if (entry != items.last) const Divider(height: 1, indent: 76),
      ])),
    ]),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.label, required this.onAdd});
  final String label;
  final VoidCallback onAdd;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24), child: Center(child: Column(children: [Icon(Icons.inbox_outlined, size: 52, color: Colors.blueGrey.shade300), const SizedBox(height: 16), Text('$labelデータはまだありません', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('最初の$labelを登録すると、集計やレポートに反映されます。'), const SizedBox(height: 20), OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text('$labelを登録'))]))));
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});
  final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(48), child: Center(child: Column(children: [Icon(Icons.cloud_off_outlined, size: 48, color: Theme.of(context).colorScheme.error), const SizedBox(height: 12), const Text('データを読み込めませんでした'), const SizedBox(height: 12), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('再読み込み'))]))));
}
