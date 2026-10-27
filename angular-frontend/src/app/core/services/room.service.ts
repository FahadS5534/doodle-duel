import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, map, of } from 'rxjs';
import { ApiResponse } from '../models/user.model';
import { CreateRoomRequest, JoinRoomRequest, Room } from '../models/room.model';
import { ConfigService } from './config.service';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class RoomService {
  private readonly http = inject(HttpClient);
  private readonly config = inject(ConfigService);
  private readonly auth = inject(AuthService);

  // In-memory mock room for offline preview/fallback
  private mockRooms: Room[] = [
    {
      id: 'mock-room-1',
      roomCode: 'DOODLE',
      name: 'Speed Sketchers Arena ⚡',
      hostId: 'host-1',
      hostName: 'NeonArtist',
      visibility: 'PUBLIC',
      status: 'WAITING',
      maxPlayers: 8,
      totalRounds: 4,
      drawTimeSeconds: 60,
      difficulty: 'MEDIUM',
      category: 'ANIMALS & NATURE',
      currentPlayers: 3,
      readyPlayers: 2,
      createdAt: new Date().toISOString(),
      members: [
        {
          userId: 'host-1',
          username: 'neon_artist',
          displayName: 'NeonArtist 👑',
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Neon',
          level: 14,
          role: 'HOST',
          isReady: true,
          connectionStatus: 'CONNECTED'
        },
        {
          userId: 'p-2',
          username: 'pixel_fox',
          displayName: 'PixelFox',
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Fox',
          level: 8,
          role: 'PLAYER',
          isReady: true,
          connectionStatus: 'CONNECTED'
        },
        {
          userId: 'p-3',
          username: 'doodle_king',
          displayName: 'DoodleKing',
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=King',
          level: 5,
          role: 'PLAYER',
          isReady: false,
          connectionStatus: 'CONNECTED'
        }
      ]
    },
    {
      id: 'mock-room-2',
      roomCode: 'ART42',
      name: 'Anime & Pop Culture 🎨',
      hostId: 'host-2',
      hostName: 'OtakuMaster',
      visibility: 'PUBLIC',
      status: 'WAITING',
      maxPlayers: 6,
      totalRounds: 3,
      drawTimeSeconds: 45,
      difficulty: 'HARD',
      category: 'POP CULTURE',
      currentPlayers: 4,
      readyPlayers: 3,
      createdAt: new Date().toISOString(),
      members: []
    }
  ];

  createRoom(req: CreateRoomRequest): Observable<Room> {
    return this.http.post<ApiResponse<Room>>(`${this.config.apiUrl()}/rooms`, req).pipe(
      map(res => res.data),
      catchError(err => {
        console.warn('Backend room creation failed, falling back to local room:', err);
        const me = this.auth.currentUser();
        const localRoom: Room = {
          id: 'room-' + Date.now(),
          roomCode: Math.random().toString(36).substring(2, 8).toUpperCase(),
          name: req.name,
          hostId: me ? me.id : 'me',
          hostName: me ? me.displayName : 'Host',
          visibility: req.visibility,
          status: 'WAITING',
          maxPlayers: req.maxPlayers,
          totalRounds: req.totalRounds,
          drawTimeSeconds: req.drawTimeSeconds,
          difficulty: req.difficulty,
          category: req.category,
          currentPlayers: 1,
          readyPlayers: 1,
          createdAt: new Date().toISOString(),
          members: [
            {
              userId: me ? me.id : 'me',
              username: me ? me.username : 'host',
              displayName: me ? me.displayName : 'Host',
              avatarUrl: me?.avatarUrl,
              level: me?.level || 1,
              role: 'HOST',
              isReady: true,
              connectionStatus: 'CONNECTED'
            }
          ]
        };
        this.mockRooms.unshift(localRoom);
        return of(localRoom);
      })
    );
  }

  getRoom(roomId: string): Observable<Room> {
    return this.http.get<ApiResponse<Room>>(`${this.config.apiUrl()}/rooms/${roomId}`).pipe(
      map(res => res.data),
      catchError(() => {
        const found = this.mockRooms.find(r => r.id === roomId || r.roomCode === roomId);
        if (found) return of(found);
        // Default preview room
        return of(this.mockRooms[0]);
      })
    );
  }

  joinRoomByCode(code: string): Observable<Room> {
    const payload: JoinRoomRequest = { roomCode: code.trim().toUpperCase() };
    return this.http.post<ApiResponse<Room>>(`${this.config.apiUrl()}/rooms/join`, payload).pipe(
      map(res => res.data),
      catchError(err => {
        const found = this.mockRooms.find(r => r.roomCode === payload.roomCode);
        if (found) {
          const me = this.auth.currentUser();
          if (me && !found.members.some(m => m.userId === me.id)) {
            found.members.push({
              userId: me.id,
              username: me.username,
              displayName: me.displayName,
              avatarUrl: me.avatarUrl,
              level: me.level,
              role: 'PLAYER',
              isReady: false,
              connectionStatus: 'CONNECTED'
            });
            found.currentPlayers = found.members.length;
          }
          return of(found);
        }
        throw err;
      })
    );
  }

  leaveRoom(roomId: string): Observable<void> {
    return this.http.post<ApiResponse<void>>(`${this.config.apiUrl()}/rooms/${roomId}/leave`, {}).pipe(
      map(() => void 0),
      catchError(() => of(void 0))
    );
  }

  getPublicRooms(): Observable<Room[]> {
    return this.http.get<ApiResponse<{ content: Room[] }>>(`${this.config.apiUrl()}/rooms/public`).pipe(
      map(res => res.data?.content || []),
      catchError(() => of(this.mockRooms))
    );
  }

  toggleReady(roomId: string): Observable<Room> {
    return this.http.patch<ApiResponse<Room>>(`${this.config.apiUrl()}/rooms/${roomId}/ready`, {}).pipe(
      map(res => res.data),
      catchError(() => {
        const room = this.mockRooms.find(r => r.id === roomId);
        if (room) {
          const me = this.auth.currentUser();
          const member = room.members.find(m => m.userId === me?.id);
          if (member) member.isReady = !member.isReady;
          room.readyPlayers = room.members.filter(m => m.isReady).length;
          return of(room);
        }
        return of(this.mockRooms[0]);
      })
    );
  }

  startMatch(roomId: string): Observable<Room> {
    return this.http.post<ApiResponse<Room>>(`${this.config.apiUrl()}/rooms/${roomId}/start`, {}).pipe(
      map(res => res.data),
      catchError(() => {
        const room = this.mockRooms.find(r => r.id === roomId) || this.mockRooms[0];
        room.status = 'IN_PROGRESS';
        return of(room);
      })
    );
  }
}
