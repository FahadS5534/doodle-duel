export interface DrawingPoint {
  x: number; // 0.0 to 1.0 normalized
  y: number; // 0.0 to 1.0 normalized
}

export interface DrawingStroke {
  strokeId: string;
  color: string;
  brushSize: number;
  tool: 'PEN' | 'BRUSH' | 'GLOW' | 'FILL' | 'ERASER';
  points: DrawingPoint[];
  isFinished: boolean;
}

export interface GameEvent<T = any> {
  eventId: string;
  eventType: string;
  roomId?: string;
  matchId?: string;
  roundNumber?: number;
  senderId?: string;
  senderName?: string;
  serverTimestamp?: string;
  payload: T;
}

export interface RoundStartPayload {
  roundId: string;
  roundNumber: number;
  totalRounds: number;
  drawerId: string;
  drawerName: string;
  category: string;
  letterBlanks: string;
  durationSeconds: number;
  startEpochMs: number;
  endEpochMs: number;
}

export interface SecretWordPayload {
  secretWord: string;
  hint: string;
  category: string;
  durationSeconds: number;
}

export interface PlayerScoreSummary {
  userId: string;
  displayName: string;
  avatarUrl?: string;
  score: number;
  hasGuessed?: boolean;
}

export interface GuessMessage {
  id: string;
  userId: string;
  username: string;
  text: string;
  isCorrect?: boolean;
  isClose?: boolean;
  pointsAwarded?: number;
  timestamp: Date;
}
