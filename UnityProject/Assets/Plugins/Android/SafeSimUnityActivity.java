package com.safesim.unitybridge;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import com.unity3d.player.UnityPlayerActivity;
import org.json.JSONObject;

/** Runs in :unity, keeping Unity's quit/process lifecycle separate from Flutter. */
public class SafeSimUnityActivity extends UnityPlayerActivity {
    private boolean returning = false;
    public String getRequestJson() {
        String request = getIntent().getStringExtra("requestJson");
        return request == null ? "" : request;
    }
    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        setResult(Activity.RESULT_CANCELED);
    }
    public void finishWithResult(final String json) {
        runOnUiThread(() -> {
            if (returning) return;
            try {
                JSONObject result = new JSONObject(json);
                JSONObject request = new JSONObject(getRequestJson());
                for (String key : new String[]{"sessionId", "workerId", "moduleId"}) {
                    if (!request.getString(key).equals(result.getString(key)))
                        throw new IllegalArgumentException("Session mismatch");
                }
                returning = true;
                Intent data = new Intent();
                data.putExtra("resultJson", json);
                setResult(Activity.RESULT_OK, data);
                finish();
            } catch (Exception error) {
                returning = true;
                setResult(Activity.RESULT_CANCELED);
                finish();
            }
        });
    }
    @Override public void onBackPressed() {
        if (returning) return;
        returning = true;
        setResult(Activity.RESULT_CANCELED);
        finish();
    }
}
