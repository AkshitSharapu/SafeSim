import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_dashboard_screen.dart';
import '../certificate/certificates_list_screen.dart';
import '../verification/verification_screen.dart';
import '../profile/profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../utils/app_constants.dart';

class HomeNavWrapper extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeNavWrapper({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeNavWrapper> createState() => _HomeNavWrapperState();
}

class _HomeNavWrapperState extends ConsumerState<HomeNavWrapper> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Refresh progress on home mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(progressProvider.notifier).refreshActiveWorker();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeDashboardScreen(),
      const CertificatesListScreen(),
      const VerificationScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppConstants.primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.workspace_premium_outlined),
            selectedIcon: Icon(Icons.workspace_premium, color: AppConstants.primaryBlue),
            label: 'Certificates',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified, color: AppConstants.primaryBlue),
            label: 'Verify',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppConstants.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
