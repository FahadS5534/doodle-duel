import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUsername = 'auth_username';
  static const String _keyDisplayName = 'auth_display_name';
  static const String _keyAvatarUrl = 'auth_avatar_url';

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String username,
    required String displayName,
    required String? avatarUrl,
  }) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
      await _secureStorage.write(key: _keyUserId, value: userId);
      await _secureStorage.write(key: _keyUsername, value: username);
      await _secureStorage.write(key: _keyDisplayName, value: displayName);
      if (avatarUrl != null) {
        await _secureStorage.write(key: _keyAvatarUrl, value: avatarUrl);
      }
    } catch (_) {
      // Fallback for environments with secure storage restrictions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyDisplayName, displayName);
      if (avatarUrl != null) {
        await prefs.setString(_keyAvatarUrl, avatarUrl);
      }
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _keyToken);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getUserId() async {
    try {
      final id = await _secureStorage.read(key: _keyUserId);
      if (id != null) return id;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<String?> getDisplayName() async {
    try {
      final name = await _secureStorage.read(key: _keyDisplayName);
      if (name != null) return name;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDisplayName);
  }

  Future<String?> getAvatarUrl() async {
    try {
      final url = await _secureStorage.read(key: _keyAvatarUrl);
      if (url != null) return url;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatarUrl);
  }

  Future<void> clearAuthData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyDisplayName);
    await prefs.remove(_keyAvatarUrl);
  }
}
