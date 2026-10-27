import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../core/services/auth.service';
import { SoundService } from '../../core/services/sound.service';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';

@Component({
  selector: 'app-welcome',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, AmbientDoodleComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>

    <div class="welcome-page">
      <div class="welcome-container">
        <!-- Top App Header Badge -->
        <div class="header-pill">
          <span class="icon">🎨</span>
          <span class="text">Multiplayer Drawing Duel</span>
        </div>

        <!-- Central Hero Section -->
        <div class="hero-section">
          <div class="logo-box">
            <span class="pencil-emoji">✏️</span>
          </div>

          <h1 class="hero-title">Doodle Duel</h1>
          <p class="hero-subtitle">"Draw it. Guess it. Own it."</p>

          <!-- Feature Pills -->
          <div class="feature-pills">
            <div class="pill pill-mint">⚡ Real-time Strokes</div>
            <div class="pill pill-yellow">👥 Squad Lobbies</div>
            <div class="pill pill-lavender">🏆 Global Ranks</div>
          </div>
        </div>

        <!-- Action CTAs -->
        <div class="actions-section">
          <button class="btn-coral btn-block" (click)="openGuestModal()">
            <span>⚡</span>
            <span>Let's Play (Instant Guest)</span>
          </button>

          <div class="auth-buttons">
            <a routerLink="/login" class="btn-outline" (click)="sound.playPop()">
              Sign In
            </a>
            <a routerLink="/register" class="btn-outline" (click)="sound.playPop()">
              Create Account
            </a>
          </div>

          <a routerLink="/sketchpad" class="sketchpad-link" (click)="sound.playPop()">
            🎨 Or practice solo in Warm-up Sketchpad
          </a>
        </div>
      </div>
    </div>

    <!-- Guest Display Name Modal -->
    @if (showGuestModal()) {
      <div class="modal-overlay" (click)="closeGuestModal()">
        <div class="modal-content" (click)="$event.stopPropagation()">
          <div class="modal-header">
            <h3>Choose Artist Name</h3>
            <button class="close-btn" (click)="closeGuestModal()">✕</button>
          </div>

          <p class="modal-desc">
            Pick a nickname or jump right in with a randomly generated artist handle.
          </p>

          <div class="input-group">
            <input
              type="text"
              class="input-glass"
              placeholder="e.g. Maya Artist, Doodler 42"
              [(ngModel)]="guestName"
              (keyup.enter)="startGuestSession()"
              maxlength="20"
              autofocus
            />
          </div>

          <button
            class="btn-coral btn-block"
            [disabled]="auth.isLoading()"
            (click)="startGuestSession()"
          >
            @if (auth.isLoading()) {
              <span>Connecting...</span>
            } @else {
              <span>Jump In as Guest 🚀</span>
            }
          </button>
        </div>
      </div>
    }
  `,
  styles: [`
    .welcome-page {
      position: relative;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 32px 20px;
      z-index: 1;
    }
    .welcome-container {
      width: 100%;
      max-width: 440px;
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
      gap: 36px;
    }

    .header-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--glass-white);
      border: 1px solid var(--border-glass);
      box-shadow: 0 4px 12px rgba(40, 30, 20, 0.06);
      padding: 6px 16px;
      border-radius: var(--radius-full);
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
    }

    .hero-section {
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .logo-box {
      width: 104px;
      height: 104px;
      background: #FFFFFF;
      border-radius: var(--radius-xl);
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 16px 36px rgba(255, 87, 51, 0.22);
      margin-bottom: 24px;
      animation: bounceSlow 3s ease-in-out infinite;
    }
    .pencil-emoji {
      font-size: 52px;
    }

    .hero-title {
      font-size: 38px;
      font-weight: 800;
      letter-spacing: -0.5px;
      margin-bottom: 8px;
      background: linear-gradient(135deg, #22252A 0%, #434850 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    .hero-subtitle {
      font-size: 16px;
      font-style: italic;
      color: var(--text-secondary);
      margin-bottom: 24px;
    }

    .feature-pills {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 8px;
    }
    .pill {
      padding: 6px 12px;
      border-radius: var(--radius-full);
      font-size: 12px;
      font-weight: 600;
    }
    .pill-mint {
      background: rgba(46, 196, 182, 0.15);
      color: #007A6E;
    }
    .pill-yellow {
      background: rgba(255, 209, 102, 0.28);
      color: #996B00;
    }
    .pill-lavender {
      background: rgba(184, 169, 201, 0.28);
      color: #634C7D;
    }

    .actions-section {
      width: 100%;
      display: flex;
      flex-direction: column;
      gap: 14px;
    }
    .btn-block {
      width: 100%;
      padding: 16px 24px;
      font-size: 16px;
    }

    .auth-buttons {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }

    .sketchpad-link {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
      margin-top: 6px;
      transition: color 0.2s;
    }
    .sketchpad-link:hover {
      color: var(--primary-coral);
    }

    /* Modal */
    .modal-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 8px;
    }
    .modal-header h3 {
      font-size: 22px;
      font-weight: 700;
    }
    .close-btn {
      font-size: 18px;
      color: var(--text-secondary);
      padding: 4px;
    }
    .modal-desc {
      font-size: 14px;
      color: var(--text-secondary);
      margin-bottom: 20px;
    }
    .input-group {
      margin-bottom: 20px;
    }
  `]
})
export class WelcomeComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  private readonly router = inject(Router);

  showGuestModal = signal<boolean>(false);
  guestName = '';

  openGuestModal(): void {
    this.sound.playPop();
    this.showGuestModal.set(true);
  }

  closeGuestModal(): void {
    this.showGuestModal.set(false);
  }

  startGuestSession(): void {
    this.sound.playChime();
    this.auth.guestLogin(this.guestName.trim() || undefined).subscribe(success => {
      if (success) {
        this.closeGuestModal();
        this.router.navigate(['/home']);
      }
    });
  }
}
