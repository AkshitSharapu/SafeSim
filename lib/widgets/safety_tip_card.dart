import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_constants.dart';

enum SafetyCardType { tip, warning, danger, success }

class SafetyTipCard extends StatelessWidget {
  final String title;
  final String message;
  final SafetyCardType type;
  final IconData? icon;

  const SafetyTipCard({
    super.key,
    required this.title,
    required this.message,
    this.type = SafetyCardType.tip,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color iconColor;
    IconData defaultIcon;

    switch (type) {
      case SafetyCardType.warning:
        borderColor = AppConstants.warningOrange;
        bgColor = AppConstants.warningLight.withValues(alpha: 0.5);
        iconColor = const Color(0xFFE65100);
        defaultIcon = Icons.warning_amber_rounded;
        break;
      case SafetyCardType.danger:
        borderColor = AppConstants.dangerRed;
        bgColor = AppConstants.dangerLight;
        iconColor = AppConstants.dangerRed;
        defaultIcon = Icons.dangerous_rounded;
        break;
      case SafetyCardType.success:
        borderColor = AppConstants.successGreen;
        bgColor = AppConstants.successLight;
        iconColor = AppConstants.successGreen;
        defaultIcon = Icons.verified_user_rounded;
        break;
      case SafetyCardType.tip:
      default:
        borderColor = AppConstants.primaryBlue;
        bgColor = AppConstants.accentLight;
        iconColor = AppConstants.primaryBlue;
        defaultIcon = Icons.lightbulb_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppConstants.borderRadius,
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon ?? defaultIcon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppConstants.textPrimary.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
