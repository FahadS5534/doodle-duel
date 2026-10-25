package com.doodleduel.games;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface GameMatchRepository extends JpaRepository<GameMatch, UUID> {

    Optional<GameMatch> findFirstByRoomIdAndStatusOrderByStartedAtDesc(UUID roomId, String status);

    @Query("SELECT m FROM GameMatch m JOIN MatchPlayerResult r ON r.match.id = m.id WHERE r.player.id = :userId ORDER BY m.startedAt DESC")
    Page<GameMatch> findMatchesForUser(@Param("userId") UUID userId, Pageable pageable);
}
