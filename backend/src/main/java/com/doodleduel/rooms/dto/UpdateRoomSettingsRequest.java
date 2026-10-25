package com.doodleduel.rooms.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class UpdateRoomSettingsRequest {

    private String name;
    private String visibility;

    @Min(value = 2, message = "Max players must be at least 2")
    @Max(value = 16, message = "Max players cannot exceed 16")
    private Integer maxPlayers;

    @Min(value = 1, message = "Total rounds must be at least 1")
    @Max(value = 10, message = "Total rounds cannot exceed 10")
    private Integer totalRounds;

    @Min(value = 20, message = "Draw time must be at least 20 seconds")
    @Max(value = 180, message = "Draw time cannot exceed 180 seconds")
    private Integer drawTimeSeconds;

    private String difficulty;
    private String category;

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

    public Integer getMaxPlayers() {
        return maxPlayers;
    }

    public void setMaxPlayers(Integer maxPlayers) {
        this.maxPlayers = maxPlayers;
    }

    public Integer getTotalRounds() {
        return totalRounds;
    }

    public void setTotalRounds(Integer totalRounds) {
        this.totalRounds = totalRounds;
    }

    public Integer getDrawTimeSeconds() {
        return drawTimeSeconds;
    }

    public void setDrawTimeSeconds(Integer drawTimeSeconds) {
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
