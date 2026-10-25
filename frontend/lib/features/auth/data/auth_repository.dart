import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  Future<UserModel> loginAsGuest({String? displayName}) async {
    final response = await _apiClient.dio.post(
      '/auth/guest',
      data: {
        if (displayName != null && displayName.isNotEmpty) 'displayName': displayName,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);

    await _storage.saveAuthData(
      token: token,
      userId: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );

    return user;
  }

  Future<UserModel> register({
    required String username,
    required String displayName,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'username': username,
        'displayName': displayName,
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);

    await _storage.saveAuthData(
      token: token,
      userId: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );

    return user;
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data);

    await _storage.saveAuthData(
      token: token,
      userId: user.id,
      username: user.username,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
    );

    return user;
  }

  Future<UserModel?> checkCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await _apiClient.dio.get('/users/me');
      final data = response.data['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (_) {
      await _storage.clearAuthData();
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearAuthData();
  }
}
