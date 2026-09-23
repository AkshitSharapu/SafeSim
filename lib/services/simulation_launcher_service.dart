import 'dart:async';
import '../models/simulation_result.dart';
import '../database/app_database.dart';
import 'landscape_controller.dart';
import 'simulation_bridge.dart';

class SimulationLauncherService {
  static final SimulationLauncherService instance = SimulationLauncherService._();
  SimulationLauncherService._();

  /// Launches the industrial Godot simulation.
  /// 1. Increments worker attempt count in SQLite
  /// 2. Switches display orientation to landscape
  /// 3. Executes simulation payload via SimulationBridge
  /// 4. Restores portrait orientation upon completion
  /// 5. Returns parsed SimulationResult
  Future<SimulationResult> launchSimulation({
    required String workerId,
    required String moduleId,
    Duration loadingDuration = const Duration(milliseconds: 3200),
  }) async {
    // 1. Record attempt in offline SQLite database
    await AppDatabase.instance.incrementAttempt(workerId, moduleId);

    // 2. Transition orientation to landscape
    await LandscapeController.enterLandscapeMode();

    try {
      // 3. Run simulation bridge
      final result = await SimulationBridge.executeSimulation(
        workerId: workerId,
        moduleId: moduleId,
        simulationMockDuration: loadingDuration,
      );

      return result;
    } finally {
      // 4. Always restore portrait orientation when exiting simulation
      await LandscapeController.exitToPortraitMode();
    }
  }
}
