package com.doodleduel.common;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
@Tag(name = "Health", description = "Application and system health monitoring endpoints")
public class HealthController {

    @GetMapping({"/health", "/api/v1/health"})
    @Operation(summary = "System Health Check", description = "Returns active runtime status for Render and deployment health checks")
    public ResponseEntity<Map<String, Object>> getHealth() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "application", "doodle-duel-backend",
                "timestamp", Instant.now().toString(),
                "actuator", "/actuator/health"
        ));
    }
}
