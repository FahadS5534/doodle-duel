package com.doodleduel.scoring;

import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class WordBankService {

    private final List<WordPrompt> wordList = new ArrayList<>();
    private final Random random = new Random();

    public WordBankService() {
        initWordBank();
    }

    private void initWordBank() {
        // FOOD
        wordList.add(new WordPrompt("Pizza", "FOOD", "EASY", "Cheesy slice with crust"));
        wordList.add(new WordPrompt("Flying Pizza", "FOOD", "HARD", "Delicious fast food with angelic wings"));
        wordList.add(new WordPrompt("Burger", "FOOD", "EASY", "Bun with patty and lettuce"));
        wordList.add(new WordPrompt("Ice Cream", "FOOD", "EASY", "Cold sweet treat in a cone"));
        wordList.add(new WordPrompt("Sushi", "FOOD", "MEDIUM", "Rice roll with fish and seaweed"));
        wordList.add(new WordPrompt("Pancake", "FOOD", "EASY", "Flat round cake topped with syrup"));
        wordList.add(new WordPrompt("Taco", "FOOD", "EASY", "Folded tortilla filled with meat"));
        wordList.add(new WordPrompt("Donut", "FOOD", "EASY", "Fried dough with a hole in the middle"));
        wordList.add(new WordPrompt("Watermelon", "FOOD", "EASY", "Large green fruit with red sweet inside"));
        wordList.add(new WordPrompt("Croissant", "FOOD", "MEDIUM", "Flaky crescent-shaped pastry"));

        // ANIMALS
        wordList.add(new WordPrompt("Cat", "ANIMALS", "EASY", "Whiskered feline pet"));
        wordList.add(new WordPrompt("Cybernetic Cat", "ANIMALS", "HARD", "Futuristic mechanical feline with neon eyes"));
        wordList.add(new WordPrompt("Dog on Moon", "ANIMALS", "HARD", "Canine explorer wearing a space helmet"));
        wordList.add(new WordPrompt("Penguin", "ANIMALS", "EASY", "Flightless bird in a tuxedo"));
        wordList.add(new WordPrompt("Elephant", "ANIMALS", "EASY", "Giant animal with a long trunk"));
        wordList.add(new WordPrompt("Giraffe", "ANIMALS", "EASY", "Tallest animal with long neck"));
        wordList.add(new WordPrompt("Dolphin", "ANIMALS", "MEDIUM", "Playful aquatic mammal"));
        wordList.add(new WordPrompt("Octopus", "ANIMALS", "MEDIUM", "Sea creature with eight arms"));
        wordList.add(new WordPrompt("Kangaroo", "ANIMALS", "MEDIUM", "Hopping marsupial with a pouch"));
        wordList.add(new WordPrompt("Panda", "ANIMALS", "EASY", "Black and white bamboo lover"));

        // OBJECTS
        wordList.add(new WordPrompt("Spaceship", "OBJECTS", "MEDIUM", "Rocket vehicle for interstellar travel"));
        wordList.add(new WordPrompt("Guitar", "OBJECTS", "EASY", "String instrument played with fingers"));
        wordList.add(new WordPrompt("Bicycle", "OBJECTS", "EASY", "Two-wheeled pedal vehicle"));
        wordList.add(new WordPrompt("Camera", "OBJECTS", "EASY", "Device used to take photos"));
        wordList.add(new WordPrompt("Telescope", "OBJECTS", "MEDIUM", "Optical tube for viewing distant stars"));
        wordList.add(new WordPrompt("Submarine", "OBJECTS", "MEDIUM", "Undersea naval vessel"));
        wordList.add(new WordPrompt("Clock", "OBJECTS", "EASY", "Tells the time with hands"));
        wordList.add(new WordPrompt("Umbrella", "OBJECTS", "EASY", "Keeps you dry when it rains"));
        wordList.add(new WordPrompt("Backpack", "OBJECTS", "EASY", "Bag carried on your shoulders"));
        wordList.add(new WordPrompt("Microscope", "OBJECTS", "HARD", "Laboratory tool to see tiny microbes"));

        // ACTIONS
        wordList.add(new WordPrompt("Swimming", "ACTIONS", "MEDIUM", "Moving through water"));
        wordList.add(new WordPrompt("Dancing", "ACTIONS", "EASY", "Moving rhythmically to music"));
        wordList.add(new WordPrompt("Cooking", "ACTIONS", "EASY", "Preparing food on a stove"));
        wordList.add(new WordPrompt("Painting", "ACTIONS", "EASY", "Using brushes and colors"));
        wordList.add(new WordPrompt("Flying", "ACTIONS", "MEDIUM", "Soaring in the air with wings"));
        wordList.add(new WordPrompt("Fishing", "ACTIONS", "EASY", "Catching fish with a rod"));
        wordList.add(new WordPrompt("Surfing", "ACTIONS", "MEDIUM", "Riding ocean waves on a board"));

        // GENERAL
        wordList.add(new WordPrompt("Campfire", "GENERAL", "EASY", "Outdoor fire with wood"));
        wordList.add(new WordPrompt("Lighthouse", "GENERAL", "MEDIUM", "Tower guiding ships with a beacon"));
        wordList.add(new WordPrompt("Castle", "GENERAL", "EASY", "Fortified stone building with towers"));
        wordList.add(new WordPrompt("Volcano", "GENERAL", "MEDIUM", "Mountain that erupts lava"));
        wordList.add(new WordPrompt("Rainbow", "GENERAL", "EASY", "Colorful arc in the sky"));
        wordList.add(new WordPrompt("Pyramid", "GENERAL", "EASY", "Ancient triangular monument"));
        wordList.add(new WordPrompt("Waterfall", "GENERAL", "MEDIUM", "Water cascading down a cliff"));
    }

    public WordPrompt getRandomPrompt(String category, String difficulty) {
        List<WordPrompt> pool = new ArrayList<>(wordList);

        if (category != null && !"GENERAL".equalsIgnoreCase(category)) {
            List<WordPrompt> filtered = pool.stream()
                    .filter(w -> w.getCategory().equalsIgnoreCase(category))
                    .toList();
            if (!filtered.isEmpty()) {
                pool = filtered;
            }
        }

        if (difficulty != null) {
            List<WordPrompt> diffFiltered = pool.stream()
                    .filter(w -> w.getDifficulty().equalsIgnoreCase(difficulty))
                    .toList();
            if (!diffFiltered.isEmpty()) {
                pool = diffFiltered;
            }
        }

        return pool.get(random.nextInt(pool.size()));
    }
}
