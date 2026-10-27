import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { RouterModule } from '@angular/router';
import { ConfigService } from '../../core/services/config.service';
import { SoundService } from '../../core/services/sound.service';
import { NavbarComponent } from '../../shared/components/navbar/navbar.component';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';
import { AvatarWidgetComponent } from '../../shared/components/avatar-widget/avatar-widget.component';
import { ApiResponse } from '../../core/models/user.model';

export interface LeaderboardEntry {
  rank: number;
  userId: string;
  username: string;
  displayName: string;
  avatarUrl?: string;
  level: number;
  totalPoints: number;
  matchesWon: number;
  winRate: number;
}

@Component({
  selector: 'app-leaderboard',
  standalone: true,
  imports: [CommonModule, RouterModule, NavbarComponent, AmbientDoodleComponent, AvatarWidgetComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>
    <app-navbar></app-navbar>

    <div class="leaderboard-page">
      <div class="leaderboard-container">
        <!-- Header -->
        <div class="page-header">
          <div class="badge-pill badge-yellow">🏆 Season 4 Leaderboard</div>
          <h1>Hall of Fame</h1>
          <p>Global rankings of top speed doodlers and guess masters.</p>
        </div>

        <!-- Period Toggle Tabs -->
        <div class="tab-toggle glass-card">
          <button
            class="tab-btn"
            [class.active]="selectedPeriod === 'all-time'"
            (click)="setPeriod('all-time')"
          >
            🌟 All-Time Legends
          </button>
          <button
            class="tab-btn"
            [class.active]="selectedPeriod === 'weekly'"
            (click)="setPeriod('weekly')"
          >
            ⚡ Weekly Blitz
          </button>
        </div>

        <!-- Top 3 Podium -->
        @if (podium().length >= 3) {
          <div class="podium-section">
            <!-- 2nd Place -->
            <div class="podium-card rank-2 glass-card">
              <span class="podium-medal">🥈</span>
              <app-avatar-widget [avatarUrl]="podium()[1].avatarUrl" [name]="podium()[1].displayName" [size]="64" [level]="podium()[1].level" [showLevel]="true"></app-avatar-widget>
              <h3 class="podium-name">{{ podium()[1].displayName }}</h3>
              <span class="podium-pts">{{ podium()[1].totalPoints }} Pts</span>
              <span class="podium-winrate">{{ podium()[1].winRate }}% Win Rate</span>
            </div>

            <!-- 1st Place (Crown) -->
            <div class="podium-card rank-1 glass-card">
              <div class="champion-crown">👑</div>
              <span class="podium-medal">🥇</span>
              <app-avatar-widget [avatarUrl]="podium()[0].avatarUrl" [name]="podium()[0].displayName" [size]="80" [level]="podium()[0].level" [showLevel]="true"></app-avatar-widget>
              <h3 class="podium-name champion">{{ podium()[0].displayName }}</h3>
              <span class="podium-pts">{{ podium()[0].totalPoints }} Pts</span>
              <span class="podium-winrate">{{ podium()[0].winRate }}% Win Rate</span>
            </div>

            <!-- 3rd Place -->
            <div class="podium-card rank-3 glass-card">
              <span class="podium-medal">🥉</span>
              <app-avatar-widget [avatarUrl]="podium()[2].avatarUrl" [name]="podium()[2].displayName" [size]="64" [level]="podium()[2].level" [showLevel]="true"></app-avatar-widget>
              <h3 class="podium-name">{{ podium()[2].displayName }}</h3>
              <span class="podium-pts">{{ podium()[2].totalPoints }} Pts</span>
              <span class="podium-winrate">{{ podium()[2].winRate }}% Win Rate</span>
            </div>
          </div>
        }

        <!-- Leaderboard Table -->
        <div class="table-card glass-card">
          <table class="ranks-table">
            <thead>
              <tr>
                <th>Rank</th>
                <th>Artist</th>
                <th>Points</th>
                <th>Matches Won</th>
                <th>Win Rate</th>
              </tr>
            </thead>
            <tbody>
              @for (entry of entries(); track entry.userId) {
                <tr class="rank-row">
                  <td class="rank-col">
                    <span class="rank-number" [class.top3]="entry.rank <= 3">
                      #{{ entry.rank }}
                    </span>
                  </td>
                  <td class="user-col">
                    <div class="user-info">
                      <app-avatar-widget [avatarUrl]="entry.avatarUrl" [name]="entry.displayName" [size]="36"></app-avatar-widget>
                      <div class="user-meta">
                        <span class="user-name">{{ entry.displayName }}</span>
                        <span class="user-lvl">Level {{ entry.level }}</span>
                      </div>
                    </div>
                  </td>
                  <td class="pts-col">{{ entry.totalPoints }}</td>
                  <td>{{ entry.matchesWon }}</td>
                  <td>
                    <span class="badge-pill badge-mint">{{ entry.winRate }}%</span>
                  </td>
                </tr>
              }
            </tbody>
          </table>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .leaderboard-page {
      position: relative;
      min-height: 100vh;
      padding: 100px 16px 100px;
      z-index: 1;
    }
    .leaderboard-container {
      max-width: 960px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 24px;
    }

    .page-header h1 {
      font-size: 32px;
      font-weight: 800;
      margin: 8px 0 4px;
    }
    .page-header p {
      color: var(--text-secondary);
      font-size: 15px;
    }

    .tab-toggle {
      padding: 6px;
      display: flex;
      gap: 8px;
      max-width: 360px;
      border-radius: var(--radius-full);
    }
    .tab-btn {
      flex: 1;
      padding: 10px 16px;
      border-radius: var(--radius-full);
      font-size: 13px;
      font-weight: 700;
      color: var(--text-secondary);
      transition: all 0.2s;
    }
    .tab-btn.active {
      background: var(--coral-gradient);
      color: #FFFFFF;
      box-shadow: 0 4px 12px rgba(255, 87, 51, 0.3);
    }

    /* Podium */
    .podium-section {
      display: flex;
      align-items: flex-end;
      justify-content: center;
      gap: 16px;
      margin: 12px 0 8px;
    }
    .podium-card {
      flex: 1;
      max-width: 240px;
      padding: 24px 16px;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 8px;
      position: relative;
    }
    .podium-card.rank-1 {
      max-width: 270px;
      padding: 32px 20px;
      background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(255, 248, 230, 0.95) 100%);
      border: 2px solid var(--accent-yellow);
      transform: translateY(-16px);
      box-shadow: 0 16px 36px rgba(255, 209, 102, 0.25);
    }
    .champion-crown {
      position: absolute;
      top: -16px;
      font-size: 30px;
      filter: drop-shadow(0 4px 8px rgba(0,0,0,0.15));
      animation: bounceSlow 2.5s infinite;
    }
    .podium-medal {
      font-size: 26px;
    }
    .podium-name {
      font-size: 16px;
      font-weight: 800;
    }
    .podium-name.champion {
      font-size: 18px;
      color: var(--primary-coral);
    }
    .podium-pts {
      font-family: var(--font-heading);
      font-size: 16px;
      font-weight: 800;
      color: var(--primary-coral);
    }
    .podium-winrate {
      font-size: 12px;
      color: var(--text-secondary);
      font-weight: 600;
    }

    /* Table */
    .table-card {
      padding: 16px;
      overflow-x: auto;
    }
    .ranks-table {
      width: 100%;
      border-collapse: collapse;
      text-align: left;
    }
    .ranks-table th {
      padding: 12px 14px;
      font-size: 12px;
      font-weight: 800;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      border-bottom: 1px solid rgba(40, 30, 20, 0.08);
    }
    .ranks-table td {
      padding: 14px;
      font-size: 14px;
      border-bottom: 1px solid rgba(40, 30, 20, 0.04);
    }
    .rank-row:hover {
      background: rgba(255, 255, 255, 0.6);
    }
    .rank-number {
      font-family: var(--font-heading);
      font-weight: 800;
      color: var(--text-secondary);
    }
    .rank-number.top3 {
      color: var(--primary-coral);
    }
    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .user-meta {
      display: flex;
      flex-direction: column;
    }
    .user-name {
      font-weight: 700;
      color: var(--text-primary);
    }
    .user-lvl {
      font-size: 11px;
      color: var(--text-muted);
      font-weight: 600;
    }
    .pts-col {
      font-family: var(--font-heading);
      font-weight: 800;
      color: var(--primary-coral);
    }

    @media (max-width: 680px) {
      .podium-section {
        flex-direction: column;
        align-items: stretch;
      }
      .podium-card.rank-1 {
        transform: none;
      }
    }
  `]
})
export class LeaderboardComponent implements OnInit {
  private readonly http = inject(HttpClient);
  private readonly config = inject(ConfigService);
  readonly sound = inject(SoundService);

  selectedPeriod = 'all-time';
  entries = signal<LeaderboardEntry[]>([]);
  podium = signal<LeaderboardEntry[]>([]);

  private mockEntries: LeaderboardEntry[] = [
    { rank: 1, userId: 'u-1', username: 'picasso_pro', displayName: 'PicassoPro 👑', level: 24, totalPoints: 12450, matchesWon: 42, winRate: 78, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Picasso' },
    { rank: 2, userId: 'u-2', username: 'neon_brush', displayName: 'NeonBrush', level: 19, totalPoints: 9800, matchesWon: 31, winRate: 71, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Neon' },
    { rank: 3, userId: 'u-3', username: 'speedy_doodler', displayName: 'SpeedyDoodler', level: 16, totalPoints: 8400, matchesWon: 26, winRate: 65, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Speedy' },
    { rank: 4, userId: 'u-4', username: 'pixel_queen', displayName: 'PixelQueen', level: 14, totalPoints: 6950, matchesWon: 20, winRate: 61, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Queen' },
    { rank: 5, userId: 'u-5', username: 'canvas_ninja', displayName: 'CanvasNinja', level: 12, totalPoints: 5720, matchesWon: 17, winRate: 58, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Ninja' },
    { rank: 6, userId: 'u-6', username: 'maya_artist', displayName: 'Maya Artist', level: 10, totalPoints: 4600, matchesWon: 14, winRate: 54, avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=Maya' }
  ];

  ngOnInit(): void {
    this.loadLeaderboard();
  }

  setPeriod(period: string): void {
    this.sound.playPop();
    this.selectedPeriod = period;
    this.loadLeaderboard();
  }

  loadLeaderboard(): void {
    this.http.get<ApiResponse<LeaderboardEntry[]>>(`${this.config.apiUrl()}/leaderboard?period=${this.selectedPeriod}`).subscribe({
      next: (res) => {
        const list = res.data && res.data.length > 0 ? res.data : this.mockEntries;
        this.entries.set(list);
        this.podium.set(list.slice(0, 3));
      },
      error: () => {
        this.entries.set(this.mockEntries);
        this.podium.set(this.mockEntries.slice(0, 3));
      }
    });
  }
}
