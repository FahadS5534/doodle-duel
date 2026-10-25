package com.doodleduel.websocket;

import com.doodleduel.drawing.DrawingStroke;
import com.doodleduel.games.engine.GameEngineService;
import com.doodleduel.rooms.RoomService;
import com.doodleduel.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.util.Map;
import java.util.UUID;

@Controller
public class GameWebSocketController {

    private static final Logger log = LoggerFactory.getLogger(GameWebSocketController.class);

    private final GameEngineService gameEngineService;
    private final RoomService roomService;

    public GameWebSocketController(GameEngineService gameEngineService, RoomService roomService) {
        this.gameEngineService = gameEngineService;
        this.roomService = roomService;
    }

    @MessageMapping("/rooms/{roomId}/ready")
    public void toggleReady(@DestinationVariable UUID roomId, Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null) {
            roomService.toggleReady(roomId, userId);
        }
    }

    @MessageMapping("/rooms/{roomId}/start")
    public void startMatch(@DestinationVariable UUID roomId, Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null) {
            gameEngineService.startMatch(roomId, userId);
        }
    }

    @MessageMapping("/rooms/{roomId}/drawing")
    public void onDrawingPoints(
            @DestinationVariable UUID roomId,
            @Payload DrawingStroke strokeChunk,
            Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null && strokeChunk != null) {
            gameEngineService.handleDrawingPoints(roomId, userId, strokeChunk);
        }
    }

    @MessageMapping("/rooms/{roomId}/drawing/undo")
    public void onDrawingUndo(@DestinationVariable UUID roomId, Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null) {
            gameEngineService.handleDrawingUndo(roomId, userId);
        }
    }

    @MessageMapping("/rooms/{roomId}/drawing/clear")
    public void onDrawingClear(@DestinationVariable UUID roomId, Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null) {
            gameEngineService.handleDrawingClear(roomId, userId);
        }
    }

    @MessageMapping("/rooms/{roomId}/guess")
    public void onGuess(
            @DestinationVariable UUID roomId,
            @Payload Map<String, String> payload,
            Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null && payload != null && payload.containsKey("text")) {
            gameEngineService.processGuess(roomId, userId, payload.get("text"));
        }
    }

    @MessageMapping("/rooms/{roomId}/reaction")
    public void onReaction(
            @DestinationVariable UUID roomId,
            @Payload Map<String, String> payload,
            Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null && payload != null && payload.containsKey("emoji")) {
            gameEngineService.handleReaction(roomId, userId, payload.get("emoji"));
        }
    }

    @MessageMapping("/rooms/{roomId}/sync")
    public void onSync(@DestinationVariable UUID roomId, Principal principal) {
        UUID userId = getUserId(principal);
        if (userId != null) {
            gameEngineService.syncGameState(roomId, userId);
        }
    }

    private UUID getUserId(Principal principal) {
        if (principal instanceof UsernamePasswordAuthenticationToken auth) {
            if (auth.getPrincipal() instanceof UserPrincipal userPrincipal) {
                return userPrincipal.getId();
            }
        }
        if (principal != null) {
            try {
                return UUID.fromString(principal.getName());
            } catch (IllegalArgumentException ignored) {
            }
        }
        log.warn("Unable to resolve userId from principal: {}", principal);
        return null;
    }
}
