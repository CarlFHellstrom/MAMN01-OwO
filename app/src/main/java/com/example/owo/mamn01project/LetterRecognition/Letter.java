package com.example.owo.mamn01project.LetterRecognition;

import java.util.Locale;

/**
 * Enum representing the letters of the alphabet that can be recognized by the LetterRecognizer.
 * This enum exists to avoid complications with the character primitive as well as String objects.
 */
public enum Letter {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z;

    /**
     * Converts a string to a Letter enum value, returning null if the string does not correspond to a valid letter.
     * @param string The string to convert, which should be a single letter (case-insensitive).
     * @return The corresponding Letter enum value, or null if the string is not a valid letter.
     */
    public static Letter fromString(String string) {
        try {
            return valueOf(string.toUpperCase(Locale.UK));
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}