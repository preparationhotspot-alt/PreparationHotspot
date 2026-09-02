import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../data/models/question_model.dart';
import '../controllers/assessment_controller.dart';

class AssessmentQuestionView extends GetView<AssessmentController> {
  const AssessmentQuestionView({super.key});

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            'Question ${controller.currentIndex.value + 1}/${controller.totalQuestions}')),
        actions: [
          Obx(() {
            final urgent = controller.remainingSeconds.value < 60;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 18, color: urgent ? AppColors.error : AppColors.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(controller.remainingSeconds.value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: urgent ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      endDrawer: _QuestionPaletteDrawer(controller: controller),
      body: SafeArea(
        child: Obx(() {
          final question = controller.currentQuestion;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _Chip(label: question.subjectName),
                    const SizedBox(width: 8),
                    _Chip(label: question.difficulty),
                    const Spacer(),
                    Builder(
                      builder: (ctx) => TextButton.icon(
                        onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                        icon: const Icon(Icons.grid_view_rounded, size: 18),
                        label: const Text('Palette'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.questionText,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 20),
                      _AnswerInput(controller: controller, question: question),
                    ],
                  ),
                ),
              ),
              _BottomNav(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.primary)),
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final AssessmentController controller;
  final QuestionModel question;
  const _AnswerInput({required this.controller, required this.question});

  @override
  Widget build(BuildContext context) {
    if (question.isTextEntry) {
      return Obx(() {
        final current = controller.answers[question.questionId] as String? ?? '';
        return TextFormField(
          key: ValueKey(question.questionId),
          initialValue: current,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: const InputDecoration(
            labelText: 'Your answer',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setTextAnswer,
        );
      });
    }

    return Obx(() {
      final selected = controller.answers[question.questionId];
      return Column(
        children: question.options.map((option) {
          final isSelected = question.isMultipleChoice
              ? (selected as List?)?.contains(option.key) ?? false
              : selected == option.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => question.isMultipleChoice
                  ? controller.toggleMultipleAnswer(option.key)
                  : controller.selectSingleAnswer(option.key),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      question.isMultipleChoice
                          ? (isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank)
                          : (isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(option.text)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _BottomNav extends StatelessWidget {
  final AssessmentController controller;
  const _BottomNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(() => Row(
            children: [
              if (controller.currentIndex.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousQuestion,
                    child: const Text('Previous'),
                  ),
                ),
              if (controller.currentIndex.value > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: controller.isLastQuestion
                      ? () => _confirmSubmit(controller)
                      : controller.nextQuestion,
                  child: Text(controller.isLastQuestion ? 'Submit' : 'Next'),
                ),
              ),
            ],
          )),
    );
  }

  Future<void> _confirmSubmit(AssessmentController controller) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Submit Assessment?',
      message: 'You have answered ${controller.answeredCount} of '
          '${controller.totalQuestions} questions. Unanswered questions will '
          'be marked as skipped. This cannot be undone.',
      confirmLabel: 'Submit',
      cancelLabel: 'Review Again',
    );
    if (confirmed) controller.submitAssessment();
  }
}

class _QuestionPaletteDrawer extends StatelessWidget {
  final AssessmentController controller;
  const _QuestionPaletteDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Question Palette', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Obx(() => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: controller.totalQuestions,
                    itemBuilder: (context, index) {
                      final question = controller.questions[index];
                      final answered = controller.isAnswered(question.questionId);
                      final visited = controller.visited.contains(question.questionId);
                      final isCurrent = controller.currentIndex.value == index;

                      Color color = AppColors.border;
                      if (answered) {
                        color = AppColors.strong;
                      } else if (visited) {
                        color = AppColors.weak;
                      }

                      return InkWell(
                        onTap: () {
                          controller.goToQuestion(index);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.primary : color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : color,
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: const [
                  _Legend(color: AppColors.strong, label: 'Answered'),
                  _Legend(color: AppColors.weak, label: 'Visited'),
                  _Legend(color: AppColors.border, label: 'Not visited'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
