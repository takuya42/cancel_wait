import 'package:business_management_tool/core/router/app_router.dart';
import 'package:business_management_tool/features/auth/application/auth_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('authRedirect', () {
    test('allows signed-out users to open authentication pages', () {
      expect(authRedirect(session: SessionStatus.signedOut, location: '/login'), isNull);
      expect(authRedirect(session: SessionStatus.signedOut, location: '/register'), isNull);
    });
    test('protects every management page', () {
      for (final location in ['/dashboard','/sales','/expenses','/reports','/business','/plans','/settings']) {
        expect(authRedirect(session: SessionStatus.signedOut, location: location), '/login', reason: location);
      }
    });
    test('sends authenticated users to the dashboard', () {
      expect(authRedirect(session: SessionStatus.authenticated, location: '/login'), '/dashboard');
      expect(authRedirect(session: SessionStatus.authenticated, location: '/register'), '/dashboard');
      expect(
        authRedirect(
          session: SessionStatus.authenticated,
          location: '/register',
          registrationInProgress: true,
        ),
        isNull,
      );
    });
    test('allows authenticated users to open management pages', () {
      expect(authRedirect(session: SessionStatus.authenticated, location: '/sales'), isNull);
    });
  });
}
