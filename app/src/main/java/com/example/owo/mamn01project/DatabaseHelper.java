package com.example.owo.mamn01project;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import android.content.ContentValues;
import android.database.Cursor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "lth_words.db";
    private static final int DATABASE_VERSION = 2;

    private final Context context;

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
        this.context = context;
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        executeSqlFile(db);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS dictionary");
        db.execSQL("DROP TABLE IF EXISTS word_programs");
        db.execSQL("DROP TABLE IF EXISTS program_sections");
        db.execSQL("DROP TABLE IF EXISTS words");
        db.execSQL("DROP TABLE IF EXISTS programs");
        db.execSQL("DROP TABLE IF EXISTS sections");
        onCreate(db);
    }

    @Override
    public void onOpen(SQLiteDatabase db) {
        super.onOpen(db);
        if (!db.isReadOnly()) {
            db.execSQL("PRAGMA foreign_keys = ON;");
        }
    }

    private void executeSqlFile(SQLiteDatabase db) {
        try {
            InputStream is = context.getResources().openRawResource(R.raw.android_migration);
            BufferedReader reader = new BufferedReader(new InputStreamReader(is));
            StringBuilder sb = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                String trimmed = line.trim();
                if (trimmed.startsWith("--") || trimmed.isEmpty()) continue;
                sb.append(trimmed).append(" ");
                if (trimmed.endsWith(";")) {
                    String statement = sb.toString().trim();
                    db.execSQL(statement.substring(0, statement.length() - 1));
                    sb.setLength(0);
                }
            }
            reader.close();
        } catch (IOException e) {
            throw new RuntimeException("Failed to read android_migration.sql", e);
        }
    }

    public void saveCollectedWord(String playerId, String word) {
        SQLiteDatabase db = this.getWritableDatabase();

        Cursor cursor = db.rawQuery(
                "SELECT id FROM words WHERE word = ? COLLATE NOCASE",
                new String[]{word}
        );

        if (!cursor.moveToFirst()) {
            cursor.close();
            return;
        }

        int wordId = cursor.getInt(cursor.getColumnIndexOrThrow("id"));
        cursor.close();

        ContentValues values = new ContentValues();
        values.put("player_id", playerId);
        values.put("word_id", wordId);

        db.insertWithOnConflict(
                "dictionary",
                null,
                values,
                SQLiteDatabase.CONFLICT_IGNORE
        );
    }

    /**
     * Returns a random word belonging to any program in the given section.
     * @param sectionCode  one of "D", "K", "V", "M", "E", "F"
     * @return the word string, or null if the section is unknown / has no words
     */
    public String getRandomWordForSection(String sectionCode) {
        SQLiteDatabase db = this.getReadableDatabase();
        String query =
                "SELECT w.word FROM words w " +
                        "JOIN word_programs wp ON wp.word_id = w.id " +
                        "JOIN program_sections ps ON ps.program_id = wp.program_id " +
                        "JOIN sections s ON s.id = ps.section_id " +
                        "WHERE s.code = ? " +
                        "ORDER BY RANDOM() LIMIT 1";

        try (Cursor cursor = db.rawQuery(query, new String[]{sectionCode})) {
            if (cursor.moveToFirst()) {
                return cursor.getString(0);
            }
        }
        return null;
    }

    /**
     * Same as above but excludes words the player has already collected.
     */
    public String getRandomUncollectedWordForSection(String playerId, String sectionCode) {
        SQLiteDatabase db = this.getReadableDatabase();
        String query =
                "SELECT w.word FROM words w " +
                        "JOIN word_programs wp ON wp.word_id = w.id " +
                        "JOIN program_sections ps ON ps.program_id = wp.program_id " +
                        "JOIN sections s ON s.id = ps.section_id " +
                        "WHERE s.code = ? " +
                        "AND w.id NOT IN (" +
                        "    SELECT word_id FROM dictionary WHERE player_id = ?" +
                        ") " +
                        "ORDER BY RANDOM() LIMIT 1";

        try (Cursor cursor = db.rawQuery(query, new String[]{sectionCode, playerId})) {
            if (cursor.moveToFirst()) {
                return cursor.getString(0);
            }
        }
        return null;
    }

    /**
     * Returns all sections as a list of Section objects.
     */
    public List<Section> getAllSections() {
        SQLiteDatabase db = this.getReadableDatabase();
        List<Section> sections = new ArrayList<>();

        try (Cursor cursor = db.rawQuery("SELECT code, name FROM sections ORDER BY code", null)) {
            while (cursor.moveToNext()) {
                String code = cursor.getString(0);
                String name = cursor.getString(1);
                sections.add(new Section(code, name));
            }
        }
        return sections;
    }

}
