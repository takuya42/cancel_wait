import 'package:flutter/foundation.dart';

/// Development-only features can be disabled for release from this one place.
abstract final class AppConfig {
  static const bool enableDemoLogin = !kReleaseMode;
}
