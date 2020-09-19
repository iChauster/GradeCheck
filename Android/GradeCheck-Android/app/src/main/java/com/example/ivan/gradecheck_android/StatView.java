package com.example.ivan.gradecheck_android;

import android.graphics.Color;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.transition.Explode;
import android.view.MenuItem;
import android.widget.Toolbar;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.*;
import com.github.mikephil.charting.data.*;
import com.github.mikephil.charting.animation.Easing;
import java.util.ArrayList;
import java.util.List;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Headers;
import okhttp3.Response;

public class StatView extends AppCompatActivity {
    private String title;
    private String URL = "http://gradecheck.herokuapp.com/";
    private LineChart chart;
    private double currentGrade;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stat_view);
        setupWindowAnimations();
        Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        chart = (LineChart) findViewById(R.id.chart);
        Bundle e = getIntent().getExtras();
        if (e != null) {
            String value = e.getString("class");
            double grade = e.getDouble("grade");
            currentGrade = grade;
            String classCode = e.getString("classCode");
            if(grade != 0){
                String[] auth = e.getStringArray("auth");
                String namepass[] = classCode.split(":");
                String course = namepass[0];
                String section = namepass[1];
                getClassPerformance(value,course,section,auth[0], auth[1], URL);
            }
            title = value;
            makeClassDataRequest(value, URL);
        }
        if(Build.VERSION.SDK_INT >= 21) {
            setActionBar(myToolbar);
            getActionBar().setDisplayHomeAsUpEnabled(true);
            getActionBar().setTitle(title);
            myToolbar.requestLayout();
        }
    }
    public void getClassPerformance(String className, String course, String section, String cookie, String id, String URL){
        Req r = new Req();

        System.out.println(URL);
        try {
            r.classAveragesRequest(className,course,section,cookie,id,URL+"classAverages", new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {

                    if (response.code() == 200) {
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }

                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());

                        } catch (JSONException a) {
                            System.out.println(a);
                        }
                    }
                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }
    }
    public void makeClassDataRequest(String cn, String URL){
        Req r = new Req();

        System.out.println(URL);
        try {
            r.classDataRequest(cn, URL + "classdata", new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {

                    if (response.code() == 200) {
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }

                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());
                            final List<Entry> entries = new ArrayList<Entry>();

                            for (int i = 0; i < j.length(); i ++){
                                try {
                                    JSONObject obj = j.getJSONObject(i);
                                    entries.add(new Entry(Float.parseFloat(obj.getString("grade")),Float.parseFloat(obj.getString("occurences"))));
                                }catch (JSONException e){
                                    System.err.print(e);
                                }

                            }
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    LineDataSet dataSet = new LineDataSet(entries, "Students"); // add entries to dataset
                                    dataSet.setMode(LineDataSet.Mode.CUBIC_BEZIER);
                                    dataSet.setLineWidth(2);
                                    dataSet.setCircleRadius(5);
                                    dataSet.setFillAlpha(62/255);
                                    dataSet.setDrawCircleHole(true);
                                    dataSet.setFillColor(Color.GREEN);
                                    dataSet.setHighLightColor(Color.WHITE);
                                    dataSet.setCircleColor(Color.WHITE);
                                    dataSet.setColor(Color.WHITE);
                                    LimitLine line = new LimitLine((float) currentGrade);
                                    line.setLabel("You");
                                    line.setLineColor(Color.RED);
                                    line.setEnabled(true);
                                    line.setLineWidth(2);
                                    line.setTextColor(Color.WHITE);
                                    chart.getXAxis().addLimitLine(line);
                                    LineData lineData = new LineData(dataSet);
                                    lineData.setValueTextColor(Color.WHITE);
                                    chart.setData(lineData);
                                    chart.getXAxis().setTextColor(Color.WHITE);
                                    Description d = new Description();
                                    d.setTextColor(Color.WHITE);
                                    chart.getAxisLeft().setTextColor(Color.WHITE);
                                    chart.getAxisRight().setTextColor(Color.WHITE);
                                    chart.setBackgroundColor(Color.parseColor("#26A65B"));
                                    d.setText("Grade Curve");
                                    chart.setDescription(d);
                                    chart.animateY(3000,Easing.EasingOption.EaseInOutQuart);
                                    chart.invalidate(); // refresh
                                }
                            });

                        } catch (JSONException a) {
                            System.out.println(a);
                        }
                    }
                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }
    }
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                if(Build.VERSION.SDK_INT >= 21) {
                    finishAfterTransition();
                }
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }
    private void setupWindowAnimations() {
        if(Build.VERSION.SDK_INT >= 21) {
            Explode ex = new Explode();
            ex.setDuration(1000);
            getWindow().setEnterTransition(ex);
        }
    }
}
