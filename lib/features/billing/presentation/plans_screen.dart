import 'package:flutter/material.dart';

import '../../../core/widgets/page_header.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1050),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: '料金プラン', subtitle: '利用中のプランと、今後利用できる機能を確認できます。'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBFDBFE))),
          child: const Row(children: [
            Icon(Icons.verified_outlined, color: Color(0xFF2563EB)), SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('現在のプラン：無料プラン', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('基本機能を利用中です。契約手続きや請求は発生していません。')]))
          ]),
        ),
        const SizedBox(height: 24),
        Text('プラン比較', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final cardWidth = constraints.maxWidth >= 720 ? (constraints.maxWidth - 18) / 2 : constraints.maxWidth;
          return Wrap(spacing: 18, runSpacing: 18, children: [
            SizedBox(width: cardWidth, child: const _PlanCard(
              title: '無料プラン', subtitle: '日々の収支管理をシンプルに', icon: Icons.spa_outlined,
              features: ['基本的な売上管理', '基本的な経費管理', 'ダッシュボード'], current: true,
            )),
            SizedBox(width: cardWidth, child: _PlanCard(
              title: 'Proプラン', subtitle: 'より詳しい分析と業務効率化', icon: Icons.workspace_premium_outlined,
              features: const ['売上・経費管理', '詳細レポート', '領収書管理（近日対応）', 'OCR（近日対応）', 'CSV・PDF出力（近日対応）'],
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proプランは現在準備中です。提供開始までお待ちください。'))),
            )),
          ]);
        }),
        const SizedBox(height: 18),
        const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, size: 18, color: Colors.blueGrey), SizedBox(width: 8), Expanded(child: Text('Proプランの料金と提供開始時期は未定です。決済情報の入力や課金は行われません。', style: TextStyle(color: Colors.blueGrey)))]),
      ]),
    )),
  );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.subtitle, required this.icon, required this.features, this.current = false, this.onPressed});
  final String title, subtitle;
  final IconData icon;
  final List<String> features;
  final bool current;
  final VoidCallback? onPressed;

  @override Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Theme.of(context).colorScheme.primary)), const Spacer(), if (current) const Chip(avatar: Icon(Icons.check_circle, size: 17), label: Text('利用中'))]),
      const SizedBox(height: 20),
      Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), Text(subtitle, style: TextStyle(color: Colors.blueGrey.shade600)),
      const SizedBox(height: 24),
      ...features.map((feature) => Padding(padding: const EdgeInsets.only(bottom: 13), child: Row(children: [const Icon(Icons.check_rounded, size: 20, color: Color(0xFF10B981)), const SizedBox(width: 10), Expanded(child: Text(feature))]))),
      const SizedBox(height: 12),
      if (current) const OutlinedButton(onPressed: null, child: Text('現在のプラン')) else FilledButton.icon(onPressed: onPressed, icon: const Icon(Icons.arrow_upward_rounded), label: const Text('Proにアップグレード')),
    ])),
  );
}
