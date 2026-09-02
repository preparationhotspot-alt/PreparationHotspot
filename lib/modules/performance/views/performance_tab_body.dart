import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../core/widgets/topic_area_section.dart';
import '../../../data/models/user_performance_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/performance_overview_controller.dart';

void _reviewTopic(UserPerformanceModel topic) => Get.toNamed(
      Routes.answerReview,
      arguments: {'topicId': topic.topicId, 'topicName': topic.topicName},
    );

/// §26: "My Performance" tab -- cumulative topic-level performance across
/// all diagnostic attempts (not tied to a single just-submitted assessment).
class PerformanceTabBody extends GetView<PerformanceOverviewController> {
  const PerformanceTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        switch (controller.status.value) {
          case PerformanceOverviewStatus.loading:
            return const AppLoadingView(message: 'Loading your performance...');
          case PerformanceOverviewStatus.error:
            return AppErrorView(
              message: controller.errorMessage.value ?? 'Something went wrong.',
              onRetry: controller.load,
            );
          case PerformanceOverviewStatus.empty:
            return const AppEmptyView(
              title: 'No performance data yet',
              subtitle: 'Complete a diagnostic assessment or practice '
                  'session to see your strong and weak topics here.',
              icon: Icons.insights_outlined,
            );
          case PerformanceOverviewStatus.loaded:
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('My Performance', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
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
                    subtitle: 'Attempt more questions on these topics '
                        'through Practice to get a performance rating -- '
                        'each needs at least 3 attempted questions.',
                    onTapTopic: _reviewTopic,
                  ),
              ],
            );
        }
      }),
    );
  }
}
