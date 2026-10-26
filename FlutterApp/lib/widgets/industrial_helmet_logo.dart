import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class IndustrialHelmetLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showBadgeCircle;

  const IndustrialHelmetLogo({
    super.key,
    this.size = 100,
    this.color,
    this.showBadgeCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final helmetColor = color ?? Colors.white;

    Widget helmetIcon = Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.engineering_rounded,
            size: size * 0.72,
            color: helmetColor,
          ),
          Positioned(
            top: size * 0.28,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppConstants.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showBadgeCircle) {
      return SizedBox(width: size, height: size, child: helmetIcon);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: helmetIcon,
    );
  }
}
