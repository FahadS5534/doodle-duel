package com.doodleduel.rooms;

import com.doodleduel.common.exception.BadRequestException;
import com.doodleduel.common.exception.ResourceNotFoundException;
import com.doodleduel.common.exception.UnauthorizedException;
import com.doodleduel.rooms.dto.*;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import com.doodleduel.websocket.GameEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class RoomService {

    private static final Logger log = LoggerFactory.getLogger(RoomService.class);
    private final GameRoomRepository roomRepository;
    private final RoomMembershipRepository membershipRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final Random random = new Random();

    public RoomService(
            GameRoomRepository roomRepository,
            RoomMembershipRepository membershipRepository,
            UserRepository userRepository,
            SimpMessagingTemplate messagingTemplate) {
        this.roomRepository = roomRepository;
        this.membershipRepository = membershipRepository;
        this.userRepository = userRepository;
        this.messagingTemplate = messagingTemplate;
    }

    @Transactional
    public RoomResponse createRoom(UUID hostId, CreateRoomRequest request) {
        User host = userRepository.findById(hostId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", hostId));

        String roomCode = generateUniqueRoomCode();

        GameRoom room = new GameRoom();
        room.setId(UUID.randomUUID());
        room.setRoomCode(roomCode);
        room.setName(request.getName().trim());
        room.setHost(host);
        room.setVisibility(request.getVisibility() != null ? request.getVisibility().toUpperCase() : "PUBLIC");
        room.setStatus("WAITING");
        room.setMaxPlayers(request.getMaxPlayers() > 0 ? request.getMaxPlayers() : 8);
        room.setTotalRounds(request.getTotalRounds() > 0 ? request.getTotalRounds() : 4);
        room.setDrawTimeSeconds(request.getDrawTimeSeconds() > 0 ? request.getDrawTimeSeconds() : 60);
        room.setDifficulty(StringUtils.hasText(request.getDifficulty()) ? request.getDifficulty().toUpperCase() : "MEDIUM");
        room.setCategory(StringUtils.hasText(request.getCategory()) ? request.getCategory().toUpperCase() : "GENERAL");
        room.setCreatedAt(Instant.now());

        room = roomRepository.save(room);

        // Host is automatically a member and ready
        RoomMembership hostMembership = new RoomMembership();
        hostMembership.setId(UUID.randomUUID());
        hostMembership.setRoom(room);
        hostMembership.setUser(host);
        hostMembership.setRole("HOST");
        hostMembership.setReady(true);
        hostMembership.setConnectionStatus("CONNECTED");
        hostMembership.setJoinedAt(Instant.now());

        membershipRepository.save(hostMembership);

        RoomMemberResponse memberDto = RoomMemberResponse.fromEntity(hostMembership);
        return RoomResponse.fromEntity(room, List.of(memberDto));
    }

    @Transactional
    public RoomResponse joinRoomByCode(UUID userId, String roomCode) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        String normalizedCode = roomCode.trim().toUpperCase();
        GameRoom room = roomRepository.findByRoomCode(normalizedCode)
                .orElseThrow(() -> new ResourceNotFoundException("Room not found with code: " + normalizedCode));

        if (!"WAITING".equals(room.getStatus())) {
            throw new BadRequestException("Game in this room is already in progress or finished");
        }

        long currentCount = membershipRepository.countByRoomId(room.getId());
        Optional<RoomMembership> existing = membershipRepository.findByRoomIdAndUserId(room.getId(), userId);

        if (existing.isEmpty()) {
            if (currentCount >= room.getMaxPlayers()) {
                throw new BadRequestException("Room is full (" + currentCount + "/" + room.getMaxPlayers() + ")");
            }

            RoomMembership membership = new RoomMembership();
            membership.setId(UUID.randomUUID());
            membership.setRoom(room);
            membership.setUser(user);
            membership.setRole("PLAYER");
            membership.setReady(false);
            membership.setConnectionStatus("CONNECTED");
            membership.setJoinedAt(Instant.now());
            membershipRepository.save(membership);
        } else {
            RoomMembership membership = existing.get();
            membership.setConnectionStatus("CONNECTED");
            membershipRepository.save(membership);
        }

        RoomResponse response = getRoomDetails(room.getId());
        broadcastLobbyUpdate(room.getId(), "PLAYER_JOINED", response);
        return response;
    }

    @Transactional(readOnly = true)
    public RoomResponse getRoomDetails(UUID roomId) {
        GameRoom room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Room", "id", roomId));

        List<RoomMembership> members = membershipRepository.findMembersWithUserByRoomId(roomId);
        List<RoomMemberResponse> memberResponses = members.stream()
                .map(RoomMemberResponse::fromEntity)
                .collect(Collectors.toList());

        return RoomResponse.fromEntity(room, memberResponses);
    }

    @Transactional
    public RoomResponse toggleReady(UUID roomId, UUID userId) {
        RoomMembership membership = membershipRepository.findByRoomIdAndUserId(roomId, userId)
                .orElseThrow(() -> new BadRequestException("User is not a member of this room"));

        // Toggle ready state
        membership.setReady(!membership.isReady());
        membershipRepository.save(membership);

        RoomResponse response = getRoomDetails(roomId);
        broadcastLobbyUpdate(roomId, "READY_TOGGLED", response);
        return response;
    }

    @Transactional
    public void leaveRoom(UUID roomId, UUID userId) {
        GameRoom room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Room", "id", roomId));

        membershipRepository.deleteByRoomIdAndUserId(roomId, userId);

        List<RoomMembership> remaining = membershipRepository.findMembersWithUserByRoomId(roomId);
        if (remaining.isEmpty()) {
            room.setStatus("FINISHED");
            roomRepository.save(room);
            log.info("Room {} closed as all players left", roomId);
        } else {
            // If host left, reassign host role to earliest joined player
            if (room.getHost().getId().equals(userId)) {
                RoomMembership newHostMember = remaining.get(0);
                newHostMember.setRole("HOST");
                newHostMember.setReady(true);
                membershipRepository.save(newHostMember);

                room.setHost(newHostMember.getUser());
                roomRepository.save(room);
                log.info("Host left. Reassigned host of room {} to {}", roomId, newHostMember.getUser().getUsername());
            }

            RoomResponse response = getRoomDetails(roomId);
            broadcastLobbyUpdate(roomId, "PLAYER_LEFT", response);
        }
    }

    @Transactional
    public RoomResponse updateRoomSettings(UUID roomId, UUID userId, UpdateRoomSettingsRequest request) {
        GameRoom room = roomRepository.findById(roomId)
                .orElseThrow(() -> new ResourceNotFoundException("Room", "id", roomId));

        if (!room.getHost().getId().equals(userId)) {
            throw new UnauthorizedException("Only the room host can modify settings");
        }

        if (!"WAITING".equals(room.getStatus())) {
            throw new BadRequestException("Cannot modify settings while match is in progress");
        }

        if (StringUtils.hasText(request.getName())) {
            room.setName(request.getName().trim());
        }
        if (StringUtils.hasText(request.getVisibility())) {
            room.setVisibility(request.getVisibility().toUpperCase());
        }
        if (request.getMaxPlayers() != null && request.getMaxPlayers() >= 2) {
            room.setMaxPlayers(request.getMaxPlayers());
        }
        if (request.getTotalRounds() != null && request.getTotalRounds() >= 1) {
            room.setTotalRounds(request.getTotalRounds());
        }
        if (request.getDrawTimeSeconds() != null && request.getDrawTimeSeconds() >= 20) {
            room.setDrawTimeSeconds(request.getDrawTimeSeconds());
        }
        if (StringUtils.hasText(request.getDifficulty())) {
            room.setDifficulty(request.getDifficulty().toUpperCase());
        }
        if (StringUtils.hasText(request.getCategory())) {
            room.setCategory(request.getCategory().toUpperCase());
        }

        room = roomRepository.save(room);

        RoomResponse response = getRoomDetails(roomId);
        broadcastLobbyUpdate(roomId, "SETTINGS_UPDATED", response);
        return response;
    }

    @Transactional(readOnly = true)
    public Page<RoomResponse> getPublicRooms(String difficulty, String category, Pageable pageable) {
        Page<GameRoom> roomsPage;
        if (StringUtils.hasText(difficulty) || StringUtils.hasText(category)) {
            roomsPage = roomRepository.searchPublicRooms(
                    StringUtils.hasText(difficulty) ? difficulty.toUpperCase() : null,
                    StringUtils.hasText(category) ? category.toUpperCase() : null,
                    pageable);
        } else {
            roomsPage = roomRepository.findAvailablePublicRooms(pageable);
        }

        List<RoomResponse> responses = roomsPage.getContent().stream()
                .map(room -> {
                    long count = membershipRepository.countByRoomId(room.getId());
                    RoomResponse res = RoomResponse.fromEntity(room, Collections.emptyList());
                    res.setCurrentPlayers((int) count);
                    return res;
                })
                .collect(Collectors.toList());

        return new PageImpl<>(responses, pageable, roomsPage.getTotalElements());
    }

    private String generateUniqueRoomCode() {
        for (int i = 0; i < 20; i++) {
            int num = 1000 + random.nextInt(9000);
            String code = "DUEL-" + num;
            if (!roomRepository.existsByRoomCode(code)) {
                return code;
            }
        }
        return "DUEL-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();
    }

    private void broadcastLobbyUpdate(UUID roomId, String action, RoomResponse roomDetails) {
        try {
            GameEvent event = new GameEvent(
                    "LOBBY_UPDATE",
                    roomId,
                    null,
                    null,
                    null,
                    "System",
                    Map.of("action", action, "room", roomDetails)
            );
            messagingTemplate.convertAndSend("/topic/rooms/" + roomId + "/lobby", event);
        } catch (Exception ex) {
            log.warn("Failed to broadcast lobby update for room {}: {}", roomId, ex.getMessage());
        }
    }
}
