package com.doodleduel.auth;

import com.doodleduel.auth.dto.AuthResponse;
import com.doodleduel.auth.dto.GuestLoginRequest;
import com.doodleduel.auth.dto.LoginRequest;
import com.doodleduel.auth.dto.RegisterRequest;
import com.doodleduel.common.exception.BadRequestException;
import com.doodleduel.common.exception.UnauthorizedException;
import com.doodleduel.security.JwtTokenProvider;
import com.doodleduel.users.User;
import com.doodleduel.users.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtTokenProvider tokenProvider;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(userRepository, passwordEncoder, tokenProvider);
    }

    @Test
    void testLoginAsGuest() {
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));
        when(tokenProvider.generateToken(any(), any(), any(), eq(true))).thenReturn("mock-jwt-token");

        GuestLoginRequest request = new GuestLoginRequest();
        request.setDisplayName("Player One");

        AuthResponse response = authService.loginAsGuest(request);

        assertNotNull(response);
        assertEquals("Player One", response.getDisplayName());
        assertTrue(response.isGuest());
        assertEquals("mock-jwt-token", response.getToken());
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void testRegisterSuccess() {
        when(userRepository.existsByUsername("alex")).thenReturn(false);
        when(passwordEncoder.encode("secret123")).thenReturn("hashed-pwd");
        when(userRepository.save(any(User.class))).thenAnswer(i -> i.getArgument(0));
        when(tokenProvider.generateToken(any(), any(), any(), eq(false))).thenReturn("mock-jwt-token");

        RegisterRequest request = new RegisterRequest();
        request.setUsername("alex");
        request.setDisplayName("Alex V");
        request.setPassword("secret123");

        AuthResponse response = authService.register(request);

        assertNotNull(response);
        assertEquals("alex", response.getUsername());
        assertFalse(response.isGuest());
    }

    @Test
    void testRegisterDuplicateUsername() {
        when(userRepository.existsByUsername("alex")).thenReturn(true);

        RegisterRequest request = new RegisterRequest();
        request.setUsername("alex");
        request.setDisplayName("Alex V");
        request.setPassword("secret123");

        assertThrows(BadRequestException.class, () -> authService.register(request));
    }

    @Test
    void testLoginSuccess() {
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setUsername("alex");
        user.setDisplayName("Alex V");
        user.setPasswordHash("hashed-pwd");
        user.setGuest(false);

        when(userRepository.findByUsername("alex")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("secret123", "hashed-pwd")).thenReturn(true);
        when(tokenProvider.generateToken(any(), any(), any(), eq(false))).thenReturn("token-123");

        LoginRequest request = new LoginRequest();
        request.setUsername("alex");
        request.setPassword("secret123");

        AuthResponse response = authService.login(request);
        assertNotNull(response);
        assertEquals("token-123", response.getToken());
    }

    @Test
    void testLoginWrongPassword() {
        User user = new User();
        user.setUsername("alex");
        user.setPasswordHash("hashed-pwd");

        when(userRepository.findByUsername("alex")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrong", "hashed-pwd")).thenReturn(false);

        LoginRequest request = new LoginRequest();
        request.setUsername("alex");
        request.setPassword("wrong");

        assertThrows(UnauthorizedException.class, () -> authService.login(request));
    }
}
