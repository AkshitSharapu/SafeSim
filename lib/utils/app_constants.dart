import 'package:flutter/material.dart';

class AppConstants {
  // App Identity
  static const String appName = 'SafeSim';
  static const String appTagline = 'Train Today. Prevent Accidents Tomorrow.';
  static const String appSubtitle = 'Offline Industrial Safety Training Platform';
  static const String appVersion = 'v1.0.0-PROD';

  // Storage & Database keys
  static const String databaseName = 'safesim_local.db';
  static const int databaseVersion = 1;
  static const String prefsActiveWorkerId = 'active_worker_id';

  // Industrial Theme Palette
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color accentLight = Color(0xFFE3F2FD);
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Status Colors
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color warningOrange = Color(0xFFF9A825);
  static const Color warningLight = Color(0xFFFFF9C4);

  // Dimensions & Radius
  static const double borderRadiusValue = 18.0;
  static final BorderRadius borderRadius = BorderRadius.circular(borderRadiusValue);
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(12.0);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(24.0);

  // Soft Industrial Shadows
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> cardHoverShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 2,
    ),
  ];

  // Default Simulation Module
  static const String defaultModuleId = 'MOD-FIRE-01';
  static const String defaultModuleName = 'Fire & Explosion Response';
}
