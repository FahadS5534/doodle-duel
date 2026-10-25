package com.doodleduel.games.dto;

import com.doodleduel.games.MatchPlayerResult;
import java.util.UUID;

public class MatchResultResponse {

    private UUID playerId;
    private String username;
    private String displayName;
    private String avatarUrl;
    private int finalScore;
    private int rankPosition;
    private int correctGuesses;
    private int roundsDrawn;
    private int xpEarned;

    public static MatchResultResponse fromEntity(MatchPlayerResult result) {
        MatchResultResponse response = new MatchResultResponse();
        response.setPlayerId(result.getPlayer().getId());
        response.setUsername(result.getPlayer().getUsername());
        response.setDisplayName(result.getPlayer().getDisplayName());
        response.setAvatarUrl(result.getPlayer().getAvatarUrl());
        response.setFinalScore(result.getFinalScore());
        response.setRankPosition(result.getRankPosition());
        response.setCorrectGuesses(result.getCorrectGuesses());
        response.setRoundsDrawn(result.getRoundsDrawn());
        response.setXpEarned(result.getXpEarned());
        return response;
    }

    public UUID getPlayerId() {
        return playerId;
    }

    public void setPlayerId(UUID playerId) {
        this.playerId = playerId;
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

    public int getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(int finalScore) {
        this.finalScore = finalScore;
    }

    public int getRankPosition() {
        return rankPosition;
    }

    public void setRankPosition(int rankPosition) {
        this.rankPosition = rankPosition;
    }

    public int getCorrectGuesses() {
        return correctGuesses;
    }

    public void setCorrectGuesses(int correctGuesses) {
        this.correctGuesses = correctGuesses;
    }

    public int getRoundsDrawn() {
        return roundsDrawn;
    }

    public void setRoundsDrawn(int roundsDrawn) {
        this.roundsDrawn = roundsDrawn;
    }

    public int getXpEarned() {
        return xpEarned;
    }

    public void setXpEarned(int xpEarned) {
        this.xpEarned = xpEarned;
    }
}
