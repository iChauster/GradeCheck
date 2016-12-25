package com.example.ivan.gradecheck_android;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.content.Intent;
import android.content.SharedPreferences;
import org.json.*;

import java.io.IOException;

import okhttp3.*;

public class Login extends AppCompatActivity {
    private static final String url = "http://gradecheck.herokuapp.com/";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);
        final Button login = (Button)findViewById(R.id.login);
        final EditText usn = (EditText)findViewById(R.id.username);
        final EditText psw = (EditText)findViewById(R.id.password);
        SharedPreferences tings = getSharedPreferences("GradeCheckInfo", 0);
        usn.setText(tings.getString("Username", ""));
        psw.setText(tings.getString("Password", ""));
        if((tings.getString("Username", "").equals("")) && (tings.getString("Password", "").equals(""))) {
            System.out.println("Nothing exists");
            login.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    System.out.println("Executing with login manual");
                    String u = usn.getText().toString();
                    String p = psw.getText().toString();
                    makeLoginRequest(u,p,url);
                }
            });
        }else{
            System.out.println("Executing with defaults");
            String u = tings.getString("Username", "");
            String p = tings.getString("Password", "");
            this.makeLoginRequest(u,p, url);
        }

    }
    public void makeLoginRequest(String u, String p, String url){
        Req r = new Req();
        final String user = u;
        final String pass = p;
        try {
            r.loginRequest(u,p,url + "login", new Callback() {
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

                    SharedPreferences settings = getSharedPreferences("GradeCheckInfo", 0);
                    SharedPreferences.Editor editor = settings.edit();
                    editor.putString("Username",user);
                    editor.putString("Password",pass);
                    editor.putString("id",user);
                    editor.commit();
                    try {
                        JSONArray j = new JSONArray(response.body().string());
                        Intent intent = new Intent(getBaseContext(), GradeTable.class);
                        intent.putExtra("DATA", j.toString());
                        System.out.println("Switching screens");
                        startActivity(intent);
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
