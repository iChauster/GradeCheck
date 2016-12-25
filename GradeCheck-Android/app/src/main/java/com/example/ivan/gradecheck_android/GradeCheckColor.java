package com.example.ivan.gradecheck_android;

import android.graphics.Color;

/**
 * Created by ivan on 12/24/16.
 */

public class GradeCheckColor {
    public int getColorWithGrade(double grade){
        int g = (int)grade;
        if(g <= 50){
            return Color.BLACK;
        }else if(g <= 75){
            return Color.RED;
        }else if(g <= 85){
            return Color.YELLOW;
        }else{
            return Color.parseColor("#25A308");
        }
    }
}
