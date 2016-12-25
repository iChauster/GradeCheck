package com.example.ivan.gradecheck_android;

import android.content.Intent;
import android.graphics.Color;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.ViewFlipper;
import android.support.v7.widget.*;
import org.json.*;
import android.content.SharedPreferences;

import java.io.IOException;

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
    private SwipeRefreshLayout gradeSl;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_grade_table);
        tableView = (RecyclerView) findViewById(R.id.gradeView);
        RecyclerView statisticsView = (RecyclerView) findViewById(R.id.lineUpView);
        assignmentView = (RecyclerView) findViewById(R.id.assignmentView);
        gradeSl = (SwipeRefreshLayout) findViewById(R.id.SwipeLayout);
        gradeSl.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
                refreshGrades(cookie,pref.getString("id", ""), URL);
            }
        });
        tableView.setHasFixedSize(true);
        final RecyclerView.LayoutManager lm = new LinearLayoutManager(this);
        tableView.setLayoutManager(lm);
        final RecyclerView.LayoutManager la = new LinearLayoutManager(this);
        assignmentView.setLayoutManager(la);
        final RecyclerView.LayoutManager ls = new LinearLayoutManager(this);
        statisticsView.setLayoutManager(ls);
        PagerBottomTabLayout tab = (PagerBottomTabLayout) findViewById(R.id.tab);
        VF = (ViewFlipper) findViewById(R.id.ViewFlipper);
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
                cookie = co.get(0).toString();
                RecyclerView.Adapter ra = new GradeCellAdapter(j);
                tableView.setAdapter(ra);
            }catch(JSONException a){
                System.err.println(a);
            }
        }
    }
    public void layoutAssignments(JSONArray a){
        final JSONArray b = a;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                RecyclerView.Adapter assignmentAdapter = new AssignmentCellAdapter(b);
                assignmentView.setAdapter(assignmentAdapter);
                VF.setDisplayedChild(1);
            }
        });
    }
    public void refreshGradesLayout (JSONArray g){
        final JSONArray b = g;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                RecyclerView.Adapter newGradeAdapter = new GradeCellAdapter(b);
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
    public void setCookie(String c){
        this.cookie = c;
    }
    public void checkCookieAndValidate(String co){
        Req r = new Req();
        try {
            SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
            String U = pref.getString("Username", "");
            String P = pref.getString("Password", "");
            r.reLoginRequest(co,U,P, URL + "assignments", new Callback() {
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
                        setCookie(o.getString("cookie"));
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

        try {
            r.gradeBookRequest(cookie,id,URL + "gradebook", new Callback() {
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
                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }
    }
}
