import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/websocket/stomp_service.dart';
import '../models/drawing_stroke_model.dart';

enum GamePhase {
  lobby,
  matchStarting,
  roundActive,
  roundResults,
  matchFinished,
}

class PlayerScoreEntry extends Equatable {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final bool hasGuessed;

  const PlayerScoreEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    this.hasGuessed = false,
  });

  PlayerScoreEntry copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    int? score,
    bool? hasGuessed,
  }) {
    return PlayerScoreEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      hasGuessed: hasGuessed ?? this.hasGuessed,
    );
  }

  @override
  List<Object?> get props => [userId, displayName, avatarUrl, score, hasGuessed];
}

class GuessFeedItem extends Equatable {
  final String id;
  final String playerName;
  final String text;
  final bool isClose;
  final bool isCorrect;
  final int pointsEarned;

  const GuessFeedItem({
    required this.id,
    required this.playerName,
    required this.text,
    this.isClose = false,
    this.isCorrect = false,
    this.pointsEarned = 0,
  });

  @override
  List<Object?> get props => [id, playerName, text, isClose, isCorrect, pointsEarned];
}

class GameState extends Equatable {
  final GamePhase phase;
  final String roomId;
  final String matchId;
  final int currentRound;
  final int totalRounds;
  final String drawerId;
  final String drawerName;
  final String? secretWord; // Only non-null if user is drawer or round ended!
  final String? hint;
  final String? category;
  final String letterBlanks;
  final int remainingSeconds;
  final int totalDurationSeconds;
  final List<PlayerScoreEntry> players;
  final List<GuessFeedItem> guessFeed;
  final List<String> activeReactions;
  final Map<String, dynamic>? matchResults;
  final String? lastEndedSecretWord;

  const GameState({
    this.phase = GamePhase.lobby,
    this.roomId = '',
    this.matchId = '',
    this.currentRound = 1,
    this.totalRounds = 4,
    this.drawerId = '',
    this.drawerName = '',
    this.secretWord,
    this.hint,
    this.category,
    this.letterBlanks = '',
    this.remainingSeconds = 60,
    this.totalDurationSeconds = 60,
    this.players = const [],
    this.guessFeed = const [],
    this.activeReactions = const [],
    this.matchResults,
    this.lastEndedSecretWord,
  });

  bool get isDrawer => drawerId.isNotEmpty && secretWord != null;

  GameState copyWith({
    GamePhase? phase,
    String? roomId,
    String? matchId,
    int? currentRound,
    int? totalRounds,
    String? drawerId,
    String? drawerName,
    String? secretWord,
    bool clearSecretWord = false,
    String? hint,
    String? category,
    String? letterBlanks,
    int? remainingSeconds,
    int? totalDurationSeconds,
    List<PlayerScoreEntry>? players,
    List<GuessFeedItem>? guessFeed,
    List<String>? activeReactions,
    Map<String, dynamic>? matchResults,
    String? lastEndedSecretWord,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      roomId: roomId ?? this.roomId,
      matchId: matchId ?? this.matchId,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      drawerId: drawerId ?? this.drawerId,
      drawerName: drawerName ?? this.drawerName,
      secretWord: clearSecretWord ? null : (secretWord ?? this.secretWord),
      hint: hint ?? this.hint,
      category: category ?? this.category,
      letterBlanks: letterBlanks ?? this.letterBlanks,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      players: players ?? this.players,
      guessFeed: guessFeed ?? this.guessFeed,
      activeReactions: activeReactions ?? this.activeReactions,
      matchResults: matchResults ?? this.matchResults,
      lastEndedSecretWord: lastEndedSecretWord ?? this.lastEndedSecretWord,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    roomId,
    matchId,
    currentRound,
    totalRounds,
    drawerId,
    drawerName,
    secretWord,
    hint,
    category,
    letterBlanks,
    remainingSeconds,
    totalDurationSeconds,
    players,
    guessFeed,
    activeReactions,
    matchResults,
    lastEndedSecretWord,
  ];
}

abstract class GameEventAction extends Equatable {
  const GameEventAction();
  @override
  List<Object?> get props => [];
}

class GameInitRequested extends GameEventAction {
  final String roomId;
  final String currentUserId;
  const GameInitRequested(this.roomId, this.currentUserId);
  @override
  List<Object?> get props => [roomId, currentUserId];
}

class _GameTick extends GameEventAction {}

class GameSubmitGuess extends GameEventAction {
  final String text;
  const GameSubmitGuess(this.text);
  @override
  List<Object?> get props => [text];
}

class GameSendReaction extends GameEventAction {
  final String emoji;
  const GameSendReaction(this.emoji);
  @override
  List<Object?> get props => [emoji];
}

class GameStartMatch extends GameEventAction {}

class _GameRawEventReceived extends GameEventAction {
  final Map<String, dynamic> data;
  const _GameRawEventReceived(this.data);
  @override
  List<Object?> get props => [data];
}

class GameBloc extends Bloc<GameEventAction, GameState> {
  final StompService _stompService = StompService();
  String _currentUserId = '';
  Timer? _countdownTimer;

  StreamSubscription? _gameSubscription;
  StreamSubscription? _scoreSubscription;
  StreamSubscription? _notificationSubscription;

  // Callback to sync canvas when reconnecting
  Function(List<DrawingStrokeModel>)? onCanvasSnapshotLoaded;

  GameBloc() : super(const GameState()) {
    on<GameInitRequested>(_onInit);
    on<_GameTick>(_onTick);
    on<GameSubmitGuess>(_onSubmitGuess);
    on<GameSendReaction>(_onSendReaction);
    on<GameStartMatch>(_onStartMatch);
    on<_GameRawEventReceived>(_onRawEvent);
  }

  void _onInit(GameInitRequested event, Emitter<GameState> emit) {
    _currentUserId = event.currentUserId;
    emit(state.copyWith(roomId: event.roomId));

    _gameSubscription?.cancel();
    _scoreSubscription?.cancel();
    _notificationSubscription?.cancel();

    _stompService.subscribeToRoom(event.roomId);

    _gameSubscription = _stompService.gameEvents.listen((data) {
      add(_GameRawEventReceived(data));
    });

    _scoreSubscription = _stompService.scoreEvents.listen((data) {
      add(_GameRawEventReceived(data));
    });

    _notificationSubscription = _stompService.privateNotifications.listen((data) {
      add(_GameRawEventReceived(data));
    });
  }

  void _onTick(_GameTick event, Emitter<GameState> emit) {
    if (state.remainingSeconds > 0) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    }
  }

  void _onSubmitGuess(GameSubmitGuess event, Emitter<GameState> emit) {
    if (state.roomId.isNotEmpty && event.text.trim().isNotEmpty) {
      _stompService.sendGuess(state.roomId, event.text.trim());
    }
  }

  void _onSendReaction(GameSendReaction event, Emitter<GameState> emit) {
    if (state.roomId.isNotEmpty && event.emoji.isNotEmpty) {
      _stompService.sendReaction(state.roomId, event.emoji);
    }
  }

  void _onStartMatch(GameStartMatch event, Emitter<GameState> emit) {
    if (state.roomId.isNotEmpty) {
      _stompService.sendStart(state.roomId);
    }
  }

  void _onRawEvent(_GameRawEventReceived event, Emitter<GameState> emit) {
    final data = event.data;
    final type = data['eventType']?.toString();
    final payload = data['payload'];

    if (type == 'MATCH_STARTED' && payload is Map) {
      final totalRounds = (payload['totalRounds'] as num?)?.toInt() ?? 4;
      final rawPlayers = payload['players'] as List? ?? [];
      final players = rawPlayers.map((p) => PlayerScoreEntry(
        userId: p['userId']?.toString() ?? '',
        displayName: p['displayName']?.toString() ?? 'Player',
        avatarUrl: p['avatarUrl']?.toString(),
        score: (p['score'] as num?)?.toInt() ?? 0,
      )).toList();

      emit(state.copyWith(
        phase: GamePhase.matchStarting,
        totalRounds: totalRounds,
        players: players,
        guessFeed: const [],
      ));
    } else if (type == 'SECRET_WORD_PROMPT' && payload is Map) {
      // Received privately because this client is the drawer!
      final word = payload['secretWord']?.toString() ?? '';
      final hint = payload['hint']?.toString();
      final cat = payload['category']?.toString();
      emit(state.copyWith(
        secretWord: word,
        hint: hint,
        category: cat,
      ));
    } else if (type == 'ROUND_START' && payload is Map) {
      final rNumber = (payload['roundNumber'] as num?)?.toInt() ?? 1;
      final tRounds = (payload['totalRounds'] as num?)?.toInt() ?? 4;
      final dId = payload['drawerId']?.toString() ?? '';
      final dName = payload['drawerName']?.toString() ?? 'Artist';
      final blanks = payload['letterBlanks']?.toString() ?? '';
      final duration = (payload['durationSeconds'] as num?)?.toInt() ?? 60;
      final cat = payload['category']?.toString();

      _startTimer(duration);

      final isCurrentDrawer = dId == _currentUserId;

      emit(state.copyWith(
        phase: GamePhase.roundActive,
        currentRound: rNumber,
        totalRounds: tRounds,
        drawerId: dId,
        drawerName: dName,
        letterBlanks: blanks,
        totalDurationSeconds: duration,
        remainingSeconds: duration,
        category: cat,
        clearSecretWord: !isCurrentDrawer,
        players: state.players.map((p) => p.copyWith(hasGuessed: false)).toList(),
      ));
    } else if (type == 'CORRECT_GUESS' && payload is Map) {
      final pId = payload['playerId']?.toString() ?? '';
      final pName = payload['playerName']?.toString() ?? 'Player';
      final points = (payload['pointsEarned'] as num?)?.toInt() ?? 200;
      final total = (payload['totalScore'] as num?)?.toInt() ?? 0;

      final updatedPlayers = state.players.map((p) {
        if (p.userId == pId) {
          return p.copyWith(score: total, hasGuessed: true);
        }
        return p;
      }).toList();

      final updatedFeed = List<GuessFeedItem>.from(state.guessFeed)
        ..add(GuessFeedItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          playerName: pName,
          text: 'Guessed the secret word! 🎉',
          isCorrect: true,
          pointsEarned: points,
        ));

      emit(state.copyWith(
        players: updatedPlayers,
        guessFeed: updatedFeed,
      ));
    } else if (type == 'GUESS_FEED' && payload is Map) {
      final pName = payload['playerName']?.toString() ?? 'Player';
      final text = payload['text']?.toString() ?? '';
      final isClose = payload['isClose'] == true;

      final updatedFeed = List<GuessFeedItem>.from(state.guessFeed)
        ..add(GuessFeedItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          playerName: pName,
          text: text,
          isClose: isClose,
        ));

      emit(state.copyWith(guessFeed: updatedFeed));
    } else if (type == 'ROUND_ENDED' && payload is Map) {
      _countdownTimer?.cancel();
      final word = payload['secretWord']?.toString() ?? '';
      final rawScores = payload['scores'] as List? ?? [];

      final updatedPlayers = rawScores.map((s) => PlayerScoreEntry(
        userId: s['userId']?.toString() ?? '',
        displayName: s['displayName']?.toString() ?? 'Player',
        avatarUrl: s['avatarUrl']?.toString(),
        score: (s['score'] as num?)?.toInt() ?? 0,
      )).toList();

      emit(state.copyWith(
        phase: GamePhase.roundResults,
        lastEndedSecretWord: word,
        players: updatedPlayers.isNotEmpty ? updatedPlayers : state.players,
      ));
    } else if (type == 'MATCH_FINISHED' && payload is Map) {
      _countdownTimer?.cancel();
      emit(state.copyWith(
        phase: GamePhase.matchFinished,
        matchResults: Map<String, dynamic>.from(payload),
      ));
    } else if (type == 'REACTION' && payload is Map) {
      final emoji = payload['emoji']?.toString() ?? '🔥';
      final updatedReactions = List<String>.from(state.activeReactions)..add(emoji);
      emit(state.copyWith(activeReactions: updatedReactions));

      // Auto-clear reaction after 1.5 seconds
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isClosed) {
          final cleaned = List<String>.from(state.activeReactions)..remove(emoji);
          emit(state.copyWith(activeReactions: cleaned));
        }
      });
    } else if (type == 'SYNC_STATE' && payload is Map) {
      final phaseStr = payload['phase']?.toString() ?? 'LOBBY';
      if (phaseStr == 'ROUND_ACTIVE') {
        final rNumber = (payload['roundNumber'] as num?)?.toInt() ?? 1;
        final tRounds = (payload['totalRounds'] as num?)?.toInt() ?? 4;
        final dId = payload['drawerId']?.toString() ?? '';
        final remaining = (payload['remainingSeconds'] as num?)?.toInt() ?? 60;
        final word = payload['secretWord']?.toString();
        final blanks = payload['letterBlanks']?.toString() ?? '';

        _startTimer(remaining);

        emit(state.copyWith(
          phase: GamePhase.roundActive,
          currentRound: rNumber,
          totalRounds: tRounds,
          drawerId: dId,
          remainingSeconds: remaining,
          secretWord: word,
          letterBlanks: blanks,
        ));
      }
    }
  }

  void _startTimer(int seconds) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_GameTick());
    });
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _gameSubscription?.cancel();
    _scoreSubscription?.cancel();
    _notificationSubscription?.cancel();
    return super.close();
  }
}
