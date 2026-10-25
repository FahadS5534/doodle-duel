package com.doodleduel.auth.dto;

import jakarta.validation.constraints.Size;

public class GuestLoginRequest {

    @Size(min = 2, max = 30, message = "Display name must be between 2 and 30 characters")
    private String displayName;

    private String avatarUrl;

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
}
