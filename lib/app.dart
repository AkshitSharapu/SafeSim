import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'models/simulation_result.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/qr_login_screen.dart';
import 'screens/home/home_nav_wrapper.dart';
import 'screens/modules/module_details_screen.dart';
import 'screens/simulation/safety_instructions_screen.dart';
import 'screens/simulation/simulation_loading_screen.dart';
import 'screens/results/results_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/certificate/certificate_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const QrLoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeNavWrapper(),
      ),
      GoRoute(
        path: '/modules/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId'] ?? 'MOD-FIRE-01';
          return ModuleDetailsScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/instructions',
        builder: (context, state) => const SafetyInstructionsScreen(),
      ),
      GoRoute(
        path: '/simulation-loading',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final workerId = extra['workerId'] as String? ?? 'WK001';
          final moduleId = extra['moduleId'] as String? ?? 'MOD-FIRE-01';
          return SimulationLoadingScreen(workerId: workerId, moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) {
          final result = state.extra as SimulationResult? ??
              const SimulationResult(
                workerId: 'WK001',
                moduleId: 'MOD-FIRE-01',
                passed: true,
                score: 92,
                mistakes: 1,
                duration: 165,
              );
          return ResultsScreen(result: result);
        },
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/certificate',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final score = extra?['score'] as int? ?? 90;
          return CertificateScreen(score: score);
        },
      ),
    ],
  );
});

class SafeSimApp extends ConsumerWidget {
  const SafeSimApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SafeSim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
