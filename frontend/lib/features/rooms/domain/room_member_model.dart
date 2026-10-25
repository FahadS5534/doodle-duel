import 'package:equatable/equatable.dart';

class RoomMemberModel extends Equatable {
  final String userId;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final int level;
  final String role; // HOST, PLAYER
  final bool isReady;
  final String connectionStatus; // CONNECTED, DISCONNECTED

  const RoomMemberModel({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.level = 1,
    this.role = 'PLAYER',
    this.isReady = false,
    this.connectionStatus = 'CONNECTED',
  });

  bool get isHost => role.toUpperCase() == 'HOST';

  factory RoomMemberModel.fromJson(Map<String, dynamic> json) {
    return RoomMemberModel(
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['username']?.toString() ?? 'Player',
      avatarUrl: json['avatarUrl']?.toString(),
      level: json['level'] is int ? json['level'] : 1,
      role: json['role']?.toString() ?? 'PLAYER',
      isReady: json['ready'] == true || json['isReady'] == true,
      connectionStatus: json['connectionStatus']?.toString() ?? 'CONNECTED',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'level': level,
    'role': role,
    'isReady': isReady,
    'connectionStatus': connectionStatus,
  };

  @override
  List<Object?> get props => [
    userId,
    username,
    displayName,
    avatarUrl,
    level,
    role,
    isReady,
    connectionStatus,
  ];
}
