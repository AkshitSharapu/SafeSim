class TrainingModule {
  final String id;
  final String title;
  final String category;
  final String department;
  final String duration;
  final String difficulty;
  final String description;
  final List<String> objectives;
  final int estimatedDurationSeconds;
  final int passingScorePercentage;
  final String icon;
  final bool isLocked;

  const TrainingModule({
    required this.id,
    required this.title,
    required this.category,
    required this.department,
    required this.duration,
    required this.difficulty,
    required this.description,
    required this.objectives,
    this.estimatedDurationSeconds = 180,
    this.passingScorePercentage = 70,
    this.icon = 'local_fire_department',
    this.isLocked = false,
  });

  factory TrainingModule.fromMap(Map<String, dynamic> map) {
    return TrainingModule(
      id: map['id'] as String? ?? 'MOD-FIRE-01',
      title: map['title'] as String? ?? 'Fire & Explosion Response',
      category: map['category'] as String? ?? 'High Hazard Emergency',
      department: map['department'] as String? ?? 'Mining & Heavy Industry',
      duration: map['duration'] as String? ?? '3 minutes',
      difficulty: map['difficulty'] as String? ?? 'Beginner',
      description: map['description'] as String? ?? '',
      objectives: (map['objectives'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      estimatedDurationSeconds: map['estimatedDurationSeconds'] as int? ?? 180,
      passingScorePercentage: map['passingScorePercentage'] as int? ?? 70,
      icon: map['icon'] as String? ?? 'local_fire_department',
      isLocked: map['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'department': department,
      'duration': duration,
      'difficulty': difficulty,
      'description': description,
      'objectives': objectives,
      'estimatedDurationSeconds': estimatedDurationSeconds,
      'passingScorePercentage': passingScorePercentage,
      'icon': icon,
      'isLocked': isLocked,
    };
  }
}
