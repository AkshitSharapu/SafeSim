import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress.dart';
import '../models/certificate.dart';
import '../database/app_database.dart';
import '../utils/app_constants.dart';
import 'auth_provider.dart';

class ProgressState {
  final WorkerProgress? activeProgress;
  final List<Certificate> certificates;
  final Map<String, dynamic> stats;
  final bool isLoading;

  const ProgressState({
    this.activeProgress,
    this.certificates = const [],
    this.stats = const {
      'completedModules': 0,
      'totalAttempts': 0,
      'averageScore': 0,
      'certificatesEarned': 0,
    },
    this.isLoading = false,
  });

  ProgressState copyWith({
    WorkerProgress? activeProgress,
    List<Certificate>? certificates,
    Map<String, dynamic>? stats,
    bool? isLoading,
  }) {
    return ProgressState(
      activeProgress: activeProgress ?? this.activeProgress,
      certificates: certificates ?? this.certificates,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final Ref ref;

  ProgressNotifier(this.ref) : super(const ProgressState()) {
    // Automatically load progress when auth state updates
    ref.listen(authProvider, (previous, next) {
      if (next.currentWorker != null) {
        loadData(next.currentWorker!.id);
      } else {
        state = const ProgressState();
      }
    });
  }

  Future<void> loadData(String workerId, {String moduleId = AppConstants.defaultModuleId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final progress = await AppDatabase.instance.getProgress(workerId, moduleId);
      final certs = await AppDatabase.instance.getCertificatesForWorker(workerId);
      final stats = await AppDatabase.instance.getWorkerStats(workerId);

      state = state.copyWith(
        activeProgress: progress,
        certificates: certs,
        stats: stats,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshActiveWorker() async {
    final worker = ref.read(authProvider).currentWorker;
    if (worker != null) {
      await loadData(worker.id);
    }
  }
}

final progressProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier(ref);
});
