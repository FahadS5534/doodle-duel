package com.doodleduel.rooms.dto;

import com.doodleduel.rooms.GameRoom;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class RoomResponse {

    private UUID id;
    private String roomCode;
    private String name;
    private UUID hostId;
    private String hostName;
    private String visibility;
    private String status;
    private int maxPlayers;
    private int totalRounds;
    private int drawTimeSeconds;
    private String difficulty;
    private String category;
    private int currentPlayers;
    private int readyPlayers;
    private Instant createdAt;
    private List<RoomMemberResponse> members;

    public static RoomResponse fromEntity(GameRoom room, List<RoomMemberResponse> members) {
        RoomResponse response = new RoomResponse();
        response.setId(room.getId());
        response.setRoomCode(room.getRoomCode());
        response.setName(room.getName());
        response.setHostId(room.getHost().getId());
        response.setHostName(room.getHost().getDisplayName());
        response.setVisibility(room.getVisibility());
        response.setStatus(room.getStatus());
        response.setMaxPlayers(room.getMaxPlayers());
        response.setTotalRounds(room.getTotalRounds());
        response.setDrawTimeSeconds(room.getDrawTimeSeconds());
        response.setDifficulty(room.getDifficulty());
        response.setCategory(room.getCategory());
        response.setCreatedAt(room.getCreatedAt());
        response.setMembers(members);
        response.setCurrentPlayers(members != null ? members.size() : 0);
        response.setReadyPlayers(members != null ? (int) members.stream().filter(RoomMemberResponse::isReady).count() : 0);
        return response;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getRoomCode() {
        return roomCode;
    }

    public void setRoomCode(String roomCode) {
        this.roomCode = roomCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public UUID getHostId() {
        return hostId;
    }

    public void setHostId(UUID hostId) {
        this.hostId = hostId;
    }

    public String getHostName() {
        return hostName;
    }

    public void setHostName(String hostName) {
        this.hostName = hostName;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getMaxPlayers() {
        return maxPlayers;
    }

    public void setMaxPlayers(int maxPlayers) {
        this.maxPlayers = maxPlayers;
    }

    public int getTotalRounds() {
        return totalRounds;
    }

    public void setTotalRounds(int totalRounds) {
        this.totalRounds = totalRounds;
    }

    public int getDrawTimeSeconds() {
        return drawTimeSeconds;
    }

    public void setDrawTimeSeconds(int drawTimeSeconds) {
        this.drawTimeSeconds = drawTimeSeconds;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getCurrentPlayers() {
        return currentPlayers;
    }

    public void setCurrentPlayers(int currentPlayers) {
        this.currentPlayers = currentPlayers;
    }

    public int getReadyPlayers() {
        return readyPlayers;
    }

    public void setReadyPlayers(int readyPlayers) {
        this.readyPlayers = readyPlayers;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public List<RoomMemberResponse> getMembers() {
        return members;
    }

    public void setMembers(List<RoomMemberResponse> members) {
        this.members = members;
    }
}
