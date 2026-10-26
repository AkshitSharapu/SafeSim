import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/worker_badge.dart';
import '../../widgets/secondary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSyncing = false;

  void _showManagerSyncModal(BuildContext context, dynamic worker, Map<String, dynamic> stats) {
    final TextEditingController notesController = TextEditingController(
      text: 'Worker completed high-hazard fire suppression training. Approved for field shifts.',
    );
    final TextEditingController managerNameController = TextEditingController(
      text: 'Rajesh Varma (Safety Superintendent)',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppConstants.borderRadius),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              const Icon(Icons.cloud_upload_rounded, color: AppConstants.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Local Training Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record a reviewer name and note on this device. This does not sync to a server or verify reviewer identity.',
                  style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                ),
                const SizedBox(height: 14),

                // Worker summary card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.scaffoldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppConstants.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worker: ${worker?.name ?? "Sharapu Akshit"} (${worker?.workerCode ?? "WK001"})',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed Modules: ${stats["completedModules"] ?? 0} • Avg Score: ${stats["averageScore"] ?? 0}%',
                        style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      ),
                      Text(
                        'Local DB Status: ${stats["syncStatus"] ?? "OFFLINE_PENDING"}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: stats["managerApproved"] == true ? AppConstants.successGreen : AppConstants.warningOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'Shift Manager Name',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: managerNameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),

                Text(
                  'Manager Verification Remarks',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Submit button
                ElevatedButton.icon(
                  onPressed: _isSyncing
                      ? null
                      : () async {
                          setDialogState(() => _isSyncing = true);
                          setState(() => _isSyncing = true);

                          // Save the review locally.
                          await Future.delayed(const Duration(milliseconds: 900));

                          final result = await ref.read(progressProvider.notifier).syncWithServer(
                            managerName: managerNameController.text.trim(),
                            notes: notesController.text.trim(),
                          );

                          if (mounted) {
                            setDialogState(() => _isSyncing = false);
                            setState(() => _isSyncing = false);
                            Navigator.of(dialogCtx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Review saved on this device. Reference: ${result?["serverReceiptId"] ?? "OK"}',
                                ),
                                backgroundColor: AppConstants.successGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  icon: _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_done_rounded),
                  label: Text(_isSyncing ? 'Saving review...' : 'Save Local Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final progressState = ref.watch(progressProvider);
    final worker = authState.currentWorker;
    if (worker == null) return const Scaffold(body: Center(child: Text('Scan your Worker QR to load your profile.')));
    final stats = progressState.stats;

    final completedCount = stats['completedModules'] ?? 0;
    final totalAttempts = stats['totalAttempts'] ?? 0;
    final certsEarned = stats['certificatesEarned'] ?? 0;
    final avgScore = stats['averageScore'] ?? 0;
    final isManagerApproved = stats['managerApproved'] == true;
    final serverReceipt = stats['serverReceiptId'] as String?;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Worker Safety Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                                worker?.name ?? 'Sharapu Akshit',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppConstants.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${worker?.role ?? "Lead Safety Officer"} • ${worker?.department ?? "Mining & Plant Div. 04"}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppConstants.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppConstants.scaffoldBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Worker ID: ${worker?.workerCode ?? "WK001"}',
                                  style: TextStyle(
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
                    const SizedBox(height: 16),

                    // Button: View My Digital QR Badge
                    OutlinedButton.icon(
                      onPressed: worker == null ? null : () => showWorkerBadge(context, worker),
                      icon: const Icon(Icons.qr_code, size: 18),
                      label: const Text('View My Digital QR Badge'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.primaryBlue,
                        side: const BorderSide(color: AppConstants.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 42),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppConstants.dividerColor),
                    const SizedBox(height: 10),

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
                                  'OFFLINE LOCAL ENCRYPTED STORE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppConstants.successGreen,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'Training results and certificates are preserved on-device in SQLite even without connectivity.',
                                  style: TextStyle(
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

              const SizedBox(height: 20),

              // Manager Server Sync Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(
                    color: isManagerApproved ? AppConstants.successGreen.withValues(alpha: 0.5) : AppConstants.warningOrange.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isManagerApproved ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                              color: isManagerApproved ? AppConstants.successGreen : AppConstants.warningOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Local Review Status',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isManagerApproved ? AppConstants.successLight : AppConstants.warningLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isManagerApproved ? 'REVIEWED LOCALLY' : 'PENDING REVIEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isManagerApproved ? AppConstants.successGreen : AppConstants.warningOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isManagerApproved
                          ? 'A reviewer note has been recorded on this device. No server sync has taken place.'
                          : 'Training scores are saved on this device. A reviewer can add a local note.',
                      style: TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                    ),
                    if (serverReceipt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Local Review Reference: $serverReceipt',
                        style: TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppConstants.primaryBlue),
                      ),
                    ],
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => _showManagerSyncModal(context, worker, stats),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: Text(isManagerApproved ? 'Update Local Review' : 'Add Local Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isManagerApproved ? AppConstants.primaryBlue : AppConstants.warningOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Safety Matrix Headline
              Text(
                'Safety Performance Metrics',
                style: TextStyle(
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
}
