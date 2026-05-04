package com.example.owo.mamn01project.Feedback;


import static android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION;

import android.content.ContentResolver;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.net.Uri;
import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.os.VibratorManager;

import com.example.owo.mamn01project.R;

import java.io.IOException;

public class FeedbackGenerator {

    private MediaPlayer fanfare_sound;
    private MediaPlayer failure_sound;
    private MediaPlayer error_sound;
    private Vibrator vibrator;

    private Context context;

    public FeedbackGenerator(Context context) {
        this.context = context;

        // Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            this.vibrator = ((VibratorManager) context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)).getDefaultVibrator();
        } else {
            this.vibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        }

        // Sound effects
        this.fanfare_sound = __createMediaPlayer(R.raw.fanfare);
        this.failure_sound = __createMediaPlayer(R.raw.failure);
        this.error_sound = __createMediaPlayer(R.raw.error);

    }

    private MediaPlayer __createMediaPlayer(int resource_location) {
        var resources = context.getResources();
        var mediaPlayer = new MediaPlayer();

        var uri = new Uri.Builder()
                .scheme(ContentResolver.SCHEME_ANDROID_RESOURCE)
                .authority(resources.getResourcePackageName(resource_location))
                .appendPath(resources.getResourceTypeName(resource_location))
                .appendPath(resources.getResourceEntryName(resource_location))
                .build();
        mediaPlayer.setAudioAttributes(
                new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_GAME)
                        .setContentType(CONTENT_TYPE_SONIFICATION)
                        .build()
        );
        try {
            mediaPlayer.setDataSource(context, uri);
            mediaPlayer.prepare();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return mediaPlayer;
    }

    public void playFanfare() {
        var effect = VibrationEffect.createWaveform(
                new long[]{150, 250, 150, 150, 250, 150, 150, 250},
                new int[]{128, 255, 0, 128, 255, 0, 128, 255},
                -1
        );
        vibrator.vibrate(effect);
        this.fanfare_sound.start();
    }

    public void playFailure() {
        var effect = VibrationEffect.createWaveform(
                new long[]{250, 150, 150, 250, 150, 150, 250, 150},
                new int[]{255, 128, 0, 255, 128, 0, 255, 128},
                -1
        );
        vibrator.vibrate(effect);
        this.failure_sound.start();
    }

    public void playError(){
        var effect = VibrationEffect.createWaveform(
                new long[]{150, 250},
                new int[]{255, 128},
                -1
        );
        vibrator.vibrate(effect);
        this.error_sound.start();
    }
}