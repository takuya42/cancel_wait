import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/page_header.dart';
import '../../transactions/application/finance_providers.dart';
import '../../transactions/domain/finance_entry.dart';
import '../../transactions/presentation/monthly_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesProvider);
    final expenses = ref.watch(expensesProvider);
    if (sales.isLoading || expenses.isLoading) return const Center(child: CircularProgressIndicator());
    if (sales.hasError || expenses.hasError) return _DashboardError(onRetry: () { ref.invalidate(salesProvider); ref.invalidate(expensesProvider); });
    return _DashboardContent(sales: sales.value ?? const [], expenses: expenses.value ?? const []);
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.sales, required this.expenses});
  final List<FinanceEntry> sales; final List<FinanceEntry> expenses;
  @override Widget build(BuildContext context) {
    final now = DateTime.now();
    bool thisMonth(FinanceEntry e) => e.date.year == now.year && e.date.month == now.month;
    final monthlySales = sales.where(thisMonth).fold(0, (sum, e) => sum + e.amount);
    final monthlyExpenses = expenses.where(thisMonth).fold(0, (sum, e) => sum + e.amount);
    final target = 1000000;
    final summaries = [('今月の売上', formatCurrency(monthlySales), Icons.trending_up_rounded, const Color(0xFF2563EB)), ('今月の経費', formatCurrency(monthlyExpenses), Icons.receipt_long_outlined, const Color(0xFFF59E0B)), ('今月の利益', formatCurrency(monthlySales - monthlyExpenses), Icons.account_balance_wallet_outlined, const Color(0xFF10B981)), ('目標達成率', '${(monthlySales / target * 100).clamp(0, 999).toStringAsFixed(1)}%', Icons.flag_outlined, const Color(0xFF7C3AED))];
    return SingleChildScrollView(padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'ダッシュボード', subtitle: '事業の最新状況を、ひと目で確認できます。'), const SizedBox(height: 24),
      LayoutBuilder(builder: (_, constraints) { final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 520 ? 2 : 1; final width = (constraints.maxWidth - (columns - 1) * 16) / columns; return Wrap(spacing: 16, runSpacing: 16, children: summaries.map((item) => SizedBox(width: width, child: _SummaryCard(title: item.$1, value: item.$2, icon: item.$3, color: item.$4))).toList()); }),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('月別の推移', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 20), MonthlyChart(data: buildMonthlyTotals(sales, expenses))]))),
      const SizedBox(height: 20),
      LayoutBuilder(builder: (_, constraints) { final width = constraints.maxWidth >= 720 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth; return Wrap(spacing: 16, runSpacing: 16, children: [SizedBox(width: width, child: _RecentCard(title: '最近の売上', items: sales.take(5).toList(), color: const Color(0xFF2563EB))), SizedBox(width: width, child: _RecentCard(title: '最近の経費', items: expenses.take(5).toList(), color: const Color(0xFFF59E0B)))]); }),
    ]))));
  }
}

class _SummaryCard extends StatelessWidget { const _SummaryCard({required this.title, required this.value, required this.icon, required this.color}); final String title, value; final IconData icon; final Color color; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: Colors.blueGrey.shade700)), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color))]), const SizedBox(height: 18), FittedBox(child: Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))) ]))); }

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.title, required this.items, required this.color});
  final String title;
  final List<FinanceEntry> items;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const SizedBox(height: 120, child: Center(child: Text('データはまだありません')))
          else
            ...items.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Container(width: 4, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(formatDate(entry.date), style: Theme.of(context).textTheme.bodySmall),
                ])),
                Text(formatCurrency(entry.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
            )),
        ],
      ),
    ),
  );
}

class _DashboardError extends StatelessWidget { const _DashboardError({required this.onRetry}); final VoidCallback onRetry; @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_off_outlined, size: 52, color: Theme.of(context).colorScheme.error), const SizedBox(height: 16), const Text('経営データを読み込めませんでした'), const SizedBox(height: 12), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('再読み込み'))])); }
