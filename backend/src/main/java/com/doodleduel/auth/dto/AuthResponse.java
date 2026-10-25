package com.doodleduel.auth.dto;

import java.util.UUID;

public class AuthResponse {

    private String token;
    private String tokenType = "Bearer";
    private UUID id;
    private String username;
    private String displayName;
    private boolean isGuest;
    private String avatarUrl;
    private int level;
    private int xp;
    private int coins;
    private int streak;

    public AuthResponse() {
    }

    public AuthResponse(String token, UUID id, String username, String displayName, boolean isGuest, String avatarUrl, int level, int xp, int coins, int streak) {
        this.token = token;
        this.id = id;
        this.username = username;
        this.displayName = displayName;
        this.isGuest = isGuest;
        this.avatarUrl = avatarUrl;
        this.level = level;
        this.xp = xp;
        this.coins = coins;
        this.streak = streak;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
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
}
