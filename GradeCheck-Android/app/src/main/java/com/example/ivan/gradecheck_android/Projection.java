package com.example.ivan.gradecheck_android;

import android.content.res.ColorStateList;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.view.GestureDetectorCompat;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;
import android.transition.Explode;
import android.app.Activity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Iterator;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Headers;
import okhttp3.Response;

/**
 * Created by ivan on 5/26/17.
 */

public class Projection extends AppCompatActivity {
    private String URL = "http://gradecheck.herokuapp.com/";
    private String cookie;
    private String id;
    private TextView projection;
    private TextView resultText;
    private GestureDetectorCompat mDetector;

    private JSONArray otherAssignments;
    private JSONObject fin = new JSONObject();
    private JSONArray weights;
    private JSONObject originalMin;
    private JSONObject data;
    private String category;
    private boolean categoryConversion;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.projection);
        setupWindowAnimations();
        final RecyclerView.LayoutManager ls = new LinearLayoutManager(this);
        Bundle e = getIntent().getExtras();
        if (e != null) {
            String value = e.getString("class");
            String dataSet = e.getString("dataSet");
            String[] auth = e.getStringArray("auth");
            String classCodes = e.getString("classCodes");
            System.out.println("not null");
            TextView assignment = (TextView) findViewById(R.id.assignment);
            try {
                JSONObject js = new JSONObject(value);
                data = js;
                JSONArray ds = new JSONArray(dataSet);
                otherAssignments = ds;
                category = js.getString("category");
                // parse this
                System.out.println("Object : " + js);
                JSONObject detail = js.getJSONObject("assignment");
                assignment.setText(detail.getString("title"));
                String cs = classCodes;
                String namepass[] = cs.split(":");
                String course = namepass[0];
                String section = namepass[1];
                cookie = auth[0];
                id = auth[1];
                this.getWeighting(cookie,id,course,section,URL);

            } catch (JSONException exception) {
                System.err.println(exception);
            }
        }
        projection = (TextView) findViewById(R.id.projectionText);
        resultText = (TextView) findViewById(R.id.resultText);
        mDetector = new GestureDetectorCompat(this, new GestureList(this));

        projection.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                mDetector.onTouchEvent(motionEvent);
                return true;
            }
        });
        setColor(100);
        projection.setText("100%");

    }
    private void setupWindowAnimations() {
        if(Build.VERSION.SDK_INT >= 21) {
            Explode ex = new Explode();
            ex.setDuration(1000);
            getWindow().setEnterTransition(ex);
        }
    }
    public void dealWithChange(int change){
        String text = (String) projection.getText();
        text = text.substring(0,text.length() - 1);
        int numberEquivalent = Integer.parseInt(text);
        numberEquivalent += change;
        if(numberEquivalent >= 100){
            numberEquivalent = 100;
        }else if(numberEquivalent <= 0){
            numberEquivalent = 0;
        }
        setColor(numberEquivalent);
        projection.setText(numberEquivalent + "%");
        adjustMin();
    }

    public void getWeighting(String cookie, String id, String course, String section, String URL) {
        Req r = new Req();
        System.out.println(cookie);
        System.out.println(id);
        System.out.println(course);
        System.out.println(section);
        System.out.println(URL);
        try {
            r.getClassWeighting(cookie, id, course, section, URL + "getClassWeighting", new Callback() {
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
                            if(j.getString(0).equals("Total Points")){
                                System.out.println("Total point conv");
                                categoryConversion = false;
                            }else if((j.getString(0).equals("Category Weighting"))){
                                categoryConversion = true;
                                JSONArray arr = j.getJSONArray(1);
                                weights = arr;
                            }
                            sum();
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
    public void sum(){
        try {
            System.out.println(otherAssignments);
            JSONObject dict = data.getJSONObject("assignment");
            String title = dict.getString("title");
            for(int i = 0; i < otherAssignments.length(); i ++){
                JSONObject not = otherAssignments.getJSONObject(i);
                String key = not.getString("category");
                JSONObject d = not.getJSONObject("assignment");
                if(d.getString("title").equals(title)) {
                    if (fin.has(key)) {
                        System.out.println(key + " exists");
                        System.out.println(fin.get(key));
                    } else {
                        JSONArray arr = new JSONArray();
                        arr.put(0, 0.0);
                        arr.put(1, 0.0);
                        fin.put(not.getString("category"), arr);
                    }
                }else{
                    if(not.getString("grade") != null && !not.getString("grade").equals("")){
                        if(fin.has(key)){
                            System.out.println(key + " exists");
                            JSONArray val = fin.getJSONArray(key);
                            System.out.println(val);
                            Double min = val.getDouble(0);
                            Double max =val.getDouble(1);
                            Double ayy = Double.parseDouble(not.getString("grade"));
                            min += ayy;
                            max += Double.parseDouble(not.getString("gradeMax"));
                            val.put(0, min);
                            val.put(1, max);
                        }else{
                            JSONArray js = new JSONArray();
                            System.out.println(not);
                            String min = not.getString("grade");
                            String max = not.getString("gradeMax");
                            js.put(0,min);
                            js.put(1,max);
                            fin.put(not.getString("category"), js);
                        }
                    }
                }
            }
            this.originalMin = new JSONObject(fin.toString());
            System.out.println(originalMin);
            adjustMin();
        }catch(JSONException e){
            System.err.println(e);
        }
    }
    public void adjustMin(){
        try {
            if (data.getString("gradeMax") != null) {
                Double a = Double.parseDouble(data.getString("gradeMax"));
                Double minscore = getProjectionValue() * 0.01 * a;
                System.out.println(originalMin.get(category));
                JSONArray arr = originalMin.getJSONArray(category);
                Double minDoubs = arr.getDouble(0);
                Double newMin = minDoubs + minscore;
                Double maxDoubs = arr.getDouble(1);
                Double newMax = maxDoubs + Double.parseDouble(data.getString("gradeMax"));
                JSONArray array = new JSONArray();
                array.put(0,newMin);
                array.put(1,newMax);
                fin.put(category,array);
                findFinalGrade();
            }
        }catch(JSONException e){
            System.err.println(e);
        }
    }
    public void findFinalGrade(){
        if(categoryConversion){
            Double finalGrade = 0.0;
            Double totalWeights = 0.0;
            for(int i = 0; i < weights.length(); i ++){
                try {
                    JSONObject dict = weights.getJSONObject(i);
                    Iterator<?> keys = dict.keys();

                    while( keys.hasNext() ) {
                        String key = (String)keys.next();
                        if (key.equals("category")) {
                            System.out.println(fin);
                            if(fin.get(dict.getString(key)) instanceof JSONArray){
                                JSONArray array =  fin.getJSONArray(dict.getString(key));
                                double percentage = array.getDouble(0)/array.getDouble(1);
                                System.out.println("should multiply" + percentage + "with" + dict.getString("weight"));
                                String pe = dict.getString("weight").substring(0,dict.getString("weight").length() - 2);
                                totalWeights += Double.parseDouble(pe);
                                System.out.println(pe);
                                finalGrade += Double.parseDouble(pe) * 0.01 * percentage;
                            }
                        }
                    }
                }catch(JSONException e){
                    System.err.println(e);
                }
            }
            System.out.println("totalWeights : " + totalWeights);
            finalGrade *= 100.0;
            finalGrade /= totalWeights;
            finalGrade *= 100.0;
            System.out.println(finalGrade);

            final double gr = Math.round(finalGrade*100)/100.0;

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    resultText.setText(gr + "%");
                }
            });
        }else{
            System.out.println(fin);
            Double gradeMax = 0.0;
            Double gradeAcheived = 0.0;
            Iterator<?> keys = fin.keys();

            while( keys.hasNext() ) {
                String key = (String)keys.next();
                try {
                    JSONArray arr = fin.getJSONArray(key);
                    gradeAcheived += arr.getDouble(0);
                    gradeMax += arr.getDouble(1);
                }catch(JSONException e){
                    System.err.println(e);
                }
            }
            Double percentage = gradeAcheived / gradeMax * 100;
            System.out.println(percentage);
            final double gr = Math.round(percentage*100)/100.0;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    resultText.setText(gr + "%");
                }
            });
        }
    }
    public Double getProjectionValue(){
        String text = (String) projection.getText();
        text = text.substring(0, text.length() - 1);
        System.out.println(text);
        return Double.parseDouble(text);
    }
    public void setColor(int grade){
        int color = new GradeCheckColor().getColorWithGrade(grade);
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
            projection.setBackgroundTintList(colorList);
        }
    }
}
class GestureList extends GestureDetector.SimpleOnGestureListener {
    private float initialY;
    private Projection act;
    public GestureList(Activity a){
        act = (Projection) a;
    }
    @Override
    public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY){
        int dist = (int) distanceY / 10;
        act.dealWithChange(dist);
        return true;
    }
    @Override
    /**
     * Don't know why but we need to intercept this guy and return true so that the other gestures are handled.
     * https://code.google.com/p/android/issues/detail?id=8233
     */
    public boolean onDown(MotionEvent e) {
        return true;
    }
}

