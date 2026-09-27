import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../domain/finance_entry.dart';

class MonthlyTotal {
  const MonthlyTotal(this.month, this.sales, this.expenses);
  final DateTime month;
  final int sales;
  final int expenses;
  int get profit => sales - expenses;
}

List<MonthlyTotal> buildMonthlyTotals(List<FinanceEntry> sales, List<FinanceEntry> expenses, {int months = 6, DateTime? now}) {
  final today = now ?? DateTime.now();
  return List.generate(months, (index) {
    final month = DateTime(today.year, today.month - (months - 1 - index));
    int total(List<FinanceEntry> entries) => entries.where((e) => e.date.year == month.year && e.date.month == month.month).fold(0, (sum, e) => sum + e.amount);
    return MonthlyTotal(month, total(sales), total(expenses));
  });
}

class MonthlyChart extends StatelessWidget {
  const MonthlyChart({required this.data, super.key});
  final List<MonthlyTotal> data;

  @override
  Widget build(BuildContext context) {
    if (data.every((item) => item.sales == 0 && item.expenses == 0)) {
      return Container(height: 220, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)), child: const Text('グラフに表示するデータがありません'));
    }
    return Column(children: [
      const Row(mainAxisAlignment: MainAxisAlignment.end, children: [_Legend(color: Color(0xFF2563EB), label: '売上'), SizedBox(width: 16), _Legend(color: Color(0xFFF59E0B), label: '経費'), SizedBox(width: 16), _Legend(color: Color(0xFF10B981), label: '利益')]),
      const SizedBox(height: 14),
      SizedBox(height: 220, width: double.infinity, child: CustomPaint(painter: _ChartPainter(data, Theme.of(context).colorScheme.outlineVariant))),
      Row(children: data.map((item) => Expanded(child: Text('${item.month.month}月', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall))).toList()),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color; final String label;
  @override Widget build(BuildContext context) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 5), Text(label, style: Theme.of(context).textTheme.bodySmall)]);
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.data, this.gridColor);
  final List<MonthlyTotal> data; final Color gridColor;
  @override void paint(Canvas canvas, Size size) {
    final maxValue = math.max(1, data.expand((e) => [e.sales, e.expenses, e.profit.abs()]).reduce(math.max));
    final grid = Paint()..color = gridColor..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) { final y = size.height * i / 4; canvas.drawLine(Offset(0, y), Offset(size.width, y), grid); }
    final colors = [const Color(0xFF2563EB), const Color(0xFFF59E0B), const Color(0xFF10B981)];
    final groupWidth = size.width / data.length;
    final barWidth = math.min(15.0, groupWidth / 5);
    for (var i = 0; i < data.length; i++) {
      final values = [data[i].sales, data[i].expenses, math.max(0, data[i].profit)];
      for (var j = 0; j < 3; j++) {
        final height = size.height * values[j] / maxValue;
        final x = groupWidth * i + groupWidth / 2 + (j - 1) * (barWidth + 2);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - barWidth / 2, size.height - height, barWidth, height), const Radius.circular(3)), Paint()..color = colors[j]);
      }
    }
  }
  @override bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.data != data || oldDelegate.gridColor != gridColor;
}

String compactCurrency(int amount) => amount.abs() >= 10000 ? '¥${(amount / 10000).toStringAsFixed(amount % 10000 == 0 ? 0 : 1)}万' : formatCurrency(amount);
