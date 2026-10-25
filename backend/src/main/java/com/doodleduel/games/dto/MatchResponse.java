package com.doodleduel.games.dto;

import com.doodleduel.games.GameMatch;
import java.time.Instant;
import java.util.UUID;

public class MatchResponse {

    private UUID id;
    private UUID roomId;
    private String roomName;
    private String status;
    private int currentRound;
    private Instant startedAt;
    private Instant endedAt;

    public static MatchResponse fromEntity(GameMatch match) {
        MatchResponse response = new MatchResponse();
        response.setId(match.getId());
        response.setRoomId(match.getRoom().getId());
        response.setRoomName(match.getRoom().getName());
        response.setStatus(match.getStatus());
        response.setCurrentRound(match.getCurrentRound());
        response.setStartedAt(match.getStartedAt());
        response.setEndedAt(match.getEndedAt());
        return response;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getRoomId() {
        return roomId;
    }

    public void setRoomId(UUID roomId) {
        this.roomId = roomId;
    }

    public String getRoomName() {
        return roomName;
    }

    public void setRoomName(String roomName) {
        this.roomName = roomName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getCurrentRound() {
        return currentRound;
    }

    public void setCurrentRound(int currentRound) {
        this.currentRound = currentRound;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(Instant startedAt) {
        this.startedAt = startedAt;
    }

    public Instant getEndedAt() {
        return endedAt;
    }

    public void setEndedAt(Instant endedAt) {
        this.endedAt = endedAt;
    }
}
