package com.doodleduel.users.dto;

import com.doodleduel.users.User;
import java.time.Instant;
import java.util.UUID;

public class UserResponse {

    private UUID id;
    private String username;
    private String displayName;
    private boolean isGuest;
    private String avatarUrl;
    private int level;
    private int xp;
    private int coins;
    private int streak;
    private int gamesPlayed;
    private int gamesWon;
    private int bestScore;
    private int correctGuesses;
    private int drawingsCompleted;
    private Instant createdAt;

    public static UserResponse fromEntity(User user) {
        UserResponse response = new UserResponse();
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setDisplayName(user.getDisplayName());
        response.setGuest(user.isGuest());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setLevel(user.getLevel());
        response.setXp(user.getXp());
        response.setCoins(user.getCoins());
        response.setStreak(user.getStreak());
        response.setGamesPlayed(user.getGamesPlayed());
        response.setGamesWon(user.getGamesWon());
        response.setBestScore(user.getBestScore());
        response.setCorrectGuesses(user.getCorrectGuesses());
        response.setDrawingsCompleted(user.getDrawingsCompleted());
        response.setCreatedAt(user.getCreatedAt());
        return response;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public boolean isGuest() {
        return isGuest;
    }

    public void setGuest(boolean guest) {
        isGuest = guest;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getXp() {
        return xp;
    }

    public void setXp(int xp) {
        this.xp = xp;
    }

    public int getCoins() {
        return coins;
    }

    public void setCoins(int coins) {
        this.coins = coins;
    }

    public int getStreak() {
        return streak;
    }

    public void setStreak(int streak) {
        this.streak = streak;
    }

    public int getGamesPlayed() {
        return gamesPlayed;
    }

    public void setGamesPlayed(int gamesPlayed) {
        this.gamesPlayed = gamesPlayed;
    }

    public int getGamesWon() {
        return gamesWon;
    }

    public void setGamesWon(int gamesWon) {
        this.gamesWon = gamesWon;
    }

    public int getBestScore() {
        return bestScore;
    }

    public void setBestScore(int bestScore) {
        this.bestScore = bestScore;
    }

    public int getCorrectGuesses() {
        return correctGuesses;
    }

    public void setCorrectGuesses(int correctGuesses) {
        this.correctGuesses = correctGuesses;
    }

    public int getDrawingsCompleted() {
        return drawingsCompleted;
    }

    public void setDrawingsCompleted(int drawingsCompleted) {
        this.drawingsCompleted = drawingsCompleted;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
