package com.example.ivan.gradecheck_android;

import android.graphics.Color;
import android.os.Build;
import android.support.v7.widget.RecyclerView;
import org.json.*;
import org.w3c.dom.Text;
import android.widget.TextView;
import android.view.*;
import android.support.v7.widget.CardView;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.app.Activity;
import android.support.v4.util.Pair;
import android.support.v4.app.ActivityOptionsCompat;
import com.daimajia.androidanimations.library.BaseViewAnimator;
import com.daimajia.androidanimations.library.Techniques;
import com.daimajia.androidanimations.library.YoYo;
/**
 * Created by ivan on 12/15/16.
 */

public class GradeCellAdapter extends RecyclerView.Adapter<GradeCellAdapter.ViewHolder> {
    private JSONArray dataSet;
    private Activity activity;
    public static class ViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        public TextView teacherText;
        public TextView gradeText;
        public TextView classText;
        public CardView view;
        public ViewHolder(View v) {
            super(v);
            view = (CardView) v.findViewById(R.id.card_view);
            teacherText = (TextView) v.findViewById(R.id.teacher_text);
            gradeText = (TextView) v.findViewById(R.id.grade_text);
            classText = (TextView) v.findViewById(R.id.class_text);
        }
    }
    public GradeCellAdapter(JSONArray dataSet, Activity a){
        this.activity = a;
        this.dataSet = dataSet;
    }
    @Override
    public GradeCellAdapter.ViewHolder onCreateViewHolder(ViewGroup parent,
                                                   int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.grade_cell, parent, false);
        // set the view's size, margins, paddings and layout parameters
        ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element

        final JSONObject object;
        try {
            object = dataSet.getJSONObject(position + 1);
            String s = object.getString("grade");
            holder.teacherText.setText(object.getString("teacher"));
            holder.classText.setText(object.getString("class"));
            Double gr = Double.parseDouble(s.substring(0,s.length()-1));
            final int g = gr.intValue();
            BaseViewAnimator bv = new BaseViewAnimator() {

                @Override
                protected void prepare(View target) {
                    final TextView gt = (TextView) target;
                    ValueAnimator animator = new ValueAnimator();
                    animator.setObjectValues(0, g);
                    animator.setDuration(2500);
                    animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                        public void onAnimationUpdate(ValueAnimator animation) {
                            gt.setText((int)animation.getAnimatedValue() + "%");
                        }
                    });
                    animator.start();
                }
            };

            YoYo.with(bv).playOn(holder.gradeText);
            YoYo.with(Techniques.RotateIn).playOn(holder.view);
            holder.view.setCardBackgroundColor(new GradeCheckColor().getColorWithGrade(gr));

            holder.view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(Build.VERSION.SDK_INT >= 16) {
                        System.out.println(object);
                        Intent i = new Intent(activity, ClassView.class);
                        GradeTable gt = (GradeTable) activity;
                        String[] s = gt.getCookieAndID();
                        i.putExtra("class", object.toString());
                        i.putExtra("auth", s);

                        activity.startActivity(i);
                    }
                }
            });
        } catch (JSONException e) {
            e.printStackTrace();
        }

    }

    @Override public int getItemCount(){
        return dataSet.length() - 1;
    }

}
