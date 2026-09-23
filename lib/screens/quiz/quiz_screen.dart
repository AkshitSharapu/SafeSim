import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Restart or load clean quiz on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizProvider.notifier).restartQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final auth = ref.watch(authProvider);
    final worker = auth.currentWorker;
    final workerId = worker?.id ?? 'WK001';

    if (quiz.isLoading || quiz.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppConstants.scaffoldBg,
        appBar: AppBar(title: const Text('Safety Competency Exam')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (quiz.isCompleted) {
      return _buildCompletionView(context, quiz, workerId);
    }

    final currentQuestion = quiz.currentQuestion!;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Assessment: Question ${quiz.currentIndex + 1} of ${quiz.totalQuestions}',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Indicator
            LinearProgressIndicator(
              value: quiz.progressRatio,
              backgroundColor: AppConstants.dividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryBlue),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Number Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.accentLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'QUESTION ${quiz.currentIndex + 1}/${quiz.totalQuestions}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.primaryBlue,
                            ),
                          ),
                        ),
                        Text(
                          'Score: ${quiz.correctAnswers} / ${quiz.currentIndex + (quiz.isAnswerSubmitted ? 1 : 0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Text
                    Text(
                      currentQuestion.question,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options List
                    ...List.generate(currentQuestion.options.length, (index) {
                      final optionText = currentQuestion.options[index];
                      return _buildOptionCard(
                        index: index,
                        text: optionText,
                        correctIndex: currentQuestion.correctIndex,
                        selectedIndex: quiz.selectedOptionIndex,
                        isSubmitted: quiz.isAnswerSubmitted,
                        onTap: () {
                          if (!quiz.isAnswerSubmitted) {
                            ref.read(quizProvider.notifier).submitAnswer(index);
                          }
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // Immediate Feedback & Explanation Card
                    if (quiz.isAnswerSubmitted) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                              ? AppConstants.successLight
                              : AppConstants.dangerLight,
                          borderRadius: AppConstants.borderRadius,
                          border: Border.all(
                            color: (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                                ? AppConstants.successGreen.withValues(alpha: 0.4)
                                : AppConstants.dangerRed.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                                      ? AppConstants.successGreen
                                      : AppConstants.dangerRed,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                                      ? 'Correct Answer!'
                                      : 'Incorrect Choice',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: (quiz.selectedOptionIndex == currentQuestion.correctIndex)
                                        ? AppConstants.successGreen
                                        : AppConstants.dangerRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.explanation,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppConstants.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Continue / Next Question Button Bar
            if (quiz.isAnswerSubmitted)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppConstants.dividerColor)),
                ),
                child: PrimaryButton(
                  text: quiz.currentIndex + 1 < quiz.totalQuestions ? 'Next Question' : 'Complete Assessment',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    ref.read(quizProvider.notifier).proceedToNext(workerId);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String text,
    required int correctIndex,
    required int? selectedIndex,
    required bool isSubmitted,
    required VoidCallback onTap,
  }) {
    Color cardBorder = AppConstants.dividerColor;
    Color cardBg = AppConstants.surfaceWhite;
    Color textColor = AppConstants.textPrimary;
    Widget? trailingIcon;

    if (isSubmitted) {
      if (index == correctIndex) {
        cardBorder = AppConstants.successGreen;
        cardBg = AppConstants.successLight.withValues(alpha: 0.6);
        textColor = AppConstants.successGreen;
        trailingIcon = const Icon(Icons.check_circle, color: AppConstants.successGreen, size: 20);
      } else if (index == selectedIndex) {
        cardBorder = AppConstants.dangerRed;
        cardBg = AppConstants.dangerLight.withValues(alpha: 0.6);
        textColor = AppConstants.dangerRed;
        trailingIcon = const Icon(Icons.cancel, color: AppConstants.dangerRed, size: 20);
      }
    }

    final letter = String.fromCharCode(65 + index); // A, B, C, D

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardBg,
        borderRadius: AppConstants.borderRadius,
        child: InkWell(
          onTap: isSubmitted ? null : onTap,
          borderRadius: AppConstants.borderRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: AppConstants.borderRadius,
              border: Border.all(color: cardBorder, width: isSubmitted && (index == correctIndex || index == selectedIndex) ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppConstants.scaffoldBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, QuizState quiz, String workerId) {
    final hasPassed = quiz.hasPassed;
    final score = quiz.scorePercentage;

    return Scaffold(
      backgroundColor: AppConstants.scaffoldBg,
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceWhite,
                  borderRadius: AppConstants.borderRadius,
                  border: Border.all(
                    color: hasPassed ? AppConstants.successGreen.withValues(alpha: 0.4) : AppConstants.dangerRed.withValues(alpha: 0.4),
                  ),
                  boxShadow: AppConstants.softShadow,
                ),
                child: Column(
                  children: [
                    Icon(
                      hasPassed ? Icons.workspace_premium_rounded : Icons.highlight_off_rounded,
                      size: 72,
                      color: hasPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      hasPassed ? 'SAFETY ACCREDITATION EARNED' : 'MINIMUM BENCHMARK NOT MET',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: hasPassed ? AppConstants.successGreen : AppConstants.dangerRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Final Score: $score%',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasPassed
                          ? 'Congratulations! You answered ${quiz.correctAnswers} of ${quiz.totalQuestions} questions correctly. Passing criteria: 70%.'
                          : 'You answered ${quiz.correctAnswers} of ${quiz.totalQuestions} questions correctly. 70% is required for official industrial signoff.',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppConstants.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (hasPassed) ...[
                PrimaryButton(
                  text: 'Generate Official Certificate',
                  icon: Icons.workspace_premium,
                  onPressed: () {
                    context.push('/certificate', extra: {'score': score});
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Return to Dashboard',
                  onPressed: () => context.go('/home'),
                ),
              ] else ...[
                PrimaryButton(
                  text: 'Re-attempt Quiz',
                  icon: Icons.refresh,
                  onPressed: () {
                    ref.read(quizProvider.notifier).restartQuiz();
                  },
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Review Safety Instructions',
                  onPressed: () => context.push('/instructions'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
