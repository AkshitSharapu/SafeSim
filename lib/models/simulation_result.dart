class SimulationResult {
  final String workerId;
  final String moduleId;
  final bool passed;
  final int score;
  final int mistakes;
  final int duration; // in seconds

  const SimulationResult({
    required this.workerId,
    required this.moduleId,
    required this.passed,
    required this.score,
    required this.mistakes,
    required this.duration,
  });

  factory SimulationResult.fromMap(Map<String, dynamic> map, {String fallbackWorkerId = '', String fallbackModuleId = 'MOD-FIRE-01'}) {
    return SimulationResult(
      workerId: map['workerId'] as String? ?? fallbackWorkerId,
      moduleId: map['moduleId'] as String? ?? map['module'] as String? ?? fallbackModuleId,
      passed: map['passed'] as bool? ?? true,
      score: map['score'] as int? ?? 90,
      mistakes: map['mistakes'] as int? ?? 0,
      duration: map['duration'] as int? ?? 165,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'module': moduleId,
      'passed': passed,
      'score': score,
      'mistakes': mistakes,
      'duration': duration,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
}
