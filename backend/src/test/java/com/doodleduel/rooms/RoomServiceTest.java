package com.doodleduel.rooms;

import com.doodleduel.common.exception.BadRequestException;
import com.doodleduel.rooms.dto.CreateRoomRequest;
import com.doodleduel.rooms.dto.RoomResponse;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class RoomServiceTest {

    @Mock
    private GameRoomRepository roomRepository;

    @Mock
    private RoomMembershipRepository membershipRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SimpMessagingTemplate messagingTemplate;

    private RoomService roomService;
    private User host;

    @BeforeEach
    void setUp() {
        roomService = new RoomService(roomRepository, membershipRepository, userRepository, messagingTemplate);

        host = new User();
        host.setId(UUID.randomUUID());
        host.setUsername("maya");
        host.setDisplayName("Maya");
    }

    @Test
    void testCreateRoom() {
        when(userRepository.findById(host.getId())).thenReturn(Optional.of(host));
        when(roomRepository.save(any(GameRoom.class))).thenAnswer(i -> i.getArgument(0));

        CreateRoomRequest request = new CreateRoomRequest();
        request.setName("Art Squad");
        request.setMaxPlayers(6);
        request.setTotalRounds(4);
        request.setDrawTimeSeconds(60);

        RoomResponse response = roomService.createRoom(host.getId(), request);

        assertNotNull(response);
        assertEquals("Art Squad", response.getName());
        assertEquals(host.getId(), response.getHostId());
        assertTrue(response.getRoomCode().startsWith("DUEL-"));
        assertEquals(1, response.getCurrentPlayers());
        verify(membershipRepository, times(1)).save(any(RoomMembership.class));
    }

    @Test
    void testJoinRoomFull() {
        UUID joinerId = UUID.randomUUID();
        User joiner = new User();
        joiner.setId(joinerId);

        GameRoom room = new GameRoom();
        room.setId(UUID.randomUUID());
        room.setRoomCode("DUEL-1234");
        room.setStatus("WAITING");
        room.setMaxPlayers(2);

        when(userRepository.findById(joinerId)).thenReturn(Optional.of(joiner));
        when(roomRepository.findByRoomCode("DUEL-1234")).thenReturn(Optional.of(room));
        when(membershipRepository.countByRoomId(room.getId())).thenReturn(2L);
        when(membershipRepository.findByRoomIdAndUserId(room.getId(), joinerId)).thenReturn(Optional.empty());

        assertThrows(BadRequestException.class, () -> roomService.joinRoomByCode(joinerId, "DUEL-1234"));
    }
}
