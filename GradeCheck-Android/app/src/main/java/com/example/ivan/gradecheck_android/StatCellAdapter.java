package com.example.ivan.gradecheck_android;

import android.animation.ValueAnimator;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import java.util.List;
import com.daimajia.androidanimations.library.BaseViewAnimator;
import com.daimajia.androidanimations.library.Techniques;
import com.daimajia.androidanimations.library.YoYo;

/**
 * Created by ivan on 12/30/16.
 */

public class StatCellAdapter  extends RecyclerView.Adapter<StatCellAdapter.ViewHolder>{
    private List<Grade> dataSet;
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
    public StatCellAdapter(List<Grade> dataSet){
        this.dataSet = dataSet;
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

        Grade object;
        object =  dataSet.get(position);
        holder.classText.setText(object.className);
        Double gr = object.grade;
        holder.view.setCardBackgroundColor(new GradeCheckColor().getColorWithGrade(gr));
        YoYo.with(Techniques.SlideInUp).playOn(holder.view);

    }
    @Override public int getItemCount(){
        return dataSet.size();
    }

}

