using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;

namespace SafeSim
{
    public sealed class SafeSimGame : MonoBehaviour
    {
        [Tooltip("Assigned in the included scene so shaders are retained in Android builds.")]
        public Shader surfaceShader;
        public Shader particleShader;
        public float walkSpeed=3.2f;
        public float mouseSensitivity=2f;
        public float touchSensitivity=.12f;
        readonly TrainingState state=new TrainingState();
        FactoryWorld world;
        TrainingHUD hud;
        CharacterController player;
        Camera view;
        AudioSource voice, hiss, fireAudio;
        float pitch,verticalSpeed,elapsedPin;
        bool paused,pinAnimating;
        int hitTarget=-1, offTargetBursts;
        bool previouslyOffTarget;
        Transform pin;
        Vector3 initialPin;
        AudioClip hissClip,fireClip;
        readonly string[] instructions={
            "Welcome to SafeSim.",
            "Raise the alarm. Follow the arrows to the red alarm station.",
            "Collect the CO2 extinguisher from its stand.",
            "Pull the safety pin before using the extinguisher.",
            "Follow the arrows to the marked operating position.",
            "Aim at the base. Hold spray and sweep across all three fire zones.",
            "Fire suppressed. Follow the arrows back to the exit.",
            "Training complete. Review your results.",
            "The extinguisher is empty. Restart the exercise and try again."
        };
        readonly string[] voices={"welcome","alarm","pickup","pin","approach","suppress","exit","complete","failed"};
        void Start()
        {
            if(!surfaceShader) surfaceShader=Shader.Find("Standard");
            if(!particleShader) particleShader=Shader.Find("SafeSim/SoftParticle");
            if(!surfaceShader || !particleShader) { Debug.LogError("SafeSim shaders missing. Open the included Training scene."); enabled=false; return; }
            UnityFlutterBridge.Initialize();
            Application.targetFrameRate=60; QualitySettings.vSyncCount=0;
            QualitySettings.pixelLightCount=3; QualitySettings.shadowDistance=22;
            Screen.sleepTimeout=SleepTimeout.NeverSleep;
            Screen.orientation=ScreenOrientation.LandscapeLeft;
            Input.multiTouchEnabled=true;
            world=new FactoryWorld(surfaceShader,particleShader);
            var p=new GameObject("Player"); p.layer=2; p.transform.SetParent(transform);
            player=p.AddComponent<CharacterController>(); player.height=1.8f; player.radius=.3f;
            player.center=new Vector3(0,.9f,0); player.stepOffset=.25f;
            var cameraObject=new GameObject("Player camera"); cameraObject.tag="MainCamera";
            cameraObject.transform.SetParent(p.transform,false); cameraObject.transform.localPosition=new Vector3(0,1.65f,0);
            view=cameraObject.AddComponent<Camera>(); view.nearClipPlane=.06f; view.farClipPlane=70; view.fieldOfView=68;
            view.clearFlags=CameraClearFlags.SolidColor; view.backgroundColor=new Color(.1f,.15f,.2f);
            cameraObject.AddComponent<AudioListener>();
            voice=gameObject.AddComponent<AudioSource>(); voice.playOnAwake=false;
            hiss=gameObject.AddComponent<AudioSource>(); hiss.playOnAwake=false; hiss.loop=true; hiss.volume=.24f;
            fireAudio=gameObject.AddComponent<AudioSource>(); fireAudio.playOnAwake=false; fireAudio.loop=true; fireAudio.volume=.12f;
            hissClip=Noise("CO2 hiss",2,false); hiss.clip=hissClip;
            fireClip=Noise("Fire crackle",3,true); fireAudio.clip=fireClip;
            hud=new TrainingHUD(Interact,TogglePause,RepeatVoice,ToggleTouch, UnityFlutterBridge.IsHosted ? (System.Action)UnityFlutterBridge.Cancel : null);
            state.Changed+=OnStage; ResetExercise();
        }
        AudioClip Noise(string name,int seconds,bool crackle)
        {
            const int rate=22050; var data=new float[rate*seconds]; var rng=new System.Random(crackle?42:8);
            float smooth=0;
            for(int i=0;i<data.Length;i++)
            {
                float noise=(float)rng.NextDouble()*2-1; smooth=smooth*.85f+noise*.15f;
                data[i]=crackle?smooth*.6f+((i%1709<13)?noise*.35f:0):noise*.25f+smooth*.2f;
                // Fade ends to prevent clicks at loop boundaries.
                data[i]*=Mathf.Min(1,Mathf.Min(i,data.Length-1-i)/220f);
            }
            var clip=AudioClip.Create(name,data.Length,1,rate,false); clip.SetData(data,0); return clip;
        }
        void ResetExercise()
        {
            offTargetBursts=0; previouslyOffTarget=false;
            paused=false; Time.timeScale=1; pinAnimating=false;
            player.enabled=false; player.transform.SetPositionAndRotation(new Vector3(0,.05f,-6),Quaternion.identity);
            player.enabled=true; pitch=0; verticalSpeed=0; view.transform.localRotation=Quaternion.identity;
            world.Extinguisher.SetParent(world.Root,false); world.Extinguisher.position=world.EquipmentPosition;
            world.Extinguisher.rotation=Quaternion.identity; world.Extinguisher.localScale=Vector3.one;
            world.Nozzle.localRotation=Quaternion.identity;
            SetLayer(world.Extinguisher,0); pin=world.Pin; initialPin=new Vector3(-.1f,.74f,0);
            pin.gameObject.SetActive(true); pin.localPosition=initialPin; world.Door.position=world.DoorClosed;
            world.Spray.Stop(true,ParticleSystemStopBehavior.StopEmittingAndClear); hiss.Stop();
            foreach(var f in world.Flames) { f.Clear(); f.Play(); }
            fireAudio.Stop(); state.Reset(); world.SetFire(state.Fire); hud.ClearInput();
        }
        void OnStage(Stage stage)
        {
            hud.Instruction.text=instructions[(int)stage]; RepeatVoice();
            if(stage==Stage.Welcome)
            {
                SetCursor(false);
                hud.ShowModal("SAFESIM", "INDUSTRIAL FIRE RESPONSE\n\nRaise the alarm, collect equipment and complete the guided exercise.\n\nDesktop: WASD move | Right mouse drag: look\nE interact | P pull pin | Hold left mouse: spray\n\nA simplified virtual training demonstration.","START TRAINING",()=>{ hud.HideModal(); state.Advance(Stage.Welcome); fireAudio.Play(); });
            }
            if(stage==Stage.Pin)
            {
                world.Extinguisher.SetParent(view.transform,false); world.Extinguisher.localPosition=new Vector3(.34f,-.72f,.57f);
                world.Extinguisher.localRotation=Quaternion.Euler(0,-10,-7); world.Extinguisher.localScale=Vector3.one*.8f;
                SetLayer(world.Extinguisher,2);
            }
            if(stage==Stage.Exit) { StopSpray(); fireAudio.Stop(); }
            if(stage==Stage.Complete || stage==Stage.Failed)
            {
                StopSpray(); SetCursor(false);
                float accuracy=state.SpraySeconds>0?state.EffectiveSeconds/state.SpraySeconds*100:0;
                string results=$"Time: {state.Elapsed:0} seconds\nEffective spray: {accuracy:0}%\nCO2 remaining: {state.Charge/30*100:0}%\n\n";
                results+=stage==Stage.Complete?"All objectives completed.\nYou may repeat the exercise to improve your aim.":"Use short, controlled bursts at the base of each fire zone. The tank has a limited charge.";
                hud.ShowModal(stage==Stage.Complete?"EXERCISE COMPLETE":"CYLINDER EMPTY",results,
                    UnityFlutterBridge.IsHosted ? "RETURN TO APP" : "RESTART",
                    UnityFlutterBridge.IsHosted ? (System.Action)(() => UnityFlutterBridge.Complete(state,offTargetBursts)) : ResetExercise);
            }
        }
        void SetLayer(Transform root,int layer) { root.gameObject.layer=layer; foreach(Transform c in root) SetLayer(c,layer); }
        public void RepeatVoice()
        {
            if(paused) return;
            voice.Stop(); voice.clip=Resources.Load<AudioClip>("Voice/"+voices[(int)state.Current]);
            if(voice.clip) voice.Play();
        }
        void Update()
        {
            if(hud==null) return;
            hud.UpdateSafeArea();
            if(Input.GetKeyDown(KeyCode.Escape) && state.Active) TogglePause();
            if(paused) return;
            UpdateHUD();
            if(!state.Active) { world.Guide(Vector3.zero,Vector3.zero,false); return; }
            float dt=Time.deltaTime; state.Tick(dt); MovePlayer(dt);
            if(Input.GetKeyDown(KeyCode.E) || Input.GetKeyDown(KeyCode.P)) Interact();
            if(pinAnimating)
            {
                elapsedPin+=dt;
                pin.localPosition=initialPin+Vector3.left*Mathf.Min(elapsedPin/.65f,1)*.22f;
                if(elapsedPin>=.65f) { pinAnimating=false; pin.gameObject.SetActive(false); state.Advance(Stage.Pin); }
            }
            Vector3 target=ObjectivePoint();
            bool guide=state.Current==Stage.Alarm || state.Current==Stage.Pickup || state.Current==Stage.Approach || state.Current==Stage.Exit;
            world.Guide(player.transform.position,target,guide);
            if(state.Current==Stage.Approach && FlatDistance(player.transform.position,world.FiringPosition)<.85f) state.Advance(Stage.Approach);
            if(state.Current==Stage.Exit)
            {
                world.Door.position=Vector3.MoveTowards(world.Door.position,world.DoorClosed+Vector3.right*3,dt*1.7f);
                if(FlatDistance(player.transform.position,world.ExitPosition)<.85f) state.Advance(Stage.Exit);
            }
            hitTarget=FindTarget();
            bool mouseSpray=!hud.TouchMode && Input.GetMouseButton(0) && !(EventSystem.current && EventSystem.current.IsPointerOverGameObject());
            bool wantsSpray=(mouseSpray || (hud.TouchMode && hud.Spray.Held)) && state.Current==Stage.Suppress;
            bool offTarget=wantsSpray && hitTarget<0;
            if(offTarget && !previouslyOffTarget) offTargetBursts++;
            previouslyOffTarget=offTarget;
            if(wantsSpray)
            {
                AimHorn();
                if(!world.Spray.isPlaying) world.Spray.Play(); if(!hiss.isPlaying) hiss.Play();
                state.Spray(hitTarget,dt); world.SetFire(state.Fire); fireAudio.volume=.12f*state.RemainingFire;
            }
            else StopSpray();
            hud.Crosshair.color=hitTarget>=0?new Color(.15f,1,.65f):Color.white;
        }
        void MovePlayer(float dt)
        {
            Vector2 move=Vector2.zero,look=Vector2.zero;
            if(hud.TouchMode)
            {
                move=hud.Move.Value;
                look=hud.Look.ConsumeDelta()*touchSensitivity*(720f/Mathf.Max(1,Screen.height));
            }
            else
            {
                move.x=(Input.GetKey(KeyCode.D)?1:0)-(Input.GetKey(KeyCode.A)?1:0);
                move.y=(Input.GetKey(KeyCode.W)?1:0)-(Input.GetKey(KeyCode.S)?1:0);
                // Right-drag avoids locking the cursor and leaves HUD buttons accessible.
                if(Input.GetMouseButton(1)) look=new Vector2(Input.GetAxisRaw("Mouse X"),Input.GetAxisRaw("Mouse Y"))*mouseSensitivity;
            }
            player.transform.Rotate(0,look.x,0); pitch=Mathf.Clamp(pitch-look.y,-75,75);
            view.transform.localRotation=Quaternion.Euler(pitch,0,0);
            Vector3 direction=player.transform.right*move.x+player.transform.forward*move.y;
            direction=Vector3.ClampMagnitude(direction,1)*walkSpeed;
            if(player.isGrounded && verticalSpeed<0) verticalSpeed=-2;
            verticalSpeed+=Physics.gravity.y*dt; direction.y=verticalSpeed;
            player.Move(direction*dt);
        }
        Vector3 ObjectivePoint()
        {
            if(state.Current==Stage.Alarm) return world.AlarmPosition;
            if(state.Current==Stage.Pickup) return world.EquipmentPosition;
            if(state.Current==Stage.Exit) return world.ExitPosition;
            return world.FiringPosition;
        }
        bool CanInteract()
        {
            if(state.Current==Stage.Pin) return !pinAnimating;
            if(state.Current!=Stage.Alarm && state.Current!=Stage.Pickup) return false;
            Vector3 target=ObjectivePoint();
            return FlatDistance(player.transform.position,target)<1.75f && Vector3.Dot(view.transform.forward,(target-view.transform.position).normalized)>.45f;
        }
        public void Interact()
        {
            if(paused || !CanInteract()) return;
            if(state.Current==Stage.Pin) { pinAnimating=true; elapsedPin=0; return; }
            state.Advance(state.Current);
        }
        int FindTarget()
        {
            if(state.Current!=Stage.Suppress) return -1;
            Ray ray=view.ViewportPointToRay(new Vector3(.5f,.5f,0));
            if(!Physics.Raycast(ray,out RaycastHit hit,6f,~(1<<2),QueryTriggerInteraction.Collide)) return -1;
            if(hit.distance<1.8f) return -1;
            for(int i=0;i<world.Targets.Length;i++) if(hit.collider==world.Targets[i] && state.Fire[i]>0) return i;
            return -1;
        }
        void AimHorn()
        {
            Ray ray=view.ViewportPointToRay(new Vector3(.5f,.5f,0)); Vector3 point=ray.origin+ray.direction*6;
            if(Physics.Raycast(ray,out RaycastHit hit,6,~(1<<2),QueryTriggerInteraction.Collide)) point=hit.point;
            world.Nozzle.rotation=Quaternion.LookRotation(point-world.Nozzle.position);
        }
        void StopSpray()
        {
            if(world.Spray.isPlaying) world.Spray.Stop(true,ParticleSystemStopBehavior.StopEmitting);
            if(hiss.isPlaying) hiss.Stop();
        }
        void UpdateHUD()
        {
            int current=(int)state.Current;
            string[] names={"Raise the alarm","Collect extinguisher","Pull safety pin","Reach operating mark","Suppress all fire zones","Return to exit"};
            string list="";
            for(int i=0;i<names.Length;i++) list+=(current>i+1 && state.Current!=Stage.Failed?"[x] ":current==i+1?">  ":"[ ] ")+names[i]+"\n";
            hud.Objectives.text=list; hud.Charge.text=$"CO2  {state.Charge/30*100:0}%";
            hud.Progress.text=$"FIRE  {state.RemainingFire*100:0}%";
            hud.Clock.text=$"{(int)state.Elapsed/60:00}:{(int)state.Elapsed%60:00}";
            hud.SetBars(state.RemainingFire,state.Charge/30);
            bool action=state.Current==Stage.Alarm || state.Current==Stage.Pickup || state.Current==Stage.Pin;
            hud.ActionButton.gameObject.SetActive(action); hud.ActionButton.interactable=CanInteract();
            hud.ActionLabel.text=state.Current==Stage.Pin?"PULL PIN [P]":state.Current==Stage.Pickup?"PICK UP [E]":"RAISE ALARM [E]";
            hud.Hint.text=state.Current==Stage.Suppress?(hitTarget>=0?"On target — sweep across the base":"Aim lower at a live fire zone • range 1.8–6 m"):
                state.Current==Stage.Pin?(pinAnimating?"Removing safety pin…":"Press P or tap PULL PIN"):
                action?(CanInteract()?"Press E or tap the interaction button":"Follow the arrows, approach and face the equipment"):
                state.Current==Stage.Approach?"Move onto the turquoise operating mark":
                state.Current==Stage.Exit?"Return to the exit to complete the exercise":"";
        }
        public void TogglePause()
        {
            if(!state.Active) return;
            paused=!paused; Time.timeScale=paused?0:1; hud.ClearInput();
            if(paused)
            {
                voice.Pause(); hiss.Pause(); fireAudio.Pause();
                hud.ShowModal("PAUSED","Your progress is saved for this session.\n\nDesktop: WASD / right-drag to look\nE interact / P pull pin / left mouse spray\n\nTouch: left joystick / right-side drag\nUse the action and spray buttons.","RESUME",TogglePause);
            }
            else { hud.HideModal(); voice.UnPause(); fireAudio.UnPause(); hiss.Stop(); }
        }
        void ToggleTouch() { hud.SetTouch(!hud.TouchMode); StopSpray(); }
        void SetCursor(bool locked) { Cursor.lockState=locked?CursorLockMode.Locked:CursorLockMode.None; Cursor.visible=!locked; }
        static float FlatDistance(Vector3 a,Vector3 b) { a.y=b.y=0; return Vector3.Distance(a,b); }
        void OnApplicationFocus(bool focus) { if(!focus && hud!=null && state.Active && !paused) TogglePause(); }
        void OnApplicationPause(bool value) { if(value && hud!=null && state.Active && !paused) TogglePause(); }
        void OnDestroy()
        {
            Time.timeScale=1; Cursor.lockState=CursorLockMode.None; Cursor.visible=true;
            state.Changed-=OnStage;
            if(hud!=null && hud.Root) Destroy(hud.Root);
            world?.Dispose(); if(hissClip) Destroy(hissClip); if(fireClip) Destroy(fireClip);
        }
    }
}
