using System;

namespace SafeSim
{
    public enum Stage { Welcome, Alarm, Pickup, Pin, Approach, Suppress, Exit, Complete, Failed }

    // Pure gameplay state: both desktop and touch actions use these same transitions.
    public sealed class TrainingState
    {
        public Stage Current { get; private set; } = Stage.Welcome;
        public float Charge { get; private set; } = 30f;
        public float Elapsed { get; private set; }
        public float SpraySeconds { get; private set; }
        public float EffectiveSeconds { get; private set; }
        public readonly float[] Fire = { 1f, 1f, 1f };
        public event Action<Stage> Changed;
        public bool Active => Current != Stage.Welcome && Current != Stage.Complete && Current != Stage.Failed;
        public float RemainingFire => (Fire[0] + Fire[1] + Fire[2]) / 3f;
        public void Reset()
        {
            Charge = 30; Elapsed = SpraySeconds = EffectiveSeconds = 0;
            for (int i = 0; i < Fire.Length; i++) Fire[i] = 1;
            Set(Stage.Welcome);
        }
        public bool Advance(Stage expected)
        {
            if (Current != expected || expected == Stage.Suppress || expected >= Stage.Complete) return false;
            Set((Stage)((int)Current + 1)); return true;
        }
        public void Tick(float seconds) { if (Active && seconds > 0) Elapsed += seconds; }
        public void Spray(int target, float seconds)
        {
            if (Current != Stage.Suppress || seconds <= 0) return;
            float used = Math.Min(seconds, Charge);
            Charge = Math.Max(0, Charge - used); SpraySeconds += used;
            if (target >= 0 && target < Fire.Length && Fire[target] > 0)
            {
                float effective = Math.Min(used, Fire[target] * 2.2f);
                EffectiveSeconds += effective;
                Fire[target] = Math.Max(0, Fire[target] - used / 2.2f);
            }
            if (RemainingFire <= 0) Set(Stage.Exit);
            else if (Charge <= 0) Set(Stage.Failed);
        }
        void Set(Stage value) { Current = value; Changed?.Invoke(value); }
    }
}
