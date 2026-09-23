import 'dart:math';
import 'package:uuid/uuid.dart';

class IdGenerator {
  static const Uuid _uuid = Uuid();

  /// Generates certificate numbers matching format: SAFE-FIRE-2026-XXXXXXXX
  static String generateCertificateId({String moduleTag = 'FIRE', int year = 2026}) {
    final rawUuid = _uuid.v4().replaceAll('-', '').toUpperCase();
    final randomSuffix = rawUuid.substring(0, 8);
    return 'SAFE-$moduleTag-$year-$randomSuffix';
  }

  /// Generates unique transaction / progress completion IDs
  static String generateUniqueId([String prefix = 'TX']) {
    final raw = _uuid.v4().replaceAll('-', '').substring(0, 10).toUpperCase();
    return '$prefix-$raw';
  }
}
