package com.example.owo.mamn01project;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.widget.ExpandableListView;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class DictionaryActivity extends AppCompatActivity {

    public static final String PLAYER_ID = "local_player";

    private DatabaseHelper databaseHelper;
    private ExpandableListView dictionaryListView;

    private final List<String> groupTitles = new ArrayList<>();
    private final Map<String, List<CollectedWord>> groupedWords = new LinkedHashMap<>();

    private final Map<String, ProgramStats> programStats = new LinkedHashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dictionary);

        dictionaryListView = findViewById(R.id.dictionaryListView);
        databaseHelper = new DatabaseHelper(this);

        loadDictionary();
    }

    private void loadDictionary() {
        groupedWords.clear();
        groupTitles.clear();
        programStats.clear();

        SQLiteDatabase db = databaseHelper.getReadableDatabase();

        Cursor cursor = db.rawQuery(
                "SELECT s.name AS section_name, w.word AS word, d.captured_at AS captured_at " +
                        "FROM sections s " +
                        "LEFT JOIN program_sections ps ON ps.section_id = s.id " +
                        "LEFT JOIN programs p ON p.id = ps.program_id " +
                        "LEFT JOIN word_programs wp ON wp.program_id = p.id " +
                        "LEFT JOIN words w ON w.id = wp.word_id " +
                        "LEFT JOIN dictionary d ON d.word_id = w.id AND d.player_id = ? " +
                        "GROUP BY s.name, w.word " +  // deduplicate words shared across programs
                        "ORDER BY s.name ASC, w.word COLLATE NOCASE ASC",
                new String[]{PLAYER_ID}
        );

        while (cursor.moveToNext()) {
            String sectionName = cursor.getString(cursor.getColumnIndexOrThrow("section_name"));

            if (!groupedWords.containsKey(sectionName)) {
                groupedWords.put(sectionName, new ArrayList<>());
                groupTitles.add(sectionName);
                programStats.put(sectionName, new ProgramStats());
            }

            int wordColumnIndex = cursor.getColumnIndexOrThrow("word");
            int capturedAtColumnIndex = cursor.getColumnIndexOrThrow("captured_at");

            if (!cursor.isNull(wordColumnIndex)) {
                programStats.get(sectionName).totalCount++;

                if (!cursor.isNull(capturedAtColumnIndex)) {
                    String word = cursor.getString(wordColumnIndex);
                    long capturedAt = cursor.getLong(capturedAtColumnIndex);

                    groupedWords.get(sectionName).add(new CollectedWord(word, capturedAt));
                    programStats.get(sectionName).collectedCount++;
                }
            }
        }

        cursor.close();

        for (String program : groupTitles) {
            List<CollectedWord> words = groupedWords.get(program);

            if (words != null && words.isEmpty()) {
                words.add(new CollectedWord("No collected words yet", 0, true));
            }
        }

        DictionaryExpandableListAdapter adapter =
                new DictionaryExpandableListAdapter(this, groupTitles, groupedWords, programStats);

        dictionaryListView.setAdapter(adapter);

        dictionaryListView.setOnChildClickListener((parent, v, groupPosition, childPosition, id) -> {
            String program = groupTitles.get(groupPosition);
            CollectedWord collectedWord = groupedWords.get(program).get(childPosition);

            if (collectedWord.isPlaceholder) {
                return true;
            }

            String formattedDate = formatTimestamp(collectedWord.capturedAt);

            new AlertDialog.Builder(this)
                    .setTitle(collectedWord.word)
                    .setMessage("Collected: " + formattedDate)
                    .setPositiveButton("OK", null)
                    .show();

            return true;
        });
    }

    private String formatTimestamp(long timestampSeconds) {
        Date date = new Date(timestampSeconds * 1000L);
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault());
        return formatter.format(date);
    }

    public static class ProgramStats {
        public int collectedCount;
        public int totalCount;

        ProgramStats() {
            this.collectedCount = 0;
            this.totalCount = 0;
        }
    }
    public static class CollectedWord {
        public String word;
        public long capturedAt;
        public boolean isPlaceholder;

        CollectedWord(String word, long capturedAt) {
            this.word = word;
            this.capturedAt = capturedAt;
            this.isPlaceholder = false;
        }

        CollectedWord(String word, long capturedAt, boolean isPlaceholder) {
            this.word = word;
            this.capturedAt = capturedAt;
            this.isPlaceholder = isPlaceholder;
        }
    }
}