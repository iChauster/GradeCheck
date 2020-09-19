package com.example.ivan.gradecheck_android;

/**
 * Created by ivan on 12/8/16.
 */
import android.content.SharedPreferences;

import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.*;
import java.io.IOException;
import java.io.StringReader;

public class Req {
    private final OkHttpClient client = new OkHttpClient();

    public void loginRequest(String username, String password, String URL, SharedPreferences pref, Callback c) throws Exception {
        String req = "username=" + username + "&password=" + password;
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        if (pref.getString("id", "") != null) {
            String id = pref.getString("id", "");
            req += "&id=" + id;
        }
        if (pref.getString("Email", "") != null) {
            String email = pref.getString("Email", "");
            req += "&email" + email;
        }
        RequestBody body = RequestBody.create(mediaType, req);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void registerRequest(String email, String password, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "username=" + email + "&password=" + password);
        //add a Device Token when push notifications are necessary.
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void assignmentRequest(String cookie, String id, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "cookie=" + cookie + "&id=" + id);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void gradeBookRequest(String cookie, String id, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "cookie=" + cookie + "&id=" + id);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void classRequest(String cookie, String id, String course, String section, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "cookie=" + cookie + "&id=" + id + "&course=" + course + "&section=" + section);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void classDataRequest(String className, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "className=" + className);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }

    public void classAveragesRequest(String className, String course, String section, String cookie, String id, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "className=" + className + "&course=" + course + "&section=" + section+"&cookie=" + cookie + "&id=" + id);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }
    public void getClassWeighting(String cookie, String id, String courseCode, String courseSection, String URL, Callback c) throws Exception {
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "courseSection=" + courseSection + "&courseCode=" + courseCode + "&cookie=" + cookie + "&id=" + id);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }
    public void reLoginRequest(String cookie, String username, String password, String URL, Callback c) throws Exception{
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "username=" + username + "&password=" + password + "&cookie=" + cookie);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }
    public void updateRequest(String field, String value, String id, String URL, Callback c) throws Exception{
        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        String s = field + "=" + value + "&id=" + id;
        RequestBody body = RequestBody.create(mediaType, s);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }
}
