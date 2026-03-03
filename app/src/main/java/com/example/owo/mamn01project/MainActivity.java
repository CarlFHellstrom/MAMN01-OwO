package com.example.owo.mamn01project;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.owo.mamn01project.LetterRecognition.Helpers;
import com.example.owo.mamn01project.LetterRecognition.Letter;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizer;
import com.example.owo.mamn01project.LetterRecognition.LetterRecognizerListener;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private SpeechRecognizer speechRecognizer;
    private LetterRecognizer letterRecognizer;
    private Intent speechIntent;
    private TextView textView;

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
        Button btnSpeak = findViewById(R.id.btnSpeak);

        // Check permission
        Helpers.ensureAudioPermission(this);

        // Initialise LetterRecognizer
        letterRecognizer = new LetterRecognizer(this);

        letterRecognizer.setListener(new LetterRecognizerListener() {
            @Override
            public void onStartListening() {
                textView.setText("Listening...");
            }
            @Override
            public void onError(String errorString) {
                textView.setText(errorString);
            }
            @Override
            public void onResult(List<Letter> letters) {
                var result_string = letters.stream()
                        .map(Letter::toString)
                        .reduce((a, b) -> a + ", " + b)
                        .orElse("No result.");
                textView.setText(result_string);
            }
        });

        btnSpeak.setOnClickListener(v -> letterRecognizer.startListening());
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