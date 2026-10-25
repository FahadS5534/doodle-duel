import '../../../core/network/api_client.dart';
import '../domain/room_model.dart';

class RoomRepository {
  final ApiClient _apiClient = ApiClient();

  Future<RoomModel> createRoom({
    required String name,
    String visibility = 'PUBLIC',
    int maxPlayers = 8,
    int totalRounds = 4,
    int drawTimeSeconds = 60,
    String difficulty = 'MEDIUM',
    String category = 'GENERAL',
  }) async {
    final response = await _apiClient.dio.post(
      '/rooms',
      data: {
        'name': name,
        'visibility': visibility,
        'maxPlayers': maxPlayers,
        'totalRounds': totalRounds,
        'drawTimeSeconds': drawTimeSeconds,
        'difficulty': difficulty,
        'category': category,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return RoomModel.fromJson(data);
  }

  Future<RoomModel> joinRoom(String roomCode) async {
    final response = await _apiClient.dio.post(
      '/rooms/join',
      data: {'roomCode': roomCode.trim().toUpperCase()},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return RoomModel.fromJson(data);
  }

  Future<RoomModel> getRoomDetails(String roomId) async {
    final response = await _apiClient.dio.get('/rooms/$roomId');
    final data = response.data['data'] as Map<String, dynamic>;
    return RoomModel.fromJson(data);
  }

  Future<void> leaveRoom(String roomId) async {
    await _apiClient.dio.post('/rooms/$roomId/leave');
  }

  Future<RoomModel> toggleReady(String roomId) async {
    final response = await _apiClient.dio.patch('/rooms/$roomId/ready');
    final data = response.data['data'] as Map<String, dynamic>;
    return RoomModel.fromJson(data);
  }

  Future<RoomModel> updateSettings(String roomId, Map<String, dynamic> settings) async {
    final response = await _apiClient.dio.patch('/rooms/$roomId/settings', data: settings);
    final data = response.data['data'] as Map<String, dynamic>;
    return RoomModel.fromJson(data);
  }

  Future<List<RoomModel>> getPublicRooms({String? difficulty, String? category}) async {
    final response = await _apiClient.dio.get(
      '/rooms/public',
      queryParameters: {
        if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
        if (category != null && category.isNotEmpty) 'category': category,
      },
    );

    final data = response.data['data'];
    if (data is Map && data.containsKey('content')) {
      final list = data['content'] as List;
      return list.map((item) => RoomModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
