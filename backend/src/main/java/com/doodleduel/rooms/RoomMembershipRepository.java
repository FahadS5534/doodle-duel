package com.doodleduel.rooms;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RoomMembershipRepository extends JpaRepository<RoomMembership, UUID> {

    List<RoomMembership> findByRoomIdOrderByJoinedAtAsc(UUID roomId);

    Optional<RoomMembership> findByRoomIdAndUserId(UUID roomId, UUID userId);

    boolean existsByRoomIdAndUserId(UUID roomId, UUID userId);

    long countByRoomId(UUID roomId);

    long countByRoomIdAndIsReadyTrue(UUID roomId);

    void deleteByRoomIdAndUserId(UUID roomId, UUID userId);

    @Query("SELECT rm FROM RoomMembership rm JOIN FETCH rm.user WHERE rm.room.id = :roomId ORDER BY rm.joinedAt ASC")
    List<RoomMembership> findMembersWithUserByRoomId(@Param("roomId") UUID roomId);

    @Query("SELECT rm FROM RoomMembership rm WHERE rm.user.id = :userId AND rm.room.status = 'WAITING' ORDER BY rm.joinedAt DESC")
    List<RoomMembership> findActiveWaitingMembershipsForUser(@Param("userId") UUID userId);
}
