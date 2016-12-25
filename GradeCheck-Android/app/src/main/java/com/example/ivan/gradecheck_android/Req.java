package com.example.ivan.gradecheck_android;

/**
 * Created by ivan on 12/8/16.
 */
import org.json.JSONException;
import org.json.JSONObject;

import okhttp3.*;
import java.io.IOException;

public class Req {
    private final OkHttpClient client = new OkHttpClient();

    public void loginRequest(String username, String password, String URL, Callback c) throws Exception{

        MediaType mediaType = MediaType.parse("application/x-www-form-urlencoded");
        RequestBody body = RequestBody.create(mediaType, "username=" + username + "&password=" + password + "&id=" + username);
        Request request = new Request.Builder()
                .url(URL)
                .post(body)
                .addHeader("cache-control", "no-cache")
                .addHeader("content-type", "application/x-www-form-urlencoded")
                .build();
        client.newCall(request).enqueue(c);
    }
    public void assignmentRequest(String cookie, String id, String URL, Callback c) throws Exception{
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
}
