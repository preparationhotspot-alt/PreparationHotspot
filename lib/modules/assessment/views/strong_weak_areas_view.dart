import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/accuracy_ring.dart';
import '../../../core/widgets/stat_chip.dart';
import '../../../core/widgets/topic_area_section.dart';
import '../../../data/models/user_performance_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/assessment_controller.dart';

void _reviewTopic(UserPerformanceModel topic) => Get.toNamed(
      Routes.answerReview,
      arguments: {'topicId': topic.topicId, 'topicName': topic.topicName},
    );

/// §15/§23: shows strong / average / weak topics with the "why" behind each
/// -- not just a label, but accuracy + attempt counts so it's
/// self-explanatory -- plus the score summary and answer review access
/// (this is the single screen students land on right after submitting).
class StrongWeakAreasView extends GetView<AssessmentController> {
  const StrongWeakAreasView({super.key});

  @override
  Widget build(BuildContext context) {
    final result = controller.result;

    return Scaffold(
      appBar: AppBar(title: const Text('Strong & Weak Areas'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (result != null) ...[
              Center(
                child: AccuracyRing(value: result.accuracy, size: 120, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Overall Accuracy · Score ${result.score}',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: StatChip(
                          label: 'Correct',
                          value: '${result.correctAnswers}',
                          color: AppColors.strong)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: StatChip(
                          label: 'Incorrect',
                          value: '${result.incorrectAnswers}',
                          color: AppColors.weak)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: StatChip(
                          label: 'Skipped',
                          value: '${result.unanswered}',
                          color: AppColors.insufficientData)),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.answerReview),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Review All Answers'),
                ),
              ),
              const SizedBox(height: 24),
            ],
            if (controller.weakTopics.isNotEmpty)
              TopicAreaSection(
                title: 'Needs Improvement',
                emoji: '🎯',
                color: AppColors.weak,
                bgColor: AppColors.weakBg,
                topics: controller.weakTopics,
                onTapTopic: _reviewTopic,
              ),
            if (controller.averageTopics.isNotEmpty)
              TopicAreaSection(
                title: 'Average',
                emoji: '💪',
                color: AppColors.average,
                bgColor: AppColors.averageBg,
                topics: controller.averageTopics,
                onTapTopic: _reviewTopic,
              ),
            if (controller.strongTopics.isNotEmpty)
              TopicAreaSection(
                title: 'Strong',
                emoji: '🏆',
                color: AppColors.strong,
                bgColor: AppColors.strongBg,
                topics: controller.strongTopics,
                onTapTopic: _reviewTopic,
              ),
            if (controller.insufficientDataTopics.isNotEmpty)
              TopicAreaSection(
                title: 'Not Enough Data Yet',
                emoji: '📊',
                color: AppColors.insufficientData,
                bgColor: AppColors.background,
                topics: controller.insufficientDataTopics,
                subtitle: 'Attempt more questions on these topics through '
                    'Practice to get a performance rating -- each needs at '
                    'least 3 attempted questions.',
                onTapTopic: _reviewTopic,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.goToPersonalizedPlan,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('See My Preparation Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
