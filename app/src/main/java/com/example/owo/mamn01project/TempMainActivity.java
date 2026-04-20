package com.example.owo.mamn01project;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
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

public class TempMainActivity extends AppCompatActivity {
    private TextView textView;

    private Button btnSpellingBee;
    private Button btnDictionary;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_temp_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        textView = findViewById(R.id.textView);
        btnSpellingBee = findViewById(R.id.btnSpeak);
        btnDictionary = findViewById(R.id.btnDictionary);

        // Check permission
        Helpers.ensureAudioPermission(this);

        btnSpellingBee.setOnClickListener(v -> {
            var databaseHelper = new DatabaseHelper(this);
            String section = "D";
            String randomWord = databaseHelper.getRandomUncollectedWordForSection(DictionaryActivity.PLAYER_ID, section);
            Log.d("TempMainActivity", "Random Word Selected: " + randomWord);

            Bundle b = new Bundle();
            b.putString("spellingBeeWord", randomWord);
            Intent intent = new Intent(TempMainActivity.this, SpellingBeeActivity.class);
            intent.putExtras(b);
            startActivity(intent);
        });

        btnDictionary.setOnClickListener(v -> {
            Intent intent = new Intent(TempMainActivity.this, DictionaryActivity.class);
            startActivity(intent);
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
}