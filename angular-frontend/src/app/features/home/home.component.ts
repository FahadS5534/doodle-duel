import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { RoomService } from '../../core/services/room.service';
import { SoundService } from '../../core/services/sound.service';
import { NavbarComponent } from '../../shared/components/navbar/navbar.component';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';
import { AvatarWidgetComponent } from '../../shared/components/avatar-widget/avatar-widget.component';
import { CreateRoomRequest, Room } from '../../core/models/room.model';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterModule,
    NavbarComponent,
    AmbientDoodleComponent,
    AvatarWidgetComponent
  ],
  template: `
    <app-ambient-doodle></app-ambient-doodle>
    <app-navbar></app-navbar>

    <main class="home-page">
      <div class="home-container">
        <!-- 1. Greeting & User Tier Header -->
        <section class="greeting-section">
          <div class="greeting-content">
            <div class="greeting-badge">
              <span class="dot"></span>
              <span>Online Arena</span>
            </div>
            <h1 class="greeting-title">
              Ready to doodle, <span class="highlight">{{ auth.currentUser()?.displayName || 'Artist' }}</span>?
            </h1>
            <p class="greeting-subtitle">
              Draw against real players, guess words in milliseconds, and climb the Season 4 leaderboard.
            </p>
          </div>

          <div class="level-card glass-card">
            <div class="level-top">
              <span class="level-title">Rank Tier</span>
              <span class="level-num">Lvl {{ auth.currentUser()?.level || 1 }}</span>
            </div>
            <div class="progress-bar">
              <div class="progress-fill" [style.width.%]="((auth.currentUser()?.xp || 40) % 100)"></div>
            </div>
            <div class="level-bottom">
              <span>{{ (auth.currentUser()?.xp || 40) % 100 }}/100 XP</span>
              <span class="tier-tag">Master Doodler</span>
            </div>
          </div>
        </section>

        <!-- 2. Hero Banner: Season 4 Masterpiece -->
        <section class="season-banner glass-card">
          <div class="banner-content">
            <div class="badge-pill badge-yellow">⭐ Season 4 Live</div>
            <h2>Masterpiece Championship</h2>
            <p>Compete in ranked rooms to win exclusive animated brush strokes, titles, and coin multipliers.</p>
            <div class="banner-actions">
              <button class="btn-coral btn-sm" (click)="openCreateModal()">
                <span>🚀 Host a Match</span>
              </button>
              <a routerLink="/leaderboard" class="btn-outline btn-sm" (click)="sound.playPop()">
                <span>🏆 View Rankings</span>
              </a>
            </div>
          </div>
          <div class="banner-illustration">
            <div class="floating-palette">🎨</div>
            <div class="floating-sparkle sparkle-1">✨</div>
            <div class="floating-sparkle sparkle-2">⚡</div>
          </div>
        </section>

        <!-- 3. Primary Game Action Bento Grid -->
        <section class="action-bento">
          <!-- Create Game Card -->
          <div class="bento-card card-create glass-card interactive" (click)="openCreateModal()">
            <div class="card-icon-box coral">🚀</div>
            <div class="card-text">
              <h3>Create Room</h3>
              <p>Custom draw time, round limits, categories & private codes.</p>
            </div>
            <div class="card-arrow">→</div>
          </div>

          <!-- Join with Code Card -->
          <div class="bento-card card-join glass-card interactive" (click)="openJoinModal()">
            <div class="card-icon-box mint">🔑</div>
            <div class="card-text">
              <h3>Join with Code</h3>
              <p>Enter a 6-character room PIN to join friends immediately.</p>
            </div>
            <div class="card-arrow">→</div>
          </div>

          <!-- Discover Public Rooms -->
          <a routerLink="/discover" class="bento-card card-discover glass-card interactive" (click)="sound.playPop()">
            <div class="card-icon-box yellow">🔍</div>
            <div class="card-text">
              <h3>Discover Public Lobbies</h3>
              <p>Find open matches and jump straight into drawing action.</p>
            </div>
            <div class="card-arrow">→</div>
          </a>

          <!-- Warm-up Sketchpad -->
          <a routerLink="/sketchpad" class="bento-card card-sketchpad glass-card interactive" (click)="sound.playPop()">
            <div class="card-icon-box lavender">🖌️</div>
            <div class="card-text">
              <h3>Warm-up Sketchpad</h3>
              <p>Offline solo canvas with 150+ categorized word prompts.</p>
            </div>
            <div class="card-arrow">→</div>
          </a>
        </section>

        <!-- 4. Play With Friends Strip -->
        <section class="friends-strip glass-card">
          <div class="strip-header">
            <h3>Online Artists & Friends</h3>
            <span class="badge-pill badge-mint">3 Active Now</span>
          </div>
          <div class="friends-list">
            @for (f of mockFriends; track f.name) {
              <div class="friend-chip" (click)="sound.playPop()">
                <app-avatar-widget [avatarUrl]="f.avatar" [name]="f.name" [size]="42" [showLevel]="true" [level]="f.level"></app-avatar-widget>
                <div class="friend-info">
                  <span class="friend-name">{{ f.name }}</span>
                  <span class="friend-status">{{ f.status }}</span>
                </div>
              </div>
            }
          </div>
        </section>

        <!-- 5. Career Snapshot Bento Grid -->
        <section class="career-section">
          <h2 class="section-title">Career Snapshot</h2>
          <div class="career-grid">
            <div class="career-stat-card glass-card">
              <span class="stat-emoji">🎮</span>
              <span class="stat-value">28</span>
              <span class="stat-label">Matches Played</span>
            </div>
            <div class="career-stat-card glass-card">
              <span class="stat-emoji">🏆</span>
              <span class="stat-value">19</span>
              <span class="stat-label">Victories (68% Win)</span>
            </div>
            <div class="career-stat-card glass-card">
              <span class="stat-emoji">💡</span>
              <span class="stat-value">142</span>
              <span class="stat-label">Correct Guesses</span>
            </div>
            <div class="career-stat-card glass-card">
              <span class="stat-emoji">🔥</span>
              <span class="stat-value">{{ auth.currentUser()?.streak || 5 }} Days</span>
              <span class="stat-label">Daily Streak</span>
            </div>
          </div>
        </section>
      </div>
    </main>

    <!-- Create Room Modal -->
    @if (showCreateModal()) {
      <div class="modal-overlay" (click)="closeCreateModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>Create a Game Room</h3>
            <button class="close-btn" (click)="closeCreateModal()">✕</button>
          </div>

          <form (ngSubmit)="handleCreateRoom()" class="room-form">
            <div class="field">
              <label>Room Name</label>
              <input type="text" class="input-glass" [(ngModel)]="newRoom.name" name="name" required placeholder="e.g. Maya's Doodle Lounge" />
            </div>

            <div class="form-row">
              <div class="field">
                <label>Draw Time (Seconds)</label>
                <select class="input-glass" [(ngModel)]="newRoom.drawTimeSeconds" name="drawTime">
                  <option [value]="30">30s (Fast Blitz)</option>
                  <option [value]="45">45s (Standard)</option>
                  <option [value]="60">60s (Balanced)</option>
                  <option [value]="90">90s (Relaxed)</option>
                </select>
              </div>

              <div class="field">
                <label>Rounds</label>
                <select class="input-glass" [(ngModel)]="newRoom.totalRounds" name="rounds">
                  <option [value]="2">2 Rounds</option>
                  <option [value]="3">3 Rounds</option>
                  <option [value]="4">4 Rounds</option>
                  <option [value]="6">6 Rounds</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="field">
                <label>Category</label>
                <select class="input-glass" [(ngModel)]="newRoom.category" name="category">
                  <option value="GENERAL">General Mix</option>
                  <option value="ANIMALS">Animals & Nature</option>
                  <option value="FOOD">Food & Cooking</option>
                  <option value="OBJECTS">Everyday Objects</option>
                  <option value="POP_CULTURE">Movies & Gaming</option>
                </select>
              </div>

              <div class="field">
                <label>Difficulty</label>
                <select class="input-glass" [(ngModel)]="newRoom.difficulty" name="difficulty">
                  <option value="EASY">Easy</option>
                  <option value="MEDIUM">Medium</option>
                  <option value="HARD">Hard</option>
                </select>
              </div>
            </div>

            <div class="visibility-toggle">
              <label class="toggle-label">
                <input type="checkbox" [checked]="newRoom.visibility === 'PUBLIC'" (change)="toggleVisibility($event)" />
                <span>Make Public (Visible in Discover list)</span>
              </label>
            </div>

            <button type="submit" class="btn-coral btn-block" [disabled]="isCreatingRoom || !newRoom.name">
              @if (isCreatingRoom) {
                <span>Setting up room...</span>
              } @else {
                <span>Launch Lobby 🚀</span>
              }
            </button>
          </form>
        </div>
      </div>
    }

    <!-- Join Room Modal -->
    @if (showJoinModal()) {
      <div class="modal-overlay" (click)="closeJoinModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>Enter Room Code</h3>
            <button class="close-btn" (click)="closeJoinModal()">✕</button>
          </div>

          <p class="modal-desc">
            Type the 6-character room PIN provided by your match host.
          </p>

          @if (joinError) {
            <div class="error-banner">⚠️ {{ joinError }}</div>
          }

          <div class="pin-input-group">
            <input
              type="text"
              class="input-glass pin-field"
              [(ngModel)]="joinCode"
              placeholder="e.g. DOODLE"
              maxlength="8"
              autofocus
              (keyup.enter)="handleJoinRoom()"
            />
          </div>

          <button class="btn-mint btn-block" [disabled]="isJoining || !joinCode.trim()" (click)="handleJoinRoom()">
            @if (isJoining) {
              <span>Connecting to lobby...</span>
            } @else {
              <span>Join Match Now 🎮</span>
            }
          </button>
        </div>
      </div>
    }
  `,
  styles: [`
    .home-page {
      position: relative;
      min-height: 100vh;
      padding: 100px 16px 100px;
      z-index: 1;
    }
    .home-container {
      max-width: 1100px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 28px;
    }

    /* Greeting Section */
    .greeting-section {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
      flex-wrap: wrap;
    }
    .greeting-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 12px;
      font-weight: 700;
      color: #007A6E;
      background: rgba(46, 196, 182, 0.15);
      padding: 4px 10px;
      border-radius: var(--radius-full);
      margin-bottom: 8px;
    }
    .greeting-badge .dot {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--accent-mint);
    }
    .greeting-title {
      font-size: 30px;
      font-weight: 800;
      line-height: 1.2;
      margin-bottom: 6px;
    }
    .greeting-title .highlight {
      color: var(--primary-coral);
    }
    .greeting-subtitle {
      font-size: 14px;
      color: var(--text-secondary);
      max-width: 580px;
    }

    .level-card {
      min-width: 220px;
      padding: 16px 20px;
    }
    .level-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
    }
    .level-title {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-secondary);
    }
    .level-num {
      font-family: var(--font-heading);
      font-size: 15px;
      font-weight: 800;
      color: var(--primary-coral);
    }
    .progress-bar {
      height: 8px;
      background: var(--surface-container);
      border-radius: var(--radius-full);
      overflow: hidden;
      margin-bottom: 8px;
    }
    .progress-fill {
      height: 100%;
      background: var(--coral-gradient);
      border-radius: var(--radius-full);
      transition: width 0.4s ease;
    }
    .level-bottom {
      display: flex;
      justify-content: space-between;
      font-size: 11px;
      font-weight: 600;
      color: var(--text-secondary);
    }
    .tier-tag {
      color: var(--accent-mint);
      font-weight: 700;
    }

    /* Season Banner */
    .season-banner {
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(255, 248, 240, 0.95) 100%);
      padding: 28px 32px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: relative;
      overflow: hidden;
    }
    .banner-content {
      max-width: 560px;
      display: flex;
      flex-direction: column;
      gap: 10px;
      z-index: 2;
    }
    .banner-content h2 {
      font-size: 26px;
      font-weight: 800;
    }
    .banner-content p {
      font-size: 14px;
      color: var(--text-secondary);
    }
    .banner-actions {
      display: flex;
      gap: 12px;
      margin-top: 8px;
    }
    .banner-illustration {
      position: relative;
      width: 140px;
      height: 140px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .floating-palette {
      font-size: 84px;
      filter: drop-shadow(0 12px 24px rgba(255, 87, 51, 0.25));
      animation: floatDoodle 6s ease-in-out infinite;
    }
    .floating-sparkle {
      position: absolute;
      font-size: 28px;
    }
    .sparkle-1 { top: 0; left: 10px; animation: bounceSlow 2s infinite; }
    .sparkle-2 { bottom: 10px; right: 10px; animation: bounceSlow 2.5s infinite; }

    /* Bento Grid */
    .action-bento {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
      gap: 16px;
    }
    .bento-card {
      padding: 22px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      min-height: 160px;
      position: relative;
      cursor: pointer;
    }
    .card-icon-box {
      width: 48px;
      height: 48px;
      border-radius: var(--radius-md);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      margin-bottom: 16px;
    }
    .card-icon-box.coral { background: rgba(255, 87, 51, 0.15); }
    .card-icon-box.mint { background: rgba(46, 196, 182, 0.15); }
    .card-icon-box.yellow { background: rgba(255, 209, 102, 0.25); }
    .card-icon-box.lavender { background: rgba(184, 169, 201, 0.25); }

    .card-text h3 {
      font-size: 18px;
      font-weight: 800;
      margin-bottom: 6px;
    }
    .card-text p {
      font-size: 13px;
      color: var(--text-secondary);
      line-height: 1.4;
    }
    .card-arrow {
      position: absolute;
      top: 22px;
      right: 22px;
      font-size: 18px;
      font-weight: 700;
      color: var(--text-muted);
      transition: transform 0.2s, color 0.2s;
    }
    .bento-card:hover .card-arrow {
      transform: translateX(4px);
      color: var(--primary-coral);
    }

    /* Friends Strip */
    .friends-strip {
      padding: 20px 24px;
    }
    .strip-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 16px;
    }
    .strip-header h3 {
      font-size: 17px;
      font-weight: 800;
    }
    .friends-list {
      display: flex;
      gap: 16px;
      overflow-x: auto;
      padding-bottom: 4px;
    }
    .friend-chip {
      display: flex;
      align-items: center;
      gap: 10px;
      background: #FFFFFF;
      padding: 8px 14px;
      border-radius: var(--radius-full);
      border: 1px solid rgba(40, 30, 20, 0.08);
      cursor: pointer;
      white-space: nowrap;
      transition: all 0.2s;
    }
    .friend-chip:hover {
      border-color: var(--primary-coral);
      transform: translateY(-2px);
    }
    .friend-info {
      display: flex;
      flex-direction: column;
    }
    .friend-name {
      font-size: 13px;
      font-weight: 700;
    }
    .friend-status {
      font-size: 11px;
      color: var(--accent-mint);
      font-weight: 600;
    }

    /* Career Section */
    .career-section {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .section-title {
      font-size: 20px;
      font-weight: 800;
    }
    .career-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 14px;
    }
    .career-stat-card {
      padding: 18px;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .stat-emoji {
      font-size: 26px;
    }
    .stat-value {
      font-family: var(--font-heading);
      font-size: 24px;
      font-weight: 800;
    }
    .stat-label {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-secondary);
    }

    /* Modals */
    .modal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 18px;
    }
    .modal-header h3 {
      font-size: 22px;
      font-weight: 800;
    }
    .close-btn {
      font-size: 18px;
      color: var(--text-secondary);
    }
    .room-form {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }
    .field {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .field label {
      font-size: 12px;
      font-weight: 700;
      color: var(--text-secondary);
    }
    .visibility-toggle {
      margin: 4px 0 10px;
    }
    .toggle-label {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
    }
    .pin-field {
      font-size: 24px;
      font-weight: 800;
      letter-spacing: 4px;
      text-align: center;
      text-transform: uppercase;
      padding: 16px;
      margin: 16px 0 20px;
    }
    .error-banner {
      background: var(--error-container);
      color: var(--error);
      padding: 10px;
      border-radius: var(--radius-md);
      font-size: 13px;
      font-weight: 600;
      margin-bottom: 12px;
    }
  `]
})
export class HomeComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  private readonly roomService = inject(RoomService);
  private readonly router = inject(Router);

  showCreateModal = signal<boolean>(false);
  showJoinModal = signal<boolean>(false);

  isCreatingRoom = false;
  isJoining = false;
  joinCode = '';
  joinError: string | null = null;

  newRoom: CreateRoomRequest = {
    name: (this.auth.currentUser()?.displayName || 'Artist') + "'s Arena",
    visibility: 'PUBLIC',
    maxPlayers: 8,
    totalRounds: 4,
    drawTimeSeconds: 60,
    difficulty: 'MEDIUM',
    category: 'GENERAL'
  };

  mockFriends = [
    { name: 'Sarah Scribbles', status: 'Drawing in Blitz #4', level: 12, avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Sarah' },
    { name: 'Neon Painter', status: 'In Waiting Lobby', level: 9, avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Neon' },
    { name: 'Sketch Wizard', status: 'Practicing Sketchpad', level: 16, avatar: 'https://api.dicebear.com/7.x/bottts/svg?seed=Wizard' }
  ];

  openCreateModal(): void {
    this.sound.playPop();
    this.showCreateModal.set(true);
  }

  closeCreateModal(): void {
    this.showCreateModal.set(false);
  }

  openJoinModal(): void {
    this.sound.playPop();
    this.joinError = null;
    this.showJoinModal.set(true);
  }

  closeJoinModal(): void {
    this.showJoinModal.set(false);
  }

  toggleVisibility(event: Event): void {
    const checked = (event.target as HTMLInputElement).checked;
    this.newRoom.visibility = checked ? 'PUBLIC' : 'PRIVATE';
  }

  handleCreateRoom(): void {
    this.sound.playPop();
    this.isCreatingRoom = true;
    this.roomService.createRoom(this.newRoom).subscribe({
      next: (room: Room) => {
        this.isCreatingRoom = false;
        this.closeCreateModal();
        this.sound.playChime();
        this.router.navigate(['/lobby', room.id]);
      },
      error: () => {
        this.isCreatingRoom = false;
      }
    });
  }

  handleJoinRoom(): void {
    if (!this.joinCode.trim()) return;
    this.sound.playPop();
    this.isJoining = true;
    this.joinError = null;

    this.roomService.joinRoomByCode(this.joinCode).subscribe({
      next: (room: Room) => {
        this.isJoining = false;
        this.closeJoinModal();
        this.sound.playChime();
        this.router.navigate(['/lobby', room.id]);
      },
      error: (err) => {
        this.isJoining = false;
        this.joinError = err.error?.message || 'Room code not found or lobby full.';
      }
    });
  }
}
