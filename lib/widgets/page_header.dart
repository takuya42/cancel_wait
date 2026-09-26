import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({required this.title, this.subtitle, this.action, super.key});
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: TextStyle(color: Colors.blueGrey.shade600)),
        ],
      ],
    );
    return LayoutBuilder(builder: (context, constraints) {
      if (action != null && constraints.maxWidth < 560) {
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [heading, const SizedBox(height: 18), action!]);
      }
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: heading), if (action != null) action!]);
    });
  }
}
