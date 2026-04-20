package com.example.owo.mamn01project.LetterRecognition;

import java.util.List;

/**
 * Interface for receiving callbacks from the LetterRecognizer when it starts listening, encounters an error, or receives a result.
 */
public interface LetterRecognizerListener {
    /**
     * Called when the recognizer starts listening for speech.
     */
    void onStartListening();

    /**
     * Called when an error occurs during recognition, with a human-readable error message.
     * @param errorString
     */
    void onError(String errorString);
    /**
     * Called when the listener receives a result. The listener stops listening after receiving a result, so this callback will only be called once per call to startListening.
     * @param letters The list of letters that were recognized.
     */
    void onResult(List<Letter> letters);
}