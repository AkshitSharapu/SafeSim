import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/simulation_result.dart';

class SimulationUnavailable implements Exception {
  final String message;
  const SimulationUnavailable(this.message);
  @override
  String toString() => message;
}
class SimulationCancelled implements Exception {
  const SimulationCancelled();
}

class SimulationBridge {
  static const channel = MethodChannel('com.safesim.unity_bridge');

  static Future<SimulationResult> executeSimulation({required String sessionId,
    required String workerId, required String moduleId}) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw const SimulationUnavailable('For the laptop review, run the simulation in Unity Editor. This Chrome demo does not launch Unity or receive Editor results. The connected simulation requires the Android build.');
    }
    try {
      final raw = await channel.invokeMethod<dynamic>('startSimulation', {
        'schemaVersion': 1, 'sessionId': sessionId, 'workerId': workerId,
        'moduleId': moduleId,
      });
      final Object? decoded = raw is String ? jsonDecode(raw) : raw;
      if (decoded is! Map) throw const FormatException('Unity returned no result');
      final data = Map<String, dynamic>.from(decoded);
      if (data['sessionId'] != sessionId || data['workerId'] != workerId || data['moduleId'] != moduleId) {
        throw const FormatException('The result belongs to a different training session');
      }
      if (data['status'] == 'cancelled') throw const SimulationCancelled();
      return SimulationResult.fromMap(data);
    } on MissingPluginException {
      throw const SimulationUnavailable('The Android Unity connection is not installed in this build.');
    } on PlatformException catch (e) {
      if (e.code == 'CANCELLED') throw const SimulationCancelled();
      throw SimulationUnavailable(e.message ?? 'Unable to open the simulation. Please try again.');
    }
  }
  static Future<List<SimulationResult>> recoverResults() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return [];
    try {
      final values = await channel.invokeListMethod<String>('getRecoveredResults') ?? [];
      return values.map((raw) => SimulationResult.fromMap(Map<String, dynamic>.from(jsonDecode(raw) as Map))).toList();
    } on MissingPluginException { return []; }
  }
  static Future<void> acknowledge(String sessionId) async {
    await channel.invokeMethod<void>('acknowledgeRecoveredResult', {'sessionId': sessionId});
  }

}
