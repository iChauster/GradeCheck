package com.example.ivan.gradecheck_android;

import android.app.Activity;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.transition.*;
import android.widget.Toolbar;
import android.view.MenuItem;
import android.content.Intent;
import org.json.JSONArray;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Arrays;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Headers;
import okhttp3.Response;

public class ClassView extends AppCompatActivity {
    private String URL = "http://gradecheck.herokuapp.com/";
    private RecyclerView tableView;
    private String title;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_class_view);
        setupWindowAnimations();
        Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        tableView = (RecyclerView) findViewById(R.id.tableView);
        final RecyclerView.LayoutManager ls = new LinearLayoutManager(this);
        tableView.setLayoutManager(ls);
        Bundle e = getIntent().getExtras();
        if (e != null) {
           String value = e.getString("class");
            String[] auth = e.getStringArray("auth");

            try {
                JSONObject js = new JSONObject(value);
                // parse this
                title = js.getString("class") + " : " + js.getString("grade");
                String cs = js.getString("classCodes");
                String namepass[] = cs.split(":");
                String course = namepass[0];
                String section = namepass[1];
                makeClassAssignmentsRequest(auth[0], auth[1], course, section, URL);
                /*RecyclerView.Adapter ra = new AssignmentCellAdapter(js);
                tableView.setAdapter(ra);*/

            } catch (JSONException exception) {
                System.err.println(exception);
            }
        }
        if(Build.VERSION.SDK_INT >= 21) {
            setActionBar(myToolbar);
            getActionBar().setDisplayHomeAsUpEnabled(true);
            getActionBar().setTitle(title);
            myToolbar.requestLayout();
        }

    }
    public void makeClassAssignmentsRequest(String cookie, String id, String course, String section, String URL) {
        Req r = new Req();
        System.out.println(cookie);
        System.out.println(id);
        System.out.println(URL);
        try {
            r.classRequest(cookie, id, course, section, URL + "listassignments", new Callback() {
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
                            refreshClassAssignmentsLayout(j);

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
    public void refreshClassAssignmentsLayout(JSONArray json){
        final JSONArray b = json;
        final Activity gt = this;
        /*RecyclerView.Adapter ra = new AssignmentCellAdapter(js);
        tableView.setAdapter(ra);*/
        final RecyclerView.Adapter newGradeAdapter = new AssignmentCellAdapter(b);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(tableView.getAdapter() == null) {
                    tableView.setAdapter(newGradeAdapter);
                }else {
                    tableView.swapAdapter(newGradeAdapter, true);
                    newGradeAdapter.notifyDataSetChanged();
                }
            }
        });
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
