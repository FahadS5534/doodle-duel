import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final bool isGuest;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final int streak;
  final int gamesPlayed;
  final int gamesWon;
  final int bestScore;
  final int correctGuesses;
  final int drawingsCompleted;

  String get accountStatus => isGuest ? 'GUEST' : 'ACTIVE';

  const UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.isGuest = false,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.coins = 1000,
    this.streak = 1,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestScore = 0,
    this.correctGuesses = 0,
    this.drawingsCompleted = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['username']?.toString() ?? 'Player',
      isGuest: json['guest'] == true || json['isGuest'] == true,
      avatarUrl: json['avatarUrl']?.toString(),
      level: json['level'] is int ? json['level'] : 1,
      xp: json['xp'] is int ? json['xp'] : 0,
      coins: json['coins'] is int ? json['coins'] : 1000,
      streak: json['streak'] is int ? json['streak'] : 1,
      gamesPlayed: json['gamesPlayed'] is int ? json['gamesPlayed'] : 0,
      gamesWon: json['gamesWon'] is int ? json['gamesWon'] : 0,
      bestScore: json['bestScore'] is int ? json['bestScore'] : 0,
      correctGuesses: json['correctGuesses'] is int ? json['correctGuesses'] : 0,
      drawingsCompleted: json['drawingsCompleted'] is int ? json['drawingsCompleted'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'isGuest': isGuest,
    'avatarUrl': avatarUrl,
    'level': level,
    'xp': xp,
    'coins': coins,
    'streak': streak,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'bestScore': bestScore,
    'correctGuesses': correctGuesses,
    'drawingsCompleted': drawingsCompleted,
  };

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    isGuest,
    avatarUrl,
    level,
    xp,
    coins,
    streak,
    gamesPlayed,
    gamesWon,
    bestScore,
  ];
}
