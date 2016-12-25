package com.example.ivan.gradecheck_android;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.RecyclerView;
import org.json.*;
import org.w3c.dom.Text;
import android.widget.TextView;
import android.view.*;
import android.support.v7.widget.CardView;

import com.daimajia.androidanimations.library.Techniques;
import com.daimajia.androidanimations.library.YoYo;

/**
 * Created by ivan on 12/24/16.
 */

public class AssignmentCellAdapter extends RecyclerView.Adapter<AssignmentCellAdapter.ViewHolder> {
    private JSONArray dataSet;
    public static class ViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        public TextView assignmentText;
        public TextView gradeText;
        public TextView classText;
        public TextView descriptionText;
        public TextView dateView;
        public CardView view;
        public ViewHolder(View v) {
            super(v);
            view = (CardView) v.findViewById(R.id.card_view);
            assignmentText = (TextView) v.findViewById(R.id.assignment_text);
            gradeText = (TextView) v.findViewById(R.id.grade_text);
            descriptionText = (TextView) v.findViewById(R.id.description_view);
            dateView = (TextView) v.findViewById(R.id.date_text);
            classText = (TextView) v.findViewById(R.id.class_text);
        }
    }
    public AssignmentCellAdapter(JSONArray dataSet){
        this.dataSet = dataSet;
    }

    @Override
    public AssignmentCellAdapter.ViewHolder onCreateViewHolder(ViewGroup parent,
                                                          int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.assignment_cell, parent, false);
        // set the view's size, margins, paddings and layout parameters
       ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(AssignmentCellAdapter.ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element
        JSONObject object = new JSONObject();
        try {
            object = dataSet.getJSONObject(position);
            String s = object.getString("percent");
            JSONObject assignment = object.getJSONObject("assignment");
            holder.assignmentText.setText(assignment.getString("title"));
            holder.gradeText.setText(s);
            holder.classText.setText(object.getString("course"));
            holder.descriptionText.setText(assignment.getString("details"));
            holder.dateView.setText(object.getString("dueDate"));
            YoYo.with(Techniques.ZoomIn).playOn(holder.gradeText);
            if(!s.equals("")) {
                s = s.substring(0, s.length() - 1);
                System.out.println(s);
                Double gr = Double.parseDouble(s);
                int color = new GradeCheckColor().getColorWithGrade(gr);
                int[][] states = new int[][] {
                        new int[] { android.R.attr.state_enabled}, // enabled
                        new int[] {-android.R.attr.state_enabled}, // disabled
                        new int[] {-android.R.attr.state_checked}, // unchecked
                        new int[] { android.R.attr.state_pressed}  // pressed
                };
                int[] colors = new int[] {
                        color,
                        color,
                        color,
                        color
                };
                ColorStateList colorList = new ColorStateList(states, colors);
                if (Build.VERSION.SDK_INT >= 21){
                    holder.gradeText.setBackgroundTintList(colorList);
                }
            }else{
                int color = Color.BLACK;
                int[][] states = new int[][] {
                        new int[] { android.R.attr.state_enabled}, // enabled
                        new int[] {-android.R.attr.state_enabled}, // disabled
                        new int[] {-android.R.attr.state_checked}, // unchecked
                        new int[] { android.R.attr.state_pressed}  // pressed
                };
                int[] colors = new int[] {
                        color,
                        color,
                        color,
                        color
                };
                ColorStateList colorList = new ColorStateList(states, colors);
                if (Build.VERSION.SDK_INT >= 21) {
                    holder.gradeText.setBackgroundTintList(colorList);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }
    @Override public int getItemCount(){
        return dataSet.length();
    }

}
