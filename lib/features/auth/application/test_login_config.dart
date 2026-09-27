import 'package:flutter/foundation.dart';

/// Build-time configuration for the development-only test login.
class TestLoginConfig {
  const TestLoginConfig({
    required this.isDebugMode,
    required this.enabledByEnvironment,
  });

  factory TestLoginConfig.fromEnvironment() => const TestLoginConfig(
        isDebugMode: kDebugMode,
        enabledByEnvironment: bool.fromEnvironment(
          'ENABLE_TEST_LOGIN',
          defaultValue: true,
        ),
      );

  final bool isDebugMode;
  final bool enabledByEnvironment;

  /// Profile and release builds never expose the test login.
  bool get isEnabled => isDebugMode && enabledByEnvironment;
}
