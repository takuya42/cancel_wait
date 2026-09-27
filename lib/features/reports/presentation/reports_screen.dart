import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: 'レポート',
    subtitle: '経営判断に必要な数字をまとめて確認します。',
    icon: Icons.analytics_outlined,
    sections: ['月次推移', '収支分析'],
  );
}
