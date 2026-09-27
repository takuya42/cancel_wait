import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_providers.dart';

class ManagementShell extends ConsumerWidget {
  const ManagementShell({required this.child, super.key});
  final Widget child;

  static const items = [
    ('ダッシュボード', Icons.dashboard_outlined, '/dashboard'),
    ('売上', Icons.trending_up_rounded, '/sales'),
    ('経費', Icons.receipt_long_outlined, '/expenses'),
    ('レポート', Icons.analytics_outlined, '/reports'),
    ('事業者情報', Icons.business_outlined, '/business'),
    ('料金プラン', Icons.workspace_premium_outlined, '/plans'),
    ('設定', Icons.settings_outlined, '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final path = GoRouterState.of(context).uri.path;
    final selected = items.indexWhere((item) => path.startsWith(item.$3));
    final navigation = _Navigation(
      selected: selected < 0 ? 0 : selected,
      onLogout: () async {
        await ref.read(authControllerProvider).logout();
        if (context.mounted) context.go('/login');
      },
    );
    return Scaffold(
      appBar: wide ? null : AppBar(
        title: const _Brand(),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      drawer: wide ? null : Drawer(child: SafeArea(child: navigation)),
      body: Row(children: [
        if (wide) SizedBox(width: 250, child: Material(color: Colors.white, child: SafeArea(child: navigation))),
        Expanded(child: child),
      ]),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selected, required this.onLogout});
  final int selected;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Column(children: [
    const Padding(padding: EdgeInsets.fromLTRB(22, 20, 22, 28), child: _Brand()),
    Expanded(child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: ManagementShell.items.length,
      itemBuilder: (context, index) {
        final item = ManagementShell.items[index];
        return Padding(padding: const EdgeInsets.only(bottom: 4), child: ListTile(
          selected: selected == index,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(item.$2), title: Text(item.$1),
          onTap: () { context.go(item.$3); if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) Navigator.pop(context); },
        ));
      },
    )),
    const Divider(height: 1),
    Padding(padding: const EdgeInsets.all(12), child: ListTile(
      leading: const Icon(Icons.logout_rounded), title: const Text('ログアウト'), onTap: onLogout,
    )),
  ]);
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.insights_rounded, color: Colors.white, size: 22)),
    const SizedBox(width: 10),
    Text('経営管理ツール', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
  ]);
}
