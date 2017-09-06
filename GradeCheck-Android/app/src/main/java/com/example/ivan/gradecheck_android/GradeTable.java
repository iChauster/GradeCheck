package com.example.ivan.gradecheck_android;

import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Build;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.transition.Explode;
import android.app.Activity;
import android.transition.Fade;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.ViewFlipper;
import android.support.v7.widget.*;
import android.content.Context;
import android.widget.TextView;
import org.json.*;
import android.content.SharedPreferences;

import com.daimajia.androidanimations.library.Techniques;
import com.daimajia.androidanimations.library.YoYo;

import java.io.IOException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Collections;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.text.DateFormat;
import java.util.Locale;
import java.util.Arrays;

import me.majiajie.pagerbottomtabstrip.PagerBottomTabLayout;
import me.majiajie.pagerbottomtabstrip.TabItemBuilder;
import me.majiajie.pagerbottomtabstrip.listener.OnTabItemSelectListener;
import me.majiajie.pagerbottomtabstrip.Controller;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Headers;
import okhttp3.Response;

public class GradeTable extends AppCompatActivity{
    private Controller controller;
    private ViewFlipper VF;
    private String cookie;
    private String URL = "http://gradecheck.herokuapp.com/";
    private RecyclerView assignmentView;
    private RecyclerView tableView;
    private RecyclerView gradeList;
    private SwipeRefreshLayout gradeSl;
    private SwipeRefreshLayout assignmentSl;
    private TextView noAssignments;
    private LinearLayout gpaView;
    private TextView gpaText;
    private TextView gpaNum;
    private JSONArray gs;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_grade_table);
        tableView = (RecyclerView) findViewById(R.id.gradeView);
        gradeList = (RecyclerView) findViewById(R.id.lineUpView);
        assignmentView = (RecyclerView) findViewById(R.id.assignmentView);
        noAssignments = (TextView) findViewById(R.id.noAssignments);
        gpaView = (LinearLayout) findViewById(R.id.gpaView);
        gpaText = (TextView) findViewById(R.id.gpaText);
        gpaNum = (TextView) findViewById(R.id.gpaNumericText);
        gradeSl = (SwipeRefreshLayout) findViewById(R.id.SwipeLayout);
        gradeSl.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
                refreshGrades(cookie,pref.getString("id", ""), URL);
            }
        });
        assignmentSl = (SwipeRefreshLayout) findViewById(R.id.AssignmentsSwipeLayout);
        assignmentSl.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
                makeAssignmentRequest(cookie,pref.getString("id", ""), URL);
            }
        });
        tableView.setHasFixedSize(true);
        final RecyclerView.LayoutManager lm = new LinearLayoutManager(this);
        tableView.setLayoutManager(lm);
        final RecyclerView.LayoutManager la = new LinearLayoutManager(this);
        assignmentView.setLayoutManager(la);
        final RecyclerView.LayoutManager ls = new LinearLayoutManager(this);
        gradeList.setLayoutManager(ls);
        PagerBottomTabLayout tab = (PagerBottomTabLayout) findViewById(R.id.tab);
        VF = (ViewFlipper) findViewById(R.id.ViewFlipper);
        setupWindowAnimations();
        TabItemBuilder grades = new TabItemBuilder(this).create()
                .setText("Grades")
                .setSelectedColor(Color.parseColor("#25A308"))
                .setDefaultIcon(R.drawable.grades)
                .build();
        TabItemBuilder assignments = new TabItemBuilder(this).create()
                .setText("Assignments")
                .setSelectedColor(Color.parseColor("#25A308"))
                .setDefaultIcon(R.drawable.assignments)
                .build();
        TabItemBuilder statistics = new TabItemBuilder(this).create()
                .setText("Statistics")
                .setSelectedColor(Color.parseColor("#25A308"))
                .setDefaultIcon(R.drawable.statistics)
                .build();

        controller = tab.builder()
                .setDefaultColor(Color.parseColor("#000000"))
                .addTabItem(grades)
                .addTabItem(assignments)
                .addTabItem(statistics)
                .build();
        controller.addTabItemClickListener(listener);

        // specify an adapter (see also next example)

        Bundle e = getIntent().getExtras();
        if (e != null) {
            String value = e.getString("DATA");
            try {
                JSONArray j = new JSONArray(value);
                JSONObject js =  j.getJSONObject(0);
                JSONArray co = (JSONArray) js.get("cookie");
                gs = j;
                cookie = co.get(0).toString();
                RecyclerView.Adapter ra = new GradeCellAdapter(j, this);
                tableView.setAdapter(ra);
            }catch(JSONException a){
                System.err.println(a);
            }
        }
    }
    private void setupWindowAnimations(){
        if(Build.VERSION.SDK_INT >= 21) {
            Fade ex = new Fade();
            ex.setDuration(1000);
            getWindow().setExitTransition(ex);
        }

    }
    public String[] getCookieAndID(){
        SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);

        String id = pref.getString("id", "");
        String[] a = new String[]{cookie,id};
        return a;
    }
    public void layoutAssignments(JSONArray a){
        final JSONArray b = a;
        final Context c = this;

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                int index = 0;
                assignmentSl.setRefreshing(false);
                List<SimpleSectionedRecyclerViewAdapter.Section> sections =
                        new ArrayList<SimpleSectionedRecyclerViewAdapter.Section>();

                //Sections
                System.out.println(b);
                for (int i = 0; i < b.length(); i ++){
                    try {
                        JSONObject obj = b.getJSONObject(i);
                        String date = obj.getString("stringDate");
                        String d = date.replace("\\", "");
                        DateFormat format = new SimpleDateFormat("M/dd/yyyy", Locale.ENGLISH);
                        try{
                            Date newDate = format.parse(d);
                            if(newDate.compareTo(new Date()) < 0){
                                System.out.println("less than zero for " + i);
                                index = i;
                            }
                        }catch(ParseException e){
                            System.err.println(e);
                        }
                        System.out.println(date);
                    }catch (JSONException e){
                        System.err.print(e);
                    }
                }
                ArrayList<JSONObject> before = new ArrayList<JSONObject>();
                ArrayList<JSONObject> after = new ArrayList<JSONObject>();
                for(int i = 0; i < b.length(); i ++){

                    try {
                        JSONObject o = b.getJSONObject(i);
                        if(i <= index){
                            after.add(o);
                        }else{
                            before.add(o);
                        }
                    }catch(JSONException e){
                        System.err.println(e);
                    }
                }
                before.addAll(after);
                JSONArray fin = new JSONArray(before);
                sections.add(new SimpleSectionedRecyclerViewAdapter.Section(0,"UPCOMING"));
                sections.add(new SimpleSectionedRecyclerViewAdapter.Section(b.length()-index-1,"COMPLETED"));
                Activity d = (Activity) c;
                //Add your adapter to the sectionAdapter
                SimpleSectionedRecyclerViewAdapter.Section[] dummy = new SimpleSectionedRecyclerViewAdapter.Section[sections.size()];
                SimpleSectionedRecyclerViewAdapter mSectionedAdapter = new
                        SimpleSectionedRecyclerViewAdapter(c,R.layout.section,R.id.section_text, new AssignmentCellAdapter(fin, d));
                mSectionedAdapter.setSections(sections.toArray(dummy));

                //Apply this adapter to the RecyclerView
                RecyclerView.Adapter assignmentAdapter = mSectionedAdapter;
                assignmentView.setAdapter(assignmentAdapter);
                if(b.length() != 0) {
                    System.out.println("THERE ARE ASSIGNMENTS TO BE DISPLAYED");
                    noAssignments.setVisibility(View.INVISIBLE);
                    assignmentView.setVisibility(View.VISIBLE);
                }else{
                    System.out.println("THERE ARE NO ASSIGNMENTS TO BE DISPLAYED");
                    noAssignments.setVisibility(View.VISIBLE);
                    assignmentView.setVisibility(View.INVISIBLE);
                }
                VF.setDisplayedChild(1);

            }
        });
    }
    public void refreshGradesLayout (JSONArray g){
        final JSONArray b = g;
        final Activity gt = this;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                RecyclerView.Adapter newGradeAdapter = new GradeCellAdapter(b, gt);
                tableView.swapAdapter(newGradeAdapter, true);
                newGradeAdapter.notifyDataSetChanged();
                gradeSl.setRefreshing(false);
            }
        });
    }

    OnTabItemSelectListener listener = new OnTabItemSelectListener() {
        @Override
        public void onSelected(int index, Object tag) {
            if(index == 1){
                System.out.println("Assignments pressed, sending request");
                SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
                if(assignmentView.getAdapter() != null){
                    VF.setDisplayedChild(index);
                }else {
                    makeAssignmentRequest(cookie, pref.getString("id", ""), URL);
                }
            }else if (index == 2){
                VF.setDisplayedChild(index);
                YoYo.with(Techniques.Bounce).playOn(gpaView);
                Map gpa = calcGPA();
                gpaText.setText(String.valueOf(gpa.get("gpa")));
                gpaNum.setText(String.valueOf(gpa.get("num")) + "%");
                layoutStatTable((List<Grade>) gpa.get("sorted"));
                System.out.println("Statistics pressed");
            }else{
                VF.setDisplayedChild(index);
            }
        }

        @Override
        public void onRepeatClick(int index, Object tag) {
            System.out.println("Index : " + index + " Tag : " + tag.toString());
        }
    };
    public void layoutStatTable(List<Grade> list){
        Activity a = this;
        if(gradeList.getAdapter() == null){
            gradeList.setAdapter(new StatCellAdapter(list,a));
        }else{
            gradeList.swapAdapter(new StatCellAdapter(list,a), true);
        }
    }
    public Map calcGPA(){
        Map m = new HashMap();
        int classes = 0;
        int gpaTotal = 0;
        int gradeTotal = 0;
        List<Grade> sortedArray = new ArrayList<Grade>();
        System.out.println(gs);
        for (int i = 1; i < gs.length(); i ++){
            try {
                JSONObject obj = gs.getJSONObject(i);

                String gr = String.valueOf(obj.get("grade"));
                double doubGrade = Double.parseDouble(gr.substring(0,gr.length()-1));
                String className = obj.getString("class");
                System.out.println(doubGrade);
                if(gr.equals("No Grades") || gr.equals("0%")){
                    Grade g = new Grade(doubGrade, className);
                    g.setClassCode(obj.getString("classCodes"));
                    sortedArray.add(g);
                    continue;
                }
                if((className.contains(" H") && className.charAt(className.length()-1) == 'H') || className.contains("Honors") || className.contains("AP") || className.contains("Hon")){
                    System.out.println(className + " is a Honors Class");
                    double grade = doubGrade + 5;
                    gradeTotal += grade;
                    Grade g = new Grade(doubGrade, className);
                    g.setClassCode(obj.getString("classCodes"));
                    sortedArray.add(g);
                    if(grade > 100){
                        grade = 100;
                    }
                    gpaTotal += grade;
                    classes ++;
                }else{
                    double grade = doubGrade;
                    gradeTotal += grade;
                    Grade g = new Grade(grade, className);
                    g.setClassCode(obj.getString("classCodes"));
                    sortedArray.add(g);
                    if(grade > 95){
                        grade = 95;
                    }
                    gpaTotal += grade;
                    classes ++;
                }
            }catch (JSONException error){
                System.err.print(error);
            }
        }
        double av = gradeTotal / (double) classes;
        av = Math.round(av * 100.0) / 100.0;
        double gpaAvg = gpaTotal / (double) classes;
        System.out.println(gpaTotal);
        double gpaDiff = 10 - Math.round(gpaAvg) / 10.0;
        double gpa = Math.round((4.5 - gpaDiff)*100.0)/100.0;
        m.put("gpa", gpa);
        m.put("num" , av);
        Collections.sort(sortedArray, new Comparator<Grade>() {
            @Override public int compare(Grade g1, Grade g2) {
                return (int)(g2.grade - g1.grade); // Ascending
            }

        });
        m.put("sorted", sortedArray);
        int color = Color.parseColor("#00C853");
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
            gpaView.setBackgroundTintList(colorList);
        }
        return m;
    }
    public void setCookie(String c){
        System.out.println("Cookie set " + this.cookie);
        this.cookie = c;
        System.out.println("Cookie set to " + this.cookie);

    }
    public void checkCookieAndValidate(String co){
        Req r = new Req();
        try {
            SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
            String U = pref.getString("Username", "");
            String P = pref.getString("Password", "");
            r.reLoginRequest(co,U,P, URL + "relogin", new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.err.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    if (!response.isSuccessful())
                        throw new IOException("Unexpected code " + response);

                    Headers responseHeaders = response.headers();
                    for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                        System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                    }

                    try {
                        JSONArray j = new JSONArray(response.body().string());
                        JSONObject o = j.getJSONObject(0);
                        JSONArray at = o.getJSONArray("cookie");
                        setCookie(at.get(0).toString());
                    } catch (JSONException a) {
                        System.err.println(a);
                    }
                }
            });
        } catch (Exception e) {
            System.err.println("Error");
            e.printStackTrace();
        }

    }
    public void refreshGrades(String cookie, String id, String URL){
        Req r = new Req();
        System.out.println(cookie);
        System.out.println(id);
        System.out.println(URL);
        try {
            r.gradeBookRequest(cookie,id,URL + "gradebook", new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {

                    if(response.code() == 200) {
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }

                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());
                            refreshGradesLayout(j);

                        } catch (JSONException a) {
                            System.out.println(a);
                        }
                    }else if(response.code() == 440){
                        System.out.println("Needs Refresh");
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }
                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());
                            JSONObject cok = j.getJSONObject(0);
                            JSONArray hafl = cok.getJSONArray("set-cookie");
                            checkCookieAndValidate(hafl.getString(0));
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    gradeSl.setRefreshing(false);
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
    public void makeAssignmentRequest(String cookie, String id, String URL){
        Req r = new Req();
        try {
            r.assignmentRequest(cookie,id,URL + "assignments", new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    if (!response.isSuccessful())
                        throw new IOException("Unexpected code " + response);
                    if(response.code() == 200) {
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }

                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());
                            layoutAssignments(j);

                        } catch (JSONException a) {
                            System.out.println(a);
                        }
                    }else if (response.code() == 440){
                        System.out.println("Needs Refresh");
                        Headers responseHeaders = response.headers();
                        for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                            System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                        }
                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            System.out.println(j.toString());
                            JSONObject cok = j.getJSONObject(0);
                            JSONArray hafl = cok.getJSONArray("set-cookie");
                            checkCookieAndValidate(hafl.getString(0));
                            gradeSl.setRefreshing(false);
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
}
