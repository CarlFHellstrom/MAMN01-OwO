package com.example.owo.mamn01project;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import java.util.HashMap;
import java.util.Map;

public class MapOverlayView extends View {

    // Default letter width as a fraction of the view width
    // Increase this value to make ALL letters bigger, decrease to make them smaller
    private static final float DEFAULT_SIZE_FRACTION = 0.12f;

    // ------------------------------------------------------------------ //
    //  Click listener
    // ------------------------------------------------------------------ //
    public interface OnLetterClickListener {
        void onLetterClicked(int drawableRes);
    }

    private OnLetterClickListener letterClickListener;

    public void setLetterClickListener(OnLetterClickListener listener) {
        this.letterClickListener = listener;
    }

    // ------------------------------------------------------------------ //
    //  LetterItem
    //    xPercent / yPercent : centre of letter as fraction of view size
    //    sizeFraction        : width of letter as fraction of view width
    //    keepAspect          : derive height from bitmap aspect ratio
    // ------------------------------------------------------------------ //
    private static class LetterItem {
        final int     drawableRes;
        final float   xPercent;
        final float   yPercent;
        final float   sizeFraction;
        final boolean keepAspect;

        LetterItem(int res, float x, float y, float size, boolean aspect) {
            drawableRes  = res;
            xPercent     = x;
            yPercent     = y;
            sizeFraction = size;
            keepAspect   = aspect;
        }

        LetterItem(int res, float x, float y) {
            this(res, x, y, DEFAULT_SIZE_FRACTION, true);
        }
    }

    // ------------------------------------------------------------------ //
    //  Letter positions
    //
    //  HOW TO TUNE:
    //    xPercent : 0.0 = left edge of screen,  1.0 = right edge
    //    yPercent : 0.0 = top  edge of screen,  1.0 = bottom edge
    //    sizeFraction: width of letter / view width  (0.12 ≈ 12 % of width)
    // ------------------------------------------------------------------ //
    private final LetterItem[] letters;

    private LetterItem[] buildLetters() {
        return new LetterItem[] {

                new LetterItem(R.drawable.k, 0.44f, 0.10f, 0.09f, true),

                new LetterItem(R.drawable.w, 0.66f, 0.10f, 0.10f, true),

                new LetterItem(R.drawable.a, 0.84f, 0.35f, 0.10f, true),

                new LetterItem(R.drawable.v, 0.70f, 0.49f, 0.10f, true),

                new LetterItem(R.drawable.d, 0.62f, 0.64f, 0.085f, true),

                new LetterItem(R.drawable.e, 0.62f, 0.71f, 0.09f, true),

                new LetterItem(R.drawable.f, 0.11f, 0.69f, 0.09f, true),

                new LetterItem(R.drawable.m, 0.66f, 0.84f, 0.09f, true),

                new LetterItem(R.drawable.i, 0.58f, 0.92f, 0.09f, true),
        };
    }

    // ------------------------------------------------------------------ //
    //  Bitmap cache
    // ------------------------------------------------------------------ //
    private final Map<Integer, Bitmap> bitmapCache = new HashMap<>();

    private Bitmap getBitmap(int res) {
        Bitmap cached = bitmapCache.get(res);
        if (cached != null) return cached;
        Bitmap bmp = BitmapFactory.decodeResource(getResources(), res);
        bitmapCache.put(res, bmp);
        return bmp;
    }

    // ------------------------------------------------------------------ //
    //  Constructors
    // ------------------------------------------------------------------ //
    public MapOverlayView(Context context) {
        super(context);
        letters = buildLetters();
    }

    public MapOverlayView(Context context, AttributeSet attrs) {
        super(context, attrs);
        letters = buildLetters();
    }

    public MapOverlayView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        letters = buildLetters();
    }

    // ------------------------------------------------------------------ //
    //  Draw
    // ------------------------------------------------------------------ //
    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float w = getWidth();
        float h = getHeight();
        if (w == 0 || h == 0) return;

        for (LetterItem letter : letters) {
            Bitmap bmp   = getBitmap(letter.drawableRes);
            float  sizeW = w * letter.sizeFraction;
            float  sizeH = (letter.keepAspect && bmp.getWidth() > 0)
                    ? sizeW * ((float) bmp.getHeight() / bmp.getWidth())
                    : sizeW;

            float cx   = w * letter.xPercent;
            float cy   = h * letter.yPercent;
            RectF rect = new RectF(cx - sizeW / 2f, cy - sizeH / 2f,
                    cx + sizeW / 2f, cy + sizeH / 2f);
            canvas.drawBitmap(bmp, null, rect, null);
        }
    }

    // ------------------------------------------------------------------ //
    //  Touch
    // ------------------------------------------------------------------ //
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() != MotionEvent.ACTION_UP) return true;

        float w  = getWidth();
        float h  = getHeight();
        float tx = event.getX();
        float ty = event.getY();

        for (LetterItem letter : letters) {
            float  sizeW  = w * letter.sizeFraction;
            Bitmap bmp    = getBitmap(letter.drawableRes);
            float  sizeH  = (letter.keepAspect && bmp.getWidth() > 0)
                    ? sizeW * ((float) bmp.getHeight() / bmp.getWidth())
                    : sizeW;
            float cx   = w * letter.xPercent;
            float cy   = h * letter.yPercent;
            float hitW = sizeW * 1.4f;
            float hitH = sizeH * 1.4f;

            if (tx >= cx - hitW / 2f && tx <= cx + hitW / 2f &&
                    ty >= cy - hitH / 2f && ty <= cy + hitH / 2f) {
                if (letterClickListener != null) {
                    letterClickListener.onLetterClicked(letter.drawableRes);
                }
                performClick();
                return true;
            }
        }
        return super.onTouchEvent(event);
    }

    @Override
    public boolean performClick() {
        super.performClick();
        return true;
    }

    // ------------------------------------------------------------------ //
    //  Returns absolute screen position of a letter's centre.
    //  SearchActivity subtracts the root view offset to get local coords.
    // ------------------------------------------------------------------ //
    public float[] getLetterScreenPosition(int drawableRes) {
        float w = getWidth();
        float h = getHeight();
        int[] loc = new int[2];
        getLocationOnScreen(loc);

        for (LetterItem letter : letters) {
            if (letter.drawableRes == drawableRes) {
                return new float[]{
                        loc[0] + w * letter.xPercent,
                        loc[1] + h * letter.yPercent
                };
            }
        }
        return new float[]{ 0f, 0f };
    }

    public int getLetterCount() {
        return letters.length;
    }

    // ------------------------------------------------------------------ //
    //  Cleanup
    // ------------------------------------------------------------------ //
    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        for (Bitmap bmp : bitmapCache.values()) {
            if (!bmp.isRecycled()) bmp.recycle();
        }
        bitmapCache.clear();
    }
}