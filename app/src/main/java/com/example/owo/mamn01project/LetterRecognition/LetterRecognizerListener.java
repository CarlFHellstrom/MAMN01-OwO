package com.example.owo.mamn01project.LetterRecognition;

import java.util.List;

public interface LetterRecognizerListener {
    void onStartListening();
    void onError(String errorString);
    void onResult(List<Letter> letters);
}