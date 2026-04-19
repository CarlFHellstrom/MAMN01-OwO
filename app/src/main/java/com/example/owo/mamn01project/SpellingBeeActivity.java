package com.example.owo.mamn01project;

import android.graphics.Color;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.owo.mamn01project.LetterRecognition.Letter;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizer;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizerListener;
import com.example.owo.mamn01project.SpellingBeeGame.Word;

import org.w3c.dom.Text;

import java.util.List;
import java.util.Locale;

public class SpellingBeeActivity extends AppCompatActivity {

    private Button speakButton;
    private Button listenButton;
    private TextView playerGuess;
    private TextView triesLeft;
    private Word word;
    private int tries = 3;
    private TextToSpeech tts;
    private LetterRecognizer letterRecognizer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_spelling_bee);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

            speakButton = findViewById(R.id.speakButton);
            listenButton = findViewById(R.id.listenButton);
            playerGuess = findViewById(R.id.playerGuess);
            triesLeft = findViewById(R.id.triesLeft);

            word = new Word("HOME");

            tts = new TextToSpeech(this, i -> {
                if (i != TextToSpeech.ERROR) {
                    tts.setLanguage(Locale.UK);
                    Log.d("SpellingBeeActivity", "TTS initialized successfully");
                } else {
                    Log.d("SpellingBeeActivity", "TTS initialization failed");
                    throw new RuntimeException("TTS initialization failed");
                }
            });

            letterRecognizer = new LetterRecognizer(this);
            letterRecognizer.setListener(new LetterRecognizerListener() {
                @Override
                public void onStartListening() {
                    onStartSpeak();
                }
                @Override
                public void onError(String errorString) {
                    onSpeakError(errorString);
                }
                @Override
                public void onResult(List<Letter> letters) {
                    Word guessedWord = new Word(letters);
                    onFinishedSpeak(guessedWord);
                }
            });

            speakButton.setOnClickListener(v -> onSpeakButtonClick());
            listenButton.setOnClickListener(v -> onListenButtonClick());
    }

    private void onSpeakButtonClick() {
        letterRecognizer.startListening();
    }

    private void onStartSpeak() {
        speakButton.setEnabled(false);
        listenButton.setEnabled(false);
    }

    private void onSpeakError(String errorString) {
        speakButton.setEnabled(true);
        listenButton.setEnabled(true);
        playerGuess.setText("Error:" + errorString);
    }

    private void onFinishedSpeak(Word guessedWord) {
        speakButton.setEnabled(true);
        listenButton.setEnabled(true);

        if (guessedWord.equals(word)) {
            // Player Guessed Correctly and Wins
            playerGuess.setText("Correct: " + guessedWord);
            playerGuess.setTextColor(Color.GREEN);
            speakButton.setEnabled(false);
        } else {
            // Player Guessed Incorrectly
            playerGuess.setText("Incorrect: " + guessedWord);
            playerGuess.setTextColor(Color.RED);
            tries -= 1;
            if(tries <= 0) {
                // Player Loses
                playerGuess.setText("Game Over! The word was: " + word.toString());
                speakButton.setEnabled(false);
            } else if (tries == 1) {
                triesLeft.setText("1 try left!");
            } else {
                triesLeft.setText(tries + " tries left!");
            }
        }


    }

    private void onListenButtonClick() {
        String wordString = word.toString();
        tts.speak(wordString, TextToSpeech.QUEUE_FLUSH, null, "SpellingBeeWord");
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (tts != null) {
            tts.stop();
            tts.shutdown();
        }
        if (letterRecognizer != null) {
            letterRecognizer.destroy();
        }
    }
}