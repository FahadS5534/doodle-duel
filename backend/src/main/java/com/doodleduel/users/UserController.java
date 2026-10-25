package com.doodleduel.users;

import com.doodleduel.common.response.ApiResponse;
import com.doodleduel.security.UserPrincipal;
import com.doodleduel.users.dto.UpdateUserRequest;
import com.doodleduel.users.dto.UserResponse;
import com.doodleduel.users.dto.UserStatsResponse;
import com.doodleduel.games.MatchService;
import com.doodleduel.games.dto.MatchResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;
    private final MatchService matchService;

    public UserController(UserService userService, MatchService matchService) {
        this.userService = userService;
        this.matchService = matchService;
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal UserPrincipal principal) {
        UserResponse response = userService.getUserProfile(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PatchMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateCurrentUser(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody UpdateUserRequest request) {
        UserResponse response = userService.updateUserProfile(principal.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Profile updated successfully", response));
    }

    @GetMapping("/me/stats")
    public ResponseEntity<ApiResponse<UserStatsResponse>> getCurrentUserStats(@AuthenticationPrincipal UserPrincipal principal) {
        UserStatsResponse response = userService.getUserStats(principal.getId());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @GetMapping("/me/matches")
    public ResponseEntity<ApiResponse<Page<MatchResponse>>> getMyMatches(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, Math.min(size, 30));
        Page<MatchResponse> response = matchService.getUserMatchHistory(principal.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}

