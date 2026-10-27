import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { SoundService } from '../../../core/services/sound.service';
import { ConfigService } from '../../../core/services/config.service';
import { AvatarWidgetComponent } from '../avatar-widget/avatar-widget.component';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, AvatarWidgetComponent],
  template: `
    <!-- Top Fixed Glass Header -->
    <header class="top-nav glass-card">
      <div class="nav-container">
        <!-- Logo Brand -->
        <a routerLink="/home" class="brand-link" (click)="sound.playPop()">
          <div class="brand-icon">✏️</div>
          <div class="brand-text">
            <span class="brand-title">Doodle Duel</span>
            <span class="brand-tag">Season 4</span>
          </div>
        </a>

        <!-- Right Quick Stats & Controls -->
        <div class="nav-actions">
          <!-- Backend Endpoint Pill (Cloud / Local Toggle) -->
          <button
            class="endpoint-pill"
            [class.local]="config.isUsingLocal()"
            (click)="toggleEndpoint()"
            [title]="config.isUsingLocal() ? 'Using Local Backend (localhost:8080). Click to switch to Cloud.' : 'Using Render Cloud Backend. Click to switch to Local.'"
          >
            <span class="pulse-dot"></span>
            <span>{{ config.isUsingLocal() ? 'Local Dev' : 'Cloud Live' }}</span>
          </button>

          <!-- Sound Mute/Unmute -->
          <button class="icon-btn" (click)="toggleSound()" [title]="sound.isSoundEnabled() ? 'Mute Sounds' : 'Unmute Sounds'">
            {{ sound.isSoundEnabled() ? '🔊' : '🔇' }}
          </button>

          @if (auth.currentUser(); as user) {
            <!-- Streak & Coins -->
            <div class="stat-pill" title="Daily Streak">
              🔥 <span>{{ user.streak || 1 }}</span>
            </div>
            <div class="stat-pill coins" title="Coins">
              🪙 <span>{{ user.coins || 100 }}</span>
            </div>

            <!-- Profile Avatar Link -->
            <a routerLink="/profile" class="profile-link" (click)="sound.playPop()" title="My Profile">
              <app-avatar-widget
                [avatarUrl]="user.avatarUrl"
                [name]="user.displayName"
                [size]="38"
                [level]="user.level"
                [showLevel]="true"
              ></app-avatar-widget>
            </a>
          } @else {
            <a routerLink="/welcome" class="btn-coral btn-sm">Sign In</a>
          }
        </div>
      </div>
    </header>

    <!-- Bottom Floating Glass Navigation Dock -->
    <nav class="bottom-dock glass-card">
      <a routerLink="/home" routerLinkActive="active" class="dock-item" (click)="sound.playPop()">
        <span class="dock-icon">🏠</span>
        <span class="dock-label">Lobby</span>
      </a>
      <a routerLink="/discover" routerLinkActive="active" class="dock-item" (click)="sound.playPop()">
        <span class="dock-icon">🔍</span>
        <span class="dock-label">Discover</span>
      </a>
      <a routerLink="/sketchpad" routerLinkActive="active" class="dock-item highlight" (click)="sound.playPop()">
        <div class="dock-fab">🎨</div>
        <span class="dock-label">Practice</span>
      </a>
      <a routerLink="/leaderboard" routerLinkActive="active" class="dock-item" (click)="sound.playPop()">
        <span class="dock-icon">🏆</span>
        <span class="dock-label">Ranks</span>
      </a>
      <a routerLink="/profile" routerLinkActive="active" class="dock-item" (click)="sound.playPop()">
        <span class="dock-icon">👤</span>
        <span class="dock-label">Profile</span>
      </a>
    </nav>
  `,
  styles: [`
    .top-nav {
      position: fixed;
      top: 12px;
      left: 16px;
      right: 16px;
      max-width: 1200px;
      margin: 0 auto;
      z-index: 100;
      border-radius: var(--radius-xl);
      padding: 10px 18px;
    }
    .nav-container {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }
    .brand-link {
      display: flex;
      align-items: center;
      gap: 10px;
      user-select: none;
    }
    .brand-icon {
      width: 40px;
      height: 40px;
      background: #FFFFFF;
      border-radius: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 20px;
      box-shadow: 0 4px 12px rgba(255, 87, 51, 0.18);
    }
    .brand-text {
      display: flex;
      flex-direction: column;
    }
    .brand-title {
      font-family: var(--font-heading);
      font-weight: 800;
      font-size: 18px;
      color: var(--text-primary);
      line-height: 1.1;
    }
    .brand-tag {
      font-size: 11px;
      font-weight: 600;
      color: var(--primary-coral);
    }

    .nav-actions {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .endpoint-pill {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      border-radius: var(--radius-full);
      background: rgba(46, 196, 182, 0.15);
      color: #007A6E;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }
    .endpoint-pill.local {
      background: rgba(255, 209, 102, 0.25);
      color: #996B00;
    }
    .pulse-dot {
      width: 7px;
      height: 7px;
      border-radius: 50%;
      background: var(--accent-mint);
      animation: pulse 1.8s infinite;
    }
    .endpoint-pill.local .pulse-dot {
      background: #E5A100;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; transform: scale(1); }
      50% { opacity: 0.4; transform: scale(0.85); }
    }

    .icon-btn {
      width: 36px;
      height: 36px;
      border-radius: 50%;
      background: #FFFFFF;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.06);
      transition: transform 0.15s;
    }
    .icon-btn:hover {
      transform: scale(1.08);
    }

    .stat-pill {
      display: flex;
      align-items: center;
      gap: 4px;
      padding: 6px 12px;
      background: rgba(255, 255, 255, 0.85);
      border: 1px solid var(--border-glass);
      border-radius: var(--radius-full);
      font-size: 13px;
      font-weight: 700;
    }
    .stat-pill.coins {
      color: #996B00;
    }
    .btn-sm {
      padding: 8px 16px;
      font-size: 13px;
      border-radius: var(--radius-full);
    }

    /* Bottom Floating Dock */
    .bottom-dock {
      position: fixed;
      bottom: 16px;
      left: 50%;
      transform: translateX(-50%);
      width: calc(100% - 32px);
      max-width: 440px;
      z-index: 100;
      display: flex;
      align-items: center;
      justify-content: space-around;
      padding: 8px 16px;
      border-radius: var(--radius-xl);
    }
    .dock-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 3px;
      color: var(--text-secondary);
      font-size: 11px;
      font-weight: 600;
      transition: all 0.2s cubic-bezier(0.16, 1, 0.3, 1);
      padding: 4px 8px;
      border-radius: var(--radius-md);
    }
    .dock-item:hover, .dock-item.active {
      color: var(--primary-coral);
      transform: translateY(-2px);
    }
    .dock-icon {
      font-size: 20px;
    }
    .dock-item.highlight .dock-fab {
      width: 44px;
      height: 44px;
      margin-top: -18px;
      border-radius: 50%;
      background: var(--coral-gradient);
      box-shadow: var(--coral-button-shadow);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
      transition: transform 0.2s;
    }
    .dock-item.highlight:hover .dock-fab {
      transform: scale(1.1) rotate(5deg);
    }

    @media (max-width: 640px) {
      .stat-pill.coins, .endpoint-pill {
        display: none;
      }
      .top-nav {
        left: 8px;
        right: 8px;
        top: 8px;
        padding: 8px 12px;
      }
    }
  `]
})
export class NavbarComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  readonly config = inject(ConfigService);

  toggleSound(): void {
    this.sound.toggleSound();
    if (this.sound.isSoundEnabled()) {
      this.sound.playChime();
    }
  }

  toggleEndpoint(): void {
    this.config.toggleLocalEndpoints();
    this.sound.playPop();
  }
}
