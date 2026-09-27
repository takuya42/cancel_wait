import 'package:business_management_tool/features/auth/application/test_login_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestLoginConfig', () {
    test('is enabled when the debug build flag and environment flag are on', () {
      expect(
        const TestLoginConfig(
          isDebugMode: true,
          enabledByEnvironment: true,
        ).isEnabled,
        isTrue,
      );
      expect(
        const TestLoginConfig(
          isDebugMode: true,
          enabledByEnvironment: false,
        ).isEnabled,
        isFalse,
      );
    });

    test('is always disabled outside a debug build', () {
      expect(
        const TestLoginConfig(
          isDebugMode: false,
          enabledByEnvironment: true,
        ).isEnabled,
        isFalse,
      );
    });
  });
}
