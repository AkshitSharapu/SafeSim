# Offline operation and worker profiles

## Worker QR flow

- Open SafeSim → scan a worker QR → the matching Profile tab opens.
- Your badge is `Worker_QR_Badges/WK001_Worker_QR.png`: Sharapu Akshit, ID WK001.
- Printable PNG badges for WK002 and WK003 are also included.
- Use **Add worker** on the login screen to register more people without internet.
- Every worker needs a unique Worker ID. Names can be the same without sharing a profile.
- Each profile keeps its own name, role, department, training attempts, scores, quiz results,
  certificates, and local reviewer information.
- Tap a worker's QR icon, or Profile → View My Digital QR Badge, to view/export their badge.
- The original WK001-style badges still work. New badges contain `SAFESIM:WK001`.
- If a scan is unknown, use **Scan another QR / Try again** or manual Worker ID entry.
- Use Switch Worker / Logout before scanning another worker.

QR codes identify local records. They are not passwords and do not contain personal details,
progress, or scores. Scan inside SafeSim, not a generic camera app. The three included workers
are registered by the app on first launch. A newly added worker must also be registered on any
other device where their badge will be used. Scores and certificates do not move between phones.
There is no cloud account or automatic sync. Clearing app data/uninstalling removes local records.

## Retained features and offline behavior

| Feature | Offline implementation |
| --- | --- |
| Worker registration, scan and manual entry | Local SQLite registry; bundled QR detector |
| Worker profile and dashboard | Local profile, progress and statistics |
| Fire module and instructions | Bundled text and module data |
| Unity factory simulation | Native library packaged inside the APK after export |
| Touch movement, pickup, pin, spray, arrows | Local Unity gameplay scripts |
| Instructor voice | Nine packaged WAV clips, no online speech service |
| Quiz and feedback | Bundled questions and local scoring |
| Results and progress | Per-worker SQLite records with session deduplication |
| Training certificates | Locally generated PDF; local save and system share/print actions |
| Certificate QR verification | Lookup in this device's registry |
| Reviewer name and notes | Local review record |
| Worker badge display and PDF export | QR and PDF generated on device |

The release manifest removes INTERNET and ACCESS_NETWORK_STATE permissions, including permissions
requested by imported libraries. Debug builds retain internet for Flutter's development tools.
The scanner is pinned to mobile_scanner 6.0.11 with its detector bundled inside the APK.
Fonts use local system/PDF fonts. No runtime HTTP clients, remote images, web pages or font downloads
were found in app source. Unity does not use Addressables, streaming downloads, or remote speech.

External share apps and physical printers have their own requirements. SafeSim generates and saves
PDFs without internet; emailing a PDF or using a remote printer is outside its offline functionality.
Certificate lookup on a second phone needs that record on the second phone; a QR is not a cloud lookup.

## First-install airplane-mode acceptance test

1. Build the release APK with the Unity export included (see START_HERE.md). Installing build tools
   and downloading developer dependencies requires internet on your computer, not during app use.
2. On a test phone, install the APK, then disable mobile data and Wi-Fi BEFORE its first launch.
   Use a clean test install; do not erase real worker records just to test.
3. Open SafeSim, grant camera access, and scan WK001 from another screen or a printed badge.
   Confirm Sharapu Akshit's Profile tab opens. This must work on the very first launch.
4. Register WK004 and display its QR. Switch workers, scan WK004, and confirm its empty profile.
5. Complete the Unity training, return a result, complete the quiz, save/export a PDF, and verify
   that certificate QR. Repeat after force-closing and restarting the app while still offline.
6. Switch to WK001: WK004's results must not appear. Try an unknown ID and a certificate QR on the
   worker login screen: neither should open an unrelated profile.
7. Test camera permission denial/manual entry, scan retry, locking/unlocking the phone, and tab
   switching. The camera must close when leaving the scanner page.
8. From Android SDK tools, `apkanalyzer manifest permissions app-release.apk` must NOT list
   android.permission.INTERNET. Check the release APK, not a debug APK.

Source and automated checks are recorded in VALIDATION.md. No physical-device or Flutter/Unity
compiler checks have been run here. Complete this checklist before claiming all features work offline.
