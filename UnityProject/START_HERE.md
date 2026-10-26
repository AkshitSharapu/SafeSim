# SafeSim — Unity mobile training prototype

A self-contained source project targeting **Unity 2022.3.62f3 LTS**, built-in render pipeline. The project creates its factory, equipment, particles and UI when Play starts. No Asset Store packages, models, API keys, paid services or external voice service are required at runtime.

**Validation status:** source syntax and package integrity checked outside Unity. Unity Editor and Android are unavailable in the authoring environment, so this release has **not been compiled or play-tested in Unity**. It is source, not a tested APK. Use the included checks and acceptance list before submission.

## Open and play

1. Extract the ZIP. Keep `Assets`, `Packages`, and `ProjectSettings` together inside the `SafeSim` folder.
2. Unity Hub → Projects → Add → select that **SafeSim** folder. Open with **2022.3.62f3**.
3. Wait for initial import and package resolution. Unity may need internet on first import to obtain its standard UGUI package.
4. Open `Assets/SafeSim/Scenes/Training.unity` (or use **SafeSim → Open Training Scene**).
5. Run **SafeSim → Run Logic Checks**. A success message appears in the Console if the supplied editor checks pass.
6. Press **Play** and select **START TRAINING** in the Game view.

The scene contains one bootstrap object before Play. The factory appears **during Play**, by design. This makes the project independent of downloaded assets. Changes to generated objects made during Play will not persist; edit `FactoryWorld.cs` to change the environment permanently.

If the included scene fails to deserialize, use **SafeSim → Repair Bootstrap Scene**, then open the scene and press Play. This generates the bootstrap using Unity's own serializer.

## Desktop controls

| Action | Input |
|---|---|
| Walk | WASD |
| Look / aim | Hold right mouse button and drag |
| Alarm / pickup | E, or click the contextual button |
| Pull pin | P or E, or click PULL PIN |
| Spray | Hold left mouse button over the game world |
| Pause / resume | Escape or PAUSE |
| Repeat instruction | REPEAT |
| Test touch layout | TOUCH UI |

The mouse remains unlocked so buttons are accessible. **Right-drag is required to look.** Holding the left button over a HUD panel does not spray.

## Exercise

1. Follow floor arrows to the red alarm station near the entrance. Face it within 1.75 metres and interact.
2. Follow arrows to the extinguisher stand and pick it up.
3. Pull the pin; its separate model slides out before spraying becomes available.
4. Move onto the turquoise floor mark.
5. Aim down at the base of the fire. The dot turns green on a live target. Hold spray and sweep across three zones. All three must be suppressed. The simulated effective range is 1.8–6 metres and the cylinder holds 30 seconds of simulated discharge.
6. Return to the exit. The door slides open and the results screen appears.
7. Restart to reset equipment, fire, charge, instructions and timer.

Missing the target uses charge. Emptying the cylinder before suppressing all zones leads to a retry screen. These are game parameters, not specifications for a real extinguisher. This prototype is a simplified demonstration, not certified safety training or a physical fire model.

## Mobile

On Android, touch controls turn on automatically:

- Left joystick: movement.
- Drag the right-side look area: camera.
- Context button: alarm, pickup and pin.
- Hold SPRAY: discharge; multiple fingers can move, aim and spray together.
- UI scales with screen size and respects the safe area. Landscape orientation is requested.

Gameplay and touch controls call the same actions. Desktop testing can come first; the mobile implementation is included for later device testing.

## Build Android

1. In Unity Hub, install **Android Build Support**, including **SDK & NDK Tools** and **OpenJDK**, for this editor version.
2. In the project, choose **SafeSim → Configure Android**.
3. Open **File → Build Settings**, choose **Android**, then **Switch Platform**.
4. Confirm `Assets/SafeSim/Scenes/Training.unity` is enabled in Scenes In Build.
5. Choose **Build** for an APK or **Build And Run** with your Android device connected and USB debugging enabled.

The setup menu selects ARM64, IL2CPP, landscape and minimum Android API 26. This is a local testing configuration; Play Store release requirements, signing and publication are outside this prototype.

## Files to modify

| File | Purpose |
|---|---|
| `Assets/SafeSim/Scripts/SafeSimGame.cs` | Input, character movement, interactions, voice and objective orchestration |
| `Assets/SafeSim/Scripts/TrainingState.cs` | Order of objectives, discharge capacity, three fire zones, results |
| `Assets/SafeSim/Scripts/FactoryWorld.cs` | Procedural factory, extinguisher, removable pin, fire, arrows, sliding door |
| `Assets/SafeSim/Scripts/TrainingHUD.cs` | Canvas, objective checklist, modal screens, touch layout |
| `Assets/SafeSim/Scripts/TouchControl.cs` | Independent touch pointer ownership and joystick handling |
| `Assets/SafeSim/Resources/Voice` | Nine offline synthesized English WAV clips and transcript |
| `Assets/SafeSim/Editor/SafeSimTools.cs` | Scene repair, Android configuration and logic checks |
| `Documentation/ACCEPTANCE_TESTS.md` | Play-test checklist |

Replace the WAV files with better recordings using the **same filenames** to improve narration. Procedural models and simple synthesized speech are placeholders; the generated concept image is a visual target, not a screenshot of this project. No animated hands, high-detail imported factory or realistic fluid simulation is included.

## Troubleshooting

- **No factory in Scene view before Play:** expected; press Play with the Training scene open.
- **Input errors:** use Active Input Handling = Input Manager (Old), or run Configure Android and accept an editor restart if prompted. This project uses `UnityEngine.Input`, not the new Input System.
- **Pink materials:** open this standalone built-in pipeline project. Do not copy it directly into a URP/HDRP project without converting its shaders.
- **Cannot pick up:** get close and face the equipment; button becomes active when in range.
- **Cannot spray:** complete the pin and operating-position steps first.
- **No fire reduction:** aim at the lower fire zones until the centre dot turns green; sweep to the remaining zones.
- **No audio:** check system volume, the Game view audio mute button, and the WAV imports.
- **Editor opens a different scene:** double-click Training.unity explicitly.

Original project code and procedural assets are provided under the MIT license in `LICENSE.txt`. Generated speech is described in `Documentation/ASSET_NOTES.md`.
