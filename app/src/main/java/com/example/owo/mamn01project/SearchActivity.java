package com.example.owo.mamn01project;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.Arrays;
import java.util.List;

public class SearchActivity extends AppCompatActivity {

    private SensorManager sensorManager;
    private Sensor accelerometer;
    private Vibrator vibrator;

    private ImageView selectionCircle;

    private ImageView currentLetter;
    private ImageView[] letters;
    private int selectedIndex = 0;
    private View overlay;
    private View dim;
    private View card;

    private TextView tutorialTitle;
    private TextView tutorialBody;

    private View rowSkipView;
    private long lastTiltTime = 0;


    private int stepIndex = -1;

    private final List<String> steps = Arrays.asList(
            "Step 1: Walk around to discover words on the map.",
            "Step 2: Tap a word to catch it.",
            "Step 3: Open your dictionary to see saved words."
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
        sensorManager = (SensorManager) getSystemService(SENSOR_SERVICE);
        accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
        vibrator = (Vibrator) getSystemService(VIBRATOR_SERVICE);

        selectionCircle = findViewById(R.id.selectionCircle);

        letters = new ImageView[] {
                findViewById(R.id.letterF),
                findViewById(R.id.letterK),
                findViewById(R.id.letterA),
                findViewById(R.id.letterW),
                findViewById(R.id.letterV),
                findViewById(R.id.letterD),
                findViewById(R.id.letterE),
                findViewById(R.id.letterM),
                findViewById(R.id.letterI)
        };

        currentLetter = findViewById(R.id.currentLetter);

        overlay = findViewById(R.id.tutorialOverlay);
        dim = findViewById(R.id.tutorialDim);
        card = findViewById(R.id.tutorialCard);

        tutorialTitle = findViewById(R.id.tutorialTitle);
        tutorialBody = findViewById(R.id.tutorialBody);

        rowSkipView = findViewById(R.id.rowSkipView);

        View btnClose = findViewById(R.id.btnClose);
        View btnSkip = findViewById(R.id.btnSkip);
        View btnView = findViewById(R.id.btnView);

        showTutorialIntro(true);

        btnClose.setOnClickListener(v -> hideTutorial());
        btnSkip.setOnClickListener(v -> hideTutorial());
        btnView.setOnClickListener(v -> showStep(0));


        dim.setOnClickListener(v -> hideTutorial());
        selectionCircle.post(this::moveSelection);
    }

    @Override
    protected void onResume() {
        super.onResume();
        sensorManager.registerListener(sensorListener, accelerometer, SensorManager.SENSOR_DELAY_UI);
    }

    private void showTutorialIntro(boolean interactable) {
        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(interactable);

        tutorialTitle.setText("Tutorial");
        tutorialBody.setText("Welcome! Want to view the tutorial?");

        rowSkipView.setVisibility(View.VISIBLE);

        stepIndex = -1;
    }

    private void showStep(int index) {
        if (index < 0) {
            showTutorialIntro(true);
            return;
        }

        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(true);

        stepIndex = index;

        tutorialTitle.setText("Tutorial (" + (index + 1) + "/" + steps.size() + ")");
        tutorialBody.setText(steps.get(index));

        rowSkipView.setVisibility(View.GONE);
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
        if (selectedIndex < 0) selectedIndex = 0;
        if (selectedIndex >= letters.length) selectedIndex = letters.length - 1;

        if (moved) {
            lastTiltTime = now;
            vibrate();
            moveSelection();
        }
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
}