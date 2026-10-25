import 'package:equatable/equatable.dart';
import 'room_member_model.dart';

class RoomModel extends Equatable {
  final String id;
  final String roomCode;
  final String name;
  final String hostId;
  final String hostName;
  final String visibility; // PUBLIC, PRIVATE
  final String status; // WAITING, IN_PROGRESS, FINISHED
  final int maxPlayers;
  final int totalRounds;
  final int drawTimeSeconds;
  final String difficulty;
  final String category;
  final int currentPlayers;
  final int readyPlayers;
  final List<RoomMemberModel> members;

  const RoomModel({
    required this.id,
    required this.roomCode,
    required this.name,
    required this.hostId,
    required this.hostName,
    this.visibility = 'PUBLIC',
    this.status = 'WAITING',
    this.maxPlayers = 8,
    this.totalRounds = 4,
    this.drawTimeSeconds = 60,
    this.difficulty = 'MEDIUM',
    this.category = 'GENERAL',
    this.currentPlayers = 1,
    this.readyPlayers = 1,
    this.members = const [],
  });

  bool get isWaiting => status.toUpperCase() == 'WAITING';
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    var rawMembers = json['members'];
    List<RoomMemberModel> memberList = [];
    if (rawMembers is List) {
      memberList = rawMembers
          .map((m) => RoomMemberModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return RoomModel(
      id: json['id']?.toString() ?? '',
      roomCode: json['roomCode']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Room',
      hostId: json['hostId']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? 'Host',
      visibility: json['visibility']?.toString() ?? 'PUBLIC',
      status: json['status']?.toString() ?? 'WAITING',
      maxPlayers: json['maxPlayers'] is int ? json['maxPlayers'] : 8,
      totalRounds: json['totalRounds'] is int ? json['totalRounds'] : 4,
      drawTimeSeconds: json['drawTimeSeconds'] is int ? json['drawTimeSeconds'] : 60,
      difficulty: json['difficulty']?.toString() ?? 'MEDIUM',
      category: json['category']?.toString() ?? 'GENERAL',
      currentPlayers: json['currentPlayers'] is int ? json['currentPlayers'] : memberList.length,
      readyPlayers: json['readyPlayers'] is int ? json['readyPlayers'] : memberList.where((m) => m.isReady).length,
      members: memberList,
    );
  }

  @override
  List<Object?> get props => [
    id,
    roomCode,
    name,
    hostId,
    hostName,
    visibility,
    status,
    maxPlayers,
    totalRounds,
    drawTimeSeconds,
    difficulty,
    category,
    currentPlayers,
    readyPlayers,
    members,
  ];
}
