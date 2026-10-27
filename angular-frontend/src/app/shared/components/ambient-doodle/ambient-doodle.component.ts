import { Component } from '@angular/core';

@Component({
  selector: 'app-ambient-doodle',
  standalone: true,
  template: `
    <div class="ambient-container" aria-hidden="true">
      <div class="doodle doodle-pencil">✏️</div>
      <div class="doodle doodle-star-1">✨</div>
      <div class="doodle doodle-palette">🎨</div>
      <div class="doodle doodle-star-2">⭐</div>
      <div class="doodle doodle-swirl">🌀</div>
      <div class="doodle doodle-brush">🖌️</div>
      <div class="doodle doodle-light">💡</div>
      <div class="blur-blob blob-coral"></div>
      <div class="blur-blob blob-mint"></div>
      <div class="blur-blob blob-yellow"></div>
    </div>
  `,
  styles: [`
    :host {
      position: fixed;
      inset: 0;
      pointer-events: none;
      z-index: 0;
      overflow: hidden;
    }
    .ambient-container {
      position: relative;
      width: 100%;
      height: 100%;
    }
    .doodle {
      position: absolute;
      opacity: 0.18;
      user-select: none;
      animation: floatDoodle 8s ease-in-out infinite;
      filter: drop-shadow(0 2px 4px rgba(0,0,0,0.04));
    }
    .doodle-pencil { top: 8%; left: 6%; font-size: 32px; animation-duration: 9s; }
    .doodle-star-1 { top: 22%; right: 8%; font-size: 26px; animation-duration: 7s; animation-delay: 1s; }
    .doodle-palette { bottom: 18%; left: 8%; font-size: 36px; animation-duration: 10s; animation-delay: 2s; }
    .doodle-star-2 { bottom: 25%; right: 12%; font-size: 28px; animation-duration: 8.5s; animation-delay: 1.5s; }
    .doodle-swirl { top: 45%; left: 4%; font-size: 24px; animation-duration: 11s; }
    .doodle-brush { top: 60%; right: 6%; font-size: 30px; animation-duration: 9.5s; animation-delay: 3s; }
    .doodle-light { bottom: 8%; right: 40%; font-size: 26px; animation-duration: 8s; }

    .blur-blob {
      position: absolute;
      border-radius: 50%;
      filter: blur(80px);
      opacity: 0.35;
      pointer-events: none;
    }
    .blob-coral {
      width: 320px;
      height: 320px;
      background: radial-gradient(circle, #FFA07A 0%, rgba(255, 87, 51, 0) 70%);
      top: -60px;
      right: -60px;
    }
    .blob-mint {
      width: 340px;
      height: 340px;
      background: radial-gradient(circle, #70F8E8 0%, rgba(46, 196, 182, 0) 70%);
      bottom: -60px;
      left: -60px;
    }
    .blob-yellow {
      width: 260px;
      height: 260px;
      background: radial-gradient(circle, #FFE29A 0%, rgba(255, 209, 102, 0) 70%);
      top: 40%;
      left: 50%;
      transform: translate(-50%, -50%);
    }
  `]
})
export class AmbientDoodleComponent {}
