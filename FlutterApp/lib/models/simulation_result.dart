/// Only a validated terminal result from the native Unity session is accepted.
class SimulationResult {
  final String sessionId;
  final String workerId;
  final String moduleId;
  final bool passed;
  final int score;
  final int mistakes;
  final int duration;

  const SimulationResult({required this.sessionId, required this.workerId,
    required this.moduleId, required this.passed, required this.score,
    required this.mistakes, required this.duration});

  factory SimulationResult.fromMap(Map<String, dynamic> map) {
    String text(String key) {
      final value = map[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Missing or invalid $key');
      }
      return value;
    }
    int number(String key, int max) {
      final value = map[key];
      if (value is! int || value < 0 || value > max) {
        throw FormatException('Invalid $key');
      }
      return value;
    }
    if (map['schemaVersion'] != 1 || map['status'] != 'completed' || map['passed'] is! bool) {
      throw const FormatException('Not a completed simulation result');
    }
    final score = number('score', 100);
    final passed = map['passed'] as bool;
    if (passed && score < 70) throw const FormatException('Inconsistent pass score');
    return SimulationResult(sessionId: text('sessionId'), workerId: text('workerId'),
      moduleId: text('moduleId'), passed: passed, score: score,
      mistakes: number('mistakes', 100000), duration: number('duration', 86400));
  }

  Map<String, dynamic> toMap() => {'schemaVersion': 1, 'status': 'completed',
    'sessionId': sessionId, 'workerId': workerId, 'moduleId': moduleId,
    'passed': passed, 'score': score, 'mistakes': mistakes, 'duration': duration};

  String get formattedDuration => '${duration ~/ 60}m ${(duration % 60).toString().padLeft(2, '0')}s';
}
