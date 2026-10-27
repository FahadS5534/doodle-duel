export interface User {
  id: string;
  username: string;
  displayName: string;
  email?: string;
  isGuest: boolean;
  avatarUrl: string;
  level: number;
  xp: number;
  coins: number;
  streak: number;
}

export interface AuthResponse {
  token: string;
  tokenType: string;
  id: string;
  username: string;
  displayName: string;
  isGuest: boolean;
  avatarUrl: string;
  level: number;
  xp: number;
  coins: number;
  streak: number;
}

export interface UserStats {
  userId: string;
  matchesPlayed: number;
  matchesWon: number;
  totalGuesses: number;
  correctGuesses: number;
  drawingsCompleted: number;
  totalPoints: number;
  winRate: number;
  accuracy: number;
  rankTitle: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  timestamp: string;
}
