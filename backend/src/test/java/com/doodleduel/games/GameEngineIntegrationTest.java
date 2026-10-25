package com.doodleduel.games;

import com.doodleduel.auth.AuthService;
import com.doodleduel.auth.dto.AuthResponse;
import com.doodleduel.auth.dto.GuestLoginRequest;
import com.doodleduel.common.exception.UnauthorizedException;
import com.doodleduel.drawing.DrawingPoint;
import com.doodleduel.drawing.DrawingStateService;
import com.doodleduel.drawing.DrawingStroke;
import com.doodleduel.games.engine.GameEngineService;
import com.doodleduel.leaderboard.LeaderboardService;
import com.doodleduel.leaderboard.dto.LeaderboardEntryResponse;
import com.doodleduel.rooms.GameRoom;
import com.doodleduel.rooms.GameRoomRepository;
import com.doodleduel.rooms.RoomService;
import com.doodleduel.rooms.dto.CreateRoomRequest;
import com.doodleduel.rooms.dto.RoomResponse;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
public class GameEngineIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private RoomService roomService;

    @Autowired
    private GameEngineService gameEngineService;

    @Autowired
    private DrawingStateService drawingStateService;

    @Autowired
    private LeaderboardService leaderboardService;

    @Autowired
    private GameRoomRepository roomRepository;

    @Autowired
    private MatchPlayerResultRepository matchPlayerResultRepository;

    @Autowired
    private UserRepository userRepository;

    @Test
    @DisplayName("End-to-End Game Flow: 2-player duel, drawing authority, guess scoring, and match finalization")
    void testFullMultiplayerDuelWorkflow() {
        // 1. Player A, Player B, and Player C authenticate as guests
        GuestLoginRequest reqA = new GuestLoginRequest();
        reqA.setDisplayName("PlayerAlice");
        AuthResponse authA = authService.loginAsGuest(reqA);

        GuestLoginRequest reqB = new GuestLoginRequest();
        reqB.setDisplayName("PlayerBob");
        AuthResponse authB = authService.loginAsGuest(reqB);

        GuestLoginRequest reqC = new GuestLoginRequest();
        reqC.setDisplayName("PlayerCharlieUnauthorized");
        AuthResponse authC = authService.loginAsGuest(reqC);

        assertNotNull(authA.getToken());
        assertNotNull(authB.getToken());
        UUID aliceId = authA.getId();
        UUID bobId = authB.getId();
        UUID charlieId = authC.getId();

        // 2. Player A creates a private room
        CreateRoomRequest createReq = new CreateRoomRequest();
        createReq.setName("Alice's Secret Duel");
        createReq.setVisibility("PRIVATE");
        createReq.setMaxPlayers(4);
        createReq.setTotalRounds(2);
        createReq.setDrawTimeSeconds(60);
        createReq.setCategory("GENERAL");
        createReq.setDifficulty("EASY");

        RoomResponse createdRoom = roomService.createRoom(aliceId, createReq);
        assertNotNull(createdRoom.getId());
        assertEquals("Alice's Secret Duel", createdRoom.getName());
        assertEquals("WAITING", createdRoom.getStatus());
        String roomCode = createdRoom.getRoomCode();

        // 3. Player B joins using the room code
        RoomResponse joinedRoom = roomService.joinRoomByCode(bobId, roomCode);
        assertEquals(2, joinedRoom.getCurrentPlayers());

        // 4. Player B sets ready
        RoomResponse readyRoom = roomService.toggleReady(createdRoom.getId(), bobId);
        assertEquals(2, readyRoom.getReadyPlayers());

        // 5. Unauthorized player verification:
        // Non-member Charlie attempting to start match must be rejected
        assertThrows(UnauthorizedException.class, () -> {
            gameEngineService.startMatch(createdRoom.getId(), charlieId);
        });

        // 6. Host (Alice) starts the match
        gameEngineService.startMatch(createdRoom.getId(), aliceId);

        // Verify room moved to IN_PROGRESS
        GameRoom liveRoom = roomRepository.findById(createdRoom.getId()).orElseThrow();
        assertEquals("IN_PROGRESS", liveRoom.getStatus());

        GameEngineService.ActiveMatchState state = gameEngineService.getActiveMatch(createdRoom.getId());
        assertNotNull(state, "Active match state should be initialized");
        if (state.currentRound == 0) {
            gameEngineService.startNextRound(createdRoom.getId());
        }
        assertEquals(1, state.currentRound);
        UUID drawerId = state.currentDrawerId;
        assertNotNull(drawerId);
        String secretWord = state.currentSecretWord;
        assertNotNull(secretWord, "Secret word must be assigned to round");

        UUID guesserId = drawerId.equals(aliceId) ? bobId : aliceId;

        // 7. Drawing authorization check:
        // Guesser attempts to draw -> ignored/rejected
        DrawingStroke unauthorizedStroke = new DrawingStroke();
        unauthorizedStroke.setStrokeId("stroke-unauthorized");
        unauthorizedStroke.setPoints(List.of(new DrawingPoint(0.1, 0.2)));
        gameEngineService.handleDrawingPoints(createdRoom.getId(), guesserId, unauthorizedStroke);
        List<DrawingStroke> snapshotAfterUnauthorized = drawingStateService.getCanvasSnapshot(createdRoom.getId());
        assertTrue(snapshotAfterUnauthorized.isEmpty(), "Unauthorized guesser strokes must NOT be recorded");

        // Drawer draws -> recorded
        DrawingStroke validStroke = new DrawingStroke();
        validStroke.setStrokeId("stroke-valid");
        validStroke.setPoints(List.of(new DrawingPoint(0.1, 0.2), new DrawingPoint(0.3, 0.4)));
        gameEngineService.handleDrawingPoints(createdRoom.getId(), drawerId, validStroke);
        List<DrawingStroke> snapshotAfterValid = drawingStateService.getCanvasSnapshot(createdRoom.getId());
        assertEquals(1, snapshotAfterValid.size(), "Drawer stroke must be recorded on canvas");

        // 8. Guessing authorization & validation:
        // Drawer attempts to guess their own drawing -> rejected
        gameEngineService.processGuess(createdRoom.getId(), drawerId, secretWord);
        assertEquals(0, state.playerScores.get(drawerId), "Drawer cannot score by guessing their own word");

        // Guesser submits wrong guess
        gameEngineService.processGuess(createdRoom.getId(), guesserId, "WrongGuess123");
        assertEquals(0, state.playerScores.get(guesserId), "Wrong guess awards 0 points");

        // Guesser submits correct guess!
        gameEngineService.processGuess(createdRoom.getId(), guesserId, secretWord);
        int guesserScore = state.playerScores.get(guesserId);
        assertTrue(guesserScore > 0, "Correct guess must award points");
        assertEquals(1, state.roundCorrectGuessers.size());

        // Duplicate guess by same player -> points awarded only once
        gameEngineService.processGuess(createdRoom.getId(), guesserId, secretWord);
        assertEquals(guesserScore, state.playerScores.get(guesserId), "Duplicate guess must NOT award extra points");

        // 9. Round ending & Drawer scoring:
        gameEngineService.endRound(createdRoom.getId());
        int drawerScore = state.playerScores.get(drawerId);
        assertTrue(drawerScore > 0, "Drawer receives bonus points when players guess correctly");

        // 10. Match completion & Data persistence:
        gameEngineService.finishMatch(createdRoom.getId());

        // Room returns to WAITING for rematch
        GameRoom postMatchRoom = roomRepository.findById(createdRoom.getId()).orElseThrow();
        assertEquals("WAITING", postMatchRoom.getStatus());

        // Match results persisted
        List<MatchPlayerResult> results = matchPlayerResultRepository.findByMatchIdWithPlayerOrderByRank(state.matchId);
        assertEquals(2, results.size());
        assertEquals(1, results.get(0).getRankPosition());
        assertEquals(2, results.get(1).getRankPosition());

        // Verify player career statistics updated
        User updatedGuesser = userRepository.findById(guesserId).orElseThrow();
        assertTrue(updatedGuesser.getGamesPlayed() >= 1);
        assertTrue(updatedGuesser.getXp() > 0);

        // 11. Leaderboard includes the participants
        List<LeaderboardEntryResponse> leaderboard = leaderboardService.getLeaderboard("all-time", 10);
        assertFalse(leaderboard.isEmpty());
    }
}
