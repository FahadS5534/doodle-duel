import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { SoundService } from '../../../core/services/sound.service';
import { AmbientDoodleComponent } from '../../../shared/components/ambient-doodle/ambient-doodle.component';

@Component({
  selector: 'app-register',
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
          <div class="brand-badge">🎨</div>
          <h2>Join the Arena!</h2>
          <p>Create an account to save your career stats and custom avatars.</p>
        </div>

        @if (auth.errorMessage()) {
          <div class="error-banner">
            ⚠️ {{ auth.errorMessage() }}
          </div>
        }

        <form (ngSubmit)="onSubmit()" class="form-container">
          <div class="field">
            <label>Display Name</label>
            <input
              type="text"
              class="input-glass"
              placeholder="e.g. Master Doodler"
              [(ngModel)]="displayName"
              name="displayName"
              required
            />
          </div>

          <div class="field">
            <label>Username</label>
            <input
              type="text"
              class="input-glass"
              placeholder="e.g. master_doodler"
              [(ngModel)]="username"
              name="username"
              required
            />
          </div>

          <div class="field">
            <label>Email Address</label>
            <input
              type="email"
              class="input-glass"
              placeholder="e.g. player@example.com"
              [(ngModel)]="email"
              name="email"
              required
            />
          </div>

          <div class="field">
            <label>Password (min 6 chars)</label>
            <input
              type="password"
              class="input-glass"
              placeholder="••••••••"
              [(ngModel)]="password"
              name="password"
              minlength="6"
              required
            />
          </div>

          <button
            type="submit"
            class="btn-coral btn-block"
            [disabled]="auth.isLoading() || !displayName || !username || !email || password.length < 6"
          >
            @if (auth.isLoading()) {
              <span>Creating Account...</span>
            } @else {
              <span>Create Account 🚀</span>
            }
          </button>
        </form>

        <p class="footer-link">
          Already have an account?
          <a routerLink="/login" (click)="sound.playPop()">Sign In</a>
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
      box-shadow: 0 8px 20px rgba(46, 196, 182, 0.25);
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
      gap: 14px;
    }
    .field {
      display: flex;
      flex-direction: column;
      gap: 5px;
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
      margin-top: 6px;
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
export class RegisterComponent {
  readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  private readonly router = inject(Router);

  displayName = '';
  username = '';
  email = '';
  password = '';

  onSubmit(): void {
    if (!this.displayName || !this.username || !this.email || this.password.length < 6) return;
    this.sound.playPop();
    this.auth.register(this.username, this.email, this.password, this.displayName).subscribe(success => {
      if (success) {
        this.sound.playChime();
        this.router.navigate(['/home']);
      }
    });
  }
}
