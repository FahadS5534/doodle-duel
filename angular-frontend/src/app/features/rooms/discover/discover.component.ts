import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { RoomService } from '../../../core/services/room.service';
import { SoundService } from '../../../core/services/sound.service';
import { NavbarComponent } from '../../../shared/components/navbar/navbar.component';
import { AmbientDoodleComponent } from '../../../shared/components/ambient-doodle/ambient-doodle.component';
import { Room } from '../../../core/models/room.model';

@Component({
  selector: 'app-discover',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, NavbarComponent, AmbientDoodleComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>
    <app-navbar></app-navbar>

    <div class="discover-page">
      <div class="discover-container">
        <!-- Header -->
        <div class="page-header">
          <div class="badge-pill badge-mint">⚡ Live Matches</div>
          <h1>Discover Public Lobbies</h1>
          <p>Find an open squad or filter by difficulty and category to duel now.</p>
        </div>

        <!-- Filter & Search Bar -->
        <div class="filter-bar glass-card">
          <div class="search-box">
            <span class="search-icon">🔍</span>
            <input
              type="text"
              class="search-input"
              placeholder="Search by room name..."
              [(ngModel)]="searchQuery"
            />
          </div>

          <div class="filter-chips">
            <button
              class="filter-chip"
              [class.active]="selectedDifficulty === 'ALL'"
              (click)="setDifficulty('ALL')"
            >
              All Levels
            </button>
            <button
              class="filter-chip"
              [class.active]="selectedDifficulty === 'EASY'"
              (click)="setDifficulty('EASY')"
            >
              Easy
            </button>
            <button
              class="filter-chip"
              [class.active]="selectedDifficulty === 'MEDIUM'"
              (click)="setDifficulty('MEDIUM')"
            >
              Medium
            </button>
            <button
              class="filter-chip"
              [class.active]="selectedDifficulty === 'HARD'"
              (click)="setDifficulty('HARD')"
            >
              Hard
            </button>
          </div>
        </div>

        <!-- Rooms Grid -->
        @if (isLoading()) {
          <div class="loading-state">
            <div class="spinner"></div>
            <p>Scanning active lobbies...</p>
          </div>
        } @else {
          <div class="rooms-grid">
            @for (room of filteredRooms(); track room.id) {
              <div class="room-card glass-card interactive" (click)="joinRoom(room)">
                <div class="room-top">
                  <div class="room-badge" [class.in-progress]="room.status === 'IN_PROGRESS'">
                    {{ room.status === 'IN_PROGRESS' ? '⚔️ In Match' : '🟢 Waiting in Lobby' }}
                  </div>
                  <span class="pin-chip">PIN: {{ room.roomCode }}</span>
                </div>

                <h3 class="room-name">{{ room.name }}</h3>

                <div class="room-meta">
                  <div class="meta-item">
                    <span class="meta-icon">👤</span>
                    <span>Host: {{ room.hostName }}</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-icon">⏱️</span>
                    <span>{{ room.drawTimeSeconds }}s / round</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-icon">🎯</span>
                    <span>{{ room.difficulty }}</span>
                  </div>
                  <div class="meta-item">
                    <span class="meta-icon">🏷️</span>
                    <span>{{ room.category }}</span>
                  </div>
                </div>

                <div class="room-bottom">
                  <div class="player-count">
                    <span>👥 {{ room.currentPlayers }}/{{ room.maxPlayers }} Players</span>
                  </div>
                  <button class="btn-coral btn-sm">
                    Join Match →
                  </button>
                </div>
              </div>
            } @empty {
              <div class="empty-state glass-card">
                <span class="empty-emoji">🎨</span>
                <h3>No active rooms matching filters</h3>
                <p>Be the first artist to create one right now!</p>
                <a routerLink="/home" class="btn-coral btn-sm" (click)="sound.playPop()">
                  🚀 Create Room
                </a>
              </div>
            }
          </div>
        }
      </div>
    </div>
  `,
  styles: [`
    .discover-page {
      position: relative;
      min-height: 100vh;
      padding: 100px 16px 100px;
      z-index: 1;
    }
    .discover-container {
      max-width: 1000px;
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

    .filter-bar {
      padding: 16px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .search-box {
      display: flex;
      align-items: center;
      gap: 10px;
      flex: 1;
      min-width: 240px;
      background: #FFFFFF;
      border: 1.5px solid rgba(40, 30, 20, 0.08);
      border-radius: var(--radius-full);
      padding: 8px 16px;
    }
    .search-input {
      border: none;
      width: 100%;
      font-size: 14px;
    }
    .filter-chips {
      display: flex;
      gap: 8px;
    }
    .filter-chip {
      padding: 6px 14px;
      border-radius: var(--radius-full);
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
      background: #FFFFFF;
      border: 1px solid rgba(40, 30, 20, 0.08);
      cursor: pointer;
      transition: all 0.15s;
    }
    .filter-chip.active {
      background: var(--primary-coral);
      color: #FFFFFF;
      border-color: var(--primary-coral);
    }

    .rooms-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(290px, 1fr));
      gap: 18px;
    }
    .room-card {
      padding: 20px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 14px;
    }
    .room-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .room-badge {
      font-size: 11px;
      font-weight: 700;
      color: #007A6E;
      background: rgba(46, 196, 182, 0.15);
      padding: 3px 8px;
      border-radius: var(--radius-full);
    }
    .room-badge.in-progress {
      color: #996B00;
      background: rgba(255, 209, 102, 0.25);
    }
    .pin-chip {
      font-family: monospace;
      font-size: 12px;
      font-weight: 700;
      background: rgba(40, 30, 20, 0.05);
      padding: 2px 6px;
      border-radius: 6px;
    }
    .room-name {
      font-size: 18px;
      font-weight: 800;
      line-height: 1.3;
    }
    .room-meta {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 6px;
      font-size: 12px;
      color: var(--text-secondary);
    }
    .meta-item {
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .room-bottom {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 10px;
      border-top: 1px solid rgba(40, 30, 20, 0.06);
    }
    .player-count {
      font-size: 13px;
      font-weight: 700;
    }

    .loading-state, .empty-state {
      text-align: center;
      padding: 48px 24px;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 12px;
    }
    .empty-emoji {
      font-size: 48px;
    }
    .spinner {
      width: 36px;
      height: 36px;
      border: 3px solid rgba(255, 87, 51, 0.2);
      border-top-color: var(--primary-coral);
      border-radius: 50%;
      animation: spin 0.8s linear infinite;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
  `]
})
export class DiscoverComponent implements OnInit {
  private readonly roomService = inject(RoomService);
  readonly sound = inject(SoundService);
  private readonly router = inject(Router);

  rooms = signal<Room[]>([]);
  isLoading = signal<boolean>(true);
  searchQuery = '';
  selectedDifficulty = 'ALL';

  ngOnInit(): void {
    this.loadRooms();
  }

  loadRooms(): void {
    this.isLoading.set(true);
    this.roomService.getPublicRooms().subscribe({
      next: (list) => {
        this.rooms.set(list);
        this.isLoading.set(false);
      },
      error: () => this.isLoading.set(false)
    });
  }

  setDifficulty(diff: string): void {
    this.sound.playPop();
    this.selectedDifficulty = diff;
  }

  filteredRooms(): Room[] {
    return this.rooms().filter(r => {
      const matchSearch = !this.searchQuery ||
        r.name.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
        r.roomCode.toLowerCase().includes(this.searchQuery.toLowerCase());
      const matchDiff = this.selectedDifficulty === 'ALL' || r.difficulty === this.selectedDifficulty;
      return matchSearch && matchDiff;
    });
  }

  joinRoom(room: Room): void {
    this.sound.playChime();
    this.router.navigate(['/lobby', room.id]);
  }
}
