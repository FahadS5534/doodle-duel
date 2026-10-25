package com.doodleduel.games;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface GameRoundRepository extends JpaRepository<GameRound, UUID> {

    List<GameRound> findByMatchIdOrderByRoundNumberAsc(UUID matchId);

    Optional<GameRound> findFirstByMatchIdAndStatusOrderByRoundNumberDesc(UUID matchId, String status);

    Optional<GameRound> findByMatchIdAndRoundNumber(UUID matchId, int roundNumber);
}
