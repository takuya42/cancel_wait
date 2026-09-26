import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/placeholder_screen.dart';
import '../screens/dashboard/waiting_list_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../widgets/dashboard_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionStatusProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (session == SessionStatus.loading) return null;
      final publicPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final authenticated = session == SessionStatus.firebase || session == SessionStatus.demo;
      if (!authenticated && !publicPage) return '/login';
      if (authenticated && publicPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (_, __, child) => DashboardShell(child: child),
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
});
