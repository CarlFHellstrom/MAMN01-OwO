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

public class DatabaseHelper extends SQLiteOpenHelper {
    private static final String DATABASE_NAME = "lth_words.db";
    private static final int DATABASE_VERSION = 1;

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
        db.execSQL("DROP TABLE IF EXISTS words");
        db.execSQL("DROP TABLE IF EXISTS programs");
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

}
