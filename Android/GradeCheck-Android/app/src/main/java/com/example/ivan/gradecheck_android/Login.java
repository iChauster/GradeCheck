package com.example.ivan.gradecheck_android;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.content.Intent;
import android.support.v7.app.AlertDialog;
import android.content.SharedPreferences;
import android.content.DialogInterface;
import java.util.List;
import java.util.ArrayList;
import org.json.*;

import java.io.IOException;

import okhttp3.*;

public class Login extends AppCompatActivity {
    private static final String url = "http://gradecheck.herokuapp.com/";
    private JSONArray confirmationDict;
    private JSONArray master;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_login);
        final Button login = (Button)findViewById(R.id.login);
        final Button register = (Button) findViewById(R.id.register);
        final EditText usn = (EditText)findViewById(R.id.username);
        final EditText psw = (EditText)findViewById(R.id.password);

        final SharedPreferences tings = getSharedPreferences("GradeCheckInfo", 0);
        usn.setText(tings.getString("Username", ""));
        psw.setText(tings.getString("Password", ""));
        if((tings.getString("Username", "").equals("")) && (tings.getString("Password", "").equals(""))) {
            System.out.println("Nothing exists");
            login.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    System.out.println("Executing with login manual");
                    SharedPreferences.Editor editor = tings.edit();
                    String u = usn.getText().toString();
                    String p = psw.getText().toString();
                    editor.putString("id", u);
                    editor.commit();
                    makeLoginRequest(u,p,url);
                }
            });
            register.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    System.out.println("Executing with Register ");
                    String u = usn.getText().toString();
                    String p = psw.getText().toString();
                    makeRegisterRequest(u,p,url);
                }
            });
        }else{
            System.out.println("Executing with defaults");
            String u = tings.getString("Username", "");
            String p = tings.getString("Password", "");
            if (tings.getString("Email", "").equals("")){
                makeLoginRequest(u,p,url);
            }else {
                this.makeLoginRequest(u, p, url);
            }
        }

    }
    public void makeRegisterRequest(String em, String p, String url){
        Req r = new Req();
        final String email = em;
        final String pass = p;
        final String u = url;
        try {
            r.registerRequest(em,p,url + "register", new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    Headers responseHeaders = response.headers();
                    for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                        System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                    }
                    if(response.code() == 200){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                makeLoginRequest(email,pass,u);
                                System.out.println("Registration Sucessful");
                            }
                        });
                    }else if(response.code() == 912){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                System.out.println("Registration Error");
                                new AlertDialog.Builder(Login.this)
                                        .setTitle("Registration Error")
                                        .setMessage("Genesis could not authorize your account. Check your username and password.")
                                        .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int which) {

                                            }
                                        })
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                            }
                        });
                    }

                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }
    }
    public void makeLoginRequest(String u, String p, final String url){
        Req r = new Req();
        final String user = u;
        final String pass = p;
        final SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
        try {
            r.loginRequest(u,p,url + "login", pref, new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    Headers responseHeaders = response.headers();
                    for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                        System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                    }
                    if(response.code() == 200) {
                        SharedPreferences settings = getSharedPreferences("GradeCheckInfo", 0);
                        if(settings.getString("Username", "").equals("") || settings.getString("Password", "").equals("")){
                            SharedPreferences.Editor editor = settings.edit();
                            editor.putString("Username", user);
                            editor.putString("Password", pass);
                            editor.commit();
                        }
                        try {
                            JSONArray j = new JSONArray(response.body().string());
                            master = j;
                            Intent intent = new Intent(getBaseContext(), GradeTable.class);
                            intent.putExtra("DATA", j.toString());
                            System.out.println("Switching screens");
                            startActivity(intent);
                        } catch (JSONException a) {
                            System.out.println(a);
                        }
                    }else if (response.code() == 679){
                        final String s = response.body().string();
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                final SharedPreferences settings = getSharedPreferences("GradeCheckInfo", 0);
                                final SharedPreferences.Editor editor = settings.edit();

                                try{
                                    confirmationDict = new JSONArray(s);
                                    if(settings.getString("Username", "").equals("") || settings.getString("Password","").equals("")){
                                        editor.putString("Username", user);
                                        editor.putString("Password", pass);
                                        editor.commit();
                                    }
                                    System.out.println(confirmationDict);
                                    AlertDialog.Builder alert = new AlertDialog.Builder(Login.this);
                                    if(confirmationDict.length() == 1){
                                        alert.setTitle("Is this you?");
                                    }else{
                                        alert.setTitle("Who are you?");
                                    }
                                    List<String> strarr = new ArrayList<String>();
                                    for (int i = 1; i < confirmationDict.length(); i ++){
                                        JSONObject obj = confirmationDict.getJSONObject(i);
                                        String id = obj.getString("id");
                                        String name = obj.getString("name");
                                        strarr.add(id + " , " + name);
                                    }
                                    alert.setItems(strarr.toArray(new String[0]), new DialogInterface.OnClickListener() {
                                        @Override
                                        public void onClick(DialogInterface dialogInterface, int i) {
                                            try {
                                                JSONObject ob = confirmationDict.getJSONObject(i+1);
                                                System.out.println(settings.getString("Username", ""));
                                                System.out.println(settings.getString("Password", ""));
                                                String id = ob.getString("id");
                                                editor.putString("id", id);
                                                editor.commit();
                                                makeLoginRequest(settings.getString("Username", ""), settings.getString("Password", ""), url);
                                                updateUser("username",id);
                                                updateUser("studId",settings.getString("Username",""));
                                            }catch(JSONException err){
                                                System.err.println(err);
                                            }
                                        }
                                    });
                                    alert.show();
                                }catch(JSONException error){
                                    System.err.println(error);
                                }
                            }
                        });
                    }
                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }
    }
    public void updateUser(String field, String value){
        Req r = new Req();
        final String f = field;
        final String v = value;
        final String u = url;
        String id = "";
        if(confirmationDict != null){
            try {
                id = confirmationDict.getJSONObject(0).getString("_id");
            }catch(JSONException err){
                System.err.println(err);
            }
        }else{
            try {
                JSONObject ob = master.getJSONObject(0);
                JSONArray ar = ob.getJSONArray("objectID");
                id = (String) ar.get(0);
            }catch(JSONException err){
                System.err.println(err);
            }
        }
        try {
            r.updateRequest(f,v,id,url + "update", new Callback() {
                @Override public void onFailure(Call call, IOException e) {
                    System.out.println("Error detected");
                    e.printStackTrace();
                }

                @Override public void onResponse(Call call, Response response) throws IOException {
                    Headers responseHeaders = response.headers();
                    final SharedPreferences pref = getSharedPreferences("GradeCheckInfo", 0);
                    final SharedPreferences.Editor editor = pref.edit();
                    for (int i = 0, size = responseHeaders.size(); i < size; i++) {
                        System.out.println(responseHeaders.name(i) + ": " + responseHeaders.value(i));
                    }
                    if(response.code() == 200){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                if(f.equals("username")){
                                    editor.putString("Email",pref.getString("Username", ""));
                                    editor.putString("Username",v);
                                    editor.commit();
                                }
                            }
                        });
                    }else if(response.code() == 1738){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                System.out.println("Username Taken");
                                new AlertDialog.Builder(Login.this)
                                        .setTitle("Registration Error")
                                        .setMessage("Looks like you already have an account. Try logging in with your student pin and Genesis password.")
                                        .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int which) {

                                            }
                                        })
                                        .setIcon(android.R.drawable.ic_dialog_alert)
                                        .show();
                            }
                        });
                    }

                }
            });
        } catch (Exception e) {
            System.out.println("Error");
            e.printStackTrace();
        }

    }
}
