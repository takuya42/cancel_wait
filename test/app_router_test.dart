import 'package:cancel_wait/providers/auth_providers.dart';
import 'package:cancel_wait/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect', () {
    test('allows signed-out users to open authentication pages', () {
      expect(
        authRedirect(session: SessionStatus.signedOut, location: '/login'),
        isNull,
      );
      expect(
        authRedirect(session: SessionStatus.signedOut, location: '/register'),
        isNull,
      );
    });

    test('protects every store management page', () {
      for (final location in [
        '/home',
        '/availability',
        '/waiting-list',
        '/notifications',
        '/settings',
      ]) {
        expect(
          authRedirect(session: SessionStatus.signedOut, location: location),
          '/login',
          reason: location,
        );
      }
    });

    test('allows public reservation pages without a session', () {
      expect(
        authRedirect(
          session: SessionStatus.signedOut,
          location: '/reserve/shop-1',
        ),
        isNull,
      );
    });

    test('does not redirect authenticated users away from reservations', () {
      expect(
        authRedirect(
          session: SessionStatus.firebase,
          location: '/reserve/shop-1',
        ),
        isNull,
      );
    });

    test('waits for Firestore provisioning during registration', () {
      expect(
        authRedirect(
          session: SessionStatus.firebase,
          location: '/register',
          registrationInProgress: true,
        ),
        isNull,
      );
      expect(
        authRedirect(
          session: SessionStatus.firebase,
          location: '/register',
        ),
        '/home',
      );
    });

    test('keeps the test login session behavior', () {
      expect(
        authRedirect(session: SessionStatus.demo, location: '/login'),
        '/home',
      );
    });
  });
}
