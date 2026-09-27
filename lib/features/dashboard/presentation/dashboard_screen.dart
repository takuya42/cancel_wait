import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  static const summaries = [
    ('今月の売上', '¥0', Icons.trending_up_rounded, Color(0xFF147D64)),
    ('今月の経費', '¥0', Icons.receipt_long_outlined, Color(0xFFD97706)),
    ('今月の利益', '¥0', Icons.account_balance_wallet_outlined, Color(0xFF2563EB)),
    ('目標達成率', '0%', Icons.flag_outlined, Color(0xFF7C3AED)),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const PageHeader(title: 'ダッシュボード', subtitle: '事業の状況をすばやく確認できます。'),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 520 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(spacing: 16, runSpacing: 16, children: summaries.map((item) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.$1, style: TextStyle(color: Colors.blueGrey.shade700)), Icon(item.$3, color: item.$4)]),
          const SizedBox(height: 18), Text(item.$2, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6), Text('データ連携後に反映されます', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey)),
        ]))))).toList());
      }),
      const SizedBox(height: 24),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('月次サマリー', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10), Text('売上・経費の登録を開始すると、ここに事業の推移を表示します。', style: TextStyle(color: Colors.blueGrey.shade600)),
        const SizedBox(height: 24), Container(height: 180, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFF7FAF9), borderRadius: BorderRadius.circular(12)), child: const Text('レポート表示エリア')),
      ]))),
    ]))),
  );
}
