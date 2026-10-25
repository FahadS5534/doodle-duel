package com.doodleduel.games;

import com.doodleduel.users.User;
import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "match_player_results", uniqueConstraints = {
        @UniqueConstraint(name = "uq_match_player", columnNames = {"match_id", "player_id"})
})
public class MatchPlayerResult {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "match_id", nullable = false)
    private GameMatch match;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "player_id", nullable = false)
    private User player;

    @Column(name = "final_score", nullable = false)
    private int finalScore = 0;

    @Column(name = "rank_position", nullable = false)
    private int rankPosition = 1;

    @Column(name = "correct_guesses", nullable = false)
    private int correctGuesses = 0;

    @Column(name = "rounds_drawn", nullable = false)
    private int roundsDrawn = 0;

    @Column(name = "xp_earned", nullable = false)
    private int xpEarned = 0;

    public MatchPlayerResult() {
    }

    @PrePersist
    protected void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public GameMatch getMatch() {
        return match;
    }

    public void setMatch(GameMatch match) {
        this.match = match;
    }

    public User getPlayer() {
        return player;
    }

    public void setPlayer(User player) {
        this.player = player;
    }

    public int getFinalScore() {
        return finalScore;
    }

    public void setFinalScore(int finalScore) {
        this.finalScore = finalScore;
    }

    public int getRankPosition() {
        return rankPosition;
    }

    public void setRankPosition(int rankPosition) {
        this.rankPosition = rankPosition;
    }

    public int getCorrectGuesses() {
        return correctGuesses;
    }

    public void setCorrectGuesses(int correctGuesses) {
        this.correctGuesses = correctGuesses;
    }

    public int getRoundsDrawn() {
        return roundsDrawn;
    }

    public void setRoundsDrawn(int roundsDrawn) {
        this.roundsDrawn = roundsDrawn;
    }

    public int getXpEarned() {
        return xpEarned;
    }

    public void setXpEarned(int xpEarned) {
        this.xpEarned = xpEarned;
    }
}
