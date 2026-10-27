import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-avatar-widget',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="avatar-wrapper" [style.width.px]="size" [style.height.px]="size">
      <div class="avatar-circle" [style.border-color]="borderColor">
        @if (avatarUrl) {
          <img [src]="avatarUrl" [alt]="name" class="avatar-img" (error)="onImgError($event)" />
        } @else {
          <div class="avatar-fallback" [style.font-size.px]="size * 0.42">
            {{ getInitials(name) }}
          </div>
        }
      </div>

      @if (showLevel && level !== undefined) {
        <div class="level-badge" [style.font-size.px]="Math.max(9, size * 0.2)">
          Lvl {{ level }}
        </div>
      }

      @if (isHost) {
        <div class="host-crown" title="Room Host">👑</div>
      }

      @if (isReady !== undefined) {
        <div class="ready-dot" [class.ready]="isReady" [title]="isReady ? 'Ready' : 'Not Ready'">
          {{ isReady ? '✓' : '•' }}
        </div>
      }
    </div>
  `,
  styles: [`
    .avatar-wrapper {
      position: relative;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      user-select: none;
    }
    .avatar-circle {
      width: 100%;
      height: 100%;
      border-radius: 50%;
      border: 2px solid rgba(255, 255, 255, 0.85);
      background: #FFFFFF;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(40, 30, 20, 0.08);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .avatar-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    .avatar-fallback {
      font-family: var(--font-heading);
      font-weight: 800;
      color: var(--primary-coral);
    }
    .level-badge {
      position: absolute;
      bottom: -4px;
      padding: 2px 6px;
      background: var(--coral-gradient);
      color: #FFFFFF;
      font-family: var(--font-heading);
      font-weight: 800;
      border-radius: var(--radius-full);
      box-shadow: 0 2px 6px rgba(255, 87, 51, 0.3);
      white-space: nowrap;
    }
    .host-crown {
      position: absolute;
      top: -10px;
      right: -4px;
      font-size: 16px;
      filter: drop-shadow(0 2px 4px rgba(0,0,0,0.15));
    }
    .ready-dot {
      position: absolute;
      bottom: -2px;
      right: -2px;
      width: 18px;
      height: 18px;
      border-radius: 50%;
      background: #D1D5DB;
      color: #FFFFFF;
      font-size: 11px;
      font-weight: 800;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 2px solid #FFFFFF;
    }
    .ready-dot.ready {
      background: var(--accent-mint);
    }
  `]
})
export class AvatarWidgetComponent {
  @Input() avatarUrl?: string;
  @Input() name = 'Artist';
  @Input() size = 48;
  @Input() level?: number;
  @Input() showLevel = false;
  @Input() isHost = false;
  @Input() isReady?: boolean;
  @Input() borderColor = 'rgba(255, 255, 255, 0.85)';

  readonly Math = Math;

  getInitials(name: string): string {
    if (!name) return 'A';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  onImgError(event: Event): void {
    const target = event.target as HTMLElement;
    target.style.display = 'none';
  }
}
