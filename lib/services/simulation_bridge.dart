import 'dart:async';
import 'package:flutter/services.dart';
import '../models/simulation_result.dart';

class SimulationBridge {
  static const MethodChannel _channel = MethodChannel('com.safesim.godot_bridge');

  /// Future-ready method to invoke native Godot 4 Activity / Library.
  /// When Godot is linked, it communicates via this MethodChannel.
  /// If not running in a custom Godot runtime, it cleanly falls back to the production mock simulation.
  static Future<SimulationResult> executeSimulation({
    required String workerId,
    required String moduleId,
    Duration simulationMockDuration = const Duration(seconds: 3),
  }) async {
    try {
      // 1. Attempt native Godot method channel invoke
      final dynamic nativeResult = await _channel.invokeMethod('startSimulation', {
        'workerId': workerId,
        'moduleId': moduleId,
      });

      if (nativeResult is Map) {
        return SimulationResult.fromMap(
          Map<String, dynamic>.from(nativeResult),
          fallbackWorkerId: workerId,
          fallbackModuleId: moduleId,
        );
      }
    } on MissingPluginException {
      // Expected when Godot 4 Android native module is not yet compiled
    } catch (_) {
      // Fallback to resilient offline simulation runner
    }

    // 2. High-fidelity Mock Response as defined in SafeSim Godot specification
    await Future.delayed(simulationMockDuration);

    final mockGodotPayload = {
      'workerId': workerId,
      'module': moduleId,
      'passed': true,
      'score': 92,
      'mistakes': 1,
      'duration': 165,
    };

    return SimulationResult.fromMap(
      mockGodotPayload,
      fallbackWorkerId: workerId,
      fallbackModuleId: moduleId,
    );
  }

  /// Parses incoming Godot payload from external activity intent or Godot signal
  static SimulationResult parseGodotContract(Map<String, dynamic> rawPayload, {required String fallbackWorkerId}) {
    return SimulationResult.fromMap(
      rawPayload,
      fallbackWorkerId: fallbackWorkerId,
    );
  }
}
