package com.doodleduel.games;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface GuessRepository extends JpaRepository<Guess, UUID> {

    List<Guess> findByRoundIdOrderBySubmittedAtAsc(UUID roundId);

    Optional<Guess> findByRoundIdAndPlayerIdAndIsCorrectTrue(UUID roundId, UUID playerId);

    long countByRoundIdAndIsCorrectTrue(UUID roundId);

    boolean existsByRoundIdAndPlayerIdAndIsCorrectTrue(UUID roundId, UUID playerId);
}
