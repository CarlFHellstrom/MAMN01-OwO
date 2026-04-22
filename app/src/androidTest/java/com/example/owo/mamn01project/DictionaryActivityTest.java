package com.example.owo.mamn01project;

import android.widget.ExpandableListView;

import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import java.util.concurrent.atomic.AtomicInteger;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static org.junit.Assert.assertTrue;

@RunWith(AndroidJUnit4.class)
public class DictionaryActivityTest {

    @Test
    public void dictionaryActivity_showsTitleAndList() {
        try (ActivityScenario<DictionaryActivity> scenario = ActivityScenario.launch(DictionaryActivity.class)) {
            onView(withText("Dictionary")).check(matches(isDisplayed()));
            onView(withId(R.id.dictionaryListView)).check(matches(isDisplayed()));
        }
    }

    @Test
    public void dictionaryActivity_hasAtLeastOneProgramGroup() {
        AtomicInteger groupCount = new AtomicInteger(0);

        try (ActivityScenario<DictionaryActivity> scenario = ActivityScenario.launch(DictionaryActivity.class)) {
            scenario.onActivity(activity -> {
                ExpandableListView listView = activity.findViewById(R.id.dictionaryListView);
                groupCount.set(listView.getExpandableListAdapter().getGroupCount());
            });
        }

        assertTrue(groupCount.get() > 0);
    }


    @Test
    public void emptyProgram_showsNoCollectedWordsYet() {
        try (ActivityScenario<DictionaryActivity> scenario =
                     ActivityScenario.launch(DictionaryActivity.class)) {

            scenario.onActivity(activity -> {
                ExpandableListView listView =
                        activity.findViewById(R.id.dictionaryListView);

                var adapter = listView.getExpandableListAdapter();

                boolean foundPlaceholder = false;

                for (int group = 0; group < adapter.getGroupCount(); group++) {

                    if (adapter.getChildrenCount(group) > 0) {

                        Object child = adapter.getChild(group, 0);

                        if (child instanceof DictionaryActivity.CollectedWord) {
                            DictionaryActivity.CollectedWord word =
                                    (DictionaryActivity.CollectedWord) child;

                            if (word.word.equals("No collected words yet")) {
                                foundPlaceholder = true;
                                break;
                            }
                        }
                    }
                }

                if (!foundPlaceholder) {
                    throw new AssertionError(
                            "No placeholder row found for empty programs."
                    );
                }
            });
        }
    }

    @Test
    public void programTitles_showCollectedOutOfTotalCounts() {
        try (ActivityScenario<DictionaryActivity> scenario = ActivityScenario.launch(DictionaryActivity.class)) {
            scenario.onActivity(activity -> {
                ExpandableListView listView = activity.findViewById(R.id.dictionaryListView);
                var adapter = listView.getExpandableListAdapter();

                boolean foundProgramWithCounts = false;

                for (int group = 0; group < adapter.getGroupCount(); group++) {
                    Object groupObject = adapter.getGroup(group);

                    if (groupObject instanceof String) {
                        String title = (String) groupObject;

                        if (title.matches(".*\\(\\d+/\\d+\\)$")) {
                            foundProgramWithCounts = true;
                            break;
                        }
                    }
                }

                if (!foundProgramWithCounts) {
                    throw new AssertionError("No program title contained collected/total counts.");
                }
            });
        }
    }
}