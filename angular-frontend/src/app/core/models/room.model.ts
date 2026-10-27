export interface RoomMember {
  userId: string;
  username: string;
  displayName: string;
  avatarUrl?: string;
  level: number;
  role: 'HOST' | 'PLAYER';
  isReady: boolean;
  connectionStatus: 'CONNECTED' | 'DISCONNECTED';
  joinedAt?: string;
}

export interface Room {
  id: string;
  roomCode: string;
  name: string;
  hostId: string;
  hostName: string;
  visibility: 'PUBLIC' | 'PRIVATE';
  status: 'WAITING' | 'STARTING' | 'IN_PROGRESS' | 'FINISHED';
  maxPlayers: number;
  totalRounds: number;
  drawTimeSeconds: number;
  difficulty: 'EASY' | 'MEDIUM' | 'HARD';
  category: string;
  currentPlayers: number;
  readyPlayers: number;
  createdAt: string;
  members: RoomMember[];
}

export interface CreateRoomRequest {
  name: string;
  visibility: 'PUBLIC' | 'PRIVATE';
  maxPlayers: number;
  totalRounds: number;
  drawTimeSeconds: number;
  difficulty: 'EASY' | 'MEDIUM' | 'HARD';
  category: string;
}

export interface JoinRoomRequest {
  roomCode: string;
}
