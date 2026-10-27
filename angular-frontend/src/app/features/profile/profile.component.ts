import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SoundService } from '../../core/services/sound.service';
import { NavbarComponent } from '../../shared/components/navbar/navbar.component';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';
import { AvatarWidgetComponent } from '../../shared/components/avatar-widget/avatar-widget.component';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, NavbarComponent, AmbientDoodleComponent, AvatarWidgetComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>
    <app-navbar></app-navbar>

    <div class="profile-page">
      <div class="profile-container">
        <!-- 1. User Hero Card -->
        <div class="user-hero glass-card">
          <div class="avatar-col">
            <app-avatar-widget
              [avatarUrl]="auth.currentUser()?.avatarUrl"
              [name]="auth.currentUser()?.displayName || 'Artist'"
              [size]="84"
              [level]="auth.currentUser()?.level"
              [showLevel]="true"
            ></app-avatar-widget>
            <button class="change-avatar-btn" (click)="toggleAvatarPicker()">
              ✏️ Change Avatar
            </button>
          </div>

          <div class="user-details">
            <div class="name-badge-row">
              <h2>{{ auth.currentUser()?.displayName }}</h2>
              @if (auth.currentUser()?.isGuest) {
                <span class="badge-pill badge-yellow">⚡ Guest Account</span>
              } @else {
                <span class="badge-pill badge-mint">✓ Verified Artist</span>
              }
            </div>
            <p class="user-handle">&#64;{{ auth.currentUser()?.username }}</p>

            <!-- Currency & Streak -->
            <div class="stats-ribbon">
              <div class="ribbon-item">
                <span class="ribbon-icon">🪙</span>
                <span class="ribbon-val">{{ auth.currentUser()?.coins || 100 }}</span>
                <span class="ribbon-lbl">Coins</span>
              </div>
              <div class="ribbon-item">
                <span class="ribbon-icon">🔥</span>
                <span class="ribbon-val">{{ auth.currentUser()?.streak || 5 }} Days</span>
                <span class="ribbon-lbl">Streak</span>
              </div>
              <div class="ribbon-item">
                <span class="ribbon-icon">⭐</span>
                <span class="ribbon-val">Lvl {{ auth.currentUser()?.level || 1 }}</span>
                <span class="ribbon-lbl">Level</span>
              </div>
            </div>
          </div>

          <div class="actions-col">
            <button class="btn-outline btn-sm logout-btn" (click)="logout()">
              Sign Out 🚪
            </button>
          </div>
        </div>

        <!-- Avatar Picker Dialog / Drawer -->
        @if (showAvatarPicker()) {
          <div class="avatar-picker glass-card">
            <div class="picker-header">
              <h3>Choose Artist Avatar</h3>
              <button class="close-btn" (click)="toggleAvatarPicker()">✕</button>
            </div>
            <div class="avatar-grid">
              @for (av of avatarOptions; track av.seed) {
                <div class="avatar-option" (click)="selectAvatar(av.url)">
                  <img [src]="av.url" [alt]="av.name" class="option-img" />
                  <span>{{ av.name }}</span>
                </div>
              }
            </div>
          </div>
        }

        <!-- 2. Guest Upgrade Banner (If Guest) -->
        @if (auth.currentUser()?.isGuest) {
          <div class="upgrade-banner glass-card">
            <div class="upgrade-text">
              <h3>🔒 Protect Your Progress</h3>
              <p>You are currently playing as a guest. Link an email to save your rank, stats, and achievements permanently.</p>
            </div>
            <a routerLink="/register" class="btn-coral btn-sm" (click)="sound.playPop()">
              Create Account
            </a>
          </div>
        }

        <!-- 3. Career Statistics Bento -->
        <section class="stats-section">
          <h2>Career Performance</h2>
          <div class="stats-grid">
            <div class="stat-card glass-card">
              <span class="stat-icon">🎮</span>
              <span class="stat-num">36</span>
              <span class="stat-text">Matches Played</span>
            </div>
            <div class="stat-card glass-card">
              <span class="stat-icon">🏆</span>
              <span class="stat-num">24</span>
              <span class="stat-text">Victories (67% Win)</span>
            </div>
            <div class="stat-card glass-card">
              <span class="stat-icon">💡</span>
              <span class="stat-num">178</span>
              <span class="stat-text">Correct Guesses</span>
            </div>
            <div class="stat-card glass-card">
              <span class="stat-icon">🎨</span>
              <span class="stat-num">48</span>
              <span class="stat-text">Drawings Completed</span>
            </div>
          </div>
        </section>

        <!-- 4. Recent Matches History -->
        <section class="history-section">
          <h2>Recent Match History</h2>
          <div class="history-list glass-card">
            @for (match of mockHistory; track match.id) {
              <div class="history-row">
                <div class="placement-badge" [class.gold]="match.rank === 1" [class.silver]="match.rank === 2" [class.bronze]="match.rank === 3">
                  {{ match.rank === 1 ? '🥇 1st Place' : (match.rank === 2 ? '🥈 2nd Place' : '🥉 3rd Place') }}
                </div>
                <div class="match-meta">
                  <span class="match-name">{{ match.roomName }}</span>
                  <span class="match-time">{{ match.timeAgo }} • Category: {{ match.category }}</span>
                </div>
                <div class="match-score">
                  <span class="score-val">+{{ match.points }} Pts</span>
                  <span class="xp-val">+{{ match.xp }} XP</span>
                </div>
              </div>
            }
          </div>
        </section>
      </div>
    </div>
  `,
  styles: [`
    .profile-page {
      position: relative;
      min-height: 100vh;
      padding: 100px 16px 100px;
      z-index: 1;
    }
    .profile-container {
      max-width: 900px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 28px;
    }

    /* User Hero */
    .user-hero {
      padding: 28px;
      display: flex;
      align-items: center;
      gap: 24px;
      flex-wrap: wrap;
    }
    .avatar-col {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 10px;
    }
    .change-avatar-btn {
      font-size: 11px;
      font-weight: 700;
      color: var(--primary-coral);
      cursor: pointer;
    }
    .user-details {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 8px;
      min-width: 240px;
    }
    .name-badge-row {
      display: flex;
      align-items: center;
      gap: 12px;
      flex-wrap: wrap;
    }
    .name-badge-row h2 {
      font-size: 26px;
      font-weight: 800;
    }
    .user-handle {
      font-size: 14px;
      color: var(--text-secondary);
    }
    .stats-ribbon {
      display: flex;
      gap: 16px;
      margin-top: 6px;
    }
    .ribbon-item {
      display: flex;
      align-items: center;
      gap: 6px;
      background: #FFFFFF;
      padding: 6px 12px;
      border-radius: var(--radius-full);
      border: 1px solid rgba(40, 30, 20, 0.08);
    }
    .ribbon-val {
      font-family: var(--font-heading);
      font-weight: 800;
      font-size: 13px;
    }
    .ribbon-lbl {
      font-size: 11px;
      color: var(--text-secondary);
    }
    .actions-col {
      display: flex;
    }
    .logout-btn:hover {
      border-color: var(--error);
      color: var(--error);
    }

    /* Avatar Picker */
    .avatar-picker {
      padding: 20px;
    }
    .picker-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .picker-header h3 {
      font-size: 18px;
      font-weight: 800;
    }
    .close-btn {
      font-size: 16px;
      color: var(--text-secondary);
    }
    .avatar-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
      gap: 14px;
    }
    .avatar-option {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
      cursor: pointer;
      padding: 8px;
      border-radius: var(--radius-md);
      transition: all 0.15s;
    }
    .avatar-option:hover {
      background: rgba(255, 87, 51, 0.1);
      transform: scale(1.08);
    }
    .option-img {
      width: 52px;
      height: 52px;
      border-radius: 50%;
      background: #FFFFFF;
      box-shadow: 0 2px 6px rgba(0,0,0,0.1);
    }
    .avatar-option span {
      font-size: 11px;
      font-weight: 600;
      color: var(--text-secondary);
    }

    /* Upgrade Banner */
    .upgrade-banner {
      padding: 20px 24px;
      background: linear-gradient(135deg, rgba(255, 209, 102, 0.25) 0%, rgba(255, 87, 51, 0.12) 100%);
      border: 1.5px solid var(--accent-yellow);
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .upgrade-text h3 {
      font-size: 18px;
      font-weight: 800;
      margin-bottom: 4px;
    }
    .upgrade-text p {
      font-size: 13px;
      color: var(--text-secondary);
      max-width: 600px;
    }

    /* Stats */
    .stats-section h2, .history-section h2 {
      font-size: 20px;
      font-weight: 800;
      margin-bottom: 14px;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 14px;
    }
    .stat-card {
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }
    .stat-icon {
      font-size: 28px;
    }
    .stat-num {
      font-family: var(--font-heading);
      font-size: 26px;
      font-weight: 800;
    }
    .stat-text {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-secondary);
    }

    /* History */
    .history-list {
      padding: 10px 16px;
    }
    .history-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 14px 10px;
      border-bottom: 1px solid rgba(40, 30, 20, 0.05);
      gap: 14px;
      flex-wrap: wrap;
    }
    .history-row:last-child {
      border-bottom: none;
    }
    .placement-badge {
      font-size: 12px;
      font-weight: 800;
      padding: 4px 10px;
      border-radius: var(--radius-full);
      background: var(--surface-container);
    }
    .placement-badge.gold {
      background: rgba(255, 209, 102, 0.35);
      color: #996B00;
    }
    .placement-badge.silver {
      background: rgba(184, 169, 201, 0.3);
      color: #554466;
    }
    .placement-badge.bronze {
      background: rgba(255, 160, 122, 0.3);
      color: #A04020;
    }
    .match-meta {
      flex: 1;
      display: flex;
      flex-direction: column;
      min-width: 200px;
    }
    .match-name {
      font-weight: 700;
      font-size: 14px;
    }
    .match-time {
      font-size: 12px;
      color: var(--text-muted);
    }
    .match-score {
      text-align: right;
      display: flex;
      flex-direction: column;
    }
    .score-val {
      font-family: var(--font-heading);
      font-size: 15px;
      font-weight: 800;
      color: var(--primary-coral);
    }
    .xp-val {
      font-size: 11px;
      font-weight: 700;
      color: var(--accent-mint);
    }
  `]
})
export class ProfileComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);

  showAvatarPicker = signal<boolean>(false);

  avatarOptions = [
    { name: 'Bot 1', seed: 'Maya', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Maya' },
    { name: 'Bot 2', seed: 'Neon', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Neon' },
    { name: 'Bot 3', seed: 'Fox', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Fox' },
    { name: 'Bot 4', seed: 'King', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=King' },
    { name: 'Bot 5', seed: 'Star', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Star' },
    { name: 'Bot 6', seed: 'Sarah', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Sarah' },
    { name: 'Bot 7', seed: 'Ninja', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Ninja' },
    { name: 'Bot 8', seed: 'Picasso', url: 'https://api.dicebear.com/7.x/bottts/svg?seed=Picasso' }
  ];

  mockHistory = [
    { id: 'm1', rank: 1, roomName: 'Speed Blitz #42', category: 'ANIMALS', timeAgo: '2 hours ago', points: 950, xp: 120 },
    { id: 'm2', rank: 2, roomName: 'Pop Culture Squad', category: 'POP CULTURE', timeAgo: 'Yesterday', points: 720, xp: 90 },
    { id: 'm3', rank: 1, roomName: 'Weekend Doodlers', category: 'GENERAL', timeAgo: '2 days ago', points: 1150, xp: 150 },
    { id: 'm4', rank: 3, roomName: 'Master Lounge', category: 'FOOD', timeAgo: '3 days ago', points: 580, xp: 75 }
  ];

  toggleAvatarPicker(): void {
    this.sound.playPop();
    this.showAvatarPicker.update(v => !v);
  }

  selectAvatar(url: string): void {
    this.sound.playChime();
    this.auth.updateProfileLocally({ avatarUrl: url });
    this.showAvatarPicker.set(false);
  }

  logout(): void {
    this.sound.playPop();
    this.auth.logout();
  }
}
