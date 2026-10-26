import 'package:flutter_test/flutter_test.dart';
import 'package:safesim/models/simulation_result.dart';

void main() {
  Map<String, dynamic> result() => {'schemaVersion': 1, 'status': 'completed',
    'sessionId': 'session-1', 'workerId': 'WK001', 'moduleId': 'MOD-FIRE-01',
    'passed': true, 'score': 85, 'mistakes': 2, 'duration': 90};
  test('completed result preserves identity and measurements', () {
    final value = SimulationResult.fromMap(result());
    expect(value.toMap(), result());
    expect(value.formattedDuration, '1m 30s');
  });
  test('absent result cannot become a default pass', () {
    expect(() => SimulationResult.fromMap({}), throwsFormatException);
  });
  test('rejects cancellation, low passing score, and invalid measurements', () {
    for (final patch in [<String, dynamic>{'status': 'cancelled'},
      {'score': 69}, {'duration': -1}, {'score': 101}, {'mistakes': '2'},
      {'workerId': ''}, {'schemaVersion': 2}, {'passed': 'true'}]) {
      expect(() => SimulationResult.fromMap({...result(), ...patch}), throwsFormatException);
    }
  });
}
