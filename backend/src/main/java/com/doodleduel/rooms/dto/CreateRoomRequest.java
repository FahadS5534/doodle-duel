package com.doodleduel.rooms.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CreateRoomRequest {

    @NotBlank(message = "Room name cannot be blank")
    @Size(min = 2, max = 50, message = "Room name must be between 2 and 50 characters")
    private String name;

    private String visibility = "PUBLIC"; // PUBLIC, PRIVATE

    @Min(value = 2, message = "Max players must be at least 2")
    @Max(value = 16, message = "Max players cannot exceed 16")
    private int maxPlayers = 8;

    @Min(value = 1, message = "Total rounds must be at least 1")
    @Max(value = 10, message = "Total rounds cannot exceed 10")
    private int totalRounds = 4;

    @Min(value = 20, message = "Draw time must be at least 20 seconds")
    @Max(value = 180, message = "Draw time cannot exceed 180 seconds")
    private int drawTimeSeconds = 60;

    private String difficulty = "MEDIUM"; // EASY, MEDIUM, HARD

    private String category = "GENERAL";

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getVisibility() {
        return visibility;
    }

    public void setVisibility(String visibility) {
        this.visibility = visibility;
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
}
