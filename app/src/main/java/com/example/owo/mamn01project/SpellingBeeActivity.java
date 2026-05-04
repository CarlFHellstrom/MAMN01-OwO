package com.example.owo.mamn01project;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.owo.mamn01project.Feedback.FeedbackGenerator;
import com.example.owo.mamn01project.LetterRecognition.Letter;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizer;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizerListener;
import com.example.owo.mamn01project.SpellingBeeGame.Word;

import java.util.List;
import java.util.Locale;

public class SpellingBeeActivity extends AppCompatActivity {

    private Button speakButton;
    private Button listenButton;
    private TextView playerGuess;
    private TextView triesLeft;

    private TextView endText;
    private TextView endStatusText;
    private Button continueButton;

    private LinearLayout gameLayout;
    private LinearLayout endLayout;
    private Word word;
    private int tries = 3;
    private TextToSpeech tts;
    private LetterRecognizer letterRecognizer;
    private DatabaseHelper databaseHelper;

    private FeedbackGenerator feedbackGenerator;

    private boolean won = false;

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

            feedbackGenerator = new FeedbackGenerator(getApplicationContext());

            speakButton = findViewById(R.id.speakButton);
            listenButton = findViewById(R.id.listenButton);
            playerGuess = findViewById(R.id.playerGuess);
            triesLeft = findViewById(R.id.triesLeft);

            endText = findViewById(R.id.endText);
            endStatusText = findViewById(R.id.endStatusText);
            continueButton = findViewById(R.id.continueButton);

            endLayout = findViewById(R.id.endLayout);
            gameLayout = findViewById(R.id.gameLayout);

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

            databaseHelper = new DatabaseHelper(this);

            Bundle b = getIntent().getExtras();
            if(b == null) throw new IllegalStateException("Bundle may not be null");
            String givenWord = b.getString("spellingBeeWord", "SOIL");
            word = new Word(givenWord);

            speakButton.setOnClickListener(v -> onSpeakButtonClick());
            listenButton.setOnClickListener(v -> onListenButtonClick());

            continueButton.setOnClickListener(v -> {
                if(won) {
                    var intent = new Intent(SpellingBeeActivity.this, DictionaryActivity.class);
                    startActivity(intent);
                    finish();
                } else {
                    finish();
                }
            });
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

            endText.setText("You Win!");
            endStatusText.setText("Word Added to Collection: " + word.toString());
            databaseHelper.saveCollectedWord(DictionaryActivity.PLAYER_ID, word.toString());
            won = true;
            feedbackGenerator.playFanfare();

            gameLayout.setVisibility(View.GONE);
            endLayout.setVisibility(View.VISIBLE);

        } else {
            // Player Guessed Incorrectly
            SpannableString feedback = generatePositionFeedback(word.toString(), guessedWord.toString());
            playerGuess.setText("Try again: " + feedback);
            playerGuess.setTextColor(Color.RED);
            tries -= 1;
            if(tries <= 0) {
                // Player Loses
                playerGuess.setText("Game Over! The word was: " + word.toString());
                speakButton.setEnabled(false);

                endText.setText("You Lose!");
                endStatusText.setText("The Word was: " + word.toString());
                won = false;
                feedbackGenerator.playFailure();

                gameLayout.setVisibility(View.GONE);
                endLayout.setVisibility(View.VISIBLE);
            } else if (tries == 1) {
                triesLeft.setText("1 try left!");
                feedbackGenerator.playError();
            } else {
                triesLeft.setText(tries + " tries left!");
                feedbackGenerator.playError();
            }
        }

    }

    private SpannableString generatePositionFeedback(String targetWord, String guessedWord) {
        String target = targetWord.toUpperCase();
        String guess = guessedWord.toUpperCase();

        StringBuilder raw = new StringBuilder();
        int errorIndex = -1;

        for (int i = 0; i < target.length(); i++) {
            if (i >= guess.length()) {
                raw.append('_');
            } else if (target.charAt(i) == guess.charAt(i)) {
                raw.append(target.charAt(i));
            } else {
                raw.append('?');
                errorIndex = i;

                for (int j = i + 1; j < target.length(); j++) {
                    raw.append('_');
                }
                break;
            }
        }

        SpannableString spannable = new SpannableString(raw.toString());

        // Color correct letters black (default)
        // Color wrong position red
        if (errorIndex != -1) {
            spannable.setSpan(
                    new ForegroundColorSpan(Color.RED),
                    errorIndex,
                    errorIndex + 1,
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
            );
        }

        return spannable;
    }
    private void onListenButtonClick() {
        String wordString = word.toString();
        tts.speak(wordString, TextToSpeech.QUEUE_FLUSH, null, "SpellingBeeWord");
        speakButton.setEnabled(true);
        // set background tint to background @color/olive_green
        speakButton.setBackgroundTintList(getResources().getColorStateList(R.color.forest_green));
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