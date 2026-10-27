import {
  Component,
  ElementRef,
  HostListener,
  OnInit,
  ViewChild,
  inject,
  signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { SoundService } from '../../core/services/sound.service';
import { NavbarComponent } from '../../shared/components/navbar/navbar.component';
import { AmbientDoodleComponent } from '../../shared/components/ambient-doodle/ambient-doodle.component';

interface SketchpadPrompt {
  word: string;
  category: string;
  difficulty: 'EASY' | 'MEDIUM' | 'HARD';
  hint: string;
}

@Component({
  selector: 'app-sketchpad',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, NavbarComponent, AmbientDoodleComponent],
  template: `
    <app-ambient-doodle></app-ambient-doodle>
    <app-navbar></app-navbar>

    <div class="sketchpad-page">
      <div class="sketchpad-container">
        <!-- Top Prompt Card -->
        <header class="prompt-header glass-card">
          <div class="prompt-left">
            <span class="badge-pill badge-mint">🎨 Warm-up Practice</span>
            <div class="word-banner">
              <span class="target-label">PROMPT IDEA:</span>
              <h2 class="target-word">{{ currentPrompt().word }}</h2>
              <span class="target-hint">💡 {{ currentPrompt().hint }}</span>
            </div>
          </div>

          <div class="prompt-actions">
            <button class="btn-coral btn-sm" (click)="generateNewPrompt()">
              🎲 New Prompt
            </button>
            <button class="btn-outline btn-sm" (click)="downloadCanvas()">
              💾 Save Artwork
            </button>
          </div>
        </header>

        <!-- Canvas Frame -->
        <main class="canvas-wrapper glass-card" #container>
          <canvas
            #sketchCanvas
            (pointerdown)="onPointerDown($event)"
            (pointermove)="onPointerMove($event)"
            (pointerup)="onPointerUp($event)"
            (pointercancel)="onPointerUp($event)"
          ></canvas>
        </main>

        <!-- Bottom Drawing Toolbar -->
        <footer class="toolbar-card glass-card">
          <div class="color-palette">
            @for (c of paletteColors; track c) {
              <button
                class="color-dot"
                [style.background]="c"
                [class.selected]="selectedColor === c && currentTool !== 'ERASER'"
                (click)="selectColor(c)"
              ></button>
            }
          </div>

          <div class="divider"></div>

          <div class="tool-buttons">
            <button
              class="tool-btn"
              [class.active]="currentTool === 'PEN'"
              (click)="selectTool('PEN', 4)"
              title="Fine Pen"
            >
              ✏️
            </button>
            <button
              class="tool-btn"
              [class.active]="currentTool === 'BRUSH'"
              (click)="selectTool('BRUSH', 12)"
              title="Thick Marker"
            >
              🖌️
            </button>
            <button
              class="tool-btn"
              [class.active]="currentTool === 'ERASER'"
              (click)="selectTool('ERASER', 24)"
              title="Eraser"
            >
              🧹
            </button>
            <button class="tool-btn" (click)="undo()" title="Undo">
              ↩️
            </button>
            <button class="tool-btn danger" (click)="clear()" title="Clear Canvas">
              🗑️
            </button>
          </div>

          <div class="divider"></div>

          <div class="brush-slider-box">
            <span class="brush-preview" [style.width.px]="brushSize" [style.height.px]="brushSize" [style.background]="selectedColor"></span>
            <input
              type="range"
              min="2"
              max="36"
              [(ngModel)]="brushSize"
              class="brush-slider"
            />
          </div>
        </footer>
      </div>
    </div>
  `,
  styles: [`
    .sketchpad-page {
      position: relative;
      min-height: 100vh;
      padding: 94px 16px 90px;
      z-index: 1;
    }
    .sketchpad-container {
      max-width: 1000px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      gap: 14px;
      height: calc(100vh - 184px);
      min-height: 520px;
    }

    .prompt-header {
      padding: 14px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      flex-wrap: wrap;
    }
    .prompt-left {
      display: flex;
      align-items: center;
      gap: 16px;
      flex-wrap: wrap;
    }
    .word-banner {
      display: flex;
      align-items: baseline;
      gap: 10px;
    }
    .target-label {
      font-size: 11px;
      font-weight: 800;
      color: var(--text-muted);
      letter-spacing: 0.5px;
    }
    .target-word {
      font-size: 24px;
      font-weight: 800;
      color: var(--primary-coral);
      letter-spacing: 1px;
      text-transform: uppercase;
    }
    .target-hint {
      font-size: 13px;
      color: var(--text-secondary);
      font-style: italic;
    }
    .prompt-actions {
      display: flex;
      gap: 10px;
    }

    /* Canvas */
    .canvas-wrapper {
      flex: 1;
      position: relative;
      background: #FFFFFF;
      overflow: hidden;
      touch-action: none;
    }
    canvas {
      width: 100%;
      height: 100%;
      display: block;
      cursor: crosshair;
    }

    /* Toolbar */
    .toolbar-card {
      padding: 10px 18px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      flex-wrap: wrap;
    }
    .color-palette {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .color-dot {
      width: 26px;
      height: 26px;
      border-radius: 50%;
      border: 2px solid #FFFFFF;
      box-shadow: 0 2px 5px rgba(0,0,0,0.15);
      cursor: pointer;
      transition: transform 0.15s;
    }
    .color-dot:hover, .color-dot.selected {
      transform: scale(1.25);
      border-color: #22252A;
    }
    .divider {
      width: 1px;
      height: 24px;
      background: rgba(40, 30, 20, 0.1);
    }
    .tool-buttons {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .tool-btn {
      width: 36px;
      height: 36px;
      border-radius: var(--radius-sm);
      background: #FFFFFF;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      box-shadow: 0 2px 6px rgba(0,0,0,0.06);
      transition: all 0.15s;
    }
    .tool-btn.active {
      background: var(--primary-coral);
      color: #FFFFFF;
    }
    .tool-btn.danger:hover {
      background: var(--error-container);
    }
    .brush-slider-box {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .brush-preview {
      border-radius: 50%;
    }
    .brush-slider {
      width: 90px;
      accent-color: var(--primary-coral);
    }
  `]
})
export class SketchpadComponent implements OnInit {
  @ViewChild('sketchCanvas', { static: true }) canvasRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('container', { static: true }) containerRef!: ElementRef<HTMLDivElement>;

  readonly sound = inject(SoundService);

  private readonly promptBank: SketchpadPrompt[] = [
    { word: 'Flying Pizza', category: 'FOOD', difficulty: 'EASY', hint: 'Delicious slice with wings' },
    { word: 'Cosmic Dragon', category: 'ANIMALS', difficulty: 'HARD', hint: 'Breathes nebula fire in space' },
    { word: 'Steampunk Robot', category: 'OBJECTS', difficulty: 'HARD', hint: 'Gears and brass whistle' },
    { word: 'Surfing Cat', category: 'ANIMALS', difficulty: 'MEDIUM', hint: 'Riding a giant pipeline wave' },
    { word: 'Electric Guitar', category: 'OBJECTS', difficulty: 'MEDIUM', hint: 'Rocking with lightning bolts' },
    { word: 'Floating Castle', category: 'PLACES', difficulty: 'HARD', hint: 'Held up by fluffy clouds' },
    { word: 'Happy Avocado', category: 'FOOD', difficulty: 'EASY', hint: 'Big smiling seed in center' },
    { word: 'Pocket Rocket', category: 'VEHICLES', difficulty: 'EASY', hint: 'Blasting to the stars' },
    { word: 'Wizard Hat', category: 'OBJECTS', difficulty: 'EASY', hint: 'Pointy with magic stars' },
    { word: 'Underwater Submarine', category: 'VEHICLES', difficulty: 'MEDIUM', hint: 'Yellow vessel with periscope' },
    { word: 'Dancing Penguin', category: 'ANIMALS', difficulty: 'EASY', hint: 'Wearing bow tie on ice' },
    { word: 'Cyberpunk City', category: 'PLACES', difficulty: 'HARD', hint: 'Neon towers and flying cars' }
  ];

  currentPrompt = signal<SketchpadPrompt>(this.promptBank[0]);

  paletteColors = [
    '#22252A', '#FF5733', '#2EC4B6', '#FFD166', '#B8A9C9',
    '#E63946', '#3A86FF', '#2A9D8F', '#F77F00', '#FFFFFF'
  ];
  selectedColor = '#FF5733';
  brushSize = 6;
  currentTool: 'PEN' | 'BRUSH' | 'ERASER' = 'PEN';

  private ctx!: CanvasRenderingContext2D;
  private isDrawing = false;
  private lastPt = { x: 0, y: 0 };
  private history: ImageData[] = [];

  ngOnInit(): void {
    this.initCanvas();
    this.generateNewPrompt();
  }

  @HostListener('window:resize')
  onResize(): void {
    const backup = this.ctx.getImageData(0, 0, this.canvasRef.nativeElement.width, this.canvasRef.nativeElement.height);
    this.initCanvas();
    this.ctx.putImageData(backup, 0, 0);
  }

  private initCanvas(): void {
    const canvas = this.canvasRef.nativeElement;
    const container = this.containerRef.nativeElement;
    const dpr = window.devicePixelRatio || 1;

    canvas.width = container.clientWidth * dpr;
    canvas.height = container.clientHeight * dpr;

    this.ctx = canvas.getContext('2d')!;
    this.ctx.scale(dpr, dpr);
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';

    // White background
    this.ctx.fillStyle = '#FFFFFF';
    this.ctx.fillRect(0, 0, container.clientWidth, container.clientHeight);
  }

  generateNewPrompt(): void {
    this.sound.playPop();
    const available = this.promptBank.filter(p => p.word !== this.currentPrompt().word);
    const random = available[Math.floor(Math.random() * available.length)];
    this.currentPrompt.set(random);
  }

  onPointerDown(e: PointerEvent): void {
    this.isDrawing = true;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.lastPt = { x: e.clientX - rect.left, y: e.clientY - rect.top };
    this.saveSnapshot();
  }

  onPointerMove(e: PointerEvent): void {
    if (!this.isDrawing) return;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const currentPt = { x: e.clientX - rect.left, y: e.clientY - rect.top };

    this.ctx.strokeStyle = this.currentTool === 'ERASER' ? '#FFFFFF' : this.selectedColor;
    this.ctx.lineWidth = this.brushSize;
    this.ctx.beginPath();
    this.ctx.moveTo(this.lastPt.x, this.lastPt.y);
    this.ctx.lineTo(currentPt.x, currentPt.y);
    this.ctx.stroke();

    this.lastPt = currentPt;
  }

  onPointerUp(e: PointerEvent): void {
    this.isDrawing = false;
  }

  private saveSnapshot(): void {
    const canvas = this.canvasRef.nativeElement;
    if (this.history.length > 20) this.history.shift();
    this.history.push(this.ctx.getImageData(0, 0, canvas.width, canvas.height));
  }

  undo(): void {
    if (this.history.length === 0) return;
    this.sound.playPop();
    const snapshot = this.history.pop()!;
    this.ctx.putImageData(snapshot, 0, 0);
  }

  clear(): void {
    this.sound.playPop();
    const container = this.containerRef.nativeElement;
    this.ctx.fillStyle = '#FFFFFF';
    this.ctx.fillRect(0, 0, container.clientWidth, container.clientHeight);
    this.history = [];
  }

  selectColor(c: string): void {
    this.sound.playPop();
    this.selectedColor = c;
    if (this.currentTool === 'ERASER') this.currentTool = 'PEN';
  }

  selectTool(t: 'PEN' | 'BRUSH' | 'ERASER', s: number): void {
    this.sound.playPop();
    this.currentTool = t;
    this.brushSize = s;
  }

  downloadCanvas(): void {
    this.sound.playChime();
    const link = document.createElement('a');
    link.download = `doodle-duel-${this.currentPrompt().word.toLowerCase().replace(/\s+/g, '-')}.png`;
    link.href = this.canvasRef.nativeElement.toDataURL('image/png');
    link.click();
  }
}
