package com.doodleduel.scoring;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ScoreCalculationService {

    private final int baseGuessScore;
    private final int firstGuessBonus;
    private final int drawerBonusPerGuess;
    private final int drawerMaxBonus;

    public ScoreCalculationService(
            @Value("${app.game.base-guess-score:200}") int baseGuessScore,
            @Value("${app.game.first-guess-bonus:100}") int firstGuessBonus,
            @Value("${app.game.drawer-bonus-per-guess:50}") int drawerBonusPerGuess,
            @Value("${app.game.drawer-max-bonus:250}") int drawerMaxBonus) {
        this.baseGuessScore = baseGuessScore;
        this.firstGuessBonus = firstGuessBonus;
        this.drawerBonusPerGuess = drawerBonusPerGuess;
        this.drawerMaxBonus = drawerMaxBonus;
    }

    public String normalize(String text) {
        if (text == null) return "";
        return text.trim().toLowerCase()
                .replaceAll("[-_]", " ")
                .replaceAll("[^a-z0-9 ]", "")
                .replaceAll("\\s+", " ")
                .trim();
    }

    public boolean isExactMatch(String guess, String secretWord) {
        return normalize(guess).equals(normalize(secretWord));
    }

    public boolean isCloseMatch(String guess, String secretWord) {
        String normGuess = normalize(guess);
        String normSecret = normalize(secretWord);

        if (normGuess.isEmpty() || normSecret.isEmpty()) return false;
        if (normGuess.equals(normSecret)) return false;

        // Substring check
        if (normSecret.contains(normGuess) && normGuess.length() >= 4) return true;
        if (normGuess.contains(normSecret)) return true;

        // Levenshtein distance <= 2 for words longer than 4 chars
        if (normSecret.length() >= 4 && Math.abs(normGuess.length() - normSecret.length()) <= 2) {
            return computeLevenshteinDistance(normGuess, normSecret) <= 2;
        }

        return false;
    }

    public int calculateGuesserScore(long remainingSeconds, long totalSeconds, boolean isFirstCorrect) {
        double ratio = totalSeconds > 0 ? (double) Math.max(0, remainingSeconds) / totalSeconds : 0.0;
        int speedBonus = (int) Math.round(ratio * 150.0);
        int score = baseGuessScore + speedBonus;
        if (isFirstCorrect) {
            score += firstGuessBonus;
        }
        return score;
    }

    public int calculateDrawerScore(int totalCorrectGuesserCount) {
        int earned = totalCorrectGuesserCount * drawerBonusPerGuess;
        return Math.min(earned, drawerMaxBonus);
    }

    private int computeLevenshteinDistance(String a, String b) {
        int[] costs = new int[b.length() + 1];
        for (int j = 0; j < costs.length; j++) costs[j] = j;
        for (int i = 1; i <= a.length(); i++) {
            costs[0] = i;
            int nw = i - 1;
            for (int j = 1; j <= b.length(); j++) {
                int cj = Math.min(1 + Math.min(costs[j], costs[j - 1]),
                        a.charAt(i - 1) == b.charAt(j - 1) ? nw : nw + 1);
                nw = costs[j];
                costs[j] = cj;
            }
        }
        return costs[b.length()];
    }
}
