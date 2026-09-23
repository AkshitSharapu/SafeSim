import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/secondary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final worker = authState.currentWorker;
    final stats = progressState.stats;

    final completedCount = stats['completedModules'] ?? 0;
    final totalAttempts = stats['totalAttempts'] ?? 0;
    final certsEarned = stats['certificatesEarned'] ?? 0;
    final avgScore = stats['averageScore'] ?? 0;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Worker Safety Profile',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppConstants.dangerRed),
            tooltip: 'Sign Out / Switch Worker',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identity Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(color: AppConstants.dividerColor),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppConstants.accentLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppConstants.primaryBlue, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.engineering_rounded, color: AppConstants.primaryBlue, size: 38),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker?.name ?? 'Ramesh Tudu',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${worker?.role ?? "Factory Worker"} • Plant Div. 04',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppConstants.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppConstants.scaffoldBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Worker ID: ${worker?.workerCode ?? "WK001"}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppConstants.dividerColor),
                    const SizedBox(height: 12),

                    // Offline Security Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.successLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.successGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_rounded, color: AppConstants.successGreen, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OFFLINE CERTIFIED RECORD',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppConstants.successGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'All telemetry and exam grades reside securely in the encrypted on-device SQLite database.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppConstants.textPrimary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Safety Matrix Headline
              Text(
                'Safety Performance Metrics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // 2x2 Stats Grid
              Row(
                children: [
                  Expanded(
                    child: ProgressCard(
                      label: 'Completed Modules',
                      value: '$completedCount',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppConstants.successGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProgressCard(
                      label: 'Certificates Earned',
                      value: '$certsEarned',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: AppConstants.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProgressCard(
                      label: 'Total Attempts',
                      value: '$totalAttempts',
                      icon: Icons.replay_rounded,
                      iconColor: AppConstants.warningOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProgressCard(
                      label: 'Average Score',
                      value: '$avgScore%',
                      icon: Icons.speed_rounded,
                      iconColor: const Color(0xFF7B1FA2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // System Diagnostics / Architecture
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(color: AppConstants.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terminal Specifications',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDiagRow('Database Engine', 'SQLite 3.x (sqflite)'),
                    const SizedBox(height: 8),
                    _buildDiagRow('Godot 4 Integration', 'SimulationBridge Ready (Hook Active)'),
                    const SizedBox(height: 8),
                    _buildDiagRow('Font Subsystem', 'Google Fonts Poppins (Cached)'),
                    const SizedBox(height: 8),
                    _buildDiagRow('Platform Build', 'SafeSim v1.0.0 Production'),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Switch Worker / Logout
              SecondaryButton(
                text: 'Switch Worker / Logout',
                icon: Icons.logout,
                textColor: AppConstants.dangerRed,
                borderColor: AppConstants.dangerRed.withValues(alpha: 0.5),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppConstants.textSecondary)),
        Text(val, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
      ],
    );
  }
}
