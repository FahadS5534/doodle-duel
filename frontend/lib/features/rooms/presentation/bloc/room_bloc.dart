import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/room_repository.dart';
import '../../domain/room_model.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object?> get props => [];
}

class RoomCreateRequested extends RoomEvent {
  final String name;
  final String visibility;
  final int maxPlayers;
  final int totalRounds;
  final int drawTimeSeconds;
  final String difficulty;
  final String category;

  const RoomCreateRequested({
    required this.name,
    this.visibility = 'PUBLIC',
    this.maxPlayers = 8,
    this.totalRounds = 4,
    this.drawTimeSeconds = 60,
    this.difficulty = 'MEDIUM',
    this.category = 'GENERAL',
  });

  @override
  List<Object?> get props => [
    name,
    visibility,
    maxPlayers,
    totalRounds,
    drawTimeSeconds,
    difficulty,
    category,
  ];
}

class RoomJoinRequested extends RoomEvent {
  final String roomCode;
  const RoomJoinRequested(this.roomCode);
  @override
  List<Object?> get props => [roomCode];
}

class RoomDiscoverRequested extends RoomEvent {
  final String? difficulty;
  final String? category;
  const RoomDiscoverRequested({this.difficulty, this.category});
  @override
  List<Object?> get props => [difficulty, category];
}

abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object?> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomActionSuccess extends RoomState {
  final RoomModel room;
  final bool isCreated;

  const RoomActionSuccess(this.room, {this.isCreated = false});

  @override
  List<Object?> get props => [room, isCreated];
}

class RoomDiscoverLoaded extends RoomState {
  final List<RoomModel> rooms;
  const RoomDiscoverLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);
  @override
  List<Object?> get props => [message];
}

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;

  RoomBloc({required this.roomRepository}) : super(RoomInitial()) {
    on<RoomCreateRequested>(_onCreate);
    on<RoomJoinRequested>(_onJoin);
    on<RoomDiscoverRequested>(_onDiscover);
  }

  Future<void> _onCreate(RoomCreateRequested event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final room = await roomRepository.createRoom(
        name: event.name,
        visibility: event.visibility,
        maxPlayers: event.maxPlayers,
        totalRounds: event.totalRounds,
        drawTimeSeconds: event.drawTimeSeconds,
        difficulty: event.difficulty,
        category: event.category,
      );
      emit(RoomActionSuccess(room, isCreated: true));
    } catch (e) {
      emit(RoomError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onJoin(RoomJoinRequested event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final room = await roomRepository.joinRoom(event.roomCode);
      emit(RoomActionSuccess(room, isCreated: false));
    } catch (e) {
      emit(RoomError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onDiscover(RoomDiscoverRequested event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      final rooms = await roomRepository.getPublicRooms(
        difficulty: event.difficulty,
        category: event.category,
      );
      emit(RoomDiscoverLoaded(rooms));
    } catch (e) {
      emit(RoomError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final map = e.response!.data as Map;
        if (map.containsKey('message')) {
          return map['message'].toString();
        }
      }
      return e.message ?? 'Server error';
    }
    return e.toString();
  }
}
