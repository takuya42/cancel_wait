import 'package:flutter/material.dart';
import 'page_header.dart';

class FeatureScaffold extends StatelessWidget {
  const FeatureScaffold({required this.title, required this.subtitle, required this.icon, required this.sections, super.key});
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> sections;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 16 : 32),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PageHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth >= 760 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;
          return Wrap(spacing: 16, runSpacing: 16, children: sections.map((section) => SizedBox(
            width: width,
            child: Card(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                Text(section, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('ここに$sectionの情報や操作を表示します。', style: TextStyle(color: Colors.blueGrey.shade600)),
              ]),
            )),
          )).toList());
        }),
      ]),
    )),
  );
}
