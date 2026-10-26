class Certificate {
  final String certificateId;
  final String workerId;
  final String module;
  final int score;
  final String issuedAt;
  final String qrCode;
  final String? workerName;

  const Certificate({
    required this.certificateId,
    required this.workerId,
    required this.module,
    required this.score,
    required this.issuedAt,
    required this.qrCode,
    this.workerName,
  });

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      certificateId: map['certificateId'] as String? ?? '',
      workerId: map['workerId'] as String? ?? '',
      module: map['module'] as String? ?? 'Fire & Explosion Response',
      score: map['score'] as int? ?? 0,
      issuedAt: map['issuedAt'] as String? ?? '',
      qrCode: map['qrCode'] as String? ?? map['certificateId'] as String? ?? '',
      workerName: map['workerName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'certificateId': certificateId,
      'workerId': workerId,
      'module': module,
      'score': score,
      'issuedAt': issuedAt,
      'qrCode': qrCode,
      if (workerName != null) 'workerName': workerName,
    };
  }
}
