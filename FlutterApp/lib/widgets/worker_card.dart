import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../utils/app_constants.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback? onSwitch;

  const WorkerCard({
    super.key,
    required this.worker,
    this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: AppConstants.borderRadius,
        border: Border.all(color: AppConstants.dividerColor),
        boxShadow: AppConstants.softShadow,
      ),
      child: Row(
        children: [
          // Industrial Avatar with hard hat icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppConstants.accentLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.primaryBlue.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.engineering,
                color: AppConstants.primaryBlue,
                size: 34,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Worker Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        worker.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.successLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.successGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${worker.role} • ID: ${worker.workerCode}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.language, size: 14, color: AppConstants.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      worker.language,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (onSwitch != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: AppConstants.primaryBlue),
              tooltip: 'Switch Worker',
              onPressed: onSwitch,
            ),
        ],
      ),
    );
  }
}
