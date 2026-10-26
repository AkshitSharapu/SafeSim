import 'package:uuid/uuid.dart';
import '../models/simulation_result.dart';
import '../database/app_database.dart';
import 'simulation_bridge.dart';
import 'landscape_controller.dart';

class SimulationLauncherService {
  static final instance = SimulationLauncherService._();
  SimulationLauncherService._();
  bool _running = false;

  Future<SimulationResult> launchSimulation({required String workerId, required String moduleId}) async {
    if (_running) throw const SimulationUnavailable('A training session is already open.');
    _running = true;
    try {
      // Unity owns its landscape activity. Flutter remains portrait underneath it.
      final result = await SimulationBridge.executeSimulation(
        sessionId: const Uuid().v4(), workerId: workerId, moduleId: moduleId);
      await AppDatabase.instance.recordSimulation(result);
      // A failed acknowledgement is harmless: SQLite deduplicates by sessionId on recovery.
      try { await SimulationBridge.acknowledge(result.sessionId); } catch (_) {}
      return result;
    } finally {
      _running = false;
      await LandscapeController.exitToPortraitMode();
    }
  }
  Future<void> recoverForWorker(String workerId) async {
    final results = await SimulationBridge.recoverResults();
    for (final result in results.where((r) => r.workerId == workerId)) {
      await AppDatabase.instance.recordSimulation(result);
      await SimulationBridge.acknowledge(result.sessionId);
    }
  }

}
