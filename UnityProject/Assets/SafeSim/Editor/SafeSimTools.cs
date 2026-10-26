using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace SafeSim.Editor
{
    public static class SafeSimTools
    {
        const string ScenePath="Assets/SafeSim/Scenes/Training.unity";
        [MenuItem("SafeSim/Open Training Scene")]
        public static void Open()
        {
            if(EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) EditorSceneManager.OpenScene(ScenePath);
        }
        [MenuItem("SafeSim/Repair Bootstrap Scene")]
        public static void Repair()
        {
            if(!EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo()) return;
            var scene=EditorSceneManager.NewScene(NewSceneSetup.EmptyScene,NewSceneMode.Single);
            var game=new GameObject("SafeSim - press Play to generate factory").AddComponent<SafeSimGame>();
            game.surfaceShader=Shader.Find("Standard"); game.particleShader=Shader.Find("SafeSim/SoftParticle");
            EditorSceneManager.SaveScene(scene,ScenePath);
            EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(ScenePath,true)};
        }
        [MenuItem("SafeSim/Configure Android")]
        public static void ConfigureAndroid()
        {
            PlayerSettings.companyName="SafeSim"; PlayerSettings.productName="SafeSim Training";
            PlayerSettings.SetApplicationIdentifier(BuildTargetGroup.Android,"com.safesim.training");
            PlayerSettings.defaultInterfaceOrientation=UIOrientation.LandscapeLeft;
            PlayerSettings.Android.minSdkVersion=AndroidSdkVersions.AndroidApiLevel26;
            PlayerSettings.Android.targetSdkVersion=AndroidSdkVersions.AndroidApiLevelAuto;
            PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android,ScriptingImplementation.IL2CPP);
            PlayerSettings.Android.targetArchitectures=AndroidArchitecture.ARM64;
#if UNITY_6000_0_OR_NEWER
            PlayerSettings.Android.applicationEntry = AndroidApplicationEntry.Activity;
#endif
            EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(ScenePath,true)};
            // This project intentionally uses the built-in renderer and legacy Input API.
            var settings=new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/ProjectSettings.asset")[0]);
            var input=settings.FindProperty("activeInputHandler");
            if(input!=null) { input.intValue=0; settings.ApplyModifiedPropertiesWithoutUndo(); }
            AssetDatabase.SaveAssets();
            Debug.Log("SafeSim configured for Android ARM64 / IL2CPP. Install Android Build Support, then use File > Build Settings > Android > Switch Platform > Build.");
        }
        [MenuItem("SafeSim/Export for Flutter")]
        public static void ExportForFlutter()
        {
            ConfigureAndroid();
            if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android) {
                EditorUtility.DisplayDialog("Switch to Android", "In File > Build Profiles switch to Android, then run SafeSim > Export for Flutter again.", "OK");
                return;
            }
            string folder = EditorUtility.SaveFolderPanel("Export Unity Android project", "", "UnityExport");
            if (string.IsNullOrEmpty(folder)) return;
            EditorUserBuildSettings.exportAsGoogleAndroidProject = true;
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
                scenes = new[]{ScenePath}, locationPathName = folder,
                target = BuildTarget.Android, options = BuildOptions.AcceptExternalModificationsToPlayer
            });
            if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
                throw new Exception("Unity export failed. Check the Console.");
            Debug.Log("Export complete. Run tools/install_unity.py with this export folder: " + folder);
        }
        [MenuItem("SafeSim/Run Logic Checks")]
        public static void CheckLogic()
        {
            int checks=0;
            Action<bool,string> check=(ok,message)=>{ if(!ok) throw new Exception("SafeSim check failed: "+message); checks++; };
            var s=new TrainingState();
            check(!s.Advance(Stage.Pin),"Cannot remove pin before pickup");
            s.Spray(0,10); check(s.Charge==30 && s.Fire[0]==1,"Spray gated until ready");
            for(int i=0;i<5;i++) check(s.Advance((Stage)i),"Expected stage "+i);
            check(s.Current==Stage.Suppress,"Arrived at suppression");
            s.Spray(-1,1); check(s.Charge==29 && s.RemainingFire==1,"Miss consumes charge but not fire");
            s.Spray(0,2.3f); check(s.Fire[0]==0 && s.Fire[1]==1 && s.Current==Stage.Suppress,"Must sweep distinct zones");
            s.Spray(1,2.3f); s.Spray(2,2.3f);
            check(s.Current==Stage.Exit,"All three zones required");
            check(s.Advance(Stage.Exit) && s.Current==Stage.Complete,"Exit completes exercise");
            s.Reset(); check(s.Charge==30 && s.RemainingFire==1 && s.Current==Stage.Welcome,"Restart restores exercise");
            for(int i=0;i<5;i++) s.Advance((Stage)i);
            s.Spray(-1,31); check(s.Current==Stage.Failed && s.Charge==0,"Empty tank fails safely");
            s.Spray(0,10); check(s.Fire[0]==1,"No spraying after failure");
            s.Reset(); s.Tick(3); check(s.Elapsed==0,"Welcome does not count time");
            s.Advance(Stage.Welcome); s.Tick(3); check(s.Elapsed==3,"Active timer advances");
            string[] clips={"welcome","alarm","pickup","pin","approach","suppress","exit","complete","failed"};
            foreach(var name in clips) check(Resources.Load<AudioClip>("Voice/"+name)!=null,"Voice clip "+name);
            check(Shader.Find("SafeSim/SoftParticle")!=null,"Particle shader available");
            check(AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath)!=null,"Training scene available");
            Debug.Log("SafeSim: "+checks+" checks passed. Play-test gameplay and Android separately; these checks do not replace runtime testing.");
        }
    }
}
