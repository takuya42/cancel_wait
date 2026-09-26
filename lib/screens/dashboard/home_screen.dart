import 'package:flutter/material.dart';

import '../../widgets/page_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PageHeader(title: 'おはようございます', subtitle: '今日も一日の状況を確認しましょう。'),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth < 700 ? constraints.maxWidth : (constraints.maxWidth - 32) / 3;
          return Wrap(spacing: 16, runSpacing: 16, children: [
            _StatusCard(width: width, label: '今日の空き枠', value: '2件', icon: Icons.event_available_outlined, color: const Color(0xFF2563EB)),
            _StatusCard(width: width, label: 'キャンセル待ち', value: '5人', icon: Icons.people_outline, color: const Color(0xFF7C3AED)),
            _StatusCard(width: width, label: '本日の通知', value: '3件', icon: Icons.notifications_none_rounded, color: const Color(0xFF059669)),
          ]);
        }),
        const SizedBox(height: 32),
        Text('最近発生した空き枠', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(24), child: LayoutBuilder(builder: (context, constraints) {
          final details = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Icon(Icons.calendar_today_outlined, size: 18), SizedBox(width: 8), Text('9月28日  15:00〜16:00', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 16),
            Wrap(spacing: 24, runSpacing: 8, children: const [_Detail(icon: Icons.person_outline, text: '担当：田中'), _Detail(icon: Icons.groups_outlined, text: 'キャンセル待ち：3人')]),
          ]);
          final button = FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.send_outlined), label: const Text('LINEで通知'));
          return constraints.maxWidth < 600 ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [details, const SizedBox(height: 22), button]) : Row(children: [Expanded(child: details), button]);
        }))),
      ]))),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.width, required this.label, required this.value, required this.icon, required this.color});
  final double width; final String label; final String value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
    const SizedBox(width: 16),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.blueGrey.shade600)), const SizedBox(height: 5), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))]),
  ]))));
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text}); final IconData icon; final String text;
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: Colors.blueGrey), const SizedBox(width: 7), Text(text)]);
}
