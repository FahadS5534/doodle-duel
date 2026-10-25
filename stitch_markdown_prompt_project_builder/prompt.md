# Doodle Duel — Premium Glassmorphic Flutter App UI

## Project Overview
Design a complete, high-fidelity mobile UI for **Doodle Duel**, a real-time multiplayer drawing and guessing game. Players create private rooms, invite friends, draw prompts against a timer, guess other players' drawings, earn points, and compete on leaderboards.

The app will eventually be developed using Flutter, BLoC, CustomPainter, and Firebase Realtime Database. Design the interface as a realistic, implementable mobile application rather than a static concept.

## 1. Design Direction

Create a distinctive, modern, playful, premium gaming experience using refined glassmorphism.

**Visual identity:**
- Background: warm ivory, soft cream, and very pale peach.
- Primary accent: vivid coral or vermilion.
- Secondary accents: fresh mint green, buttery yellow, and lavender.
- Text: deep charcoal, warm graphite, and muted grey.
- Surfaces: translucent white glass panels with subtle background blur, delicate borders, and restrained shadows.
- Gradients: occasional coral-to-peach or mint-to-cream gradients.
- Typography: use a clean, contemporary sans-serif such as Inter, with expressive rounded headings.
- Icons: consistent rounded-line icons, simple and recognizable.
- Illustrations: hand-drawn doodles, imperfect strokes, stars, sparkles, squiggles, and tiny playful characters.

**Avoid completely:**
- Dark blue, navy, and purple-dominated SaaS aesthetics.
- Generic AI-generated dashboard layouts.
- Excessive gradients, glowing borders, neon effects, and overdone blur.
- Huge empty hero sections and unnecessary oversized cards.
- Generic stock photography and 3D cartoon characters.
- Too many floating glass cards layered on top of one another.
- Desktop web dashboard styling squeezed into a phone screen.

The result should feel like a combination of a premium indie game, a playful creative tool, and a carefully designed social app.

## 2. Glassmorphism Rules

Use glass selectively to create depth, not as decoration everywhere.

- Main background: solid warm ivory with subtle decorative doodle patterns.
- Primary cards: translucent white with approximately 75–90% visual opacity.
- Borders: thin white or warm-grey borders with subtle highlights.
- Shadows: soft, diffuse, low-opacity shadows.
- Blur: reserve backdrop blur for floating overlays, modals, navigation, and selected panels.
- Buttons: mostly solid coral, mint, or charcoal fills for strong contrast.
- Text: always readable, even when placed over translucent surfaces.
- Drawing canvas: clean, opaque white surface without glass effects.

Prioritize readability, accessible contrast, consistent spacing, and layouts that can be recreated using Flutter widgets.

## 3. Design the Following Screens

Create a cohesive multi-screen mobile application. Use the same design system, navigation patterns, typography, colors, radii, and icon style across all screens.

### Screen 1 — Welcome and Onboarding
- App logo featuring a simple hand-drawn pencil, doodle, or playful brush mark.
- Wordmark: Doodle Duel.
- Tagline: "Draw it. Guess it. Own it."
- Small illustrated doodles floating around the composition.
- Primary coral button: "Let's Play".
- Secondary text button: "I already have an account".
- Minimal onboarding slides explaining drawing, guessing, and playing with friends.

### Screen 2 — Home Lobby
This is the primary screen and should receive the most design attention.

- Greeting: "Ready to doodle?"
- Player avatar, username, and small level or streak indicator.
- A prominent coral-to-peach feature panel saying "Your next masterpiece awaits."
- Primary CTA: "Create a Room".
- Secondary CTA: "Join with Code".
- A compact "Play with Friends" section showing friends' avatars and online indicators.
- A "Jump Back In" section for recent rooms or ongoing games.
- Small statistics for games played, wins, and best score.
- A subtle daily drawing challenge.
- Bottom navigation: Home, Discover, Leaderboard, Profile.

Keep the hierarchy clear. Room creation and joining should be immediately accessible without scrolling.

### Screen 3 — Create Room
- Heading: "Set up your duel".
- Room name field.
- Player capacity selector.
- Rounds selector.
- Drawing time selector.
- Difficulty selection: Easy, Medium, Hard.
- Toggle for private or public room.
- Optional custom word categories.
- A clear summary of the selected game settings.
- Prominent coral button: "Create Room".
- Compact, translucent settings sections with tasteful icons.

Do not overcrowd this screen. Use expandable settings or grouped controls where appropriate.

### Screen 4 — Join Room
- Heading: "Jump into the fun".
- Large room-code input with clearly separated characters.
- Paste-code interaction.
- Optional QR-code scanning entry point.
- Recently joined rooms.
- Primary button: "Join Game".
- Friendly validation and error states.
- Small doodle illustration suggesting friends connecting.

### Screen 5 — Room Waiting Lobby
- Room title and invite code with a copy action.
- Player capacity and current player count.
- Grid or horizontal arrangement of player avatars.
- Ready status for each participant.
- Host indicator and host-only room settings.
- Invite friends action.
- Animated-style waiting illustration or subtle doodle accents.
- Host CTA: "Start Game".
- Non-host state: "Waiting for host..."
- Empty player slots represented by understated dashed outlines.

Make the room feel social and lively without visual clutter.

### Screen 6 — Main Drawing Gameplay
This is the most important screen. Prioritize drawing space and fast interactions.

- Top bar with round number, remaining time, and compact player score indicators.
- Prompt display with the selected word, shown only to the drawer.
- A large, responsive, white drawing canvas occupying most of the screen.
- A compact drawing toolbar with pen, eraser, undo, redo, and clear controls.
- Color palette using circular swatches.
- Brush-size selector.
- Clear visual feedback for the currently selected tool and color.
- Player list with small avatars and online/connection indicators.
- Lightweight chat or guess input where appropriate for the game mode.
- Floating glass overlay for secondary game information.
- A subtle timer progress indicator that becomes coral near the deadline.

Design the canvas as an actual usable workspace, not a decorative illustration. Avoid placing translucent panels over the drawing surface. Keep the main tools reachable with one hand.

### Screen 7 — Guessing Gameplay
- Large shared drawing canvas.
- Prompt hidden from guessers.
- Timer and round information.
- Compact live score strip.
- Text input at the bottom with a clear send button.
- Quick-guess suggestions or emoji reactions as optional controls.
- Subtle correct-guess feedback.
- A success state with a mint-green accent and a short celebratory animation concept.
- Incorrect guesses should show understated feedback without interrupting typing.

The guessing input must remain accessible while the canvas is visible.

### Screen 8 — Round Results
- Large illustrated correct answer.
- Heading: "You got it!" or "Round complete".
- Points earned displayed prominently.
- Breakdown of speed bonus, drawing quality or participation points if applicable.
- Compact player ranking for the round.
- Playful confetti and doodle accents used sparingly.
- CTA: "Next Round".
- Secondary action: "Back to Lobby".

Create variations for a correct guess, a missed guess, and the drawer's result.

### Screen 9 — Final Results and Leaderboard
- Heading: "The final doodle-off".
- Winner presentation using a distinctive illustration rather than a generic trophy stock image.
- Ranked players with avatars, points, and small badges.
- Clear differentiation between first, second, and third place.
- Personal performance summary.
- Actions: "Play Again", "Rematch Friends", and "Return Home".
- A shareable results-card concept.
- Celebrate everyone, not just the winner.

### Screen 10 — Discover Games
- Featured public rooms.
- Filters for player count, difficulty, and game type.
- Search rooms by name or code.
- Room cards with player count, status, and host avatar.
- Daily drawing challenge.
- Trending community categories.
- Clear join actions and full-room states.

### Screen 11 — Leaderboard
- Weekly and all-time tabs.
- Top players with avatars and distinct podium styling.
- Ranked player list.
- Current player's position pinned near the bottom when useful.
- Filters for friends and global rankings.
- Small trend indicators for positions gained or lost.
- Maintain a light, playful appearance rather than a competitive esports dashboard.

### Screen 12 — Profile and Settings
- Avatar and username.
- Editable profile information.
- Statistics: games played, wins, correct guesses, and drawings completed.
- Achievements and badges.
- Recent match history.
- Sound and haptic preferences.
- Theme and accessibility preferences.
- Account and logout actions.

Use a clean, organized layout with restrained glass panels and compact statistics.

## 4. Component Design System

Establish reusable components that can later be implemented in Flutter.

**Buttons**
- Primary: solid coral, rounded corners, strong contrast.
- Secondary: white or translucent surface with a subtle border.
- Tertiary: text buttons with minimal visual weight.
- Destructive: muted red treatment.
- Clear loading, disabled, pressed, and focus states.

**Cards**
- Rounded corners between 18 and 24 logical pixels.
- Consistent padding.
- Thin borders and soft shadows.
- Avoid unnecessary nested cards.

**Inputs**
- Rounded rectangular fields.
- Clear labels, hints, focus states, and validation errors.
- Distinct filled and outlined variants.

**Navigation**
- Compact, rounded bottom navigation.
- Clear active state using coral accents.
- Respect mobile safe areas.

**Feedback**
- Lightweight snackbars.
- Small confirmation dialogs.
- Connection-lost banners.
- Loading skeletons.
- Empty states with small doodle illustrations.
- Success and error states with distinct colors and accessible text.

## 5. Motion and Interaction

Design subtle interaction concepts:
- Buttons compress slightly when pressed.
- Cards lift gently on selection.
- Avatars animate into the lobby.
- Drawing tools show immediate selected states.
- Timer transitions smoothly as time decreases.
- Correct guesses trigger a brief mint-colored confirmation.
- Final results reveal rankings with a short staggered entrance.
- Connection loss displays a compact reconnecting indicator.

Motion should feel quick and intentional. Avoid excessive bouncing, long transitions, or distracting animations during gameplay.

## 6. Responsive and Flutter-Friendly Requirements

- Target a modern Android phone viewport, approximately 393 × 852 logical pixels.
- Use responsive layouts that adapt to smaller and larger screens.
- Respect safe areas and keyboard insets.
- Ensure the drawing canvas resizes correctly when controls or keyboards appear.
- Use a consistent spacing scale based on 4- and 8-point increments.
- Prefer reusable components, standard mobile navigation, and straightforward layouts.
- Keep interactive targets approximately 44–48 logical pixels or larger where practical.
- Use clear semantic hierarchy and accessible color contrast.
- Avoid layouts that depend on complex overlapping elements or impossible blur effects.

Assume the app will later use Flutter, BLoC, CustomPainter, and Firebase Realtime Database. Design realistic screens and interaction states that fit this implementation.

## 7. Final Deliverable

Generate a polished, cohesive mobile UI design system and the complete set of screens above.

Start by creating the Home Lobby, Main Drawing Gameplay, Guessing Gameplay, and Room Waiting Lobby at high fidelity. Then extend the same design language to onboarding, room creation, results, leaderboard, discovery, and profile.

Show realistic app content, consistent spacing, meaningful component reuse, and believable gameplay states.

**Final creative direction:** warm glassmorphism, tactile controls, expressive doodle illustrations, sophisticated whitespace, coral accents, mint details, and a distinctly playful personality. The app should look designed by a thoughtful product designer, not generated from a generic AI dashboard template.