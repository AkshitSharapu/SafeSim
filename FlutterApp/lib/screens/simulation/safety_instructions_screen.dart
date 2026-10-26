import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/safety_tip_card.dart';

class SafetyInstructionsScreen extends ConsumerWidget {
  const SafetyInstructionsScreen({super.key});

  void _beginSimulation(BuildContext context, WidgetRef ref) {
    final worker = ref.read(authProvider).currentWorker;
    if (worker == null) { context.go('/login'); return; }
    final workerId = worker.id;

    context.push(
      '/simulation-loading',
      extra: {
        'workerId': workerId,
        'moduleId': AppConstants.defaultModuleId,
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Standard Operating Procedure',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.accentLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'SOP-FIRE-EXT-04',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The P.A.S.S. Suppression Method',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Remember the four core sequential steps before activating any pressurized industrial cylinder.',
                style: TextStyle(fontSize: 13, color: AppConstants.textSecondary),
              ),
              const SizedBox(height: 24),

              // Card 1: P - PULL
              _buildPassStepCard(
                letter: 'P',
                title: 'PULL the Safety Pin',
                description:
                    'Firmly pull the metal retention ring located on the handle assembly. This snaps the plastic tamper indicator seal and primes the valve.',
                icon: Icons.lock_open_rounded,
                badgeColor: const Color(0xFF1565C0),
              ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 14),

              // Card 2: A - AIM
              _buildPassStepCard(
                letter: 'A',
                title: 'AIM Low at the Base',
                description:
                    'Direct the horn or discharge hose directly at the base of the fire where fuel is igniting. Aiming at high flame tongues will waste extinguishing agent.',
                icon: Icons.gps_fixed_rounded,
                badgeColor: const Color(0xFF0288D1),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 14),

              // Card 3: S - SQUEEZE
              _buildPassStepCard(
                letter: 'S',
                title: 'SQUEEZE the Operating Lever',
                description:
                    'Press down the top operating handle steadily. Maintain an even grip to release a continuous, high-velocity stream of dry chemical powder or CO2.',
                icon: Icons.compress_rounded,
                badgeColor: const Color(0xFFEF6C00),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 14),

              // Card 4: S - SWEEP
              _buildPassStepCard(
                letter: 'S',
                title: 'SWEEP Side to Side',
                description:
                    'Move the nozzle smoothly in a wide lateral sweeping motion across the front edge to back until the base of the burning material is smothered.',
                icon: Icons.swipe_rounded,
                badgeColor: const Color(0xFF2E7D32),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 24),

              // Critical Safety Tips
              const SafetyTipCard(
                title: 'Critical Distance & Egress Warning',
                message:
                    'Always stand 6 to 8 feet (2 meters) away from the fire source. NEVER allow flames to block your escape path to the designated exit door.',
                type: SafetyCardType.danger,
              ),
              const SizedBox(height: 12),
              const SafetyTipCard(
                title: 'Post-Extinguishment Watch',
                message:
                    'Watch for hidden smoldering embers and reignition. Keep the nozzle aimed at the source even after flames disappear.',
                type: SafetyCardType.tip,
              ),
              const SizedBox(height: 32),

              // Begin Simulation Button
              PrimaryButton(
                text: 'Begin Simulation',
                icon: Icons.sensors_rounded,
                onPressed: () => _beginSimulation(context, ref),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassStepCard({
    required String letter,
    required String title,
    required String description,
    required IconData icon,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: AppConstants.borderRadius,
        border: Border.all(color: AppConstants.dividerColor),
        boxShadow: AppConstants.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bold Letter Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: badgeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppConstants.textSecondary,
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
