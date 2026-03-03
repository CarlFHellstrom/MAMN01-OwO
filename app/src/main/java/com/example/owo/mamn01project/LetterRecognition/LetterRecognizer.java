package com.example.owo.mamn01project.LetterRecognition;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class LetterRecognizer {

    LetterRecognizerListener listener = null;

    private SpeechRecognizer speechRecognizer;
    private Intent speechIntent;

    public LetterRecognizer(Activity activity){
        // Initialize SpeechRecognizer
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(activity);

        speechIntent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
        speechIntent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-GB");

        speechRecognizer.setRecognitionListener(new RecognitionListener() {
            @Override
            public void onReadyForSpeech(Bundle params) {
                Log.d("[Voice]", "Ready for speech...");
            }
            @Override
            public void onBeginningOfSpeech() {}
            @Override
            public void onRmsChanged(float rmsdB) {}
            @Override
            public void onBufferReceived(byte[] buffer) {}
            @Override
            public void onEndOfSpeech() {}
            @Override
            public void onError(int error) {
                String error_string;
                switch (error) {
                    case SpeechRecognizer.ERROR_NETWORK_TIMEOUT:
                        error_string = "Network Timeout";
                        break;
                    case SpeechRecognizer.ERROR_NO_MATCH:
                        error_string = "No Match";
                        break;
                    case SpeechRecognizer.ERROR_CLIENT:
                        error_string = "Client";
                        break;
                    default:
                        error_string = String.valueOf(error);
                        break;
                }

                Log.d("[Voice]", "Error: " + error_string);
                listener.onError(error_string);
            }
            @Override
            public void onResults(Bundle results) {
                StringBuilder resultsBuilder = new StringBuilder();
                ArrayList<String> matches = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                if (matches == null || matches.isEmpty()) {
                    return;
                }
                String raw_match = matches.get(0);
                Log.d("[Voice]", "Raw match: " + raw_match);

                List<Letter> processed_match = MatchProcessor.processMatch(raw_match);

                Log.d("[Voice]", "Processed Match: " + processed_match);
                listener.onResult(processed_match);
            }
            @Override
            public void onPartialResults(Bundle partialResults) {}
            @Override
            public void onEvent(int eventType, Bundle params) {}
        });
    }

    public void setListener(LetterRecognizerListener listener) {
        this.listener = listener;
    }

    public void startListening() {
        if(listener == null) {
            throw new IllegalStateException("Listener may not be null when starting listening");
        }
        speechRecognizer.startListening(speechIntent);
        listener.onStartListening();
    }
}