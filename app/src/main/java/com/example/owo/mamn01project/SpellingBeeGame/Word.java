package com.example.owo.mamn01project.SpellingBeeGame;

import androidx.annotation.NonNull;

import com.example.owo.mamn01project.LetterRecognition.Letter;

import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * Helper class for representing a word as a list of letters.
 */
public class Word {
    private List<Letter> letters;

     public Word(List<Letter> letters) {
        this.letters = letters;
    }

    public Word(String word) {
        this(
                Arrays.stream(word.split(""))
                    .map(Letter::fromString)
                    .map(o -> Objects.requireNonNull(o, "Non-letter character in word: '" + word + "'"))
                    .collect(Collectors.toList())
        );
    }

     public List<Letter> getLetters() {
        return List.copyOf(letters);
    }

    @NonNull
    @Override
    public String toString() {
        return letters.stream().map(Enum::name).collect(Collectors.joining());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Word word = (Word) o;
        return letters.equals(word.letters);
    }
}
