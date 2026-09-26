import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/dashboard/waiting_list_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/dashboard/availability_screen.dart';
import '../screens/dashboard/notifications_screen.dart';
import '../screens/dashboard/settings_screen.dart';
import '../widgets/dashboard_shell.dart';

String? authRedirect({
  required SessionStatus session,
  required String location,
  bool registrationInProgress = false,
}) {
  if (session == SessionStatus.loading) return null;

  final isAuthPage = location == '/login' || location == '/register';
  final isPublicReservation =
      location == '/reserve' || location.startsWith('/reserve/');
  // Keep existing links working while /reserve is rolled out.
  final isLegacyBooking = location == '/book' || location.startsWith('/book/');
  final isPublicPage = isAuthPage || isPublicReservation || isLegacyBooking;
  final isAuthenticated =
      session == SessionStatus.firebase || session == SessionStatus.demo;

  if (!isAuthenticated && !isPublicPage) return '/login';
  if (isAuthenticated && isAuthPage) {
    if (location == '/register' && registrationInProgress) return null;
    return '/home';
  }
  return null;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen(sessionStatusProvider, (_, _) => refreshNotifier.refresh())
    ..listen(
      registrationInProgressProvider,
      (_, _) => refreshNotifier.refresh(),
    );

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      return authRedirect(
        session: ref.read(sessionStatusProvider),
        location: state.matchedLocation,
        registrationInProgress: ref.read(registrationInProgressProvider),
      );
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
        path: '/reserve/:shopId',
        builder: (_, state) =>
            BookingScreen(shopId: state.pathParameters['shopId']!),
      ),
      GoRoute(
        path: '/book/:shopId',
        redirect: (_, state) => '/reserve/${state.pathParameters['shopId']}',
      ),
      ShellRoute(
        builder: (_, _, child) => DashboardShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          GoRoute(path: '/availability', builder: (_, _) => const AvailabilityScreen()),
          GoRoute(path: '/waiting-list', builder: (_, _) => const WaitingListScreen()),
          GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
