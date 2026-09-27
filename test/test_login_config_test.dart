import 'package:business_management_tool/features/auth/application/test_login_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestLoginConfig', () {
    test('is enabled only when both credentials exist in a non-release build', () {
      expect(
        const TestLoginConfig(
          email: 'test@example.com',
          password: 'password',
          isReleaseMode: false,
        ).isEnabled,
        isTrue,
      );
      expect(
        const TestLoginConfig(
          email: '',
          password: 'password',
          isReleaseMode: false,
        ).isEnabled,
        isFalse,
      );
      expect(
        const TestLoginConfig(
          email: 'test@example.com',
          password: '',
          isReleaseMode: false,
        ).isEnabled,
        isFalse,
      );
    });

    test('is always disabled in a release build', () {
      expect(
        const TestLoginConfig(
          email: 'test@example.com',
          password: 'password',
          isReleaseMode: true,
        ).isEnabled,
        isFalse,
      );
    });
  });
}
