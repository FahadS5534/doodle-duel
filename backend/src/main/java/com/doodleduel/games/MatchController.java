package com.doodleduel.games;

import com.doodleduel.common.response.ApiResponse;
import com.doodleduel.games.dto.MatchResponse;
import com.doodleduel.games.dto.MatchResultResponse;
import com.doodleduel.security.UserPrincipal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/matches")
public class MatchController {

    private final MatchService matchService;

    public MatchController(MatchService matchService) {
        this.matchService = matchService;
    }

    @GetMapping("/{matchId}")
    public ResponseEntity<ApiResponse<MatchResponse>> getMatch(@PathVariable UUID matchId) {
        MatchResponse response = matchService.getMatch(matchId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/{matchId}/results")
    public ResponseEntity<ApiResponse<List<MatchResultResponse>>> getMatchResults(@PathVariable UUID matchId) {
        List<MatchResultResponse> response = matchService.getMatchResults(matchId);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/my-history")
    public ResponseEntity<ApiResponse<Page<MatchResponse>>> getMyMatchHistory(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, Math.min(size, 30));
        Page<MatchResponse> response = matchService.getUserMatchHistory(principal.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
