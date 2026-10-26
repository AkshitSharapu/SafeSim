package com.safesim.app

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var pending: MethodChannel.Result? = null
    private var request: String? = null
    private val requestCode = 7301
    private val activityName = "com.safesim.unitybridge.SafeSimUnityActivity"
    private val storage by lazy { getSharedPreferences("safesim_bridge", MODE_PRIVATE) }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)
        MethodChannel(engine.dartExecutor.binaryMessenger, "com.safesim.unity_bridge")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startSimulation" -> {
                        if (pending != null) { result.error("BUSY", "A simulation is already open.", null); return@setMethodCallHandler }
                        val args = call.arguments as? Map<*, *>
                        val session = args?.get("sessionId") as? String
                        val worker = args?.get("workerId") as? String
                        val module = args?.get("moduleId") as? String
                        if (session.isNullOrBlank() || worker.isNullOrBlank() || module != "MOD-FIRE-01") {
                            result.error("INVALID_REQUEST", "Invalid training session.", null); return@setMethodCallHandler
                        }
                        try {
                            val unityClass = Class.forName(activityName)
                            val json = JSONObject().put("schemaVersion", 1).put("sessionId", session)
                                .put("workerId", worker).put("moduleId", module).toString()
                            request = json
                            storage.edit().putString("request", json).apply()
                            pending = result
                            val intent = Intent(this, unityClass).putExtra("requestJson", json)
                            startActivityForResult(intent, requestCode)
                        } catch (_: ClassNotFoundException) {
                            pending = null; request = null
                            storage.edit().remove("request").apply()
                            result.error("UNITY_NOT_INSTALLED", "The 3D module is not included in this build. Install the Unity export and rebuild the app.", null)
                        } catch (e: Exception) {
                            pending = null; request = null
                            storage.edit().remove("request").apply()
                            result.error("LAUNCH_FAILED", "Could not launch the Unity activity: ${e.message}", null)
                        }
                    }
                    "getRecoveredResults" -> result.success(storage.all.filterKeys { it.startsWith("result.") }.values.filterIsInstance<String>())
                    "acknowledgeRecoveredResult" -> {
                        val id = call.argument<String>("sessionId")
                        if (!id.isNullOrBlank()) storage.edit().remove("result.$id").apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Android activity result callback retained for FlutterActivity compatibility")
    override fun onActivityResult(code: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(code, resultCode, data)
        if (code != requestCode) return
        val callback = pending; pending = null
        val original = request ?: storage.getString("request", null)
        request = null; storage.edit().remove("request").apply()
        if (resultCode != Activity.RESULT_OK || data?.getStringExtra("resultJson") == null) {
            callback?.error("CANCELLED", "Training was closed without a result.", null)
            return
        }
        try {
            val raw = data.getStringExtra("resultJson")!!
            val payload = JSONObject(raw)
            val launch = JSONObject(original ?: throw IllegalStateException("Missing request"))
            for (key in listOf("sessionId", "workerId", "moduleId")) {
                require(payload.getString(key) == launch.getString(key)) { "Session mismatch" }
            }
            // Persist before returning to Dart. Flutter acknowledges only after SQLite commit.
            if (payload.optString("status") == "completed")
                storage.edit().putString("result.${payload.getString("sessionId")}", raw).commit()
            callback?.success(raw)
        } catch (e: Exception) {
            callback?.error("INVALID_RESULT", "Unity returned an invalid session result.", null)
        }
    }
}
