import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../services/verification_service.dart';
import '../../widgets/qr_scanner_widget.dart';
import '../../widgets/primary_button.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  VerificationResult? _lastResult;
  bool _isChecking = false;
  bool _isScannerOpen = true;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    setState(() {
      _isChecking = true;
      _lastResult = null;
    });

    final result = await VerificationService.instance.verifyCode(code);

    setState(() {
      _lastResult = result;
      _isChecking = false;
    });
  }

  void _resetVerification() {
    setState(() {
      _lastResult = null;
      _codeController.clear();
      _isScannerOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Offline Credential Verifier',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, size: 12, color: AppConstants.successGreen),
                const SizedBox(width: 4),
                Text(
                  '100% OFFLINE',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppConstants.successGreen),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Industrial Safety Gate Verification',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scan any physical or digital worker certificate QR code to authenticate accreditation without an internet connection.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppConstants.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Verification Result Display
              if (_isChecking)
                Container(
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppConstants.borderRadius,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Querying On-Device SQLite Registry...'),
                      ],
                    ),
                  ),
                )
              else if (_lastResult != null)
                _buildVerificationResultCard(_lastResult!)
              else ...[
                // Active Scanner View
                if (_isScannerOpen) ...[
                  QRScannerWidget(
                    promptTitle: 'Scan Certificate QR (SAFE-FIRE-2026-...)',
                    manualHint: 'Enter Certificate ID (e.g. SAFE-FIRE...)',
                    onScanned: (code) {
                      _codeController.text = code;
                      _verify(code);
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationResultCard(VerificationResult result) {
    if (result.isVerified && result.certificate != null) {
      final cert = result.certificate!;
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConstants.surfaceWhite,
          borderRadius: AppConstants.borderRadius,
          border: Border.all(color: AppConstants.successGreen, width: 2),
          boxShadow: AppConstants.cardHoverShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppConstants.successLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.verified_rounded, color: AppConstants.successGreen, size: 44),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              'CERTIFICATE VERIFIED AUTHENTIC',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppConstants.successGreen,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Validated against ${result.source}',
              style: GoogleFonts.poppins(fontSize: 11, color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppConstants.dividerColor),
            const SizedBox(height: 12),

            // Worker Details
            _buildDetailRow('Worker Name', cert.workerName ?? cert.workerId),
            const SizedBox(height: 10),
            _buildDetailRow('Worker ID', cert.workerId),
            const SizedBox(height: 10),
            _buildDetailRow('Module', cert.module),
            const SizedBox(height: 10),
            _buildDetailRow('Score Earned', '${cert.score}% (PASSED)', valueColor: AppConstants.successGreen),
            const SizedBox(height: 10),
            _buildDetailRow('Date Issued', cert.issuedAt),
            const SizedBox(height: 10),
            _buildDetailRow('Certificate Code', cert.certificateId),

            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Scan Another Certificate',
              icon: Icons.qr_code_scanner,
              onPressed: _resetVerification,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms);
    } else {
      // Not Verified Red Warning
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppConstants.surfaceWhite,
          borderRadius: AppConstants.borderRadius,
          border: Border.all(color: AppConstants.dangerRed, width: 2),
          boxShadow: AppConstants.cardHoverShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: AppConstants.dangerLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.gpp_bad_rounded, color: AppConstants.dangerRed, size: 44),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              'CERTIFICATE NOT VERIFIED',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppConstants.dangerRed,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result.errorMessage ?? 'Record not found in local offline registry. Invalid or counterfeit credential.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: AppConstants.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Try Again',
              icon: Icons.refresh,
              backgroundColor: AppConstants.dangerRed,
              onPressed: _resetVerification,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms);
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: AppConstants.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppConstants.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
