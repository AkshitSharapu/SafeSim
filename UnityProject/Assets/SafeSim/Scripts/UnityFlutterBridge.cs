using System;
using UnityEngine;

namespace SafeSim
{
    public static class UnityFlutterBridge
    {
        [Serializable] public sealed class Session
        {
            public int schemaVersion;
            public string sessionId, workerId, moduleId;
        }
        [Serializable] sealed class Result
        {
            public int schemaVersion = 1;
            public string status, sessionId, workerId, moduleId;
            public bool passed;
            public int score, mistakes, duration;
        }
        static Session session;
        static bool sent;
        public static bool IsHosted => session != null;
        public static void Initialize()
        {
            session = null; sent = false;
#if UNITY_ANDROID && !UNITY_EDITOR
            try
            {
                using (var player = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
                using (var activity = player.GetStatic<AndroidJavaObject>("currentActivity"))
                {
                    string json = activity.Call<string>("getRequestJson");
                    if (string.IsNullOrEmpty(json)) return;
                    var request = JsonUtility.FromJson<Session>(json);
                    if (request.schemaVersion != 1 || string.IsNullOrEmpty(request.sessionId) ||
                        string.IsNullOrEmpty(request.workerId) || request.moduleId != "MOD-FIRE-01")
                        throw new InvalidOperationException("Invalid Flutter session");
                    session = request;
                }
            }
            catch (Exception e) { Debug.LogWarning("Standalone mode: " + e.Message); }
#endif
        }
        public static void Complete(TrainingState state, int mistakes)
        {
            if (!IsHosted || sent) return;
            bool passed = state.Current == Stage.Complete;
            float accuracy = state.SpraySeconds > 0 ? Mathf.Clamp01(state.EffectiveSeconds / state.SpraySeconds) : 0;
            int score = passed ? Mathf.RoundToInt(70 + accuracy * 30) : Mathf.RoundToInt((1 - state.RemainingFire) * 60);
            Send(new Result { status = "completed", passed = passed, score = score,
                mistakes = mistakes, duration = Mathf.Clamp(Mathf.RoundToInt(state.Elapsed),0,86400) });
        }
        public static void Cancel() { if (IsHosted) Send(new Result { status = "cancelled" }); }
        static void Send(Result result)
        {
            if (sent) return;
            result.sessionId = session.sessionId; result.workerId = session.workerId; result.moduleId = session.moduleId;
#if UNITY_ANDROID && !UNITY_EDITOR
            using (var player = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            using (var activity = player.GetStatic<AndroidJavaObject>("currentActivity"))
                activity.Call("finishWithResult", JsonUtility.ToJson(result));
#endif
            sent = true;
        }
    }
}
