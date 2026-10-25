import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  // Override this at runtime or via environment if needed
  static String? _customHost;

  static void setCustomHost(String host) {
    _customHost = host;
  }

  static String get host {
    if (_customHost != null && _customHost!.isNotEmpty) {
      return _customHost!;
    }
    if (kIsWeb) {
      return 'localhost:8080';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator loopback alias to host machine
        return '10.0.2.2:8080';
      case TargetPlatform.iOS:
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return 'localhost:8080';
    }
  }

  static String get baseUrl => 'http://$host/api/v1';
  static String get wsUrl => 'ws://$host/ws';
}
