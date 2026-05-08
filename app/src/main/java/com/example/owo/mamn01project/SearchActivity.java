package com.example.owo.mamn01project;

import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
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
import android.view.Window;
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
    private ProgressBar selectionProgress;
    private Handler handler = new Handler();
    private Runnable progressRunnable;
    private int progress = 0;

    private ImageView selectionCircle;
    private ImageView currentLetter;
    private MapOverlayView mapOverlay;

    // Drawables in the same order as MapOverlayView.buildLetters()
    private final int[] letterDrawables = {
            R.drawable.f,
            R.drawable.k,
            R.drawable.w,
            R.drawable.a,
            R.drawable.v,
            R.drawable.d,
            R.drawable.e,
            R.drawable.m,
            R.drawable.i
    };

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

            "Step 3: You can then confirm the chosen guild and be redirected to the spelling bee game.",

            "Step 4: Press the 'Play Word' button to hear the word before spelling.",

            "Step 5: Press 'Start Listening' and say the word out loud. You have 3 tries.",

            "Step 6: Spell the word correctly to save it to your dictionary."
    );

    private final SensorEventListener sensorListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent event) {
            tilt((int) event.values[0]);
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}
    };

    // ------------------------------------------------------------------ //
    //  onCreate
    // ------------------------------------------------------------------ //
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

        Helpers.ensureAudioPermission(this);

        sensorManager  = (SensorManager) getSystemService(SENSOR_SERVICE);
        accelerometer  = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        vibrator       = (Vibrator) getSystemService(VIBRATOR_SERVICE);

        selectionCircle         = findViewById(R.id.selectionCircle);
        currentLetter           = findViewById(R.id.currentLetter);
        selectedLetterCenter    = findViewById(R.id.selectedLetterCenter);
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

        View   btnClose = findViewById(R.id.btnClose);
        View   btnSkip  = findViewById(R.id.btnSkip);
        View   btnView  = findViewById(R.id.btnView);
        View   btnBack  = findViewById(R.id.btnBack);
        Button btnNext  = findViewById(R.id.btnNext);

        Button btnOpenDictionary = findViewById(R.id.btnOpenDictionary);
        Button btnOpenTutorial = findViewById(R.id.btnOpenTutorial);

        View btnBack = findViewById(R.id.btnBack);
        View btnNext = findViewById(R.id.btnNext);

        showTutorialIntro(true);

        btnClose.setOnClickListener(v -> hideTutorial());
        btnSkip .setOnClickListener(v -> hideTutorial());
        btnView .setOnClickListener(v -> showStep(0));
        btnBack .setOnClickListener(v -> showStep(stepIndex - 1));
        btnNext .setOnClickListener(v -> showStep(stepIndex + 1));

        btnOpenDictionary.setOnClickListener(v ->
                startActivity(new Intent(SearchActivity.this, DictionaryActivity.class)));
        btnOpenTutorial.setOnClickListener(v -> showTutorialIntro(true));
        dim.setOnClickListener(v -> hideTutorial());

        mapOverlay.post(this::moveSelection);
    }

    // ------------------------------------------------------------------ //
    //  Lifecycle
    // ------------------------------------------------------------------ //
    @Override
    protected void onResume() {
        super.onResume();
        sensorManager.registerListener(sensorListener, accelerometer,
                SensorManager.SENSOR_DELAY_UI);
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

        if (index >= steps.size()) {
            hideTutorial();
            return;
        }

        tutorialImage.setVisibility(View.VISIBLE);

        // Update images based on step index
        if (index == 0) {
            tutorialImage.setImageResource(R.drawable.tilt1);
        } else if (index == 1) {
            tutorialImage.setImageResource(R.drawable.hold_still);
        } else if (index == 2) {
            tutorialImage.setVisibility(View.GONE);
        } else if (index == 3) {
            tutorialImage.setImageResource(R.drawable.play_word);
        } else if (index == 4) {
            tutorialImage.setImageResource(R.drawable.start_listening2);
        } else if (index == 5) {
            tutorialImage.setImageResource(R.drawable.speaking1);
        }


        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(true);

        stepIndex = index;

        tutorialTitle.setText("Tutorial (" + (index + 1) + "/" + steps.size() + ")");
        tutorialBody.setText(steps.get(index));

        float[] screenPos = mapOverlay.getLetterScreenPosition(drawableRes);
        float screenCx = screenPos[0];
        float screenCy = screenPos[1];

        View root = findViewById(R.id.main);
        int[] rootLoc = new int[2];
        root.getLocationOnScreen(rootLoc);

        float localCx = screenCx - rootLoc[0];
        float localCy = screenCy - rootLoc[1];

        selectionCircle.setX(localCx - selectionCircle.getWidth()  / 2f);
        selectionCircle.setY(localCy - selectionCircle.getHeight() / 2f);

        currentLetter.setImageResource(drawableRes);
    }

    // ------------------------------------------------------------------ //
    //  Tilt navigation
    // ------------------------------------------------------------------ //
    private void tilt(int x) {
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

        if (selectedIndex < 0)                            selectedIndex = letterDrawables.length - 1;
        else if (selectedIndex >= letterDrawables.length) selectedIndex = 0;

        if (moved) {
            lastTiltTime = now;
            vibrate();
            moveSelection();
            resetSelectionProgress();
            startSelectionProgress();
        }
    }

    // ------------------------------------------------------------------ //
    //  Progress bar
    // ------------------------------------------------------------------ //
    private void startSelectionProgress() {
        handler.removeCallbacks(progressRunnable);
        progress = 0;
        selectionProgress.setProgress(0);

        progressRunnable = new Runnable() {
            @Override
            public void run() {
                if (doneSelecting) return;
                progress += 2;
                selectionProgress.setProgress(progress);
                if (progress >= 100) {
                    vibrator.vibrate(VibrationEffect.createOneShot(100, 200));
                    doneSelecting = true;
                    showSectionConfirmation();
                    return;
                }
                handler.postDelayed(this, 50);
            }
        };
        handler.postDelayed(progressRunnable, 50);
    }

    private void resetSelectionProgress() {
        handler.removeCallbacks(progressRunnable);
        progress = 0;
        selectionProgress.setProgress(0);
    }

    // ------------------------------------------------------------------ //
    //  Section confirmation — themed custom dialog
    // ------------------------------------------------------------------ //
    private void showSectionConfirmation() {
        String section   = letterValues[selectedIndex];
        String guildName = section + " Guild";

        // Show the selected letter in the centre popup while the dialog is open
        selectedLetterCenter.setImageResource(letterDrawables[selectedIndex]);
        selectedLetterContainer.setVisibility(View.VISIBLE);

        // Inflate our custom layout into a bare Dialog so we control every pixel
        Dialog dialog = new Dialog(this);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.dialog_section_confirm);

        // Transparent window background so our dark-green card shape shows cleanly
        if (dialog.getWindow() != null) {
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        }

        // Wire up views
        TextView titleView   = dialog.findViewById(R.id.dialogTitle);
        TextView messageView = dialog.findViewById(R.id.dialogMessage);
        Button   btnNo       = dialog.findViewById(R.id.dialogBtnNo);
        Button   btnYes      = dialog.findViewById(R.id.dialogBtnYes);

        titleView.setText("Catch a Letter?");
        messageView.setText("Do you want to catch a letter from the " + guildName + "?");

        // YES — go to the spelling game
        btnYes.setOnClickListener(v -> {
            dialog.dismiss();
            startGame(section);
        });

        // NO — stay on map, reset so player can pick again
        btnNo.setOnClickListener(v -> {
            dialog.dismiss();
            selectedLetterContainer.setVisibility(View.GONE);
            doneSelecting = false;
            resetSelectionProgress();
        });

        // Tapping outside = No
        dialog.setCancelable(true);
        dialog.setOnCancelListener(d -> {
            selectedLetterContainer.setVisibility(View.GONE);
            doneSelecting = false;
            resetSelectionProgress();
        });

        dialog.show();
    }

    // ------------------------------------------------------------------ //
    //  Game
    // ------------------------------------------------------------------ //
    private void startGame(String section) {
        Log.d("SearchActivity", "Starting Game with Section " + section);
        DatabaseHelper databaseHelper = new DatabaseHelper(this);
        String randomWord = databaseHelper.getRandomUncollectedWordForSection(
                DictionaryActivity.PLAYER_ID, section);
        Log.d("SearchActivity", "Random Word Selected: " + randomWord);

        Bundle b = new Bundle();
        b.putString("spellingBeeWord", randomWord);
        Intent intent = new Intent(SearchActivity.this, SpellingBeeActivity.class);
        intent.putExtras(b);
        startActivity(intent);
    }

    // ------------------------------------------------------------------ //
    //  Tutorial
    // ------------------------------------------------------------------ //
    private void showTutorialIntro(boolean interactable) {
        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(interactable);
        tutorialTitle.setText("Tutorial");
        tutorialBody.setText("Welcome! Want to view the tutorial?");
        rowSkipView.setVisibility(View.VISIBLE);
        rowStepNavigation.setVisibility(View.GONE);
        stepIndex = -1;
    }

    private void showStep(int index) {
        if (index < 0) { showTutorialIntro(true); return; }
        if (index >= steps.size()) { hideTutorial(); return; }

        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(true);
        stepIndex = index;

        tutorialTitle.setText("Tutorial (" + (index + 1) + "/" + steps.size() + ")");
        tutorialBody.setText(steps.get(index));

        rowSkipView.setVisibility(View.GONE);
        rowStepNavigation.setVisibility(View.VISIBLE);

        View   btnBack = findViewById(R.id.btnBack);
        Button btnNext = findViewById(R.id.btnNext);
        btnBack.setEnabled(index > 0);
        btnBack.setAlpha(index > 0 ? 1f : 0.5f);
        btnNext.setText(index == steps.size() - 1 ? "Done" : "Next");
    }

    private void hideTutorial() {
        overlay.setVisibility(View.GONE);
        stepIndex = -1;
    }

    private void setOverlayInteractable(boolean interactable) {
        overlay.setClickable(interactable);
        overlay.setFocusable(interactable);
        overlay.setFocusableInTouchMode(interactable);
        dim.setAlpha(interactable ? 1f : 0f);
        card.setEnabled(interactable);
        card.setAlpha(interactable ? 1f : 0.6f);
    }

    // ------------------------------------------------------------------ //
    //  Misc
    // ------------------------------------------------------------------ //
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    private void vibrate() {
        if (vibrator != null && vibrator.hasVibrator()) {
            vibrator.vibrate(
                    VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE));
        }
    }
}