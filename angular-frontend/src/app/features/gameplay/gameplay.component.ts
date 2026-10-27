import {
  Component,
  ElementRef,
  HostListener,
  OnDestroy,
  OnInit,
  ViewChild,
  inject,
  signal
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { Subscription, interval } from 'rxjs';
import confetti from 'canvas-confetti';
import { StompService } from '../../core/services/stomp.service';
import { AuthService } from '../../core/services/auth.service';
import { SoundService } from '../../core/services/sound.service';
import { RoomService } from '../../core/services/room.service';
import { DrawingPoint, DrawingStroke, GameEvent, GuessMessage, PlayerScoreSummary } from '../../core/models/game.model';
import { Room } from '../../core/models/room.model';
import { AvatarWidgetComponent } from '../../shared/components/avatar-widget/avatar-widget.component';

@Component({
  selector: 'app-gameplay',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, AvatarWidgetComponent],
  template: `
    <div class="game-container">
      <!-- Top Gameplay Bar -->
      <header class="game-top-bar glass-card">
        <div class="top-left">
          <button class="btn-exit" (click)="exitGame()" title="Leave Game">✕</button>
          <div class="round-indicator">
            <span class="round-num">Round {{ currentRound() }}/{{ totalRounds() }}</span>
            <span class="category-pill">{{ category() }}</span>
          </div>
        </div>

        <!-- Center: Secret Word or Blank Mask -->
        <div class="word-display-box">
          @if (isCurrentDrawer()) {
            <div class="drawer-prompt">
              <span class="prompt-label">YOUR WORD TO DRAW:</span>
              <span class="prompt-word">{{ secretWord() || 'DRAW SOMETHING!' }}</span>
              <span class="prompt-hint">{{ hint() ? '(' + hint() + ')' : '' }}</span>
            </div>
          } @else {
            <div class="guesser-prompt">
              <span class="prompt-label">GUESS THE WORD:</span>
              <span class="mask-blanks">{{ letterBlanks() }}</span>
              <span class="drawer-info">✏️ Artist: {{ drawerName() }}</span>
            </div>
          }
        </div>

        <!-- Right: Animated Turn Timer -->
        <div class="timer-box" [class.urgent]="remainingSeconds() <= 10">
          <div class="timer-circle">
            <span class="timer-num">{{ remainingSeconds() }}</span>
          </div>
          <span class="timer-label">SECONDS</span>
        </div>
      </header>

      <!-- Main Layout: Scoreboard, Canvas, Guess Feed -->
      <div class="game-layout">
        <!-- 1. Left: Live Scoreboard -->
        <aside class="sidebar-scores glass-card">
          <h3 class="panel-title">Scoreboard</h3>
          <div class="scores-list">
            @for (player of players(); track player.userId; let idx = $index) {
              <div
                class="player-score-row"
                [class.is-drawer]="player.userId === currentDrawerId()"
                [class.has-guessed]="player.hasGuessed"
              >
                <div class="rank-badge">#{{ idx + 1 }}</div>
                <app-avatar-widget [avatarUrl]="player.avatarUrl" [name]="player.displayName" [size]="34"></app-avatar-widget>
                <div class="player-meta">
                  <span class="player-name">
                    {{ player.displayName }}
                    @if (player.userId === currentDrawerId()) {
                      <span class="drawer-pencil">✏️</span>
                    }
                  </span>
                  <span class="player-pts">{{ player.score }} Pts</span>
                </div>
                @if (player.hasGuessed) {
                  <span class="guessed-check" title="Guessed Correctly!">✓</span>
                }
              </div>
            }
          </div>

          <!-- Quick Reaction Buttons -->
          <div class="reaction-bar">
            @for (emoji of reactions; track emoji) {
              <button class="emoji-btn" (click)="sendReaction(emoji)">{{ emoji }}</button>
            }
          </div>
        </aside>

        <!-- 2. Center: Tactile Canvas Stage -->
        <main class="canvas-stage">
          <div class="canvas-frame glass-card" #canvasContainer>
            <canvas
              #canvas
              (pointerdown)="onPointerDown($event)"
              (pointermove)="onPointerMove($event)"
              (pointerup)="onPointerUp($event)"
              (pointercancel)="onPointerUp($event)"
            ></canvas>

            <!-- Floating Overlay Reactions -->
            @for (r of floatingReactions(); track r.id) {
              <div class="floating-emoji" [style.left.%]="r.x" [style.top.%]="r.y">
                {{ r.emoji }}
              </div>
            }

            <!-- Round Transition Banner Overlay -->
            @if (showRoundOverlay()) {
              <div class="round-overlay">
                <div class="overlay-modal glass-card">
                  <span class="overlay-icon">🎨</span>
                  <h2>{{ overlayTitle() }}</h2>
                  <p class="overlay-subtitle">{{ overlaySubtitle() }}</p>
                  @if (revealedWord()) {
                    <div class="revealed-box">
                      <span>The secret word was:</span>
                      <strong>{{ revealedWord() }}</strong>
                    </div>
                  }
                </div>
              </div>
            }

            <!-- Match Complete / Victory Podium Overlay -->
            @if (showMatchEndOverlay()) {
              <div class="round-overlay match-end">
                <div class="overlay-modal glass-card victory-modal">
                  <span class="trophy-icon">🏆</span>
                  <h2>Match Complete!</h2>
                  <p class="victory-subtitle">Congratulations to our top doodle masters!</p>

                  <div class="podium-display">
                    @for (winner of matchPodium(); track winner.userId; let i = $index) {
                      <div class="podium-rank rank-{{ i + 1 }}">
                        <span class="medal-icon">{{ i === 0 ? '🥇' : (i === 1 ? '🥈' : '🥉') }}</span>
                        <app-avatar-widget [avatarUrl]="winner.avatarUrl" [name]="winner.displayName" [size]="52"></app-avatar-widget>
                        <span class="winner-name">{{ winner.displayName }}</span>
                        <span class="winner-score">{{ winner.score }} Pts</span>
                      </div>
                    }
                  </div>

                  <div class="victory-actions">
                    <button class="btn-coral" (click)="exitGame()">Back to Home</button>
                  </div>
                </div>
              </div>
            }
          </div>

          <!-- Bottom: Drawer Controls Toolbar (Only active for current drawer) -->
          @if (isCurrentDrawer()) {
            <div class="drawer-toolbar glass-card">
              <!-- Color Palette -->
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

              <div class="tool-divider"></div>

              <!-- Tools: Pen, Thick Brush, Eraser -->
              <div class="tool-actions">
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
                  (click)="selectTool('ERASER', 20)"
                  title="Eraser"
                >
                  🧹
                </button>
                <button class="tool-btn" (click)="undoStroke()" title="Undo Last Stroke">
                  ↩️
                </button>
                <button class="tool-btn danger" (click)="clearCanvas()" title="Clear Canvas">
                  🗑️
                </button>
              </div>

              <!-- Brush Size Slider -->
              <div class="brush-slider-box">
                <span class="brush-preview" [style.width.px]="brushSize" [style.height.px]="brushSize" [style.background]="selectedColor"></span>
                <input
                  type="range"
                  min="2"
                  max="32"
                  [(ngModel)]="brushSize"
                  class="brush-slider"
                />
              </div>
            </div>
          }
        </main>

        <!-- 3. Right: Live Guess & Chat Feed -->
        <aside class="sidebar-guesses glass-card">
          <h3 class="panel-title">Guesses & Chat</h3>

          <div class="guesses-stream" #guessFeed>
            @for (msg of guessMessages(); track msg.id) {
              <div
                class="guess-bubble"
                [class.correct]="msg.isCorrect"
                [class.close]="msg.isClose"
              >
                <span class="guesser-author">{{ msg.username }}:</span>
                <span class="guesser-text">{{ msg.text }}</span>
                @if (msg.isCorrect) {
                  <span class="correct-badge">🎉 CORRECT (+{{ msg.pointsAwarded || 200 }})</span>
                }
                @if (msg.isClose) {
                  <span class="close-badge">🔥 So Close!</span>
                }
              </div>
            }
          </div>

          <!-- Guess Input Box -->
          <form (ngSubmit)="submitGuess()" class="guess-input-form">
            <input
              type="text"
              class="input-glass"
              [placeholder]="isCurrentDrawer() ? 'You are drawing this round...' : (hasGuessedCorrectly() ? 'You guessed it! Chat here...' : 'Type your guess here...')"
              [(ngModel)]="guessText"
              name="guess"
              [disabled]="isCurrentDrawer()"
              autocomplete="off"
            />
            <button
              type="submit"
              class="btn-coral btn-sm"
              [disabled]="isCurrentDrawer() || !guessText.trim()"
            >
              Send
            </button>
          </form>
        </aside>
      </div>
    </div>
  `,
  styles: [`
    .game-container {
      width: 100vw;
      height: 100vh;
      display: flex;
      flex-direction: column;
      padding: 12px;
      gap: 12px;
      background: var(--bg-root);
      overflow: hidden;
      user-select: none;
    }

    /* Top Bar */
    .game-top-bar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 10px 18px;
      border-radius: var(--radius-lg);
      flex-shrink: 0;
    }
    .top-left {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .btn-exit {
      width: 34px;
      height: 34px;
      border-radius: 50%;
      background: #FFFFFF;
      font-size: 14px;
      font-weight: 800;
      color: var(--text-secondary);
      box-shadow: 0 2px 6px rgba(0,0,0,0.06);
      transition: all 0.2s;
    }
    .btn-exit:hover {
      background: var(--error-container);
      color: var(--error);
    }
    .round-indicator {
      display: flex;
      flex-direction: column;
      gap: 2px;
    }
    .round-num {
      font-family: var(--font-heading);
      font-size: 14px;
      font-weight: 800;
    }
    .category-pill {
      font-size: 11px;
      font-weight: 600;
      color: var(--primary-coral);
    }

    /* Word Box */
    .word-display-box {
      text-align: center;
    }
    .drawer-prompt, .guesser-prompt {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 2px;
    }
    .prompt-label {
      font-size: 10px;
      font-weight: 800;
      letter-spacing: 1px;
      color: var(--text-muted);
    }
    .prompt-word {
      font-family: var(--font-heading);
      font-size: 22px;
      font-weight: 800;
      color: var(--primary-coral);
      letter-spacing: 2px;
      text-transform: uppercase;
    }
    .prompt-hint {
      font-size: 12px;
      color: var(--text-secondary);
      font-style: italic;
    }
    .mask-blanks {
      font-family: monospace;
      font-size: 24px;
      font-weight: 800;
      letter-spacing: 6px;
      color: var(--text-primary);
    }
    .drawer-info {
      font-size: 11px;
      font-weight: 600;
      color: var(--accent-mint);
    }

    /* Timer */
    .timer-box {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .timer-circle {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: #FFFFFF;
      border: 3px solid var(--accent-mint);
      display: flex;
      align-items: center;
      justify-content: center;
      font-family: var(--font-heading);
      font-size: 18px;
      font-weight: 800;
      color: var(--text-primary);
      transition: all 0.3s;
    }
    .timer-box.urgent .timer-circle {
      border-color: var(--error);
      color: var(--error);
      animation: pulse 0.8s infinite;
    }
    .timer-label {
      font-size: 10px;
      font-weight: 800;
      color: var(--text-muted);
    }

    /* Main Grid Layout */
    .game-layout {
      flex: 1;
      display: grid;
      grid-template-columns: 240px 1fr 280px;
      gap: 12px;
      min-height: 0;
    }
    @media (max-width: 960px) {
      .game-layout {
        grid-template-columns: 1fr;
        grid-template-rows: auto 1fr auto;
      }
      .sidebar-scores, .sidebar-guesses {
        display: none;
      }
    }

    /* Sidebars */
    .sidebar-scores, .sidebar-guesses {
      padding: 16px;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      min-height: 0;
    }
    .panel-title {
      font-size: 14px;
      font-weight: 800;
      margin-bottom: 12px;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    .scores-list {
      flex: 1;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .player-score-row {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 10px;
      border-radius: var(--radius-sm);
      background: rgba(255, 255, 255, 0.7);
      transition: all 0.2s;
    }
    .player-score-row.is-drawer {
      background: rgba(255, 87, 51, 0.12);
      border-left: 3px solid var(--primary-coral);
    }
    .player-score-row.has-guessed {
      background: rgba(46, 196, 182, 0.15);
    }
    .rank-badge {
      font-size: 11px;
      font-weight: 800;
      color: var(--text-muted);
    }
    .player-meta {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }
    .player-name {
      font-size: 13px;
      font-weight: 700;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .player-pts {
      font-size: 11px;
      font-weight: 600;
      color: var(--primary-coral);
    }
    .guessed-check {
      color: var(--accent-mint);
      font-weight: 800;
      font-size: 14px;
    }
    .reaction-bar {
      display: flex;
      justify-content: space-between;
      margin-top: 10px;
      padding-top: 8px;
      border-top: 1px solid rgba(40, 30, 20, 0.06);
    }
    .emoji-btn {
      font-size: 18px;
      background: #FFFFFF;
      padding: 4px;
      border-radius: 8px;
      transition: transform 0.15s;
    }
    .emoji-btn:hover {
      transform: scale(1.25);
    }

    /* Canvas Stage */
    .canvas-stage {
      display: flex;
      flex-direction: column;
      gap: 10px;
      min-height: 0;
      position: relative;
    }
    .canvas-frame {
      flex: 1;
      position: relative;
      background: #FFFFFF;
      border-radius: var(--radius-lg);
      box-shadow: var(--glass-shadow);
      overflow: hidden;
      touch-action: none;
    }
    canvas {
      width: 100%;
      height: 100%;
      display: block;
      cursor: crosshair;
    }

    /* Floating Reactions */
    .floating-emoji {
      position: absolute;
      font-size: 32px;
      pointer-events: none;
      animation: floatUpFade 1.6s ease-out forwards;
      z-index: 20;
    }
    @keyframes floatUpFade {
      0% { transform: translateY(0) scale(0.6); opacity: 1; }
      100% { transform: translateY(-70px) scale(1.3); opacity: 0; }
    }

    /* Drawer Toolbar */
    .drawer-toolbar {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 8px 16px;
      border-radius: var(--radius-md);
      gap: 12px;
      flex-wrap: wrap;
    }
    .color-palette {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .color-dot {
      width: 24px;
      height: 24px;
      border-radius: 50%;
      border: 2px solid #FFFFFF;
      box-shadow: 0 2px 4px rgba(0,0,0,0.15);
      cursor: pointer;
      transition: transform 0.15s, border-color 0.15s;
    }
    .color-dot:hover, .color-dot.selected {
      transform: scale(1.25);
      border-color: #22252A;
    }
    .tool-divider {
      width: 1px;
      height: 24px;
      background: rgba(40, 30, 20, 0.12);
    }
    .tool-actions {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .tool-btn {
      width: 34px;
      height: 34px;
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
      gap: 8px;
    }
    .brush-preview {
      border-radius: 50%;
      min-width: 8px;
      min-height: 8px;
    }
    .brush-slider {
      width: 80px;
      accent-color: var(--primary-coral);
    }

    /* Guesses Stream */
    .guesses-stream {
      flex: 1;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 6px;
      padding: 6px;
      background: rgba(255, 255, 255, 0.6);
      border-radius: var(--radius-md);
      margin-bottom: 10px;
    }
    .guess-bubble {
      padding: 6px 10px;
      border-radius: var(--radius-sm);
      background: #FFFFFF;
      font-size: 13px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 4px;
    }
    .guess-bubble.correct {
      background: rgba(46, 196, 182, 0.2);
      border: 1px solid var(--accent-mint);
      font-weight: 700;
    }
    .guess-bubble.close {
      background: rgba(255, 209, 102, 0.25);
    }
    .guesser-author {
      font-weight: 700;
      color: var(--text-secondary);
    }
    .correct-badge {
      color: #007A6E;
      font-size: 11px;
      font-weight: 800;
    }
    .close-badge {
      color: #B25E00;
      font-size: 11px;
      font-weight: 800;
    }
    .guess-input-form {
      display: flex;
      gap: 6px;
    }

    /* Overlays */
    .round-overlay {
      position: absolute;
      inset: 0;
      background: rgba(34, 37, 42, 0.5);
      backdrop-filter: blur(8px);
      z-index: 50;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
      animation: fadeIn 0.2s ease;
    }
    .overlay-modal {
      text-align: center;
      padding: 32px;
      max-width: 440px;
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 12px;
    }
    .overlay-icon {
      font-size: 52px;
    }
    .revealed-box {
      margin-top: 8px;
      background: #FFFFFF;
      padding: 10px 16px;
      border-radius: var(--radius-md);
      display: flex;
      flex-direction: column;
      gap: 4px;
    }
    .revealed-box strong {
      font-size: 20px;
      color: var(--primary-coral);
    }

    /* Victory Podium */
    .victory-modal {
      max-width: 520px;
    }
    .trophy-icon {
      font-size: 64px;
      animation: bounceSlow 2s infinite;
    }
    .podium-display {
      display: flex;
      justify-content: center;
      align-items: flex-end;
      gap: 16px;
      width: 100%;
      margin: 20px 0;
    }
    .podium-rank {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
      padding: 14px;
      border-radius: var(--radius-lg);
      background: #FFFFFF;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      flex: 1;
    }
    .podium-rank.rank-1 {
      border: 2px solid var(--accent-yellow);
      transform: translateY(-12px);
    }
    .medal-icon {
      font-size: 28px;
    }
    .winner-name {
      font-size: 13px;
      font-weight: 700;
    }
    .winner-score {
      font-size: 12px;
      font-weight: 800;
      color: var(--primary-coral);
    }
  `]
})
export class GameplayComponent implements OnInit, OnDestroy {
  @ViewChild('canvas', { static: true }) canvasRef!: ElementRef<HTMLCanvasElement>;
  @ViewChild('canvasContainer', { static: true }) containerRef!: ElementRef<HTMLDivElement>;
  @ViewChild('guessFeed') guessFeedRef?: ElementRef<HTMLDivElement>;

  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly stomp = inject(StompService);
  private readonly auth = inject(AuthService);
  readonly sound = inject(SoundService);
  private readonly roomService = inject(RoomService);

  roomId = '';
  room = signal<Room | null>(null);

  // Match State Signals
  currentRound = signal<number>(1);
  totalRounds = signal<number>(4);
  category = signal<string>('GENERAL');
  drawerName = signal<string>('Artist');
  currentDrawerId = signal<string>('');
  secretWord = signal<string>('');
  hint = signal<string>('');
  letterBlanks = signal<string>('_ _ _ _ _');
  remainingSeconds = signal<number>(60);

  isCurrentDrawer = signal<boolean>(false);
  hasGuessedCorrectly = signal<boolean>(false);

  // Scoreboard
  players = signal<PlayerScoreSummary[]>([]);

  // Guesses feed
  guessText = '';
  guessMessages = signal<GuessMessage[]>([
    {
      id: 'init-1',
      userId: 'sys',
      username: 'GameEngine',
      text: 'Round started! Watch the canvas and guess the word.',
      timestamp: new Date()
    }
  ]);

  // Reactions & Overlays
  reactions = ['🎉', '❤️', '🔥', '👏', '😂', '🎨'];
  floatingReactions = signal<Array<{ id: number; emoji: string; x: number; y: number }>>([]);

  showRoundOverlay = signal<boolean>(false);
  overlayTitle = signal<string>('Round Started!');
  overlaySubtitle = signal<string>('Get ready to guess or draw.');
  revealedWord = signal<string>('');

  showMatchEndOverlay = signal<boolean>(false);
  matchPodium = signal<PlayerScoreSummary[]>([]);

  // Drawing Tools
  paletteColors = [
    '#22252A', '#FF5733', '#2EC4B6', '#FFD166', '#B8A9C9',
    '#E63946', '#3A86FF', '#2A9D8F', '#F77F00', '#FFFFFF'
  ];
  selectedColor = '#FF5733';
  brushSize = 4;
  currentTool: 'PEN' | 'BRUSH' | 'GLOW' | 'FILL' | 'ERASER' = 'PEN';

  // Canvas context & stroke buffer
  private ctx!: CanvasRenderingContext2D;
  private isDrawing = false;
  private currentStroke: DrawingStroke | null = null;
  private strokesHistory: DrawingStroke[] = [];

  private subs = new Subscription();
  private timerSub?: Subscription;

  ngOnInit(): void {
    this.roomId = this.route.snapshot.params['roomId'] || '';
    this.initCanvas();
    this.setupRoomAndStomp();
    this.startLocalTimer(60);
  }

  ngOnDestroy(): void {
    this.subs.unsubscribe();
    this.timerSub?.unsubscribe();
  }

  @HostListener('window:resize')
  onResize(): void {
    this.resizeCanvas();
    this.redrawAllStrokes();
  }

  private initCanvas(): void {
    const canvas = this.canvasRef.nativeElement;
    this.ctx = canvas.getContext('2d')!;
    this.resizeCanvas();
  }

  private resizeCanvas(): void {
    const container = this.containerRef.nativeElement;
    const canvas = this.canvasRef.nativeElement;
    const dpr = window.devicePixelRatio || 1;

    canvas.width = container.clientWidth * dpr;
    canvas.height = container.clientHeight * dpr;

    this.ctx.scale(dpr, dpr);
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
  }

  private setupRoomAndStomp(): void {
    this.stomp.subscribeToRoom(this.roomId);

    // Initial players setup from room members
    this.roomService.getRoom(this.roomId).subscribe(r => {
      if (r) {
        this.room.set(r);
        this.totalRounds.set(r.totalRounds);
        this.category.set(r.category);
        const me = this.auth.currentUser();

        const summaries: PlayerScoreSummary[] = (r.members || []).map((m, idx) => ({
          userId: m.userId,
          displayName: m.displayName,
          avatarUrl: m.avatarUrl,
          score: 0,
          hasGuessed: false
        }));

        this.players.set(summaries);

        // If I am host, set drawer to host or first player
        if (r.members && r.members.length > 0) {
          const firstDrawer = r.members[0];
          this.currentDrawerId.set(firstDrawer.userId);
          this.drawerName.set(firstDrawer.displayName);
          this.isCurrentDrawer.set(me?.id === firstDrawer.userId);

          if (this.isCurrentDrawer()) {
            this.secretWord.set('DRAGON');
            this.hint.set('Mythical creature');
          } else {
            this.letterBlanks.set('_ _ _ _ _ _');
          }
        }
      }
    });

    // 1. Private User Queue: Secret Word Prompt
    this.subs.add(
      this.stomp.privateNotifications$.subscribe((event: GameEvent) => {
        if (event.eventType === 'SECRET_WORD_PROMPT' || event.eventType === 'SECRET_WORD') {
          this.sound.playChime();
          this.isCurrentDrawer.set(true);
          this.secretWord.set(event.payload.secretWord);
          this.hint.set(event.payload.hint || '');
          this.category.set(event.payload.category || 'GENERAL');
          this.startLocalTimer(event.payload.durationSeconds || 60);

          this.triggerRoundBanner('Your Turn to Draw!', `Secret Word: ${event.payload.secretWord}`);
        }
      })
    );

    // 2. Public Game Topic: ROUND_START, ROUND_END, MATCH_END, REACTION
    this.subs.add(
      this.stomp.gameEvents$.subscribe((event: GameEvent) => {
        switch (event.eventType) {
          case 'ROUND_START':
            this.handleRoundStart(event.payload);
            break;
          case 'ROUND_END':
            this.handleRoundEnd(event.payload);
            break;
          case 'MATCH_END':
            this.handleMatchEnd(event.payload);
            break;
          case 'REACTION':
            this.showFloatingReaction(event.payload?.emoji || '🎨');
            break;
        }
      })
    );

    // 3. Drawing Topic: Remote Strokes & Erase
    this.subs.add(
      this.stomp.drawingEvents$.subscribe((event: GameEvent<DrawingStroke>) => {
        if (event.eventType === 'DRAWING_CHUNK') {
          if (!this.isCurrentDrawer()) {
            this.renderRemoteStroke(event.payload);
          }
        } else if (event.eventType === 'DRAWING_UNDO') {
          this.strokesHistory.pop();
          this.redrawAllStrokes();
        } else if (event.eventType === 'DRAWING_CLEAR') {
          this.strokesHistory = [];
          this.clearCanvasLocally();
        }
      })
    );

    // 4. Score Topic: CORRECT_GUESS, SCORES_UPDATE
    this.subs.add(
      this.stomp.scoreEvents$.subscribe((event: GameEvent) => {
        if (event.eventType === 'CORRECT_GUESS') {
          this.sound.playChime();
          const guesserId = event.payload?.userId;
          const guesserName = event.payload?.displayName || 'Player';
          const points = event.payload?.pointsAwarded || 250;

          if (guesserId === this.auth.currentUser()?.id) {
            this.hasGuessedCorrectly.set(true);
          }

          this.addGuessMessage(guesserName, 'Guessed the word!', true, false, points);
          this.markPlayerGuessed(guesserId);
        } else if (event.eventType === 'CLOSE_GUESS') {
          this.addGuessMessage(event.senderName || 'Player', event.payload?.text || '', false, true);
        } else if (event.eventType === 'SCORES_UPDATE') {
          if (Array.isArray(event.payload?.scores)) {
            this.players.set(event.payload.scores);
          }
        }
      })
    );
  }

  private handleRoundStart(payload: any): void {
    this.sound.playFanfare();
    this.clearCanvasLocally();
    this.strokesHistory = [];
    this.hasGuessedCorrectly.set(false);

    this.currentRound.set(payload.roundNumber || 1);
    this.totalRounds.set(payload.totalRounds || 4);
    this.currentDrawerId.set(payload.drawerId);
    this.drawerName.set(payload.drawerName || 'Artist');
    this.category.set(payload.category || 'GENERAL');
    this.letterBlanks.set(payload.letterBlanks || '_ _ _ _ _');

    const me = this.auth.currentUser();
    const isMe = me?.id === payload.drawerId;
    this.isCurrentDrawer.set(isMe);

    this.startLocalTimer(payload.durationSeconds || 60);

    if (!isMe) {
      this.triggerRoundBanner(`Round ${payload.roundNumber}`, `Artist: ${payload.drawerName}`);
    }
  }

  private handleRoundEnd(payload: any): void {
    this.sound.playChime();
    this.revealedWord.set(payload.secretWord || '');
    this.showRoundOverlay.set(true);
    this.overlayTitle.set('Round Over!');
    this.overlaySubtitle.set('Next round starting shortly...');

    setTimeout(() => {
      this.showRoundOverlay.set(false);
      this.revealedWord.set('');
    }, 4000);
  }

  private handleMatchEnd(payload: any): void {
    this.sound.playFanfare();
    this.showMatchEndOverlay.set(true);
    this.matchPodium.set(this.players().slice(0, 3));

    // Fire celebratory confetti!
    confetti({
      particleCount: 120,
      spread: 70,
      origin: { y: 0.6 }
    });
  }

  // --- Vector Drawing Implementation ---

  onPointerDown(e: PointerEvent): void {
    if (!this.isCurrentDrawer()) return;
    this.isDrawing = true;
    const pt = this.getNormalizedPoint(e);

    this.currentStroke = {
      strokeId: 's-' + Date.now() + '-' + Math.random().toString(36).substring(2, 6),
      color: this.currentTool === 'ERASER' ? '#FFFFFF' : this.selectedColor,
      brushSize: this.brushSize,
      tool: this.currentTool,
      points: [pt],
      isFinished: false
    };

    this.drawSegment(pt, pt, this.currentStroke.color, this.currentStroke.brushSize);
  }

  onPointerMove(e: PointerEvent): void {
    if (!this.isDrawing || !this.currentStroke) return;
    const pt = this.getNormalizedPoint(e);
    const lastPt = this.currentStroke.points[this.currentStroke.points.length - 1];

    this.currentStroke.points.push(pt);
    this.drawSegment(lastPt, pt, this.currentStroke.color, this.currentStroke.brushSize);

    // Send stroke chunk over STOMP every 3 points to optimize network
    if (this.currentStroke.points.length % 3 === 0) {
      this.stomp.sendDrawingStroke(this.roomId, this.currentStroke);
    }
  }

  onPointerUp(e: PointerEvent): void {
    if (!this.isDrawing || !this.currentStroke) return;
    this.isDrawing = false;
    this.currentStroke.isFinished = true;
    this.strokesHistory.push(this.currentStroke);

    // Broadcast finalized stroke
    this.stomp.sendDrawingStroke(this.roomId, this.currentStroke);
    this.currentStroke = null;
  }

  private getNormalizedPoint(e: PointerEvent): DrawingPoint {
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));
    return { x, y };
  }

  private drawSegment(p1: DrawingPoint, p2: DrawingPoint, color: string, size: number): void {
    const container = this.containerRef.nativeElement;
    const w = container.clientWidth;
    const h = container.clientHeight;

    this.ctx.strokeStyle = color;
    this.ctx.lineWidth = size;
    this.ctx.beginPath();
    this.ctx.moveTo(p1.x * w, p1.y * h);
    this.ctx.lineTo(p2.x * w, p2.y * h);
    this.ctx.stroke();
  }

  private renderRemoteStroke(stroke: DrawingStroke): void {
    if (!stroke || !stroke.points || stroke.points.length === 0) return;
    for (let i = 1; i < stroke.points.length; i++) {
      this.drawSegment(stroke.points[i - 1], stroke.points[i], stroke.color, stroke.brushSize);
    }
  }

  private redrawAllStrokes(): void {
    this.clearCanvasLocally();
    this.strokesHistory.forEach(s => this.renderRemoteStroke(s));
  }

  private clearCanvasLocally(): void {
    const container = this.containerRef.nativeElement;
    this.ctx.clearRect(0, 0, container.clientWidth, container.clientHeight);
  }

  selectColor(color: string): void {
    this.sound.playPop();
    this.selectedColor = color;
    if (this.currentTool === 'ERASER') {
      this.currentTool = 'PEN';
    }
  }

  selectTool(tool: 'PEN' | 'BRUSH' | 'GLOW' | 'FILL' | 'ERASER', size: number): void {
    this.sound.playPop();
    this.currentTool = tool;
    this.brushSize = size;
  }

  undoStroke(): void {
    if (this.strokesHistory.length === 0) return;
    this.sound.playPop();
    this.strokesHistory.pop();
    this.redrawAllStrokes();
    this.stomp.sendDrawingUndo(this.roomId);
  }

  clearCanvas(): void {
    this.sound.playPop();
    this.strokesHistory = [];
    this.clearCanvasLocally();
    this.stomp.sendDrawingClear(this.roomId);
  }

  // --- Gameplay Interaction ---

  submitGuess(): void {
    if (!this.guessText.trim() || this.isCurrentDrawer()) return;
    const text = this.guessText.trim();
    this.guessText = '';
    this.sound.playPop();

    const me = this.auth.currentUser();
    const username = me?.displayName || 'You';

    // Check if offline mock match matches local secret word
    const isMockMatch = text.toLowerCase() === this.secretWord().toLowerCase();
    if (isMockMatch) {
      this.sound.playChime();
      this.hasGuessedCorrectly.set(true);
      this.addGuessMessage(username, text, true, false, 250);
      if (me) this.markPlayerGuessed(me.id);
    } else {
      this.addGuessMessage(username, text, false, false);
    }

    this.stomp.sendGuess(this.roomId, text);
  }

  private addGuessMessage(username: string, text: string, isCorrect = false, isClose = false, pointsAwarded?: number): void {
    const msg: GuessMessage = {
      id: Date.now() + '-' + Math.random(),
      userId: 'user',
      username,
      text,
      isCorrect,
      isClose,
      pointsAwarded,
      timestamp: new Date()
    };
    this.guessMessages.update(msgs => [...msgs, msg]);

    setTimeout(() => {
      if (this.guessFeedRef) {
        this.guessFeedRef.nativeElement.scrollTop = this.guessFeedRef.nativeElement.scrollHeight;
      }
    }, 50);
  }

  private markPlayerGuessed(userId: string): void {
    this.players.update(list =>
      list.map(p => (p.userId === userId ? { ...p, score: p.score + 250, hasGuessed: true } : p))
    );
  }

  sendReaction(emoji: string): void {
    this.sound.playPop();
    this.stomp.sendReaction(this.roomId, emoji);
    this.showFloatingReaction(emoji);
  }

  private showFloatingReaction(emoji: string): void {
    const reaction = {
      id: Date.now() + Math.random(),
      emoji,
      x: 30 + Math.random() * 40,
      y: 60 + Math.random() * 20
    };
    this.floatingReactions.update(list => [...list, reaction]);

    setTimeout(() => {
      this.floatingReactions.update(list => list.filter(r => r.id !== reaction.id));
    }, 1600);
  }

  private startLocalTimer(seconds: number): void {
    this.remainingSeconds.set(seconds);
    this.timerSub?.unsubscribe();

    this.timerSub = interval(1000).subscribe(() => {
      const cur = this.remainingSeconds();
      if (cur <= 1) {
        this.remainingSeconds.set(0);
        this.timerSub?.unsubscribe();
      } else {
        this.remainingSeconds.set(cur - 1);
        if (cur - 1 <= 10) {
          this.sound.playTick();
        }
      }
    });
  }

  private triggerRoundBanner(title: string, subtitle: string): void {
    this.overlayTitle.set(title);
    this.overlaySubtitle.set(subtitle);
    this.showRoundOverlay.set(true);

    setTimeout(() => {
      this.showRoundOverlay.set(false);
    }, 3000);
  }

  exitGame(): void {
    this.sound.playPop();
    this.router.navigate(['/home']);
  }
}
