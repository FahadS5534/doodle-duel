package com.doodleduel.scoring;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ScoreCalculationServiceTest {

    private ScoreCalculationService scoreService;

    @BeforeEach
    void setUp() {
        scoreService = new ScoreCalculationService(200, 100, 50, 250);
    }

    @Test
    void testNormalize() {
        assertEquals("pizza", scoreService.normalize("  Pizza!  "));
        assertEquals("flying pizza", scoreService.normalize("Flying-Pizza!"));
        assertEquals("cat", scoreService.normalize("CAT"));
    }

    @Test
    void testExactMatch() {
        assertTrue(scoreService.isExactMatch("pizza", "Pizza"));
        assertTrue(scoreService.isExactMatch("  FLYING PIZZA! ", "flying pizza"));
        assertFalse(scoreService.isExactMatch("burger", "pizza"));
    }

    @Test
    void testCloseMatch() {
        // One character typo
        assertTrue(scoreService.isCloseMatch("pizaa", "pizza"));
        // Substring
        assertTrue(scoreService.isCloseMatch("pizza", "flying pizza"));
        assertFalse(scoreService.isCloseMatch("elephant", "pizza"));
    }

    @Test
    void testScoreCalculations() {
        // First correct guess with full time remaining
        int firstScore = scoreService.calculateGuesserScore(60, 60, true);
        assertEquals(450, firstScore); // 200 base + 150 speed + 100 first

        // Subsequent guess with half time remaining
        int midScore = scoreService.calculateGuesserScore(30, 60, false);
        assertEquals(275, midScore); // 200 base + 75 speed

        // Drawer score with 3 correct guessers
        int drawerScore3 = scoreService.calculateDrawerScore(3);
        assertEquals(150, drawerScore3);

        // Drawer score capped at max 250
        int drawerScoreMax = scoreService.calculateDrawerScore(10);
        assertEquals(250, drawerScoreMax);
    }
}
