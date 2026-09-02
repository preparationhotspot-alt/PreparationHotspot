import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_state_views.dart';
import '../../../data/models/study_plan_model.dart';
import '../controllers/personalized_plan_controller.dart';

/// §13/§16/§56: "Your Preparation Plan" -- the step between Strong/Weak
/// Areas and Home in the product flow, and reachable any time afterward
/// from Home/Profile.
class PersonalizedPlanView extends GetView<PersonalizedPlanController> {
  const PersonalizedPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Preparation Plan')),
      body: SafeArea(
        child: Obx(() {
          switch (controller.status.value) {
            case PersonalizedPlanStatus.loading:
              return const AppLoadingView(message: 'Building your plan...');
            case PersonalizedPlanStatus.error:
              return AppErrorView(
                message: controller.errorMessage.value ?? 'Something went wrong.',
                onRetry: controller.load,
              );
            case PersonalizedPlanStatus.empty:
              return AppEmptyView(
                title: 'No plan yet',
                subtitle: controller.plan == null
                    ? 'Complete a diagnostic assessment to get your personalized plan.'
                    : 'Every topic looks strong right now -- nothing urgent to plan for.',
                icon: Icons.map_outlined,
              );
            case PersonalizedPlanStatus.loaded:
              return _PlanBody(controller: controller);
          }
        }),
      ),
    );
  }
}

class _PlanBody extends StatelessWidget {
  final PersonalizedPlanController controller;
  const _PlanBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final plan = controller.plan!;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(plan.description,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (controller.highPriority.isNotEmpty)
                _PrioritySection(
                  title: 'Focus on These First',
                  emoji: '🎯',
                  color: AppColors.weak,
                  items: controller.highPriority,
                ),
              if (controller.mediumPriority.isNotEmpty)
                _PrioritySection(
                  title: 'Keep Practicing',
                  emoji: '💪',
                  color: AppColors.average,
                  items: controller.mediumPriority,
                ),
              if (controller.lowPriority.isNotEmpty)
                _PrioritySection(
                  title: 'Revise Periodically',
                  emoji: '🏆',
                  color: AppColors.strong,
                  items: controller.lowPriority,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: controller.startLearning,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Start Learning'),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrioritySection extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final List<StudyPlanItemModel> items;
  const _PrioritySection({
    required this.title,
    required this.emoji,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${item.subjectName} · ${item.topicName}',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      Text('${item.accuracy.toStringAsFixed(0)}%',
                          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.reason,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip('${item.recommendedQuestions} Questions'),
                      _Chip(item.recommendedDifficulty),
                      _Chip(item.actionLabel),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
    );
  }
}
