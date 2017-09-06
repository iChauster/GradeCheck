package com.example.ivan.gradecheck_android;

import android.graphics.Color;

/**
 * Created by ivan on 12/24/16.
 */

public class GradeCheckColor {
    public int getColorWithGrade(double grade){
        int g = (int)grade;
        if(g <= 50){
            return Color.parseColor("#1F1F21");
        }else if(g <= 75){
            return Color.parseColor("#F4564D");
        }else if(g <= 85){
            return Color.parseColor("#FFCD02");
        }else{
            return Color.parseColor("#25A308");
        }
    }
}
