# 🎨 Doodle Duel — Angular Web Client

> **"Draw it. Guess it. Own it."** — Web Edition

A modern, responsive, standalone **Angular 19+** single-page web application replicating the full **Warm Refined Glassmorphism** design system, real-time multiplayer vector drawing canvas, and game engine integration of Doodle Duel.

---

## 🌟 Highlights & Features

- **Warm Refined Glassmorphism Aesthetic**:
  - Exact color tokens matching the Flutter client: Warm parchment background (`#FBF8F3`), tactile coral CTA buttons (`#FF5733`), vibrant mint accents (`#2EC4B6`), butter yellow badges (`#FFD166`), and translucent frosted glass cards (`rgba(255, 255, 255, 0.82)`).
  - Modern typography powered by **Plus Jakarta Sans** (headings) & **Inter** (body text).
  - Ambient floating doodles background (pencils, stars, swirls, paint palettes).
- **Cross-Platform Real-Time Vector Canvas**:
  - Hardware-accelerated HTML5 vector drawing canvas with smooth Bezier interpolation.
  - Normalized $[0.0, 1.0]$ coordinates matching the Spring Boot authoritative backend and Flutter mobile client.
  - Tactile 10-color artist palette, brush thickness slider, undo stroke, and clear canvas.
  - Role-adaptive interface: Secret word drawer prompt vs masked word blanks (`_ _ _ _ _`) for guessers.
- **WebSocket STOMP Integration**:
  - Real-time room events (`/topic/rooms/{roomId}/lobby`, `/game`, `/drawing`, `/scores`).
  - Private drawer notifications (`/user/queue/notifications`).
  - Reaction emoji bursts, live turn countdown timer, guess feed, and scoreboards.
- **Offline Warm-up Sketchpad**:
  - Standalone practice mode with 150+ categorized prompts across Easy, Medium, Hard, and Pop Culture.
  - Prompt randomizer and full drawing toolkit.
  - High-res PNG export (`doodle-duel-practice.png`).
- **Web Audio API Sound Engine**:
  - Zero-asset synthesized acoustic feedback: Button pops, correct guess chimes, tick-tock countdown, and victory fanfares.
  - Persistent sound toggle in the navigation bar.
- **Dual Endpoint Switcher**:
  - 1-click switcher between **Live Cloud** (`https://doodle-duel-9wbf.onrender.com`) and **Local Development** (`http://localhost:8080`).

---

## 📁 Project Architecture

```
angular-frontend/
├── src/
│   ├── app/
│   │   ├── core/
│   │   │   ├── guards/          # authGuard & guestOrAuthGuard
│   │   │   ├── interceptors/    # AuthInterceptor (JWT Bearer injection)
│   │   │   ├── models/          # User, Room, Game, DrawingPoint, Guess models
│   │   │   └── services/        # AuthService, RoomService, StompService, SoundService, ConfigService
│   │   ├── shared/
│   │   │   ├── components/      # Navbar, AvatarWidget, AmbientDoodle
│   │   │   └── pipes/
│   │   ├── features/
│   │   │   ├── welcome/         # Hero landing & guest nickname modal
│   │   │   ├── auth/            # Login & Register views
│   │   │   ├── home/            # Bento grid lobby, Season 4 banner, quick actions
│   │   │   ├── rooms/           # Public room discovery & search
│   │   │   ├── lobby/           # Waiting room, player grid, ready check, chat
│   │   │   ├── gameplay/        # Real-time multiplayer drawing & guessing
│   │   │   ├── sketchpad/       # Offline practice canvas with 150+ prompts
│   │   │   ├── leaderboard/     # All-time and weekly podium rankings
│   │   │   └── profile/         # Avatar customizer & career stats
│   │   ├── app.component.ts
│   │   ├── app.config.ts        # Standalone app configuration & router providers
│   │   └── app.routes.ts        # Declarative route configuration
│   ├── index.html               # Plus Jakarta Sans & Inter webfonts
│   ├── styles.css               # Global glassmorphism design system & utility classes
│   └── main.ts
├── angular.json
├── package.json
└── tsconfig.json
```

---

## 🚀 Quick Start & Development

### Prerequisites
- **Node.js**: v18.19+ or v20+ (`node -v`)
- **npm**: v9+ (`npm -v`)

### 1. Install Dependencies
```bash
cd angular-frontend
npm install
```

### 2. Start Local Development Server
```bash
npm start
# or: ng serve
```
Navigate to `http://localhost:4200/` in your browser. The app will automatically reload if you change any source files.

### 3. Production Build
```bash
npm run build
```
Compiled output is generated in the `dist/angular-frontend/browser` folder with zero errors and zero warnings.

---

## 🎨 Design Tokens

| Token Name | Value | Purpose |
| :--- | :--- | :--- |
| `--bg-root` | `#FBF8F3` | Warm parchment main screen background |
| `--surface-solid` | `#FFFFFF` | Solid drawing canvas |
| `--primary-coral` | `#FF5733` | Primary action CTAs and active states |
| `--primary-coral-dark` | `#E04826` | Hover and active button states |
| `--accent-mint` | `#2EC4B6` | Correct guess celebrations & ready badges |
| `--accent-yellow` | `#FFD166` | Host crowns, streaks, and coin counters |
| `--accent-lavender` | `#B8A9C9` | Secondary chips and decorative accents |
| `--text-primary` | `#22252A` | High-contrast typography headings |
| `--text-secondary` | `#636B78` | Subheadings and meta labels |
| `--glass-bg` | `rgba(255, 255, 255, 0.82)` | Frosted glass card fill |
| `--glass-border` | `rgba(255, 255, 255, 0.60)` | Frosted glass card border |

---

## 📄 License
This project is open-source and available under the Apache 2.0 License.
