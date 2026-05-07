package com.example.owo.mamn01project;

import android.content.Context;
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.example.owo.mamn01project.LetterRecognition.Helpers;

import java.util.Arrays;
import java.util.List;

public class SearchActivity extends AppCompatActivity {

    private SensorManager sensorManager;
    private Sensor accelerometer;
    private Vibrator vibrator;
    private ImageView selectedLetterCenter;
    private View selectedLetterContainer;
    //test
    private ProgressBar selectionProgress;
    private Handler handler = new Handler();
    private Runnable progressRunnable;

    private int progress = 0;

    //end test
    private ImageView selectionCircle;

    private ImageView currentLetter;
    private ImageView[] letters;

    private final String[] letterValues = {
            "F", "K", "W", "A", "V", "D", "E", "M", "I"
    };
    private int selectedIndex = 0;
    private View overlay;
    private View dim;
    private View card;

    private TextView tutorialTitle;
    private TextView tutorialBody;

    private ImageView tutorialImage;


    private View rowSkipView;
    private View rowStepNavigation;
    private long lastTiltTime = 0;

    private boolean doneSelecting = false;

    private int stepIndex = -1;

    private final List<String> steps = Arrays.asList(
            "Step 1: Tilt your phone left or right to move the selector between the guild letters.",

            "Step 2: Hold the selector still on a letter to choose it.",

            "Step 3: A new word from that guild will appear automatically.",

            "Step 4: Press the 'Play Word' button to hear the word before spelling.",

            "Step 5: Press 'Start Listening' and say the word out loud. You have 3 tries.",

            "Step 6: Spell the word correctly to save it to your dictionary."
    );

    private final SensorEventListener sensorListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent event) {
            float x = event.values[0];

            tilt((int) x);
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_search);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        // Ensure permissions
        Helpers.ensureAudioPermission(this);

        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);

        selectionCircle = findViewById(R.id.selectionCircle);

        letters = new ImageView[] {
                findViewById(R.id.letterF),
                findViewById(R.id.letterK),
                findViewById(R.id.letterW),
                findViewById(R.id.letterA),
                findViewById(R.id.letterV),
                findViewById(R.id.letterD),
                findViewById(R.id.letterE),
                findViewById(R.id.letterM),
                findViewById(R.id.letterI)
        };

        currentLetter = findViewById(R.id.currentLetter);
        selectedLetterCenter = findViewById(R.id.selectedLetterCenter);
        selectedLetterContainer = findViewById(R.id.selectedLetterContainer);

        //test
        selectionProgress = findViewById(R.id.selectionProgress);

        overlay = findViewById(R.id.tutorialOverlay);
        dim = findViewById(R.id.tutorialDim);
        card = findViewById(R.id.tutorialCard);

        tutorialTitle = findViewById(R.id.tutorialTitle);
        tutorialBody = findViewById(R.id.tutorialBody);

        tutorialImage = findViewById(R.id.tutorialImage);

        rowSkipView = findViewById(R.id.rowSkipView);

        rowStepNavigation = findViewById(R.id.rowStepNavigation);

        View btnClose = findViewById(R.id.btnClose);
        View btnSkip = findViewById(R.id.btnSkip);
        View btnView = findViewById(R.id.btnView);

        Button btnOpenDictionary = findViewById(R.id.btnOpenDictionary);
        Button btnOpenTutorial = findViewById(R.id.btnOpenTutorial);

        View btnBack = findViewById(R.id.btnBack);
        View btnNext = findViewById(R.id.btnNext);

        showTutorialIntro(true);

        btnClose.setOnClickListener(v -> hideTutorial());
        btnSkip.setOnClickListener(v -> hideTutorial());
        btnView.setOnClickListener(v -> showStep(0));
        btnBack.setOnClickListener(v -> showStep(stepIndex - 1));
        btnNext.setOnClickListener(v -> showStep(stepIndex + 1));

        btnOpenDictionary.setOnClickListener(v -> {
            Intent intent = new Intent(SearchActivity.this, DictionaryActivity.class);
            startActivity(intent);
        });

        btnOpenTutorial.setOnClickListener(v -> showTutorialIntro(true));

        dim.setOnClickListener(v -> hideTutorial());
        selectionCircle.post(this::moveSelection);
        moveSelection();
    }

    @Override
    protected void onResume() {
        super.onResume();
        sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_UI);

        doneSelecting = false;
        selectedLetterContainer.setVisibility(View.GONE);
        resetSelectionProgress();
    }

    @Override
    protected void onPause() {
        super.onPause();
        sensorManager.unregisterListener(sensorListener);
        resetSelectionProgress();
    }

    private void showTutorialIntro(boolean interactable) {
        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(interactable);
        tutorialImage.setVisibility(View.GONE);

        tutorialTitle.setText("Tutorial");
        tutorialBody.setText("Welcome! Want to view the tutorial?");

        rowSkipView.setVisibility(View.VISIBLE);
        rowStepNavigation.setVisibility(View.GONE);

        stepIndex = -1;
    }

    private void showStep(int index) {
        if (index < 0) {
            showTutorialIntro(true);
            return;
        }

        tutorialImage.setVisibility(View.VISIBLE);

        //Bilden
        if (index == 0) {
            tutorialImage.setImageResource(R.drawable.tilt1);
        }

        if (index >= steps.size()) {
            hideTutorial();
            return;
        }
        //tutorialImage.setImageResource(stepImages.get(index));


        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(true);

        stepIndex = index;

        tutorialTitle.setText("Tutorial (" + (index + 1) + "/" + steps.size() + ")");
        tutorialBody.setText(steps.get(index));

        rowSkipView.setVisibility(View.GONE);
        rowStepNavigation.setVisibility(View.VISIBLE);

        View btnBack = findViewById(R.id.btnBack);
        Button btnNext = findViewById(R.id.btnNext);

        btnBack.setEnabled(index > 0);
        btnBack.setAlpha(index > 0 ? 1f : 0.5f);

        if (index == steps.size() - 1) {
            btnNext.setText("Done");
        } else {
            btnNext.setText("Next");
        }
    }

    private void moveSelection() {
        ImageView selected = letters[selectedIndex];

        selectionCircle.setX(selected.getX() - 10);
        selectionCircle.setY(selected.getY() - 10);
        currentLetter.setImageDrawable(selected.getDrawable());
    }

    private void vibrate() {
        if (vibrator != null && vibrator.hasVibrator()) {
            vibrator.vibrate(
                    VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE)
            );
        }
    }
    private void tilt(int x){
        if (doneSelecting) return;
        if (overlay.getVisibility() == View.VISIBLE) return;

        long now = System.currentTimeMillis();

        if (now - lastTiltTime < 500) return;

        boolean moved = false;

        if (x > 4) {
            selectedIndex--;
            moved = true;
        } else if (x < -4) {
            selectedIndex++;
            moved = true;
        }

        // bounds
        if (selectedIndex < 0) {
            selectedIndex = letters.length - 1; // hoppa till sista (I)
        } else if (selectedIndex >= letters.length) {
            selectedIndex = 0; // hoppa till första (F)
        }

        //ändrat
        if (moved) {
            lastTiltTime = now;
            vibrate();
            moveSelection();

            resetSelectionProgress();
            startSelectionProgress();
        }
    }
    private void hideTutorial() {
        overlay.setVisibility(View.GONE);
        stepIndex = -1;
    }

    private void startGame(String section)  {
        Log.d("SearchActivity", "Starting Game with Section " + section);
        var databaseHelper = new DatabaseHelper(this);
        String randomWord = databaseHelper.getRandomUncollectedWordForSection(DictionaryActivity.PLAYER_ID, section);
        Log.d("SearchActivity", "Random Word Selected: " + randomWord);

        Bundle b = new Bundle();
        b.putString("spellingBeeWord", randomWord);
        Intent intent = new Intent(SearchActivity.this, SpellingBeeActivity.class);
        intent.putExtras(b);
        startActivity(intent);
    }
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }
    private void startSelectionProgress() {
        handler.removeCallbacks(progressRunnable);
        progress = 0;
        selectionProgress.setProgress(0);

        progressRunnable = new Runnable() {
            @Override
            public void run() {
                if(doneSelecting) return;

                progress += 2;
                selectionProgress.setProgress(progress);

                if (progress >= 100) {
                    vibrator.vibrate(VibrationEffect.createOneShot(100, 200));

                    doneSelecting = true;
                    showSelectedLetter();

                    return;
                }

                handler.postDelayed(this, 50);
            }
        };

        handler.postDelayed(progressRunnable, 50);
    }

    private void showSelectedLetter() {
        ImageView selected = letters[selectedIndex];

        selectedLetterCenter.setImageDrawable(selected.getDrawable());
        selectedLetterContainer.setVisibility(View.VISIBLE);
        System.out.println(selectedIndex);
        String selectedLetter = letterValues[selectedIndex];

        startGame(selectedLetter);
    }
    private void resetSelectionProgress() {
        handler.removeCallbacks(progressRunnable);
        progress = 0;
        selectionProgress.setProgress(0);
    }

    private void setOverlayInteractable(boolean interactable) {
        overlay.setClickable(interactable);
        overlay.setFocusable(interactable);
        overlay.setFocusableInTouchMode(interactable);

        dim.setAlpha(interactable ? 1f : 0f);
        card.setEnabled(interactable);
        card.setAlpha(interactable ? 1f : 0.6f);
    }
}