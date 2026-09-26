import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({required this.child, super.key});
  final Widget child;

  static const _items = [
    (label: 'ホーム', icon: Icons.home_outlined, selected: Icons.home_rounded, path: '/home'),
    (label: '空き枠', icon: Icons.event_available_outlined, selected: Icons.event_available_rounded, path: '/availability'),
    (label: 'キャンセル待ち', icon: Icons.people_outline, selected: Icons.people_rounded, path: '/waiting-list'),
    (label: 'LINE通知', icon: Icons.notifications_none_rounded, selected: Icons.notifications_rounded, path: '/notifications'),
    (label: '設定', icon: Icons.settings_outlined, selected: Icons.settings_rounded, path: '/settings'),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _items.indexWhere((item) => location.startsWith(item.path));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final navigation = _Navigation(selectedIndex: _selectedIndex(context));
    return Scaffold(
      appBar: wide ? null : AppBar(title: const _Brand(compact: true), backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      drawer: wide ? null : Drawer(child: SafeArea(child: navigation)),
      body: Row(children: [
        if (wide) SizedBox(width: 260, child: Material(color: Colors.white, child: SafeArea(child: navigation))),
        Expanded(child: child),
      ]),
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Padding(padding: EdgeInsets.fromLTRB(24, 20, 20, 28), child: _Brand()),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: DashboardShell._items.length,
          itemBuilder: (context, index) {
            final item = DashboardShell._items[index];
            final selected = index == selectedIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                selected: selected,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                leading: Icon(selected ? item.selected : item.icon),
                title: Text(item.label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                onTap: () { Navigator.maybePop(context); context.go(item.path); },
              ),
            );
          },
        ),
      ),
      const Divider(height: 1),
      ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10), leading: const Icon(Icons.logout_rounded), title: const Text('ログアウト'), onTap: () => context.go('/login')),
    ]);
  }
}

class _Brand extends StatelessWidget {
  const _Brand({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: EdgeInsets.all(compact ? 6 : 8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.update_rounded, color: Colors.white, size: compact ? 20 : 24)),
    const SizedBox(width: 10),
    Text('CancelWait', style: (compact ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.titleLarge)?.copyWith(fontWeight: FontWeight.w700)),
  ]);
}
