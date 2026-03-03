package com.example.owo.mamn01project.LetterRecognition;

import java.util.Locale;

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
    X,
    Y,
    Z;

    public static Letter fromString(String string) {
        try {
            return valueOf(string.toUpperCase(Locale.UK));
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}