package com.doodleduel.leaderboard;

import com.doodleduel.leaderboard.dto.LeaderboardEntryResponse;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class LeaderboardService {

    private final UserRepository userRepository;

    public LeaderboardService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> getLeaderboard(String period, int limit) {
        int boundedLimit = Math.min(Math.max(limit, 1), 100);
        boolean byBestScore = "weekly".equalsIgnoreCase(period);

        List<User> users = byBestScore
                ? userRepository.findTopByBestScore(PageRequest.of(0, boundedLimit))
                : userRepository.findTopByXp(PageRequest.of(0, boundedLimit));

        List<LeaderboardEntryResponse> result = new ArrayList<>();
        int rank = 1;
        for (User u : users) {
            result.add(LeaderboardEntryResponse.fromUser(u, rank++, byBestScore));
        }
        return result;
    }
}
