package com.doodleduel.users.dto;

import com.doodleduel.users.User;

public class UserStatsResponse {

    private int gamesPlayed;
    private int gamesWon;
    private double winRate;
    private int bestScore;
    private int correctGuesses;
    private int drawingsCompleted;
    private int level;
    private int xp;
    private int coins;
    private int streak;

    public static UserStatsResponse fromEntity(User user) {
        UserStatsResponse stats = new UserStatsResponse();
        stats.setGamesPlayed(user.getGamesPlayed());
        stats.setGamesWon(user.getGamesWon());
        stats.setWinRate(user.getGamesPlayed() > 0 ? (double) user.getGamesWon() / user.getGamesPlayed() * 100.0 : 0.0);
        stats.setBestScore(user.getBestScore());
        stats.setCorrectGuesses(user.getCorrectGuesses());
        stats.setDrawingsCompleted(user.getDrawingsCompleted());
        stats.setLevel(user.getLevel());
        stats.setXp(user.getXp());
        stats.setCoins(user.getCoins());
        stats.setStreak(user.getStreak());
        return stats;
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

    public double getWinRate() {
        return winRate;
    }

    public void setWinRate(double winRate) {
        this.winRate = winRate;
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
}
