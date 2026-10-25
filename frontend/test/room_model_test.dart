import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/rooms/domain/room_member_model.dart';
import 'package:frontend/features/rooms/domain/room_model.dart';

void main() {
  group('RoomMemberModel', () {
    test('parses json correctly and handles readiness', () {
      final json = {
        'userId': 'user-123',
        'username': 'doodler',
        'displayName': 'Master Doodler',
        'avatarUrl': 'https://example.com/avatar.png',
        'role': 'HOST',
        'ready': true,
        'connectionStatus': 'CONNECTED',
      };

      final member = RoomMemberModel.fromJson(json);
      expect(member.userId, 'user-123');
      expect(member.displayName, 'Master Doodler');
      expect(member.isHost, true);
      expect(member.isReady, true);
    });
  });

  group('RoomModel', () {
    test('calculates readyPlayers and currentPlayers accurately', () {
      final json = {
        'id': 'room-xyz',
        'roomCode': 'DUEL-1234',
        'name': 'Doodle Party',
        'hostId': 'user-1',
        'hostName': 'Host Player',
        'visibility': 'PUBLIC',
        'status': 'WAITING',
        'maxPlayers': 8,
        'totalRounds': 4,
        'drawTimeSeconds': 60,
        'difficulty': 'MEDIUM',
        'category': 'GENERAL',
        'members': [
          {'userId': 'user-1', 'username': 'p1', 'displayName': 'Player 1', 'role': 'HOST', 'ready': true},
          {'userId': 'user-2', 'username': 'p2', 'displayName': 'Player 2', 'role': 'PLAYER', 'ready': false},
          {'userId': 'user-3', 'username': 'p3', 'displayName': 'Player 3', 'role': 'PLAYER', 'ready': true},
        ],
      };

      final room = RoomModel.fromJson(json);
      expect(room.id, 'room-xyz');
      expect(room.roomCode, 'DUEL-1234');
      expect(room.members.length, 3);
      expect(room.currentPlayers, 3);
      expect(room.readyPlayers, 2);
    });
  });
}
