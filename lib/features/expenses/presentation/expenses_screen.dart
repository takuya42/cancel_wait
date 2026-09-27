import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: '経費',
    subtitle: '日々の支出を整理して収支を把握します。',
    icon: Icons.receipt_long_outlined,
    sections: ['経費サマリー', '経費明細'],
  );
}
