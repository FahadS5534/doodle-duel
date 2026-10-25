package com.doodleduel.leaderboard.dto;

import com.doodleduel.users.User;
import java.util.UUID;

public class LeaderboardEntryResponse {

    private int rank;
    private UUID userId;
    private String username;
    private String displayName;
    private String avatarUrl;
    private int score;
    private int level;
    private int gamesWon;

    public static LeaderboardEntryResponse fromUser(User user, int rank, boolean byBestScore) {
        LeaderboardEntryResponse entry = new LeaderboardEntryResponse();
        entry.setRank(rank);
        entry.setUserId(user.getId());
        entry.setUsername(user.getUsername());
        entry.setDisplayName(user.getDisplayName());
        entry.setAvatarUrl(user.getAvatarUrl());
        entry.setScore(byBestScore ? user.getBestScore() : user.getXp());
        entry.setLevel(user.getLevel());
        entry.setGamesWon(user.getGamesWon());
        return entry;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getGamesWon() {
        return gamesWon;
    }

    public void setGamesWon(int gamesWon) {
        this.gamesWon = gamesWon;
    }
}
