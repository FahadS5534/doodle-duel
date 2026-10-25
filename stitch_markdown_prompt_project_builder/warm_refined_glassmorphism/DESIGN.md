---
name: Warm Refined Glassmorphism
colors:
  surface: '#fcf9f4'
  surface-dim: '#dcdad5'
  surface-bright: '#fcf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ee'
  surface-container: '#f0ede9'
  surface-container-high: '#ebe8e3'
  surface-container-highest: '#e5e2dd'
  on-surface: '#1c1c19'
  on-surface-variant: '#5b403a'
  inverse-surface: '#31302d'
  inverse-on-surface: '#f3f0eb'
  outline: '#8f7069'
  outline-variant: '#e4beb6'
  surface-tint: '#b72301'
  primary: '#b72301'
  on-primary: '#ffffff'
  primary-container: '#ff5733'
  on-primary-container: '#580c00'
  inverse-primary: '#ffb4a4'
  secondary: '#006a62'
  on-secondary: '#ffffff'
  secondary-container: '#70f8e8'
  on-secondary-container: '#007168'
  tertiary: '#785a00'
  on-tertiary: '#ffffff'
  tertiary-container: '#b38c27'
  on-tertiary-container: '#382800'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad3'
  primary-fixed-dim: '#ffb4a4'
  on-primary-fixed: '#3d0600'
  on-primary-fixed-variant: '#8c1800'
  secondary-fixed: '#70f8e8'
  secondary-fixed-dim: '#4fdbcc'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#ffdf9b'
  tertiary-fixed-dim: '#edc157'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#5b4300'
  background: '#fcf9f4'
  on-background: '#1c1c19'
  surface-variant: '#e5e2dd'
  bg-root: '#FBF8F3'
  bg-secondary: '#F5EFEB'
  surface-canvas: '#FFFFFF'
  primary-coral: '#FF5733'
  primary-coral-light: '#FF6B4A'
  accent-mint: '#2EC4B6'
  accent-mint-bright: '#38D9A9'
  accent-yellow: '#FFD166'
  accent-lavender: '#B8A9C9'
  accent-lavender-subtle: '#E8E0F0'
  text-primary: '#22252A'
  text-secondary: '#636B78'
  text-muted: '#9AA0A6'
  border-glass: rgba(255, 255, 255, 0.7)
  border-subtle: rgba(40, 30, 20, 0.08)
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 21px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.5rem
---

# Doodle Duel Design System — Warm Refined Glassmorphism

## 1. Visual Identity & Brand Concept
- **Product**: Doodle Duel — Real-time multiplayer drawing & guessing mobile game (Flutter architecture ready).
- **Aesthetic**: Warm ivory & soft cream surfaces, translucent frosted white glass panels (75–90% opacity), thin crisp borders (rgba(255,255,255,0.8) and soft warm graphite), diffuse organic shadows, and playful doodle accents.
- **Tone**: Playful, tactile, premium indie game, welcoming creative tool with vibrant coral accents and fresh mint details.

## 2. Color Palette & Tokens
- **Background Root**: `#FBF8F3` (Warm Ivory / Soft Alabaster)
- **Background Secondary / Tint**: `#F5EFEB` (Pale Warm Cream)
- **Surface Glass High**: `rgba(255, 255, 255, 0.85)` with `backdrop-filter: blur(16px)`
- **Surface Glass Subtle**: `rgba(255, 255, 255, 0.65)` with `backdrop-filter: blur(12px)`
- **Surface Canvas (Drawing)**: `#FFFFFF` (Solid, high contrast, zero blur)
- **Primary Accent (Coral/Vermilion)**: `#FF5733` / `#FF6B4A` (Vivid Coral)
- **Primary Gradient**: `linear-gradient(135deg, #FF6B4A 0%, #FFA07A 100%)`
- **Secondary Accent (Mint Green)**: `#2EC4B6` / `#38D9A9` (Fresh Mint for correct guesses, readiness)
- **Tertiary Accent (Buttery Yellow)**: `#FFD166` (Coins, stars, streaks, warnings)
- **Quaternary Accent (Soft Lavender)**: `#B8A9C9` / `#E8E0F0` (Tags, playful doodle tint)
- **Text Primary**: `#22252A` (Deep Charcoal)
- **Text Secondary**: `#636B78` (Warm Graphite / Muted Grey)
- **Text Muted**: `#9AA0A6`
- **Border Glass**: `rgba(255, 255, 255, 0.7)` and `rgba(40, 30, 20, 0.08)`
- **Shadow Soft**: `0 10px 30px -5px rgba(180, 150, 130, 0.15), 0 4px 12px -2px rgba(180, 150, 130, 0.08)`

## 3. Typography Scale (Mobile Viewport ~393x852)
- **Font Family**: Inter, Plus Jakarta Sans, system-ui sans-serif
- **Display / Headings**: Rounded, bold, playful character tracking
  - Display 1: 28px, Bold / 800, Line height 1.2
  - Heading 1: 22px, Bold / 700, Line height 1.25
  - Heading 2: 18px, SemiBold / 600, Line height 1.3
  - Heading 3 / Subhead: 15px, Medium / 600, Line height 1.4
  - Body Regular: 14px, Regular / 400, Line height 1.5
  - Caption / Badge: 11px–12px, SemiBold / 600, uppercase letter-spacing +0.5px

## 4. Components & Flutter-Ready Conventions
- **Buttons**:
  - Primary: Solid vivid coral `#FF5733`, text `#FFFFFF`, rounded 16px-20px, height 50px, active scale 0.98.
  - Secondary: Glass white `rgba(255,255,255,0.9)`, border 1.5px solid `rgba(255,87,51,0.2)`, text `#22252A`.
  - Icon Buttons: 44x44px circular or rounded-14px glass containers.
- **Cards & Sheets**:
  - Radius: 20px–24px.
  - Padding: 16px–20px.
  - Border: 1px solid `rgba(255, 255, 255, 0.9)`.
- **Game Elements**:
  - Timer bar: Rounded pill with gradient filling; shifts to vivid coral below 10s.
  - Live Score Strip: Mini floating avatar chips with +points floating counter.
  - Drawing Canvas: Crisp `#FFFFFF` card, 16px radius, subtle inset shadow, dedicated touch zone.
