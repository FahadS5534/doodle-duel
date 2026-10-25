# ☕ Doodle Duel — Java Spring Boot Backend Architecture & Code Walkthrough

This document provides a comprehensive, class-by-class explanation of every source file in the **Doodle Duel** Spring Boot 3 (`Java 21 LTS`) backend.

---

## 📑 Table of Contents

1. [Architectural Overview & Design Principles](#1-architectural-overview--design-principles)
2. [Application Entry Point](#2-application-entry-point)
3. [Configuration Layer (`com.doodleduel.config`)](#3-configuration-layer-comdoodleduelconfig)
4. [Security & Authentication (`com.doodleduel.security` & `com.doodleduel.auth`)](#4-security--authentication-comdoodleduelsecurity--comdoodleduelauth)
5. [Common Utilities & Error Handling (`com.doodleduel.common`)](#5-common-utilities--error-handling-comdoodleduelcommon)
6. [User & Career Management (`com.doodleduel.users`)](#6-user--career-management-comdoodleduelusers)
7. [Room & Lobby Management (`com.doodleduel.rooms`)](#7-room--lobby-management-comdoodleduelrooms)
8. [Drawing Subsystem (`com.doodleduel.drawing`)](#8-drawing-subsystem-comdoodledueldrawing)
9. [Scoring & Word Bank Engine (`com.doodleduel.scoring`)](#9-scoring--word-bank-engine-comdoodleduelscoring)
10. [Game Engine & Match Persistence (`com.doodleduel.games` & `.engine`)](#10-game-engine--match-persistence-comdoodleduelgames--engine)
11. [Real-Time WebSocket & STOMP Messaging (`com.doodleduel.websocket`)](#11-real-time-websocket--stomp-messaging-comdoodleduelwebsocket)
12. [Leaderboard System (`com.doodleduel.leaderboard`)](#12-leaderboard-system-comdoodleduelleaderboard)

---

## 1. Architectural Overview & Design Principles

The backend is built around four fundamental architectural pillars:

1. **Server-Authoritative State Machine**: The Spring Boot backend owns word selection, turn countdowns, guess validation, score math, and phase transitions. The Flutter client acts purely as a responsive rendering and input terminal.
2. **Hybrid State Strategy (In-Memory Live Buffer + Relational PostgreSQL)**:
   - High-frequency drawing coordinates (60 Hz touch events) and sub-second guessing events are processed in memory using thread-safe data structures (`ConcurrentHashMap`, `CopyOnWriteArrayList`).
   - Durable data (users, completed matches, rounds, round results, player statistics, and leaderboard standings) is transactional and persisted to PostgreSQL using **Flyway** migrations.
3. **Strict Secret Word Isolation**: The plain drawing word is delivered **exclusively** to the active drawer's private destination (`/user/queue/notifications`). Guessers receive masked letter counts (e.g. `_ _ _ _   _ _ _ _ _`) over the public room topic (`/topic/rooms/{roomId}/game`).
4. **Normalized Vector Coordinate Protocol**: Touch events are transformed to unit coordinates $[0.0, 1.0]$. This guarantees responsive canvas reproduction regardless of client screen size or aspect ratio.

---

## 2. Application Entry Point

### `com.doodleduel.DoodleDuelApplication.java`
- **Role**: Main Spring Boot entry point.
- **Key Annotations**:
  - `@SpringBootApplication`: Combines `@Configuration`, `@EnableAutoConfiguration`, and `@ComponentScan`.
- **Functionality**:
  - Contains `public static void main(String[] args)`, invoking `SpringApplication.run(DoodleDuelApplication.class, args)`.
  - Boots the embedded Tomcat container (default port `8080`), triggers Flyway migrations, registers Spring Data JPA repositories, and initializes the STOMP message broker.

---

## 3. Configuration Layer (`com.doodleduel.config`)

### `WebSecurityConfig.java`
- **Role**: Central Spring Security 6 configuration for stateless REST and WebSocket communication.
- **Key Annotations**: `@Configuration`, `@EnableWebSecurity`, `@EnableMethodSecurity`.
- **Key Beans & Responsibilities**:
  - `SecurityFilterChain`: Configures HTTP security with `SessionCreationPolicy.STATELESS`.
  - **PermitAll Endpoints**: `/api/v1/auth/**`, `/ws/**`, `/error`, `/actuator/**`, `/v3/api-docs/**`, `/swagger-ui/**`.
  - **Authenticated Endpoints**: All other endpoints require valid Bearer JWT.
  - `JwtAuthenticationFilter`: Injected before `UsernamePasswordAuthenticationFilter` to validate Bearer tokens on REST requests.
  - `CorsConfigurationSource`: Configures CORS with permitted HTTP verbs (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`) and wildcard origin patterns for development.
  - `PasswordEncoder`: Registers `BCryptPasswordEncoder` for hashing user passwords.

### `WebSocketConfig.java`
- **Role**: STOMP over WebSocket broker configuration.
- **Key Annotations**: `@Configuration`, `@EnableWebSocketMessageBroker`.
- **Key Responsibilities**:
  - `registerStompEndpoints(StompEndpointRegistry)`: Registers `/ws` endpoint with CORS enabled (`setAllowedOriginPatterns("*")`).
  - `configureMessageBroker(MessageBrokerRegistry)`:
    - In-memory message broker enabled for destination prefixes: `/topic` (broadcasts), `/queue` (directed queues), and `/user` (private per-user messaging).
    - Application destination prefix: `/app` (routes client STOMP messages to `@MessageMapping` handlers).
    - User destination prefix: `/user` (enables `convertAndSendToUser()`).
  - `configureClientInboundChannel(ChannelRegistration)`: Adds `JwtChannelInterceptor` to authenticate incoming STOMP `CONNECT` frames.

### `OpenApiConfig.java`
- **Role**: OpenAPI 3 / Swagger metadata and security specification.
- **Key Annotations**: `@Configuration`.
- **Key Responsibilities**:
  - Defines the `OpenAPI` metadata (Title: *"Doodle Duel API"*, Version: *"1.0.0"*, description, license).
  - Configures the `bearerAuth` security scheme so developers can authenticate with JWT tokens directly inside the Swagger UI (`/swagger-ui/index.html`).

---

## 4. Security & Authentication (`com.doodleduel.security` & `com.doodleduel.auth`)

### `security/UserPrincipal.java`
- **Role**: Spring Security `UserDetails` implementation representing an authenticated user.
- **Fields**: `UUID id`, `String username`, `String passwordHash`, `boolean isGuest`, `Collection<? extends GrantedAuthority> authorities`.
- **Methods**: Implements Spring Security contract (`getUsername()`, `getPassword()`, `isAccountNonExpired()`, etc.). Allows controllers to inject `@AuthenticationPrincipal UserPrincipal principal`.

### `security/JwtTokenProvider.java`
- **Role**: Cryptographic generation and validation of JSON Web Tokens.
- **Library**: JJWT (`io.jsonwebtoken` 0.12.6).
- **Key Methods**:
  - `generateToken(User user)`: Signs an HMAC-SHA256 JWT containing `sub` (userId), `username`, `displayName`, `isGuest`, issued timestamp, and expiration.
  - `getUserIdFromToken(String token)`: Parses claims and extracts the user's `UUID`.
  - `validateToken(String token)`: Verifies signature validity, structure, and expiration; logs warnings for expired or malformed tokens without throwing unhandled exceptions.

### `security/JwtAuthenticationFilter.java`
- **Role**: `OncePerRequestFilter` inspecting HTTP `Authorization: Bearer <token>` headers on REST requests.
- **Workflow**:
  1. Extracts token from `Authorization` header.
  2. Validates token via `JwtTokenProvider`.
  3. Resolves user from `UserRepository`.
  4. Builds a `UsernamePasswordAuthenticationToken` and sets it in `SecurityContextHolder`.

### `security/JwtChannelInterceptor.java`
- **Role**: `ChannelInterceptor` intercepting STOMP WebSocket frames during the `CONNECT` phase.
- **Workflow**:
  1. Listens for `StompCommand.CONNECT`.
  2. Reads native header `Authorization` or `token`.
  3. Validates JWT and populates `accessor.setUser(authentication)` so that WebSocket sessions have an authenticated `Principal` for role enforcement and targeted `/user/queue/...` messaging.

---

### `auth/AuthController.java`
- **Role**: REST Controller exposed at `/api/v1/auth`.
- **Endpoints**:
  - `POST /guest`: Calls `authService.loginAsGuest()`.
  - `POST /register`: Validates `@Valid RegisterRequest` and creates persistent account.
  - `POST /login`: Validates credentials via `AuthenticationManager` and issues JWT.

### `auth/AuthService.java`
- **Role**: Authentication business logic.
- **Key Methods**:
  - `loginAsGuest(GuestLoginRequest request)`: Generates a persistent guest user record with a randomized handle (`guest_1234_abcd`), default avatar, and issues a JWT token.
  - `register(RegisterRequest request)`: Validates username uniqueness, hashes password with BCrypt, saves `User`, and returns `AuthResponse`.
  - `login(LoginRequest request)`: Authenticates against `AuthenticationManager`, retrieves user record, and returns `AuthResponse`.

### `auth/dto/*`
- `GuestLoginRequest.java`: DTO with optional custom `displayName` and `avatarUrl`.
- `RegisterRequest.java`: DTO with `@NotBlank` username, password (min 6 chars), and display name.
- `LoginRequest.java`: DTO with `@NotBlank` username and password.
- `AuthResponse.java`: Unified DTO containing JWT `token`, `tokenType: "Bearer"`, user ID, username, display name, level, XP, coins, and streak.

---

## 5. Common Utilities & Error Handling (`com.doodleduel.common`)

### `common/response/ApiResponse.java`
- **Role**: Standardized JSON envelope returned across all REST endpoints.
- **Fields**:
  - `boolean success`: Indicates operation outcome.
  - `String message`: Descriptive status message.
  - `T data`: Payload object.
  - `Instant timestamp`: Server timestamp.
- **Static Factories**: `ApiResponse.ok(data)`, `ApiResponse.ok(message, data)`, `ApiResponse.error(message)`.

### `common/exception/*`
- `AppException.java`: Base runtime exception.
- `BadRequestException.java`: Thrown for invalid operations (e.g., room full, already started, invalid state). Maps to HTTP 400.
- `ResourceNotFoundException.java`: Thrown when an entity (Room, User, Match) is not found. Maps to HTTP 404.
- `UnauthorizedException.java`: Thrown when a player performs an action without proper authorization (e.g., non-host starts game, non-drawer attempts to draw). Maps to HTTP 403.

### `common/exception/GlobalExceptionHandler.java`
- **Role**: `@RestControllerAdvice` providing centralized exception translation.
- **Handlers**:
  - `handleBadRequestException`: Returns HTTP 400 with `ApiResponse.error()`.
  - `handleResourceNotFoundException`: Returns HTTP 404.
  - `handleUnauthorizedException`: Returns HTTP 403.
  - `handleMethodArgumentNotValidException`: Captures Bean Validation errors and returns field-level error messages.
  - `handleGenericException`: Catches unexpected exceptions, logs stack trace, and returns HTTP 500 without leaking sensitive internals.

---

## 6. User & Career Management (`com.doodleduel.users`)

### `users/User.java`
- **Role**: JPA Entity representing a player.
- **Table**: `users`.
- **Fields**:
  - `UUID id`: Primary key.
  - `String username`: Unique handle (e.g. `guest_4821_fa23` or registered username).
  - `String displayName`: Screen name shown in lobbies and leaderboards.
  - `String passwordHash`: BCrypt hash (null for guest accounts).
  - `boolean isGuest`: Flag distinguishing guest sessions from registered accounts.
  - `String avatarUrl`: Profile avatar reference.
  - `int level`, `int xp`, `int coins`, `int streak`: Progression attributes.
  - `int gamesPlayed`, `int gamesWon`, `int bestScore`, `int correctGuesses`, `int drawingsCompleted`: Career statistics.
  - `String accountStatus`: `ACTIVE`, `SUSPENDED`, etc.
  - `Instant createdAt`: Account creation timestamp.

### `users/UserRepository.java`
- **Role**: Spring Data JPA repository.
- **Custom Queries**:
  - `findByUsername(String username)`: Used by authentication and user resolution.
  - `existsByUsername(String username)`: Validates username availability during registration.
  - `findTopByXp(Pageable pageable)`: Returns top players ordered by lifetime XP for all-time leaderboard.
  - `findTopByBestScore(Pageable pageable)`: Returns top players ordered by match best score for weekly leaderboard.

### `users/UserService.java`
- **Role**: User profile management.
- **Methods**:
  - `getUserProfile(UUID userId)`: Retrieves profile details.
  - `updateUserProfile(UUID userId, UpdateUserRequest request)`: Updates display name or avatar URL.
  - `getUserStats(UUID userId)`: Aggregates games played, win rate percentage, correct guesses, and high scores.

### `users/UserController.java`
- **Role**: REST Controller at `/api/v1/users`.
- **Endpoints**:
  - `GET /me`: Fetches profile of currently authenticated user.
  - `PATCH /me`: Updates profile details.
  - `GET /me/stats`: Fetches career game statistics.
  - `GET /me/matches`: Returns paginated match history for current user.

### `users/dto/*`
- `UserResponse.java`: Sanitized DTO exposing public user attributes without password hashes.
- `UpdateUserRequest.java`: DTO containing mutable profile fields.
- `UserStatsResponse.java`: DTO presenting calculated statistics and career achievements.

---

## 7. Room & Lobby Management (`com.doodleduel.rooms`)

### `rooms/GameRoom.java`
- **Role**: JPA Entity representing a multiplayer room.
- **Table**: `game_rooms`.
- **Fields**:
  - `UUID id`: Room ID.
  - `String roomCode`: Unique 6-character room code (e.g. `DUEL-9921`) generated for quick joining.
  - `String name`: Room title (e.g. *"Doodle Masters"*).
  - `User host`: Reference to room creator.
  - `String visibility`: `PUBLIC` (discoverable) or `PRIVATE` (code-only).
  - `String status`: `WAITING`, `IN_PROGRESS`, `FINISHED`.
  - `int maxPlayers`: Player capacity (2 to 16).
  - `int totalRounds`: Rounds per match (1 to 10).
  - `int drawTimeSeconds`: Turn duration (20 to 180 seconds).
  - `String difficulty`: `EASY`, `MEDIUM`, `HARD`.
  - `String category`: `GENERAL`, `ANIMALS`, `FOOD`, `OBJECTS`.
  - `Instant createdAt`, `Instant expiresAt`: Lifecycle timestamps.

### `rooms/RoomMembership.java`
- **Role**: JPA Entity mapping players to rooms.
- **Table**: `room_memberships`.
- **Unique Constraint**: `(room_id, user_id)`.
- **Fields**:
  - `UUID id`: Primary key.
  - `GameRoom room`: Target room.
  - `User user`: Participant.
  - `String role`: `HOST` or `PLAYER`.
  - `boolean ready`: Ready status flag for non-host players.
  - `String connectionStatus`: `CONNECTED` or `DISCONNECTED`.
  - `Instant joinedAt`: Timestamp of joining.

### `rooms/GameRoomRepository.java` & `RoomMembershipRepository.java`
- **GameRoomRepository**:
  - `findByRoomCode(String roomCode)`: Finds room by case-insensitive code.
  - `findByVisibilityAndStatusOrderByCreatedAtDesc(...)`: Finds public joinable rooms for discovery feed.
- **RoomMembershipRepository**:
  - `findMembersWithUserByRoomId(UUID roomId)`: Eagerly fetches room members and associated `User` entities with `JOIN FETCH` to eliminate N+1 queries.
  - `countByRoomId(UUID roomId)`: Fast player count check.
  - `findByRoomIdAndUserId(UUID roomId, UUID userId)`: Resolves a player's membership.

### `rooms/RoomService.java`
- **Role**: Room creation, lifecycle, and lobby coordination.
- **Key Methods**:
  - `createRoom(UUID hostId, CreateRoomRequest request)`: Generates room code, creates `GameRoom`, creates host `RoomMembership` (marked ready by default), and broadcasts creation.
  - `joinRoomByCode(UUID userId, String roomCode)`: Validates room state (`WAITING`), verifies player limit, adds player, and broadcasts `PLAYER_JOINED` via STOMP (`/topic/rooms/{roomId}/lobby`).
  - `toggleReady(UUID roomId, UUID userId)`: Toggles readiness flag and broadcasts updated roster.
  - `leaveRoom(UUID roomId, UUID userId)`: Handles player departure. If the host leaves, automatically reassigns host role to the next oldest connected player; if empty, deletes or closes room.
  - `updateRoomSettings(UUID roomId, UUID hostId, ...)`: Updates rounds, time, and category before match begins.

### `rooms/RoomController.java`
- **Role**: REST Controller at `/api/v1/rooms`.
- **Endpoints**:
  - `POST /`: Create room.
  - `POST /join`: Join room with code.
  - `GET /{roomId}`: Get room details & roster.
  - `PATCH /{roomId}/ready`: Toggle ready state.
  - `PATCH /{roomId}/settings`: Host updates settings.
  - `POST /{roomId}/leave`: Leave room.
  - `POST /{roomId}/start`: Host initiates match.
  - `GET /public`: Discover public joinable rooms.

---

## 8. Drawing Subsystem (`com.doodleduel.drawing`)

### `drawing/DrawingPoint.java`
- **Role**: Vector coordinate data point.
- **Fields**: `double x`, `double y` (normalized between $0.0$ and $1.0$).
- **Constructor & Validation**: Clamps coordinates to $[0.0, 1.0]$ to guard against malicious or out-of-bounds inputs.

### `drawing/DrawingStroke.java`
- **Role**: Vector stroke model representing a continuous brush movement.
- **Fields**:
  - `String strokeId`: Unique client-generated UUID for the stroke.
  - `String color`: Hex color string (e.g. `#FF5733`).
  - `double brushSize`: Brush radius in logical pixels.
  - `String tool`: `PEN`, `ERASER`.
  - `List<DrawingPoint> points`: Batched vector points.

### `drawing/DrawingStateService.java`
- **Role**: In-memory canvas state manager per room.
- **Data Structure**: `ConcurrentHashMap<UUID, CopyOnWriteArrayList<DrawingStroke>> roomCanvases`.
- **Key Methods**:
  - `recordStroke(UUID roomId, DrawingStroke strokeChunk)`: Appends points to existing stroke or appends new stroke chunk.
  - `undoLastStroke(UUID roomId)`: Removes the most recent stroke from the canvas history.
  - `clearCanvas(UUID roomId)`: Clears all strokes for the room.
  - `getCanvasSnapshot(UUID roomId)`: Returns an immutable snapshot of all strokes for synchronizing reconnecting clients.
  - `resetCanvas(UUID roomId)`: Cleans up canvas buffer when moving to a new round.

---

## 9. Scoring & Word Bank Engine (`com.doodleduel.scoring`)

### `scoring/WordPrompt.java`
- **Role**: Immutable model representing a drawing challenge.
- **Fields**: `String word`, `String hint`, `String category`, `String difficulty`.

### `scoring/WordBankService.java`
- **Role**: In-memory prompt library containing 40+ categorized words across `GENERAL`, `ANIMALS`, `FOOD`, and `OBJECTS`.
- **Prompt Examples**:
  - Animals: `Dolphin` ("Playful marine mammal"), `Octopus` ("Eight-armed ocean creature"), `Giraffe` ("Tallest mammal with long neck").
  - Food: `Pizza` ("Cheesy Italian pie with toppings"), `Taco` ("Folded Mexican tortilla with filling"), `Sushi` ("Japanese vinegared rice roll").
- **Methods**:
  - `getRandomPrompt(String category, String difficulty)`: Filters prompts by category and difficulty, falling back gracefully if no match exists.

### `scoring/ScoreCalculationService.java`
- **Role**: Server-authoritative score and text matching engine.
- **Key Methods**:
  - `normalize(String text)`: Lowercases, removes punctuation, replaces hyphens with spaces, and trims whitespace.
  - `isExactMatch(String guess, String secret)`: Returns `true` if normalized strings match exactly.
  - `isCloseMatch(String guess, String secret)`: Uses Levenshtein distance $\le 2$ or substring checking to flag near-miss guesses without awarding points.
  - `calculateGuesserScore(long remainingSec, int totalSec, boolean isFirstCorrect)`:
    - Base score: $200$ pts.
    - Speed bonus: Up to $100$ pts proportional to remaining time fraction $\frac{\text{remainingSec}}{\text{totalSec}}$.
    - First correct bonus: $+100$ pts.
  - `calculateDrawerScore(int correctGuessCount)`:
    - $50$ pts per correct guesser, capped at $250$ pts.

---

## 10. Game Engine & Match Persistence (`com.doodleduel.games` & `.engine`)

### Relational Entities:
1. **`GameMatch.java`**: Represents a played match. Contains `UUID id`, `GameRoom room`, `String status` (`IN_PROGRESS`, `COMPLETED`), `int currentRound`, `Instant startedAt`, `Instant endedAt`.
2. **`GameRound.java`**: Represents a single turn. Contains `UUID id`, `GameMatch match`, `int roundNumber`, `User drawer`, `String secretWord`, `String category`, `String hint`, `String status` (`DRAWING`, `ENDED`), timestamps.
3. **`Guess.java`**: Represents a submitted guess. Contains `UUID id`, `GameRound round`, `User player`, `String submittedText`, `boolean isCorrect`, `int pointsAwarded`, `Instant submittedAt`.
4. **`MatchPlayerResult.java`**: Represents final player standings. Contains `UUID id`, `GameMatch match`, `User player`, `int finalScore`, `int rankPosition`, `int correctGuesses`, `int roundsDrawn`, `int xpEarned`.

### Repositories:
- `GameMatchRepository.java`, `GameRoundRepository.java`, `GuessRepository.java`, `MatchPlayerResultRepository.java`.

### `games/engine/GameEngineService.java`
- **Role**: Core game controller managing match lifecycles, turn timers, and real-time event dispatching.
- **Key State Container**: `ActiveMatchState`:
  - In-memory tracker holding `matchId`, `playerOrder`, `playerScores`, `currentDrawerId`, `currentSecretWord`, `roundCorrectGuessers`, and `ScheduledFuture<?> roundTimerFuture`.
- **Key Methods**:
  - `startMatch(UUID roomId, UUID requesterId)`:
    - Validates host authority, room status (`WAITING`), and minimum player count ($\ge 2$).
    - Updates room status to `IN_PROGRESS`, persists `GameMatch`, initializes `ActiveMatchState`.
    - Broadcasts `MATCH_STARTED` over `/topic/rooms/{roomId}/game`.
    - Schedules `startNextRound(roomId)` after a 2-second countdown.
  - `startNextRound(UUID roomId)`:
    - Increments round index. If `currentRound > totalRounds`, delegates to `finishMatch(roomId)`.
    - Selects drawer using round-robin index: $(round - 1) \pmod{\text{players}}$.
    - Selects `WordPrompt` from `WordBankService`.
    - Resets canvas state in `DrawingStateService`.
    - Saves `GameRound` to database.
    - **Delivers secret word privately to drawer** via `messagingTemplate.convertAndSendToUser(drawerId, "/queue/notifications", event)`.
    - **Broadcasts masked letter blanks** (`_ _ _ _`) to room via `/topic/rooms/{roomId}/game`.
    - Schedules round timeout with `scheduler.schedule(() -> endRound(roomId), duration, TimeUnit.SECONDS)`.
  - `handleDrawingPoints(UUID roomId, UUID senderId, DrawingStroke strokeChunk)`:
    - Rejects draw events from anyone other than the active drawer.
    - Records stroke in `DrawingStateService` and broadcasts over `/topic/rooms/{roomId}/drawing`.
  - `handleDrawingUndo(...)` & `handleDrawingClear(...)`:
    - Validates drawer authorization and broadcasts canvas modification events.
  - `processGuess(UUID roomId, UUID playerId, String guessText)`:
    - Rejects guesses from the active drawer.
    - Rejects guesses from players who already answered correctly in the current round.
    - Evaluates exact match:
      - Awards points (base + speed + first-guess bonus).
      - Persists `Guess` to database.
      - Broadcasts `CORRECT_GUESS` celebration event.
      - If all non-drawers have guessed correctly, cancels remaining round timer and triggers `endRound` early!
    - Evaluates close match: broadcasts `GUESS_FEED` with `isClose: true`.
    - Evaluates wrong guess: broadcasts `GUESS_FEED` with `isClose: false`.
  - `endRound(UUID roomId)`:
    - Awards drawer bonus points based on correct guesser count.
    - Updates `GameRound` in database to `ENDED`.
    - Broadcasts `ROUND_ENDED` revealing the secret word and scoreboard.
    - Schedules next round or match completion after a 6-second results break.
  - `finishMatch(UUID roomId)`:
    - Updates `GameMatch` to `COMPLETED`.
    - Sorts players by score, calculates rank and XP rewards.
    - Persists `MatchPlayerResult` for each participant.
    - Updates career statistics on each `User` (games played, wins, high scores, coins, XP).
    - Sets room status back to `WAITING` for rematches.
    - Broadcasts `MATCH_FINISHED` with final podium leaderboard.
  - `syncGameState(UUID roomId, UUID userId)`:
    - Supports reconnection by assembling phase, remaining seconds, current scores, full canvas stroke snapshot, and secret word (for drawer) or masked blanks (for guesser).

### `games/MatchService.java` & `MatchController.java`
- `MatchService`: Provides read operations for completed match details, scoreboards, and user match histories.
- `MatchController`: REST endpoints at `/api/v1/matches/{matchId}`, `/api/v1/matches/{matchId}/results`, and `/api/v1/matches/my-history`.

---

## 11. Real-Time WebSocket & STOMP Messaging (`com.doodleduel.websocket`)

### `websocket/GameEvent.java`
- **Role**: Unified event envelope for all real-time STOMP messages.
- **Fields**:
  - `String eventId`: Randomized UUID.
  - `String eventType`: E.g. `MATCH_STARTED`, `ROUND_START`, `DRAWING_POINTS`, `CORRECT_GUESS`, `ROUND_ENDED`, `MATCH_FINISHED`.
  - `UUID roomId`, `UUID matchId`, `Integer roundNumber`.
  - `UUID senderId`, `String senderName`.
  - `Instant serverTimestamp`: Authoritative server epoch timestamp.
  - `Object payload`: Typed event data.

### `websocket/GameWebSocketController.java`
- **Role**: Spring STOMP Controller handling incoming messages sent to `/app/rooms/{roomId}/*`.
- **Endpoints**:
  - `@MessageMapping("/rooms/{roomId}/ready")`: Toggles player readiness.
  - `@MessageMapping("/rooms/{roomId}/drawing")`: Receives vector stroke chunk and calls `GameEngineService.handleDrawingPoints`.
  - `@MessageMapping("/rooms/{roomId}/drawing/undo")`: Receives undo request.
  - `@MessageMapping("/rooms/{roomId}/drawing/clear")`: Receives clear canvas request.
  - `@MessageMapping("/rooms/{roomId}/guess")`: Receives guess string and calls `GameEngineService.processGuess`.
  - `@MessageMapping("/rooms/{roomId}/reaction")`: Receives emoji reaction string and broadcasts to room.
  - `@MessageMapping("/rooms/{roomId}/sync")`: Handles client reconnect sync request.

---

## 12. Leaderboard System (`com.doodleduel.leaderboard`)

### `leaderboard/LeaderboardService.java`
- **Role**: Queries and ranks top players.
- **Methods**:
  - `getLeaderboard(String period, int limit)`:
    - If `period.equalsIgnoreCase("weekly")`: Queries `userRepository.findTopByBestScore(limit)`.
    - If `period.equalsIgnoreCase("all-time")`: Queries `userRepository.findTopByXp(limit)`.
    - Maps entities to ranked `LeaderboardEntryResponse` DTOs.

### `leaderboard/LeaderboardController.java`
- **Role**: REST Controller at `/api/v1/leaderboard`.
- **Endpoint**:
  - `GET /api/v1/leaderboard?period=weekly` or `period=all-time`.

### `leaderboard/dto/LeaderboardEntryResponse.java`
- **Role**: DTO presenting player rank position, display name, avatar, level, score/XP, and games won.
