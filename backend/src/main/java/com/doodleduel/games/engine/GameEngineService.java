package com.doodleduel.games.engine;

import com.doodleduel.common.exception.BadRequestException;
import com.doodleduel.common.exception.ResourceNotFoundException;
import com.doodleduel.common.exception.UnauthorizedException;
import com.doodleduel.drawing.DrawingStateService;
import com.doodleduel.drawing.DrawingStroke;
import com.doodleduel.games.*;
import com.doodleduel.rooms.GameRoom;
import com.doodleduel.rooms.GameRoomRepository;
import com.doodleduel.rooms.RoomMembership;
import com.doodleduel.rooms.RoomMembershipRepository;
import com.doodleduel.scoring.ScoreCalculationService;
import com.doodleduel.scoring.WordBankService;
import com.doodleduel.scoring.WordPrompt;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import com.doodleduel.websocket.GameEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;

@Service
public class GameEngineService {

    private static final Logger log = LoggerFactory.getLogger(GameEngineService.class);

    private final GameRoomRepository roomRepository;
    private final RoomMembershipRepository membershipRepository;
    private final GameMatchRepository matchRepository;
    private final GameRoundRepository roundRepository;
    private final GuessRepository guessRepository;
    private final MatchPlayerResultRepository matchPlayerResultRepository;
    private final UserRepository userRepository;
    private final WordBankService wordBankService;
    private final ScoreCalculationService scoreService;
    private final DrawingStateService drawingService;
    private final SimpMessagingTemplate messagingTemplate;

    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(4);

    // In-memory active game states
    private final Map<UUID, ActiveMatchState> activeMatches = new ConcurrentHashMap<>();

    public GameEngineService(
            GameRoomRepository roomRepository,
            RoomMembershipRepository membershipRepository,
            GameMatchRepository matchRepository,
            GameRoundRepository roundRepository,
            GuessRepository guessRepository,
            MatchPlayerResultRepository matchPlayerResultRepository,
            UserRepository userRepository,
            WordBankService wordBankService,
            ScoreCalculationService scoreService,
            DrawingStateService drawingService,
            SimpMessagingTemplate messagingTemplate) {
        this.roomRepository = roomRepository;
        this.membershipRepository = membershipRepository;
        this.matchRepository = matchRepository;
        this.roundRepository = roundRepository;
        this.guessRepository = guessRepository;
        this.matchPlayerResultRepository = matchPlayerResultRepository;
        this.userRepository = userRepository;
        this.wordBankService = wordBankService;
        this.scoreService = scoreService;
        this.drawingService = drawingService;
        this.messagingTemplate = messagingTemplate;
    }

    public static class ActiveMatchState {
        public UUID matchId;
        public UUID roomId;
        public int currentRound = 0;
        public int totalRounds = 4;
        public int drawDurationSeconds = 60;
        public String category = "GENERAL";
        public String difficulty = "MEDIUM";
        public List<UUID> playerOrder = new ArrayList<>();
        public Map<UUID, Integer> playerScores = new ConcurrentHashMap<>();
        public Map<UUID, Integer> correctGuessesPerPlayer = new ConcurrentHashMap<>();
        public Map<UUID, Integer> roundsDrawnPerPlayer = new ConcurrentHashMap<>();

        // Current round data
        public UUID roundId;
        public UUID currentDrawerId;
        public String currentSecretWord;
        public String currentHint;
        public Instant roundStartTime;
        public Instant roundEndTime;
        public Set<UUID> roundCorrectGuessers = ConcurrentHashMap.newKeySet();
        public ScheduledFuture<?> roundTimerFuture;
        public boolean isRoundActive = false;
    }

    @Transactional
    public void startMatch(UUID roomId, UUID requesterId) {
        GameRoom room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Room", "id", roomId));

        if (!room.getHost().getId().equals(requesterId)) {
            throw new UnauthorizedException("Only the room host can start the game");
        }

        if (!"WAITING".equals(room.getStatus())) {
            throw new BadRequestException("Match is already in progress or finished");
        }

        List<RoomMembership> members = membershipRepository.findMembersWithUserByRoomId(roomId);
        if (members.size() < 2) {
            throw new BadRequestException("At least 2 players are required to start a duel");
        }

        // Mark room IN_PROGRESS
        room.setStatus("IN_PROGRESS");
        roomRepository.save(room);

        // Create GameMatch in DB
        GameMatch match = new GameMatch();
        match.setId(UUID.randomUUID());
        match.setRoom(room);
        match.setStatus("IN_PROGRESS");
        match.setCurrentRound(1);
        match.setStartedAt(Instant.now());
        match = matchRepository.save(match);

        // Setup in-memory state
        ActiveMatchState state = new ActiveMatchState();
        state.matchId = match.getId();
        state.roomId = roomId;
        state.totalRounds = room.getTotalRounds();
        state.drawDurationSeconds = room.getDrawTimeSeconds();
        state.category = room.getCategory();
        state.difficulty = room.getDifficulty();
        state.playerOrder = members.stream().map(m -> m.getUser().getId()).collect(Collectors.toList());

        for (UUID pId : state.playerOrder) {
            state.playerScores.put(pId, 0);
            state.correctGuessesPerPlayer.put(pId, 0);
            state.roundsDrawnPerPlayer.put(pId, 0);
        }

        activeMatches.put(roomId, state);

        log.info("Match {} started in room {} with {} players", match.getId(), roomId, state.playerOrder.size());

        // Broadcast MATCH_STARTED
        broadcastGameEvent(roomId, "MATCH_STARTED", Map.of(
                "matchId", match.getId(),
                "totalRounds", state.totalRounds,
                "players", members.stream().map(m -> Map.of(
                        "userId", m.getUser().getId(),
                        "username", m.getUser().getUsername(),
                        "displayName", m.getUser().getDisplayName(),
                        "avatarUrl", m.getUser().getAvatarUrl(),
                        "score", 0
                )).collect(Collectors.toList())
        ));

        // Start Round 1 after a brief 2-second countdown
        scheduler.schedule(() -> startNextRound(roomId), 2, TimeUnit.SECONDS);
    }

    public synchronized void startNextRound(UUID roomId) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null) return;

        state.currentRound++;
        if (state.currentRound > state.totalRounds) {
            finishMatch(roomId);
            return;
        }

        // Select drawer in round-robin fashion
        int drawerIndex = (state.currentRound - 1) % state.playerOrder.size();
        UUID drawerId = state.playerOrder.get(drawerIndex);
        state.currentDrawerId = drawerId;
        state.roundsDrawnPerPlayer.merge(drawerId, 1, Integer::sum);

        // Pick secret word
        WordPrompt prompt = wordBankService.getRandomPrompt(state.category, state.difficulty);
        state.currentSecretWord = prompt.getWord();
        state.currentHint = prompt.getHint();
        state.roundCorrectGuessers.clear();
        state.roundStartTime = Instant.now();
        state.roundEndTime = state.roundStartTime.plusSeconds(state.drawDurationSeconds);
        state.isRoundActive = true;

        // Reset canvas for new round
        drawingService.resetCanvas(roomId);

        // Save round to DB
        User drawer = userRepository.findById(drawerId).orElse(null);
        GameMatch match = matchRepository.findById(state.matchId).orElse(null);

        if (drawer != null && match != null) {
            GameRound round = new GameRound();
            round.setId(UUID.randomUUID());
            round.setMatch(match);
            round.setRoundNumber(state.currentRound);
            round.setDrawer(drawer);
            round.setSecretWord(state.currentSecretWord);
            round.setCategory(prompt.getCategory());
            round.setHint(prompt.getHint());
            round.setStatus("DRAWING");
            round.setStartedAt(state.roundStartTime);
            round = roundRepository.save(round);
            state.roundId = round.getId();
        }

        log.info("Starting round {}/{} in room {}. Drawer: {}, Word: {}",
                state.currentRound, state.totalRounds, roomId, drawer != null ? drawer.getUsername() : drawerId, state.currentSecretWord);

        // 1. Deliver private secret word prompt to drawer ONLY
        String drawerUsername = drawer != null ? drawer.getUsername() : "";
        GameEvent privatePromptEvent = new GameEvent(
                "SECRET_WORD_PROMPT",
                roomId,
                state.matchId,
                state.currentRound,
                drawerId,
                drawerUsername,
                Map.of(
                        "secretWord", state.currentSecretWord,
                        "hint", state.currentHint,
                        "category", prompt.getCategory(),
                        "durationSeconds", state.drawDurationSeconds
                )
        );
        messagingTemplate.convertAndSendToUser(drawerId.toString(), "/queue/notifications", privatePromptEvent);

        // 2. Deliver public round start event (word letters masked e.g. "Flying Pizza" -> 6, 5 letter counts)
        broadcastGameEvent(roomId, "ROUND_START", Map.of(
                "roundId", state.roundId != null ? state.roundId : UUID.randomUUID(),
                "roundNumber", state.currentRound,
                "totalRounds", state.totalRounds,
                "drawerId", drawerId,
                "drawerName", drawer != null ? drawer.getDisplayName() : "Unknown",
                "category", prompt.getCategory(),
                "letterBlanks", getMaskedLetterBlanks(state.currentSecretWord),
                "durationSeconds", state.drawDurationSeconds,
                "startEpochMs", state.roundStartTime.toEpochMilli(),
                "endEpochMs", state.roundEndTime.toEpochMilli()
        ));

        // Schedule timer to end round when duration expires
        if (state.roundTimerFuture != null) {
            state.roundTimerFuture.cancel(false);
        }
        state.roundTimerFuture = scheduler.schedule(() -> endRound(roomId), state.drawDurationSeconds, TimeUnit.SECONDS);
    }

    public synchronized void processGuess(UUID roomId, UUID playerId, String guessText) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null || !state.isRoundActive) {
            return;
        }

        if (state.currentDrawerId.equals(playerId)) {
            // Drawers cannot guess their own drawing!
            return;
        }

        User player = userRepository.findById(playerId).orElse(null);
        String playerName = player != null ? player.getDisplayName() : "Player";

        if (state.roundCorrectGuessers.contains(playerId)) {
            // Already guessed correctly this round
            return;
        }

        long remainingSec = Math.max(0, (state.roundEndTime.toEpochMilli() - System.currentTimeMillis()) / 1000);

        if (scoreService.isExactMatch(guessText, state.currentSecretWord)) {
            // Correct guess!
            boolean isFirst = state.roundCorrectGuessers.isEmpty();
            state.roundCorrectGuessers.add(playerId);
            int points = scoreService.calculateGuesserScore(remainingSec, state.drawDurationSeconds, isFirst);

            state.playerScores.merge(playerId, points, Integer::sum);
            state.correctGuessesPerPlayer.merge(playerId, 1, Integer::sum);

            // Record guess in DB
            if (state.roundId != null && player != null) {
                GameRound round = roundRepository.findById(state.roundId).orElse(null);
                if (round != null) {
                    Guess guess = new Guess();
                    guess.setId(UUID.randomUUID());
                    guess.setRound(round);
                    guess.setPlayer(player);
                    guess.setSubmittedText(guessText);
                    guess.setCorrect(true);
                    guess.setPointsAwarded(points);
                    guess.setSubmittedAt(Instant.now());
                    guessRepository.save(guess);
                }
            }

            // Broadcast celebration to room
            broadcastScoreEvent(roomId, "CORRECT_GUESS", Map.of(
                    "playerId", playerId,
                    "playerName", playerName,
                    "pointsEarned", points,
                    "totalScore", state.playerScores.get(playerId),
                    "isFirst", isFirst,
                    "message", playerName + " guessed the secret word!"
            ));

            // Check if all non-drawers have guessed correctly -> early round finish!
            long totalGuessers = state.playerOrder.size() - 1;
            if (state.roundCorrectGuessers.size() >= totalGuessers) {
                log.info("All players guessed correctly in room {}! Ending round early.", roomId);
                if (state.roundTimerFuture != null) {
                    state.roundTimerFuture.cancel(false);
                }
                scheduler.schedule(() -> endRound(roomId), 1, TimeUnit.SECONDS);
            }
        } else if (scoreService.isCloseMatch(guessText, state.currentSecretWord)) {
            // Close guess!
            broadcastScoreEvent(roomId, "GUESS_FEED", Map.of(
                    "playerId", playerId,
                    "playerName", playerName,
                    "text", guessText,
                    "isClose", true
            ));
        } else {
            // Regular wrong guess
            broadcastScoreEvent(roomId, "GUESS_FEED", Map.of(
                    "playerId", playerId,
                    "playerName", playerName,
                    "text", guessText,
                    "isClose", false
            ));
        }
    }

    public synchronized void endRound(UUID roomId) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null || !state.isRoundActive) {
            return;
        }

        state.isRoundActive = false;
        if (state.roundTimerFuture != null) {
            state.roundTimerFuture.cancel(false);
        }

        // Award drawer bonus
        int drawerPoints = scoreService.calculateDrawerScore(state.roundCorrectGuessers.size());
        state.playerScores.merge(state.currentDrawerId, drawerPoints, Integer::sum);

        // Update GameRound in DB
        if (state.roundId != null) {
            roundRepository.findById(state.roundId).ifPresent(r -> {
                r.setStatus("ENDED");
                r.setEndedAt(Instant.now());
                roundRepository.save(r);
            });
        }

        User drawer = userRepository.findById(state.currentDrawerId).orElse(null);
        String drawerName = drawer != null ? drawer.getDisplayName() : "Drawer";

        log.info("Round {} ended in room {}. Secret word: {}, Drawer earned: {}",
                state.currentRound, roomId, state.currentSecretWord, drawerPoints);

        // Broadcast ROUND_ENDED with secret word reveal and updated scoreboard
        broadcastGameEvent(roomId, "ROUND_ENDED", Map.of(
                "roundNumber", state.currentRound,
                "secretWord", state.currentSecretWord,
                "drawerId", state.currentDrawerId,
                "drawerName", drawerName,
                "drawerPoints", drawerPoints,
                "correctGuessersCount", state.roundCorrectGuessers.size(),
                "scores", getScoresSummary(state)
        ));

        // Schedule next round or match finish after 6-second results break
        if (state.currentRound < state.totalRounds) {
            scheduler.schedule(() -> startNextRound(roomId), 6, TimeUnit.SECONDS);
        } else {
            scheduler.schedule(() -> finishMatch(roomId), 6, TimeUnit.SECONDS);
        }
    }

    @Transactional
    public synchronized void finishMatch(UUID roomId) {
        ActiveMatchState state = activeMatches.remove(roomId);
        if (state == null) return;

        if (state.roundTimerFuture != null) {
            state.roundTimerFuture.cancel(false);
        }

        // Update GameMatch status
        GameMatch match = matchRepository.findById(state.matchId).orElse(null);
        if (match != null) {
            match.setStatus("COMPLETED");
            match.setEndedAt(Instant.now());
            matchRepository.save(match);
        }

        // Rank players by score
        List<Map.Entry<UUID, Integer>> sortedPlayers = state.playerScores.entrySet().stream()
                .sorted(Map.Entry.<UUID, Integer>comparingByValue().reversed())
                .toList();

        List<Map<String, Object>> leaderboard = new ArrayList<>();
        int rank = 1;

        for (Map.Entry<UUID, Integer> entry : sortedPlayers) {
            UUID pId = entry.getKey();
            int finalScore = entry.getValue();
            int correctGuesses = state.correctGuessesPerPlayer.getOrDefault(pId, 0);
            int roundsDrawn = state.roundsDrawnPerPlayer.getOrDefault(pId, 0);
            int xpEarned = (finalScore / 2) + (rank == 1 ? 250 : (rank == 2 ? 150 : 75));

            User user = userRepository.findById(pId).orElse(null);
            if (user != null && match != null) {
                // Save MatchPlayerResult
                MatchPlayerResult result = new MatchPlayerResult();
                result.setId(UUID.randomUUID());
                result.setMatch(match);
                result.setPlayer(user);
                result.setFinalScore(finalScore);
                result.setRankPosition(rank);
                result.setCorrectGuesses(correctGuesses);
                result.setRoundsDrawn(roundsDrawn);
                result.setXpEarned(xpEarned);
                matchPlayerResultRepository.save(result);

                // Update career stats
                user.setGamesPlayed(user.getGamesPlayed() + 1);
                if (rank == 1) {
                    user.setGamesWon(user.getGamesWon() + 1);
                }
                if (finalScore > user.getBestScore()) {
                    user.setBestScore(finalScore);
                }
                user.setCorrectGuesses(user.getCorrectGuesses() + correctGuesses);
                user.setDrawingsCompleted(user.getDrawingsCompleted() + roundsDrawn);
                user.setXp(user.getXp() + xpEarned);
                user.setLevel(1 + (user.getXp() / 500));
                user.setCoins(user.getCoins() + (finalScore / 10));
                userRepository.save(user);

                leaderboard.add(Map.of(
                        "userId", user.getId(),
                        "username", user.getUsername(),
                        "displayName", user.getDisplayName(),
                        "avatarUrl", user.getAvatarUrl(),
                        "finalScore", finalScore,
                        "rank", rank,
                        "xpEarned", xpEarned
                ));
            }
            rank++;
        }

        // Return room to WAITING state for rematch
        roomRepository.findById(roomId).ifPresent(r -> {
            r.setStatus("WAITING");
            roomRepository.save(r);
        });

        log.info("Match {} completed for room {}. Winner: {}",
                state.matchId, roomId, !leaderboard.isEmpty() ? leaderboard.get(0).get("displayName") : "None");

        broadcastGameEvent(roomId, "MATCH_FINISHED", Map.of(
                "matchId", state.matchId,
                "leaderboard", leaderboard,
                "winner", !leaderboard.isEmpty() ? leaderboard.get(0) : Map.of()
        ));
    }

    public void handleDrawingPoints(UUID roomId, UUID senderId, DrawingStroke strokeChunk) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null || !state.isRoundActive) {
            return;
        }

        // Only active drawer may draw!
        if (!state.currentDrawerId.equals(senderId)) {
            log.warn("Unauthorized draw attempt by user {} in room {}", senderId, roomId);
            return;
        }

        drawingService.recordStroke(roomId, strokeChunk);

        // Broadcast to all room subscribers
        messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/drawing", new GameEvent(
                "DRAWING_POINTS",
                roomId,
                state.matchId,
                state.currentRound,
                senderId,
                null,
                strokeChunk
        ));
    }

    public void handleDrawingUndo(UUID roomId, UUID senderId) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null || !state.isRoundActive || !state.currentDrawerId.equals(senderId)) {
            return;
        }

        boolean undone = drawingService.undoLastStroke(roomId);
        if (undone) {
            messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/drawing", new GameEvent(
                    "DRAWING_UNDO",
                    roomId,
                    state.matchId,
                    state.currentRound,
                    senderId,
                    null,
                    Map.of("undone", true)
            ));
        }
    }

    public void handleDrawingClear(UUID roomId, UUID senderId) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null || !state.isRoundActive || !state.currentDrawerId.equals(senderId)) {
            return;
        }

        drawingService.clearCanvas(roomId);
        messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/drawing", new GameEvent(
                "DRAWING_CLEAR",
                roomId,
                state.matchId,
                state.currentRound,
                senderId,
                null,
                Map.of("cleared", true)
        ));
    }

    public void handleReaction(UUID roomId, UUID senderId, String emoji) {
        User player = userRepository.findById(senderId).orElse(null);
        String name = player != null ? player.getDisplayName() : "Player";

        messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/game", new GameEvent(
                "REACTION",
                roomId,
                null,
                null,
                senderId,
                name,
                Map.of("emoji", emoji, "playerName", name)
        ));
    }

    public void syncGameState(UUID roomId, UUID userId) {
        ActiveMatchState state = activeMatches.get(roomId);
        if (state == null) {
            // Room is in lobby
            messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/notifications", new GameEvent(
                    "SYNC_STATE",
                    roomId,
                    null,
                    null,
                    null,
                    "System",
                    Map.of("phase", "LOBBY")
            ));
            return;
        }

        boolean isDrawer = state.currentDrawerId != null && state.currentDrawerId.equals(userId);
        long remainingSec = state.roundEndTime != null
                ? Math.max(0, (state.roundEndTime.toEpochMilli() - System.currentTimeMillis()) / 1000)
                : 0;

        List<DrawingStroke> canvasSnapshot = drawingService.getCanvasSnapshot(roomId);

        Map<String, Object> syncPayload = new HashMap<>();
        syncPayload.put("phase", state.isRoundActive ? "ROUND_ACTIVE" : "ROUND_TRANSITION");
        syncPayload.put("matchId", state.matchId);
        syncPayload.put("roundNumber", state.currentRound);
        syncPayload.put("totalRounds", state.totalRounds);
        syncPayload.put("drawerId", state.currentDrawerId);
        syncPayload.put("remainingSeconds", remainingSec);
        syncPayload.put("scores", getScoresSummary(state));
        syncPayload.put("canvasStrokes", canvasSnapshot);

        if (isDrawer) {
            syncPayload.put("secretWord", state.currentSecretWord);
            syncPayload.put("hint", state.currentHint);
        } else {
            syncPayload.put("letterBlanks", getMaskedLetterBlanks(state.currentSecretWord));
        }

        messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/notifications", new GameEvent(
                "SYNC_STATE",
                roomId,
                state.matchId,
                state.currentRound,
                null,
                "System",
                syncPayload
        ));
    }

    private String getMaskedLetterBlanks(String word) {
        if (word == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : word.toCharArray()) {
            if (Character.isWhitespace(c)) {
                sb.append("   ");
            } else if (Character.isLetterOrDigit(c)) {
                sb.append("_ ");
            } else {
                sb.append(c).append(" ");
            }
        }
        return sb.toString().trim();
    }

    private List<Map<String, Object>> getScoresSummary(ActiveMatchState state) {
        return state.playerScores.entrySet().stream()
                .map(e -> {
                    User u = userRepository.findById(e.getKey()).orElse(null);
                    return Map.<String, Object>of(
                            "userId", e.getKey(),
                            "displayName", u != null ? u.getDisplayName() : "Player",
                            "avatarUrl", u != null && u.getAvatarUrl() != null ? u.getAvatarUrl() : "",
                            "score", e.getValue()
                    );
                })
                .collect(Collectors.toList());
    }

    private void broadcastGameEvent(UUID roomId, String type, Object payload) {
        GameEvent event = new GameEvent(type, roomId, null, null, null, "GameEngine", payload);
        messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/game", event);
    }

    private void broadcastScoreEvent(UUID roomId, String type, Object payload) {
        GameEvent event = new GameEvent(type, roomId, null, null, null, "ScoreEngine", payload);
        messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/scores", event);
    }

    public ActiveMatchState getActiveMatch(UUID roomId) {
        return activeMatches.get(roomId);
    }
}

