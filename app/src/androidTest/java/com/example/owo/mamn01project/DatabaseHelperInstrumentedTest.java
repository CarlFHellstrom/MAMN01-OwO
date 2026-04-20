package com.example.owo.mamn01project;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

@RunWith(AndroidJUnit4.class)
public class DatabaseHelperInstrumentedTest {

    private static final String PLAYER_ID = "test_player";
    private Context context;
    private DatabaseHelper databaseHelper;

    @Before
    public void setUp() {
        context = ApplicationProvider.getApplicationContext();

        DatabaseHelper tempHelper = new DatabaseHelper(context);
        context.deleteDatabase(tempHelper.getDatabaseName());

        databaseHelper = new DatabaseHelper(context);
        databaseHelper.getWritableDatabase();
    }

    @After
    public void tearDown() {
        if (databaseHelper != null) {
            databaseHelper.close();
            context.deleteDatabase(databaseHelper.getDatabaseName());
        }
    }

    @Test
    public void saveCollectedWord_insertsWordIntoDictionary() {
        databaseHelper.saveCollectedWord(PLAYER_ID, "Interface");

        SQLiteDatabase db = databaseHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery(
                "SELECT COUNT(*) " +
                        "FROM dictionary d " +
                        "JOIN words w ON d.word_id = w.id " +
                        "WHERE d.player_id = ? AND w.word = ? COLLATE NOCASE",
                new String[]{PLAYER_ID, "Interface"}
        );

        cursor.moveToFirst();
        int count = cursor.getInt(0);
        cursor.close();

        assertEquals(1, count);
    }

    @Test
    public void saveCollectedWord_duplicateInsertIsIgnored() {
        databaseHelper.saveCollectedWord(PLAYER_ID, "Interface");
        databaseHelper.saveCollectedWord(PLAYER_ID, "Interface");

        SQLiteDatabase db = databaseHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery(
                "SELECT COUNT(*) " +
                        "FROM dictionary d " +
                        "JOIN words w ON d.word_id = w.id " +
                        "WHERE d.player_id = ? AND w.word = ? COLLATE NOCASE",
                new String[]{PLAYER_ID, "Interface"}
        );

        cursor.moveToFirst();
        int count = cursor.getInt(0);
        cursor.close();

        assertEquals(1, count);
    }

    @Test
    public void saveCollectedWord_unknownWordDoesNothing() {
        databaseHelper.saveCollectedWord(PLAYER_ID, "THIS_WORD_DOES_NOT_EXIST");

        SQLiteDatabase db = databaseHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery(
                "SELECT COUNT(*) FROM dictionary WHERE player_id = ?",
                new String[]{PLAYER_ID}
        );

        cursor.moveToFirst();
        int count = cursor.getInt(0);
        cursor.close();

        assertEquals(0, count);
    }

    @Test
    public void saveCollectedWord_setsCapturedAt() {
        databaseHelper.saveCollectedWord(PLAYER_ID, "Interface");

        SQLiteDatabase db = databaseHelper.getReadableDatabase();
        Cursor cursor = db.rawQuery(
                "SELECT d.captured_at " +
                        "FROM dictionary d " +
                        "JOIN words w ON d.word_id = w.id " +
                        "WHERE d.player_id = ? AND w.word = ? COLLATE NOCASE",
                new String[]{PLAYER_ID, "Interface"}
        );

        cursor.moveToFirst();
        long capturedAt = cursor.getLong(0);
        cursor.close();

        assertTrue(capturedAt > 0);
    }
}