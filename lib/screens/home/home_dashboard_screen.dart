import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../models/training_module.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/module_card.dart';
import '../../widgets/progress_card.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  TrainingModule? _fireModule;
  bool _isLoadingModule = true;

  @override
  void initState() {
    super.initState();
    _loadModuleData();
  }

  Future<void> _loadModuleData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/modules.json');
      final List<dynamic> list = json.decode(jsonString);
      if (list.isNotEmpty) {
        setState(() {
          _fireModule = TrainingModule.fromMap(list.first);
          _isLoadingModule = false;
        });
      }
    } catch (_) {
      // Fallback
      setState(() {
        _fireModule = const TrainingModule(
          id: AppConstants.defaultModuleId,
          title: 'Fire & Explosion Response',
          category: 'High Hazard Emergency',
          department: 'Mining & Heavy Steel',
          duration: '3 minutes',
          difficulty: 'Beginner',
          description: 'Emergency containment and suppression of industrial fires using PASS protocol.',
          objectives: ['Identify fire classes', 'Master PASS protocol', 'Safe evacuation'],
        );
        _isLoadingModule = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final worker = authState.currentWorker;

    final stats = progressState.stats;
    final completedCount = stats['completedModules'] ?? 0;
    final totalAttempts = stats['totalAttempts'] ?? 0;
    final avgScore = stats['averageScore'] ?? 0;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(progressProvider.notifier).refreshActiveWorker(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Worker Profile Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppConstants.primaryBlue,
                        AppConstants.primaryDark,
                      ],
                    ),
                    borderRadius: AppConstants.borderRadius,
                    boxShadow: AppConstants.cardHoverShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.engineering, color: Colors.white, size: 30),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker?.name ?? 'Industrial Worker',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ID: ${worker?.workerCode ?? "WK001"} • ${worker?.role ?? "Operator"}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Safety Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white70, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'LEVEL 1',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Offline Status Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cloud_off, size: 14, color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  'Local SQLite Storage Active',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
                                ),
                              ],
                            ),
                            Text(
                              'SafeSim Sync 100%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF81C784),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: ProgressCard(
                        label: 'Completed',
                        value: '$completedCount',
                        icon: Icons.check_circle_outline,
                        iconColor: AppConstants.successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProgressCard(
                        label: 'Avg Score',
                        value: '$avgScore%',
                        icon: Icons.speed,
                        iconColor: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProgressCard(
                        label: 'Attempts',
                        value: '$totalAttempts',
                        icon: Icons.replay,
                        iconColor: AppConstants.warningOrange,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 28),

                // Section Header: Today's Training
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Training",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MANDATORY',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.dangerRed,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Large Fire Module Card
                if (_isLoadingModule)
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppConstants.borderRadius,
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (_fireModule != null)
                  ModuleCard(
                    module: _fireModule!,
                    progress: progressState.activeProgress,
                    onTap: () {
                      context.push('/modules/${_fireModule!.id}');
                    },
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms).scale(begin: const Offset(0.98, 0.98)),

                const SizedBox(height: 24),

                // Industrial Safety Notice Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: AppConstants.borderRadius,
                    border: Border.all(color: AppConstants.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppConstants.primaryBlue, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Factory Protocol Directive',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All plant personnel must recertify on emergency evacuation and fire containment quarterly.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
