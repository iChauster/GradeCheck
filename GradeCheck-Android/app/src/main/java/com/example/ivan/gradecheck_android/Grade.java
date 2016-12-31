package com.example.ivan.gradecheck_android;

/**
 * Created by ivan on 12/29/16.
 */

public class Grade {
    public double grade;
    public String className;

    public Grade(double g, String s){
        grade = g;
        className = s;
    }
    @Override
    public String toString(){
        String r = className + " : " + String.valueOf(grade);
        return r;
    }

}
