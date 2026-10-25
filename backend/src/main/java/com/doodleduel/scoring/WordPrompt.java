package com.doodleduel.scoring;

public class WordPrompt {

    private String word;
    private String category;
    private String difficulty; // EASY, MEDIUM, HARD
    private String hint;

    public WordPrompt() {
    }

    public WordPrompt(String word, String category, String difficulty, String hint) {
        this.word = word;
        this.category = category;
        this.difficulty = difficulty;
        this.hint = hint;
    }

    public String getWord() {
        return word;
    }

    public void setWord(String word) {
        this.word = word;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public String getHint() {
        return hint;
    }

    public void setHint(String hint) {
        this.hint = hint;
    }
}
