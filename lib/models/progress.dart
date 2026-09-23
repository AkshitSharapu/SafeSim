class WorkerProgress {
  final String workerId;
  final String moduleId;
  final bool completed;
  final int score;
  final int mistakes;
  final int attempts;
  final String? completedAt;

  const WorkerProgress({
    required this.workerId,
    required this.moduleId,
    this.completed = false,
    this.score = 0,
    this.mistakes = 0,
    this.attempts = 0,
    this.completedAt,
  });

  factory WorkerProgress.fromMap(Map<String, dynamic> map) {
    return WorkerProgress(
      workerId: map['workerId'] as String? ?? '',
      moduleId: map['moduleId'] as String? ?? '',
      completed: (map['completed'] is int)
          ? (map['completed'] as int) == 1
          : (map['completed'] as bool? ?? false),
      score: map['score'] as int? ?? 0,
      mistakes: map['mistakes'] as int? ?? 0,
      attempts: map['attempts'] as int? ?? 0,
      completedAt: map['completedAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'moduleId': moduleId,
      'completed': completed ? 1 : 0,
      'score': score,
      'mistakes': mistakes,
      'attempts': attempts,
      'completedAt': completedAt,
    };
  }

  WorkerProgress copyWith({
    String? workerId,
    String? moduleId,
    bool? completed,
    int? score,
    int? mistakes,
    int? attempts,
    String? completedAt,
  }) {
    return WorkerProgress(
      workerId: workerId ?? this.workerId,
      moduleId: moduleId ?? this.moduleId,
      completed: completed ?? this.completed,
      score: score ?? this.score,
      mistakes: mistakes ?? this.mistakes,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
