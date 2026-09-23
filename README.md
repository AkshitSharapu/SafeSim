# SafeSim — Industrial Safety Training Platform
### *Train Today. Prevent Accidents Tomorrow.*

SafeSim is a production-quality, **offline-first** industrial safety training application built with **Flutter (Android)** for workers in steel manufacturing, mining, and heavy process industries. 

The application provides interactive procedural training (PASS fire extinguisher protocols, emergency evacuation, hazard containment), offline cryptographic credential verification, and a plug-and-play **Godot 4 3D simulation integration layer**.

---

## Key Features

1. **100% Offline-First Operation**:
   - Zero internet dependency.
   - Built-in encrypted SQLite database (`safesim_local.db`) tracking workers, progress attempts, and issued credentials.
   - Local JSON fallback seed for initial deployment without connectivity.

2. **Industrial Material 3 Design System**:
   - **Industrial Blue**: Primary `#1565C0`, Secondary `#42A5F5`, Background `#F5F7FA`
   - High-contrast safety status indicators: Success `#2E7D32`, Danger `#D32F2F`, Warning `#F9A825`
   - Rounded corners (18px) and soft industrial shadows.
   - Large 56px touch targets for factory workers wearing PPE/gloves.
   - Modern typography powered by Google Fonts `Poppins`.

3. **Plug-and-Play Godot 4 Integration Layer**:
   - The Flutter UI and business logic are fully decoupled from the 3D game engine.
   - `SimulationLauncherService`: Exposes `launchSimulation({ required String workerId, required String moduleId })`.
   - `LandscapeController`: Automatically locks display to Landscape during the 3D simulation and safely restores Portrait orientation upon completion.
   - `SimulationBridge`: Bidirectional contract ready to receive the Godot 4 payload:
     ```json
     {
       "workerId": "WK001",
       "module": "fire",
       "passed": true,
       "score": 90,
       "mistakes": 2,
       "duration": 164
     }
     ```
   - `SimulationLoadingScreen`: Fullscreen dark industrial HUD with animated safety helmet, telemetry pulse, and status indicators.

4. **P.A.S.S. Safety Instructions**:
   - Interactive sequential illustrated cards:
     - **P** - Pull the safety pin & break tamper seal
     - **A** - Aim low at the base of the fire
     - **S** - Squeeze the operating lever
     - **S** - Sweep side-to-side across burning fuel
   - Egress path warnings and mandatory safety tips.

5. **Theoretical Assessment Quiz**:
   - 10 industrial multiple-choice questions covering Class A/B/C/D fires, electrical safety, chemical precautions, and evacuation.
   - Live progress indicator with immediate option feedback and safety explanations.
   - Passing threshold: **70%**.
   - Scores and attempt counts automatically saved to SQLite.

6. **Cryptographic Certificate Generation & Offline QR Verification**:
   - Vector PDF generation via `pdf` and `printing`.
   - Unique Certificate ID format: `SAFE-FIRE-2026-XXXXXXXX`.
   - Embedded QR code generated using `qr_flutter` containing strictly `SAFE-FIRE-2026-XXXXXXXX` (no external URLs).
   - Offline double-check verification engine searching SQLite first, then master JSON manifest.
   - Green verified badge for valid credentials / Red alert for unverified credentials.

---

## Project Structure

```
SafeSim/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Camera & storage permissions, orientation
├── assets/
│   ├── data/
│   │   ├── workers.json              # Seed worker records (WK001 Ramesh Tudu)
│   │   ├── modules.json              # Fire & Explosion Response module
│   │   ├── questions.json            # 10 industrial fire safety questions
│   │   └── certificates.json         # Master certificate registry
│   ├── images/
│   ├── icons/
│   └── certificates/
├── lib/
│   ├── main.dart                     # App entry point, portrait orientation lock
│   ├── app.dart                      # GoRouter definitions & theme configuration
│   ├── theme/
│   │   └── app_theme.dart            # Material Design 3 industrial theme tokens
│   ├── models/
│   │   ├── worker.dart
│   │   ├── training_module.dart
│   │   ├── progress.dart
│   │   ├── question.dart
│   │   ├── certificate.dart
│   │   └── simulation_result.dart
│   ├── database/
│   │   └── app_database.dart         # SQLite CRUD (Workers, Progress, Certificates)
│   ├── services/
│   │   ├── landscape_controller.dart
│   │   ├── simulation_bridge.dart    # Godot 4 contract
│   │   ├── simulation_launcher_service.dart
│   │   ├── certificate_service.dart  # PDF & QR generation
│   │   └── verification_service.dart # 2-tier offline verifier
│   ├── providers/
│   │   ├── auth_provider.dart        # Riverpod authentication state
│   │   ├── progress_provider.dart    # Reactive training stats
│   │   └── quiz_provider.dart        # Quiz progression & instant feedback
│   ├── screens/
│   │   ├── splash/splash_screen.dart
│   │   ├── auth/qr_login_screen.dart
│   │   ├── home/
│   │   │   ├── home_nav_wrapper.dart
│   │   │   └── home_dashboard_screen.dart
│   │   ├── modules/module_details_screen.dart
│   │   ├── simulation/
│   │   │   ├── safety_instructions_screen.dart
│   │   │   └── simulation_loading_screen.dart
│   │   ├── results/results_screen.dart
│   │   ├── quiz/quiz_screen.dart
│   │   ├── certificate/
│   │   │   ├── certificate_screen.dart
│   │   │   └── certificates_list_screen.dart
│   │   ├── verification/verification_screen.dart
│   │   └── profile/profile_screen.dart
│   ├── widgets/
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   ├── module_card.dart
│   │   ├── progress_card.dart
│   │   ├── worker_card.dart
│   │   ├── certificate_card.dart
│   │   ├── safety_tip_card.dart
│   │   ├── qr_scanner_widget.dart
│   │   └── industrial_helmet_logo.dart
│   └── utils/
│       ├── app_constants.dart
│       └── id_generator.dart
└── pubspec.yaml
```

---

## How to Plug in Godot 4 Later

The Flutter codebase is already prepared to interface with Godot 4 via `SimulationBridge` and `SimulationLauncherService`:

1. **Native MethodChannel**:
   - `SimulationBridge` listens on channel `com.safesim.godot_bridge`.
   - When Godot is added (as an Android Library `.aar` or via Android Intent to a Godot Android activity), pass:
     ```dart
     { "workerId": workerId, "moduleId": moduleId }
     ```
2. **Returning from Godot**:
   - Return a Map / JSON matching the contract:
     ```json
     {
       "workerId": "WK001",
       "module": "MOD-FIRE-01",
       "passed": true,
       "score": 90,
       "mistakes": 2,
       "duration": 164
     }
     ```
   - Flutter automatically parses it into `SimulationResult`, rotates back to Portrait mode, and routes directly to `/results`.

---

## Running the Application

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run on Connected Device or Emulator**:
   ```bash
   flutter run
   ```

3. **Instant Test Login**:
   - On the QR Login screen, tap the chip **WK001 (Ramesh Tudu)** or scan any badge encoded with `WK001`.
