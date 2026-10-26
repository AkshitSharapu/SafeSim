> **For your laptop review, start with CHROME_REVIEW_START_HERE.md.** The Android instructions below are for the later phone build.

# SafeSim Flutter + Unity Android prototype

This is an updated copy of your Flutter app plus the Unity fire-training source project.
It is source code, not a prebuilt APK. Unity export and on-device testing are still required.

## Offline worker update (v1.2)

All runtime features are designed for offline use after the app is built and installed. Scan your
worker badge to open your own Profile tab. Add more workers from the login screen; each receives
an individual QR and separate local progress. Your printable badge is
`Worker_QR_Badges/WK001_Worker_QR.png`. See `docs/OFFLINE_AND_WORKERS.md` for the full feature list,
local-device limits, and first-launch airplane-mode test. Keep all existing app data when upgrading.

## What is included

- Your worker login, dashboard, modules, quizzes, progress, and PDF training records.
- A procedural 3D factory with mobile movement/look controls, arrows, offline instructor voice,
  alarm interaction, extinguisher pickup, pin removal, CO2 spray, three fire zones, and exit.
- A native Android connection that opens Unity full-screen and returns the actual result.
- Session identity checks, local result persistence, duplicate-result protection, and cancellation.
- Training records require both a saved simulation pass and a passing quiz.

The factory uses simple generated geometry. It is a prototype, not a polished asset pack.
Only Android ARM64 is integrated. iOS and web Unity hosting are not implemented.

## 1. Install the development tools

On your Windows computer install:

- Unity Hub and **Unity 6000.0.76f1 LTS**, with Android Build Support, SDK/NDK Tools, and OpenJDK.
- Flutter **3.29 or newer** on PATH, Android Studio with Android SDK platform 36, and Java 17.
- Python 3 on PATH (the commands below use `python`; Windows can also use `py`).

Run `flutter doctor` and resolve Android toolchain issues. Use a physical ARM64 Android phone
running Android 8 or newer with USB debugging enabled. Initial dependency downloads need internet.

## 2. Prepare Flutter

Open a terminal in this extracted `SafeSim_Integrated` folder:

```console
python tools/setup_flutter.py
```

This obtains official Flutter Gradle wrapper files without replacing the app code, and downloads
Flutter dependencies. Android Gradle Plugin 8.10.0 and Gradle 8.13 match the target Unity editor.

## 3. Check and export Unity

1. Unity Hub → Add project from disk → select **UnityProject**.
2. Open with **6000.0.76f1**. Let Unity import everything.
3. Select **SafeSim → Open Training Scene**, then press Play. The factory appears at runtime.
4. Run **SafeSim → Run Logic Checks** and inspect Console errors before continuing.
5. Stop Play, select **SafeSim → Configure Android**.
6. In **File → Build Profiles**, select Android and switch platform.
7. Select **SafeSim → Export for Flutter**. Choose a separate folder, for example `C:\SafeSimUnityExport`.

Keep the export outside `FlutterApp/android`. Export the supplied project so it includes the Java
bridge. A standalone APK from Unity is not the library export Flutter needs.

## 4. Connect the export and run

From this bundle's root folder:

```console
python tools/install_unity.py "C:\SafeSimUnityExport"
cd FlutterApp
flutter analyze
flutter test
flutter run
```

The installer copies `unityLibrary` and Unity's shared Gradle scripts, removes the extra launcher
entry, and connects the library to Flutter. Previous imported libraries are renamed as backups.
After changes to Unity, export again and rerun the installer. For Flutter changes, rebuild Flutter.

You can run Flutter without installing the Unity export to inspect the app menus; launching training
then shows an unavailable message. It deliberately does not manufacture a successful result.

## 5. Test on your phone

Use a demo worker from `FlutterApp/assets/data/workers.json`. Start the fire module. Complete the
alarm → pickup → pin → approach → aim/spray/sweep → exit sequence. Tap RETURN TO APP.
Check the result, complete the quiz, then issue a training record. Also test cancellation, an empty
extinguisher, a second attempt, reopening the app, and switching workers. Full checklist: `docs/TESTING.md`.

For an installable development APK, after the checks pass:

```console
flutter build apk --release --target-platform android-arm64
```

Output: `FlutterApp/build/app/outputs/flutter-apk/app-release.apk`. This configuration uses the
development signing key. Configure your own release signing before distributing a production app.

## Prototype limits and honest verification

Unity and Flutter SDKs were unavailable in the preparation environment. Source syntax, data files,
and installer behavior were checked; Unity compilation, Flutter analysis/tests, Android builds,
graphics/audio performance, and lifecycle behavior still need verification on your machine.
See `docs/VALIDATION.md` for the checks actually executed.

Worker login is local demo identification, not secure authentication. SQLite data is not encrypted.
There is no remote server sync. Local review and QR lookup do not provide independent accreditation.
PDFs are practice records, not legal or professional fire-safety certification. Legacy progress from
an older installed database is retained, but new record issuance requires new validated attempts.
The simulated CO2 cloud is a visual particle effect; training content needs review before workplace use.

If you encounter a build error, share the first full error from the Unity Console or Flutter terminal.
