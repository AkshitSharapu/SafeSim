import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/certificate.dart';
import '../database/app_database.dart';

class VerificationResult {
  final bool isVerified;
  final Certificate? certificate;
  final String? errorMessage;
  final String source; // 'SQLite Database' or 'Pre-Loaded Manifest'

  const VerificationResult({
    required this.isVerified,
    this.certificate,
    this.errorMessage,
    this.source = 'Local SQLite Database',
  });
}

class VerificationService {
  static final VerificationService instance = VerificationService._();
  VerificationService._();

  /// Verifies a scanned or entered certificate code completely offline.
  /// 1. Searches SQLite Certificates table first
  /// 2. If not found, checks assets/data/certificates.json
  /// 3. Returns verified Certificate details or unverified result
  Future<VerificationResult> verifyCode(String rawCode) async {
    final cleanCode = rawCode.trim();
    if (cleanCode.isEmpty) {
      return const VerificationResult(
        isVerified: false,
        errorMessage: 'Certificate code cannot be empty.',
      );
    }

    // 1. Search SQLite Database first
    try {
      final dbCertificate = await AppDatabase.instance.verifyCertificate(cleanCode);
      if (dbCertificate != null) {
        return VerificationResult(
          isVerified: true,
          certificate: dbCertificate,
          source: 'Local SQLite registry',
        );
      }
    } catch (_) {
      // Proceed to secondary check
    }

    // 2. Search local asset certificates.json
    try {
      final jsonString = await rootBundle.loadString('assets/data/certificates.json');
      final List<dynamic> certList = json.decode(jsonString);

      for (var item in certList) {
        if (item is Map<String, dynamic>) {
          final certId = item['certificateId'] as String? ?? '';
          final qr = item['qrCode'] as String? ?? '';
          if (certId.toUpperCase() == cleanCode.toUpperCase() ||
              qr.toUpperCase() == cleanCode.toUpperCase()) {
            return VerificationResult(
              isVerified: true,
              certificate: Certificate.fromMap(item),
              source: 'Bundled sample registry (not cryptographic verification)',
            );
          }
        }
      }
    } catch (_) {
      // JSON load error
    }

    // 3. Not verified
    return const VerificationResult(
      isVerified: false,
      errorMessage: 'Certificate Not Verified. Record not found in local safety registry.',
    );
  }
}
