package com.doodleduel.auth;

import com.doodleduel.auth.dto.AuthResponse;
import com.doodleduel.auth.dto.GuestLoginRequest;
import com.doodleduel.auth.dto.LoginRequest;
import com.doodleduel.auth.dto.RegisterRequest;
import com.doodleduel.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/guest")
    public ResponseEntity<ApiResponse<AuthResponse>> guestLogin(@Valid @RequestBody(required = false) GuestLoginRequest request) {
        AuthResponse response = authService.loginAsGuest(request);
        return ResponseEntity.ok(ApiResponse.ok("Guest session created", response));
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.ok("User registered successfully", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("Login successful", response));
    }
}
