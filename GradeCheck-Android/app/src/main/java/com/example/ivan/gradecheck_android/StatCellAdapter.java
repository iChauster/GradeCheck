package com.example.ivan.gradecheck_android;

import android.animation.ValueAnimator;
import android.content.Intent;
import android.os.Build;
import android.support.v4.app.ActivityOptionsCompat;
import android.support.v4.util.Pair;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import java.util.List;
import android.app.Activity;
import com.daimajia.androidanimations.library.BaseViewAnimator;
import com.daimajia.androidanimations.library.Techniques;
import com.daimajia.androidanimations.library.YoYo;

/**
 * Created by ivan on 12/30/16.
 */

public class StatCellAdapter  extends RecyclerView.Adapter<StatCellAdapter.ViewHolder>{
    private List<Grade> dataSet;
    private Activity a;
    public static class ViewHolder extends RecyclerView.ViewHolder {
        // each data item is just a string in this case
        public TextView classText;
        public CardView view;
        public ViewHolder(View v) {
            super(v);
            view = (CardView) v.findViewById(R.id.card_view);
            classText = (TextView) v.findViewById(R.id.class_text);
        }
    }
    public StatCellAdapter(List<Grade> dataSet, Activity act){
        this.dataSet = dataSet;
        this.a = act;
    }
    @Override
    public StatCellAdapter.ViewHolder onCreateViewHolder(ViewGroup parent,
                                                          int viewType) {
        // create a new view
        View v = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.stat_cell, parent, false);
        // set the view's size, margins, paddings and layout parameters
        ViewHolder vh = new ViewHolder(v);
        return vh;
    }

    // Replace the contents of a view (invoked by the layout manager)
    @Override
    public void onBindViewHolder(StatCellAdapter.ViewHolder holder, int position) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element

        final Grade object;
        object =  dataSet.get(position);
        holder.classText.setText(object.className);
        Double gr = object.grade;
        holder.view.setCardBackgroundColor(new GradeCheckColor().getColorWithGrade(gr));
        YoYo.with(Techniques.SlideInUp).playOn(holder.view);
        holder.view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                System.out.println(object);
                if(Build.VERSION.SDK_INT >= 16) {
                    System.out.println(object);
                    Intent i = new Intent(a, StatView.class);
                    i.putExtra("class", object.className);
                    i.putExtra("grade", object.grade);
                    i.putExtra("classCode", object.classcode);
                    GradeTable gt = (GradeTable) a;
                    String[] s = gt.getCookieAndID();
                    i.putExtra("auth", s);

                    final Pair<View, String>[] pairs = TransitionHelper.createSafeTransitionParticipants(a, true);

                    ActivityOptionsCompat transitionActivityOptions = ActivityOptionsCompat.makeSceneTransitionAnimation(a, pairs);
                    a.startActivity(i, transitionActivityOptions.toBundle());
                }
            }
        });

    }
    @Override public int getItemCount(){
        return dataSet.size();
    }

}

