import { Injectable, inject } from '@angular/core';
import { Client, IMessage, StompSubscription } from '@stomp/stompjs';
import SockJS from 'sockjs-client';
import { BehaviorSubject, Observable, Subject } from 'rxjs';
import { ConfigService } from './config.service';
import { AuthService } from './auth.service';
import { DrawingStroke, GameEvent } from '../models/game.model';

@Injectable({
  providedIn: 'root'
})
export class StompService {
  private readonly config = inject(ConfigService);
  private readonly auth = inject(AuthService);

  private client: Client | null = null;
  private readonly isConnected$ = new BehaviorSubject<boolean>(false);

  // Room Event Subjects
  readonly lobbyEvents$ = new Subject<GameEvent>();
  readonly gameEvents$ = new Subject<GameEvent>();
  readonly drawingEvents$ = new Subject<GameEvent<DrawingStroke>>();
  readonly scoreEvents$ = new Subject<GameEvent>();
  readonly privateNotifications$ = new Subject<GameEvent>();

  private activeSubscriptions: StompSubscription[] = [];

  get isConnected(): Observable<boolean> {
    return this.isConnected$.asObservable();
  }

  connect(): void {
    if (this.client?.active) {
      return;
    }

    const token = this.auth.token() || '';
    const wsUrl = this.config.wsUrl();

    this.client = new Client({
      brokerURL: wsUrl.startsWith('ws') ? wsUrl : undefined,
      webSocketFactory: !wsUrl.startsWith('ws')
        ? () => new SockJS(wsUrl)
        : undefined,
      connectHeaders: {
        Authorization: `Bearer ${token}`,
        token: token
      },
      debug: (msg: string) => {
        // Uncomment for verbose STOMP frames:
        // console.log('[STOMP]', msg);
      },
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
      onConnect: () => {
        console.log('✅ STOMP Connected to:', wsUrl);
        this.isConnected$.next(true);

        // Subscribe to private notifications queue
        this.client?.subscribe('/user/queue/notifications', (message: IMessage) => {
          this.handleIncoming(message, this.privateNotifications$);
        });
      },
      onStompError: (frame) => {
        console.error('❌ STOMP Error:', frame.headers['message'], frame.body);
      },
      onWebSocketClose: () => {
        console.warn('⚠️ STOMP Disconnected');
        this.isConnected$.next(false);
      }
    });

    try {
      this.client.activate();
    } catch (err) {
      console.warn('Could not activate STOMP client:', err);
    }
  }

  subscribeToRoom(roomId: string): void {
    if (!this.client || !this.client.active) {
      this.connect();
    }

    // Clear existing room subscriptions
    this.unsubscribeAll();

    // Small delay to ensure client connected if newly activating
    setTimeout(() => {
      if (!this.client?.connected) return;

      // 1. Lobby topic
      const subLobby = this.client.subscribe(`/topic/rooms/${roomId}/lobby`, (msg: IMessage) => {
        this.handleIncoming(msg, this.lobbyEvents$);
      });
      this.activeSubscriptions.push(subLobby);

      // 2. Game flow topic
      const subGame = this.client.subscribe(`/topic/rooms/${roomId}/game`, (msg: IMessage) => {
        this.handleIncoming(msg, this.gameEvents$);
      });
      this.activeSubscriptions.push(subGame);

      // 3. Drawing strokes topic
      const subDrawing = this.client.subscribe(`/topic/rooms/${roomId}/drawing`, (msg: IMessage) => {
        this.handleIncoming(msg, this.drawingEvents$);
      });
      this.activeSubscriptions.push(subDrawing);

      // 4. Scores and guess messages topic
      const subScores = this.client.subscribe(`/topic/rooms/${roomId}/scores`, (msg: IMessage) => {
        this.handleIncoming(msg, this.scoreEvents$);
      });
      this.activeSubscriptions.push(subScores);

      // Request initial state synchronization
      this.requestSync(roomId);
    }, 500);
  }

  private handleIncoming(msg: IMessage, subject: Subject<any>): void {
    if (!msg.body) return;
    try {
      const parsed = JSON.parse(msg.body);
      subject.next(parsed);
    } catch (e) {
      console.error('Failed to parse STOMP message body:', e);
    }
  }

  sendReady(roomId: string): void {
    this.publish(`/app/rooms/${roomId}/ready`, {});
  }

  sendStart(roomId: string): void {
    this.publish(`/app/rooms/${roomId}/start`, {});
  }

  sendDrawingStroke(roomId: string, stroke: DrawingStroke): void {
    this.publish(`/app/rooms/${roomId}/drawing`, stroke);
  }

  sendDrawingUndo(roomId: string): void {
    this.publish(`/app/rooms/${roomId}/drawing/undo`, {});
  }

  sendDrawingClear(roomId: string): void {
    this.publish(`/app/rooms/${roomId}/drawing/clear`, {});
  }

  sendGuess(roomId: string, text: string): void {
    this.publish(`/app/rooms/${roomId}/guess`, { text });
  }

  sendReaction(roomId: string, emoji: string): void {
    this.publish(`/app/rooms/${roomId}/reaction`, { emoji });
  }

  requestSync(roomId: string): void {
    this.publish(`/app/rooms/${roomId}/sync`, {});
  }

  private publish(destination: string, body: any): void {
    if (!this.client?.connected) {
      console.warn('STOMP client not connected, skipping publish to:', destination);
      return;
    }
    this.client.publish({
      destination,
      body: JSON.stringify(body)
    });
  }

  unsubscribeAll(): void {
    this.activeSubscriptions.forEach(sub => {
      try {
        sub.unsubscribe();
      } catch (_) {}
    });
    this.activeSubscriptions = [];
  }

  disconnect(): void {
    this.unsubscribeAll();
    if (this.client) {
      this.client.deactivate();
      this.client = null;
    }
    this.isConnected$.next(false);
  }
}
