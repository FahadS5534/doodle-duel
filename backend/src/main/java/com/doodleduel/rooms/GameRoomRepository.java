package com.doodleduel.rooms;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface GameRoomRepository extends JpaRepository<GameRoom, UUID> {

    Optional<GameRoom> findByRoomCode(String roomCode);

    boolean existsByRoomCode(String roomCode);

    @Query("SELECT r FROM GameRoom r WHERE r.visibility = 'PUBLIC' AND r.status = 'WAITING' ORDER BY r.createdAt DESC")
    Page<GameRoom> findAvailablePublicRooms(Pageable pageable);

    @Query("SELECT r FROM GameRoom r WHERE r.visibility = 'PUBLIC' AND r.status = 'WAITING' AND " +
            "(:difficulty IS NULL OR r.difficulty = :difficulty) AND " +
            "(:category IS NULL OR r.category = :category) ORDER BY r.createdAt DESC")
    Page<GameRoom> searchPublicRooms(
            @Param("difficulty") String difficulty,
            @Param("category") String category,
            Pageable pageable);
}
