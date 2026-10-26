# Validation performed

- Parsed all 44 Dart files, 7 C# files, 1 Kotlin file and 1 Java file with Tree-sitter: no syntax errors.
- Parsed packaged JSON and Android XML successfully.
- Confirmed all 9 offline voice WAV files contain audio frames.
- Ran 4 Python unittest cases successfully: installer copies Unity dependencies and removes duplicate launcher; existing export backup; invalid export rejection; certificate gate requires both quiz and simulation for the same worker; duplicate session delivery does not increase row count.
  (Multiple assertions and scenarios are grouped into those 4 cases.)
- Included 7 Flutter tests covering result parsing and native bridge success/failure/session mismatch. These have NOT been executed because Flutter is unavailable here.

These are source and contract checks, not compiler or device validation. Unity Editor, Flutter analyzer, Gradle/Android compilation, and physical-device tests have NOT been run. Follow TESTING.md before treating the app as usable or distributing it.

Compatibility references consulted:
- https://docs.unity3d.com/6000.0/Documentation/Manual/android-gradle-version-compatibility.html
- https://github.com/Unity-Technologies/uaal-example/blob/master/docs/android.md
- https://docs.flutter.dev/platform-integration/platform-channels
- https://docs.unity.com/ja-jp/engine/6000.0/manual/packages-list/packages-all/pack-core/com-unity-ugui

## v1.2 offline-worker update

- Parsed 47 dart files, 7 cs files, 1 kt files, 1 java files: no syntax errors.
- All packaged JSON/XML parsed and all 9 voice WAVs contain audio.
- Ran 8 Python tests successfully covering installer, SQL eligibility/deduplication, offline release configuration, worker identity lookup and profile route wiring.
- Generated all three worker PNG QR badges and independently decoded each with ZXing at full and half size; all match their expected Worker IDs.
- Added 4 Dart tests for QR identity parsing/validation (11 Flutter tests total); not executed here.
- Flutter analysis, APK compilation, Unity export and physical-device airplane-mode tests remain unexecuted.

Scanner packaging reference: https://pub.dev/packages/mobile_scanner/versions/6.0.11

## Chrome review patch

- All 49 Dart source/test files parsed without syntax errors.
- 8 existing Python installer/database/configuration checks passed. These do not execute the new browser database driver.
- All 60 uploaded Unity files were compared byte-for-byte and are unchanged.
- New browser driver setup, Flutter compilation, and Chrome runtime tests still require the user laptop.
