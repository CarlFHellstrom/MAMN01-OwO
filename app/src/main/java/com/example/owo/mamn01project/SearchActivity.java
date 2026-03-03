package com.example.owo.mamn01project;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.Arrays;
import java.util.List;

public class SearchActivity extends AppCompatActivity {

    private View overlay;
    private View dim;
    private View card;

    private TextView tutorialTitle;
    private TextView tutorialBody;

    private View rowSkipView;
    private View rowBackNext;

    private Button btnBack;
    private Button btnNext;

    private int stepIndex = -1;

    private final List<String> steps = Arrays.asList(
            "Step 1: Walk around to discover words on the map.",
            "Step 2: Tap a word to catch it.",
            "Step 3: Open your dictionary to see saved words."
    );

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

        overlay = findViewById(R.id.tutorialOverlay);
        dim = findViewById(R.id.tutorialDim);
        card = findViewById(R.id.tutorialCard);

        tutorialTitle = findViewById(R.id.tutorialTitle);
        tutorialBody = findViewById(R.id.tutorialBody);

        rowSkipView = findViewById(R.id.rowSkipView);
        rowBackNext = findViewById(R.id.rowBackNext);

        View btnClose = findViewById(R.id.btnClose);
        View btnSkip = findViewById(R.id.btnSkip);
        View btnView = findViewById(R.id.btnView);

        btnBack = findViewById(R.id.btnBack);
        btnNext = findViewById(R.id.btnNext);

        showTutorialIntro(true);

        btnClose.setOnClickListener(v -> hideTutorial());
        btnSkip.setOnClickListener(v -> hideTutorial());
        btnView.setOnClickListener(v -> showStep(0));

        btnBack.setOnClickListener(v -> showStep(stepIndex - 1));

        btnNext.setOnClickListener(v -> {
            int next = stepIndex + 1;
            if (next >= steps.size()) {
                hideTutorial();
            } else {
                showStep(next);
            }
        });

        dim.setOnClickListener(v -> hideTutorial());
    }


    private void showTutorialIntro(boolean interactable) {
        overlay.setVisibility(View.VISIBLE);
        setOverlayInteractable(interactable);

        tutorialTitle.setText("Tutorial");
        tutorialBody.setText("Welcome! Want to view the tutorial?");

        rowSkipView.setVisibility(View.VISIBLE);
        rowBackNext.setVisibility(View.GONE);

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
        rowBackNext.setVisibility(View.VISIBLE);

        btnBack.setEnabled(index > 0);
        btnNext.setText(index == steps.size() - 1 ? "Finish" : "Next");
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