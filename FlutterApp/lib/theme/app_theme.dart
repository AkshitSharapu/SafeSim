import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppConstants.primaryBlue,
      scaffoldBackgroundColor: AppConstants.scaffoldBg,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppConstants.accentLight,
        onPrimaryContainer: AppConstants.primaryDark,
        secondary: AppConstants.secondaryBlue,
        onSecondary: Colors.white,
        surface: AppConstants.surfaceWhite,
        onSurface: AppConstants.textPrimary,
        error: AppConstants.dangerRed,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppConstants.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppConstants.textPrimary,
          fontSize: 24,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
          fontSize: 18,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppConstants.textPrimary,
          fontSize: 16,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppConstants.textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppConstants.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppConstants.surfaceWhite,
        foregroundColor: AppConstants.textPrimary,
        titleTextStyle: TextStyle(
          color: AppConstants.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppConstants.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppConstants.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadius,
          side: const BorderSide(color: AppConstants.dividerColor, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius,
          ),
          elevation: 2,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryBlue,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppConstants.primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppConstants.borderRadius,
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: AppConstants.textMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius,
          borderSide: const BorderSide(color: AppConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius,
          borderSide: const BorderSide(color: AppConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius,
          borderSide: const BorderSide(color: AppConstants.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppConstants.borderRadius,
          borderSide: const BorderSide(color: AppConstants.dangerRed, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: AppConstants.surfaceWhite,
        elevation: 10,
        shadowColor: Colors.black12,
        indicatorColor: AppConstants.accentLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConstants.primaryBlue,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppConstants.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppConstants.primaryBlue, size: 24);
          }
          return const IconThemeData(color: AppConstants.textSecondary, size: 24);
        }),
      ),
    );
  }
}
