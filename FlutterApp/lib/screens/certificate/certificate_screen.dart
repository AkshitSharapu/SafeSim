import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/app_constants.dart';
import '../../models/certificate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/certificate_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/industrial_helmet_logo.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  final int score;

  const CertificateScreen({
    super.key,
    this.score = 0,
  });

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen> {
  Certificate? _certificate;
  bool _isIssuing = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _issueCertificate();
  }

  Future<void> _issueCertificate() async {
    final worker = ref.read(authProvider).currentWorker;
    try {
      if (worker == null) throw StateError('Please sign in first.');
      final cert = await CertificateService.instance.issueCertificate(
        worker: worker, moduleName: AppConstants.defaultModuleName, score: widget.score);
      await ref.read(progressProvider.notifier).refreshActiveWorker();
      if (mounted) setState(() { _certificate = cert; _isIssuing = false; });
    } catch (_) {
      if (mounted) setState(() {
        _isIssuing = false;
        _error = 'A saved Unity simulation pass and a quiz score of at least 70% are required.';
      });
    }
  }

  Future<void> _saveLocally() async {
    if (_certificate == null) return;
    setState(() => _isSaving = true);
    try {
      final saved = await CertificateService.instance.savePdfLocally(_certificate!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved),
            backgroundColor: AppConstants.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF could not be saved. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Training certificate')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center))));
    }
    if (_isIssuing || _certificate == null) {
      return Scaffold(
        backgroundColor: AppConstants.scaffoldBg,
        appBar: AppBar(title: const Text('Training Record')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating Local Industrial Certificate...'),
            ],
          ),
        ),
      );
    }

    final cert = _certificate!;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Training Certificate',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Certificate',
            onPressed: () => CertificateService.instance.sharePdf(cert),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Certificate Document Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(color: AppConstants.primaryBlue, width: 2),
                  boxShadow: AppConstants.cardHoverShadow,
                ),
                child: Column(
                  children: [
                    // Header Logo & Directorate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const IndustrialHelmetLogo(size: 26, showBadgeCircle: false),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SAFESIM INDUSTRIAL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppConstants.primaryBlue,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Safety Directorate & Standards Board',
                                  style: TextStyle(fontSize: 9, color: AppConstants.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.successLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppConstants.successGreen.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'OFFLINE VERIFIED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Certificate Title
                    Text(
                      'CERTIFICATE OF TRAINING COMPLETION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This training record confirms that',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Worker Name
                    Text(
                      (cert.workerName ?? cert.workerId).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    Text(
                      'Worker ID: ${cert.workerId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Module Description
                    Text(
                      'has met all proficiency standards in theoretical protocol and interactive virtual hazard mitigation for',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppConstants.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.scaffoldBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cert.module.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bottom info: Date, Score, QR, Signature
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${cert.issuedAt}',
                              style: TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                            ),
                            Text(
                              'Score: ${cert.score}% (PASSED)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppConstants.successGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cert.certificateId,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ],
                        ),

                        // Center Offline QR Code
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppConstants.dividerColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: QrImageView(
                                data: cert.qrCode, // Strictly SAFE-FIRE-2026-XXXXXXXX
                                version: QrVersions.auto,
                                size: 68.0,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scan to Verify',
                              style: TextStyle(fontSize: 8, color: AppConstants.textMuted),
                            ),
                          ],
                        ),

                        // Right Signatory
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(width: 100, height: 1, color: AppConstants.textSecondary),
                            const SizedBox(height: 4),
                            Text(
                              'Safety Director',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'SafeSim Board',
                              style: TextStyle(fontSize: 8, color: AppConstants.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 28),

              // Action Buttons: View, Save, Share
              PrimaryButton(
                text: 'View / Print PDF',
                icon: Icons.print_rounded,
                onPressed: () => CertificateService.instance.viewOrPrintPdf(cert),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: _isSaving ? 'Saving PDF...' : 'Save PDF Locally',
                icon: Icons.save_alt_rounded,
                onPressed: _isSaving ? null : _saveLocally,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Share Certificate',
                icon: Icons.share_rounded,
                onPressed: () => CertificateService.instance.sharePdf(cert),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home Dashboard'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
