package com.example.owo.mamn01project;

import android.content.Context;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.util.List;
import java.util.Map;

public class DictionaryExpandableListAdapter extends BaseExpandableListAdapter {

    private final Context context;
    private final List<String> groupTitles;
    private final Map<String, List<DictionaryActivity.CollectedWord>> groupedWords;
    private final Map<String, DictionaryActivity.ProgramStats> programStats;

    public DictionaryExpandableListAdapter(Context context,
                                           List<String> groupTitles,
                                           Map<String, List<DictionaryActivity.CollectedWord>> groupedWords,
                                           Map<String, DictionaryActivity.ProgramStats> programStats ) {
        this.context = context;
        this.groupTitles = groupTitles;
        this.groupedWords = groupedWords;
        this.programStats = programStats;
    }

    @Override
    public int getGroupCount() {
        return groupTitles.size();
    }

    @Override
    public int getChildrenCount(int groupPosition) {
        return groupedWords.get(groupTitles.get(groupPosition)).size();
    }

    @Override
    public Object getGroup(int groupPosition) {
        String programName = groupTitles.get(groupPosition);
        DictionaryActivity.ProgramStats stats = programStats.get(programName);

        if (stats != null) {
            return programName + " (" + stats.collectedCount + "/" + stats.totalCount + ")";
        }

        return programName;
    }

    @Override
    public Object getChild(int groupPosition, int childPosition) {
        return groupedWords.get(groupTitles.get(groupPosition)).get(childPosition);
    }

    @Override
    public long getGroupId(int groupPosition) {
        return groupPosition;
    }

    @Override
    public long getChildId(int groupPosition, int childPosition) {
        return childPosition;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }

    @Override
    public View getGroupView(int groupPosition, boolean isExpanded, View convertView, ViewGroup parent) {
        String programName = groupTitles.get(groupPosition);
        DictionaryActivity.ProgramStats stats = programStats.get(programName);

        int collected = 0;
        int total = 0;

        if (stats != null) {
            collected = stats.collectedCount;
            total = stats.totalCount;
        }

        boolean isEmpty = collected == 0;
        boolean isCompleted = total > 0 && collected == total;

        LinearLayout card = new LinearLayout(context);
        card.setOrientation(LinearLayout.VERTICAL);
        card.setPadding(36, 28, 36, 28);

        GradientDrawable background = new GradientDrawable();
        background.setCornerRadius(28);

        if (isCompleted) {
            background.setColor(context.getColor(R.color.light_green));
            background.setStroke(4, context.getColor(R.color.forest_green));
        } else if (isEmpty) {
            background.setColor(context.getColor(R.color.light_green));
        } else {
            background.setColor(context.getColor(R.color.light_green));
            background.setStroke(3, context.getColor(R.color.forest_green));
        }

        card.setBackground(background);
        card.setAlpha(isEmpty ? 0.75f : 1.0f);

        LinearLayout titleRow = new LinearLayout(context);
        titleRow.setOrientation(LinearLayout.HORIZONTAL);
        titleRow.setGravity(Gravity.CENTER_VERTICAL);

        TextView title = new TextView(context);
        title.setText(programName + (isCompleted ? " 👑" : ""));
        title.setTextSize(20);
        title.setTypeface(null, Typeface.BOLD);
        title.setTextColor(context.getColor(R.color.dark_green));

        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                1
        );
        title.setLayoutParams(titleParams);

        TextView expandIcon = new TextView(context);
        expandIcon.setText(isExpanded ? "⌃" : "⌄");
        expandIcon.setTextSize(24);
        expandIcon.setTypeface(null, Typeface.BOLD);
        expandIcon.setTextColor(context.getColor(R.color.dark_green));

        titleRow.addView(title);
        titleRow.addView(expandIcon);

        TextView progressText = new TextView(context);
        progressText.setText(collected + " / " + total + " words collected");
        progressText.setTextSize(14);
        progressText.setTextColor(context.getColor(R.color.forest_green));
        progressText.setPadding(0, 8, 0, 8);

        ProgressBar progressBar = new ProgressBar(
                context,
                null,
                android.R.attr.progressBarStyleHorizontal
        );
        progressBar.setMax(total == 0 ? 1 : total);
        progressBar.setProgress(collected);

        card.addView(titleRow);
        card.addView(progressText);
        card.addView(progressBar);

        return card;
    }

    @Override
    public View getChildView(int groupPosition, int childPosition, boolean isLastChild, View convertView, ViewGroup parent) {
        DictionaryActivity.CollectedWord collectedWord =
                groupedWords.get(groupTitles.get(groupPosition)).get(childPosition);

        TextView textView = new TextView(context);
        textView.setPadding(100, 24, 32, 24);
        textView.setTextSize(18);
        textView.setGravity(Gravity.CENTER_VERTICAL);
        textView.setText(collectedWord.word);

        if (collectedWord.isPlaceholder) {
            textView.setTextColor(context.getColor(R.color.forest_green));
            textView.setBackgroundColor(context.getColor(R.color.light_green));
        } else {
            textView.setTextColor(context.getColor(R.color.dark_green));
            textView.setBackgroundColor(context.getColor(R.color.light_green));
        }

        return textView;
    }

    @Override
    public boolean isChildSelectable(int groupPosition, int childPosition) {
        return true;
    }
}