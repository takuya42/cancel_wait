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
              data: (items) => Column(children: [
                _TotalCard(label: label, items: items, type: type),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyCard(label: label, onAdd: () => _edit(context, ref))
                else
                  _EntryList(items: items, type: type, onEdit: (entry) => _edit(context, ref, entry), onDelete: (entry) => _delete(context, ref, entry)),
              ]),
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.label, required this.items, required this.type});
  final String label;
  final List<FinanceEntry> items;
  final EntryType type;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, item) => sum + item.amount);
    final color = type == EntryType.sale ? const Color(0xFF2563EB) : const Color(0xFFF59E0B);
    return Card(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: Icon(type == EntryType.sale ? Icons.trending_up_rounded : Icons.receipt_long_outlined, color: color)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label合計', style: TextStyle(color: Colors.blueGrey.shade600)),
          const SizedBox(height: 4),
          Text(formatCurrency(total), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ]),
        const Spacer(),
        Text('${items.length}件', style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}

class _EntryList extends StatelessWidget {
  const _EntryList({required this.items, required this.type, required this.onEdit, required this.onDelete});
  final List<FinanceEntry> items;
  final EntryType type;
  final ValueChanged<FinanceEntry> onEdit;
  final ValueChanged<FinanceEntry> onDelete;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth >= 720) return _EntryTable(items: items, onEdit: onEdit, onDelete: onDelete);
    return Column(children: items.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Card(child: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(backgroundColor: type == EntryType.sale ? const Color(0xFFE8F1FF) : const Color(0xFFFFF1E5), child: Icon(type == EntryType.sale ? Icons.arrow_upward : Icons.arrow_downward, color: type == EntryType.sale ? Colors.blue : Colors.orange.shade800)),
          title: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${formatDate(entry.date)}${entry.memo.isEmpty ? '' : '  •  ${entry.memo}'}${entry.createdAt == null ? '' : '\n登録: ${formatDate(entry.createdAt!)}'}'),
          isThreeLine: entry.createdAt != null,
          trailing: _EntryMenu(entry: entry, onEdit: onEdit, onDelete: onDelete),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 18), child: Align(alignment: Alignment.centerRight, child: Text(formatCurrency(entry.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)))),
      ])))).toList());
  });
}

class _EntryTable extends StatelessWidget {
  const _EntryTable({required this.items, required this.onEdit, required this.onDelete});
  final List<FinanceEntry> items;
  final ValueChanged<FinanceEntry> onEdit, onDelete;
  @override Widget build(BuildContext context) => Card(child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Table(
    columnWidths: const {0: FixedColumnWidth(130), 1: FlexColumnWidth(1.2), 2: FlexColumnWidth(2), 3: FixedColumnWidth(150), 4: FixedColumnWidth(64)},
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: [
      TableRow(decoration: const BoxDecoration(color: Color(0xFFF8FAFC)), children: const [_Header('日付'), _Header('カテゴリ'), _Header('メモ'), _Header('金額', right: true), SizedBox(height: 52)]),
      ...items.map((entry) => TableRow(decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE7ECF3)))), children: [
        _Cell(formatDate(entry.date)), _Cell(entry.category, bold: true), _Cell(entry.memo.isEmpty ? '—' : entry.memo), _Cell(formatCurrency(entry.amount), bold: true, right: true), _EntryMenu(entry: entry, onEdit: onEdit, onDelete: onDelete),
      ])),
    ],
  )));
}

class _Header extends StatelessWidget { const _Header(this.text, {this.right = false}); final String text; final bool right; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(text, textAlign: right ? TextAlign.right : null, style: TextStyle(color: Colors.blueGrey.shade600, fontWeight: FontWeight.w700))); }
class _Cell extends StatelessWidget { const _Cell(this.text, {this.bold = false, this.right = false}); final String text; final bool bold, right; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: right ? TextAlign.right : null, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null, color: bold ? null : Colors.blueGrey.shade700))); }
class _EntryMenu extends StatelessWidget { const _EntryMenu({required this.entry, required this.onEdit, required this.onDelete}); final FinanceEntry entry; final ValueChanged<FinanceEntry> onEdit, onDelete; @override Widget build(BuildContext context) => PopupMenuButton<String>(tooltip: '操作', onSelected: (value) => value == 'edit' ? onEdit(entry) : onDelete(entry), itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('編集'), contentPadding: EdgeInsets.zero)), PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('削除'), contentPadding: EdgeInsets.zero))]); }

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
