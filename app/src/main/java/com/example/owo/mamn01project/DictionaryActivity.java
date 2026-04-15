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

    private static final String PLAYER_ID = "local_player";

    private DatabaseHelper databaseHelper;
    private ExpandableListView dictionaryListView;

    private final List<String> groupTitles = new ArrayList<>();
    private final Map<String, List<CollectedWord>> groupedWords = new LinkedHashMap<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dictionary);

        dictionaryListView = findViewById(R.id.dictionaryListView);
        databaseHelper = new DatabaseHelper(this);

        insertTemporaryTestWords();
        loadDictionary();
    }

    private void insertTemporaryTestWords() {
        databaseHelper.saveCollectedWord(PLAYER_ID, "Interface");
        databaseHelper.saveCollectedWord(PLAYER_ID, "Database");
        databaseHelper.saveCollectedWord(PLAYER_ID, "Circuit");
        databaseHelper.saveCollectedWord(PLAYER_ID, "Signal");
    }

    private void loadDictionary() {
        groupedWords.clear();
        groupTitles.clear();

        SQLiteDatabase db = databaseHelper.getReadableDatabase();

        Cursor cursor = db.rawQuery(
                "SELECT p.name AS program_name, w.word AS word, d.captured_at AS captured_at " +
                        "FROM programs p " +
                        "LEFT JOIN word_programs wp ON p.id = wp.program_id " +
                        "LEFT JOIN words w ON wp.word_id = w.id " +
                        "LEFT JOIN dictionary d ON d.word_id = w.id AND d.player_id = ? " +
                        "ORDER BY p.name ASC, w.word COLLATE NOCASE ASC",
                new String[]{PLAYER_ID}
        );

        while (cursor.moveToNext()) {
            String programName = cursor.getString(cursor.getColumnIndexOrThrow("program_name"));

            if (!groupedWords.containsKey(programName)) {
                groupedWords.put(programName, new ArrayList<>());
                groupTitles.add(programName);
            }

            int wordColumnIndex = cursor.getColumnIndexOrThrow("word");
            int capturedAtColumnIndex = cursor.getColumnIndexOrThrow("captured_at");

            if (!cursor.isNull(wordColumnIndex) && !cursor.isNull(capturedAtColumnIndex)) {
                String word = cursor.getString(wordColumnIndex);
                long capturedAt = cursor.getLong(capturedAtColumnIndex);

                groupedWords.get(programName).add(new CollectedWord(word, capturedAt));
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
                new DictionaryExpandableListAdapter(this, groupTitles, groupedWords);

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