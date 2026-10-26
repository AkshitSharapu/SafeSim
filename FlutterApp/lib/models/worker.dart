class Worker {
  final String id;
  final String workerCode;
  final String name;
  final String role;
  final String language;
  final String qr;
  final String department;

  const Worker({
    required this.id,
    required this.workerCode,
    required this.name,
    required this.role,
    required this.language,
    required this.qr,
    this.department = 'Mining & Plant Div. 04',
  });

  factory Worker.fromMap(Map<String, dynamic> map) {
    return Worker(
      id: map['id'] as String? ?? '',
      workerCode: map['workerCode'] as String? ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Industrial Worker',
      role: map['role'] as String? ?? 'Operator',
      language: map['language'] as String? ?? 'English',
      qr: map['qr'] as String? ?? map['workerCode'] as String? ?? '',
      department: map['department'] as String? ?? 'Mining & Plant Div. 04',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerCode': workerCode,
      'name': name,
      'role': role,
      'language': language,
      'qr': qr,
      'department': department,
    };
  }

  Worker copyWith({
    String? id,
    String? workerCode,
    String? name,
    String? role,
    String? language,
    String? qr,
    String? department,
  }) {
    return Worker(
      id: id ?? this.id,
      workerCode: workerCode ?? this.workerCode,
      name: name ?? this.name,
      role: role ?? this.role,
      language: language ?? this.language,
      qr: qr ?? this.qr,
      department: department ?? this.department,
    );
  }
}
