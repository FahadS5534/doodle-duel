package com.doodleduel.leaderboard;

import com.doodleduel.common.response.ApiResponse;
import com.doodleduel.leaderboard.dto.LeaderboardEntryResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/leaderboard")
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    public LeaderboardController(LeaderboardService leaderboardService) {
        this.leaderboardService = leaderboardService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<LeaderboardEntryResponse>>> getLeaderboard(
            @RequestParam(defaultValue = "all-time") String period,
            @RequestParam(defaultValue = "50") int limit) {
        List<LeaderboardEntryResponse> leaderboard = leaderboardService.getLeaderboard(period, limit);
        return ResponseEntity.ok(ApiResponse.ok(leaderboard));
    }
}
