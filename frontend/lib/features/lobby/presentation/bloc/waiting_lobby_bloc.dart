import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/websocket/stomp_service.dart';
import '../../../rooms/data/room_repository.dart';
import '../../../rooms/domain/room_member_model.dart';
import '../../../rooms/domain/room_model.dart';

abstract class WaitingLobbyEvent extends Equatable {
  const WaitingLobbyEvent();
  @override
  List<Object?> get props => [];
}

class LobbyLoadRequested extends WaitingLobbyEvent {
  final String roomId;
  final String currentUserId;
  const LobbyLoadRequested(this.roomId, this.currentUserId);
  @override
  List<Object?> get props => [roomId, currentUserId];
}

class LobbyToggleReady extends WaitingLobbyEvent {}

class LobbyLeaveRoom extends WaitingLobbyEvent {}

class LobbyStartGame extends WaitingLobbyEvent {}

class _LobbyUpdateReceived extends WaitingLobbyEvent {
  final Map<String, dynamic> data;
  const _LobbyUpdateReceived(this.data);
  @override
  List<Object?> get props => [data];
}

class _LobbyGameStartedReceived extends WaitingLobbyEvent {}

abstract class WaitingLobbyState extends Equatable {
  const WaitingLobbyState();
  @override
  List<Object?> get props => [];
}

class WaitingLobbyInitial extends WaitingLobbyState {}

class WaitingLobbyLoading extends WaitingLobbyState {}

class WaitingLobbyLoaded extends WaitingLobbyState {
  final RoomModel room;
  final String currentUserId;
  final bool isHost;
  final bool isReady;
  final bool canStart;

  const WaitingLobbyLoaded({
    required this.room,
    required this.currentUserId,
    required this.isHost,
    required this.isReady,
    required this.canStart,
  });

  @override
  List<Object?> get props => [room, currentUserId, isHost, isReady, canStart];
}

class WaitingLobbyGameStarting extends WaitingLobbyState {
  final String roomId;
  const WaitingLobbyGameStarting(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class WaitingLobbyLeft extends WaitingLobbyState {}

class WaitingLobbyError extends WaitingLobbyState {
  final String message;
  const WaitingLobbyError(this.message);
  @override
  List<Object?> get props => [message];
}

class WaitingLobbyBloc extends Bloc<WaitingLobbyEvent, WaitingLobbyState> {
  final RoomRepository roomRepository;
  final StompService _stompService = StompService();

  String _roomId = '';
  String _currentUserId = '';
  StreamSubscription? _lobbySub;
  StreamSubscription? _gameSub;

  WaitingLobbyBloc({required this.roomRepository}) : super(WaitingLobbyInitial()) {
    on<LobbyLoadRequested>(_onLoad);
    on<LobbyToggleReady>(_onToggleReady);
    on<LobbyLeaveRoom>(_onLeave);
    on<LobbyStartGame>(_onStart);
    on<_LobbyUpdateReceived>(_onUpdate);
    on<_LobbyGameStartedReceived>(_onGameStarted);
  }

  Future<void> _onLoad(LobbyLoadRequested event, Emitter<WaitingLobbyState> emit) async {
    _roomId = event.roomId;
    _currentUserId = event.currentUserId;
    emit(WaitingLobbyLoading());

    try {
      final room = await roomRepository.getRoomDetails(_roomId);

      _stompService.subscribeToRoom(_roomId);

      _lobbySub?.cancel();
      _lobbySub = _stompService.lobbyEvents.listen((data) {
        add(_LobbyUpdateReceived(data));
      });

      _gameSub?.cancel();
      _gameSub = _stompService.gameEvents.listen((data) {
        if (data['eventType'] == 'MATCH_STARTED') {
          add(_LobbyGameStartedReceived());
        }
      });

      final currentMember = room.members.firstWhere(
        (m) => m.userId == _currentUserId,
        orElse: () => RoomMemberModel(userId: _currentUserId, username: '', displayName: ''),
      );

      final isHost = room.hostId == _currentUserId;
      final canStart = isHost && room.members.length >= 2;

      emit(WaitingLobbyLoaded(
        room: room,
        currentUserId: _currentUserId,
        isHost: isHost,
        isReady: currentMember.isReady,
        canStart: canStart,
      ));
    } catch (e) {
      emit(WaitingLobbyError(e.toString()));
    }
  }

  Future<void> _onToggleReady(LobbyToggleReady event, Emitter<WaitingLobbyState> emit) async {
    _stompService.sendReady(_roomId);
  }

  Future<void> _onStart(LobbyStartGame event, Emitter<WaitingLobbyState> emit) async {
    _stompService.sendStart(_roomId);
  }

  Future<void> _onLeave(LobbyLeaveRoom event, Emitter<WaitingLobbyState> emit) async {
    try {
      await roomRepository.leaveRoom(_roomId);
      emit(WaitingLobbyLeft());
    } catch (_) {
      emit(WaitingLobbyLeft());
    }
  }

  void _onUpdate(_LobbyUpdateReceived event, Emitter<WaitingLobbyState> emit) {
    final payload = event.data['payload'];
    if (payload is Map && payload.containsKey('room')) {
      final roomData = payload['room'] as Map<String, dynamic>;
      final updatedRoom = RoomModel.fromJson(roomData);

      final currentMember = updatedRoom.members.firstWhere(
        (m) => m.userId == _currentUserId,
        orElse: () => RoomMemberModel(userId: _currentUserId, username: '', displayName: ''),
      );

      final isHost = updatedRoom.hostId == _currentUserId;
      final canStart = isHost && updatedRoom.members.length >= 2;

      emit(WaitingLobbyLoaded(
        room: updatedRoom,
        currentUserId: _currentUserId,
        isHost: isHost,
        isReady: currentMember.isReady,
        canStart: canStart,
      ));
    }
  }

  void _onGameStarted(_LobbyGameStartedReceived event, Emitter<WaitingLobbyState> emit) {
    emit(WaitingLobbyGameStarting(_roomId));
  }

  @override
  Future<void> close() {
    _lobbySub?.cancel();
    _gameSub?.cancel();
    return super.close();
  }
}
