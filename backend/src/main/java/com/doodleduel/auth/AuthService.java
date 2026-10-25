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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.Random;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final Random random = new Random();

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    @Transactional
    public AuthResponse loginAsGuest(GuestLoginRequest request) {
        String randomSuffix = String.format("%04d", random.nextInt(10000));
        String username = "guest_" + randomSuffix + "_" + UUID.randomUUID().toString().substring(0, 4);

        String displayName = "Doodler " + randomSuffix;
        if (request != null && StringUtils.hasText(request.getDisplayName())) {
            displayName = request.getDisplayName().trim();
        }

        String avatarUrl = (request != null && StringUtils.hasText(request.getAvatarUrl()))
                ? request.getAvatarUrl()
                : "https://api.dicebear.com/7.x/bottts/png?seed=" + username;

        User user = new User();
        user.setId(UUID.randomUUID());
        user.setUsername(username);
        user.setDisplayName(displayName);
        user.setGuest(true);
        user.setAvatarUrl(avatarUrl);
        user.setLevel(1);
        user.setXp(50);
        user.setCoins(1000);
        user.setStreak(1);

        user = userRepository.save(user);

        String token = tokenProvider.generateToken(user.getId(), user.getUsername(), user.getDisplayName(), true);

        return new AuthResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.isGuest(),
                user.getAvatarUrl(),
                user.getLevel(),
                user.getXp(),
                user.getCoins(),
                user.getStreak()
        );
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername().trim().toLowerCase())) {
            throw new BadRequestException("Username is already taken");
        }

        String avatarUrl = StringUtils.hasText(request.getAvatarUrl())
                ? request.getAvatarUrl()
                : "https://api.dicebear.com/7.x/bottts/png?seed=" + request.getUsername().trim().toLowerCase();

        User user = new User();
        user.setId(UUID.randomUUID());
        user.setUsername(request.getUsername().trim().toLowerCase());
        user.setDisplayName(request.getDisplayName().trim());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setGuest(false);
        user.setAvatarUrl(avatarUrl);
        user.setLevel(1);
        user.setXp(100);
        user.setCoins(1200);
        user.setStreak(1);

        user = userRepository.save(user);

        String token = tokenProvider.generateToken(user.getId(), user.getUsername(), user.getDisplayName(), false);

        return new AuthResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.isGuest(),
                user.getAvatarUrl(),
                user.getLevel(),
                user.getXp(),
                user.getCoins(),
                user.getStreak()
        );
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        String username = request.getUsername().trim().toLowerCase();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UnauthorizedException("Invalid username or password"));

        if (user.getPasswordHash() == null || !passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid username or password");
        }

        String token = tokenProvider.generateToken(user.getId(), user.getUsername(), user.getDisplayName(), user.isGuest());

        return new AuthResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.isGuest(),
                user.getAvatarUrl(),
                user.getLevel(),
                user.getXp(),
                user.getCoins(),
                user.getStreak()
        );
    }
}
