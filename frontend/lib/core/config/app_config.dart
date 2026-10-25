class AppConfig {
  AppConfig._();

  // Production Render deployment defaults
  static const String defaultApiUrl = 'https://doodle-duel-9wbf.onrender.com/api/v1';
  static const String defaultWsUrl = 'wss://doodle-duel-9wbf.onrender.com/ws';

  // Overrides via --dart-define=API_URL=... and --dart-define=WS_URL=...
  static const String _envApiUrl = String.fromEnvironment('API_URL');
  static const String _envWsUrl = String.fromEnvironment('WS_URL');

  static String? _customApiUrl;
  static String? _customWsUrl;

  /// Configure custom endpoints at runtime (e.g., for local developer toggling)
  static void setCustomEndpoints({String? apiUrl, String? wsUrl}) {
    _customApiUrl = apiUrl;
    _customWsUrl = wsUrl;
  }

  /// REST API Base URL (defaults to Render production cloud backend)
  static String get baseUrl {
    if (_customApiUrl != null && _customApiUrl!.isNotEmpty) {
      return _customApiUrl!;
    }
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }
    return defaultApiUrl;
  }

  /// STOMP WebSocket URL (defaults to Render production cloud backend)
  static String get wsUrl {
    if (_customWsUrl != null && _customWsUrl!.isNotEmpty) {
      return _customWsUrl!;
    }
    if (_envWsUrl.isNotEmpty) {
      return _envWsUrl;
    }
    return defaultWsUrl;
  }
}
