import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../services/simulation_launcher_service.dart';
import '../../widgets/industrial_helmet_logo.dart';
import '../../models/simulation_result.dart';

class SimulationLoadingScreen extends ConsumerStatefulWidget {
  final String workerId;
  final String moduleId;

  const SimulationLoadingScreen({
    super.key,
    required this.workerId,
    required this.moduleId,
  });

  @override
  ConsumerState<SimulationLoadingScreen> createState() => _SimulationLoadingScreenState();
}

class _SimulationLoadingScreenState extends ConsumerState<SimulationLoadingScreen> {
  int _statusIndex = 0;
  Timer? _statusTimer;

  final List<String> _telemetryMessages = [
    'Initializing Godot 4 Industrial Physics Pipeline...',
    'Loading Steel Foundry Class-B Fuel Hazards...',
    'Calibrating Extinguisher P.A.S.S. Virtual Sensors...',
    'Binding Offline Worker Telemetry Registry...',
    'Simulation Scenario Ready. Synchronizing...',
  ];

  @override
  void initState() {
    super.initState();
    _startTelemetryCycle();
    _executeLaunch();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startTelemetryCycle() {
    _statusTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _telemetryMessages.length;
        });
      }
    });
  }

  Future<void> _executeLaunch() async {
    // Launch simulation via SimulationLauncherService which automatically:
    // 1. Enters landscape mode
    // 2. Increments attempts in SQLite
    // 3. Runs simulation bridge
    // 4. Restores portrait mode
    // 5. Returns parsed SimulationResult
    final result = await SimulationLauncherService.instance.launchSimulation(
      workerId: widget.workerId,
      moduleId: widget.moduleId,
      loadingDuration: const Duration(milliseconds: 3500),
    );

    if (mounted) {
      // Replace with Results Screen
      context.go('/results', extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09121F), // Dark industrial simulation background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Helmet Logo with Radar Pulse
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryBlue.withValues(alpha: 0.15),
                    border: Border.all(color: AppConstants.secondaryBlue.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const IndustrialHelmetLogo(
                    size: 90,
                    showBadgeCircle: false,
                    color: Colors.white,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 0.95, end: 1.05, duration: 1200.ms, curve: Curves.easeInOut)
                    .shimmer(duration: 1800.ms, color: AppConstants.secondaryBlue.withValues(alpha: 0.3)),

                const SizedBox(height: 24),

                // Main Title
                Text(
                  'Loading Industrial Simulation...',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // Rotating Status Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _telemetryMessages[_statusIndex],
                    key: ValueKey<int>(_statusIndex),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.secondaryBlue,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 28),

                // Linear Loading Bar
                SizedBox(
                  width: 320,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Color(0xFF1E293B),
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryBlue),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SafeSim Industrial Runtime Contract tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Godot 4 Integration Ready • Worker: ${widget.workerId}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
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
