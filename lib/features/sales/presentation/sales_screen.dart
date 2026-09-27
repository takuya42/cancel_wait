import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: '売上',
    subtitle: '売上の記録と入金状況を管理します。',
    icon: Icons.trending_up_rounded,
    sections: ['売上サマリー', '売上明細'],
  );
}
