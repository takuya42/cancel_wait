import 'package:flutter/material.dart';
import '../../../core/widgets/feature_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const FeatureScaffold(
    title: '設定',
    subtitle: 'アカウントとサービスの設定を管理します。',
    icon: Icons.settings_outlined,
    sections: ['アカウント設定', '通知設定'],
  );
}
