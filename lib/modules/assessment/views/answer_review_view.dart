import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/question_review_model.dart';
import '../controllers/assessment_controller.dart';

/// §23: per-question review -- "Your Answer / Correct Answer / Explanation
/// / Related Topic" -- reachable either for the whole assessment or scoped
/// to a single topic (e.g. tapping a weak topic on the strong/weak screen).
/// Arguments (optional): {'topicId': String, 'topicName': String}.
class AnswerReviewView extends GetView<AssessmentController> {
  const AnswerReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final topicId = args?['topicId'] as String?;
    final topicName = args?['topicName'] as String?;

    final all = controller.result?.reviewAnswers ?? [];
    final questions =
        topicId == null ? all : all.where((q) => q.topicId == topicId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(topicName ?? 'Review Answers')),
      body: SafeArea(
        child: questions.isEmpty
            ? const Center(child: Text('No questions to review.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _ReviewCard(index: index, review: questions[index]),
              ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final QuestionReviewModel review;
  const _ReviewCard({required this.index, required this.review});

  bool _isCorrectOption(String key) {
    final correct = review.correctAnswer;
    if (correct is List) return correct.contains(key);
    return correct == key;
  }

  bool _isSelectedOption(String key) {
    final selected = review.selectedAnswer;
    if (selected is List) return selected.contains(key);
    return selected == key;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = !review.isAnswered
        ? AppColors.insufficientData
        : review.isCorrect
            ? AppColors.strong
            : AppColors.weak;
    final statusLabel =
        !review.isAnswered ? 'Skipped' : review.isCorrect ? 'Correct' : 'Incorrect';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Q${index + 1}. ${review.questionText}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final option in review.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OptionRow(
                text: option['text'] ?? '',
                isCorrect: _isCorrectOption(option['key']),
                isSelected: _isSelectedOption(option['key']),
              ),
            ),
          if (review.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explanation',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(review.explanation,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final bool isSelected;
  const _OptionRow({required this.text, required this.isCorrect, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.background;
    Color border = AppColors.border;
    IconData? icon;
    Color? iconColor;

    if (isCorrect) {
      bg = AppColors.strongBg;
      border = AppColors.strong;
      icon = Icons.check_circle;
      iconColor = AppColors.strong;
    } else if (isSelected) {
      bg = AppColors.weakBg;
      border = AppColors.weak;
      icon = Icons.cancel;
      iconColor = AppColors.weak;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (icon != null) Icon(icon, size: 18, color: iconColor),
        ],
      ),
    );
  }
}
