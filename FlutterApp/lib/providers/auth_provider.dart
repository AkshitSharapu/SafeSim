import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/worker.dart';
import '../database/app_database.dart';
import '../utils/app_constants.dart';

class AuthState {
  final Worker? currentWorker;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.currentWorker,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => currentWorker != null;

  AuthState copyWith({
    Worker? currentWorker,
    bool? isLoading,
    String? errorMessage,
    bool clearWorker = false,
  }) {
    return AuthState(
      currentWorker: clearWorker ? null : (currentWorker ?? this.currentWorker),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Attempts to restore previously logged in worker from SharedPreferences
  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(AppConstants.prefsActiveWorkerId);
      if (savedId != null && savedId.isNotEmpty) {
        final worker = await AppDatabase.instance.getWorkerByCodeOrId(savedId);
        if (worker != null) {
          state = state.copyWith(currentWorker: worker, isLoading: false);
          return;
        }
      }
    } catch (_) {}
    state = state.copyWith(isLoading: false);
  }

  /// Logs in a worker using QR code string or manual ID (e.g. 'WK001')
  Future<bool> loginWithCode(String code) async {
    if (state.isLoading) return false;
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter or scan a valid Worker ID.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final worker = await AppDatabase.instance.getWorkerByCodeOrId(cleanCode);
      if (worker != null) {
        // Persist active worker session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.prefsActiveWorkerId, worker.id);

        state = state.copyWith(currentWorker: worker, isLoading: false, errorMessage: null);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Worker "$cleanCode" not found in local offline registry.',
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('SafeSim database login failed: $e\n$stack');
      state = state.copyWith(
        isLoading: false,
        errorMessage: kIsWeb
          ? 'Browser database could not open. Run RUN_CHROME.cmd from FlutterApp, then refresh localhost:7357. Check the browser console if this continues.'
          : 'Database error: Unable to read local worker record.',
      );
      return false;
    }
  }

  /// Logs out worker
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefsActiveWorkerId);
    } catch (_) {}
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
