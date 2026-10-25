package com.doodleduel.scoring;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class WordBankServiceTest {

    private WordBankService wordBankService;

    @BeforeEach
    void setUp() {
        wordBankService = new WordBankService();
    }

    @Test
    void testGetRandomPrompt() {
        WordPrompt prompt = wordBankService.getRandomPrompt(null, null);
        assertNotNull(prompt);
        assertNotNull(prompt.getWord());
        assertNotNull(prompt.getCategory());
        assertNotNull(prompt.getHint());
    }

    @Test
    void testFilterByCategory() {
        WordPrompt foodPrompt = wordBankService.getRandomPrompt("FOOD", null);
        assertNotNull(foodPrompt);
        assertEquals("FOOD", foodPrompt.getCategory());

        WordPrompt animalPrompt = wordBankService.getRandomPrompt("ANIMALS", null);
        assertNotNull(animalPrompt);
        assertEquals("ANIMALS", animalPrompt.getCategory());
    }
}
