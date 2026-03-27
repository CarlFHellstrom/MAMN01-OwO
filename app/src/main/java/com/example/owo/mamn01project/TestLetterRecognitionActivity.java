package com.example.owo.mamn01project;

import android.content.Intent;
import android.os.Bundle;
import android.speech.SpeechRecognizer;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.owo.mamn01project.LetterRecognition.Helpers;
import com.example.owo.mamn01project.LetterRecognition.Letter;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizer;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizerListener;

import java.util.List;

public class TestLetterRecognitionActivity extends AppCompatActivity {

    private SpeechRecognizer speechRecognizer;
    private LetterRecognizer letterRecognizer;
    private Intent speechIntent;
    private TextView textView;

    private Button btnSpeak;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        textView = findViewById(R.id.textView);
        btnSpeak = findViewById(R.id.btnSpeak);

        // Check permission
        Helpers.ensureAudioPermission(this);

        // Initialise LetterRecognizer
        letterRecognizer = new LetterRecognizer(this);

        letterRecognizer.setListener(new LetterRecognizerListener() {
            @Override
            public void onStartListening() {
                textView.setText("Listening...");
                setButtonState(true);
            }
            @Override
            public void onError(String errorString) {
                textView.setText(errorString);
                setButtonState(false);
            }
            @Override
            public void onResult(List<Letter> letters) {
                var result_string = letters.stream()
                        .map(Letter::toString)
                        .reduce((a, b) -> a + ", " + b)
                        .orElse("No result.");
                textView.setText(result_string);
                setButtonState(false);
            }
        });

        btnSpeak.setOnClickListener(v -> {
            letterRecognizer.startListening();
            setButtonState(true);
        });
    }

    private void setButtonState(boolean isListening) {
        btnSpeak.setEnabled(!isListening);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (speechRecognizer != null) {
            speechRecognizer.destroy();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}