import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/qr_scanner_widget.dart';

class QrLoginScreen extends ConsumerStatefulWidget {
  const QrLoginScreen({super.key});

  @override
  ConsumerState<QrLoginScreen> createState() => _QrLoginScreenState();
}

class _QrLoginScreenState extends ConsumerState<QrLoginScreen> {
  Future<void> _processLogin(String code) async {
    final success = await ref.read(authProvider.notifier).loginWithCode(code);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in successfully as ${ref.read(authProvider).currentWorker?.name}'),
          backgroundColor: AppConstants.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: AppConstants.primaryBlue, size: 22),
            const SizedBox(width: 8),
            Text(
              'SafeSim Terminal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Offline Badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.successLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppConstants.successGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppConstants.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'OFFLINE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.successGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Worker Authentication',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Point camera directly at your factory QR badge to authenticate.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Error banner if any
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.dangerLight,
                    borderRadius: AppConstants.borderRadiusSmall,
                    border: Border.all(color: AppConstants.dangerRed.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppConstants.dangerRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: GoogleFonts.poppins(
                            color: AppConstants.dangerRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pure Scanner Widget Only
              QRScannerWidget(
                promptTitle: 'Align Worker Badge within frame',
                showManualFallback: false,
                height: 380,
                onScanned: (code) => _processLogin(code),
              ),
              const SizedBox(height: 20),

              // Offline verification notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(color: AppConstants.dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppConstants.primaryBlue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Offline cryptographic badge verification enabled',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
