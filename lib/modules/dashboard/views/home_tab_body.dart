import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../data/models/study_plan_model.dart';
import '../../../routes/app_routes.dart';
import '../../main/controllers/main_shell_controller.dart';
import '../controllers/dashboard_controller.dart';

/// §18: Home Dashboard tab -- greeting, preparation progress, today's
/// recommended topics (from the §17 rule-based study plan), and stats.
class HomeTabBody extends GetView<DashboardController> {
  const HomeTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        switch (controller.status.value) {
          case DashboardStatus.loading:
            return const AppLoadingView(message: 'Loading your dashboard...');
          case DashboardStatus.error:
            return AppErrorView(
              message: controller.errorMessage.value ?? 'Something went wrong.',
              onRetry: controller.load,
            );
          case DashboardStatus.loaded:
            return _DashboardBody(controller: controller);
        }
      }),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardController controller;
  const _DashboardBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final firstName = (user?.fullName ?? '').split(' ').firstOrNull ?? 'there';

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $firstName 👋',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      controller.examName.isNotEmpty
                          ? '${controller.examName} Preparation'
                          : 'Select an exam to get started',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ProgressCard(controller: controller),
          const SizedBox(height: 24),
          Text('Today\'s Preparation', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (controller.recommendedTopics.isEmpty)
            const _EmptyRecommendations()
          else
            for (final item in controller.recommendedTopics) _RecommendedTopicCard(item: item),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Get.toNamed(Routes.personalizedPlan),
            icon: const Icon(Icons.map_outlined),
            label: const Text('View Full Study Plan'),
          ),
          const SizedBox(height: 24),
          Text('Your Stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                  label: 'Questions Practiced',
                  value: '${user?.questionsAttempted ?? 0}',
                  icon: Icons.quiz_outlined),
              _StatCard(
                  label: 'Tests Completed',
                  value: '${user?.testsAttempted ?? 0}',
                  icon: Icons.fact_check_outlined),
              _StatCard(
                  label: 'Accuracy',
                  value: '${(user?.overallAccuracy ?? 0).toStringAsFixed(0)}%',
                  icon: Icons.gps_fixed_rounded),
              _StatCard(
                  label: 'Topics Mastered',
                  value: '${controller.topicsMastered}',
                  icon: Icons.emoji_events_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final DashboardController controller;
  const _ProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final progress = controller.preparationProgress / 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preparation Progress',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text('${controller.preparationProgress.toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedTopicCard extends StatelessWidget {
  final StudyPlanItemModel item;
  const _RecommendedTopicCard({required this.item});

  Color get _priorityColor {
    switch (item.priority) {
      case 'high':
        return AppColors.weak;
      case 'medium':
        return AppColors.average;
      default:
        return AppColors.strong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.find<MainShellController>().changeTab(3),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.subjectName,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(item.topicName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(item.actionLabel,
                        style: TextStyle(
                            fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Complete a diagnostic assessment to get your personalized topic '
        'recommendations here.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
