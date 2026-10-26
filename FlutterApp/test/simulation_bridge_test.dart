import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safesim/services/simulation_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Future<dynamic> launch() => SimulationBridge.executeSimulation(
    sessionId: 's1', workerId: 'WK001', moduleId: 'MOD-FIRE-01');
  Map<String, dynamic> result() => {'schemaVersion': 1, 'status': 'completed',
    'sessionId': 's1', 'workerId': 'WK001', 'moduleId': 'MOD-FIRE-01',
    'passed': true, 'score': 85, 'mistakes': 2, 'duration': 90};
  setUp(() { debugDefaultTargetPlatformOverride = TargetPlatform.android; });
  tearDown(() {
    messenger.setMockMethodCallHandler(SimulationBridge.channel, null);
    debugDefaultTargetPlatformOverride = null;
  });
  test('launch passes identity and accepts a matching native result', () async {
    messenger.setMockMethodCallHandler(SimulationBridge.channel, (call) async {
      expect(call.method, 'startSimulation');
      expect(call.arguments['sessionId'], 's1');
      return jsonEncode(result());
    });
    expect((await launch()).score, 85);
  });
  test('rejects result belonging to another worker', () async {
    messenger.setMockMethodCallHandler(SimulationBridge.channel,
      (_) async => {...result(), 'workerId': 'WK002'});
    await expectLater(launch(), throwsFormatException);
  });
  test('cancelling never creates a pass result', () async {
    messenger.setMockMethodCallHandler(SimulationBridge.channel,
      (_) async => throw PlatformException(code: 'CANCELLED'));
    await expectLater(launch(), throwsA(isA<SimulationCancelled>()));
  });
  test('missing native bridge produces an actionable failure', () async {
    await expectLater(launch(), throwsA(isA<SimulationUnavailable>()));
  });
}
