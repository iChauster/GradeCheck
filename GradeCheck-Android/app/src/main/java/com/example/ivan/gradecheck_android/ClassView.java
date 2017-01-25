package com.example.ivan.gradecheck_android;

import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.RecyclerView;
import android.transition.*;
import android.widget.Toolbar;
import android.view.MenuItem;
import android.content.Intent;
import org.json.JSONArray;

import org.json.JSONException;

public class ClassView extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_class_view);
        setupWindowAnimations();
        Toolbar myToolbar = (Toolbar) findViewById(R.id.my_toolbar);
        RecyclerView tableView = (RecyclerView) findViewById(R.id.tableView);
        Bundle e = getIntent().getExtras();
        if (e != null) {
            String value = e.getString("class");
            try {
                JSONArray js = new JSONArray(value);

                RecyclerView.Adapter ra = new AssignmentCellAdapter(js);
                tableView.setAdapter(ra);

            } catch (JSONException exception) {
                System.err.println(exception);
            }
        }
        if(Build.VERSION.SDK_INT >= 21) {
            setActionBar(myToolbar);
            getActionBar().setDisplayHomeAsUpEnabled(true);
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
