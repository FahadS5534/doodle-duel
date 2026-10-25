package com.doodleduel.games;

import com.doodleduel.common.exception.ResourceNotFoundException;
import com.doodleduel.games.dto.MatchResponse;
import com.doodleduel.games.dto.MatchResultResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MatchService {

    private final GameMatchRepository matchRepository;
    private final MatchPlayerResultRepository matchPlayerResultRepository;

    public MatchService(GameMatchRepository matchRepository, MatchPlayerResultRepository matchPlayerResultRepository) {
        this.matchRepository = matchRepository;
        this.matchPlayerResultRepository = matchPlayerResultRepository;
    }

    @Transactional(readOnly = true)
    public MatchResponse getMatch(UUID matchId) {
        GameMatch match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match", "id", matchId));
        return MatchResponse.fromEntity(match);
    }

    @Transactional(readOnly = true)
    public List<MatchResultResponse> getMatchResults(UUID matchId) {
        List<MatchPlayerResult> results = matchPlayerResultRepository.findByMatchIdWithPlayerOrderByRank(matchId);
        return results.stream().map(MatchResultResponse::fromEntity).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<MatchResponse> getUserMatchHistory(UUID userId, Pageable pageable) {
        return matchRepository.findMatchesForUser(userId, pageable).map(MatchResponse::fromEntity);
    }
}
