package com.doodleduel.rooms.dto;

import com.doodleduel.rooms.RoomMembership;
import java.time.Instant;
import java.util.UUID;

public class RoomMemberResponse {

    private UUID userId;
    private String username;
    private String displayName;
    private String avatarUrl;
    private int level;
    private String role; // HOST, PLAYER
    private boolean isReady;
    private String connectionStatus; // CONNECTED, DISCONNECTED
    private Instant joinedAt;

    public static RoomMemberResponse fromEntity(RoomMembership membership) {
        RoomMemberResponse response = new RoomMemberResponse();
        response.setUserId(membership.getUser().getId());
        response.setUsername(membership.getUser().getUsername());
        response.setDisplayName(membership.getUser().getDisplayName());
        response.setAvatarUrl(membership.getUser().getAvatarUrl());
        response.setLevel(membership.getUser().getLevel());
        response.setRole(membership.getRole());
        response.setReady(membership.isReady());
        response.setConnectionStatus(membership.getConnectionStatus());
        response.setJoinedAt(membership.getJoinedAt());
        return response;
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

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isReady() {
        return isReady;
    }

    public void setReady(boolean ready) {
        isReady = ready;
    }

    public String getConnectionStatus() {
        return connectionStatus;
    }

    public void setConnectionStatus(String connectionStatus) {
        this.connectionStatus = connectionStatus;
    }

    public Instant getJoinedAt() {
        return joinedAt;
    }

    public void setJoinedAt(Instant joinedAt) {
        this.joinedAt = joinedAt;
    }
}
