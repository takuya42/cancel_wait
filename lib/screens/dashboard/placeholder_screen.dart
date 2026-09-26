import 'package:flutter/material.dart';

import '../../widgets/page_header.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, required this.icon, super.key});
  final String title; final IconData icon;
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(32), child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    PageHeader(title: title), const SizedBox(height: 28), Expanded(child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: Colors.blueGrey.shade300), const SizedBox(height: 16), Text('$title画面は今後追加予定です', style: TextStyle(color: Colors.blueGrey.shade600))])))),
  ]))));
}
