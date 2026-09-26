import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/placeholder_screen.dart';
import '../screens/dashboard/waiting_list_screen.dart';
import '../screens/login_screen.dart';
import '../widgets/dashboard_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/availability', builder: (_, __) => const PlaceholderScreen(title: '空き枠', icon: Icons.event_available_outlined)),
        GoRoute(path: '/waiting-list', builder: (_, __) => const WaitingListScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const PlaceholderScreen(title: 'LINE通知', icon: Icons.notifications_none_rounded)),
        GoRoute(path: '/settings', builder: (_, __) => const PlaceholderScreen(title: '設定', icon: Icons.settings_outlined)),
      ],
    ),
  ],
);
