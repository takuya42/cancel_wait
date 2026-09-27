import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/application/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/billing/presentation/plans_screen.dart';
import '../../features/business/presentation/business_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../widgets/management_shell.dart';

String? authRedirect({
  required SessionStatus session,
  required String location,
  bool registrationInProgress = false,
}) {
  if (session == SessionStatus.loading) return null;
  final isAuthPage = location == '/login' || location == '/register';
  final authenticated = session == SessionStatus.authenticated;
  if (!authenticated && !isAuthPage) return '/login';
  if (authenticated && isAuthPage) {
    if (location == '/register' && registrationInProgress) return null;
    return '/dashboard';
  }
  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref
    ..onDispose(notifier.dispose)
    ..listen(sessionStatusProvider, (_, _) => notifier.refresh())
    ..listen(registrationInProgressProvider, (_, _) => notifier.refresh());
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (_, state) => authRedirect(
      session: ref.read(sessionStatusProvider),
      location: state.matchedLocation,
      registrationInProgress: ref.read(registrationInProgressProvider),
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      ShellRoute(builder: (_, _, child) => ManagementShell(child: child), routes: [
        GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
        GoRoute(path: '/sales', builder: (_, _) => const SalesScreen()),
        GoRoute(path: '/expenses', builder: (_, _) => const ExpensesScreen()),
        GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
        GoRoute(path: '/business', builder: (_, _) => const BusinessScreen()),
        GoRoute(path: '/plans', builder: (_, _) => const PlansScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ]),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
