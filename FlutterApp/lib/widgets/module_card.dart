import 'package:flutter/material.dart';
import '../models/training_module.dart';
import '../models/progress.dart';
import '../utils/app_constants.dart';

class ModuleCard extends StatelessWidget {
  final TrainingModule module;
  final WorkerProgress? progress;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress?.completed ?? false;
    final score = progress?.score ?? 0;
    final attempts = progress?.attempts ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: AppConstants.borderRadius,
        border: Border.all(
          color: isCompleted ? AppConstants.successGreen.withValues(alpha: 0.4) : AppConstants.dividerColor,
          width: isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: AppConstants.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppConstants.borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppConstants.borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tags Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppConstants.accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, size: 14, color: AppConstants.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            module.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppConstants.successLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: AppConstants.successGreen),
                            const SizedBox(width: 4),
                            Text(
                              'COMPLETED ($score%)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.successGreen,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (attempts > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppConstants.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'IN PROGRESS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppConstants.warningOrange,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon & Title
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECEB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department,
                          color: Color(0xFFD32F2F),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.department,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  module.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Specs & Action Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppConstants.scaffoldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppConstants.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            module.duration,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.stacked_line_chart, size: 16, color: AppConstants.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            module.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppConstants.primaryBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
