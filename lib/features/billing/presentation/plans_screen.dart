import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: '料金プラン',
    subtitle: '利用中のプランと提供機能を確認します。',
    icon: Icons.workspace_premium_outlined,
    sections: ['現在のプラン', 'プラン比較'],
  );
}
