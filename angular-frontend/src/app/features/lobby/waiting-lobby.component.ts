import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { Subscription } from 'rxjs';
import { RoomService } from '../../core/services/room.service';
import { StompService } from '../../core/services/stomp.service';
import { AuthService } from '../../core/services/auth.service';
import { SoundService } from '../../core/services/sound.service';
import { AvatarWidgetComponent } from '../../shared/components/avatar-widget/avatar-widget.component';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';
import { Room, RoomMember } from '../../core/models/room.model';
import { GameEvent } from '../../core/models/game.model';

@Component({
  selector: 'app-waiting-lobby',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, AvatarWidgetComponent, AmbientDoodleComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>

    <div class="lobby-page">
      <div class="lobby-container">
        <!-- Top Back & Title Bar -->
        <div class="lobby-top-bar glass-card">
          <button class="icon-back" (click)="leaveRoom()">← Leave</button>
          <div class="room-title-box">
            <h2>{{ room()?.name || 'Waiting Room' }}</h2>
            <div class="room-tags">
              <span class="badge-pill badge-coral">{{ room()?.difficulty || 'MEDIUM' }}</span>
              <span class="badge-pill badge-mint">{{ room()?.category || 'GENERAL' }}</span>
              <span class="badge-pill badge-yellow">⏱️ {{ room()?.drawTimeSeconds || 60 }}s</span>
            </div>
          </div>
          <!-- Room PIN Copy Chip -->
          <div class="pin-card" (click)="copyPin()" title="Click to copy room code">
            <span class="pin-label">ROOM PIN</span>
            <span class="pin-code">{{ room()?.roomCode || '...' }}</span>
            <span class="copy-hint">{{ copiedPin() ? 'Copied! ✓' : '📋 Copy' }}</span>
          </div>
        </div>

        <div class="lobby-main-grid">
          <!-- Left: Players Grid -->
          <div class="players-card glass-card">
            <div class="card-header">
              <h3>Squad Members</h3>
              <span class="badge-pill badge-mint">
                {{ members().length }}/{{ room()?.maxPlayers || 8 }} Players
              </span>
            </div>

            <div class="members-grid">
              @for (member of members(); track member.userId) {
                <div class="member-tile glass-card" [class.is-ready]="member.isReady">
                  <app-avatar-widget
                    [avatarUrl]="member.avatarUrl"
                    [name]="member.displayName"
                    [size]="60"
                    [level]="member.level"
                    [showLevel]="true"
                    [isHost]="member.role === 'HOST'"
                    [isReady]="member.isReady"
                  ></app-avatar-widget>

                  <div class="member-meta">
                    <span class="member-name">{{ member.displayName }}</span>
                    <span class="member-role" [class.host]="member.role === 'HOST'">
                      {{ member.role === 'HOST' ? '👑 Room Host' : (member.isReady ? '✅ Ready' : '⏳ Waiting') }}
                    </span>
                  </div>
                </div>
              }
            </div>

            <!-- Host / Player Action Footer -->
            <div class="lobby-actions">
              @if (isHost()) {
                <button
                  class="btn-coral btn-block"
                  [disabled]="!canStartMatch()"
                  (click)="startMatch()"
                >
                  <span>🚀 Start Match Now!</span>
                </button>
                @if (!canStartMatch()) {
                  <p class="ready-warning">Need at least 2 players to begin match.</p>
                }
              } @else {
                <button
                  class="btn-block"
                  [class.btn-coral]="!isMyReady()"
                  [class.btn-mint]="isMyReady()"
                  (click)="toggleReady()"
                >
                  <span>{{ isMyReady() ? '✓ You Are Ready!' : 'Ready Up! 🚀' }}</span>
                </button>
              }
            </div>
          </div>

          <!-- Right: Chat & Quick Reactions -->
          <div class="chat-card glass-card">
            <div class="card-header">
              <h3>Lobby Chat & Hype</h3>
              <div class="reaction-strip">
                @for (emoji of reactions; track emoji) {
                  <button class="reaction-btn" (click)="sendReaction(emoji)">
                    {{ emoji }}
                  </button>
                }
              </div>
            </div>

            <!-- Messages Stream -->
            <div class="messages-list">
              @for (msg of chatMessages(); track msg.id) {
                <div class="chat-msg" [class.system]="msg.isSystem">
                  <span class="sender">{{ msg.sender }}:</span>
                  <span class="text">{{ msg.text }}</span>
                </div>
              }
            </div>

            <!-- Chat Input -->
            <form (ngSubmit)="sendChat()" class="chat-form">
              <input
                type="text"
                class="input-glass"
                placeholder="Send message to squad..."
                [(ngModel)]="chatText"
                name="chat"
              />
              <button type="submit" class="btn-coral btn-sm">Send</button>
            </form>
          </div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .lobby-page {
      position: relative;
      min-height: 100vh;
      padding: 24px 16px 80px;
      z-index: 1;
    }
    .lobby-container {
      max-width: 1100px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .lobby-top-bar {
      padding: 18px 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .icon-back {
      font-size: 14px;
      font-weight: 700;
      color: var(--text-secondary);
      background: #FFFFFF;
      padding: 8px 16px;
      border-radius: var(--radius-full);
      box-shadow: 0 2px 6px rgba(0,0,0,0.06);
      transition: all 0.2s;
    }
    .icon-back:hover {
      color: var(--primary-coral);
    }
    .room-title-box {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .room-title-box h2 {
      font-size: 24px;
      font-weight: 800;
    }
    .room-tags {
      display: flex;
      gap: 8px;
    }

    .pin-card {
      display: flex;
      flex-direction: column;
      align-items: center;
      background: #FFFFFF;
      border: 1.5px dashed var(--primary-coral);
      border-radius: var(--radius-md);
      padding: 8px 18px;
      cursor: pointer;
      transition: all 0.2s;
    }
    .pin-card:hover {
      background: rgba(255, 87, 51, 0.05);
      transform: scale(1.03);
    }
    .pin-label {
      font-size: 10px;
      font-weight: 800;
      color: var(--text-muted);
      letter-spacing: 1px;
    }
    .pin-code {
      font-family: monospace;
      font-size: 22px;
      font-weight: 800;
      color: var(--primary-coral);
      letter-spacing: 3px;
    }
    .copy-hint {
      font-size: 11px;
      font-weight: 600;
      color: var(--accent-mint);
    }

    .lobby-main-grid {
      display: grid;
      grid-template-columns: 1fr 380px;
      gap: 20px;
    }
    @media (max-width: 860px) {
      .lobby-main-grid {
        grid-template-columns: 1fr;
      }
    }

    .players-card, .chat-card {
      padding: 24px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      min-height: 480px;
    }
    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
    }
    .card-header h3 {
      font-size: 18px;
      font-weight: 800;
    }

    .members-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }
    .member-tile {
      padding: 16px;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 10px;
      background: #FFFFFF;
      border-radius: var(--radius-md);
    }
    .member-tile.is-ready {
      border-color: var(--accent-mint);
      background: rgba(46, 196, 182, 0.05);
    }
    .member-name {
      font-family: var(--font-heading);
      font-size: 14px;
      font-weight: 700;
    }
    .member-role {
      font-size: 12px;
      color: var(--text-secondary);
      font-weight: 600;
    }
    .member-role.host {
      color: var(--primary-coral);
    }

    .lobby-actions {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .ready-warning {
      text-align: center;
      font-size: 12px;
      color: var(--text-muted);
    }

    /* Chat */
    .reaction-strip {
      display: flex;
      gap: 4px;
    }
    .reaction-btn {
      font-size: 18px;
      padding: 4px 6px;
      border-radius: var(--radius-sm);
      background: #FFFFFF;
      transition: transform 0.15s;
    }
    .reaction-btn:hover {
      transform: scale(1.2);
    }

    .messages-list {
      flex: 1;
      height: 300px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 8px;
      padding: 10px;
      background: rgba(255, 255, 255, 0.6);
      border-radius: var(--radius-md);
      margin-bottom: 14px;
    }
    .chat-msg {
      font-size: 13px;
      line-height: 1.4;
    }
    .chat-msg.system {
      color: var(--accent-mint);
      font-weight: 600;
      font-style: italic;
    }
    .chat-msg .sender {
      font-weight: 700;
      margin-right: 6px;
      color: var(--primary-coral);
    }
    .chat-form {
      display: flex;
      gap: 8px;
    }
  `]
})
export class WaitingLobbyComponent implements OnInit, OnDestroy {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly roomService = inject(RoomService);
  private readonly stomp = inject(StompService);
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);

  roomId = '';
  room = signal<Room | null>(null);
  members = signal<RoomMember[]>([]);
  copiedPin = signal<boolean>(false);

  chatText = '';
  chatMessages = signal<Array<{ id: string; sender: string; text: string; isSystem?: boolean }>>([
    { id: '1', sender: 'System', text: 'Welcome to the lobby! Chat and warm up your drawing fingers.', isSystem: true }
  ]);

  reactions = ['🎉', '❤️', '🔥', '👏', '😂', '🎨'];
  private subs = new Subscription();

  ngOnInit(): void {
    this.roomId = this.route.snapshot.params['roomId'] || '';
    if (this.roomId) {
      this.loadRoomDetails();
      this.setupStompSubscriptions();
    }
  }

  ngOnDestroy(): void {
    this.subs.unsubscribe();
    this.stomp.unsubscribeAll();
  }

  loadRoomDetails(): void {
    this.roomService.getRoom(this.roomId).subscribe(data => {
      if (data) {
        this.room.set(data);
        this.members.set(data.members || []);
      }
    });
  }

  setupStompSubscriptions(): void {
    this.stomp.subscribeToRoom(this.roomId);

    // Listen to lobby events (player join, leave, ready toggle)
    this.subs.add(
      this.stomp.lobbyEvents$.subscribe((event: GameEvent) => {
        this.sound.playPop();
        this.loadRoomDetails();
        if (event.payload?.message) {
          this.chatMessages.update(msgs => [
            ...msgs,
            { id: Date.now().toString(), sender: 'Lobby', text: event.payload.message, isSystem: true }
          ]);
        }
      })
    );

    // Listen to game events (e.g. ROUND_START or MATCH_START)
    this.subs.add(
      this.stomp.gameEvents$.subscribe((event: GameEvent) => {
        if (event.eventType === 'ROUND_START' || event.eventType === 'MATCH_START') {
          this.sound.playFanfare();
          this.router.navigate(['/game', this.roomId]);
        } else if (event.eventType === 'REACTION') {
          this.sound.playPop();
          const sender = event.senderName || 'Player';
          const emoji = event.payload?.emoji || '🎨';
          this.chatMessages.update(msgs => [
            ...msgs,
            { id: Date.now().toString(), sender, text: `reacted ${emoji}` }
          ]);
        }
      })
    );
  }

  isHost(): boolean {
    const me = this.auth.currentUser();
    const r = this.room();
    return !!(me && r && (r.hostId === me.id || r.hostName === me.displayName));
  }

  isMyReady(): boolean {
    const me = this.auth.currentUser();
    return !!(this.members().find(m => m.userId === me?.id)?.isReady);
  }

  canStartMatch(): boolean {
    return this.members().length >= 2;
  }

  copyPin(): void {
    const code = this.room()?.roomCode || '';
    if (code) {
      navigator.clipboard.writeText(code);
      this.copiedPin.set(true);
      this.sound.playChime();
      setTimeout(() => this.copiedPin.set(false), 2000);
    }
  }

  toggleReady(): void {
    this.sound.playPop();
    this.roomService.toggleReady(this.roomId).subscribe(updated => {
      this.room.set(updated);
      this.members.set(updated.members || []);
      this.stomp.sendReady(this.roomId);
    });
  }

  startMatch(): void {
    this.sound.playFanfare();
    this.roomService.startMatch(this.roomId).subscribe(() => {
      this.stomp.sendStart(this.roomId);
      this.router.navigate(['/game', this.roomId]);
    });
  }

  sendReaction(emoji: string): void {
    this.sound.playPop();
    this.stomp.sendReaction(this.roomId, emoji);
    this.chatMessages.update(msgs => [
      ...msgs,
      { id: Date.now().toString(), sender: 'You', text: `reacted ${emoji}` }
    ]);
  }

  sendChat(): void {
    if (!this.chatText.trim()) return;
    this.sound.playPop();
    const text = this.chatText.trim();
    this.chatText = '';
    const me = this.auth.currentUser()?.displayName || 'You';
    this.chatMessages.update(msgs => [
      ...msgs,
      { id: Date.now().toString(), sender: me, text }
    ]);
  }

  leaveRoom(): void {
    this.sound.playPop();
    this.roomService.leaveRoom(this.roomId).subscribe(() => {
      this.router.navigate(['/home']);
    });
  }
}
