package com.example.owo.mamn01project;

import android.content.Context;
import android.graphics.Typeface;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseExpandableListAdapter;
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
        TextView textView = new TextView(context);
        textView.setPadding(60, 32, 32, 32);
        textView.setTextSize(20);
        textView.setTypeface(null, Typeface.BOLD);
        String programName = groupTitles.get(groupPosition);
        DictionaryActivity.ProgramStats stats = programStats.get(programName);

        String titleText = programName;
        if (stats != null) {
            titleText = programName + " (" + stats.collectedCount + "/" + stats.totalCount + ")";
        }

        textView.setText((String) getGroup(groupPosition));
        textView.setTextColor(context.getColor(R.color.dark_green));
        textView.setBackgroundColor(context.getColor(R.color.sage_green));
        return textView;
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