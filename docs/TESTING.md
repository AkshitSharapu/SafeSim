# Required editor and device validation

1. Run `python -m unittest discover -s tools -p "test_*.py"` from the bundle root.
2. Run `flutter analyze` and `flutter test` in FlutterApp. These need Flutter installed.
3. Run Unity's SafeSim → Run Logic Checks. Play the training scene, follow every instruction, and
   verify pickup, pin removal, spray, three-zone suppression, exit, and restart.
4. Export and install Unity, then build/run Flutter on a physical ARM64 Android device.
5. Verify portrait Flutter → landscape Unity → portrait results, including Android Back cancellation.
6. Test touch movement and look together, movement and spray together, instructor audio, and arrows.
7. Miss until the cylinder is empty: the result must fail. Cancellation must not increase attempts.
8. Complete and return: exactly one attempt must be saved. Reopen the app: it must not duplicate.
9. Pass quiz without passing Unity: no training record. Pass Unity but fail quiz: no record.
10. Pass both: record becomes available. Switch worker: results and eligibility must stay separate.
11. Background and restore both screens; test phone lock/unlock and repeated launches. Force-stop
    during training: an unfinished session must not count as passed. Finish and restart Flutter:
    a delivered but unacknowledged result should be recovered once.
12. Disable internet after installation. Voice and gameplay should remain available. Check low-memory
    devices, overheating/frame rate, permissions, PDF printing, and QR camera scanning.

Do not mark device checks complete based solely on the source checks or the Unity logic checker.

13. Run the complete first-install airplane-mode checklist in OFFLINE_AND_WORKERS.md, including new worker registration and profile isolation.
