import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { SoundService } from '../../../core/services/sound.service';
import { AmbientDoodleComponent } from '../../../shared/components/ambient-doodle/ambient-doodle.component';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, AmbientDoodleComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>

    <div class="auth-page">
      <div class="auth-card glass-card">
        <a routerLink="/welcome" class="back-link" (click)="sound.playPop()">
          ← Back to Welcome
        </a>

        <div class="header-box">
          <div class="brand-badge">✏️</div>
          <h2>Welcome Back!</h2>
          <p>Sign in to your Doodle Duel account and track your rank.</p>
        </div>

        @if (auth.errorMessage()) {
          <div class="error-banner">
            ⚠️ {{ auth.errorMessage() }}
          </div>
        }

        <form (ngSubmit)="onSubmit()" class="form-container">
          <div class="field">
            <label>Username or Email</label>
            <input
              type="text"
              class="input-glass"
              placeholder="e.g. doodler or doodler@example.com"
              [(ngModel)]="usernameOrEmail"
              name="usernameOrEmail"
              required
            />
          </div>

          <div class="field">
            <label>Password</label>
            <input
              type="password"
              class="input-glass"
              placeholder="••••••••"
              [(ngModel)]="password"
              name="password"
              required
            />
          </div>

          <button
            type="submit"
            class="btn-coral btn-block"
            [disabled]="auth.isLoading() || !usernameOrEmail || !password"
          >
            @if (auth.isLoading()) {
              <span>Signing In...</span>
            } @else {
              <span>Sign In 🚀</span>
            }
          </button>
        </form>

        <div class="divider">
          <span>OR</span>
        </div>

        <button class="btn-outline btn-block" (click)="playAsGuest()">
          ⚡ Continue as Guest Instead
        </button>

        <p class="footer-link">
          Don't have an account?
          <a routerLink="/register" (click)="sound.playPop()">Create one</a>
        </p>
      </div>
    </div>
  `,
  styles: [`
    .auth-page {
      position: relative;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px 16px;
      z-index: 1;
    }
    .auth-card {
      width: 100%;
      max-width: 440px;
      padding: 32px 28px;
    }
    .back-link {
      display: inline-block;
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
      margin-bottom: 20px;
      transition: color 0.2s;
    }
    .back-link:hover {
      color: var(--primary-coral);
    }
    .header-box {
      text-align: center;
      margin-bottom: 24px;
    }
    .brand-badge {
      width: 56px;
      height: 56px;
      background: #FFFFFF;
      border-radius: var(--radius-md);
      box-shadow: 0 8px 20px rgba(255, 87, 51, 0.2);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 28px;
      margin: 0 auto 16px;
    }
    .header-box h2 {
      font-size: 26px;
      font-weight: 800;
      margin-bottom: 6px;
    }
    .header-box p {
      font-size: 14px;
      color: var(--text-secondary);
    }

    .error-banner {
      background: var(--error-container);
      color: var(--error);
      padding: 10px 14px;
      border-radius: var(--radius-md);
      font-size: 13px;
      font-weight: 600;
      margin-bottom: 18px;
    }

    .form-container {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }
    .field {
      display: flex;
      flex-direction: column;
      gap: 6px;
      text-align: left;
    }
    .field label {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-secondary);
    }
    .btn-block {
      width: 100%;
      padding: 14px 20px;
    }

    .divider {
      position: relative;
      text-align: center;
      margin: 20px 0;
    }
    .divider::before {
      content: '';
      position: absolute;
      top: 50%;
      left: 0;
      right: 0;
      height: 1px;
      background: rgba(40, 30, 20, 0.08);
    }
    .divider span {
      position: relative;
      background: #FFFFFF;
      padding: 0 12px;
      font-size: 12px;
      font-weight: 600;
      color: var(--text-muted);
    }

    .footer-link {
      text-align: center;
      margin-top: 20px;
      font-size: 13px;
      color: var(--text-secondary);
    }
    .footer-link a {
      color: var(--primary-coral);
      font-weight: 700;
      margin-left: 4px;
    }
  `]
})
export class LoginComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  private readonly router = inject(Router);

  usernameOrEmail = '';
  password = '';

  onSubmit(): void {
    if (!this.usernameOrEmail || !this.password) return;
    this.sound.playPop();
    this.auth.login(this.usernameOrEmail, this.password).subscribe(success => {
      if (success) {
        this.sound.playChime();
        this.router.navigate(['/home']);
      }
    });
  }

  playAsGuest(): void {
    this.sound.playPop();
    this.auth.guestLogin().subscribe(success => {
      if (success) {
        this.sound.playChime();
        this.router.navigate(['/home']);
      }
    });
  }
}
