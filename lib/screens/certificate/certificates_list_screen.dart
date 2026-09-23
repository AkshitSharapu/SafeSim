import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../services/certificate_service.dart';
import '../../widgets/certificate_card.dart';
import '../../widgets/primary_button.dart';

class CertificatesListScreen extends ConsumerWidget {
  const CertificatesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider);
    final authState = ref.watch(authProvider);
    final certificates = progressState.certificates;
    final worker = authState.currentWorker;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Accredited Certificates',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: certificates.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppConstants.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          size: 64,
                          color: AppConstants.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Certificates Yet',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete the Fire & Explosion simulation and achieve 70% in the assessment quiz to earn your industrial credential.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppConstants.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: 'Start Fire Training',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          context.push('/modules/${AppConstants.defaultModuleId}');
                        },
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(progressProvider.notifier).refreshActiveWorker(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: certificates.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final cert = certificates[index];
                    return CertificateCard(
                      certificate: cert,
                      onView: () => CertificateService.instance.viewOrPrintPdf(cert),
                      onShare: () => CertificateService.instance.sharePdf(cert),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
