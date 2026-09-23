import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../models/simulation_result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class ResultsScreen extends ConsumerWidget {
  final SimulationResult result;

  const ResultsScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final worker = authState.currentWorker;
    final currentProgress = progressState.activeProgress;
    final totalAttempts = (currentProgress?.attempts ?? 0) > 0 ? (currentProgress?.attempts ?? 1) : 1;

    final isPassed = result.passed && result.score >= 70;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: AppConstants.scaffoldBg,
        appBar: AppBar(
          title: Text(
            'Simulation Assessment',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceWhite,
                    borderRadius: AppConstants.borderRadius,
                    border: Border.all(
                      color: isPassed ? AppConstants.successGreen.withValues(alpha: 0.3) : AppConstants.dangerRed.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: AppConstants.softShadow,
                  ),
                  child: Column(
                    children: [
                      // Large Icon Indicator
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPassed ? AppConstants.successLight : AppConstants.dangerLight,
                          border: Border.all(
                            color: isPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            isPassed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                            color: isPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                            size: 46,
                          ),
                        ),
                      )
                          .animate()
                          .scale(duration: 500.ms, curve: Curves.easeOutBack)
                          .shimmer(delay: 600.ms, duration: 1000.ms),

                      const SizedBox(height: 18),

                      Text(
                        isPassed ? 'SIMULATION PASSED' : 'SIMULATION NOT CLEARED',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPassed
                            ? 'Excellent response time and safe extinguisher handling demonstrated.'
                            : 'Critical procedural mistakes observed during hazard containment.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Metrics Matrix
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceWhite,
                    borderRadius: AppConstants.borderRadius,
                    border: Border.all(color: AppConstants.dividerColor),
                    boxShadow: AppConstants.softShadow,
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow('Worker Name', worker?.name ?? 'Ramesh Tudu', Icons.person_outline),
                      const Divider(color: AppConstants.dividerColor, height: 24),
                      _buildMetricRow('Module', 'Fire & Explosion Response', Icons.local_fire_department_outlined),
                      const Divider(color: AppConstants.dividerColor, height: 24),
                      _buildMetricRow(
                        'Simulation Score',
                        '${result.score}%',
                        Icons.speed,
                        highlightColor: isPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                      ),
                      const Divider(color: AppConstants.dividerColor, height: 24),
                      _buildMetricRow('Mistakes Logged', '${result.mistakes}', Icons.error_outline),
                      const Divider(color: AppConstants.dividerColor, height: 24),
                      _buildMetricRow('Attempt Count', '#$totalAttempts', Icons.replay),
                      const Divider(color: AppConstants.dividerColor, height: 24),
                      _buildMetricRow('Time Elapsed', result.formattedDuration, Icons.timer_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                PrimaryButton(
                  text: 'Continue to Assessment Quiz',
                  icon: Icons.assignment_turned_in_outlined,
                  onPressed: () {
                    context.push('/quiz');
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Retry Simulation',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    // Retry increments attempt count & re-launches simulation
                    context.pushReplacement(
                      '/simulation-loading',
                      extra: {
                        'workerId': worker?.id ?? 'WK001',
                        'moduleId': result.moduleId,
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, {Color? highlightColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppConstants.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: highlightColor ?? AppConstants.textPrimary,
          ),
        ),
      ],
    );
  }
}
