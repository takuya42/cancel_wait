import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class BusinessScreen extends StatelessWidget {
  const BusinessScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: '事業者情報',
    subtitle: '事業者の基本情報とメンバーを管理します。',
    icon: Icons.business_outlined,
    sections: ['基本情報', 'メンバー'],
  );
}
