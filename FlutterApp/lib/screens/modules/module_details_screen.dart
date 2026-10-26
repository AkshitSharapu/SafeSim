import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_constants.dart';
import '../../models/training_module.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/simulation_launcher_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/safety_tip_card.dart';

class ModuleDetailsScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const ModuleDetailsScreen({
    super.key,
    required this.moduleId,
  });

  @override
  ConsumerState<ModuleDetailsScreen> createState() => _ModuleDetailsScreenState();
}

class _ModuleDetailsScreenState extends ConsumerState<ModuleDetailsScreen> {
  bool _isLaunching = false;

  final TrainingModule _module = const TrainingModule(
    id: 'MOD-FIRE-01',
    title: 'Fire & Explosion Response',
    category: 'High Hazard Emergency',
    department: 'Mining, Steel & Heavy Manufacturing',
    duration: '3 minutes',
    difficulty: 'Beginner',
    description: 'A guided virtual factory exercise with voice instructions, direction arrows and a CO2 extinguisher.',
    objectives: [
      'Raise the alarm and follow the guidance arrows.',
      'Collect the CO2 extinguisher and remove the pin.',
      'Aim at the base and sweep across the simulated fire zones.',
      'Return to the exit and review your result.'
    ],
  );

  Future<void> _launchUnitySimulation() async {
    final worker = ref.read(authProvider).currentWorker;
    if (worker == null) { context.go('/login'); return; }
    final workerId = worker.id;

    setState(() {
      _isLaunching = true;
    });

    // Navigate to the fullscreen landscape simulation loading screen
    context.push(
      '/simulation-loading',
      extra: {
        'workerId': workerId,
        'moduleId': _module.id,
      },
    );

    setState(() {
      _isLaunching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressProvider);
    final activeProgress = progressState.activeProgress;
    final isCompleted = activeProgress?.completed ?? false;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Module Specification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(color: AppConstants.dividerColor),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'HAZARD CLASS 1',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.dangerRed,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.successLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, size: 14, color: AppConstants.successGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'ACCREDITED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _module.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _module.department,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Specs row
                    Row(
                      children: [
                        _buildSpecChip(Icons.timer_outlined, 'Duration', _module.duration),
                        const SizedBox(width: 12),
                        _buildSpecChip(Icons.stairs_outlined, 'Difficulty', _module.difficulty),
                        const SizedBox(width: 12),
                        _buildSpecChip(Icons.score_outlined, 'Pass Mark', '70%'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                'Curriculum Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _module.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Key Objectives
              Text(
                'Competency Objectives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._module.objectives.map((obj) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppConstants.accentLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: AppConstants.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            obj,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppConstants.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 20),

              // Safety Alert
              const SafetyTipCard(
                title: 'Mandatory PPE Reminder',
                message: 'All interactive simulations mandate high-visibility helmet and blast visor check before ignition trials.',
                type: SafetyCardType.warning,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              PrimaryButton(
                text: 'Start Training',
                icon: Icons.play_arrow_rounded,
                isLoading: _isLaunching,
                onPressed: _launchUnitySimulation,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'View Instructions',
                icon: Icons.menu_book_outlined,
                onPressed: () {
                  context.push('/instructions');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppConstants.scaffoldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppConstants.primaryBlue),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: AppConstants.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
