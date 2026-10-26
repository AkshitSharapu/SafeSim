# Acceptance checks — run in Unity and on an Android device

These are pending runtime tests. Do not interpret this checklist as a record of passed tests.

1. Import in Unity 2022.3.62f3. No compile errors. Run SafeSim → Run Logic Checks and inspect Console.
2. Open Training and Play. Start screen, bright factory, three fire zones and narration appear. No missing/pink materials.
3. Starting timer remains zero before START; moves after START. WASD collision prevents going through walls and tanks.
4. Camera responds to right-drag and clamps vertical pitch. HUD buttons remain clickable.
5. Press E away from alarm: no advancement. Near alarm, facing away: no advancement. Facing it: next objective and voice.
6. Extinguisher pickup attaches the visible cylinder to the camera. Spraying before pin removal does nothing and uses no charge.
7. Pin button triggers one removal animation; repeated clicks cannot skip stages. Arrow target changes to operating mark.
8. Walk onto mark; spraying becomes available. White plume and hiss run only while spray is held. Releasing stops emission.
9. Aim above the base: charge decreases, fire does not. Aim at live base: green crosshair and that zone shrinks.
10. A wall or tank between camera and fire blocks suppression. Moving too far away or closer than allowed prevents a hit.
11. Extinguish one zone; other zones remain. Extinguish all three; instructor directs player to exit and spray stops.
12. Door slides open. Reach exit: completion results with elapsed time, effective spray percentage and remaining charge.
13. Restart: cylinder and pin restored, fire back, charge full, door closed, timer reset. Play a second complete run.
14. Deliberately empty tank while missing: retry screen, no further suppression. Restart works.
15. Pause while moving/spraying: timer and particles freeze, sound pauses. Resume: input is released, no stuck spray.
16. Repeat voice: current clip restarts; previous instruction does not overlap.
17. TOUCH UI on desktop: joystick and look drag respond; toggle back restores mouse/keyboard movement.
18. Android: left thumb movement, right finger look, third finger spray work together; release any finger without stopping the others.
19. Android: switch apps while spraying. Returning shows pause and no stuck touch input. Resume works.
20. Test 16:9 and wider phone ratios; confirm safe area and readable buttons, and no controls hidden behind device cutouts.
21. Test audio offline. Run two full cycles and check memory, heat and frame rate on the intended phone.

Performance target is configurable, not measured: 60 FPS request, a few unshadowed lights, one shadowed directional light, bounded particle counts, no network calls. Measure with Unity Profiler and a real device before promising a frame rate.
