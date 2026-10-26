# Start the Chrome review demo

## Do this first

1. Extract this ZIP to a NEW folder. Keep your existing working Unity project as it is.
2. In VS Code open **SafeSim_Integrated/FlutterApp**, not `FlutterApp/lib`.
3. Open Terminal and run:

```powershell
.\RUN_CHROME.cmd
```

4. Wait for setup and compilation to finish. Then open **http://localhost:7357** in your normal
   Chrome window. Keep the terminal running. Do not use Incognito for persistent records.
5. Enter **WK001** or tap **Sharapu Akshit**. His Profile tab should open.

The first setup needs internet to resolve Flutter packages and generate the browser SQLite files.
The script checks for `web/sqlite3.wasm` and `web/sqflite_sw.js` before launching. It does not
clear your database. If setup fails, share the FIRST error in the terminal.

## What was fixed

- The app selects SQLite's browser implementation for Chrome, using IndexedDB persistence.
- Browser code no longer calls Android's database-directory method.
- The web runner now lives at `FlutterApp/web`, beside the real pubspec.yaml.
- The accidentally generated blank Flutter project inside `FlutterApp/lib` was moved into
  `Preserved_Nested_Project.zip`. Your real screens and Unity source were retained.
- Save PDF uses a browser download on Chrome and local filesystem storage on Android.
- Database failures now log their underlying error and show useful setup guidance.

## Review sequence

1. Show WK001's profile and QR badge.
2. Add a new worker with a unique ID; show their own profile and badge.
3. Refresh the page at the SAME URL and confirm the worker is still registered.
4. Show the dashboard, module instructions and quiz. Quiz results save to the browser database.
5. Switch to Unity Editor and play the working simulation with movement, instructor voice,
   arrows, extinguisher pickup, pin, spray, suppression, and exit.

Chrome and Unity Editor are separate demos. The existing native simulation bridge works only
with an exported Android build. No simulated completion is fabricated in Chrome; training-record
issuance still requires a real saved simulation pass and quiz pass. A quiz alone will not issue one.
The normal Chrome session does not receive the standalone Editor's result.

## Storage and offline limits

The browser database is local to the browser profile and origin, including PORT. Always use
`http://localhost:7357`; a different port, browser, or Incognito profile gets separate storage.
Clearing browser site data removes its records. Android's database is independent.

For this review, use the development server while the terminal remains open. This is NOT a
packaged offline website: Flutter's web renderer and the web QR/print libraries may fetch browser
resources. The Android offline configuration remains unchanged. The laptop's database itself
has no remote server. Manual Worker ID entry is available if webcam access is unavailable.

## Checks and troubleshooting

- 8 Python checks passed after the patch; Dart source parsed without syntax errors.
- Flutter/Chrome compilation and browser IndexedDB execution could not be run in this environment.
  This source patch must still be confirmed on your laptop. It is not a prebuilt web app.
- If setup files fail to load, stop the server with Ctrl+C, then run:

```powershell
dart run sqflite_common_ffi_web:setup --force
.\RUN_CHROME.cmd
```

- If port 7357 is occupied, stop the previous server. Keep the port stable for persistence.
- Do NOT run `flutter create` inside `lib`. The app root is the folder containing the pubspec
  whose name is `safesim`.
- If login still fails, press F12 → Console in Chrome and send the error beginning
  `SafeSim database login failed`, plus the terminal error. Do not erase the database first.

Implementation references:
https://pub.dev/packages/sqflite_common_ffi_web/versions/1.2.0
https://pub.dev/documentation/printing/latest/printing/Printing/sharePdf.html
