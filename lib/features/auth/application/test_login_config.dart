import 'package:flutter/foundation.dart';

/// Build-time configuration for the development-only test login.
class TestLoginConfig {
  const TestLoginConfig({
    required this.email,
    required this.password,
    required this.isReleaseMode,
  });

  factory TestLoginConfig.fromEnvironment() => const TestLoginConfig(
        email: String.fromEnvironment('TEST_LOGIN_EMAIL'),
        password: String.fromEnvironment('TEST_LOGIN_PASSWORD'),
        isReleaseMode: kReleaseMode,
      );

  final String email;
  final String password;
  final bool isReleaseMode;

  /// Release builds never expose the test login, even if defines are supplied.
  bool get isEnabled =>
      !isReleaseMode && email.trim().isNotEmpty && password.isNotEmpty;
}
