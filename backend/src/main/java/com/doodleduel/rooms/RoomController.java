package com.doodleduel.rooms;

import com.doodleduel.common.response.ApiResponse;
import com.doodleduel.games.engine.GameEngineService;
import com.doodleduel.rooms.dto.*;
import com.doodleduel.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/rooms")
public class RoomController {

    private final RoomService roomService;
    private final GameEngineService gameEngineService;

    public RoomController(RoomService roomService, GameEngineService gameEngineService) {
        this.roomService = roomService;
        this.gameEngineService = gameEngineService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<RoomResponse>> createRoom(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CreateRoomRequest request) {
        RoomResponse response = roomService.createRoom(principal.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Room created successfully", response));
    }

    @GetMapping("/{roomId}")
    public ResponseEntity<ApiResponse<RoomResponse>> getRoomDetails(@PathVariable UUID roomId) {
        RoomResponse response = roomService.getRoomDetails(roomId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/join")
    public ResponseEntity<ApiResponse<RoomResponse>> joinRoom(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody JoinRoomRequest request) {
        RoomResponse response = roomService.joinRoomByCode(principal.getId(), request.getRoomCode());
        return ResponseEntity.ok(ApiResponse.ok("Joined room successfully", response));
    }

    @PostMapping("/{roomId}/leave")
    public ResponseEntity<ApiResponse<Void>> leaveRoom(
            @PathVariable UUID roomId,
            @AuthenticationPrincipal UserPrincipal principal) {
        roomService.leaveRoom(roomId, principal.getId());
        return ResponseEntity.ok(ApiResponse.ok("Left room successfully", null));
    }

    @PatchMapping("/{roomId}/ready")
    public ResponseEntity<ApiResponse<RoomResponse>> toggleReady(
            @PathVariable UUID roomId,
            @AuthenticationPrincipal UserPrincipal principal) {
        RoomResponse response = roomService.toggleReady(roomId, principal.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/{roomId}/start")
    public ResponseEntity<ApiResponse<RoomResponse>> startMatch(
            @PathVariable UUID roomId,
            @AuthenticationPrincipal UserPrincipal principal) {
        gameEngineService.startMatch(roomId, principal.getId());
        RoomResponse response = roomService.getRoomDetails(roomId);
        return ResponseEntity.ok(ApiResponse.ok("Match started successfully", response));
    }

    @PatchMapping("/{roomId}/settings")
    public ResponseEntity<ApiResponse<RoomResponse>> updateSettings(
            @PathVariable UUID roomId,
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody UpdateRoomSettingsRequest request) {
        RoomResponse response = roomService.updateRoomSettings(roomId, principal.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Settings updated", response));
    }

    @GetMapping("/public")
    public ResponseEntity<ApiResponse<Page<RoomResponse>>> getPublicRooms(
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, Math.min(size, 50));
        Page<RoomResponse> rooms = roomService.getPublicRooms(difficulty, category, pageable);
        return ResponseEntity.ok(ApiResponse.ok(rooms));
    }
}
