import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/certificate.dart';
import '../utils/app_constants.dart';

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onView;
  final VoidCallback onShare;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onView,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceWhite,
        borderRadius: AppConstants.borderRadius,
        border: Border.all(color: AppConstants.dividerColor),
        boxShadow: AppConstants.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini QR Preview
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppConstants.dividerColor),
                  ),
                  child: QrImageView(
                    data: certificate.qrCode, // Strictly SAFE-FIRE-2026-XXXXXXXX
                    version: QrVersions.auto,
                    size: 50.0,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 14),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.module,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${certificate.certificateId}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Issued: ${certificate.issuedAt}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppConstants.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${certificate.score}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.successGreen,
                        ),
                      ),
                      Text(
                        'PASSED',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
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
            const Divider(color: AppConstants.dividerColor, height: 1),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: Text(
                      'View / Print',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryBlue,
                      side: const BorderSide(color: AppConstants.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(40),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 16),
                    label: Text(
                      'Share PDF',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentLight,
                      foregroundColor: AppConstants.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(40),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
