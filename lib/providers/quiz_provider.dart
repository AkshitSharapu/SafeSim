import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';
import '../models/progress.dart';
import '../database/app_database.dart';
import '../utils/app_constants.dart';
import 'progress_provider.dart';

class QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOptionIndex;
  final bool isAnswerSubmitted;
  final int correctAnswers;
  final int mistakes;
  final bool isCompleted;
  final bool isLoading;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedOptionIndex,
    this.isAnswerSubmitted = false,
    this.correctAnswers = 0,
    this.mistakes = 0,
    this.isCompleted = false,
    this.isLoading = false,
  });

  QuizQuestion? get currentQuestion =>
      (questions.isNotEmpty && currentIndex < questions.length) ? questions[currentIndex] : null;

  int get totalQuestions => questions.length;
  double get progressRatio => totalQuestions > 0 ? (currentIndex + 1) / totalQuestions : 0.0;
  int get scorePercentage => totalQuestions > 0 ? ((correctAnswers / totalQuestions) * 100).round() : 0;
  bool get hasPassed => scorePercentage >= 70;

  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedOptionIndex,
    bool? isAnswerSubmitted,
    int? correctAnswers,
    int? mistakes,
    bool? isCompleted,
    bool? isLoading,
    bool clearSelection = false,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIndex: clearSelection ? null : (selectedOptionIndex ?? this.selectedOptionIndex),
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      mistakes: mistakes ?? this.mistakes,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref ref;

  QuizNotifier(this.ref) : super(const QuizState()) {
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true);
    try {
      final jsonString = await rootBundle.loadString('assets/data/questions.json');
      final List<dynamic> list = json.decode(jsonString);
      final questions = list.map((q) => QuizQuestion.fromMap(q)).toList();

      state = QuizState(
        questions: questions,
        currentIndex: 0,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void submitAnswer(int optionIndex) {
    if (state.isAnswerSubmitted || state.currentQuestion == null) return;

    final isCorrect = optionIndex == state.currentQuestion!.correctIndex;

    state = state.copyWith(
      selectedOptionIndex: optionIndex,
      isAnswerSubmitted: true,
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
      mistakes: !isCorrect ? state.mistakes + 1 : state.mistakes,
    );
  }

  Future<void> proceedToNext(String workerId, {String moduleId = AppConstants.defaultModuleId}) async {
    if (state.currentIndex + 1 < state.totalQuestions) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelection: true,
        isAnswerSubmitted: false,
      );
    } else {
      // Completed quiz!
      state = state.copyWith(isCompleted: true);

      // Persist results to SQLite
      final passed = state.hasPassed;
      final finalScore = state.scorePercentage;
      final progressRecord = WorkerProgress(
        workerId: workerId,
        moduleId: moduleId,
        completed: passed,
        score: finalScore,
        mistakes: state.mistakes,
        attempts: 1, // Will merge or increment in database
        completedAt: DateTime.now().toIso8601String(),
      );

      await AppDatabase.instance.saveProgress(progressRecord);
      await ref.read(progressProvider.notifier).refreshActiveWorker();
    }
  }

  void restartQuiz() {
    state = QuizState(
      questions: state.questions,
      currentIndex: 0,
      selectedOptionIndex: null,
      isAnswerSubmitted: false,
      correctAnswers: 0,
      mistakes: 0,
      isCompleted: false,
      isLoading: false,
    );
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});
