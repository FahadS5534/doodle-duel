package com.doodleduel.games;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MatchPlayerResultRepository extends JpaRepository<MatchPlayerResult, UUID> {

    @Query("SELECT r FROM MatchPlayerResult r JOIN FETCH r.player WHERE r.match.id = :matchId ORDER BY r.rankPosition ASC")
    List<MatchPlayerResult> findByMatchIdWithPlayerOrderByRank(@Param("matchId") UUID matchId);

    List<MatchPlayerResult> findByPlayerId(UUID playerId);
}
