import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/page_header.dart';
import '../../transactions/application/finance_providers.dart';
import '../../transactions/domain/finance_entry.dart';
import '../../transactions/presentation/monthly_chart.dart';

enum ReportPeriod { thisMonth, lastMonth, thisYear }

class ReportsScreen extends ConsumerStatefulWidget { const ReportsScreen({super.key}); @override ConsumerState<ReportsScreen> createState() => _ReportsScreenState(); }
class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod period = ReportPeriod.thisMonth;
  @override Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesProvider); final expensesAsync = ref.watch(expensesProvider);
    return SingleChildScrollView(padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: 'レポート', subtitle: '期間ごとの収支とカテゴリ構成を分析します。', action: SegmentedButton<ReportPeriod>(segments: const [ButtonSegment(value: ReportPeriod.thisMonth, label: Text('今月')), ButtonSegment(value: ReportPeriod.lastMonth, label: Text('先月')), ButtonSegment(value: ReportPeriod.thisYear, label: Text('今年'))], selected: {period}, onSelectionChanged: (value) => setState(() => period = value.first))), const SizedBox(height: 24),
      if (salesAsync.isLoading || expensesAsync.isLoading) const Card(child: SizedBox(height: 320, child: Center(child: CircularProgressIndicator())))
      else if (salesAsync.hasError || expensesAsync.hasError) Card(child: Padding(padding: const EdgeInsets.all(48), child: Center(child: Column(children: [const Text('レポートを読み込めませんでした。'), const SizedBox(height: 12), OutlinedButton(onPressed: () { ref.invalidate(salesProvider); ref.invalidate(expensesProvider); }, child: const Text('再読み込み'))]))))
      else _ReportBody(period: period, allSales: salesAsync.value ?? const [], allExpenses: expensesAsync.value ?? const []),
    ]))));
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({required this.period, required this.allSales, required this.allExpenses});
  final ReportPeriod period; final List<FinanceEntry> allSales, allExpenses;
  @override Widget build(BuildContext context) {
    final now = DateTime.now(); final selectedMonth = period == ReportPeriod.lastMonth ? DateTime(now.year, now.month - 1) : now;
    bool included(FinanceEntry e) => period == ReportPeriod.thisYear ? e.date.year == now.year : e.date.year == selectedMonth.year && e.date.month == selectedMonth.month;
    final sales = allSales.where(included).toList(); final expenses = allExpenses.where(included).toList();
    final salesTotal = sales.fold(0, (sum, e) => sum + e.amount); final expenseTotal = expenses.fold(0, (sum, e) => sum + e.amount);
    final categories = <String, int>{}; for (final e in sales) { categories['売上・${e.category}'] = (categories['売上・${e.category}'] ?? 0) + e.amount; } for (final e in expenses) { categories['経費・${e.category}'] = (categories['経費・${e.category}'] ?? 0) + e.amount; }
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(children: [
      LayoutBuilder(builder: (_, c) { final width = c.maxWidth >= 720 ? (c.maxWidth - 32) / 3 : c.maxWidth; return Wrap(spacing: 16, runSpacing: 16, children: [('売上合計', salesTotal, const Color(0xFF2563EB)), ('経費合計', expenseTotal, const Color(0xFFF59E0B)), ('利益', salesTotal - expenseTotal, const Color(0xFF10B981))].map((e) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.$1), const SizedBox(height: 10), Text(formatCurrency(e.$2), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: e.$3))]))))).toList()); }),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('月別推移', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 20), MonthlyChart(data: buildMonthlyTotals(allSales.where((e) => period != ReportPeriod.thisYear || e.date.year == now.year).toList(), allExpenses.where((e) => period != ReportPeriod.thisYear || e.date.year == now.year).toList(), months: period == ReportPeriod.thisYear ? 12 : 6, now: period == ReportPeriod.thisYear ? DateTime(now.year, 12) : selectedMonth))]))),
      const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('カテゴリ別集計', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 18), if (categories.isEmpty) const SizedBox(height: 120, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.donut_large_outlined, color: Colors.blueGrey), SizedBox(height: 10), Text('対象期間のデータがありません')])) ) else ...sortedCategories.map((e) => _CategoryBar(label: e.key, value: e.value, maxValue: sortedCategories.first.value, expense: e.key.startsWith('経費・'))) ]))),
    ]);
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.label, required this.value, required this.maxValue, required this.expense});
  final String label;
  final int value, maxValue;
  final bool expense;
  @override Widget build(BuildContext context) {
    final color = expense ? const Color(0xFFF59E0B) : const Color(0xFF2563EB);
    return Padding(padding: const EdgeInsets.only(bottom: 18), child: Column(children: [
      Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))), Text(formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.w700))]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: maxValue == 0 ? 0 : value / maxValue, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: .1))),
    ]));
  }
}
